#pragma once
#include <wx/wx.h>

struct wxLiquidGlassOptions
{
    double cornerRadius = 5.0;
    bool opaque = false;
};

namespace wxLiquidGlass
{
    void SwiftBridgeTestFunc();
    // Returns a glass instance ID
    int AddGlassEffect(wxWindow* window, const wxLiquidGlassOptions& opts);

    void RemoveGlassEffect(int id);
}
