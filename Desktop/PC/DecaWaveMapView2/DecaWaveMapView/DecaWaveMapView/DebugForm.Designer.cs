namespace DecaWaveMapView
{
    partial class DebugForm
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
            this.txtOutput = new System.Windows.Forms.TextBox();
            this.ClearBtn = new System.Windows.Forms.Button();
            this.pauseResumeBtn = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.connectedStateLbl = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.serverIPLabel = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // txtOutput
            // 
            this.txtOutput.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.txtOutput.Location = new System.Drawing.Point(0, 78);
            this.txtOutput.Multiline = true;
            this.txtOutput.Name = "txtOutput";
            this.txtOutput.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtOutput.Size = new System.Drawing.Size(641, 531);
            this.txtOutput.TabIndex = 0;
            // 
            // ClearBtn
            // 
            this.ClearBtn.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.ClearBtn.Location = new System.Drawing.Point(554, 48);
            this.ClearBtn.Name = "ClearBtn";
            this.ClearBtn.Size = new System.Drawing.Size(75, 23);
            this.ClearBtn.TabIndex = 1;
            this.ClearBtn.Text = "Clear";
            this.ClearBtn.UseVisualStyleBackColor = true;
            this.ClearBtn.Click += new System.EventHandler(this.ClearBtn_Click);
            // 
            // pauseResumeBtn
            // 
            this.pauseResumeBtn.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.pauseResumeBtn.Location = new System.Drawing.Point(473, 48);
            this.pauseResumeBtn.Name = "pauseResumeBtn";
            this.pauseResumeBtn.Size = new System.Drawing.Size(75, 23);
            this.pauseResumeBtn.TabIndex = 3;
            this.pauseResumeBtn.Text = "Pause";
            this.pauseResumeBtn.UseVisualStyleBackColor = true;
            this.pauseResumeBtn.Click += new System.EventHandler(this.pauseResumeBtn_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(62, 13);
            this.label1.TabIndex = 4;
            this.label1.Text = "Connected:";
            // 
            // connectedStateLbl
            // 
            this.connectedStateLbl.AutoSize = true;
            this.connectedStateLbl.Location = new System.Drawing.Point(80, 9);
            this.connectedStateLbl.Name = "connectedStateLbl";
            this.connectedStateLbl.Size = new System.Drawing.Size(27, 13);
            this.connectedStateLbl.TabIndex = 5;
            this.connectedStateLbl.Text = "N/A";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(12, 32);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(54, 13);
            this.label2.TabIndex = 6;
            this.label2.Text = "Server IP:";
            // 
            // serverIPLabel
            // 
            this.serverIPLabel.AutoSize = true;
            this.serverIPLabel.Location = new System.Drawing.Point(80, 32);
            this.serverIPLabel.Name = "serverIPLabel";
            this.serverIPLabel.Size = new System.Drawing.Size(27, 13);
            this.serverIPLabel.TabIndex = 7;
            this.serverIPLabel.Text = "N/A";
            // 
            // DebugForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(641, 609);
            this.Controls.Add(this.serverIPLabel);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.connectedStateLbl);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.pauseResumeBtn);
            this.Controls.Add(this.ClearBtn);
            this.Controls.Add(this.txtOutput);
            this.MinimumSize = new System.Drawing.Size(657, 547);
            this.Name = "DebugForm";
            this.Text = "DebugForm";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.DebugForm_FormClosing_1);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox txtOutput;
        private System.Windows.Forms.Button ClearBtn;
        private System.Windows.Forms.Button pauseResumeBtn;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label connectedStateLbl;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label serverIPLabel;
    }
}