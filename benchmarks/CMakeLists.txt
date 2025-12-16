# Benchmark executable
add_executable(lock_free_data_structures_benchmark utils_benchmark.cpp
                                                   counter_benchmark.cpp)

target_link_libraries(lock_free_data_structures_benchmark
                      PRIVATE data_structures benchmark::benchmark_main)

target_include_directories(lock_free_data_structures_benchmark
                           PRIVATE ${CMAKE_SOURCE_DIR}/include)
target_compile_options(lock_free_data_structures_benchmark
                       PRIVATE ${PROJECT_WARNING_FLAGS})
