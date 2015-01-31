public enum WindowState {
    NORMAL = 0,
    MAXIMIZED = 1,
    FULLSCREEN = 2
}

public class SavedState : Settings {
    public int window_width { get; set; default = 800; }
    public int window_height { get; set; default = 476; }
    public WindowState window_state { get; set; }
    public int opening_x { get; set; }
    public int opening_y { get; set; }

    public SavedState () {
        base ("org.markmywords.saved-state");
    }

    public override void load () {
        window_width = settings.get_int ("window-width");
        window_height = settings.get_int ("window-height");
        window_state = (WindowState) settings.get_enum ("window-state");
        opening_x = settings.get_int ("opening-x");
        opening_y = settings.get_int ("opening-y");
    }
}
