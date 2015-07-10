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



            Console.WriteLine("Enter to quit.");

            // close mysql database
            m_database.Close();

            Console.ReadLine();
        }
    }
}
