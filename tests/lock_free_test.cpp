#include "lock_free.h"

#include <gtest/gtest.h>

namespace lock_free {

TEST(HelloWorldTest, GetGreeting) {
  std::string greeting = get_greeting();
  EXPECT_FALSE(greeting.empty());
  EXPECT_EQ(greeting, "Hello, World!");
}

}  // namespace lock_free
