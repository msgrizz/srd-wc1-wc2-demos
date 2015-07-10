using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MySQLScratchPad
{
    class MySQLConnector
    {
        MySqlConnection m_myConnection;
        string m_myConnectionString;

        public MySQLConnector(string dbname)
        {
            m_myConnectionString = "server=127.0.0.1;uid=root;" +
                "pwd=12345;database=" + dbname + "; ";

            try
            {
                m_myConnection = new MySql.Data.MySqlClient.MySqlConnection();
                m_myConnection.ConnectionString = m_myConnectionString;
                m_myConnection.Open();
            }
            catch (MySql.Data.MySqlClient.MySqlException ex)
            {
                throw new Exception("Failed to connect to database: " +
                    dbname, ex);
            }
        }

        internal void Close()
        {
            m_myConnection.Close();
        }
    }

    class User
    {
        public int m_idusers;
        public string m_username, m_password, m_pcname,
            m_tagid, m_text, m_appsettings;

        public User()
        {
        }

        public User(string idusers, string username, password,
            pcname, tagid, text, appsettings)
        {

        }
    }
}
