#include "EmptyWindow.h"


MyFrame::MyFrame()
    : wxFrame(nullptr, wxID_ANY, "Wx Liquid Glass Test", wxDefaultPosition,
              wxSize(500, 250)) {

  SetBackgroundColour(wxColour(0, 0, 0, 0));

  wxPanel *panel = new wxPanel(this);
  wxButton *testButton =
      new wxButton(panel, wxID_ANY, "TEST", wxPoint(50, 50), wxSize(250, 50));

  this->CreateStatusBar(); // optional

#ifdef __APPLE__
  WxLiquidGlassOptions opts;
  opts.cornerRadius = 32.0;
  opts.opaque = false;

  m_glassId = wxLiquidGlass::AddGlassEffect(testButton, opts);
#endif
}

MyFrame::~MyFrame() {

#ifdef __APPLE__
  wxLiquidGlass::RemoveGlassEffect(m_glassId);
#endif
}
