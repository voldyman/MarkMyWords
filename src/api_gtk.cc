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

int gtk_write_file(const char *file_location, const char *data,
                   int length, void *user_data)
{
  bool status = write_file(file_location, data, length);
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
  ret->write_file = gtk_write_file;

  return ret;
}

void run_ui(int argc, char *argv[])
{
  API *api = get_gtk_api();

  run (argv, argc, api);
}
