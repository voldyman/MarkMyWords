
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

    public void set_font (string name) {
        var font = Pango.FontDescription.from_string (name);
        code_view.override_font (font);
    }

    public void set_scheme (string id) {
        var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
        var style = style_manager.get_scheme (id);
        code_buffer.set_style_scheme (style);
    }

    private string get_default_scheme () {
        var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
        if ("solarized-dark" in style_manager.scheme_ids) { // In Gnome
            return "solarized-dark";
        } else { // In Elementary
            return "solarizeddark";
        }
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
        // wrap text between words, we don't need to be
        // very strict since people should be wrting text not code
        code_view.wrap_mode = Gtk.WrapMode.WORD;
        code_view.show_line_numbers = true;

        this.set_scheme (this.get_default_scheme ());

        add (code_view);
    }
}