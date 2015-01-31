public class Window : Gtk.Window {
    private MarkMyWordsApp app;
    private DocumentView doc;
    private WebKit.WebView  html_view;
    private Toolbar toolbar;
    private Preferences prefs;
    private SavedState saved_state;

    // current state
    private File? current_file = null;
    private bool file_modified = false;
    private FileMonitor? file_monitor = null;

    // autosave timer related variables
    private bool autosave_timer_scheduled = false;
    private uint autosave_timer_id = 0;

    // rendering assets caching
    private string render_stylesheet = null;
    private string syntax_stylesheet = null;
    private string syntax_script = null;

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
        this.app = app;

        set_application (app);
        setup_prefs ();
        setup_ui ();
        setup_events ();

        prefs.load ();
    }

    public override bool delete_event (Gdk.EventAny ev) {
        var dont_quit = false;

        if (file_modified) {
            var d = new UnsavedChangesDialog.for_quit (this);
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

        // save state anyway
        save_window_state ();

        return dont_quit;
    }

    public void use_file (File? file, bool should_monitor = true) {
        if (file != null) {
            FileHandler.load_content_from_file.begin (file, (obj, res) => {
                doc.set_text (FileHandler.load_content_from_file.end (res));
                update_html_view ();
                if (should_monitor) {
                    setup_file_monitor ();
                }
            });
        }
        current_file = file;
        file_modified = false;
    }

    public void reset_file () {
        remove_timer ();
        current_file = null;
        doc.reset ();

        file_modified = false;
        file_monitor.cancel ();
        file_monitor = null;

        // update html output
        update_html_view ();
    }

    private void setup_prefs () {
        prefs = new Preferences ();

        prefs.notify["editor-font"].connect ((s, p) => {
            doc.set_font (prefs.editor_font);
        });

        prefs.notify["editor-scheme"].connect ((s, p) => {
            doc.set_scheme (prefs.editor_scheme);
        });

        prefs.notify["render-stylesheet"].connect ((s, p) => {
            var uri = prefs.render_stylesheet_uri;
            if (uri == "") {
                uri = get_data_file_uri ("github-markdown.css");
            }

            var file = File.new_for_uri (uri);
            FileHandler.load_content_from_file.begin (file, (obj, res) => {
                render_stylesheet = FileHandler.load_content_from_file.end (res);
                update_html_view ();
            });
        });

        prefs.notify["render-syntax-highlighting"].connect ((s, p) => {
            if (prefs.render_syntax_highlighting) {
                if (syntax_stylesheet == null) {
                    var css_uri = get_data_file_uri ("github-syntax.css");
                    var css_file = File.new_for_uri (css_uri);
                    syntax_stylesheet = FileHandler.load_content_from_file_sync (css_file);
                }
                if (syntax_script == null) {
                    var js_uri = get_data_file_uri ("highlight.pack.js");
                    var js_file = File.new_for_uri (js_uri);
                    syntax_script = FileHandler.load_content_from_file_sync (js_file);

                    // Escape </script> tag
                    syntax_script = syntax_script.replace("</script>", "\\<\\/script\\>");
                }
            }

            update_html_view ();
        });

        prefs.notify["prefer-dark-theme"].connect ((s, p) => {
            Gtk.Settings.get_default().set("gtk-application-prefer-dark-theme", prefs.prefer_dark_theme);
        });

        prefs.notify["autosave-interval"].connect ((s, p) => {
            schedule_autosave_timer ();
        });
    }

    private void setup_ui () {
        load_window_state ();
        window_position = Gtk.WindowPosition.CENTER;
        set_hide_titlebar_when_maximized (false);
        icon_name = MarkMyWords.ICON_NAME;

        toolbar = new Toolbar ();
        toolbar.set_title (MarkMyWords.APP_NAME);
        set_titlebar (toolbar);

        var box = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        int width;
        get_size (out width, null);
        box.set_position (width/2);

        doc = new DocumentView ();
        html_view = new WebKit.WebView ();
        var webkit_settings = new WebKit.Settings ();
        webkit_settings.enable_page_cache = true;
        webkit_settings.enable_developer_extras = false;

        box.add1 (doc);
        box.add2 (html_view);

        doc.give_focus ();

        add (box);
    }

    private void setup_events () {
        this.key_press_event.connect (key_pressed);
        doc.changed.connect (schedule_timer);
        doc.changed.connect (update_state);

        toolbar.new_clicked.connect (new_action);
        toolbar.open_clicked.connect (open_action);
        toolbar.save_clicked.connect (save_action);
        toolbar.export_html_clicked.connect (export_html_action);
        toolbar.export_pdf_clicked.connect (export_pdf_action);
        toolbar.export_print_clicked.connect (export_print_action);
        toolbar.preferences_clicked.connect (preferences_action);
        toolbar.about_clicked.connect (about_action);
    }

    private void load_window_state () {
        saved_state = new SavedState ();
        saved_state.load ();

        int window_width = saved_state.window_width;
        int window_height = saved_state.window_height;
        WindowState state = saved_state.window_state;
        set_default_size (window_width, window_height);

        if (state == WindowState.MAXIMIZED) {
            maximize ();
        } else if (state == WindowState.FULLSCREEN) {
            fullscreen ();
        }
        int x = saved_state.opening_x;
        int y = saved_state.opening_y;

        move (x, y);
    }

    private void save_window_state () {
        var window_state = get_state ();

        if ((window_state & Gdk.WindowState.MAXIMIZED) != 0) {
            saved_state.window_state = WindowState.MAXIMIZED;
        } else if ((window_state & Gdk.WindowState.FULLSCREEN) != 0) {
            saved_state.window_state = WindowState.FULLSCREEN;
        } else {
            saved_state.window_state = WindowState.NORMAL;
        }

        int width, height;
        get_size (out width, out height);
        saved_state.window_width = width;
        saved_state.window_height = height;

        int x, y;
        get_position (out x, out y);
        saved_state.opening_x = x;
        saved_state.opening_y = y;
    }

    public bool key_pressed (Gdk.EventKey ev) {
        bool handled_event = false;
        bool ctrl_pressed = modifier_pressed (ev,
                                              Gdk.ModifierType.CONTROL_MASK);

        switch (ev.keyval) {
        case Gdk.Key.o:
            if (ctrl_pressed) {
                handled_event = true;
                open_action ();
            }
            break;

        case Gdk.Key.n:
            if (ctrl_pressed) {
                handled_event = true;
                new_action ();
            }
            break;

        case Gdk.Key.s:
            if (ctrl_pressed) {
                handled_event = true;
                save_action ();
            }
            break;

        case Gdk.Key.q:
            if (ctrl_pressed) {
                handled_event = true;
                close_action ();
            }
            break;
        }
        return handled_event;
    }

    private bool modifier_pressed (Gdk.EventKey event,
                                   Gdk.ModifierType modifier) {

        return (event.state & modifier)  == modifier;
    }

    private void setup_file_monitor () {
        if (file_monitor != null) {
            file_monitor.cancel ();
        }

        if (current_file != null) {
            try {
                file_monitor = current_file.monitor_file (
                    FileMonitorFlags.NONE);
            } catch (Error e) {
                warning ("Could not monitor file");
            }
            file_monitor.changed.connect (file_changed_event);
        }
    }

    private void file_changed_event (File old_file, File? new_file,
                                     FileMonitorEvent event_type) {
        switch (event_type) {
        case FileMonitorEvent.CHANGED:
            use_file (old_file, false);
            break;

        case FileMonitorEvent.MOVED:
            use_file (new_file);
            break;
        }
    }

    private void update_state () {
        file_modified = true;
    }

    private void schedule_autosave_timer () {
        if (autosave_timer_scheduled) {
            remove_autosave_timer ();
        }
        if (prefs.autosave_interval > 0) {
            autosave_timer_id = Timeout.add (prefs.autosave_interval * 60 * 1000, autosave_func);
            autosave_timer_scheduled = true;
        }
    }

    private void remove_autosave_timer () {
        if (autosave_timer_scheduled) {
            Source.remove(autosave_timer_id);
        }
    }

    private bool autosave_func () {
        if (current_file != null) {
            save_action ();
        }
        return true;
    }

    private void schedule_timer () {
        timer_id = Timeout.add (TIME_TO_REFRESH, render_func);
        timer_scheduled = true;
    }

    private void remove_timer () {
        if (timer_scheduled) {
            Source.remove(timer_id);
        }
    }

    private bool render_func () {
        update_html_view ();
        timer_scheduled = false;
        return false;
    }

    private string get_data_file_uri (string filename) {
        File file = File.new_for_path ("../data/assets/"+filename);
        if (file.query_exists ()) {
            return file.get_uri ();
        }

        file = File.new_for_uri (Constants.PKGDATADIR+"/"+filename);
        if (file.query_exists ()) {
            return file.get_uri ();
        }

        return "";
    }

    /**
     * Process the frontmatter of a markdown document, if it exists.
     * Returns the frontmatter data and strips the frontmatter from the markdown doc.
     *
     * @see http://jekyllrb.com/docs/frontmatter/
     */
    private string[] process_frontmatter (string raw_mk, out string processed_mk) {
        string[] map = {};

        processed_mk = null;

        // Parse frontmatter
        if (raw_mk.length > 4 && raw_mk[0:4] == "---\n") {
            int i = 0;
            bool valid_frontmatter = true;
            int last_newline = 3;
            int next_newline;
            string line = "";
            while (true) {
                next_newline = raw_mk.index_of_char('\n', last_newline + 1);
                if (next_newline == -1) { // End of file
                    valid_frontmatter = false;
                    break;
                }
                line = raw_mk[last_newline+1:next_newline];
                last_newline = next_newline;

                if (line == "---") { // End of frontmatter
                    break;
                }

                var sep_index = line.index_of_char(':');
                if (sep_index != -1) {
                    map += line[0:sep_index-1];
                    map += line[sep_index+1:line.length];
                } else { // No colon, invalid frontmatter
                    valid_frontmatter = false;
                    break;
                }

                i++;
            }

            if (valid_frontmatter) { // Strip frontmatter if it's a valid one
                processed_mk = raw_mk[last_newline:raw_mk.length];
            }
        }

        if (processed_mk == null) {
            processed_mk = raw_mk;
        }

        return map;
    }

    private string process (string raw_mk) {
        string processed_mk;
        process_frontmatter (raw_mk, out processed_mk);

        var mkd = new Markdown.Document (processed_mk.data);
        mkd.compile ();

        string result;
        mkd.get_document (out result);

        string html = "<html><head>";
        if (prefs.render_stylesheet) {
            html += "<style>"+render_stylesheet+"</style>";
        }
        if (prefs.render_syntax_highlighting) {
            html += "<style>"+syntax_stylesheet+"</style>";
            html += "<script>"+syntax_script+"</script>";
            html += "<script>hljs.initHighlightingOnLoad();</script>";
        }
        html += "</head><body><div class=\"markdown-body\">";
        html += result;
        html += "</div></body></html>";

        return html;
    }

    private void update_html_view () {
        string text = doc.get_text ();
        string html = process (text);
        html_view.load_html (html, null);
        updated ();
    }

    private void new_action () {
        if (file_modified) {
            var dialog = new UnsavedChangesDialog.for_close_file (this);
            var result = dialog.run ();
            dialog.destroy ();

            if (result == UnsavedChangesResult.CANCEL) {
                return;
            } else if (result == UnsavedChangesResult.SAVE) {
                save_action ();
            } else {
                // the user doesn't care about the file,
                // close it anyway
                reset_file ();
            }
        }
        reset_file ();
    }

    private void open_action () {
        var new_file = get_file_from_user (DialogType.MARKDOWN_IN);
        use_file (new_file);
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

    private void close_action () {
        close ();
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
        var file = get_file_from_user (DialogType.PDF_OUT);

        try {
            FileHandler.create_file_if_not_exists (file);
        } catch (Error e) {
            warning ("Could not write initial PDF file: %s", e.message);
            return;
        }

        var op = new WebKit.PrintOperation (html_view);
        var settings = new Gtk.PrintSettings ();
        settings.set_printer (dgettext ("gtk30", "Print to File"));
        settings[Gtk.PRINT_SETTINGS_OUTPUT_URI] = "file://" + file.get_path ();
        op.set_print_settings (settings);

        op.print ();
    }

    private void export_print_action () {
        var op = new WebKit.PrintOperation (html_view);
        op.run_dialog (this);
    }

    private void preferences_action () {
        var dialog = new PreferencesDialog(this, this.prefs);
        dialog.show_all ();
    }

    private void about_action () {
        app.show_about (this);
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
