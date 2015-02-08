public interface IToolbar : GLib.Object {
    public signal void new_clicked ();
    public signal void open_clicked ();
    public signal void save_clicked ();
    public signal void export_html_clicked ();
    public signal void export_pdf_clicked ();
    public signal void export_print_clicked ();
    public signal void preferences_clicked ();
    public signal void about_clicked ();

    public abstract void set_title (string title);
}