using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using System.Linq;
using System;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.Library;
using System.Collections.Generic;
using System.Threading.Tasks;
using Facile.BusinessPortal.Library.Extensions;

namespace Facile.BusinessPortal.Controllers.Main.AdminEmpresa
{
    [Authorize]
    [Area("AdminEmpresa")]
    public class HomeController : CommonController<Usuario>
    {
        public HomeController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        public override async Task<IActionResult> Index()
        {
            var modulo = AccessControl.SetCurrentModuloById(HttpContext, _context, 5);
            AccessControl.CriarMenusUsuario(HttpContext, _context, _userId, modulo);

            return await Task.Run<ActionResult>(() =>
            {
                return RedirectToAction("Index", "Sacado", new { Area = "AdminEmpresa" });
            });
        }
    }
}
