#include <benchmark/benchmark.h>

#include "counter.h"

// ===== Single-threaded: Baseline =====
static void BM_NaiveCounter(benchmark::State& state) {
  naive::Counter counter;
  for (auto _ : state) {
    counter.increment();
    benchmark::DoNotOptimize(counter);
  }
}
BENCHMARK(BM_NaiveCounter);

static void BM_LockedCounter(benchmark::State& state) {
  locked::Counter counter;
  for (auto _ : state) {
    counter.increment();
  }
}
BENCHMARK(BM_LockedCounter);

static void BM_LockFreeCounter(benchmark::State& state) {
  lock_free::Counter counter;
  for (auto _ : state) {
    counter.increment();
  }
}
BENCHMARK(BM_LockFreeCounter);

// ===== Multi-threaded: Pure Writes =====
static void BM_LockedCounter_Increment_MT(benchmark::State& state) {
  static locked::Counter counter;
  for (auto _ : state) {
    counter.increment();
  }
}
BENCHMARK(BM_LockedCounter_Increment_MT)->ThreadRange(1, 16)->UseRealTime();

static void BM_LockFreeCounter_Increment_MT(benchmark::State& state) {
  static lock_free::Counter counter;
  for (auto _ : state) {
    counter.increment();
  }
}
BENCHMARK(BM_LockFreeCounter_Increment_MT)->ThreadRange(1, 16)->UseRealTime();

static void BM_DistributedCounter_Increment_MT(benchmark::State& state) {
  static distributed::Counter counter(static_cast<size_t>(state.threads()));
  const size_t thread_id = static_cast<size_t>(state.thread_index());
  for (auto _ : state) {
    counter.increment(thread_id);
  }
}
BENCHMARK(BM_DistributedCounter_Increment_MT)
    ->ThreadRange(1, 16)
    ->UseRealTime();

// ===== Multi-threaded: Pure Reads =====
static void BM_LockedCounter_Get_MT(benchmark::State& state) {
  static locked::Counter counter;
  // Pre-populate
  if (state.thread_index() == 0) {
    for (int i = 0; i < 1000; ++i) counter.increment();
  }

  for (auto _ : state) {
    auto result = counter.get();
    benchmark::DoNotOptimize(result);
  }
}
BENCHMARK(BM_LockedCounter_Get_MT)->ThreadRange(1, 16)->UseRealTime();

static void BM_LockFreeCounter_Get_MT(benchmark::State& state) {
  static lock_free::Counter counter;
  if (state.thread_index() == 0) {
    for (int i = 0; i < 1000; ++i) counter.increment();
  }

  for (auto _ : state) {
    auto result = counter.get();
    benchmark::DoNotOptimize(result);
  }
}
BENCHMARK(BM_LockFreeCounter_Get_MT)->ThreadRange(1, 16)->UseRealTime();

static void BM_DistributedCounter_Get_MT(benchmark::State& state) {
  static distributed::Counter counter(static_cast<size_t>(state.threads()));
  const size_t thread_id = static_cast<size_t>(state.thread_index());
  if (state.thread_index() == 0) {
    for (int i = 0; i < 1000; ++i) counter.increment(thread_id);
  }

  for (auto _ : state) {
    auto result = counter.get();
    benchmark::DoNotOptimize(result);
  }
}
BENCHMARK(BM_DistributedCounter_Get_MT)->ThreadRange(1, 16)->UseRealTime();

// ===== Multi-threaded: Realistic Mix (90% write, 10% read) =====
static void BM_LockedCounter_Mixed_MT(benchmark::State& state) {
  static locked::Counter counter;
  int op_count = 0;

  for (auto _ : state) {
    if (++op_count % 10 == 0) {
      auto result = counter.get();
      benchmark::DoNotOptimize(result);
    } else {
      counter.increment();
    }
  }
}
BENCHMARK(BM_LockedCounter_Mixed_MT)->ThreadRange(1, 16)->UseRealTime();

static void BM_LockFreeCounter_Mixed_MT(benchmark::State& state) {
  static lock_free::Counter counter;
  int op_count = 0;

  for (auto _ : state) {
    if (++op_count % 10 == 0) {
      auto result = counter.get();
      benchmark::DoNotOptimize(result);
    } else {
      counter.increment();
    }
  }
}
BENCHMARK(BM_LockFreeCounter_Mixed_MT)->ThreadRange(1, 16)->UseRealTime();

static void BM_DistributedCounter_Mixed_MT(benchmark::State& state) {
  static distributed::Counter counter(static_cast<size_t>(state.threads()));
  const size_t thread_id = static_cast<size_t>(state.thread_index());
  int op_count = 0;

  for (auto _ : state) {
    if (++op_count % 10 == 0) {
      auto result = counter.get();
      benchmark::DoNotOptimize(result);
    } else {
      counter.increment(thread_id);
    }
  }
}
BENCHMARK(BM_DistributedCounter_Mixed_MT)->ThreadRange(1, 16)->UseRealTime();
