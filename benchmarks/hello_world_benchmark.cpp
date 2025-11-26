#include <benchmark/benchmark.h>

#include <string>

#include "hello_world.h"

namespace hello_world {

// Benchmark the get_greeting() function
static void BM_GetGreeting(benchmark::State& state) {
  for (auto _ : state) {
    auto result = get_greeting();
    benchmark::DoNotOptimize(result);
  }
}
BENCHMARK(BM_GetGreeting);

// Example: Benchmark with different string sizes (demonstrates parameterized
// benchmarks)
static void BM_StringConstruction(benchmark::State& state) {
  const auto size = state.range(0);
  for (auto _ : state) {
    std::string s(size, 'x');
    benchmark::DoNotOptimize(s.data());
  }
}
BENCHMARK(BM_StringConstruction)->Arg(8)->Arg(64)->Arg(512)->Arg(4096);

// Example: Benchmark with fixture (demonstrates more complex setup)
class StringFixture : public benchmark::Fixture {
 public:
  void SetUp(const ::benchmark::State& state) override {
    test_string = get_greeting();
  }

  void TearDown(const ::benchmark::State& state) override {
    // Cleanup if needed
  }

  std::string test_string;
};

BENCHMARK_F(StringFixture, FindSubstring)(benchmark::State& state) {
  for (auto _ : state) {
    auto pos = test_string.find("World");
    benchmark::DoNotOptimize(pos);
  }
}

}  // namespace hello_world
