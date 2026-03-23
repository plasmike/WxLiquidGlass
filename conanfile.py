import os
from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMakeDeps, cmake_layout

class WxLiquidGlassRecipe(ConanFile):
  name = "wxLiquidGlass"

  # config
  settings = "os", "compiler", "build_type", "arch"
  options = {"shared": [True, False], "fPIC": [True, False]}
  default_options = {"shared": False, "fPIC": True}

  def requirements(self):
    self.requires("wxwidgets/3.3.1")

  def layout(self):
    cmake_layout(self)

  def generate(self):
    tc = CMakeToolchain(self)
    tc.user_presets_path = None # prevent conan from overwriting our CMakeUserPresets.json
    tc.generate()
    cmake = CMakeDeps(self)
    cmake.generate()
