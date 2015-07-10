namespace Plantronics.UC.SmartLock
{
    partial class OptionsForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(OptionsForm));
            this.tabSmartLockDW = new System.Windows.Forms.TabControl();
            this.tabLockerPage = new System.Windows.Forms.TabPage();
            this.TestLockBtn = new System.Windows.Forms.Button();
            this.cmbxLockAction = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.ckbxLockOnOutsideGeofence = new System.Windows.Forms.CheckBox();
            this.pictureBox2 = new System.Windows.Forms.PictureBox();
            this.label6 = new System.Windows.Forms.Label();
            this.cmbxDelay = new System.Windows.Forms.ComboBox();
            this.label3 = new System.Windows.Forms.Label();
            this.tabProx = new System.Windows.Forms.TabPage();
            this.tabMisc = new System.Windows.Forms.TabPage();
            this.suppressLockReasonsChkBox = new System.Windows.Forms.CheckBox();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.testAudioBtn = new System.Windows.Forms.Button();
            this.audioVolumeTrackBar = new System.Windows.Forms.TrackBar();
            this.AudioDevicesComboBox = new System.Windows.Forms.ComboBox();
            this.label16 = new System.Windows.Forms.Label();
            this.label15 = new System.Windows.Forms.Label();
            this.useVoicePromptsChk = new System.Windows.Forms.CheckBox();
            this.pictureBox3 = new System.Windows.Forms.PictureBox();
            this.showToastCheckBox = new System.Windows.Forms.CheckBox();
            this.startWithWinCheckBox = new System.Windows.Forms.CheckBox();
            this.label8 = new System.Windows.Forms.Label();
            this.debugCheckBox = new System.Windows.Forms.CheckBox();
            this.tabHelp = new System.Windows.Forms.TabPage();
            this.pictureBox4 = new System.Windows.Forms.PictureBox();
            this.UnlockButton = new System.Windows.Forms.Button();
            this.expireDaysLabel = new System.Windows.Forms.Label();
            this.label13 = new System.Windows.Forms.Label();
            this.label11 = new System.Windows.Forms.Label();
            this.fileLabel = new System.Windows.Forms.Label();
            this.assemblyLabel = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label12 = new System.Windows.Forms.Label();
            this.DeviceLabel = new System.Windows.Forms.Label();
            this.label10 = new System.Windows.Forms.Label();
            this.label14 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.tabAdmin = new System.Windows.Forms.TabPage();
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.serverConnectionStatusLbl = new System.Windows.Forms.Label();
            this.tabSmartLockDW.SuspendLayout();
            this.tabLockerPage.SuspendLayout();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox2)).BeginInit();
            this.tabMisc.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.audioVolumeTrackBar)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox3)).BeginInit();
            this.tabHelp.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox4)).BeginInit();
            this.SuspendLayout();
            // 
            // tabSmartLockDW
            // 
            this.tabSmartLockDW.Controls.Add(this.tabLockerPage);
            this.tabSmartLockDW.Controls.Add(this.tabProx);
            this.tabSmartLockDW.Controls.Add(this.tabMisc);
            this.tabSmartLockDW.Controls.Add(this.tabHelp);
            this.tabSmartLockDW.Controls.Add(this.tabAdmin);
            this.tabSmartLockDW.Location = new System.Drawing.Point(5, 8);
            this.tabSmartLockDW.Margin = new System.Windows.Forms.Padding(2);
            this.tabSmartLockDW.Name = "tabSmartLockDW";
            this.tabSmartLockDW.SelectedIndex = 0;
            this.tabSmartLockDW.Size = new System.Drawing.Size(401, 330);
            this.tabSmartLockDW.TabIndex = 0;
            // 
            // tabLockerPage
            // 
            this.tabLockerPage.Controls.Add(this.TestLockBtn);
            this.tabLockerPage.Controls.Add(this.cmbxLockAction);
            this.tabLockerPage.Controls.Add(this.label4);
            this.tabLockerPage.Controls.Add(this.groupBox1);
            this.tabLockerPage.Location = new System.Drawing.Point(4, 22);
            this.tabLockerPage.Margin = new System.Windows.Forms.Padding(2);
            this.tabLockerPage.Name = "tabLockerPage";
            this.tabLockerPage.Padding = new System.Windows.Forms.Padding(2);
            this.tabLockerPage.Size = new System.Drawing.Size(393, 304);
            this.tabLockerPage.TabIndex = 1;
            this.tabLockerPage.Text = "Screen Locker";
            this.tabLockerPage.UseVisualStyleBackColor = true;
            // 
            // TestLockBtn
            // 
            this.TestLockBtn.Location = new System.Drawing.Point(144, 228);
            this.TestLockBtn.Name = "TestLockBtn";
            this.TestLockBtn.Size = new System.Drawing.Size(42, 23);
            this.TestLockBtn.TabIndex = 14;
            this.TestLockBtn.Text = "Test";
            this.TestLockBtn.UseVisualStyleBackColor = true;
            this.TestLockBtn.Click += new System.EventHandler(this.TestLockBtn_Click);
            // 
            // cmbxLockAction
            // 
            this.cmbxLockAction.FormattingEnabled = true;
            this.cmbxLockAction.Items.AddRange(new object[] {
            "No Action",
            "Screen Saver",
            "Screen Lock ",
            "PC Sleep",
            "PC Hibernate"});
            this.cmbxLockAction.Location = new System.Drawing.Point(14, 230);
            this.cmbxLockAction.Margin = new System.Windows.Forms.Padding(2);
            this.cmbxLockAction.Name = "cmbxLockAction";
            this.cmbxLockAction.Size = new System.Drawing.Size(125, 21);
            this.cmbxLockAction.TabIndex = 10;
            this.cmbxLockAction.SelectedIndexChanged += new System.EventHandler(this.cmbxLockAction_SelectedIndexChanged);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(15, 212);
            this.label4.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(78, 13);
            this.label4.TabIndex = 9;
            this.label4.Text = "Lock action:";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.ckbxLockOnOutsideGeofence);
            this.groupBox1.Controls.Add(this.pictureBox2);
            this.groupBox1.Controls.Add(this.label6);
            this.groupBox1.Controls.Add(this.cmbxDelay);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.groupBox1.Location = new System.Drawing.Point(12, 16);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(371, 186);
            this.groupBox1.TabIndex = 13;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Screen is locked when:";
            // 
            // ckbxLockOnOutsideGeofence
            // 
            this.ckbxLockOnOutsideGeofence.AutoSize = true;
            this.ckbxLockOnOutsideGeofence.Checked = true;
            this.ckbxLockOnOutsideGeofence.CheckState = System.Windows.Forms.CheckState.Checked;
            this.ckbxLockOnOutsideGeofence.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ckbxLockOnOutsideGeofence.Location = new System.Drawing.Point(9, 20);
            this.ckbxLockOnOutsideGeofence.Name = "ckbxLockOnOutsideGeofence";
            this.ckbxLockOnOutsideGeofence.Size = new System.Drawing.Size(112, 17);
            this.ckbxLockOnOutsideGeofence.TabIndex = 12;
            this.ckbxLockOnOutsideGeofence.Text = "Outside Geofence";
            this.ckbxLockOnOutsideGeofence.UseVisualStyleBackColor = true;
            this.ckbxLockOnOutsideGeofence.CheckedChanged += new System.EventHandler(this.ckbxLockOnDoff_CheckedChanged);
            // 
            // pictureBox2
            // 
            this.pictureBox2.Image = global::Plantronics.UC.SmartLock.Properties.Resources.smartlock124x94;
            this.pictureBox2.Location = new System.Drawing.Point(238, 21);
            this.pictureBox2.Name = "pictureBox2";
            this.pictureBox2.Size = new System.Drawing.Size(124, 94);
            this.pictureBox2.TabIndex = 4;
            this.pictureBox2.TabStop = false;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label6.Location = new System.Drawing.Point(237, 155);
            this.label6.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(49, 13);
            this.label6.TabIndex = 11;
            this.label6.Text = "Seconds";
            // 
            // cmbxDelay
            // 
            this.cmbxDelay.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cmbxDelay.FormattingEnabled = true;
            this.cmbxDelay.Items.AddRange(new object[] {
            "Immediate",
            "15",
            "30"});
            this.cmbxDelay.Location = new System.Drawing.Point(137, 152);
            this.cmbxDelay.Margin = new System.Windows.Forms.Padding(2);
            this.cmbxDelay.Name = "cmbxDelay";
            this.cmbxDelay.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.cmbxDelay.Size = new System.Drawing.Size(96, 21);
            this.cmbxDelay.TabIndex = 8;
            this.cmbxDelay.SelectedIndexChanged += new System.EventHandler(this.cmbxDelay_SelectedIndexChanged);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(8, 155);
            this.label3.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(130, 13);
            this.label3.TabIndex = 7;
            this.label3.Text = "Take off/dock lock delay:";
            // 
            // tabProx
            // 
            this.tabProx.Location = new System.Drawing.Point(4, 22);
            this.tabProx.Name = "tabProx";
            this.tabProx.Padding = new System.Windows.Forms.Padding(3);
            this.tabProx.Size = new System.Drawing.Size(393, 304);
            this.tabProx.TabIndex = 4;
            this.tabProx.Text = "Marauder Map";
            this.tabProx.UseVisualStyleBackColor = true;
            // 
            // tabMisc
            // 
            this.tabMisc.Controls.Add(this.serverConnectionStatusLbl);
            this.tabMisc.Controls.Add(this.suppressLockReasonsChkBox);
            this.tabMisc.Controls.Add(this.pictureBox1);
            this.tabMisc.Controls.Add(this.testAudioBtn);
            this.tabMisc.Controls.Add(this.audioVolumeTrackBar);
            this.tabMisc.Controls.Add(this.AudioDevicesComboBox);
            this.tabMisc.Controls.Add(this.label1);
            this.tabMisc.Controls.Add(this.label16);
            this.tabMisc.Controls.Add(this.label15);
            this.tabMisc.Controls.Add(this.useVoicePromptsChk);
            this.tabMisc.Controls.Add(this.pictureBox3);
            this.tabMisc.Controls.Add(this.showToastCheckBox);
            this.tabMisc.Controls.Add(this.startWithWinCheckBox);
            this.tabMisc.Controls.Add(this.label8);
            this.tabMisc.Controls.Add(this.debugCheckBox);
            this.tabMisc.Location = new System.Drawing.Point(4, 22);
            this.tabMisc.Name = "tabMisc";
            this.tabMisc.Padding = new System.Windows.Forms.Padding(3);
            this.tabMisc.Size = new System.Drawing.Size(393, 304);
            this.tabMisc.TabIndex = 2;
            this.tabMisc.Text = "Misc";
            this.tabMisc.UseVisualStyleBackColor = true;
            // 
            // suppressLockReasonsChkBox
            // 
            this.suppressLockReasonsChkBox.AutoSize = true;
            this.suppressLockReasonsChkBox.Location = new System.Drawing.Point(18, 168);
            this.suppressLockReasonsChkBox.Name = "suppressLockReasonsChkBox";
            this.suppressLockReasonsChkBox.Size = new System.Drawing.Size(174, 17);
            this.suppressLockReasonsChkBox.TabIndex = 35;
            this.suppressLockReasonsChkBox.Text = "Suppress Lock Reason Display";
            this.suppressLockReasonsChkBox.UseVisualStyleBackColor = true;
            this.suppressLockReasonsChkBox.CheckedChanged += new System.EventHandler(this.suppressLockReasonsChkBox_CheckedChanged);
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = global::Plantronics.UC.SmartLock.Properties.Resources.volumescale2;
            this.pictureBox1.Location = new System.Drawing.Point(276, 190);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(70, 13);
            this.pictureBox1.TabIndex = 34;
            this.pictureBox1.TabStop = false;
            // 
            // testAudioBtn
            // 
            this.testAudioBtn.Location = new System.Drawing.Point(321, 219);
            this.testAudioBtn.Name = "testAudioBtn";
            this.testAudioBtn.Size = new System.Drawing.Size(44, 23);
            this.testAudioBtn.TabIndex = 32;
            this.testAudioBtn.Text = "Test";
            this.testAudioBtn.UseVisualStyleBackColor = true;
            this.testAudioBtn.Click += new System.EventHandler(this.testAudioBtn_Click);
            // 
            // audioVolumeTrackBar
            // 
            this.audioVolumeTrackBar.BackColor = System.Drawing.Color.White;
            this.audioVolumeTrackBar.Location = new System.Drawing.Point(266, 168);
            this.audioVolumeTrackBar.Maximum = 20;
            this.audioVolumeTrackBar.Name = "audioVolumeTrackBar";
            this.audioVolumeTrackBar.Size = new System.Drawing.Size(90, 45);
            this.audioVolumeTrackBar.TabIndex = 31;
            this.audioVolumeTrackBar.Value = 20;
            this.audioVolumeTrackBar.Scroll += new System.EventHandler(this.audioVolumeTrackBar_Scroll);
            // 
            // AudioDevicesComboBox
            // 
            this.AudioDevicesComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.AudioDevicesComboBox.FormattingEnabled = true;
            this.AudioDevicesComboBox.Location = new System.Drawing.Point(18, 262);
            this.AudioDevicesComboBox.Name = "AudioDevicesComboBox";
            this.AudioDevicesComboBox.Size = new System.Drawing.Size(349, 21);
            this.AudioDevicesComboBox.TabIndex = 30;
            this.AudioDevicesComboBox.SelectedIndexChanged += new System.EventHandler(this.AudioDevicesComboBox_SelectedIndexChanged);
            // 
            // label16
            // 
            this.label16.AutoSize = true;
            this.label16.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label16.Location = new System.Drawing.Point(247, 152);
            this.label16.Name = "label16";
            this.label16.Size = new System.Drawing.Size(129, 13);
            this.label16.TabIndex = 28;
            this.label16.Text = "Voice prompt volume:";
            // 
            // label15
            // 
            this.label15.AutoSize = true;
            this.label15.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label15.Location = new System.Drawing.Point(15, 246);
            this.label15.Name = "label15";
            this.label15.Size = new System.Drawing.Size(197, 13);
            this.label15.TabIndex = 29;
            this.label15.Text = "Audio Device (for voice prompts):";
            // 
            // useVoicePromptsChk
            // 
            this.useVoicePromptsChk.AutoSize = true;
            this.useVoicePromptsChk.Location = new System.Drawing.Point(18, 137);
            this.useVoicePromptsChk.Name = "useVoicePromptsChk";
            this.useVoicePromptsChk.Size = new System.Drawing.Size(116, 17);
            this.useVoicePromptsChk.TabIndex = 6;
            this.useVoicePromptsChk.Text = "Use Voice Prompts";
            this.useVoicePromptsChk.UseVisualStyleBackColor = true;
            this.useVoicePromptsChk.CheckedChanged += new System.EventHandler(this.useVoicePromptsChk_CheckedChanged);
            // 
            // pictureBox3
            // 
            this.pictureBox3.Image = global::Plantronics.UC.SmartLock.Properties.Resources.smartlock124x94;
            this.pictureBox3.Location = new System.Drawing.Point(250, 37);
            this.pictureBox3.Name = "pictureBox3";
            this.pictureBox3.Size = new System.Drawing.Size(124, 94);
            this.pictureBox3.TabIndex = 5;
            this.pictureBox3.TabStop = false;
            // 
            // showToastCheckBox
            // 
            this.showToastCheckBox.AutoSize = true;
            this.showToastCheckBox.Location = new System.Drawing.Point(18, 104);
            this.showToastCheckBox.Name = "showToastCheckBox";
            this.showToastCheckBox.Size = new System.Drawing.Size(157, 17);
            this.showToastCheckBox.TabIndex = 3;
            this.showToastCheckBox.Text = "Show Toast Popup on Start";
            this.showToastCheckBox.UseVisualStyleBackColor = true;
            this.showToastCheckBox.CheckedChanged += new System.EventHandler(this.showToastCheckBox_CheckedChanged);
            // 
            // startWithWinCheckBox
            // 
            this.startWithWinCheckBox.AutoSize = true;
            this.startWithWinCheckBox.Location = new System.Drawing.Point(18, 71);
            this.startWithWinCheckBox.Name = "startWithWinCheckBox";
            this.startWithWinCheckBox.Size = new System.Drawing.Size(117, 17);
            this.startWithWinCheckBox.TabIndex = 2;
            this.startWithWinCheckBox.Text = "Start with Windows";
            this.startWithWinCheckBox.UseVisualStyleBackColor = true;
            this.startWithWinCheckBox.CheckedChanged += new System.EventHandler(this.startWithWinCheckBox_CheckedChanged);
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label8.Location = new System.Drawing.Point(15, 17);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(137, 13);
            this.label8.TabIndex = 1;
            this.label8.Text = "Miscellaneous Settings";
            // 
            // debugCheckBox
            // 
            this.debugCheckBox.AutoSize = true;
            this.debugCheckBox.Location = new System.Drawing.Point(18, 38);
            this.debugCheckBox.Name = "debugCheckBox";
            this.debugCheckBox.Size = new System.Drawing.Size(88, 17);
            this.debugCheckBox.TabIndex = 0;
            this.debugCheckBox.Text = "Debug Mode";
            this.debugCheckBox.UseVisualStyleBackColor = true;
            this.debugCheckBox.CheckedChanged += new System.EventHandler(this.debugCheckBox_CheckedChanged);
            // 
            // tabHelp
            // 
            this.tabHelp.Controls.Add(this.pictureBox4);
            this.tabHelp.Controls.Add(this.UnlockButton);
            this.tabHelp.Controls.Add(this.expireDaysLabel);
            this.tabHelp.Controls.Add(this.label13);
            this.tabHelp.Controls.Add(this.label11);
            this.tabHelp.Controls.Add(this.fileLabel);
            this.tabHelp.Controls.Add(this.assemblyLabel);
            this.tabHelp.Controls.Add(this.label2);
            this.tabHelp.Controls.Add(this.label12);
            this.tabHelp.Controls.Add(this.DeviceLabel);
            this.tabHelp.Controls.Add(this.label10);
            this.tabHelp.Controls.Add(this.label14);
            this.tabHelp.Controls.Add(this.label9);
            this.tabHelp.Location = new System.Drawing.Point(4, 22);
            this.tabHelp.Name = "tabHelp";
            this.tabHelp.Padding = new System.Windows.Forms.Padding(3);
            this.tabHelp.Size = new System.Drawing.Size(393, 304);
            this.tabHelp.TabIndex = 3;
            this.tabHelp.Text = "Help";
            this.tabHelp.UseVisualStyleBackColor = true;
            // 
            // pictureBox4
            // 
            this.pictureBox4.Image = global::Plantronics.UC.SmartLock.Properties.Resources.smartlock124x94;
            this.pictureBox4.Location = new System.Drawing.Point(250, 37);
            this.pictureBox4.Name = "pictureBox4";
            this.pictureBox4.Size = new System.Drawing.Size(124, 94);
            this.pictureBox4.TabIndex = 20;
            this.pictureBox4.TabStop = false;
            // 
            // UnlockButton
            // 
            this.UnlockButton.Location = new System.Drawing.Point(324, 270);
            this.UnlockButton.Name = "UnlockButton";
            this.UnlockButton.Size = new System.Drawing.Size(63, 21);
            this.UnlockButton.TabIndex = 19;
            this.UnlockButton.Text = "Unlock...";
            this.UnlockButton.UseVisualStyleBackColor = true;
            this.UnlockButton.Click += new System.EventHandler(this.UnlockButton_Click);
            // 
            // expireDaysLabel
            // 
            this.expireDaysLabel.AutoSize = true;
            this.expireDaysLabel.Location = new System.Drawing.Point(247, 273);
            this.expireDaysLabel.Name = "expireDaysLabel";
            this.expireDaysLabel.Size = new System.Drawing.Size(44, 13);
            this.expireDaysLabel.TabIndex = 18;
            this.expireDaysLabel.Text = "30 days";
            // 
            // label13
            // 
            this.label13.AutoSize = true;
            this.label13.Location = new System.Drawing.Point(16, 141);
            this.label13.Name = "label13";
            this.label13.Size = new System.Drawing.Size(77, 39);
            this.label13.TabIndex = 16;
            this.label13.Text = "Windows XP\r\nWindows Vista\r\nWindows 7";
            // 
            // label11
            // 
            this.label11.AutoSize = true;
            this.label11.Location = new System.Drawing.Point(16, 39);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(189, 65);
            this.label11.TabIndex = 16;
            this.label11.Text = "Voyager Pro UC v2\r\nVoyager Legend UC\r\nSavi 700 Series\r\nSavi 400 Series\r\nBlackwire" +
    " C710 / C720 / C510 / C520";
            // 
            // fileLabel
            // 
            this.fileLabel.AutoSize = true;
            this.fileLabel.Location = new System.Drawing.Point(247, 242);
            this.fileLabel.Name = "fileLabel";
            this.fileLabel.Size = new System.Drawing.Size(24, 13);
            this.fileLabel.TabIndex = 15;
            this.fileLabel.Text = "n/a";
            // 
            // assemblyLabel
            // 
            this.assemblyLabel.AutoSize = true;
            this.assemblyLabel.Location = new System.Drawing.Point(247, 221);
            this.assemblyLabel.Name = "assemblyLabel";
            this.assemblyLabel.Size = new System.Drawing.Size(24, 13);
            this.assemblyLabel.TabIndex = 14;
            this.assemblyLabel.Text = "n/a";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(247, 198);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(117, 13);
            this.label2.TabIndex = 13;
            this.label2.Text = "SmartLock Version:";
            // 
            // label12
            // 
            this.label12.AutoSize = true;
            this.label12.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label12.Location = new System.Drawing.Point(16, 119);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(179, 13);
            this.label12.TabIndex = 11;
            this.label12.Text = "Supported Software Platforms:";
            // 
            // DeviceLabel
            // 
            this.DeviceLabel.AutoSize = true;
            this.DeviceLabel.Location = new System.Drawing.Point(16, 221);
            this.DeviceLabel.Name = "DeviceLabel";
            this.DeviceLabel.Size = new System.Drawing.Size(24, 13);
            this.DeviceLabel.TabIndex = 12;
            this.DeviceLabel.Text = "n/a";
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label10.Location = new System.Drawing.Point(16, 17);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(186, 13);
            this.label10.TabIndex = 11;
            this.label10.Text = "Supported Plantronics Devices:";
            // 
            // label14
            // 
            this.label14.AutoSize = true;
            this.label14.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label14.Location = new System.Drawing.Point(16, 273);
            this.label14.Name = "label14";
            this.label14.Size = new System.Drawing.Size(199, 13);
            this.label14.TabIndex = 11;
            this.label14.Text = "This Demo Software will expire in:";
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label9.Location = new System.Drawing.Point(16, 198);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(183, 13);
            this.label9.TabIndex = 11;
            this.label9.Text = "Connected Plantronics Device:";
            // 
            // tabAdmin
            // 
            this.tabAdmin.Location = new System.Drawing.Point(4, 22);
            this.tabAdmin.Name = "tabAdmin";
            this.tabAdmin.Padding = new System.Windows.Forms.Padding(3);
            this.tabAdmin.Size = new System.Drawing.Size(393, 304);
            this.tabAdmin.TabIndex = 5;
            this.tabAdmin.Text = "Admin";
            this.tabAdmin.UseVisualStyleBackColor = true;
            // 
            // btnOK
            // 
            this.btnOK.Location = new System.Drawing.Point(254, 342);
            this.btnOK.Margin = new System.Windows.Forms.Padding(2);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(73, 24);
            this.btnOK.TabIndex = 1;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Location = new System.Drawing.Point(333, 342);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(2);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(73, 24);
            this.btnCancel.TabIndex = 2;
            this.btnCancel.Text = "Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(15, 200);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(156, 13);
            this.label1.TabIndex = 28;
            this.label1.Text = "Server Connection Status:";
            // 
            // serverConnectionStatusLbl
            // 
            this.serverConnectionStatusLbl.AutoSize = true;
            this.serverConnectionStatusLbl.Location = new System.Drawing.Point(15, 219);
            this.serverConnectionStatusLbl.Name = "serverConnectionStatusLbl";
            this.serverConnectionStatusLbl.Size = new System.Drawing.Size(27, 13);
            this.serverConnectionStatusLbl.TabIndex = 36;
            this.serverConnectionStatusLbl.Text = "N/A";
            // 
            // OptionsForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(409, 371);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.tabSmartLockDW);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(2);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "OptionsForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Text = "SmartLockDW Options";
            this.TopMost = true;
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.OptionsForm_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.OptionsForm_FormClosed);
            this.Load += new System.EventHandler(this.OptionsForm_Load);
            this.tabSmartLockDW.ResumeLayout(false);
            this.tabLockerPage.ResumeLayout(false);
            this.tabLockerPage.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox2)).EndInit();
            this.tabMisc.ResumeLayout(false);
            this.tabMisc.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.audioVolumeTrackBar)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox3)).EndInit();
            this.tabHelp.ResumeLayout(false);
            this.tabHelp.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox4)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TabControl tabSmartLockDW;
        private System.Windows.Forms.TabPage tabLockerPage;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.ComboBox cmbxDelay;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox cmbxLockAction;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.CheckBox ckbxLockOnOutsideGeofence;
        private System.Windows.Forms.TabPage tabMisc;
        private System.Windows.Forms.Label label8;
        public System.Windows.Forms.CheckBox debugCheckBox;
        private System.Windows.Forms.CheckBox showToastCheckBox;
        private System.Windows.Forms.CheckBox startWithWinCheckBox;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.PictureBox pictureBox2;
        private System.Windows.Forms.PictureBox pictureBox3;
        private System.Windows.Forms.TabPage tabHelp;
        private System.Windows.Forms.Label label13;
        private System.Windows.Forms.Label label11;
        private System.Windows.Forms.Label fileLabel;
        private System.Windows.Forms.Label assemblyLabel;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label12;
        private System.Windows.Forms.Label DeviceLabel;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Label expireDaysLabel;
        private System.Windows.Forms.Label label14;
        private System.Windows.Forms.Button UnlockButton;
        private System.Windows.Forms.CheckBox useVoicePromptsChk;
        private System.Windows.Forms.PictureBox pictureBox4;
        private System.Windows.Forms.Button testAudioBtn;
        private System.Windows.Forms.TrackBar audioVolumeTrackBar;
        private System.Windows.Forms.ComboBox AudioDevicesComboBox;
        private System.Windows.Forms.Label label16;
        private System.Windows.Forms.Label label15;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.TabPage tabProx;
        private System.Windows.Forms.CheckBox suppressLockReasonsChkBox;
        private System.Windows.Forms.Button TestLockBtn;
        private System.Windows.Forms.TabPage tabAdmin;
        private System.Windows.Forms.Label serverConnectionStatusLbl;
        private System.Windows.Forms.Label label1;
    }
}
