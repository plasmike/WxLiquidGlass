#include "wxLiquidGlass/wxLiquidGlass.h"
#include "wxLiquidGlassCommon.h"
#include "wxLiquidGlass-Swift.h"

namespace wxLiquidGlass {

void SwiftBridgeTestFunc()
{
#ifdef PLATFORM_OSX
    wxLiquidGlassBridge::SwiftBridgeTest();
#endif
}

int AddGlassEffect(wxWindow* window, const wxLiquidGlassOptions& opts) {
#ifdef PLATFORM_OSX
    if (!window)
      return -1;

    if (!window->IsShown())
      window->Show();

    window->Update();
    window->Refresh();

    void* nativeHandle = window->GetHandle();
    if (!nativeHandle)
      return -1;

    // call our objective c++ function that adds NSGlassEffectView
    int id = AddGlassEffectView(nativeHandle, opts.opaque);

    // add custom materials here

    return id;
#else
    return -1;
#endif
}

void RemoveGlassEffect(int id) {
#ifdef PLATFORM_OSX
    RemoveGlassEffectView(id);
#endif
}
} // namespace wxLiquidGlass
