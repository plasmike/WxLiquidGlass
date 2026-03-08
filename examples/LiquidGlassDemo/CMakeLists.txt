cmake_minimum_required(VERSION 3.15)
project(WxGlassExamples LANGUAGES CXX)

if(APPLE)
  enable_language(OBJC OBJCXX)
endif()

find_package(wxWidgets REQUIRED)

add_executable(WxGlassExamples
  main.cpp
  EmptyWindow.cpp
)


target_link_libraries(${PROJECT_NAME} PRIVATE wxWidgets::wxWidgets wxLiquidGlass)
