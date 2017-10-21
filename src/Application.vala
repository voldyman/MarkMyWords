public class MarkMyWordsApp : Gtk.Application {

    private static bool print_version = false;
    private static bool show_about_dialog = false;

    public MarkMyWordsApp () {
        Object (application_id: "com.voldyman.markmywords",
                flags: ApplicationFlags.HANDLES_COMMAND_LINE);

    }

    protected override void startup () {
        base.startup ();
        Gtk.Window.set_default_icon_name (MarkMyWords.ICON_NAME);
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

    private void new_window (File? open_file = null) {
        var window = new Window (this);
        add_window (window);

        if (open_file != null) {
            window.use_file (open_file);
        }

        window.present ();
    }

    private int _command_line (ApplicationCommandLine command_line) {
        var context = new OptionContext (MarkMyWords.APP_NAME);
        context.add_main_entries (entries, MarkMyWords.APP_SYSTEM_NAME);
        context.add_group (Gtk.get_option_group (true));

        string[] args = command_line.get_arguments ();
        // Copy the pointers of the strings to a new array so references to the
        // strings in args are not lost when context.parse is called
        string*[] _args = new string*[args.length];
        for (int i = 0; i < args.length; i++) {
            _args[i] = args[i];
        }
        int unclaimed_args;

        try {
            unowned string[] tmp = _args;
            context.parse (ref tmp);
            unclaimed_args = tmp.length - 1;
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
            File? file = null;
            if (unclaimed_args > 0) {
                message (_args[unclaimed_args]);
                file = File.new_for_commandline_arg (_args[unclaimed_args]);
            }

            new_window (file);
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
