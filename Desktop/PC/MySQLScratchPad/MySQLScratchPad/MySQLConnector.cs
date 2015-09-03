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

        ~MySQLConnector()
        {
            Close();
        }

        internal void Close()
        {
            if (m_myConnection != null)
            {
                m_myConnection.Close();
                m_myConnection = null;
            }
        }

        static Entity QueryEntityByTagId(string tag_id)
        {
            Entity m_retval = null;

            try
            {

            }

            return m_retval;
        }
    }

    class Entity
    {
        public int m_internal_id;
        public enum EntityType
        {
            Asset,
            Person
        }
        public EntityType m_type;
        public string m_name;
        public enum EntityDepartment
        {
            Engineering,
            Sales,
            Marketing
        }
        public EntityDepartment m_department;
        public string m_id, m_tag_id,
            m_visibility_filter,
            m_access_filter,
            m_privilege_filter;

        public Entity()
        {
        }

        public Entity(int internal_id, EntityType type, string name, EntityDepartment department,
            string id, string tag_id, string visibility_filter, string access_filter, string privilege_filter)
        {
            m_internal_id = internal_id;
            m_type = type;
            //m_
        }
    }
}
