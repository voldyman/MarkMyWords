using Gtk;

class Toolbar : Gtk.HeaderBar {
    private Button new_button;
    private Button open_button;
    private Button save_button;

    private MenuButton export_button;
    private Gtk.MenuItem export_pdf;
    private Gtk.MenuItem export_html;

    private MenuButton settings_button;
    private Gtk.MenuItem about;

    public signal void new_clicked ();
    public signal void open_clicked ();
    public signal void save_clicked ();
    public signal void export_html_clicked ();
    public signal void export_pdf_clicked ();
    public signal void about_clicked ();

    public Toolbar () {
        this.show_close_button = true;
        setup_ui ();
        setup_events ();
    }

    private void setup_ui () {
        new_button = new Button.from_icon_name ("document-new",
                                                IconSize.LARGE_TOOLBAR);
        new_button.set_tooltip_text (_("New file"));

        open_button = new Button.from_icon_name ("document-open",
                                                 IconSize.LARGE_TOOLBAR);
        open_button.set_tooltip_text (_("Open file"));

        save_button = new Button.from_icon_name ("document-save",
                                                 IconSize.LARGE_TOOLBAR);
        save_button.set_tooltip_text (_("Save file"));

        export_button = new MenuButton ();
        export_button.image = get_export_image ();

        var export_menu = new Gtk.Menu ();
        export_pdf = new Gtk.MenuItem.with_label (_("Export PDF"));

        export_html = new Gtk.MenuItem.with_label (_("Export HTML"));

        export_menu.add (export_html);
        export_menu.add (export_pdf);
        export_menu.show_all ();

        export_button.set_popup (export_menu);

        settings_button = new MenuButton ();
        settings_button.image = new Gtk.Image.from_icon_name ("open-menu",
                                                              IconSize.LARGE_TOOLBAR);

        var settings_menu = new Gtk.Menu ();
        about = new Gtk.MenuItem.with_label (_("About"));

        settings_menu.add (about);
        settings_menu.show_all ();
        settings_button.set_popup (settings_menu);

        pack_start (new_button);
        pack_start (open_button);
        pack_start (save_button);

        pack_end (settings_button);
        pack_end (export_button);
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

        about.activate.connect (() => {
            about_clicked ();
        });

    }

    private Gtk.Image get_export_image () {
        var icon_name = "document-export";
        var backup_icon_name = "document-revert-rtl";
        Gtk.Image image;

        Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();

        if (icon_theme.has_icon (icon_name)) {
            image = new Image.from_icon_name (icon_name,
                                              IconSize.LARGE_TOOLBAR);
        } else {
            image = new Image.from_icon_name (backup_icon_name,
                                              IconSize.LARGE_TOOLBAR);
        }
        return image;
    }
}