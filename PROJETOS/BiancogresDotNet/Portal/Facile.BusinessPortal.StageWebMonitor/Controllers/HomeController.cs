using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Facile.BusinessPortal.StageWebMonitor.Models;
using Facile.BusinessPortal.StageArea.Model;

namespace Facile.BusinessPortal.StageWebMonitor.Controllers
{
    public class HomeController : Controller
    {
        protected readonly FBSAContext _context;

        public HomeController(FBSAContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            var processos = _context.ProcessoEmpresa.ToList();
            return View(processos);
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
