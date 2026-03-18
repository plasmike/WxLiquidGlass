#pragma once
#include <wx/wx.h>

struct WxLiquidGlassOptions
{
    double cornerRadius = 5.0;
    bool opaque = false;
};

namespace wxLiquidGlass
{
    // Returns a glass instance ID
    int AddGlassEffect(wxWindow* window, const WxLiquidGlassOptions& opts);

    void RemoveGlassEffect(int id);
}
