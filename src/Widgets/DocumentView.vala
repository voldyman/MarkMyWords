public delegate void KBDAction ();

public struct KBDInfo {
    uint keyval;
    Gdk.ModifierType mask;

    KBDAction action;
}

public class DocumentView : Gtk.ScrolledWindow {
    private Gtk.SourceView code_view;
    private Gtk.SourceBuffer code_buffer;
    private KBDInfo[] bindings;

    public signal void changed ();

    public DocumentView () {
        setup_code_view ();
    }

    public void set_text (string text, bool new_file = false) {
        if (new_file) {
            code_buffer.changed.disconnect (trigger_changed);
        }

        code_buffer.text = text;

        if (new_file) {
            code_buffer.changed.connect (trigger_changed);
        }
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
                ((ev.state & kbd.mask) == kbd.mask)) {

                kbd.action ();
                handled = true;

				// exit the loop
				break;
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

    private void trigger_changed () {
        changed ();
    }

    private void setup_code_view () {
        // need to setup language
        var manager = Gtk.SourceLanguageManager.get_default ();
        var language = manager.guess_language (null, "text/x-markdown");
        code_buffer = new Gtk.SourceBuffer.with_language (language);

        code_view = new Gtk.SourceView.with_buffer (code_buffer);

        code_buffer.changed.connect (trigger_changed);

        // make it look pretty
        code_view.left_margin = 5;
        code_view.pixels_above_lines = 5;
        // wrap text between words, we don't need to be
        // very strict since people should be wrting text not code
        code_view.wrap_mode = Gtk.WrapMode.WORD;
        code_view.show_line_numbers = true;

        this.set_scheme (this.get_default_scheme ());

        add (code_view);
    }

    private void insert_tag_at_cursor (string tag_start, string tag_end) {
        if (code_buffer.has_selection) {
            Gtk.TextIter sel_start, sel_end;
            code_buffer.get_selection_bounds (out sel_start, out sel_end);

            var end_mark = code_buffer.create_mark (null, sel_end, true);

            code_buffer.insert (ref sel_start, tag_start, tag_start.length);

            code_buffer.get_iter_at_mark (out sel_end, end_mark);
            code_buffer.insert (ref sel_end, tag_end, tag_end.length);
        } else {
            code_buffer.insert_at_cursor (tag_start,
                                          tag_start.length);

            int pos = code_buffer.cursor_position;

            code_buffer.insert_at_cursor (tag_end,
                                          tag_end.length);

            Gtk.TextIter iter;
            code_buffer.get_iter_at_offset (out iter, pos);
            code_buffer.place_cursor (iter);
            }
      }

    private void underline_text () {
        insert_tag_at_cursor ("++", "++");
    }

    private void bold_text () {
        insert_tag_at_cursor ("**", "**");
    }

    private void italic_text () {
        insert_tag_at_cursor ("*", "*");
    }

    private void strike_text () {
        insert_tag_at_cursor ("~~", "~~");
    }

    private void link_text () {
        insert_tag_at_cursor ("[", "]()");
    }

    private void image_text () {
        insert_tag_at_cursor ("![", "]()");
    }

    private void code_text () {
        insert_tag_at_cursor ("```", "```");
    }

    private void highlight_text () {
        message ("highlight");
    }

    private void task_list_text () {
        print ("task_list\n");
    }

    private void ordered_list_text () {
		print ("ordered list\n");
        //TODO: add ordered list
        insert_tag_at_cursor ("*", "");
    }

    private void unordered_list_text () {
        insert_tag_at_cursor ("*", "");
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

        bindings += underline;
        bindings += bold;
        bindings += italic;
        bindings += strike;
        bindings += link;
        bindings += code;
        bindings += highlight;
        bindings += task_list;
        bindings += ordered_list;
        bindings += unordered_list;
        bindings += blockquote;
        bindings += section_break;
        bindings += page_break;
        bindings += sentence_break;
        // this won't work as
        // ctrl+shift+i is for gnome-inspector
        bindings += image;
    }

}
