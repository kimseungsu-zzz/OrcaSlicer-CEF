function(apply_wx_cef_patch patch marker source_file)
    file(READ "${CEF_SOURCE}/${source_file}" _cef_source_contents)
    string(FIND "${_cef_source_contents}" "${marker}" _patch_already_applied)

    if (_patch_already_applied EQUAL -1)
        execute_process(
            COMMAND git apply --verbose "${CMAKE_CURRENT_LIST_DIR}/${patch}"
            WORKING_DIRECTORY "${CEF_SOURCE}"
            RESULT_VARIABLE _patch_result
        )
        if (NOT _patch_result EQUAL 0)
            message(FATAL_ERROR "Failed to apply ${patch}")
        endif ()
    endif ()
endfunction()

apply_wx_cef_patch(
    "0002-cef-cmake-options.patch"
    "CEF uses nested generator expressions"
    "build/cmake/lib/webview_chromium/CMakeLists.txt"
)
apply_wx_cef_patch(
    "0003-cef-151-api.patch"
    "include/cef_version_info.h"
    "src/common/webview_chromium.cpp"
)
apply_wx_cef_patch(
    "0004-cef-cxx20-compat.patch"
    "cef_api_hash(CEF_API_VERSION, 0)"
    "src/common/webview_chromium.cpp"
)
apply_wx_cef_patch(
    "0005-cef-script-message-bridge.patch"
    "wxWebViewChromium::AddScriptMessageHandler"
    "src/common/webview_chromium.cpp"
)
