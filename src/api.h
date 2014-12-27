#ifndef API_H
#define API_H

char* markdown_converter(const char *raw_str);
int read_file(const char *file_location, char **file_data);
bool write_file(const char *file_location, char *data, int lenght);

// implemented differently for each platform
void run_ui(int argc, char *argv[]);

#endif
