#include <benchmark/benchmark.h>

#include "counter.h"

// Single-threaded baseline
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

// Multi-threaded
static void BM_LockedCounter_MT(benchmark::State& state) {
  static locked::Counter counter;
  for (auto _ : state) {
    if (state.iterations() % 10 == 0)
      counter.increment();
    else
      benchmark::DoNotOptimize(counter.get());
  }
}
BENCHMARK(BM_LockedCounter_MT)->ThreadRange(2, 16)->UseRealTime();

static void BM_LockFreeCounter_MT(benchmark::State& state) {
  static lock_free::Counter counter;
  for (auto _ : state) {
    if (state.iterations() % 10 == 0)
      counter.increment();
    else
      benchmark::DoNotOptimize(counter.get());
  }
}
BENCHMARK(BM_LockFreeCounter_MT)->ThreadRange(2, 16)->UseRealTime();
