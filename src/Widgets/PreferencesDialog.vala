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

        var font_label = new Gtk.Label.with_mnemonic (_("_Editor font:"));
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

        var scheme_label = new Gtk.Label.with_mnemonic (_("_Editor theme:"));
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

        // Close button
        /*hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
        vbox.pack_start (hbox, false, false, 0);

        var close_btn = new Gtk.Button.with_label (_("Close"));
        hbox.pack_end (close_btn, false, false, 0);*/
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