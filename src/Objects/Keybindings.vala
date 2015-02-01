public class Keybindings : Settings {
    public string underline { get; set; }

    public Keybindings () {
        base ("org.markmywords.keybindings");
    }

    public override void load () {
        this.underline = settings.get_string ("underline");
    }
}