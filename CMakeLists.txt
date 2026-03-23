cmake_minimum_required(VERSION 3.29)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

project(wxLiquidGlass LANGUAGES CXX)

find_package(wxWidgets REQUIRED)

if(APPLE)
  enable_language(OBJC OBJCXX)
endif()

add_library(wxLiquidGlass
  src/wxLiquidGlass.cpp
  src/wxLiquidGlass.mm
  include/wxLiquidGlass/wxLiquidGlass.h
  src/wxLiquidGlassCommon.h
)

if(APPLE)
  target_sources(wxLiquidGlass PRIVATE src/wxLiquidGlass.mm)

  find_library(APPKIT_LIBRARY AppKit)
  find_library(FOUNDATION_LIBRARY Foundation)

  target_link_libraries(wxLiquidGlass PRIVATE ${APPKIT_LIBRARY} ${FOUNDATION_LIBRARY})
endif()

target_include_directories(wxLiquidGlass
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
)

target_link_libraries(wxLiquidGlass
PUBLIC
wxWidgets::wxWidgets
)

if(WIN32) # for windows builds
    target_link_libraries(wxLiquidGlass PRIVATE gdiplus)
endif()


# only build examples if this is the top-level project
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  add_subdirectory(examples/LiquidGlassDemo)
endif()
