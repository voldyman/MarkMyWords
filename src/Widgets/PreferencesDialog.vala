public class PreferencesDialog : Gtk.Window {
    private Gtk.FontButton font_btn;

    public PreferencesDialog (Window parent, Preferences prefs) {
        this.title = _("Preferences");
        this.window_position = Gtk.WindowPosition.CENTER;
        this.set_modal (true);
        this.set_transient_for (parent);
        this.border_width = 10;

        var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
        this.add (vbox);

        // Editor font
        var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        vbox.pack_start (hbox, false, false, 0);

        font_btn = new Gtk.FontButton ();
        font_btn.use_font = true;
        font_btn.use_size = true;

        if (prefs.editor_font != "") {
            font_btn.set_font_name (prefs.editor_font);
        }

        font_btn.font_set.connect (() => {
            unowned string name = font_btn.get_font_name ();
            prefs.editor_font = name;
        });

        var font_label = new Gtk.Label.with_mnemonic (_("Editor _font:"));
        font_label.mnemonic_widget = font_btn;

        hbox.pack_start (font_label, false, false, 0);
        hbox.pack_start (font_btn, false, false, 0);

        // Editor theme
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
        vbox.pack_start (hbox, false, false, 0);

        var schemes_store = new Gtk.ListStore (2, typeof (string), typeof (string));
        Gtk.TreeIter iter = {};
        
        var scheme_box = new Gtk.ComboBox.with_model (schemes_store);
        var scheme_renderer = new Gtk.CellRendererText ();
        scheme_box.pack_start (scheme_renderer, true);
        scheme_box.add_attribute (scheme_renderer, "text", 1);

        var schemes = this.get_source_schemes ();
        int i = 0;
        foreach (var scheme in schemes) {
            schemes_store.append (out iter);
            schemes_store.set (iter, 0, scheme.id, 1, scheme.name);

            if (scheme.id == prefs.editor_scheme) {
                scheme_box.active = i;
            }

            i++;
        }

        var scheme_label = new Gtk.Label.with_mnemonic (_("Editor _theme:"));
        scheme_label.mnemonic_widget = scheme_box;

        scheme_box.changed.connect(() => {
            Value box_val;
            scheme_box.get_active_iter (out iter);
            schemes_store.get_value (iter, 0, out box_val);

            var scheme_id = (string) box_val;
            prefs.editor_scheme = scheme_id;
        });

        hbox.pack_start (scheme_label, false, false, 0);
        hbox.pack_start (scheme_box, false, false, 0);

        // Stylesheet
        var stylesheet_none = new Gtk.RadioButton.with_label_from_widget (null, "Do not use a stylesheet");
        var stylesheet_default = new Gtk.RadioButton.with_label_from_widget (stylesheet_none, "Use the default stylesheet");
        var stylesheet_custom = new Gtk.RadioButton.with_label_from_widget (stylesheet_none, "Use a custom stylesheet");

        vbox.pack_start (stylesheet_none, false, false, 0);
        vbox.pack_start (stylesheet_default, false, false, 0);
        vbox.pack_start (stylesheet_custom, false, false, 0);

        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
        vbox.pack_start (hbox, false, false, 0);

        var stylesheet_chooser = new Gtk.FileChooserButton ("Choose a stylesheet", Gtk.FileChooserAction.OPEN);

        Gtk.FileFilter stylesheet_filter = new Gtk.FileFilter ();
        stylesheet_chooser.set_filter (stylesheet_filter);
        stylesheet_filter.add_mime_type ("text/css");

        var stylesheet_label = new Gtk.Label.with_mnemonic (_("Custom _stylesheet:"));
        stylesheet_label.mnemonic_widget = stylesheet_chooser;

        var default_stylesheet = "https://github.com/sindresorhus/github-markdown-css/raw/gh-pages/github-markdown.css";
        if (prefs.render_stylesheet == "") {
            stylesheet_none.set_active (true);
        } else if (prefs.render_stylesheet == default_stylesheet) {
            stylesheet_default.set_active (true);
        } else {
            stylesheet_custom.set_active (true);
            stylesheet_chooser.set_uri (prefs.render_stylesheet);
        }

        if (!stylesheet_custom.get_active ()) {
            stylesheet_label.set_sensitive (false);
            stylesheet_chooser.set_sensitive (false);
        }

        hbox.pack_start (stylesheet_label, false, false, 0);
        hbox.pack_start (stylesheet_chooser, false, false, 0);

        stylesheet_none.toggled.connect((b) => {
            if (stylesheet_none.get_active ()) {
                prefs.render_stylesheet = "";
            }
        });
        stylesheet_default.toggled.connect((b) => {
            if (stylesheet_default.get_active ()) {
                prefs.render_stylesheet = default_stylesheet;
            }
        });
        stylesheet_custom.toggled.connect((b) => {
            var activated = stylesheet_custom.get_active ();
            stylesheet_label.set_sensitive (activated);
            stylesheet_chooser.set_sensitive (activated);
        });
        stylesheet_chooser.selection_changed.connect (() => {
            //prefs.render_stylesheet = stylesheet_chooser.get_filename ();
            prefs.render_stylesheet = stylesheet_chooser.get_uri ();
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