
#include <vala-ui.h>

#include "api.h"

char* gtk_markdown_converter(const char *data, void *user_data)
{
  return markdown_converter(data);
}

int gtk_read_file(const char *file_location, char **data, void *user_data)
{
  bool status =  read_file(file_location, data);
  if (status) {
    return 1;
  } else {
    return 0;
  }
}

API* get_gtk_api()
{
  API *ret = new API;
  ret->mk_converter = gtk_markdown_converter;
  ret->read_file = gtk_read_file;

  return ret;
}

void run_ui(int argc, char *argv[])
{
  API *api = get_gtk_api();

  Window *win = window_new(argv, argc, api);
//  g_signal_connect(w, "updated",
//                   G_CALLBACK(updated), nullptr);

  window_run(win);
}
