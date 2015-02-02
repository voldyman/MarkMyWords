public class Keybindings : Settings {
    public string underline { get; set; }
    public string bold { get; set; }
    public string italic { get; set; }
    public string strike { get; set; }
    public string link { get; set; }
    public string image { get; set; }
    public string code { get; set; }
    public string highlight { get; set; }
    public string task_list { get; set; }
    public string ordered_list { get; set; }
    public string unordered_list { get; set; }
    public string blockquote { get; set; }
    public string section_break { get; set; }
    public string page_break { get; set; }
    public string sentence_break { get; set; }
    
    public Keybindings () {
        base ("org.markmywords.keybindings");
    }

    public override void load () {
        this.underline = settings.get_string ("underline");
        this.bold = settings.get_string ("bold");
        this.italic = settings.get_string ("italic");
        this.strike = settings.get_string ("strike");
        this.link = settings.get_string ("link");
        this.image = settings.get_string ("image");
        this.code = settings.get_string ("code");
        this.highlight = settings.get_string ("highlight");
        this.task_list = settings.get_string ("task-list");
        this.ordered_list = settings.get_string ("ordered-list");
        this.unordered_list = settings.get_string ("unordered-list");
        this.blockquote = settings.get_string ("blockquote");
        this.section_break = settings.get_string ("section-break");
        this.page_break = settings.get_string ("page-break");
        this.sentence_break = settings.get_string ("sentence-break");

    }
}