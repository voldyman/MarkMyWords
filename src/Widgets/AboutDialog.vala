public class AboutDialog : Gtk.AboutDialog {

    public AboutDialog () {
        this.set_default_size (450, 500);
        this.get_content_area ().margin = 10;
        this.title = "About MarkMyWords";
        setup_content ();

        this.response.connect (response_handler);
    }

    private void setup_content () {
        program_name = "MarkMyWords";
        logo_icon_name = "accessories-text-editor";
        
        comments = "A text editor that allows you to easily format your" +
                   "text using the markdown markup langauge.";

        website = "http://github.com/voldyman/MarkMyWords";
        version = "0.1";

        authors = { "<a href='http://tripent.net'>Akshay Shekher</a>" };

    }

    private void response_handler (int response) {
        if (response == Gtk.ResponseType.DELETE_EVENT) {
            this.destroy ();
        }
    }

}