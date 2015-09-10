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
                "pwd=house99;database=" + dbname + "; ";

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

        /// <summary>
        /// Queries the OAS MySQL database for an entity.
        /// </summary>
        /// <param name="tag_id">Pass the OpenRTLS tag id of the entity you want to find.</param>
        /// <returns>Returns the Entity or null if not found.</returns>
        public Entity QueryEntityByTagId(string tag_id)
        {
            Entity m_retval = null;
            MySqlDataReader rdr = null;

            try
            {
                string stm = "SELECT * FROM oas_database.users WHERE tag_id=\""+ tag_id + "\"";
                MySqlCommand cmd = new MySqlCommand(stm, m_myConnection);
                rdr = cmd.ExecuteReader();

                while (rdr.Read())
                {
                    if (m_retval == null)
                    {
                        m_retval = new Entity(
                            rdr.GetInt32(0),
                            (Entity.EntityType)Enum.Parse(typeof(Entity.EntityType), rdr.GetString(1), true),
                            rdr.GetString(2),
                            (Entity.EntityDepartment)Enum.Parse(typeof(Entity.EntityDepartment), rdr.GetString(3), true),
                            rdr.GetString(4),
                            rdr.GetString(5),
                            rdr.GetString(6),
                            rdr.GetString(7),
                            rdr.GetString(8)
                            );

                        break;
                    }
                    //Console.WriteLine(
                    //    String.Format(
                    //        "internal_id: {0}\r\n" +
                    //        "type: {1}\r\n" +
                    //        "name: {2}\r\n" +
                    //        "department: {3}\r\n" +
                    //        "id: {4}\r\n" +
                    //        "tag_id: {5}\r\n" +
                    //        "visibility_filter: {6}\r\n" +
                    //        "access_filter: {7}\r\n" +
                    //        "privilege_filter: {8}\r\n",
                    //        rdr.GetInt32(0),
                    //        rdr.GetString(1),
                    //        rdr.GetString(2),
                    //        rdr.GetString(3),
                    //        rdr.GetString(4),
                    //        rdr.GetString(5),
                    //        rdr.GetString(6),
                    //        rdr.GetString(7),
                    //        rdr.GetString(8)
                    //    ));
                }

                rdr.Close();
            }
            catch
            {
            }

            return m_retval;
        }

        /// <summary>
        /// This deletes the entity in the database.
        /// </summary>
        /// <param name="m_internal_id">The internal id of the entity to delete</param>
        /// <returns>A boolean indicating success or failure</returns>
        internal bool DeleteEntity(int internal_id)
        {
            bool m_retval = false;

            MySqlTransaction tr = null;

            try
            {
                tr = m_myConnection.BeginTransaction();

                MySqlCommand cmd = new MySqlCommand();
                cmd.Connection = m_myConnection;
                cmd.Transaction = tr;
                cmd.CommandText =
                    String.Format(
                    "DELETE FROM `oas_database`.`users`" +
                    " WHERE `internal_id` = {0};",
                    internal_id
                    );
                cmd.Prepare();

                cmd.ExecuteNonQuery();

                tr.Commit();

                m_retval = true;
            }
            catch (MySqlException ex)
            {
                try
                {
                    tr.Rollback();

                }
                catch (MySqlException ex1)
                {
                    Console.WriteLine("Error: {0}", ex1.ToString());
                }

                Console.WriteLine("Error: {0}", ex.ToString());

                m_retval = false;
            }

            return m_retval;
        }

        /// <summary>
        /// This updates the entity in the database.
        /// </summary>
        /// <param name="anEntity">The entity to update. Note: the internal id in myEntity must be correct in database.</param>
        /// <returns>A boolean indicating success or failure</returns>
        internal bool UpdateEntity(Entity anEntity)
        {
            bool m_retval = false;

            MySqlTransaction tr = null;

            try
            {
                tr = m_myConnection.BeginTransaction();

                MySqlCommand cmd = new MySqlCommand();
                cmd.Connection = m_myConnection;
                cmd.Transaction = tr;
                cmd.CommandText =
                    String.Format(
                    "UPDATE `oas_database`.`users`" +
                    "SET `type` = \"{0}\"," +
                    "`name` = \"{1}\"," +
                    "`department` = \"{2}\"," +
                    "`id` = \"{3}\"," +
                    "`tag_id` = \"{4}\"," +
                    "`visibility_filter` = \"{5}\"," +
                    "`access_filter` = \"{6}\"," +
                    "`privilege_filter` = \"{7}\"" +
                    " WHERE `internal_id` = {8};",
                    anEntity.m_type,
                    anEntity.m_name,
                    anEntity.m_department,
                    anEntity.m_id,
                    anEntity.m_tag_id,
                    anEntity.m_visibility_filter,
                    anEntity.m_access_filter,
                    anEntity.m_privilege_filter,
                    anEntity.m_internal_id
                    );
                cmd.Prepare();

                //cmd.Parameters.AddWithValue("@Name", "Trygve Gulbranssen");   // maybe we need later
                cmd.ExecuteNonQuery();

                tr.Commit();

                m_retval = true;
            }
            catch (MySqlException ex)
            {
                try
                {
                    tr.Rollback();

                }
                catch (MySqlException ex1)
                {
                    Console.WriteLine("Error: {0}", ex1.ToString());
                }

                Console.WriteLine("Error: {0}", ex.ToString());

                m_retval = false;
            }

            return m_retval;
        }

        /// <summary>
        /// Add an Entity to the OAS MySQL database.
        /// </summary>
        /// <param name="anEntity">The Entity you wish to add</param>
        /// <returns>A boolean indicating success or failure</returns>
        public bool AddEntity(Entity anEntity)
        {
            bool m_retval = false;

            try
            {
                MySqlCommand cmd = new MySqlCommand();
                cmd.Connection = m_myConnection;
                cmd.CommandText =
                    String.Format(
                    "INSERT INTO `oas_database`.`users`" +
                    "(`type`," +
                    "`name`," +
                    "`department`," +
                    "`id`," +
                    "`tag_id`," +
                    "`visibility_filter`," +
                    "`access_filter`," +
                    "`privilege_filter`)" +
                    "VALUES" +
                    "(\"{0}\"," +
                    "\"{1}\"," +
                    "\"{2}\"," +
                    "\"{3}\"," +
                    "\"{4}\"," +
                    "\"{5}\"," +
                    "\"{6}\"," +
                    "\"{7}\");",
                    anEntity.m_type,
                    anEntity.m_name,
                    anEntity.m_department,
                    anEntity.m_id,
                    anEntity.m_tag_id,
                    anEntity.m_visibility_filter,
                    anEntity.m_access_filter,
                    anEntity.m_privilege_filter
                    );
                cmd.Prepare();

                //cmd.Parameters.AddWithValue("@Name", "Trygve Gulbranssen");   // maybe we need later
                cmd.ExecuteNonQuery();

                m_retval = true;
            }
            catch(MySqlException ex)
            {
                Console.WriteLine("Error: {0}", ex.ToString());

                m_retval = false;
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
            m_name = name;
            m_department = department;
            m_id = id;
            m_tag_id = tag_id;
            m_visibility_filter = visibility_filter;
            m_access_filter = access_filter;
            m_privilege_filter = privilege_filter;
        }
    }
}
