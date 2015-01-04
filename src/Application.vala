public class MarkMyWordsApp : Gtk.Application {
    public MarkMyWordsApp () {
        Object (application_id: "com.voldyman.markmywords",
                flags: ApplicationFlags.FLAGS_NONE);

    }

    public override void activate () {
        var window = new Window (this);
        add_window (window);
        window.show_all ();
    }
}
