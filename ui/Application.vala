public class MarkMyWordsApp : Gtk.Application {
    public API api;

    public MarkMyWordsApp (API api) {
        Object (application_id: "com.voldyman.markmywords",
                flags: ApplicationFlags.FLAGS_NONE);

        this.api = api;
    }

    public override void activate () {
        var window = new Window (this);
        add_window (window);
        window.show_all ();
    }
}

public void run (string[] args, API api) {
    var app = new MarkMyWordsApp (api);
    app.run (args);
}