#include <print>

#include "counter.h"
#include "utils.h"

int main() {
  std::println("{}", utils::get_greeting());

  naive::Counter naive_counter;
  locked::Counter locked_counter;
  lock_free::Counter lock_free_counter;
  for (auto i = 0; i < 5; ++i) {
    naive_counter.increment();
    locked_counter.increment();
    lock_free_counter.increment();
  }

  std::println("naive counter: {}", naive_counter.get());
  std::println("locked counter: {}", locked_counter.get());
  std::println("lock free counter: {}", lock_free_counter.get());

  return 0;
}
