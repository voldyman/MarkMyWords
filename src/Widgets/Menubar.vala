public class Menubar : IToolbar, Gtk.Toolbar {
    private Gtk.Window parent_window;
    private Gtk.ToolButton new_button;
    private Gtk.ToolButton open_button;
    private Gtk.ToolButton save_button;

    private Gtk.MenuToolButton export_button;
    private Gtk.MenuItem export_pdf;
    private Gtk.MenuItem export_html;
    private Gtk.MenuItem export_print;

    private Gtk.MenuToolButton settings_button;
    private Gtk.MenuItem preferences;
    private Gtk.MenuItem about;

    public Menubar (Gtk.Window win) {
        parent_window = win;
        setup_ui ();
        setup_events ();
    }

    public void set_title (string title) {
        if (parent != null) {
            parent_window.title = title;
        }
    }
    private void setup_ui () {
        var new_image = new Gtk.Image.from_icon_name ("document-new",
                                                      Gtk.IconSize.LARGE_TOOLBAR);
        new_button = new Gtk.ToolButton (new_image, null);

        new_button.set_tooltip_text (_("New file"));

        var open_image = new Gtk.Image.from_icon_name ("document-open",
                                                       Gtk.IconSize.LARGE_TOOLBAR);
        open_button = new Gtk.ToolButton (open_image, null);
        open_button.set_tooltip_text (_("Open file"));

        var save_image = new Gtk.Image.from_icon_name ("document-save",
                                                       Gtk.IconSize.LARGE_TOOLBAR);
        save_button = new Gtk.ToolButton (save_image, null);
        save_button.set_tooltip_text (_("Save file"));

        var export_image = Toolbar.get_image_with_fallback ("document-export",
                                                            "document-revert-rtl");

        export_button = new Gtk.MenuToolButton (export_image, null);

        var export_menu = new Gtk.Menu ();
        export_pdf = new Gtk.MenuItem.with_label (_("Export PDF"));
        export_html = new Gtk.MenuItem.with_label (_("Export HTML"));
        export_print = new Gtk.MenuItem.with_label (_("Print"));

        export_menu.add (export_html);
        export_menu.add (export_pdf);
        export_menu.add (export_print);
        export_menu.show_all ();

        export_button.set_menu (export_menu);

        var settings_image = Toolbar.get_image_with_fallback ("open-menu",
                                                              "preferences-system");

        settings_button = new Gtk.MenuToolButton (settings_image, null);

        var settings_menu = new Gtk.Menu ();
        preferences = new Gtk.MenuItem.with_label (_("Preferences"));
        about = new Gtk.MenuItem.with_label (_("About"));

        settings_menu.add (preferences);
        settings_menu.add (about);
        settings_menu.show_all ();
        settings_button.set_menu (settings_menu);

        add (new_button);
        add (open_button);
        add (save_button);

        add (settings_button);
        add (export_button);
    }

    private void setup_events () {
        new_button.clicked.connect (() => {
            new_clicked ();
        });

        open_button.clicked.connect (() => {
            open_clicked ();
        });

        save_button.clicked.connect (() => {
            save_clicked ();
        });

        export_pdf.activate.connect (() => {
            export_pdf_clicked ();
        });

        export_html.activate.connect (() => {
            export_html_clicked ();
        });

        export_print.activate.connect (() => {
            export_print_clicked ();
        });

        preferences.activate.connect (() => {
            preferences_clicked ();
        });

        about.activate.connect (() => {
            about_clicked ();
        });

    }
}