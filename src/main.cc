#include <iostream>
#include <fstream>
#include <sstream>
#include <cstring>

#include <vala-ui.h>
// discount, the markdown lib
// is written in C
extern "C" {
#include <mkdio.h>
}

char* converter(const char *raw_str, void *vala_ctx)
{
  MMIOT *data = mkd_string(raw_str,
                           strlen(raw_str), 0);

  mkd_compile(data, 0);

  char *result;
  int len = mkd_document(data, &result);

  char *ret = g_strdup(result);
  mkd_cleanup(data);
  return ret;
}

int read_file(const char *file_location, char **file_data, void *vala_ctx)
{
  std::fstream file(file_location);
  std::stringstream data;
  std::string cur_line;

  if (file.is_open()) {
    while(std::getline(file, cur_line)) {
      data << cur_line;
    }
    *file_data = g_strdup(data.str().c_str());

    return 1;
  }
  return -1;
}

void updated()
{
  std::cout << "ui updated" <<std::endl;
}

int main(int argc, char *argv[])
{
  MarkdownConverter cv = converter;

  // create window
  Window *w = window_new(argv, argc);
  // setup backend
  window_set_converter(w, cv, nullptr);
  window_set_reader(w, read_file, nullptr);
  g_signal_connect(w, "updated",
                   G_CALLBACK(updated), nullptr);
  window_run(w);
  window_unref(w);
  return 0;
}
