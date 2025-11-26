# Test executable
add_executable(hello_world_test hello_world_test.cpp)
target_link_libraries(hello_world_test PRIVATE hello_world GTest::gtest_main)
target_include_directories(hello_world_test PRIVATE ${CMAKE_SOURCE_DIR}/include)

# Discover tests
include(GoogleTest)
gtest_discover_tests(hello_world_test)
