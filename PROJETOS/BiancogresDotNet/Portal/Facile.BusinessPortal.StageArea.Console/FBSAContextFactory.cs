using Facile.BusinessPortal.StageArea.Model;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Facile.BusinessPortal.StageArea.SAConsole
{
    public class FBSAContextFactory: IDesignTimeDbContextFactory<FBSAContext>
    {        
        FBSAContext IDesignTimeDbContextFactory<FBSAContext>.CreateDbContext(string[] args)
        {
            var builder = new ConfigurationBuilder()
              .SetBasePath(Directory.GetCurrentDirectory())
              .AddJsonFile("AppSettings.json", optional: true, reloadOnChange: true);

            IConfigurationRoot configuration = builder.Build();

            var connStr = configuration.GetSection("ConnectionStrings").GetSection("DefaultConnection").Value;

            var optionsBuilder = new DbContextOptionsBuilder<FBSAContext>();
            optionsBuilder.UseLazyLoadingProxies().UseSqlServer(connStr);

            return new FBSAContext(optionsBuilder.Options);
        }
    }
}
