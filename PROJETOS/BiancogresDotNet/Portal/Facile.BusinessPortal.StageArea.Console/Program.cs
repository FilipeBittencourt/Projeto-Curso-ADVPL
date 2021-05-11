using Facile.BusinessPortal.StageArea.Interface.Cliente;
using Facile.BusinessPortal.StageArea.Model;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Serilog;
using System;
using System.IO;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.StageArea.SAConsole
{
    class Program
    {
        static void Main(string[] args)
        {

            if (!Directory.Exists(AppContext.BaseDirectory + "\\LOGS"))
            {
                Directory.CreateDirectory(AppContext.BaseDirectory + "\\LOGS");
            }

            Log.Logger = new LoggerConfiguration()
                  .WriteTo.Console()
                  .CreateLogger();

            //var serviceCollection = new ServiceCollection();
            //ConfigureServices(serviceCollection);
            //var serviceProvider = serviceCollection.BuildServiceProvider();
            //serviceProvider.GetService<MyLogger>();
            //var logger = serviceProvider.GetService<ILogger<MyLogger>>();

            var robo = new Robo(Log.Logger);
            robo.Iniciar();

            Console.WriteLine("Press \'q\' to quit.");
            while (Console.Read() != 'q') ;
        }

        //private static void ConfigureServices(IServiceCollection services)
        //{
        //    services.AddLogging(configure => configure.AddSerilog())
        //        .AddTransient<MyLogger>();
        //}
    }
}
