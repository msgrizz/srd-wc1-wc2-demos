using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Windows.Forms;

/**
 * WindowPositionManager - a convenience class for position Windows Forms
 * either central on primary monitor or close to system tray area
 * regardless of system tray location (bottom, top, sides)
 * Also to position form to a point, ensuring first that
 * if the point is used it will be on screen! (and adjusting if not)
 * 
 * Author: Lewis Collins, Plantronics
 * Oct 2012
 * 
 **/

namespace Plantronics.UC.SmartLock
{
    public enum TaskbarLocation 
    {
        bottom,
        top,
        leftside,
        rightside
    }

    public static class WindowPosition
    {
        public static void PositionToTray(Form aForm)
        {
            // Position window to system tray
            Rectangle systrayrect = WinAPI.GetTrayRectangle();

            Point dlg_pos = new Point(systrayrect.X, systrayrect.Y);

            // Get screen coords and make sure we are inside them!
            Rectangle screenarea = Screen.PrimaryScreen.WorkingArea;
            if (dlg_pos.X < screenarea.Left)
            {
                dlg_pos.X = screenarea.Left + 5;
            }
            if ((dlg_pos.X + aForm.Width) > screenarea.Right)
            {
                dlg_pos.X = screenarea.Right - aForm.Width - 5;
            }
            if (dlg_pos.Y < screenarea.Top)
            {
                dlg_pos.Y = screenarea.Top + 5;
            }
            if ((dlg_pos.Y + aForm.Height) > screenarea.Bottom)
            {
                dlg_pos.Y = screenarea.Bottom - aForm.Height - 5;
            }

            aForm.StartPosition = FormStartPosition.Manual;
            aForm.Location = dlg_pos;
        }

        // Find out which edge of screen taskbar is located on...
        public static TaskbarLocation GetTaskbarLocation()
        {
            TaskbarLocation loc = TaskbarLocation.bottom;

            Rectangle systrayrect = WinAPI.GetTrayRectangle();

            Rectangle screenarea = Screen.PrimaryScreen.Bounds;

            if (systrayrect.Left == screenarea.Left)
            {
                loc = TaskbarLocation.leftside;
            }
            else if (systrayrect.Top == screenarea.Top)
            {
                loc = TaskbarLocation.top;
            }
            else if (Math.Abs(systrayrect.Right - screenarea.Right) < 5)
            {
                loc = TaskbarLocation.rightside;
            }

            return loc;
        }

        public static void PositionToCenter(Form aForm)
        {
            // Position window to primary display coords
            // Get screen coords and make sure we are inside them!
            Rectangle screenarea = Screen.PrimaryScreen.WorkingArea;

            Point dlg_pos = new Point();
            dlg_pos.X = screenarea.Left + (screenarea.Width / 2) - (aForm.Width / 2);
            dlg_pos.Y = screenarea.Top + (screenarea.Height / 2) - (aForm.Height / 2);

            aForm.StartPosition = FormStartPosition.Manual;
            aForm.Location = dlg_pos;
        }

        // This will position the form to the specified point
        // BUT will make adjustments if that would place the dialog
        // not on the visible screen area!
        // Returns TRUE of point was used as passed in
        // Returns FALSE if adjustments were made!
        internal static bool PositionToPointIfOnScreen(Form aForm, Point toPoint)
        {
            bool pointWasOk = true;

            // Ok what is the working screen area?
            System.Drawing.Rectangle workingRectangle =
                new Rectangle(0,0,SystemInformation.VirtualScreen.Width,SystemInformation.VirtualScreen.Height);

            // make adjustments to point to fit aForm within working area...
            if (toPoint.X < workingRectangle.Left)
            {
                toPoint.X = workingRectangle.Left;
                pointWasOk = false;
            }
            if (toPoint.Y < workingRectangle.Top)
            {
                toPoint.Y = workingRectangle.Top;
                pointWasOk = false;
            }
            if ((toPoint.X + aForm.Width) > workingRectangle.Width)
            {
                toPoint.X = workingRectangle.Width - aForm.Width;
                pointWasOk = false;
            }
            if ((toPoint.Y + aForm.Height) > workingRectangle.Height)
            {
                toPoint.Y = workingRectangle.Height - aForm.Height;
                pointWasOk = false;
            }

            aForm.Location = toPoint;

            return pointWasOk;
        }
    }
}
