#pragma once

#include <atomic>
#include <cassert>
#include <concepts>
#include <mutex>

template <typename T>
concept Counter = requires(T t, const T ct) {
  { t.increment() } -> std::same_as<void>;
  { ct.get() } -> std::same_as<int64_t>;
};

namespace naive {

class Counter {
 public:
  Counter() = default;
  ~Counter() = default;

  void increment() noexcept { ++count_; }
  [[nodiscard]] int64_t get() const noexcept { return count_; }

 private:
  int64_t count_ = 0;
};

}  // namespace naive

namespace locked {

class Counter {
 public:
  Counter() = default;
  ~Counter() = default;

  Counter(const Counter&) = delete;
  Counter& operator=(const Counter&) = delete;
  Counter(Counter&&) = delete;
  Counter& operator=(Counter&&) = delete;

  void increment() noexcept {
    std::scoped_lock lock(mtx_);
    ++count_;
  }
  [[nodiscard]] int64_t get() const noexcept {
    std::scoped_lock lock(mtx_);
    return count_;
  }

 private:
  mutable std::mutex mtx_;
  int64_t count_ = 0;
};

}  // namespace locked

namespace lock_free {

class Counter {
 public:
  Counter() = default;
  ~Counter() = default;

  Counter(const Counter&) = delete;
  Counter& operator=(const Counter&) = delete;
  Counter(Counter&&) = delete;
  Counter& operator=(Counter&&) = delete;

  void increment() noexcept { count_.fetch_add(1, std::memory_order_relaxed); }
  [[nodiscard]] int64_t get() const noexcept {
    return count_.load(std::memory_order_relaxed);
  }

 private:
  std::atomic<int64_t> count_ = 0;
};

}  // namespace lock_free

namespace distributed {

class Counter {
 public:
  explicit Counter(const size_t num_threads) : num_threads_(num_threads_) {
    assert(num_threads_ < MAX_THREADS);
  }
  ~Counter() = default;

  Counter(const Counter&) = delete;
  Counter& operator=(const Counter&) = delete;
  Counter(Counter&&) = delete;
  Counter& operator=(Counter&&) = delete;

  void increment(const size_t thread_id) noexcept {
    counts_[thread_id].value.fetch_add(1, std::memory_order_relaxed);
  }

  [[nodiscard]] int64_t get() const noexcept {
    int64_t total = 0;
    for (size_t i = 0; i < num_threads_; ++i) {
      total += counts_[i].value.load(std::memory_order_relaxed);
    }
    return total;
  }

 private:
  static constexpr size_t MAX_THREADS = 64;

  struct alignas(64) PaddedAtomicInt64 {
    std::atomic<int64_t> value = 0;
  };

  PaddedAtomicInt64 counts_[MAX_THREADS];
  size_t num_threads_;
};

}  // namespace distributed
