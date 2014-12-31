public class Window : Gtk.Window{
    private Gtk.TextView mk_textview;
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

        mk_textview = new Gtk.TextView ();
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

        toolbar.open_clicked.connect (open_action);
        toolbar.save_clicked.connect (save_action);
    }
    
    private void update_html_view () {
        string text = mk_textview.buffer.text;
        string html = api.mk_converter(text);
        html_view.load_html (html, null);
        updated ();
    }

    private void open_action () {
        print ("Open clicked\n");
    }

    private void save_action () {
        print ("Save clicked\n");
    }

}