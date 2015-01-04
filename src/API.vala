
// Functions that we need
public delegate string MarkdownConverter (string data);
public delegate bool FileReader (string file_location, out string data);
public delegate bool FileWriter (string file_location,
                                 string data, int length);

public struct API {
    MarkdownConverter mk_converter;
    FileReader read_file;
    FileWriter write_file;
}