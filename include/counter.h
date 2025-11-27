#pragma once

#include <atomic>
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
