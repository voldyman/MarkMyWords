[CCode (cprefix = "mkd")]
namespace Markdown {

    [Compact]
    [CCode (cheader_filename = "mkdio.h", cname = "MMIOT", free_function = "mkd_cleanup")]
    public class Document {

        [CCode (cname = "mkd_string")]
        public Document.for_string (uint8[] data, int flag);

        [CCode (cname = "mkd_compile")]
        public void compile (int flag);

        [CCode (cname = "mkd_document")]
        public int get_document (out unowned string result);
    }
}