
public class DocumentView : Gtk.ScrolledWindow {
    private Gtk.SourceView code_view;
    private Gtk.SourceBuffer code_buffer;

    public signal void changed ();

    public DocumentView () {
        setup_code_view ();
    }

    public void set_text (string text) {
        code_buffer.text = text;
    }

    public void reset () {
        code_buffer.text = "";
    }

    public string get_text () {
        return code_view.buffer.text;
    }

    public void give_focus () {
        code_view.grab_focus ();
    }

    private void setup_code_view () {
        // need to setup language
        var manager = Gtk.SourceLanguageManager.get_default ();
        var language = manager.guess_language (null, "text/x-markdown");
        code_buffer = new Gtk.SourceBuffer.with_language (language);

        code_view = new Gtk.SourceView.with_buffer (code_buffer);

        code_buffer.changed.connect (() => {
            changed ();
        });
        
        // make it look pretty
        code_view.left_margin = 5;
        code_view.pixels_above_lines = 5;

        var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
        var style = style_manager.get_scheme ("solarizeddark");
        code_buffer.set_style_scheme (style);

        code_view.show_line_numbers = true;

        add (code_view);
    }
}