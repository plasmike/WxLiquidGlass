#include "EmptyWindow.h"


MyFrame::MyFrame()
    : wxFrame(nullptr, wxID_ANY, "Wx Liquid Glass", wxDefaultPosition, wxSize(500, 250))
{

#ifdef PLATFORM_OSX
    this->CreateStatusBar();

    this->SetStatusText("Liquid Glass Test");

    WxLiquidGlassOptions opts;
    opts.cornerRadius = 16.0;
    opts.opaque = false;

    m_glassId = wxLiquidGlass::AddGlassEffect(this, opts);
#endif
}

MyFrame::~MyFrame()
{

#ifdef PLATFORM_OSX
    wxLiquidGlass::RemoveGlassEffect(m_glassId);
#endif
}
