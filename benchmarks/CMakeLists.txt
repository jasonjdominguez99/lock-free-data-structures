# Benchmark executable
add_executable(lock_free_benchmark lock_free_benchmark.cpp)
target_link_libraries(lock_free_benchmark PRIVATE lock_free
                                                    benchmark::benchmark_main)
target_include_directories(lock_free_benchmark
                           PRIVATE ${CMAKE_SOURCE_DIR}/include)
