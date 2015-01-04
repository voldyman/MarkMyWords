public class Window : Gtk.Window{
    private Document doc;
    private WebKit.WebView  html_view;
    private Toolbar toolbar;

    private API api;
    
    public signal void updated ();
    
    public Window (MarkMyWordsApp app) {
        this.api = app.api;

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
    
    private void update_html_view () {
        string text = doc.get_text ();
        string html = api.mk_converter(text);
        html_view.load_html (html, null);
        updated ();
    }

    private void new_action () {
        doc.reset ();
    }

    private void open_action () {
        var dialog = new Gtk.FileChooserDialog (
            _("Select markdown file to open"),
            this,
            Gtk.FileChooserAction.OPEN,
            _("_Cancel"), Gtk.ResponseType.CANCEL,
            _("_Open"), Gtk.ResponseType.ACCEPT);

        var filter = new Gtk.FileFilter ();
        filter.add_mime_type ("text/plain");
        filter.add_mime_type ("text/x-markdown");

        dialog.set_filter (filter);

        if (dialog.run () == Gtk.ResponseType.ACCEPT) {
            print ("%s\n", dialog.get_filename ());
        }
        dialog.close ();
            
        debug ("Open clicked\n");
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
        mk_filter.set_filter_name ("Markdown");
        mk_filter.add_mime_type ("text/plain");
        mk_filter.add_mime_type ("text/x-markdown");
        mk_filter.add_pattern ("*.md, *.markdown");

        var all_filter = new Gtk.FileFilter ();
        all_filter.set_filter_name ("All Files");
        all_filter.add_pattern ("*");

        dialog.add_filter (mk_filter);
        dialog.add_filter (all_filter);

        if (dialog.run () == Gtk.ResponseType.ACCEPT) {
            var file_loc = dialog.get_filename ();
            print ("%s\n", file_loc);
            var code = doc.get_text ();
            api.write_file (file_loc, code, code.length);
        }
        dialog.close ();
    }

}