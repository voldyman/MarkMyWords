public class Window : Gtk.Window{
    private DocumentView doc;
    private WebKit.WebView  html_view;
    private Toolbar toolbar;

    // current state
    private File? current_file = null;
    private bool file_modified = false;

    // timer related variables
    private bool timer_scheduled = false;
    private uint timer_id = 0;
    // average word length = 5.1
    // average typing speed = 40 words per minute
    // 204 keys per minute == 0.294 seconds per key
    // we'll make it render after 0.3 seconds
    private const int TIME_TO_REFRESH = 3 * 100;

    public signal void updated ();

    public Window (MarkMyWordsApp app) {
        set_application (app);
        setup_ui ();
        setup_events ();
    }

    public override bool delete_event (Gdk.EventAny ev) {
        var dont_quit = false;

        if (file_modified) {
            var d = new UnsavedChangesDialog ();
            var result = d.run ();
            switch (result) {
            case UnsavedChangesResult.QUIT:
                dont_quit = false;
                break;

            // anything other than quit means cancel
            case UnsavedChangesResult.CANCEL:
            default:
                dont_quit = true;
                break;
            }
            d.destroy ();
        }

        return dont_quit;
    }

    private void setup_ui () {
        set_default_size (600, 480);
        window_position = Gtk.WindowPosition.CENTER;
        set_hide_titlebar_when_maximized (false);
        icon_name = "accessories-text-editor";

        toolbar = new Toolbar ();
        toolbar.set_title ("Mark My Words");
        set_titlebar (toolbar);

        var box = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        int width;
        get_size (out width, null);
        box.set_position (width/2);

        doc = new DocumentView ();
        html_view = new WebKit.WebView ();

        box.add1 (doc);
        box.add2 (html_view);

        doc.give_focus ();

        add (box);
    }

    private void setup_events () {
        doc.changed.connect (schedule_timer);
        doc.changed.connect (update_state);

        toolbar.new_clicked.connect (new_action);
        toolbar.open_clicked.connect (open_action);
        toolbar.save_clicked.connect (save_action);
        toolbar.export_html_clicked.connect (export_html_action);
        toolbar.export_pdf_clicked.connect (export_pdf_action);
    }

    private void update_state () {
        file_modified = true;
    }

    private void schedule_timer () {
        if (timer_scheduled) {
            Source.remove(timer_id);
        }
        timer_id = Timeout.add (TIME_TO_REFRESH, render_func);
        timer_scheduled = true;
    }

    private bool render_func () {
        update_html_view ();
        timer_scheduled = false;
        return false;
    }

    private string process (string raw_mk) {
        var mkd = new Markdown.Document (raw_mk.data);
        mkd.compile ();

        string result;
        mkd.get_document (out result);

        return result;
    }

    private void update_html_view () {
        string text = doc.get_text ();
        string html = process (text);
        html_view.load_html (html, null);
        updated ();
    }

    private void new_action () {
        current_file = null;
        doc.reset ();
    }

    private void open_action () {
        var new_file = get_file_from_user (DialogType.MARKDOWN_IN);

        FileHandler.load_content_from_file.begin (new_file, (obj, res) => {
            doc.set_text (FileHandler.load_content_from_file.end (res));
            current_file = new_file;
        });
    }

    private void save_action () {
        if (current_file == null) {
            var file = get_file_from_user (DialogType.MARKDOWN_OUT);

            if (file == null) {
                return;
            } else {
                current_file = file;
            }
        }

        try {
            FileHandler.write_file (current_file, doc.get_text ());
            file_modified = false;
        } catch (Error e) {
            warning ("%s: %s", e.message, current_file.get_basename ());
        }
    }

    private void export_html_action () {
        var file = get_file_from_user (DialogType.HTML_OUT);

        string text = doc.get_text ();
        string html = process (text);

        try {
            FileHandler.write_file (file, html);
        } catch (Error e) {
            warning ("Could not export HTML: %s", e.message);
        }
    }

    private void export_pdf_action () {
        print ("Export pdf\n");
        var file = get_file_from_user (DialogType.PDF_OUT);
    }

    private enum DialogType {
        MARKDOWN_OUT,
        MARKDOWN_IN,
        HTML_OUT,
        PDF_OUT
    }

    private File? get_file_from_user (DialogType dtype) {
        File? result = null;

        string title = "";
        Gtk.FileChooserAction chooser_action = Gtk.FileChooserAction.SAVE;
        string accept_button_label = "";
        List<Gtk.FileFilter> filters = new List<Gtk.FileFilter> ();

        switch (dtype) {
        case DialogType.MARKDOWN_OUT:
            title =  _("Select destination markdown file");
            chooser_action = Gtk.FileChooserAction.SAVE;
            accept_button_label = _("Save");

            filters.append (get_markdown_filter ());
            break;

        case DialogType.MARKDOWN_IN:
            title = _("Select markdown file to open");
            chooser_action = Gtk.FileChooserAction.OPEN;
            accept_button_label = _("Open");

            filters.append (get_markdown_filter ());
            break;

        case DialogType.HTML_OUT:
            title =  _("Select destination HTML file");
            chooser_action = Gtk.FileChooserAction.SAVE;
            accept_button_label = _("Save");

            var html_filter = new Gtk.FileFilter ();
            html_filter.set_filter_name ("HTML File");

            html_filter.add_mime_type ("text/plain");
            html_filter.add_mime_type ("text/html");

            html_filter.add_pattern ("*.html");
            html_filter.add_pattern ("*.htm");

            filters.append (html_filter);
            break;

        case DialogType.PDF_OUT:
            title =  _("Select destination PDF file");
            chooser_action = Gtk.FileChooserAction.SAVE;
            accept_button_label = _("Save");

            var pdf_filter = new Gtk.FileFilter ();
            pdf_filter.set_filter_name ("PDF File");

            pdf_filter.add_mime_type ("application/pdf");
            pdf_filter.add_pattern ("*.pdf");

            filters.append (pdf_filter);
            break;

        }

        var all_filter = new Gtk.FileFilter ();
        all_filter.set_filter_name ("All Files");
        all_filter.add_pattern ("*");

        filters.append (all_filter);

        var dialog = new Gtk.FileChooserDialog (
            title,
            this,
            chooser_action,
            _("_Cancel"), Gtk.ResponseType.CANCEL,
            accept_button_label, Gtk.ResponseType.ACCEPT);


        filters.@foreach ((filter) => {
            dialog.add_filter (filter);
        });

        if (dialog.run () == Gtk.ResponseType.ACCEPT) {
            result = dialog.get_file ();
        }

        dialog.close ();

        return result;
    }

    private Gtk.FileFilter get_markdown_filter () {
        var mk_filter = new Gtk.FileFilter ();
        mk_filter.set_filter_name ("Markdown File");

        mk_filter.add_mime_type ("text/plain");
        mk_filter.add_mime_type ("text/x-markdown");

        mk_filter.add_pattern ("*.md");
        mk_filter.add_pattern ("*.markdown");
        mk_filter.add_pattern ("*.mkd");

        return mk_filter;
    }
}
