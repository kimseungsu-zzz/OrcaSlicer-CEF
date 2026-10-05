// Run Chromium child processes without passing their arguments through the
// OrcaSlicer command-line parser.
#include "include/cef_app.h"

int main(int argc, char* argv[])
{
    CefMainArgs args(argc, argv);
    return CefExecuteProcess(args, nullptr, nullptr);
}
