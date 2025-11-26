# Test executable
add_executable(lock_free_test lock_free_test.cpp)
target_link_libraries(lock_free_test PRIVATE lock_free GTest::gtest_main)
target_include_directories(lock_free_test PRIVATE ${CMAKE_SOURCE_DIR}/include)

# Discover tests
include(GoogleTest)
gtest_discover_tests(lock_free_test)
