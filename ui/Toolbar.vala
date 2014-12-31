using Gtk;

class Toolbar : Gtk.HeaderBar {
    private Button open_button;
    private Button save_button;

    public signal void open_clicked ();
    public signal void save_clicked ();

    public Toolbar () {
        this.show_close_button = true;

        open_button = new Button.from_icon_name ("document-open",
                                                 IconSize.LARGE_TOOLBAR);
        open_button.set_tooltip_text (_("Open file"));
        open_button.clicked.connect (() => {
            open_clicked ();
        });

        save_button = new Button.from_icon_name ("document-save",
                                                 IconSize.LARGE_TOOLBAR);
        save_button.set_tooltip_text (_("Save file"));
        save_button.clicked.connect (()=> {
            save_clicked ();
        });
        
        pack_start (open_button);
        pack_start (save_button);

        open_button.show ();
        save_button.show ();
    }
}