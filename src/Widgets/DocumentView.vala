public delegate void KBDAction ();

public struct KBDInfo {
    uint keyval;
    Gdk.ModifierType mask;

    KBDAction action;
}

public class DocumentView : Gtk.ScrolledWindow {
    private Gtk.SourceView code_view;
    private Gtk.SourceBuffer code_buffer;
    private List<KBDInfo?> bindings;

    public signal void changed ();

    public DocumentView () {
        setup_code_view ();

        bindings = new List<KBDInfo?> ();
    }


    public void set_text (string text) {
        code_buffer.text = text;
    }

    public void reset () {
        code_buffer.text = "";
    }

    public string get_text () {
        return code_view.buffer.text;
    }

    public void give_focus () {
        code_view.grab_focus ();
    }

    public void set_font (string name) {
        var font = Pango.FontDescription.from_string (name);
        code_view.override_font (font);
    }

    public void set_scheme (string id) {
        var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
        var style = style_manager.get_scheme (id);
        code_buffer.set_style_scheme (style);
    }

    public override bool key_press_event (Gdk.EventKey ev) {
        bool handled = false;

        foreach (KBDInfo kbd in bindings) {
            // check if the keys pressed match
            // some value in the stored bindings
            if ((ev.keyval == kbd.keyval) &&
                ((ev.state & kbd.mask) != 0)) {

                kbd.action ();
                handled = true;
            }
        }

        return handled;
    }

    private string get_default_scheme () {
        var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
        if ("solarized-dark" in style_manager.scheme_ids) { // In Gnome
            return "solarized-dark";
        } else { // In Elementary
            return "solarizeddark";
        }
    }

    private void setup_code_view () {
        // need to setup language
        var manager = Gtk.SourceLanguageManager.get_default ();
        var language = manager.guess_language (null, "text/x-markdown");
        code_buffer = new Gtk.SourceBuffer.with_language (language);

        code_view = new Gtk.SourceView.with_buffer (code_buffer);

        code_buffer.changed.connect (() => {
            changed ();
        });

        // make it look pretty
        code_view.left_margin = 5;
        code_view.pixels_above_lines = 5;

        code_view.show_line_numbers = true;

        this.set_scheme (this.get_default_scheme ());

        add (code_view);
    }

    private void underline_text () {
        message ("Underlining");
    }

    private void bold_text () {
        message ("bold");
    }

    private void italic_text () {
        message ("italic");
    }

    private void strike_text () {
        message ("strike");
    }

    private void link_text () {
        message ("link");
    }

    private void image_text () {
        message ("image");
    }

    private void code_text () {
        message ("code");
    }

    private void highlight_text () {
        message ("highlight");
    }

    private void task_list_text () {
        message ("task_list");
    }

    private void ordered_list_text () {
        message ("ordered list");
    }

    private void unordered_list_text () {
        message ("unordered_list");
    }

    private void blockquote_text () {
        message ("blockquote");
    }

    private void section_break_text () {
        message ("section break");
    }

    private void page_break_text () {
        message ("page break");
    }

    private void sentence_break_text () {
        message ("sentence break");
    }

    public void set_keybindings (Keybindings kbd) {
        uint keyval;
        Gdk.ModifierType mask;

        Gtk.accelerator_parse (kbd.underline, out keyval, out mask);
        var underline = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = underline_text
        };

        Gtk.accelerator_parse (kbd.bold, out keyval, out mask);
        var bold = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = bold_text
        };

        Gtk.accelerator_parse (kbd.italic, out keyval, out mask);
        var italic = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = italic_text
        };

        Gtk.accelerator_parse (kbd.strike, out keyval, out mask);
        var strike = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = strike_text
        };

        Gtk.accelerator_parse (kbd.link, out keyval, out mask);
        var link = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = link_text
        };

        Gtk.accelerator_parse (kbd.image, out keyval, out mask);
        var image = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = image_text
        };

        Gtk.accelerator_parse (kbd.code, out keyval, out mask);
        var code = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = code_text
        };

        Gtk.accelerator_parse (kbd.highlight, out keyval, out mask);
        var highlight = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = highlight_text
        };

        Gtk.accelerator_parse (kbd.task_list, out keyval, out mask);
        var task_list = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = task_list_text
        };

        Gtk.accelerator_parse (kbd.ordered_list, out keyval, out mask);
        var ordered_list = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = ordered_list_text
        };

        Gtk.accelerator_parse (kbd.unordered_list, out keyval, out mask);
        var unordered_list = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = unordered_list_text
        };

        Gtk.accelerator_parse (kbd.blockquote, out keyval, out mask);
        var blockquote = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = blockquote_text
        };

        Gtk.accelerator_parse (kbd.section_break, out keyval, out mask);
        var section_break = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = section_break_text
        };

        Gtk.accelerator_parse (kbd.page_break, out keyval, out mask);
        var page_break = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = page_break_text
        };

        Gtk.accelerator_parse (kbd.sentence_break, out keyval, out mask);
        var sentence_break = KBDInfo () {
            keyval = keyval,
            mask = mask,
            action = sentence_break_text
        };

        bindings = new List<KBDInfo?> ();
        bindings.append (underline);
        bindings.append (bold);
        bindings.append (italic);
        bindings.append (strike);
        bindings.append (link);
        bindings.append (code);
        bindings.append (highlight);
        bindings.append (task_list);
        bindings.append (ordered_list);
        bindings.append (unordered_list);
        bindings.append (blockquote);
        bindings.append (section_break);
        bindings.append (page_break);
        bindings.append (sentence_break);
        // this won't work as
        // ctrl+shift+i is for gnome-inspector
        bindings.append (image);
     }

}