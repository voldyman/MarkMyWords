const string GETTEXT_PACKAGE = "markmywords";

int main(string[] args) {
    Intl.setlocale(LocaleCategory.MESSAGES, "");
    Intl.textdomain(GETTEXT_PACKAGE); 
    Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
    Intl.bindtextdomain(GETTEXT_PACKAGE, "../po");

    var app = new MarkMyWordsApp ();
    return app.run (args);
}
