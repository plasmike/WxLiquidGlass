#pragma once

#if defined(__APPLE__) && defined(__MACH__)
  #define PLATFORM_OSX
#endif

#ifdef PLATFORM_OSX
  // Dont include AppKit/Foundation bc this header is included by WxLiquidGlass.cpp which is a standard C++ file

  // Forward declarations for internal functions used by backend
  extern "C" {
    int AddGlassEffectView(void* nativeViewPtr, bool opaque);

    void RemoveGlassEffectView(int viewID);
  }

#endif
