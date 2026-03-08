#include <wx/wx.h>
#include "EmptyWindow.h"

class MyApp : public wxApp
{
public:
    bool OnInit() override
    {
        MyFrame* frame = new MyFrame();
        frame->Show(true);
        return true;
    }
};

wxIMPLEMENT_APP(MyApp);
