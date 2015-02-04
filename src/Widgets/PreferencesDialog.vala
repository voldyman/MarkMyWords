public class PreferencesDialog : Gtk.Window {
    private Preferences prefs;

    private Gtk.FontButton font_btn;

    private Gtk.ListStore schemes_store;
    private Gtk.TreeIter schemes_iter;
    private Gtk.ComboBox scheme_box;

    private Gtk.CheckButton autosave_btn;
    private Gtk.SpinButton autosave_spin;

    private Gtk.CheckButton dark_theme_btn;

    private Gtk.RadioButton stylesheet_none;
    private Gtk.RadioButton stylesheet_default;
    private Gtk.RadioButton stylesheet_custom;
    private Gtk.Label stylesheet_label;
    private Gtk.FileChooserButton stylesheet_chooser;

    private Gtk.CheckButton syntax_highlighting_btn;

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

        int margin = 10;

        var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, margin);
        this.add (vbox);

        Gtk.Box hbox;

        // EDITOR
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, margin);
        vbox.pack_start (hbox, false, false, 0);

        var editor_label = new Gtk.Label ("<b>" + _("Editor") + "</b>");
        editor_label.set_use_markup (true);
        hbox.pack_start (editor_label, false, true, 0);

        // Editor font
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, margin);
        vbox.pack_start (hbox, false, false, 0);

        font_btn = new Gtk.FontButton ();
        font_btn.use_font = true;
        font_btn.use_size = true;

        if (prefs.editor_font != "") {
            font_btn.set_font_name (prefs.editor_font);
        }

        var font_label = new Gtk.Label.with_mnemonic (_("Editor _font:"));
        font_label.mnemonic_widget = font_btn;

        hbox.pack_start (font_label, false, false, 0);
        hbox.pack_start (font_btn, false, false, 0);

        // Editor theme
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
        vbox.pack_start (hbox, false, false, 0);

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

        hbox.pack_start (scheme_label, false, false, 0);
        hbox.pack_start (scheme_box, false, false, 0);

        // Autosave
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
        vbox.pack_start (hbox, false, false, 0);

        autosave_btn = new Gtk.CheckButton.with_label (_("Save automatically every"));
        autosave_spin = new Gtk.SpinButton.with_range (0, 999, 1);
        autosave_btn.set_active (prefs.autosave_interval != 0);
        if (prefs.autosave_interval != 0) {
            autosave_spin.set_value (prefs.autosave_interval);
        } else {
            autosave_spin.set_value (10);
        }

        hbox.pack_start (autosave_btn, false, false, 0);
        hbox.pack_start (autosave_spin, false, false, 0);
        hbox.pack_start (new Gtk.Label (_("minutes")), false, false, 0);

        // Dark theme
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
        vbox.pack_start (hbox, false, false, 0);

        dark_theme_btn = new Gtk.CheckButton.with_label (_("Enable dark theme"));
        dark_theme_btn.set_active (prefs.prefer_dark_theme);

        hbox.pack_start (dark_theme_btn, false, true, 0);

        // RENDERING
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, margin);
        vbox.pack_start (hbox, false, false, 0);

        var rendering_label = new Gtk.Label ("<b>" + _("Rendering") + "</b>");
        rendering_label.set_use_markup (true);
        hbox.pack_start (rendering_label, false, true, 0);

        // Stylesheet
        stylesheet_none = new Gtk.RadioButton.with_label_from_widget (null,
                                                                      _("Do not use a stylesheet"));

        stylesheet_default = new Gtk.RadioButton.with_label_from_widget (stylesheet_none,
                                                                         _("Use the default stylesheet"));

        stylesheet_custom = new Gtk.RadioButton.with_label_from_widget (stylesheet_none,
                                                                        _("Use a custom stylesheet"));

        vbox.pack_start (stylesheet_none, false, false, 0);
        vbox.pack_start (stylesheet_default, false, false, 0);
        vbox.pack_start (stylesheet_custom, false, false, 0);

        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
        vbox.pack_start (hbox, false, false, 0);

        stylesheet_chooser = new Gtk.FileChooserButton (_("Choose a stylesheet"),
                                                        Gtk.FileChooserAction.OPEN);

        Gtk.FileFilter stylesheet_filter = new Gtk.FileFilter ();
        stylesheet_chooser.set_filter (stylesheet_filter);
        stylesheet_filter.add_mime_type ("text/css");

        stylesheet_label = new Gtk.Label.with_mnemonic (_("Custom _stylesheet:"));
        stylesheet_label.mnemonic_widget = stylesheet_chooser;

        if (!prefs.render_stylesheet) {
            stylesheet_none.set_active (true);
        } else if (prefs.render_stylesheet_uri == "") {
            stylesheet_default.set_active (true);
        } else {
            stylesheet_custom.set_active (true);
            stylesheet_chooser.set_uri (prefs.render_stylesheet_uri);
        }

        if (!stylesheet_custom.get_active ()) {
            stylesheet_label.set_sensitive (false);
            stylesheet_chooser.set_sensitive (false);
        }

        hbox.pack_start (stylesheet_label, false, false, 20);
        hbox.pack_start (stylesheet_chooser, false, false, 0);

        // Dark theme
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
        vbox.pack_start (hbox, false, false, 0);

        syntax_highlighting_btn = new Gtk.CheckButton.with_label (_("Enable syntax highlighting"));
        syntax_highlighting_btn.set_active (prefs.render_syntax_highlighting);

        hbox.pack_start (syntax_highlighting_btn, false, true, 0);
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
                prefs.render_stylesheet = true;
                prefs.render_stylesheet_uri = "";
            }
        });
        stylesheet_custom.toggled.connect((b) => {
            var activated = stylesheet_custom.get_active ();
            stylesheet_label.set_sensitive (activated);
            stylesheet_chooser.set_sensitive (activated);
        });
        stylesheet_chooser.selection_changed.connect (() => {
            prefs.render_stylesheet = true;
            prefs.render_stylesheet_uri = stylesheet_chooser.get_uri ();
        });

        syntax_highlighting_btn.toggled.connect((b) => {
            prefs.render_syntax_highlighting = syntax_highlighting_btn.get_active ();
        });
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