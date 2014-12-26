#include <iostream>
#include <fstream>
#include <sstream>
#include <cstring> // for strlen

// discount, the markdown lib
// is written in C
extern "C" {
#include <mkdio.h>
}

char* markdown_converter(const char *raw_str)
{
  MMIOT *data = mkd_string(raw_str,
                           strlen(raw_str), 0);

  mkd_compile(data, 0);

  char *result;
  int len = mkd_document(data, &result);

//  char *ret = std::strdup(result);
  char *ret = new char[len+1];
  std::copy(result, result+len+1, ret);

  mkd_cleanup(data);
  return ret;
}

int read_file(const char *file_location, char **file_data)
{
  std::fstream file(file_location);
  std::stringstream string_buffer;
  std::string cur_line;

  if (file.is_open()) {
    while(std::getline(file, cur_line)) {
      string_buffer << cur_line;
    }
    std::string data = string_buffer.str().c_str();
    const char * data_c_str = data.c_str();
    int len = data.length()+1;
    char *ret = new char[len];
    std::copy(data_c_str, data_c_str+len,
              ret);
    *file_data = ret;
    
    return 1;
  }
  return -1;
}
