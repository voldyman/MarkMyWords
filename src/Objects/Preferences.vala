public class Preferences : Settings {
    public string editor_font { get; set; default = ""; }
    public string editor_scheme { get; set; default = ""; }
    public bool render_stylesheet { get; set; default = true; }
    public string render_stylesheet_uri { get; set; default = ""; }
    public bool render_syntax_highlighting { get; set; default = false; }
    public bool prefer_dark_theme { get; set; default = false; }
    public int autosave_interval { get; set; default = 0; }
    public bool use_headerbar { get; set; }
    
    public Preferences () {
        base ("org.markmywords.settings");
    }

    public override void load () {
        this.editor_font = settings.get_string ("editor-font");
        this.editor_scheme = settings.get_string ("editor-scheme");
        this.render_stylesheet = settings.get_boolean ("render-stylesheet");
        this.render_stylesheet_uri = settings.get_string ("render-stylesheet-uri");
        this.render_syntax_highlighting = settings.get_boolean ("render-syntax-highlighting");
        this.prefer_dark_theme = settings.get_boolean ("prefer-dark-theme");
        this.autosave_interval = settings.get_int ("autosave-interval");
        this.use_headerbar = settings.get_boolean ("use-headerbar");
    }
}