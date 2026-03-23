cmake_minimum_required(VERSION 3.29)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

project(wxLiquidGlass LANGUAGES CXX)

find_package(wxWidgets REQUIRED)

if(APPLE)
  enable_language(OBJC OBJCXX Swift)
endif()

# Sources

add_library(wxLiquidGlass
  src/wxLiquidGlass.cpp
  include/wxLiquidGlass/wxLiquidGlass.h
  src/wxLiquidGlassCommon.h
)

# Swift - CXX interop/bridge
if (APPLE)
  target_sources(wxLiquidGlass PRIVATE
    src/wxLiquidGlass.mm
    src/wxLiquidGlassBridge.swift
  )

  add_custom_command(
      OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/src/wxLiquidGlass-Swift.h
      COMMAND swiftc -frontend -typecheck
              ${CMAKE_CURRENT_SOURCE_DIR}/src/wxLiquidGlassBridge.swift
              -module-name wxLiquidGlassBridge # namespace name inside of the wxLiquidGlass-Swift.h file
              -cxx-interoperability-mode=default
              -sdk ${CMAKE_OSX_SYSROOT}
              -emit-clang-header-path ${CMAKE_CURRENT_SOURCE_DIR}/src/wxLiquidGlass-Swift.h
      DEPENDS src/wxLiquidGlassBridge.swift
      COMMENT "Generating Swift - Cxx interop/bridge header"
  )
  add_custom_target(wxLiquidGlass_SwiftHeader
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/wxLiquidGlass-Swift.h
  )
  add_dependencies(wxLiquidGlass wxLiquidGlass_SwiftHeader)

  target_compile_options(wxLiquidGlass PRIVATE
    $<$<COMPILE_LANGUAGE:Swift>:-cxx-interoperability-mode=default>
    $<$<COMPILE_LANGUAGE:Swift>:-module-name wxLiquidGlassBridge>
  )

  find_library(APPKIT_LIBRARY AppKit)
  find_library(FOUNDATION_LIBRARY Foundation)
  target_link_libraries(wxLiquidGlass PRIVATE ${APPKIT_LIBRARY} ${FOUNDATION_LIBRARY})
endif()

# Include directories

target_include_directories(wxLiquidGlass
    PUBLIC
      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
      $<INSTALL_INTERFACE:include>
)

# Dependencies

target_link_libraries(wxLiquidGlass
  PUBLIC
  wxWidgets::wxWidgets
)

# For windows builds
if(WIN32)
  target_link_libraries(wxLiquidGlass PRIVATE gdiplus)
endif()


# only build examples if this is the top-level project
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  add_subdirectory(examples/LiquidGlassDemo)
endif()
