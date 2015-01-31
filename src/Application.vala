public class MarkMyWordsApp : Gtk.Application {

    private static bool print_version = false;
    private static bool show_about_dialog = false;

    public MarkMyWordsApp () {
        Object (application_id: "com.voldyman.markmywords",
                flags: ApplicationFlags.HANDLES_COMMAND_LINE);

    }

    public override void activate () {
        new_window ();
    }

    public override int command_line (ApplicationCommandLine command_line) {
        hold ();
        int res = _command_line (command_line);
        release ();
        return res;
    }

    private void new_window () {
        var window = new Window (this);
        add_window (window);
        window.show_all ();
    }

    private int _command_line (ApplicationCommandLine command_line) {
        var context = new OptionContext (MarkMyWords.APP_NAME);
        context.add_main_entries (entries, MarkMyWords.APP_SYSTEM_NAME);
        context.add_group (Gtk.get_option_group (true));

        string[] args = command_line.get_arguments ();

        try {
            unowned string[] tmp = args;
            context.parse (ref tmp);
        } catch (Error e) {
            stdout.printf ("%s: Error: %s \n", "MarkMyWords", e.message);
            return 0;
        }

        if (print_version) {
            stdout.printf ("%s %s\n", MarkMyWords.APP_NAME, MarkMyWords.APP_VERSION);
            stdout.printf ("Copyright 2014-2015 '%s' Developers.\n", MarkMyWords.APP_NAME);
        } else if (show_about_dialog) {
            show_about ();
        } else {
            new_window ();
        }

        return 0;
    }

    public void show_about (Window? parent = null) {
        var dialog = new AboutDialog ();

        if (parent != null) {
            dialog.set_transient_for (parent);
        } 

        dialog.run ();
    }

    static const OptionEntry[] entries = {
        { "version", 'v', 0, OptionArg.NONE, out print_version, N_("Print version info and exit"), null },
        { "about", 'a', 0, OptionArg.NONE, out show_about_dialog, N_("Show about dialog"), null },
        { null }
    };

}
