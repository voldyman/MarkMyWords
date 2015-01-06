
public class FileHandler : GLib.Object {

    public static void create_file_if_not_exists (File file) throws Error{
        if (!file.query_exists ()) {
            try {
                file.create (FileCreateFlags.REPLACE_DESTINATION);
            } catch (Error e) {
                throw new Error (Quark.from_string (""), -1, "Could not write file: %s", e.message);
            }
        }
    }

    public static async string? load_content_from_file (File file) {
        var text = new StringBuilder ();

        try {
            var dis = new DataInputStream (file.read ());
            string line = null;
            while ((line = yield dis.read_line_async (Priority.DEFAULT)) != null) {
                text.append (line);
                text.append_c ('\n');
            }
            return text.erase(text.len - 1, 1).str;
        } catch (Error e) {
            warning ("Cannot read \"%s\": %s", file.get_basename (), e.message);
            return null;
        }
    }

    public static string? load_content_from_file_sync (File file) {
        var text = new StringBuilder ();

        try {
            var dis = new DataInputStream (file.read ());
            string line = null;
            while ((line = dis.read_line (null, null)) != null) {
                if (line != "\n") {
                    text.append (line);
                    text.append_c ('\n');
                }
            }
            return text.erase(text.len - 1, 1).str;
        } catch (Error e) {
            warning ("Cannot read \"%s\": %s", file.get_basename (), e.message);
            return null;
        }
    }

    public static void write_file (File file, string contents) throws Error {
        create_file_if_not_exists (file);

        file.open_readwrite_async.begin (Priority.DEFAULT, null, (obj, res) => {
            try {
                var iostream = file.open_readwrite_async.end (res);
                var ostream = iostream.output_stream;
                 ostream.write_all (contents.data, null);
            } catch (Error e) {
                warning ("Could not write file \"%s\": %s", file.get_basename (), e.message);
            }
        });
    }
}