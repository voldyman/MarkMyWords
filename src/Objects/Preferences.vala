public class Preferences : Object {
    private Settings settings;

    public string editor_font { get; set; default = ""; }
    public string editor_scheme { get; set; default = ""; }
    public bool render_stylesheet { get; set; default = true; }
    public string render_stylesheet_uri { get; set; default = ""; }
    public bool render_syntax_highlighting { get; set; default = false; }
    public bool prefer_dark_theme { get; set; default = false; }
    public int autosave_interval { get; set; default = 0; }

    public void load () {
        string schema_id = "org.markmywords";
        string settings_dir = "../schemas";
        SettingsSchema schema = null;
        try { // Get schema from build dir if available
            var sss = new SettingsSchemaSource.from_directory (settings_dir, null, false);
            schema = sss.lookup (schema_id, false);
        } catch (Error e) {}
        if (schema != null) {
            settings = new Settings.full (schema, null, null);
        } else {
            settings = new Settings (schema_id);
        }

        this.editor_font = settings.get_string ("editor-font");
        this.editor_scheme = settings.get_string ("editor-scheme");
        this.render_stylesheet = settings.get_boolean ("render-stylesheet");
        this.render_stylesheet_uri = settings.get_string ("render-stylesheet-uri");
        this.render_syntax_highlighting = settings.get_boolean ("render-syntax-highlighting");
        this.prefer_dark_theme = settings.get_boolean ("prefer-dark-theme");
        this.autosave_interval = settings.get_int ("autosave-interval");

        this.notify.connect ((s, p) => {
            stdout.printf ("Updated pref: %s\n", p.name);

            string prop_name = p.name.replace("-", "_");

            var oldval = settings.get_value (p.name);
            unowned string type_str = oldval.get_type_string ();
            if (type_str == "s") {
                Value val = Value (typeof (string));
                this.get_property (prop_name, ref val);
                settings.set_string (p.name, val.get_string());
            } else if (type_str == "i") {
                Value val = Value (typeof (int));
                this.get_property (prop_name, ref val);
                settings.set_int (p.name, val.get_int());
            } else if (type_str == "b") {
                Value val = Value (typeof (bool));
                this.get_property (prop_name, ref val);
                settings.set_boolean (p.name, val.get_boolean());
            } else {
                warning ("Unsupported setting type: %s", type_str);
            }
        });
    }
}