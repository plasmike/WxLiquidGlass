#include "EmptyWindow.h"


MyFrame::MyFrame()
    : wxFrame(nullptr, wxID_ANY, "Wx Liquid Glass", wxDefaultPosition, wxSize(500, 250))
{

#ifdef __APPLE__
    this->CreateStatusBar();

    this->SetStatusText("Liquid Glass Test");

    WxLiquidGlassOptions opts;
    opts.cornerRadius = 16.0;

    void* native = this->GetHandle();
    m_glassId = wxLiquidGlass::AddGlassEffect(native, opts);
#endif
}

MyFrame::~MyFrame()
{

#ifdef __APPLE__
    wxLiquidGlass::RemoveGlassEffect(m_glassId);
#endif
}
