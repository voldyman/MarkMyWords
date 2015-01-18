public class Preferences : Object {
    private Settings settings;

    public string editor_font { get; set; default = ""; }
    public string editor_scheme { get; set; default = ""; }
    public string render_stylesheet { get; set; default = ""; }

    public void load () {
        // TODO: use granite.settings?
        string settings_dir = "../schemas";
        var sss = new SettingsSchemaSource.from_directory (settings_dir, null, false);
        var schema = sss.lookup ("org.markmywords", false);
        if (sss.lookup == null) {
            return;
        }
        settings = new Settings.full (schema, null, null);

        this.editor_font = settings.get_string ("editor-font");
        this.editor_scheme = settings.get_string ("editor-scheme");
        this.render_stylesheet = settings.get_string ("render-stylesheet");

        this.notify.connect ((s, p) => {
            stdout.printf ("Updated pref: %s\n", p.name);
            Value val = Value (typeof (string));
            this.get_property (p.name.replace("-", "_"), ref val);
            settings.set_string (p.name, val.get_string());
        });
    }
}