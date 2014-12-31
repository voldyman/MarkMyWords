using Gtk;

class Toolbar : Gtk.HeaderBar {
    private Button open_button;
    private Button save_button;

    public Toolbar () {
        this.show_close_button = true;

        open_button = new Button.from_icon_name ("document-open",
                                                 IconSize.LARGE_TOOLBAR);
        open_button.set_tooltip_text (_("Open file"));

        save_button = new Button.from_icon_name ("document-save",
                                                 IconSize.LARGE_TOOLBAR);
        save_button.set_tooltip_text (_("Save file"));
        
        pack_start (open_button);
        pack_start (save_button);

        open_button.show ();
        save_button.show ();
    }
}