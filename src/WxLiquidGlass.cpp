#include "WxLiquidGlass/WxLiquidGlass.h"
#include "WxLiquidGlassCommon.h"

#include <wx/wx.h>

namespace wxLiquidGlass {

int AddGlassEffect(wxWindow* window, const WxLiquidGlassOptions& opts) {
#ifdef __APPLE__
    if (!window) return -1;

    // make sure native handle exists
    void* nativeHandle = window->GetHandle();
    if (!nativeHandle) {
        window->Show();
        nativeHandle = window->GetHandle();
    }
    if (!nativeHandle) return -1;

    // call our objective c++ function that adds NSGlassEffectView
    int id = ::wxLiquidGlass::AddGlassEffect(nativeHandle, opts);

    return id;
#else
    return -1;
#endif
}



void RemoveGlassEffect(int id) {
#ifdef __APPLE__
    ::wxLiquidGlass::RemoveGlassEffect(id);
#endif
}

} // namespace wxLiquidGlass
