using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Reflection;

namespace Plantronics.UC.SmartLock
{
    public partial class ToastPopup : Form
    {
        private Timer timer;
        private Timer killtimer;
        private int startPosX;
        private int startPosY;
        private int xvel;
        private int yvel;
        private int steps;
        private int curstep;

        private ScreenLockerForm theParent;

        public ToastPopup(string msg, ScreenLockerForm parent)
        {
            InitializeComponent();

            theParent = parent;

            label2.Text = msg;

            curstep = 0;
            steps = 0;

            // We want our window to be the top most
            TopMost = true;
            // Create and run timer for animation
            timer = new Timer();
            timer.Interval = 25;
            timer.Tick += timer_Tick;

            killtimer = new Timer();
            killtimer.Interval = 5000;
            killtimer.Tick += new EventHandler(killtimer_Tick);
        }

        void killtimer_Tick(object sender, EventArgs e)
        {
            killtimer.Stop();
            Close();
        }

        void timer_Tick(object sender, EventArgs e)
        {
            //Move window by its defined velocities
            startPosX += xvel;
            startPosY += yvel;
            //If window is fully visible stop the timer
            curstep += 1;
            if (curstep > steps)
            {
                timer.Stop();
                // animation is done
                // start kill timer to remove the message!
                killtimer.Start();
            }
            else
            {
                SetDesktopLocation(startPosX, startPosY);
            }
        }

        private void ToastPopup_Load(object sender, EventArgs e)
        {
            BringToFront();
            // Position relative to tray
            WindowPosition.PositionToTray(this);

            // Move out of screen in direction depending on taskbar position (bottom, top, left, right)
            // and set window velocities accordingly...
            TaskbarPosition tbloc = WinAPI.GetTaskBarPosition();
            switch (tbloc)
            {
                case TaskbarPosition.Bottom:
                    startPosX = this.Left;
                    startPosY = this.Bottom;
                    xvel = 0;
                    yvel = -5;
                    steps = this.Height / 5;
                    break;
                case TaskbarPosition.Top:
                    startPosX = this.Left;
                    startPosY = -this.Height;
                    xvel = 0;
                    yvel = 5;
                    steps = this.Height / 5;
                    break;
                case TaskbarPosition.Left:
                    startPosX = -this.Width;
                    startPosY = this.Top;
                    xvel = 10;
                    yvel = 0;
                    steps = this.Width / 10;
                    break;
                case TaskbarPosition.Right:
                    startPosX = this.Right;
                    startPosY = this.Top;
                    xvel = -10;
                    yvel = 0;
                    steps = this.Width / 10;
                    break;

            }
            SetDesktopLocation(startPosX, startPosY);
            // Begin animation
            timer.Start();
        }

        private void panel1_MouseClick(object sender, MouseEventArgs e)
        {
            // user has clicked toast, open options dialog...
            theParent.OpenOptionsDialog();
            Close();
        }

        private void label2_MouseClick(object sender, MouseEventArgs e)
        {
            // user has clicked toast, open options dialog...
            theParent.OpenOptionsDialog();
            Close();
        }

        private void ToastPopup_FormClosed(object sender, FormClosedEventArgs e)
        {
            theParent.DebugPrint(MethodInfo.GetCurrentMethod().Name, "INFO: User closed popup - stop timers.");
            timer.Stop();
            killtimer.Stop();
        }
    }
}
