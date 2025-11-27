#include "utils.h"

#include <gtest/gtest.h>

namespace utils {

TEST(HelloWorldTest, GetGreeting) {
  std::string greeting = get_greeting();
  EXPECT_FALSE(greeting.empty());
  EXPECT_EQ(greeting, "Hello, World!");
}

}  // namespace utils
