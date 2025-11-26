#include <print>

#include "lock_free.h"

int main() {
  std::println("{}", lock_free::get_greeting());
  return 0;
}
