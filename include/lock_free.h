#pragma once

#include <string>

/**
 * @brief Main namespace for the lock_free library
 *
 * Contains greeting-related functionality demonstrating
 * modern C++23 patterns and best practices.
 */
namespace lock_free {

/**
 * @brief Get a greeting message
 *
 * Returns a standard greeting string that can be used
 * for demonstration purposes.
 *
 * @return A greeting message as a string
 */
std::string get_greeting();

}  // namespace lock_free
