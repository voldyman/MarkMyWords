using Gtk;

class Toolbar : Gtk.HeaderBar {
    private ToolButton open_button;
    private ToolButton save_button;

    public Toolbar () {
        this.show_close_button = true;

/*
        open_button = main_actions.get_action ("Open")
            .create_tool_item () as Gtk.ToolButton;

        save_button = main_actions.get_action ("SaveFile")
            .create_tool_item () as Gtk.ToolButton;

        
        pack_start (open_button);
        pack_start (save_button);
*/
    }
}