namespace Plantronics.UC.SmartLock
{
    partial class LockMessageForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(LockMessageForm));
            this.btnCancel = new System.Windows.Forms.Button();
            this.ciTxtMessage = new System.Windows.Forms.RichTextBox();
            this.settingsButton = new System.Windows.Forms.Button();
            this.okbutton = new System.Windows.Forms.Button();
            this.bannerPicBox = new System.Windows.Forms.PictureBox();
            this.panel1 = new System.Windows.Forms.Panel();
            this.lockTxtMessage = new System.Windows.Forms.Label();
            this.rtxtMessage = new System.Windows.Forms.Label();
            this.txtCounter = new System.Windows.Forms.Label();
            this.lockScreenBtn = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.bannerPicBox)).BeginInit();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnCancel
            // 
            this.btnCancel.Location = new System.Drawing.Point(189, 177);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(2);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(100, 21);
            this.btnCancel.TabIndex = 0;
            this.btnCancel.Text = "Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // ciTxtMessage
            // 
            this.ciTxtMessage.BackColor = System.Drawing.Color.White;
            this.ciTxtMessage.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.ciTxtMessage.Font = new System.Drawing.Font("Arial", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ciTxtMessage.Location = new System.Drawing.Point(22, 52);
            this.ciTxtMessage.Margin = new System.Windows.Forms.Padding(2);
            this.ciTxtMessage.Name = "ciTxtMessage";
            this.ciTxtMessage.ReadOnly = true;
            this.ciTxtMessage.Size = new System.Drawing.Size(353, 16);
            this.ciTxtMessage.TabIndex = 1;
            this.ciTxtMessage.Text = "Your screen was locked because Plantronics Marauder";
            this.ciTxtMessage.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.ciTxtMessage_KeyPress);
            // 
            // settingsButton
            // 
            this.settingsButton.Location = new System.Drawing.Point(294, 177);
            this.settingsButton.Name = "settingsButton";
            this.settingsButton.Size = new System.Drawing.Size(100, 21);
            this.settingsButton.TabIndex = 4;
            this.settingsButton.Text = "Settings";
            this.settingsButton.UseVisualStyleBackColor = true;
            this.settingsButton.Visible = false;
            this.settingsButton.Click += new System.EventHandler(this.settingsButton_Click);
            // 
            // okbutton
            // 
            this.okbutton.Location = new System.Drawing.Point(188, 177);
            this.okbutton.Name = "okbutton";
            this.okbutton.Size = new System.Drawing.Size(100, 21);
            this.okbutton.TabIndex = 5;
            this.okbutton.Text = "OK";
            this.okbutton.UseVisualStyleBackColor = true;
            this.okbutton.Visible = false;
            this.okbutton.Click += new System.EventHandler(this.okbutton_Click);
            // 
            // bannerPicBox
            // 
            this.bannerPicBox.Image = global::Plantronics.UC.SmartLock.Properties.Resources.warning;
            this.bannerPicBox.Location = new System.Drawing.Point(0, 0);
            this.bannerPicBox.Name = "bannerPicBox";
            this.bannerPicBox.Size = new System.Drawing.Size(404, 40);
            this.bannerPicBox.TabIndex = 6;
            this.bannerPicBox.TabStop = false;
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.White;
            this.panel1.Controls.Add(this.lockTxtMessage);
            this.panel1.Controls.Add(this.rtxtMessage);
            this.panel1.Controls.Add(this.txtCounter);
            this.panel1.Location = new System.Drawing.Point(0, 40);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(404, 129);
            this.panel1.TabIndex = 7;
            // 
            // lockTxtMessage
            // 
            this.lockTxtMessage.AutoSize = true;
            this.lockTxtMessage.Location = new System.Drawing.Point(112, 28);
            this.lockTxtMessage.Name = "lockTxtMessage";
            this.lockTxtMessage.Size = new System.Drawing.Size(118, 13);
            this.lockTxtMessage.TabIndex = 2;
            this.lockTxtMessage.Text = "Your screen will lock in:";
            // 
            // rtxtMessage
            // 
            this.rtxtMessage.AutoSize = true;
            this.rtxtMessage.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rtxtMessage.Location = new System.Drawing.Point(21, 28);
            this.rtxtMessage.Name = "rtxtMessage";
            this.rtxtMessage.Size = new System.Drawing.Size(93, 13);
            this.rtxtMessage.TabIndex = 1;
            this.rtxtMessage.Text = "state detected.";
            // 
            // txtCounter
            // 
            this.txtCounter.AutoSize = true;
            this.txtCounter.Font = new System.Drawing.Font("Arial", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtCounter.Location = new System.Drawing.Point(135, 66);
            this.txtCounter.Name = "txtCounter";
            this.txtCounter.Size = new System.Drawing.Size(139, 27);
            this.txtCounter.TabIndex = 0;
            this.txtCounter.Text = "15 Seconds";
            // 
            // lockScreenBtn
            // 
            this.lockScreenBtn.Location = new System.Drawing.Point(294, 177);
            this.lockScreenBtn.Name = "lockScreenBtn";
            this.lockScreenBtn.Size = new System.Drawing.Size(100, 21);
            this.lockScreenBtn.TabIndex = 8;
            this.lockScreenBtn.Text = "Lock Screen";
            this.lockScreenBtn.UseVisualStyleBackColor = true;
            this.lockScreenBtn.Click += new System.EventHandler(this.lockScreenBtn_Click);
            // 
            // LockMessageForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(404, 207);
            this.Controls.Add(this.lockScreenBtn);
            this.Controls.Add(this.bannerPicBox);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.okbutton);
            this.Controls.Add(this.settingsButton);
            this.Controls.Add(this.ciTxtMessage);
            this.Controls.Add(this.panel1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(2);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "LockMessageForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "SmartLockDW";
            this.TopMost = true;
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.LockMessageForm_FormClosed);
            ((System.ComponentModel.ISupportInitialize)(this.bannerPicBox)).EndInit();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.RichTextBox ciTxtMessage;
        public System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button settingsButton;
        private System.Windows.Forms.Button okbutton;
        private System.Windows.Forms.PictureBox bannerPicBox;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label rtxtMessage;
        private System.Windows.Forms.Button lockScreenBtn;
        private System.Windows.Forms.Label lockTxtMessage;
        public System.Windows.Forms.Label txtCounter;
    }
}
