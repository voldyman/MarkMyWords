public enum UnsavedChangesResult {
    SAVE,
    CANCEL,
    QUIT
}

public class UnsavedChangesDialog : Gtk.MessageDialog {

    public UnsavedChangesDialog.for_quit () {
        use_markup = true;
        set_markup ("<span weight='bold' size='larger'>" +
                    _("Are you sure you want to quit MarkMyWords?") + "</span>\n\n" +
                    _("The current file has some unsaved changes which " + 
                      "would be lost if you quit."));

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.show ();
        add_action_widget (cancel_button,
                           UnsavedChangesResult.CANCEL);

        var exit_button = new Gtk.Button.with_label (_("Quit MarkMyWords"));
        exit_button.show ();
        add_action_widget (exit_button,
                           UnsavedChangesResult.QUIT);

        var warning_image = new Gtk.Image.from_icon_name ("dialog-warning",
                                                          Gtk.IconSize.DIALOG);
        warning_image.show ();
        set_image (warning_image);
    }

    public UnsavedChangesDialog.for_close_file () {
        use_markup = true;
        set_markup ("<span weight='bold' size='larger'>" +
                    _("Save changes to document before closing?") + "</span>\n\n" +
                    _("The changes made to the current document haven't been saved " + 
                      "and would be permanently lost."));
        var close_button = new Gtk.Button.with_label (_("Close Without Saving"));
        close_button.show ();
        add_action_widget (close_button,
                           UnsavedChangesResult.QUIT);

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.show ();
        add_action_widget (cancel_button,
                           UnsavedChangesResult.CANCEL);

        var save_button = new Gtk.Button.with_label (_("Save"));
        save_button.show ();
        add_action_widget (save_button,
                           UnsavedChangesResult.SAVE);

        var warning_image = new Gtk.Image.from_icon_name ("dialog-warning",
                                                          Gtk.IconSize.DIALOG);
        warning_image.show ();
        set_image (warning_image);
    }
}