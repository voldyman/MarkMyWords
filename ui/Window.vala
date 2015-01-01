public class Window : Gtk.Window{
    private Gtk.SourceView mk_textview;
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

        var manager = Gtk.SourceLanguageManager.get_default ();
        var language = manager.guess_language (null, "text/x-markdown");
        var source_buffer = new Gtk.SourceBuffer.with_language (language);
        mk_textview = new Gtk.SourceView.with_buffer (source_buffer);
        mk_textview.left_margin = 5;
        mk_textview.pixels_above_lines = 5;
        var scroll = new Gtk.ScrolledWindow (null, null);
        scroll.add (mk_textview);
        box.add1 (scroll);

        html_view = new WebKit.WebView ();
        box.add2 (html_view);

        add (box);
    }

    private void setup_events () {
        mk_textview.buffer.changed.connect (update_html_view);

        toolbar.new_clicked.connect (new_action);
        toolbar.open_clicked.connect (open_action);
        toolbar.save_clicked.connect (save_action);
    }
    
    private void update_html_view () {
        string text = mk_textview.buffer.text;
        string html = api.mk_converter(text);
        html_view.load_html (html, null);
        updated ();
    }

    private void new_action () {
        debug ("New Clicked");
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
        var dialog = new Gtk.FileChooserDialog (
            _("Select destination markdown file"),
            this,
            Gtk.FileChooserAction.SAVE,
            _("_Cancel"), Gtk.ResponseType.CANCEL,
            _("_Save"), Gtk.ResponseType.ACCEPT);

        var filter = new Gtk.FileFilter ();
        filter.add_mime_type ("text/plain");
        filter.add_mime_type ("text/x-markdown");

        dialog.set_filter (filter);

        if (dialog.run () == Gtk.ResponseType.ACCEPT) {
            print ("%s\n", dialog.get_filename ());
        }
        dialog.close ();

        debug ("Save clicked\n");
    }

}