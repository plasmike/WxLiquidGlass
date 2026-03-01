#ifdef __APPLE__

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#include <map>

struct GlassCtx {
    NSVisualEffectView* effectView;
    NSView* hostView;
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
    } while (0)
    extern "C" int WxAddLiquidGlass(void* nativeViewPtr)
    {
        if (!nativeViewPtr)
            return -1;

        __block int result = -1;

        RUN_ON_MAIN(^{

            NSView* hostView = (__bridge NSView*)nativeViewPtr;
            if (!hostView)
                return;

            NSWindow* window = [hostView window];
            if (!window)
                return;

            // Make window transparent
            [window setOpaque:YES];
            [window setBackgroundColor:[NSColor clearColor]];
            window.titlebarAppearsTransparent = YES;
            window.styleMask |= NSWindowStyleMaskFullSizeContentView;

            NSRect bounds = [hostView bounds];

            NSVisualEffectView* effect =
                [[NSVisualEffectView alloc] initWithFrame:bounds];

            effect.autoresizingMask =
                NSViewWidthSizable | NSViewHeightSizable;

            effect.blendingMode = NSVisualEffectBlendingModeBehindWindow;
            effect.material = NSVisualEffectMaterialUnderWindowBackground;
            effect.state = NSVisualEffectStateActive;

            effect.wantsLayer = YES;
            effect.layer.cornerRadius = 16.0;
            effect.layer.masksToBounds = YES;

            // Insert behind wx content
            [hostView addSubview:effect
                      positioned:NSWindowBelow
                      relativeTo:nil];

            int id = g_nextId++;
            GlassCtx ctx;
            ctx.effectView = effect;
            ctx.hostView = hostView;
            g_registry[id] = ctx;

            result = id;
        });

        return result;
    }

extern "C" void WxRemoveLiquidGlass(int viewId)
{
    RUN_ON_MAIN(^{
        auto it = g_registry.find(viewId);
        if (it == g_registry.end())
            return;

        if (it->second.effectView)
            [it->second.effectView removeFromSuperview];

        g_registry.erase(it);
    });
}

#endif
