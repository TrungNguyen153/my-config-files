// Prints the mouse position inside the foreground window as "x y", in physical
// pixels from the top-left of its client area.
//
// WezTerm's Lua API has no way to ask where the mouse is, and its click event
// for the tab bar button carries no position, so lua/workspace_bar.lua runs
// this to learn which workspace was clicked. It compiles this file on first use
// with the csc.exe that ships with Windows; delete cursor-pos.exe from the
// state directory (%LOCALAPPDATA%\wezterm) to rebuild after editing.
using System;
using System.Runtime.InteropServices;

static class CursorPos
{
    [StructLayout(LayoutKind.Sequential)]
    struct Point
    {
        public int X, Y;
    }

    [DllImport("user32.dll")]
    static extern bool SetProcessDPIAware();

    [DllImport("user32.dll")]
    static extern bool GetCursorPos(out Point point);

    [DllImport("user32.dll")]
    static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    static extern bool ScreenToClient(IntPtr window, ref Point point);

    static int Main()
    {
        // Without this, a scaled display reports virtualised coordinates that
        // do not match the pixel sizes WezTerm works in.
        SetProcessDPIAware();

        Point point;
        if (!GetCursorPos(out point) || !ScreenToClient(GetForegroundWindow(), ref point))
        {
            return 1;
        }
        Console.WriteLine(point.X + " " + point.Y);
        return 0;
    }
}
