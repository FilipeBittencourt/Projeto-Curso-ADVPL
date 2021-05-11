using Facile.BusinessPortal.Library.Util;
using System;

namespace ConsoleTest
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");


            string[] numbers = { "abc1234", "abccc", "1111", "11111", "654321", "123455", "321def123", "12abc", "fr4512" };

            foreach (var str in numbers)
            {
                Console.WriteLine(str);

                if (LibraryUtil.HasSequentialOrRepeating(str))
                    Console.WriteLine("match erro");
                else
                    Console.WriteLine("string ok");
            }
        }
    }
}
