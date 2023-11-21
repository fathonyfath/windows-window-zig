const std = @import("std");
const foundation = @import("win32").foundation;
const windows_and_messaging = @import("win32").ui.windows_and_messaging;
const library_loader = @import("win32").system.library_loader;

const HINSTANCE = foundation.HINSTANCE;
const classname = std.unicode.utf8ToUtf16LeStringLiteral("window");
const title = std.unicode.utf8ToUtf16LeStringLiteral("window");

pub fn main() !void {
    const module_handle = library_loader.GetModuleHandleW(null) orelse unreachable;

    const hInstance = @as(HINSTANCE, @ptrCast(module_handle));

    const window_class_info = windows_and_messaging.WNDCLASSEXW{
        .cbSize = @sizeOf(windows_and_messaging.WNDCLASSEXW),
        .style = windows_and_messaging.WNDCLASS_STYLES.initFlags(.{}),
        .lpfnWndProc = windowProc,
        .cbClsExtra = 0,
        .cbWndExtra = @sizeOf(usize),
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .hInstance = hInstance,
        .lpszClassName = classname,
        .hIconSm = null,
    };

    if (windows_and_messaging.RegisterClassExW(&window_class_info) == 0) {
        return error.RegisterClassFailed;
    }

    const extraWindowStyle = windows_and_messaging.WINDOW_EX_STYLE.initFlags(.{});
    const windowStyle = windows_and_messaging.WINDOW_STYLE.initFlags(.{
        .VISIBLE = 1,
        .CAPTION = 1,
        .SYSMENU = 1,
        .THICKFRAME = 1,
    });
    const x = 0;
    const y = 0;
    const width = 800;
    const height = 600;
    const handle = windows_and_messaging.CreateWindowExW(extraWindowStyle, classname, title, windowStyle, x, y, width, height, null, null, hInstance, null) orelse return error.CreateWindowFailed;
    _ = windows_and_messaging.ShowWindow(handle, windows_and_messaging.SW_SHOW);

    var msg: windows_and_messaging.MSG = undefined;

    var running: bool = true;
    while (running) {
        while (windows_and_messaging.PeekMessageW(&msg, null, 0, 0, windows_and_messaging.PM_REMOVE) == 1) {
            if (msg.message == windows_and_messaging.WM_QUIT) {
                std.log.debug("Quit...", .{});
                running = false;
            }

            _ = windows_and_messaging.TranslateMessage(&msg);
            _ = windows_and_messaging.DispatchMessageW(&msg);
        }
    }
}

fn windowProc(
    hwnd: foundation.HWND,
    uMsg: u32,
    wParam: foundation.WPARAM,
    lParam: foundation.LPARAM,
) callconv(std.os.windows.WINAPI) foundation.LRESULT {
    switch (uMsg) {
        windows_and_messaging.WM_DESTROY => {
            std.log.debug("Destroy...", .{});
            windows_and_messaging.PostQuitMessage(0);
            return 0;
        },
        else => {
            return windows_and_messaging.DefWindowProcW(hwnd, uMsg, wParam, lParam);
        },
    }
}
