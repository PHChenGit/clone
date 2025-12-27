cmake_minimum_required(VERSION 3.22)
project(clone LANGUAGES CXX)

# [修正 1] Slint 強烈建議使用 C++20
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- 下載 Slint ---
find_package(Slint QUIET)
if (NOT Slint_FOUND)
  message(STATUS "Slint not found. Fetching from git...")
  include(FetchContent)
  FetchContent_Declare(
    Slint
    GIT_REPOSITORY https://github.com/slint-ui/slint.git
    GIT_TAG release/1
    SOURCE_SUBDIR api/cpp
  )
  FetchContent_MakeAvailable(Slint)
endif (NOT Slint_FOUND)

add_executable(clone src/main.cpp)

slint_target_sources(clone 
    ui/app-window.slint 
)

target_link_libraries(clone PRIVATE Slint::Slint)

# [修正 4] 修正 Windows DLL 複製指令
# 這裡必須使用你的 target 名稱 "clone"，原本寫成 my_application 會報錯
if (WIN32)
    add_custom_command(TARGET clone POST_BUILD 
        COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:clone> $<TARGET_FILE_DIR:clone> 
        COMMAND_EXPAND_LISTS
    )
endif()