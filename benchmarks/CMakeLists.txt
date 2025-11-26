# Benchmark executable
add_executable(hello_world_benchmark hello_world_benchmark.cpp)
target_link_libraries(hello_world_benchmark PRIVATE hello_world
                                                    benchmark::benchmark_main)
target_include_directories(hello_world_benchmark
                           PRIVATE ${CMAKE_SOURCE_DIR}/include)
