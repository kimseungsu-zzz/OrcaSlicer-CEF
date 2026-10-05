// Run Chromium child processes without passing their arguments through the
// OrcaSlicer command-line parser.
#include "include/cef_app.h"
#include "include/cef_browser.h"
#include "include/cef_v8.h"
#include "include/cef_version_info.h"

namespace {

class WxPostMessageHandler : public CefV8Handler
{
public:
    bool Execute(const CefString& name,
                 CefRefPtr<CefV8Value> object,
                 const CefV8ValueList& arguments,
                 CefRefPtr<CefV8Value>& retval,
                 CefString& exception) override
    {
        if (name != "postMessage" || arguments.size() != 1 || !arguments[0]->IsString())
            return false;

        CefRefPtr<CefV8Context> context = CefV8Context::GetCurrentContext();
        CefRefPtr<CefBrowser> browser = context ? context->GetBrowser() : nullptr;
        if (!browser)
            return false;

        CefRefPtr<CefProcessMessage> message = CefProcessMessage::Create("wxWebViewMessage");
        message->GetArgumentList()->SetString(0, arguments[0]->GetStringValue());
        browser->GetMainFrame()->SendProcessMessage(PID_BROWSER, message);
        return true;
    }

    IMPLEMENT_REFCOUNTING(WxPostMessageHandler);
};

class OrcaCefRenderApp : public CefApp, public CefRenderProcessHandler
{
public:
    CefRefPtr<CefRenderProcessHandler> GetRenderProcessHandler() override
    {
        return this;
    }

    void OnWebKitInitialized() override
    {
        CefRegisterExtension("wx/webview", R"(
            var wx;
            if (!wx) wx = {};
            (function() {
                native function postMessage();
                wx.postMessage = function(message) { postMessage(message); };
            })();
        )", new WxPostMessageHandler());
    }

    IMPLEMENT_REFCOUNTING(OrcaCefRenderApp);
};

} // namespace

int main(int argc, char* argv[])
{
    (void)cef_api_hash(CEF_API_VERSION, 0);
    CefMainArgs args(argc, argv);
    return CefExecuteProcess(args, new OrcaCefRenderApp(), nullptr);
}
