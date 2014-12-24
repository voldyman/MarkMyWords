using Gtk;

class Toolbar : Gtk.HeaderBar {
    private ToolButton open_button;
    private ToolButton save_button;

    public Toolbar (Gtk.ActionGroup main_actions) {
        open_button = main_actions.get_action ("Open")
            .create_tool_item () as Gtk.ToolButton;

        save_button = main_actions.get_action ("SaveFile")
            .create_tool_item () as Gtk.ToolButton;

        this.show_close_button = true;
        
        pack_start (open_button);
        pack_start (save_button);
    }
}