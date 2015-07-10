using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Plantronics.UC.SmartLock
{
    public partial class EnterUnlockKeyForm : Form
    {
        OptionsForm m_parent = null;

        public EnterUnlockKeyForm(OptionsForm parent)
        {
            InitializeComponent();

            m_parent = parent;
        }

        private void EnterUnlockKeyForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            if (m_parent != null)
            {
                m_parent.m_keyform = null;
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (m_parent != null)
            {
                m_parent.m_keyform = null;
            }
            Close();
        }

        // user has clicked Unlock...
        private void button1_Click(object sender, EventArgs e)
        {
            SubmitForm();
        }

        private void SubmitForm()
        {
            if (keyTextBox.Text.ToUpper() == "ONCE UPON A TIME IN THE WEST") // "LARGE MAGELLANIC CLOUD")  // "PARIS IN THE SPRINGTIME")
            {
                TimeoutSystem.UnlockDemo();
                MessageBox.Show("The SmartLockDW Software has been unlocked and will not expire!",
                    "Plantronics ScreenLockDW Unlocked!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                if (m_parent != null)
                    m_parent.Close(); // note will also close this window
                else
                    Close(); // close this
            }
            else
            {
                MessageBox.Show("Sorry, the key you have entered is not valid!",
                    "Plantronics ScreenLock", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            }
        }

        private void EnterUnlockKeyForm_Load(object sender, EventArgs e)
        {
            WindowPosition.PositionToCenter(this);
        }

        private void keyTextBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            // user presses enter, lets submit form
            if (e.KeyChar == (char)Keys.Return)
            {
                SubmitForm();
            }
        }

        private void keySurveyLinkLabel_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Process.Start("http://www.surveymonkey.com/s/smartlock");
        }
    }
}
