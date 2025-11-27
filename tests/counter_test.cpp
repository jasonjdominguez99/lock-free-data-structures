#include "counter.h"

#include <gtest/gtest.h>

#include <thread>

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

// DistributedCounter Tests
TEST(DistributedCounter, InitializesAtZero) {
  distributed::Counter counter(1);
  EXPECT_EQ(counter.get(), 0);
}

TEST(DistributedCounter, IncrementsByOne) {
  distributed::Counter counter(1);
  EXPECT_EQ(counter.get(), 0);
  counter.increment(0);
  EXPECT_EQ(counter.get(), 1);
}

TEST(DistributedCounter, MultiThreadedIncrements) {
  const int64_t NUM_INCREMENTS_PER_THREAD = 100;
  const int64_t NUM_THREADS = 2;

  distributed::Counter counter(static_cast<size_t>(NUM_THREADS));
  EXPECT_EQ(counter.get(), 0);

  {
    std::vector<std::jthread> threads;
    threads.reserve(NUM_THREADS);
    for (size_t thread_id = 0; thread_id < NUM_THREADS; ++thread_id) {
      threads.emplace_back([&counter, thread_id, NUM_INCREMENTS_PER_THREAD]() {
        for (int64_t i = 0; i < NUM_INCREMENTS_PER_THREAD; ++i)
          counter.increment(thread_id);
      });
    }
  }

  EXPECT_EQ(counter.get(), NUM_INCREMENTS_PER_THREAD * NUM_THREADS);
}
