public delegate string MarkdownConverter (string data);

public class Window {
    private Gtk.Window win;
    private Gtk.TextView mk_textview;
    private WebKit.WebView  html_view;

    private Gtk.ActionGroup main_actions;
    private MarkdownConverter converter;

    public signal void updated ();
    
    public Window (string[] args, MarkdownConverter converter) {
        Gtk.init (ref args);
        this.converter = converter;
        setup_actions ();
    }
    private void update_html_view () {
        string text = mk_textview.buffer.text;
        string html;
        html = converter(text);
        html_view.load_html (html, null);
        updated ();
    }

    public void run() {
        win = new Gtk.Window ();
        win.set_default_size (600, 480);
        win.window_position = Gtk.WindowPosition.CENTER;
        win.set_hide_titlebar_when_maximized (false);
        win.icon_name = "accessories-text-editor";
        win.destroy.connect (Gtk.main_quit);
        
        var toolbar = new Toolbar (main_actions);
        toolbar.set_title ("Mark My Words");
        win.set_titlebar (toolbar);
        
        var box = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

        mk_textview = new Gtk.TextView ();
        box.add1 (mk_textview);

        html_view = new WebKit.WebView ();
        box.add2 (html_view);

        mk_textview.buffer.changed.connect (update_html_view);

        win.add (box);
        win.show_all();
        Gtk.main ();
    }

    private void action_open () {
        print ("Open file\n");
    }

    private void action_save () {
        print ("Save file\n");
    }
    
    private void setup_actions () {
        main_actions = new Gtk.ActionGroup ("MainActionGroup");
        main_actions.add_actions (main_entries, this);
    }

    static const Gtk.ActionEntry[] main_entries = {
        { "Open", "document-open",
          /* label, accelerator */   "Open", "<Control>o",
          /* tooltip */              "Open a file",
                                     action_open },
        { "SaveFile", "document-save",
          /* label, accelerator */   "Save", "<Control>s",
          /* tooltip */              "Save this file",
                                     action_save }

    };

}