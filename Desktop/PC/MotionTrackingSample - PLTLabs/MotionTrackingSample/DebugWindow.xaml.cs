using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace HeadTrackingDiagnostics
{
    /// <summary>
    /// Interaction logic for DebugWindow.xaml
    /// </summary>
    public partial class DebugWindow : Window
    {
        private MainWindow m_mainwin;
        public DebugWindow(MainWindow mainwin)
        {
            InitializeComponent();

            m_mainwin = mainwin;
        }

        internal void DebugPrint(string methodname, string str)
        {
            try
            {
                logtextbox.Dispatcher.Invoke(new Action(delegate()
                {
                    AppendLog(methodname, str);
                }));
            }
            catch (Exception) { }
        }

        private void AppendLog(string methodname, string str)
        {
            string datetime = DateTime.Now.ToString("HH:mm:ss.fff");
            logtextbox.AppendText((String.Format("{0}: {1}(): {2}\r\n", datetime, methodname, str)));
            logtextbox.ScrollToEnd();
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            m_mainwin.DisableDebugging();
        }        
    }
}
