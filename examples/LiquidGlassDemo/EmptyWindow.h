#pragma once

#include <wx/wx.h>
#include "WxLiquidGlass/WxLiquidGlass.h"

class MyFrame : public wxFrame
{
public:
    MyFrame();
    ~MyFrame();

private:
    int m_glassId = -1;
};
