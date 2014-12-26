#include <iostream>

#include "api.h"

void updated()
{
  std::cout << "ui updated" <<std::endl;
}

int main(int argc, char *argv[])
{
  run_ui(argc, argv);
  return 0;
}
