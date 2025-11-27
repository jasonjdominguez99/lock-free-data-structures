#include "counter.h"

#include <gtest/gtest.h>

template <typename T>
class CounterTest : public ::testing::Test {
  static_assert(Counter<T>, "Type must satisfy Counter concept");
};

using CounterTypes =
    ::testing::Types<naive::Counter, locked::Counter, lock_free::Counter>;

TYPED_TEST_SUITE(CounterTest, CounterTypes);

TYPED_TEST(CounterTest, InitializesAtZero) {
  TypeParam counter;
  EXPECT_EQ(counter.get(), 0);
}

TYPED_TEST(CounterTest, IncrementsByOne) {
  TypeParam counter;
  EXPECT_EQ(counter.get(), 0);
  counter.increment();
  EXPECT_EQ(counter.get(), 1);
}

TYPED_TEST(CounterTest, MultipleIncrements) {
  TypeParam counter;
  EXPECT_EQ(counter.get(), 0);

  const int64_t NUM_INCREMENTS = 100;

  for (auto i = 0; i < NUM_INCREMENTS; ++i) {
    counter.increment();
  }

  EXPECT_EQ(counter.get(), NUM_INCREMENTS);
}
