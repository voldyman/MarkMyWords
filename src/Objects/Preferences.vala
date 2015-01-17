public class Preferences : Object {
    private KeyFile keyfile = new KeyFile ();

    public string editor_font { get; set; default = ""; }
    public string editor_scheme { get; set; default = ""; }

    public void load_from_file (string filepath) {
        var file = File.new_for_path (filepath);
        if (!file.query_exists ()) { // No config file yet...
            return;
        }

        try {
            keyfile.load_from_file (filepath, KeyFileFlags.NONE);

            if (keyfile.has_group ("editor")) {
                if (keyfile.has_key ("editor", "font")) {
                    this.editor_font = keyfile.get_value ("editor", "font");
                }
                if (keyfile.has_key ("editor", "scheme")) {
                    this.editor_font = keyfile.get_value ("editor", "scheme");
                }
            }
        } catch (Error e) {
            warning (e.message);
        }
    }

    public void save_to_file (string filepath) {
        var file = File.new_for_path (filepath);
        var parent_path = filepath.substring (0, filepath.last_index_of_char ('/'));
        var parent = File.new_for_path (parent_path);
        
        try { // Create file if it doesn't exist
            if (!parent.query_exists ()) {
                parent.make_directory_with_parents ();
            }
            FileHandler.create_file_if_not_exists (file);
        } catch (Error e) {
            warning (e.message);
            return;
        }

        keyfile.set_value("editor", "font", this.editor_font);
        keyfile.set_value("editor", "scheme", this.editor_scheme);

        try {
            keyfile.save_to_file (filepath);
        } catch (Error e) {
            warning (e.message);
        }
    }
}