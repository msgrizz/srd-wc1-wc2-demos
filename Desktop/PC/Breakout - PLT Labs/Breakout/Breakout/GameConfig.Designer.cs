namespace Breakout
{
    partial class GameConfig
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
            this.label1 = new System.Windows.Forms.Label();
            this.resCombo = new System.Windows.Forms.ComboBox();
            this.checkBox1 = new System.Windows.Forms.CheckBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.extraHashtagsTextBox = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.extraHashtagsCheckbox = new System.Windows.Forms.CheckBox();
            this.tweetCheckBox = new System.Windows.Forms.CheckBox();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(14, 27);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(105, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Graphics Resolution:";
            // 
            // resCombo
            // 
            this.resCombo.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.resCombo.FormattingEnabled = true;
            this.resCombo.Location = new System.Drawing.Point(125, 24);
            this.resCombo.Name = "resCombo";
            this.resCombo.Size = new System.Drawing.Size(425, 21);
            this.resCombo.TabIndex = 1;
            this.resCombo.SelectedIndexChanged += new System.EventHandler(this.resCombo_SelectedIndexChanged);
            // 
            // checkBox1
            // 
            this.checkBox1.AutoSize = true;
            this.checkBox1.Location = new System.Drawing.Point(17, 53);
            this.checkBox1.Name = "checkBox1";
            this.checkBox1.Size = new System.Drawing.Size(85, 17);
            this.checkBox1.TabIndex = 2;
            this.checkBox1.Text = "Full Screen?";
            this.checkBox1.UseVisualStyleBackColor = true;
            this.checkBox1.CheckedChanged += new System.EventHandler(this.checkBox1_CheckedChanged);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Controls.Add(this.checkBox1);
            this.groupBox1.Controls.Add(this.resCombo);
            this.groupBox1.Location = new System.Drawing.Point(12, 12);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(628, 88);
            this.groupBox1.TabIndex = 3;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Graphics Settings";
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.extraHashtagsTextBox);
            this.groupBox2.Controls.Add(this.label2);
            this.groupBox2.Controls.Add(this.extraHashtagsCheckbox);
            this.groupBox2.Controls.Add(this.tweetCheckBox);
            this.groupBox2.Location = new System.Drawing.Point(12, 106);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(628, 101);
            this.groupBox2.TabIndex = 4;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Social Media Settings";
            // 
            // extraHashtagsTextBox
            // 
            this.extraHashtagsTextBox.Location = new System.Drawing.Point(107, 68);
            this.extraHashtagsTextBox.Name = "extraHashtagsTextBox";
            this.extraHashtagsTextBox.Size = new System.Drawing.Size(220, 20);
            this.extraHashtagsTextBox.TabIndex = 3;
            this.extraHashtagsTextBox.Text = "#CLEUR";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(14, 71);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(87, 13);
            this.label2.TabIndex = 2;
            this.label2.Text = "Extra #hashtags:";
            // 
            // extraHashtagsCheckbox
            // 
            this.extraHashtagsCheckbox.AutoSize = true;
            this.extraHashtagsCheckbox.Location = new System.Drawing.Point(17, 51);
            this.extraHashtagsCheckbox.Name = "extraHashtagsCheckbox";
            this.extraHashtagsCheckbox.Size = new System.Drawing.Size(146, 17);
            this.extraHashtagsCheckbox.TabIndex = 1;
            this.extraHashtagsCheckbox.Text = "Include extra #hashtags?";
            this.extraHashtagsCheckbox.UseVisualStyleBackColor = true;
            // 
            // tweetCheckBox
            // 
            this.tweetCheckBox.AutoSize = true;
            this.tweetCheckBox.Checked = true;
            this.tweetCheckBox.CheckState = System.Windows.Forms.CheckState.Checked;
            this.tweetCheckBox.Location = new System.Drawing.Point(17, 28);
            this.tweetCheckBox.Name = "tweetCheckBox";
            this.tweetCheckBox.Size = new System.Drawing.Size(241, 17);
            this.tweetCheckBox.TabIndex = 0;
            this.tweetCheckBox.Text = "Auto-Tweet New Highscores to @Pltciscolive";
            this.tweetCheckBox.UseVisualStyleBackColor = true;
            // 
            // GameConfig
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(655, 220);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Name = "GameConfig";
            this.Text = "Breakout Game Configuration";
            this.Activated += new System.EventHandler(this.GameConfig_Activated);
            this.Deactivate += new System.EventHandler(this.GameConfig_Deactivate);
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.GameConfig_FormClosing);
            this.MouseEnter += new System.EventHandler(this.GameConfig_MouseEnter);
            this.MouseLeave += new System.EventHandler(this.GameConfig_MouseLeave);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label label1;
        public System.Windows.Forms.ComboBox resCombo;
        public System.Windows.Forms.CheckBox checkBox1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.GroupBox groupBox2;
        public System.Windows.Forms.CheckBox tweetCheckBox;
        private System.Windows.Forms.Label label2;
        public System.Windows.Forms.CheckBox extraHashtagsCheckbox;
        public System.Windows.Forms.TextBox extraHashtagsTextBox;
    }
}