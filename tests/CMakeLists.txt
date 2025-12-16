# Test executable
add_executable(lock_free_data_structures_test utils_test.cpp counter_test.cpp)

target_link_libraries(lock_free_data_structures_test PRIVATE data_structures
                                                             GTest::gtest_main)
target_include_directories(lock_free_data_structures_test
                           PRIVATE ${CMAKE_SOURCE_DIR}/include)
target_compile_options(lock_free_data_structures_test
                       PRIVATE ${PROJECT_WARNING_FLAGS})

# Discover tests
include(GoogleTest)
gtest_discover_tests(lock_free_data_structures_test)
