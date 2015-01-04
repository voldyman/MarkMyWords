public class Window : Gtk.Window{
    private Document doc;
    private WebKit.WebView  html_view;
    private Toolbar toolbar;
    
    public signal void updated ();
    
    public Window (MarkMyWordsApp app) {
        set_application (app);
        setup_ui ();
        setup_events ();
    }

    private void setup_ui () {
        set_default_size (600, 480);
        window_position = Gtk.WindowPosition.CENTER;
        set_hide_titlebar_when_maximized (false);
        icon_name = "accessories-text-editor";
        
        toolbar = new Toolbar ();
        toolbar.set_title ("Mark My Words");
        set_titlebar (toolbar);
        
        var box = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        int width;
        get_size (out width, null);
        box.set_position (width/2);

        doc = new Document ();
        box.add1 (doc);

        html_view = new WebKit.WebView ();
        box.add2 (html_view);

        add (box);
    }

    private void setup_events () {
        doc.changed.connect (update_html_view);

        toolbar.new_clicked.connect (new_action);
        toolbar.open_clicked.connect (open_action);
        toolbar.save_clicked.connect (save_action);
    }

    private string process (string raw_mk) {
        var mkd = new Markdown.Document.for_string (raw_mk.data, 0);
        mkd.compile (0);

        string result;
        mkd.get_document (out result);

        return result;
    }

    private void update_html_view () {
        string text = doc.get_text ();
        string html = process (text);
        html_view.load_html (html, null);
        updated ();
    }

    private void new_action () {
        doc.reset ();
    }

    private void open_action () {
        debug ("Open clicked\n");

        var dialog = new Gtk.FileChooserDialog (
            _("Select markdown file to open"),
            this,
            Gtk.FileChooserAction.OPEN,
            _("_Cancel"), Gtk.ResponseType.CANCEL,
            _("_Open"), Gtk.ResponseType.ACCEPT);

        var mk_filter = new Gtk.FileFilter ();
        mk_filter.set_filter_name ("Markdown File");
        mk_filter.add_pattern ("*.md, *.markdown");
        mk_filter.add_mime_type ("text/plain");
        mk_filter.add_mime_type ("text/x-markdown");

        var all_filter = new Gtk.FileFilter ();
        all_filter.set_filter_name ("All Files");
        all_filter.add_pattern ("*");

        dialog.add_filter (mk_filter);
        dialog.add_filter (all_filter);

        if (dialog.run () == Gtk.ResponseType.ACCEPT) {
            var file = dialog.get_file ();
            FileHandler.load_content_from_file.begin (file, (obj, res) => {
                doc.set_text (FileHandler.load_content_from_file.end (res));
            });
        }
        dialog.close ();
            
    }

    private void save_action () {
        debug ("Save clicked\n");

        var dialog = new Gtk.FileChooserDialog (
            _("Select destination markdown file"),
            this,
            Gtk.FileChooserAction.SAVE,
            _("_Cancel"), Gtk.ResponseType.CANCEL,
            _("_Save"), Gtk.ResponseType.ACCEPT);

        var mk_filter = new Gtk.FileFilter ();
        mk_filter.set_filter_name ("Markdown File");
        mk_filter.add_mime_type ("text/plain");
        mk_filter.add_mime_type ("text/x-markdown");
        mk_filter.add_pattern ("*.md, *.markdown");

        var all_filter = new Gtk.FileFilter ();
        all_filter.set_filter_name ("All Files");
        all_filter.add_pattern ("*");

        dialog.add_filter (mk_filter);
        dialog.add_filter (all_filter);

        if (dialog.run () == Gtk.ResponseType.ACCEPT) {
            dialog.close ();

            var file = dialog.get_file ();
            FileHandler.write_file (file, doc.get_text ());
        }
    }
}