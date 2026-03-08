#pragma once

#ifdef __APPLE__
struct WxLiquidGlassOptions
{
    double cornerRadius = 5.0;
    bool opaque = false;
};

namespace wxLiquidGlass
{
    // Returns a glass instance ID
    int AddGlassEffect(void* nativeView, const WxLiquidGlassOptions& opts);

    void RemoveGlassEffect(int id);
}

#endif
