public class AboutDialog : Gtk.AboutDialog {

    public AboutDialog () {
        this.set_default_size (450, 500);
        this.get_content_area ().margin = 10;
        this.title = "About %s".printf (MarkMyWords.APP_NAME);
        setup_content ();

        this.response.connect (response_handler);
    }

    private void setup_content () {
        program_name = MarkMyWords.APP_NAME;
        logo_icon_name = "accessories-text-editor";
        
        comments = "A text editor that allows you to easily format your" +
                   "text using the markdown markup langauge.";

        website = "http://github.com/voldyman/MarkMyWords";
        version = MarkMyWords.APP_VERSION;

        authors = { "<a href='http://tripent.net'>Akshay Shekher</a>",
                    "<a href='mailto://contact@emersion.fr'>Emersion</a>"};

    }

    private void response_handler (int response) {
        if (response == Gtk.ResponseType.DELETE_EVENT) {
            this.destroy ();
        }
    }
}