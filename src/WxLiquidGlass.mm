#ifdef __APPLE__

#import <AppKit/AppKit.h>
#include <map>
#include "WxLiquidGlass.h"
#include <objc/message.h>

struct GlassCtx
{
    NSView* hostView;
    NSView* glassView; // NSGlassEffectView*
};

static std::map<int, GlassCtx> g_registry;
static int g_nextId = 1;

#define RUN_ON_MAIN(block)                          \
    do {                                            \
        if ([NSThread isMainThread]) {              \
            block();                                \
        } else {                                    \
            dispatch_sync(dispatch_get_main_queue(), block); \
        }                                           \
    } while(0)

extern "C" int WxLiquidGlass_AddGlassEffect(void* nativeViewPtr, const WxLiquidGlassOptions& opts)
{
    if (!nativeViewPtr)
        return -1;

    __block int result = -1;

    RUN_ON_MAIN(^{

        NSView* hostView = (__bridge NSView*)nativeViewPtr;
        if (!hostView) return;

        NSWindow* window = [hostView window];
        if (!window) return;

        // Transparent window so the glass effect shows through
        [window setOpaque:NO];
        [window setBackgroundColor:[NSColor clearColor]];
        window.titlebarAppearsTransparent = YES;
        window.styleMask |= NSWindowStyleMaskFullSizeContentView;

        NSRect bounds = [hostView bounds];

        // Dynamically instantiate NSGlassEffectView
        Class glassClass = NSClassFromString(@"NSGlassEffectView");
        NSView* glass = nil;
        if (glassClass) {
            glass = [[glassClass alloc] initWithFrame:bounds];
        } else {
            // fallback for old macOS
            NSVisualEffectView* visual = [[NSVisualEffectView alloc] initWithFrame:bounds];
            visual.material = NSVisualEffectMaterialSidebar;
            visual.blendingMode = NSVisualEffectBlendingModeBehindWindow;
            visual.state = NSVisualEffectStateActive;
            glass = visual;
        }

        glass.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        glass.wantsLayer = YES;

        // Set corner radius if possible
        if (glass.layer) {
            glass.layer.cornerRadius = opts.cornerRadius;
            glass.layer.masksToBounds = (opts.cornerRadius > 0);
        }

        // Insert behind content
        [hostView addSubview:glass positioned:NSWindowBelow relativeTo:nil];

        int id = g_nextId++;
        GlassCtx ctx;
        ctx.hostView = hostView;
        ctx.glassView = glass;

        g_registry[id] = ctx;
        result = id;
    });

    return result;
}

extern "C" void WxLiquidGlass_RemoveGlassEffect(int glassId)
{
    RUN_ON_MAIN(^{
        auto it = g_registry.find(glassId);
        if (it == g_registry.end()) return;

        if (it->second.glassView) {
            [it->second.glassView removeFromSuperview];
        }

        g_registry.erase(it);
    });
}

#endif
