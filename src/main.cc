#include <iostream>
#include <cstring>

#include <vala-ui.h>
// discount, the markdown lib
// is written in C
extern "C" {
#include <mkdio.h>
}

char*
converter(const char *raw_str, void *vala_ctx)
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

void updated()
{
  std::cout << "ui updated" <<std::endl;
}
int main(int argc, char *argv[])
{
  MarkdownConverter cv = converter;

  Window *w = window_new(argv, argc, cv, nullptr);
  g_signal_connect(w, "updated",
                   G_CALLBACK(updated), nullptr);
  window_run(w);
  window_unref(w);
  return 0;
}
