using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Facile.BusinessPortal.StageArea.SAConsole
{
    public class MyLogger
    {
        private readonly ILogger _logger;

        public MyLogger(ILogger<MyLogger> logger)
        {
            _logger = logger;
        }

        public void LogInformation(string message)
        {
            Console.WriteLine(message);
            _logger.LogInformation(message);
        }
    }
}
