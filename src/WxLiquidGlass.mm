#include "WxLiquidGlassCommon.h"

#ifdef PLATFORM_OSX
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

#include <objc/runtime.h>
#include <objc/message.h>
#include <map>

#include <iostream>

struct GlassContext
{
    NSView* glassView; // NSGlassEffectView*
    NSView* hostView; // Native View to attach to
    NSView* containerView; // Parent we injected into (NSThemeFrame for root windows)
    NSBox* backgroundView; // Optional opaque backing layer
    int id;
};

static std::map<int, GlassContext> g_registry;
static int g_nextViewId = 1;

// Keys for objc-associated objects (to find ID from View)
static const void *kGlassContextIdKey = &kGlassContextIdKey;

#define RUN_ON_MAIN(block)                                  \
  if ([NSThread isMainThread]) {                            \
    block();                                                \
  } else {                                                  \
    dispatch_sync(dispatch_get_main_queue(), block);        \
  }

// Inject NSGlassEffectView behind the native view
extern "C" int AddGlassEffectView(void* nativeViewPtr, bool opaque)
{
    if (!nativeViewPtr)
        return -1;

    __block int resultId = -1;

    RUN_ON_MAIN(^{
        NSView* rootView = reinterpret_cast<NSView *>(nativeViewPtr);
        if (!rootView) return;

        // Remove existing glass to prevent stacking duplicates
        NSNumber *existingId = objc_getAssociatedObject(rootView, kGlassContextIdKey);
        if (existingId) {
            RemoveGlassEffectView([existingId intValue]);
        }

        NSWindow *win = [rootView window];
        bool isRoot = (win && [win contentView] == rootView);

        NSView *container = nil;
        if (isRoot) {
            // Root window: force transparency and inject into the frame
            [win setOpaque:NO];
            [win setBackgroundColor:[NSColor clearColor]];
            win.styleMask |= NSWindowStyleMaskFullSizeContentView;
            win.titlebarAppearsTransparent = YES;

            // Inject into NSThemeFrame's content slot, or swap if needed
            if ([rootView superview]) {
                container = [rootView superview];
            } else {
                // Frameless: wrap rootView in a new container
                NSRect frame = [rootView frame];
                NSView *newContainer = [[NSView alloc] initWithFrame:frame];
                newContainer.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
                newContainer.wantsLayer = YES;

                [win setContentView:newContainer];

                [rootView setFrame:newContainer.bounds];
                [rootView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
                [newContainer addSubview:rootView];

                container = newContainer;
            }
        } else {
            // Child widget: inject inside its native view
            container = rootView;
        }

        NSRect frameRect = (container == rootView) ? [rootView bounds] : [rootView frame];
        if (isRoot && container != [rootView superview]) {
             frameRect = [container bounds];
        }

        // Optional opaque backing layer
        NSBox *backgroundView = nil;
        if (opaque) {
            backgroundView = [[NSBox alloc] initWithFrame:frameRect];
            backgroundView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
            backgroundView.boxType = NSBoxCustom;
            backgroundView.borderType = NSNoBorder;
            backgroundView.fillColor = [NSColor windowBackgroundColor];
            backgroundView.wantsLayer = YES;
        }

        NSView *glass = nil;
        Class glassCls = NSClassFromString(@"NSGlassEffectView");
        if (glassCls) {
            glass = [[glassCls alloc] initWithFrame:frameRect];
        } else {
            // Fallback to NSVisualEffectView on older macOS
            std::cout << "FALLBACK to NSVisualEffectView activated" << std::endl;
            NSVisualEffectView *visual = [[NSVisualEffectView alloc] initWithFrame:frameRect];
            visual.blendingMode = NSVisualEffectBlendingModeBehindWindow;
            visual.material = NSVisualEffectMaterialUnderWindowBackground;
            visual.state = NSVisualEffectStateActive;
            glass = visual;
        }
        glass.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        glass.wantsLayer = YES;

        // Subview order: [Background] -> [Glass] -> [Wx Content]
        if (container == rootView) {
            if (backgroundView) {
                [container addSubview:backgroundView positioned:NSWindowBelow relativeTo:nil];
                [container addSubview:glass positioned:NSWindowAbove relativeTo:backgroundView];
            } else {
                [container addSubview:glass positioned:NSWindowBelow relativeTo:nil];
            }
        } else {
            if (backgroundView) {
                [container addSubview:backgroundView positioned:NSWindowBelow relativeTo:rootView];
                [container addSubview:glass positioned:NSWindowAbove relativeTo:backgroundView];
            } else {
                [container addSubview:glass positioned:NSWindowBelow relativeTo:rootView];
            }
        }

        // Register context and associate the ID with the host view
        int id = g_nextViewId++;
        GlassContext ctx;
        ctx.id = id;
        ctx.glassView = glass;
        ctx.backgroundView = backgroundView;
        ctx.hostView = rootView;
        ctx.containerView = container;

        g_registry[id] = ctx;
        objc_setAssociatedObject(rootView, kGlassContextIdKey, @(id), OBJC_ASSOCIATION_RETAIN);

        resultId = id;
      });

      return resultId;
    }


// Detach Glass and backing views, clear associated object and remove object from registry
extern "C" void RemoveGlassEffectView(int viewId)
{
    RUN_ON_MAIN(^{
        auto it = g_registry.find(viewId);
        if (it == g_registry.end())
          return;
        GlassContext& ctx = it->second;

        // Detach views and clear associated object on the host
        if (ctx.glassView) [ctx.glassView removeFromSuperview];
        if (ctx.backgroundView) [ctx.backgroundView removeFromSuperview];
        if (ctx.hostView) {
          objc_setAssociatedObject(ctx.hostView, kGlassContextIdKey, nil, OBJC_ASSOCIATION_ASSIGN);
        }

        g_registry.erase(it);
    });
}

#endif
