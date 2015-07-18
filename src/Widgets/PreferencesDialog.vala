public class PreferencesDialog : Gtk.Dialog {
    private enum StylesheetState {
        NONE,
        DEFAULT,
        CUSTOM
    }

    private Preferences prefs;

    private Gtk.FontButton font_btn;

    private Gtk.ListStore schemes_store;
    private Gtk.TreeIter schemes_iter;
    private Gtk.ComboBox scheme_box;

    private Gtk.CheckButton autosave_btn;
    private Gtk.SpinButton autosave_spin;

    private Gtk.Switch dark_theme_switch;

    private Gtk.ListStore stylesheet_store;
    private Gtk.ComboBox stylesheet_box;
    private Gtk.FileChooserButton stylesheet_chooser;

    private Gtk.Switch syntax_highlighting_switch;

    private Gtk.Revealer csb_revealer;

    private const string DEFAULT_STYLESHEET = "https://github.com/sindresorhus/github-markdown-css/raw/gh-pages/github-markdown.css";

    public PreferencesDialog (Window parent, Preferences prefs) {
        this.set_transient_for (parent);
        this.prefs = prefs;

        setup_ui ();
        setup_events ();
    }

    private void setup_ui () {
        this.title = _("Preferences");
        this.window_position = Gtk.WindowPosition.CENTER;
        this.set_modal (true);
        this.border_width = 10;

        var main_layout = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);

        var editor_prefs = get_editor_prefs ();
        var preview_prefs = get_preview_prefs ();

        var stack = new Gtk.Stack ();
        stack.halign = Gtk.Align.CENTER;
        var switcher = new Gtk.StackSwitcher ();

        switcher.halign = Gtk.Align.CENTER;
        switcher.set_stack (stack);

        stack.add_titled (editor_prefs, "editor-prefs", _("Editor"));
        stack.add_titled (preview_prefs, "preview-prefs", _("Preview"));

        main_layout.pack_start (switcher);
        main_layout.pack_start (stack);

        get_content_area ().add (main_layout);
    }

    private void setup_events () {
        font_btn.font_set.connect (() => {
            unowned string name = font_btn.get_font_name ();
            prefs.editor_font = name;
        });

        scheme_box.changed.connect(() => {
            Value box_val;
            scheme_box.get_active_iter (out schemes_iter);
            schemes_store.get_value (schemes_iter, 0, out box_val);

            var scheme_id = (string) box_val;
            prefs.editor_scheme = scheme_id;
        });

        autosave_btn.toggled.connect((b) => {
            if (autosave_btn.get_active ()) {
                prefs.autosave_interval = (int) autosave_spin.get_value ();
            } else {
                prefs.autosave_interval = 0;
            }
        });
        autosave_spin.changed.connect(() => {
            if (!autosave_btn.get_active ()) {
                return;
            }
            prefs.autosave_interval = (int) autosave_spin.get_value ();
        });

        dark_theme_switch.state_set.connect((state) => {
            prefs.prefer_dark_theme = !dark_theme_switch.get_state ();
            // let the signal bubble down
            return false;
        });

        stylesheet_box.changed.connect (() => {
            Gtk.TreeIter iter;
            stylesheet_box.get_active_iter (out iter);

            GLib.Value state_value;
            stylesheet_store.get_value (iter, 1, out state_value);
            StylesheetState state = (StylesheetState) state_value.get_int ();

            switch (state) {
            case StylesheetState.NONE:
                prefs.render_stylesheet = false;
                csb_revealer.set_reveal_child (false);
                break;

            case StylesheetState.CUSTOM:
                csb_revealer.set_reveal_child (true);
                break;

            case StylesheetState.DEFAULT:
                prefs.render_stylesheet = true;
                prefs.render_stylesheet_uri = "";
                csb_revealer.set_reveal_child (false);
                break;
            }
        });

        syntax_highlighting_switch.state_set.connect((state) => {
            prefs.render_syntax_highlighting = !syntax_highlighting_switch.get_state ();

            return false;
        });
    }

    private Gtk.Grid get_editor_prefs () {
        var layout = new Gtk.Grid ();
        layout.margin = 10;
        layout.row_spacing = 12;
        layout.column_spacing = 9;
        int row = 0;

        font_btn = new Gtk.FontButton ();
        font_btn.use_font = true;
        font_btn.use_size = true;

        if (prefs.editor_font != "") {
            font_btn.set_font_name (prefs.editor_font);
        }

        var font_label = new Gtk.Label.with_mnemonic (_("Editor _font:"));
        font_label.mnemonic_widget = font_btn;

        layout.attach (font_label, 0, row, 1, 1);
        layout.attach_next_to (font_btn, font_label, Gtk.PositionType.RIGHT, 1, 1);
        row++;

        schemes_store = new Gtk.ListStore (2, typeof (string), typeof (string));

        scheme_box = new Gtk.ComboBox.with_model (schemes_store);
        var scheme_renderer = new Gtk.CellRendererText ();
        scheme_box.pack_start (scheme_renderer, true);
        scheme_box.add_attribute (scheme_renderer, "text", 1);

        var schemes = this.get_source_schemes ();
        int i = 0;
        schemes_iter = {};
        foreach (var scheme in schemes) {
            schemes_store.append (out schemes_iter);
            schemes_store.set (schemes_iter, 0, scheme.id, 1, scheme.name);

            if (scheme.id == prefs.editor_scheme) {
                scheme_box.active = i;
            }

            i++;
        }

        var scheme_label = new Gtk.Label.with_mnemonic (_("Editor _theme:"));
        scheme_label.mnemonic_widget = scheme_box;

        layout.attach (scheme_label, 0, row, 1, 1);
        layout.attach_next_to (scheme_box, scheme_label, Gtk.PositionType.RIGHT, 1, 1);
        row++;

        // Autosave
        autosave_btn = new Gtk.CheckButton.with_label (_("Save automatically every"));
        autosave_spin = new Gtk.SpinButton.with_range (0, 999, 1);
        autosave_btn.set_active (prefs.autosave_interval != 0);

        if (prefs.autosave_interval != 0) {
            autosave_spin.set_value (prefs.autosave_interval);
        } else {
            autosave_spin.set_value (10);
        }

//        hbox.pack_start (autosave_btn, false, false, 0);
//        hbox.pack_start (autosave_spin, false, false, 0);
//        hbox.pack_start (new Gtk.Label (_("minutes")), false, false, 0);

        // Dark theme
        var dark_theme_label = new Gtk.Label (_("Enable dark theme"));
        dark_theme_switch = new Gtk.Switch ();
        dark_theme_switch.active = prefs.prefer_dark_theme;

        layout.attach (dark_theme_label, 0, row, 1, 1);
        layout.attach_next_to (dark_theme_switch, dark_theme_label, Gtk.PositionType.RIGHT, 1, 1);

        return layout;
    }

    private Gtk.Grid get_preview_prefs () {
        var layout = new Gtk.Grid ();
        layout.margin = 10;
        layout.row_spacing = 12;
        layout.column_spacing = 9;
        int row = 0;

        // Stylesheet
        stylesheet_store = new Gtk.ListStore (2, typeof (string), typeof (int));
        Gtk.TreeIter iter;

        stylesheet_store.append (out iter);
        stylesheet_store.set (iter, 0, _("Do not use a stylesheet"), 1, StylesheetState.NONE);

        stylesheet_store.append (out iter);
        stylesheet_store.set (iter, 0, _("Use the default stylesheet"), 1, StylesheetState.DEFAULT);

        stylesheet_store.append (out iter);
        stylesheet_store.set (iter, 0, _("Use a custom stylesheet"), 1, StylesheetState.CUSTOM);

        stylesheet_box = new Gtk.ComboBox.with_model (stylesheet_store);

        var text_renderer = new Gtk.CellRendererText ();
        stylesheet_box.pack_start (text_renderer, true);
        stylesheet_box.add_attribute (text_renderer, "text", 0);

        if (!prefs.render_stylesheet) {
            stylesheet_box.active = 0;
        } else if (prefs.render_stylesheet_uri == "") {
            stylesheet_box.active = 1;
        } else {
            stylesheet_box.active = 2;
        }

        var stylesheet_label = new Gtk.Label (_("Style Sheet"));

        layout.attach (stylesheet_label, 0, row, 1, 1);
        layout.attach_next_to (stylesheet_box, stylesheet_label, Gtk.PositionType.RIGHT, 1, 1);
        row++;

        var choose_stylesheet_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        stylesheet_chooser = new Gtk.FileChooserButton (_("Choose a stylesheet"),
                                                        Gtk.FileChooserAction.OPEN);

        Gtk.FileFilter stylesheet_filter = new Gtk.FileFilter ();
        stylesheet_chooser.set_filter (stylesheet_filter);
        stylesheet_filter.add_mime_type ("text/css");
        choose_stylesheet_box.pack_start (stylesheet_chooser);

        csb_revealer = new Gtk.Revealer ();
        csb_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
        csb_revealer.add (choose_stylesheet_box);
        csb_revealer.set_reveal_child (false);

        layout.attach (csb_revealer, 1, row, 1, 1);
        row++;

        var syntax_highlighting_label = new Gtk.Label (_("Enable syntax highlighting"));

        syntax_highlighting_switch = new Gtk.Switch ();
        syntax_highlighting_switch.active = prefs.render_syntax_highlighting;

/*        autosave_btn.toggled.connect((b) => {
            if (autosave_btn.get_active ()) {
                prefs.autosave_interval = (int) autosave_spin.get_value ();
            } else {
                prefs.autosave_interval = 0;
            }
        });
        autosave_spin.changed.connect(() => {
            if (!autosave_btn.get_active ()) {
                return;
            }
            prefs.autosave_interval = (int) autosave_spin.get_value ();
        });

        dark_theme_btn.toggled.connect((b) => {
            prefs.prefer_dark_theme = dark_theme_btn.get_active ();
        });

        stylesheet_none.toggled.connect((b) => {
            if (stylesheet_none.get_active ()) {
                prefs.render_stylesheet = false;
            }
        });
        stylesheet_default.toggled.connect((b) => {
            if (stylesheet_default.get_active ()) {
                prefs.render_stylesheet_uri = "";
                prefs.render_stylesheet = true;
            }
        });
        stylesheet_custom.toggled.connect((b) => {
            var activated = stylesheet_custom.get_active ();
            stylesheet_label.set_sensitive (activated);
            stylesheet_chooser.set_sensitive (activated);
        });
        stylesheet_chooser.selection_changed.connect (() => {
            prefs.render_stylesheet_uri = stylesheet_chooser.get_uri ();
            prefs.render_stylesheet = true;
        });

        syntax_highlighting_btn.toggled.connect((b) => {
            prefs.render_syntax_highlighting = syntax_highlighting_btn.get_active ();
        });
*/

        layout.attach (syntax_highlighting_label, 0, row, 1, 1);
        layout.attach_next_to (syntax_highlighting_switch, syntax_highlighting_label,
                               Gtk.PositionType.RIGHT, 1, 1);
        return layout;
    }

    private Gtk.SourceStyleScheme[] get_source_schemes () {
        var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
        unowned string[] scheme_ids = style_manager.get_scheme_ids ();
        Gtk.SourceStyleScheme[] schemes = {};

        foreach (string id in scheme_ids) {
            schemes += style_manager.get_scheme (id);
        }
        return schemes;
    }
}