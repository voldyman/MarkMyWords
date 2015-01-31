public enum WindowState {
    NORMAL = 0,
    MAXIMIZED = 1,
    FULLSCREEN = 2
}

public class SavedState : Object {
    private GLib.Settings settings;

    public int window_width { get; set; default = 800; }
    public int window_height { get; set; default = 476; }
    public WindowState window_state { get; set; }
    public int opening_x { get; set; }
    public int opening_y { get; set; }

    public void load () {
        string schema_id = "org.markmywords.saved-state";
        string settings_dir = "../schemas";
        SettingsSchema schema = null;
        try {
            // Get schema from build dir if available
            var sss = new SettingsSchemaSource.from_directory (settings_dir,
                                                               null, false);
            schema = sss.lookup (schema_id, false);
        } catch (Error e) {}
        if (schema != null) {
            settings = new Settings.full (schema, null, null);
        } else {
            settings = new Settings (schema_id);
        }

        window_width = settings.get_int ("window-width");
        window_height = settings.get_int ("window-height");
        window_state = (WindowState) settings.get_enum ("window-state");
        opening_x = settings.get_int ("opening-x");
        opening_y = settings.get_int ("opening-y");
        this.notify.connect ((s, p) => {
            update_values (p);
        });

    }

    private void update_values (ParamSpec prop) {
        bool success = true;
        string key = prop.name;
        var type = prop.value_type;
        var val = Value (type);
        this.get_property (prop.name, ref val);

        if(val.type() == prop.value_type) {
            if(type == typeof (int)) {
                if (val.get_int () != settings.get_int (key)) {
                    success = settings.set_int (key, val.get_int ());
                }
            } else if(type == typeof (uint)) {
                if (val.get_uint () != settings.get_uint (key)) {
                    success = settings.set_uint (key, val.get_uint ());
                }
            } else if(type == typeof (double)) {
                if (val.get_double () != settings.get_double (key)) {
                    success = settings.set_double (key, val.get_double ());
                }
            } else if(type == typeof (string)) {
                if (val.get_string () != settings.get_string (key)) {
                    success = settings.set_string (key, val.get_string ());
                }
            } else if(type == typeof (string[])) {
                string[] strings = null;
                this.get(key, &strings);
                if (strings != settings.get_strv (key)) {
                    success = settings.set_strv (key, strings);
                }
            } else if(type == typeof (bool)) {
                if (val.get_boolean () != settings.get_boolean (key)) {
                    success = settings.set_boolean (key, val.get_boolean ());
                }
            } else if(type.is_enum ()) {
                if (val.get_enum () != settings.get_enum (key)) {
                    success = settings.set_enum (key, val.get_enum ());
                }
            }
        }
    }
}