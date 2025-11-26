#include <print>

#include "hello_world.h"

int main() {
  std::println("{}", hello_world::get_greeting());
  return 0;
}
