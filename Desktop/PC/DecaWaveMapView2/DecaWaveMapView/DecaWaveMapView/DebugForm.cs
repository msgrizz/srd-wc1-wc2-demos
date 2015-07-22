using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace DecaWaveMapView
{
    public partial class DebugForm : Form
    {
        private Game1 m_game;
        private bool m_stoplogging = false;

        delegate void SetTextCallback(string method, string text);
        delegate void SetLabelCallback(Label aLabel, string text);

        public DebugForm(Game1 theGame)
        {
            m_game = theGame;

            InitializeComponent();
        }

        public void AppendToOutputWindow(String method, String message)
        {
            if (m_stoplogging) return;
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (this.txtOutput.InvokeRequired)
            {
                try
                {
                    SetTextCallback d = new SetTextCallback(AppendToOutputWindow);
                    this.Invoke(d, new object[] { method, message });
                }
                catch (ObjectDisposedException)
                {
                    // oops, probably just window was disposing
                }
            }
            else
            {
                if (!m_stoplogging)
                {
                    try
                    {
                        this.txtOutput.AppendText(String.Format("{0}: {1}\r\n", method, message));
                        this.txtOutput.SelectionStart = txtOutput.Text.Length;
                        this.txtOutput.ScrollToCaret();
                    }
                    catch (ObjectDisposedException)
                    {
                        // oops, probably just window was disposing
                    }
                }
            }
        }


        public void SetServerIP(string ip)
        {
            SetLabel(serverIPLabel, ip);
        }

        public void SetConnectedState(bool connected)
        {
            SetLabel(connectedStateLbl,
                connected ? "Yes" : "N/A");
        }

        private void SetLabel(Label aLabel, String message)
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (this.txtOutput.InvokeRequired)
            {
                try
                {
                    SetLabelCallback d = new SetLabelCallback(SetLabel);
                    this.Invoke(d, new object[] { aLabel, message });
                }
                catch (ObjectDisposedException)
                {
                    // oops, probably just window was disposing
                }
            }
            else
            {
                try
                {
                    aLabel.Text = message;
                }
                catch (ObjectDisposedException)
                {
                    // oops, probably just window was disposing
                }
            }
        }

        internal void SetExitting(bool exitting)
        {
            m_stoplogging = exitting;
        }

        private void DebugForm_FormClosing_1(object sender, FormClosingEventArgs e)
        {
            if (!m_stoplogging)
                e.Cancel = true;
            m_game.Exit();
        }

        private void pauseResumeBtn_Click(object sender, EventArgs e)
        {
            m_stoplogging = !m_stoplogging;
            pauseResumeBtn.Text =
                m_stoplogging ? "Resume" : "Pause";
        }

        private void ClearBtn_Click(object sender, EventArgs e)
        {
            txtOutput.Clear();
        }
    }
}
