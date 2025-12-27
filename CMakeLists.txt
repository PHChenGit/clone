cmake_minimum_required(VERSION 3.21)
project(clone LANGUAGES CXX)

include(FetchContent)

FetchContent_Declare(
    lucide_slint
    GIT_REPOSITORY https://github.com/cnlancehu/lucide-slint.git
    GIT_TAG        0.562.0
)
FetchContent_MakeAvailable(lucide_slint)

find_package(Slint QUIET)
if (NOT Slint_FOUND)
  message("Slint could not be located in the CMake module search path. Downloading it from Git and building it locally")
  include(FetchContent)
  FetchContent_Declare(
    Slint
    GIT_REPOSITORY https://github.com/slint-ui/slint.git
    # `release/1` will auto-upgrade to the latest Slint >= 1.0.0 and < 2.0.0
    # `release/1.0` will auto-upgrade to the latest Slint >= 1.0.0 and < 1.1.0
    GIT_TAG release/1
    SOURCE_SUBDIR api/cpp
  )
  FetchContent_MakeAvailable(Slint)
endif (NOT Slint_FOUND)

add_executable(clone src/main.cpp)
target_link_libraries(clone PRIVATE Slint::Slint)
slint_target_sources(clone ui/app-window.slint LIBRARY_PATHS "lucide=${lucide_slint_SOURCE_DIR}")
# On Windows, copy the Slint DLL next to the application binary so that it's found.
if (WIN32)
    add_custom_command(TARGET clone POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:my_application> $<TARGET_FILE_DIR:my_application> COMMAND_EXPAND_LISTS)
endif()
