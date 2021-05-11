using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using System.Linq;
using System;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.Library.Extensions;
using Facile.BusinessPortal.ViewModels;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        protected readonly FBContext _context;

        public HomeController(FBContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            /*var UsuarioGrupo = HttpContext.Session.GetObject<UsuarioGrupoViewModel>("UsuarioGrupo");
            if (UsuarioGrupo == null)
            {
                return RedirectToAction("Modulo");
            }*/

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

        public IActionResult Modulo()
        {
            var user = User.FindFirstValue(ClaimTypes.NameIdentifier);
            ViewBag.ListaTipoVeiculo = new List<UsuarioGrupo>();

            HttpContext.Session.SetObject("AllMenusUsuarioViewModel", new AllMenusUsuarioViewModel());
            HttpContext.Session.SetObject("AllModulosUsuarioViewModel", new AllModulosUsuarioViewModel());


            var usuario = _context.Usuario.FirstOrDefault(o => o.UserId == user);
            if (usuario != null)
            {
                var ListaUsuarioGrupo = _context.UsuarioGrupo.Include(x => x.GrupoUsuario).AsNoTracking().Where(x => x.UsuarioID == usuario.ID).ToList();
                if (ListaUsuarioGrupo.Count == 1)
                {
                    HttpContext.Session.SetObject("UsuarioGrupo", new UsuarioGrupoViewModel { 
                        UsuarioID = ListaUsuarioGrupo.First().UsuarioID,
                        UsuarioGrupoID = ListaUsuarioGrupo.First().GrupoUsuarioID,
                        Tipo = (Library.TipoUsuario)ListaUsuarioGrupo.First().GrupoUsuario.Tipo
                    });
                    return RedirectToAction("Index");
                }
                ViewBag.ListaUsuarioGrupo = ListaUsuarioGrupo;
            }
           
            return View();
        }

        public IActionResult SetModulo(long ID)
        {
            var user = User.FindFirstValue(ClaimTypes.NameIdentifier);
            ViewBag.ListaTipoVeiculo = new List<UsuarioGrupo>();

            var usuario = _context.Usuario.FirstOrDefault(o => o.UserId == user);
            if (usuario != null)
            {
                var UsuarioGrupo = _context.UsuarioGrupo.Include(x=> x.GrupoUsuario).AsNoTracking().Where(x => x.UsuarioID == usuario.ID && x.ID == ID).FirstOrDefault();
                if (UsuarioGrupo != null)
                {
                    HttpContext.Session.SetObject("UsuarioGrupo", new UsuarioGrupoViewModel
                    {
                        UsuarioID = UsuarioGrupo.UsuarioID,
                        UsuarioGrupoID = UsuarioGrupo.GrupoUsuarioID,
                        Tipo = (Library.TipoUsuario)UsuarioGrupo.GrupoUsuario.Tipo
                    });
                    return RedirectToAction("Index");
                }
            }
            return RedirectToAction("Modulo");
        }

    }
}
