#pragma once

#include <wx/wx.h>
#include <wx/wxprec.h>
#include "WxLiquidGlass/WxLiquidGlass.h"

class MyFrame : public wxFrame
{
public:
    MyFrame();
    ~MyFrame();
    MyFrame(const wxString& title, const wxPoint& pos, const wxSize& size);

private:
    int m_glassId = -1;
};
