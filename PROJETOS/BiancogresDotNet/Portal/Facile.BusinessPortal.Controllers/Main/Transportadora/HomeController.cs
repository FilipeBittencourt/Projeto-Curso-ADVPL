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
using Facile.BusinessPortal.BusinessRules.DAO;
using Microsoft.EntityFrameworkCore;
using Facile.BusinessPortal.Library.Util;

namespace Facile.BusinessPortal.Controllers.Main.Transportadora
{
    [Authorize]
    [Area("Transportadora")]
    public class HomeController : BaseCommonController<Model.Transportadora>
    {
        public HomeController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        public override async Task<IActionResult> Index()
        {
            var modulo = AccessControl.SetCurrentModuloById(HttpContext, _context, 3);
            AccessControl.CriarMenusUsuario(HttpContext, _context, _userId, modulo);

            Usuario usuario = await UsuarioDAO.GetUsuarioAsync(_context, User);

            if (usuario != null)
            {

                
               
            }

            return View();
        }
    }
}
