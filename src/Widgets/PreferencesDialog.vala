using Gtk;

public class PreferencesDialog : Gtk.Window {
    private FontButton font_btn;

    public PreferencesDialog (Window parent, Preferences prefs) {
        this.title = _("Preferences");
        this.window_position = Gtk.WindowPosition.CENTER;
        this.set_modal (true);
        this.set_transient_for (parent);

        font_btn = new FontButton ();
        font_btn.use_font = true;
        font_btn.use_size = true;

        font_btn.font_set.connect (() => {
            unowned string name = font_btn.get_font_name ();
            prefs.editor_font = name;
        });

        this.add(font_btn);
    }
}