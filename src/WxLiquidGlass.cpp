#include "WxLiquidGlass/WxLiquidGlass.h"
#include "WxLiquidGlassCommon.h"

namespace wxLiquidGlass {

int AddGlassEffect(wxWindow* window, const WxLiquidGlassOptions& opts) {
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
    //Q_UNUSED(opts);
    return -1;
#endif
}

void RemoveGlassEffect(int id) {
#ifdef PLATFORM_OSX
    RemoveGlassEffectView(id);
#else
    //Q_UNUSED(id);
#endif
}
} // namespace wxLiquidGlass
