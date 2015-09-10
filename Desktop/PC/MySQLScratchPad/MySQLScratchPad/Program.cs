using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MySQLScratchPad
{
    class Program
    {
        private static MySQLConnector m_database;

        static void Main(string[] args)
        {
            Console.WriteLine("MySQL Scratch Pad / test and learn C# MySQL interface\r\n--\r\n");

            // instatiate database connector and connect to mysql database
            m_database = new MySQLConnector("OAS_Database");

            Console.WriteLine("About to try adding a new Entity (Sandra): ");
            Entity tmpEntity = new Entity(
                0,
                Entity.EntityType.Person,
                "Sandra Hayward",
                Entity.EntityDepartment.Engineering,
                "",
                "0xDECA393031102335",
                "",
                "",
                "");
            bool success = m_database.AddEntity(tmpEntity);
            Console.WriteLine("Adding Entity " + (success ? "SUCCESS" : "FAILED"));

            Console.WriteLine("About to look for Entity with tag id: 0xDECA393031102335");
            Entity myEntity = m_database.QueryEntityByTagId("0xDECA393031102335");
            int sandra_id = -1;

            if (myEntity != null)
            {
                sandra_id = myEntity.m_internal_id;
                Console.WriteLine("Found this entity: ");
                Console.WriteLine(
                    String.Format(
                        "internal_id: {0}\r\n" +
                        "type: {1}\r\n" +
                        "name: {2}\r\n" +
                        "department: {3}\r\n" +
                        "id: {4}\r\n" +
                        "tag_id: {5}\r\n" +
                        "visibility_filter: {6}\r\n" +
                        "access_filter: {7}\r\n" +
                        "privilege_filter: {8}\r\n",
                        myEntity.m_internal_id,
                        myEntity.m_type,
                        myEntity.m_name,
                        myEntity.m_department,
                        myEntity.m_id,
                        myEntity.m_tag_id,
                        myEntity.m_visibility_filter,
                        myEntity.m_access_filter,
                        myEntity.m_privilege_filter
                    ));
            }

            Console.WriteLine("About to try adding a new Entity (Lewis): ");
            tmpEntity = new Entity(
                0,
                Entity.EntityType.Person,
                "Lewis Collins",
                Entity.EntityDepartment.Engineering,
                "",
                "0xDECA313033614013",
                "",
                "",
                "");
            success = m_database.AddEntity(tmpEntity);
            Console.WriteLine("Adding Entity " + (success ? "SUCCESS" : "FAILED"));

            Console.WriteLine("About to look for Entity with tag id: 0xDECA313033614013");
            myEntity = m_database.QueryEntityByTagId("0xDECA313033614013");

            if (myEntity != null)
            {
                Console.WriteLine("Found this entity: ");
                Console.WriteLine(
                    String.Format(
                        "internal_id: {0}\r\n" +
                        "type: {1}\r\n" +
                        "name: {2}\r\n" +
                        "department: {3}\r\n" +
                        "id: {4}\r\n" +
                        "tag_id: {5}\r\n" +
                        "visibility_filter: {6}\r\n" +
                        "access_filter: {7}\r\n" +
                        "privilege_filter: {8}\r\n",
                        myEntity.m_internal_id,
                        myEntity.m_type,
                        myEntity.m_name,
                        myEntity.m_department,
                        myEntity.m_id,
                        myEntity.m_tag_id,
                        myEntity.m_visibility_filter,
                        myEntity.m_access_filter,
                        myEntity.m_privilege_filter
                    ));
            }

            Console.WriteLine("About to update Entity with tag id: 0xDECA313033614013");
            myEntity.m_name = "Lewis Collins (Updated 1)";
            success = m_database.UpdateEntity(myEntity);
            Console.WriteLine("Updating Entity " + (success ? "SUCCESS" : "FAILED"));

            Console.WriteLine("About to look for Entity with tag id: 0xDECA313033614013");
            myEntity = m_database.QueryEntityByTagId("0xDECA313033614013");

            if (myEntity != null)
            {
                Console.WriteLine("Found this entity: ");
                Console.WriteLine(
                    String.Format(
                        "internal_id: {0}\r\n" +
                        "type: {1}\r\n" +
                        "name: {2}\r\n" +
                        "department: {3}\r\n" +
                        "id: {4}\r\n" +
                        "tag_id: {5}\r\n" +
                        "visibility_filter: {6}\r\n" +
                        "access_filter: {7}\r\n" +
                        "privilege_filter: {8}\r\n",
                        myEntity.m_internal_id,
                        myEntity.m_type,
                        myEntity.m_name,
                        myEntity.m_department,
                        myEntity.m_id,
                        myEntity.m_tag_id,
                        myEntity.m_visibility_filter,
                        myEntity.m_access_filter,
                        myEntity.m_privilege_filter
                    ));
            }

            Console.WriteLine("Enter to test delete entity> ");
            Console.ReadLine();

            Console.WriteLine("About to delete Entity with internal id: " + myEntity.m_internal_id);
            success = m_database.DeleteEntity(myEntity.m_internal_id);
            Console.WriteLine("Deleting Entity " + (success ? "SUCCESS" : "FAILED"));

            Console.WriteLine("About to delete Entity with internal id:" + sandra_id);
            success = m_database.DeleteEntity(sandra_id);
            Console.WriteLine("Deleting Entity " + (success ? "SUCCESS" : "FAILED"));

            Console.WriteLine("Enter to quit.");

            // close mysql database
            m_database.Close();

            Console.ReadLine();
        }
    }
}
