public class Settings : Object {
    public signal void settings_changed (string key);

    protected GLib.Settings settings;

    private string schema_id;
    private bool is_monitored = false;

    public Settings (string schema_id) {
        this.schema_id = schema_id;
        string settings_dir = "../schemas";
        SettingsSchema schema = null;
        try {
            // Get schema from build dir if available
            var sss = new SettingsSchemaSource.from_directory (settings_dir,
                                                               null, false);
            schema = sss.lookup (schema_id, false);
        } catch (Error e) {}
        if (schema != null) {
            settings = new GLib.Settings.full (schema, null, null);
        } else {
            settings = new GLib.Settings (schema_id);
        }
        this.notify.connect (handle_notify);

    }

    public virtual void load () {
        // load values here
    }

    public void start_monitor () {
        if (!is_monitored) {
            settings.changed.connect (handle_settings_changed);
            is_monitored = true;
        }   
    }

    public void stop_monitor () {
        if (is_monitored) {
            settings.changed.disconnect (handle_settings_changed);
            is_monitored = false;
        }
    }

    private void handle_settings_changed (string key) {
        settings_changed (key);
    }

    private void handle_notify (Object sender, ParamSpec prop) {
        update_values (prop);
        handle_settings_changed (prop.name);
    }

    private void update_values (ParamSpec prop) {
        // only call stop monitored if
        // settings were being monitored
        bool was_monitored = is_monitored;
        if (is_monitored) {
            stop_monitor ();
        }

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
        // if settings were monitored
        // start monitoring them again
        if (was_monitored) {
            start_monitor ();
        }
    }
}