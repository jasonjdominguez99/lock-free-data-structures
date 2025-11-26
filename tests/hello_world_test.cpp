#include "hello_world.h"

#include <gtest/gtest.h>

namespace hello_world {

TEST(HelloWorldTest, GetGreeting) {
  std::string greeting = get_greeting();
  EXPECT_FALSE(greeting.empty());
  EXPECT_EQ(greeting, "Hello, World!");
}

}  // namespace hello_world
