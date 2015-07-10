namespace Plantronics.UC.SmartLock
{
    partial class ScreenLockerForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
                if (trayIcon!=null) trayIcon.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ScreenLockerForm));
            this.notifyIconMobileCall = new System.Windows.Forms.NotifyIcon(this.components);
            this.SuspendLayout();
            // 
            // ScreenLockerForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(190, 148);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(2);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "ScreenLockerForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "SmartLockDW";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.MobileCallForm_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.MobileCallForm_FormClosed);
            this.Load += new System.EventHandler(this.ScreenLockerForm_Load);
            this.VisibleChanged += new System.EventHandler(this.ScreenLockerForm_VisibleChanged);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.NotifyIcon notifyIconMobileCall;
    }
}

