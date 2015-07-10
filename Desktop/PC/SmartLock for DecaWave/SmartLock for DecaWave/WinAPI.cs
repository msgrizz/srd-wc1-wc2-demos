using System;
using System.Runtime.InteropServices;
using System.Drawing;
using System.ComponentModel;

namespace Plantronics.UC.SmartLock
{
    public enum TaskbarPosition
    {
        Unknown = -1,
        Left,
        Top,
        Right,
        Bottom,
    }

    public enum ABE : uint
    {
        Left = 0,
        Top = 1,
        Right = 2,
        Bottom = 3
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT
    {
        public int left;
        public int top;
        public int right;
        public int bottom;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct APPBARDATA
    {
        public uint cbSize;
        public IntPtr hWnd;
        public uint uCallbackMessage;
        public ABE uEdge;
        public RECT rc;
        public int lParam;
    }

    public enum ABM : uint
    {
        New = 0x00000000,
        Remove = 0x00000001,
        QueryPos = 0x00000002,
        SetPos = 0x00000003,
        GetState = 0x00000004,
        GetTaskbarPos = 0x00000005,
        Activate = 0x00000006,
        GetAutoHideBar = 0x00000007,
        SetAutoHideBar = 0x00000008,
        WindowPosChanged = 0x00000009,
        SetState = 0x0000000A,
    }

    public class WinAPI
    {
        public struct RECT
        {
            public int left;
            public int top;
            public int right;
            public int bottom;

            public override string ToString()
            {
                return "(" + left + ", " + top + ") --> (" + right + ", " + bottom + ")";
            }
        }

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr FindWindow(string strClassName, string strWindowName);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr FindWindowEx(IntPtr parentHandle, IntPtr childAfter, string className, IntPtr windowTitle);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("shell32.dll", SetLastError = true)]
        public static extern IntPtr SHAppBarMessage(ABM dwMessage, [In] ref APPBARDATA pData);

        // Struct we'll need to pass to the function
        internal struct LASTINPUTINFO
        {
            public uint cbSize;
            public uint dwTime;
        }

        // Unmanaged function from user32.dll
        [DllImport("user32.dll")]
        static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        public static IntPtr GetTrayHandle()
        {
            IntPtr taskBarHandle = WinAPI.FindWindow("Shell_TrayWnd", null);
            if (!taskBarHandle.Equals(IntPtr.Zero))
            {
                return WinAPI.FindWindowEx(taskBarHandle, IntPtr.Zero, "TrayNotifyWnd", IntPtr.Zero);
            }
            return IntPtr.Zero;
        }

        public static Rectangle GetTrayRectangle()
        {
            WinAPI.RECT rect;
            WinAPI.GetWindowRect(WinAPI.GetTrayHandle(), out rect);
            return new Rectangle(new Point(rect.left, rect.top), new Size((rect.right - rect.left) + 1, (rect.bottom - rect.top) + 1));
        }

        public static TaskbarPosition GetTaskBarPosition()
        {
            TaskbarPosition tbpos = TaskbarPosition.Unknown;
            IntPtr taskbarHandle = WinAPI.FindWindow("Shell_TrayWnd", null);
            if (!taskbarHandle.Equals(IntPtr.Zero))
            {
                APPBARDATA data = new APPBARDATA();
                data.cbSize = (uint)Marshal.SizeOf(typeof(APPBARDATA));
                data.hWnd = taskbarHandle;
                IntPtr result = SHAppBarMessage(ABM.GetTaskbarPos, ref data);
                if (result == IntPtr.Zero)
                    throw new InvalidOperationException();

                tbpos = (TaskbarPosition)data.uEdge;
            }
            return tbpos;
        }

        // How long has user been idle on their PC?
        public static int GetIdleTime()
        {
            // Get the system uptime
            int systemUptime = Environment.TickCount;

            // The tick at which the last input was recorded
            int LastInputTicks = 0;

            // The number of ticks that passed since last input
            int IdleTicks = 0;

            // Set the struct
            LASTINPUTINFO LastInputInfo = new LASTINPUTINFO();
            LastInputInfo.cbSize = (uint)Marshal.SizeOf(LastInputInfo);
            LastInputInfo.dwTime = 0;

            // If we have a value from the function
            if (GetLastInputInfo(ref LastInputInfo))
            {
                // Get the number of ticks at the point when the last activity was seen
                LastInputTicks = (int)LastInputInfo.dwTime;
                // Number of idle ticks = system uptime ticks - number of ticks at last input
                IdleTicks = systemUptime - LastInputTicks;
            }

            // divide by 1000 to transform the milliseconds to seconds
            return IdleTicks / 1000;
        }

        // LC new screen saver detection code... (for stopping non-password protected screen saver)
        // Signatures for unmanaged calls
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern bool SystemParametersInfo(
           int uAction, int uParam, ref int lpvParam,
           int flags);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern bool SystemParametersInfo(
           int uAction, int uParam, ref bool lpvParam,
           int flags);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr OpenDesktop(
           string hDesktop, int Flags, bool Inherit,
           uint DesiredAccess);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern bool CloseDesktop(
           IntPtr hDesktop);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern bool EnumDesktopWindows(
           IntPtr hDesktop, EnumDesktopWindowsProc callback,
           IntPtr lParam);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern bool IsWindowVisible(
           IntPtr hWnd);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr GetForegroundWindow();

        // Callbacks
        public delegate bool EnumDesktopWindowsProc(
           IntPtr hDesktop, IntPtr lParam);

        // Constants
        public const int SPI_GETSCREENSAVERACTIVE = 16;
        public const int SPI_SETSCREENSAVERACTIVE = 17;
        public const int SPI_GETSCREENSAVERTIMEOUT = 14;
        public const int SPI_SETSCREENSAVERTIMEOUT = 15;
        public const int SPI_GETSCREENSAVERRUNNING = 114;
        public const int SPIF_SENDWININICHANGE = 2;

        public const uint DESKTOP_WRITEOBJECTS = 0x0080;
        public const uint DESKTOP_READOBJECTS = 0x0001;
        public const int WM_CLOSE = 16;

        [DllImport("user32.dll")]
        public static extern bool LockWorkStation();
        public const int WM_SYSCOMMAND = 0x112;
        public const int SC_SCREENSAVE = 0xF140;

        // from winuser.h
        // receive notifications of users windows session (unlock, when user logs back in)
        // from wtsapi32.h
        public const int NotifyForThisSession = 0;

        public const int SessionChangeMessage = 0x02B1;
        public const int SessionLockParam = 0x7;
        public const int SessionUnlockParam = 0x8;

        [DllImport("wtsapi32.dll")]
        public static extern bool WTSRegisterSessionNotification(IntPtr hWnd, int dwFlags);

        [DllImport("wtsapi32.dll")]
        public static extern bool WTSUnRegisterSessionNotification(IntPtr hWnd);

        // Win32 interop stuff for one instance only handling
        public const int HWND_BROADCAST = 0xffff;
        public static readonly int WM_SHOWME = RegisterWindowMessage("WM_SHOWME_SMARTLOCK");

        [DllImport("user32.dll")]
        public static extern int PostMessage(IntPtr hWnd, int msg, int wParam, int lParam);

        [DllImport("user32.dll")]
        public static extern int RegisterWindowMessage(string message);
   }
}