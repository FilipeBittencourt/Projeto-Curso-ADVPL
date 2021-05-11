using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using System.Linq;
using System;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Extensions;
using Facile.BusinessPortal.ViewModels;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    public class OLD_HomeController : Controller
    {
        protected readonly FBContext _context;

        public OLD_HomeController(FBContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            //carregando usuario logado
            Usuario usuario;

            //Carregandodados e menus do usuario
            var user = User.FindFirstValue(ClaimTypes.NameIdentifier);

            AccessControl.CriarModulosUsuario(HttpContext, _context, user);
            var currModulo = HttpContext.Session.GetObject<ModuloUsuarioViewModel>("CurrentModuloViewModel");

            if (currModulo != null)
            {
                AccessControl.CriarMenusUsuario(HttpContext, _context, user, currModulo);

                if (_context.Usuario.Any(o => o.UserId == user))
                {
                    usuario = _context.Usuario.First(o => o.UserId == user);

                    int hora = 0;
                    int minuto = 0;

                    string last = (hora > 0 ? hora.ToString() + " horas " : "") + (minuto.ToString() + " minutos");

                    HttpContext.Session.SetString("CurrentUserName", usuario.Nome ?? user);
                    HttpContext.Session.SetString("LastLoginTime", last);

                    return RedirectToAction("Index", currModulo.URL, new { area = currModulo.Nome });
                }
            }

            return View();
        }


    }
}
