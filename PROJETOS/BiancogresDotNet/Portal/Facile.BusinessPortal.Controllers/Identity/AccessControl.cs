using Facile.BusinessPortal.Library.Extensions;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;

namespace Facile.BusinessPortal.Controllers
{
    public class AccessControl
    {
        public static bool SaveLastLogin(FBContext db, string userId)
        {
            try
            {
                var usuario = db.Usuario.First(o => o.UserId == userId);
                if (usuario != null)
                {
                    //usuario.PenultimoAcesso = usuario.UltimoAcesso;
                    usuario.UltimoAcesso = DateTime.Now;
                    db.SaveChanges();

                    return true;
                }
                return false;
            }
            catch
            {
                return false;
            }
        }

        public static bool CheckControllerAccess(FBContext context, string controllerName, string userId)
        {
            var hasAccess = false;

            var qadmin = from GrupoUsuario g in context.GrupoUsuario
                         join u in context.Usuario on g.ID equals u.GrupoUsuarioID
                         where g.Nome == "Admin"
                         && u.UserId == userId
                         select new { ok = true };

            hasAccess = qadmin.Any();

            if (!hasAccess)
            {
                var qaccess = from Menu m in context.Menu
                              join p in context.Permissao on m.ID equals p.MenuID
                              join g in context.GrupoUsuario on p.GrupoUsuarioID equals g.ID
                              join u in context.Usuario on g.ID equals u.GrupoUsuarioID
                              where m.Nome == controllerName
                              && u.UserId == userId
                              select new { ok = true };

                hasAccess = qaccess.Any();
            }


            return hasAccess;
        }

        public static bool CheckAccess(FBContext context, ControllerContext controllerContext)
        {
            try
            {
                var userId = controllerContext.HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
                var actionName = controllerContext.ActionDescriptor.ActionName;
                var controllerName = controllerContext.ActionDescriptor.ControllerName;

                var hasAccess = CheckControllerAccess(context, controllerName, userId);

                return hasAccess;
            }
            catch
            {
                return false;
            }
        }

        public static bool CheckAccess(FBContext context, string userId, string controllerName)
        {
            try
            {
                var hasAccess = CheckControllerAccess(context, controllerName, userId);
                return hasAccess;
            }
            catch
            {
                return false;
            }
        }

        public static void CriarMenusUsuario(HttpContext Httpcontext, FBContext context, string userId, ModuloUsuarioViewModel modulo)
        {
            var menusmodel = CreateMenuUsuario(context, userId, modulo);
            Httpcontext.Session.SetObject("AllMenusUsuarioViewModel", menusmodel);
        }

        public static void CriarModulosUsuario(HttpContext Httpcontext, FBContext context, string userId)
        {
            var modulosmodel = AccessControl.CreateModuloUsuario(context, userId);
            if (modulosmodel.Modulos != null && modulosmodel.Modulos.Any())
            {
                Httpcontext.Session.SetObject("CurrentModuloViewModel", modulosmodel.Modulos.First());
                Httpcontext.Session.SetObject("AllModulosUsuarioViewModel", modulosmodel);
            }
        }

        public static AllMenusUsuarioViewModel CreateMenuUsuario(FBContext context, string userId, ModuloUsuarioViewModel modulo)
        {
            var model = new AllMenusUsuarioViewModel();

            var qmenu = (from Menu m in context.Menu
                         join p in context.Permissao on m.ID equals p.MenuID
                         join g in context.GrupoUsuario on p.GrupoUsuarioID equals g.ID
                         join u in context.Usuario on g.ID equals u.GrupoUsuarioID
                         where u.UserId == userId
                         && m.ModuloID == modulo.Id
                         && p.Habilitado
                         && p.Acao.Nome.Equals("Listar")
                         select m).OrderBy(m => m.Ordem);

            if (qmenu.Any())
            {

                var ResultGrupoMenu = qmenu.Where(x => !x.MenuSuperiorID.HasValue);

                foreach (var gm in ResultGrupoMenu)
                {
                    GrupoMenuUsuarioViewModel gmodel = new GrupoMenuUsuarioViewModel() { Nome = gm.Nome, URL = gm.Nome, Area = gm.Modulo.Nome, ClasseIcone = gm.ClasseIcone };

                    var ResultMenu = qmenu.Where(x => x.MenuSuperiorID.HasValue && x.MenuSuperiorID == gm.ID).ToList();

                    if (ResultMenu.Count() > 0)
                    {
                        foreach (var menu in ResultMenu)
                        {

                            var menuModel = new MenuUsuarioViewModel()
                            {
                                ControllerName = menu.Nome,
                                Nome = menu.Nome,
                                Descricao = menu.Descricao
                            };

                            gmodel.Menus.Add(menuModel);
                        }
                    }
                    else
                    {
                        var menuModel = new MenuUsuarioViewModel()
                        {
                            ControllerName = gm.Nome,
                            Nome = gm.Nome,
                            Descricao = gm.Descricao
                        };

                        gmodel.Menus.Add(menuModel);
                    }

                    model.Grupos.Add(gmodel);

                }


            }

            return model;
        }

        public static AllModulosUsuarioViewModel CreateModuloUsuario(FBContext context, string userId)
        {
            var model = new AllModulosUsuarioViewModel();

            var qmodulo = (from Menu m in context.Menu
                           join p in context.Permissao on m.ID equals p.MenuID
                           join g in context.GrupoUsuario on p.GrupoUsuarioID equals g.ID
                           join u in context.Usuario on g.ID equals u.GrupoUsuarioID
                           where u.UserId == userId
                           && m.Habilitado
                           select m).GroupBy(m => m.ModuloID);

            if (qmodulo.Any())
            {
                foreach (var m in qmodulo)
                {
                    var ResultModulo = context.Modulo.AsNoTracking().FirstOrDefault(x => x.Habilitado && x.ID == m.Key);
                    if (ResultModulo != null)
                    {
                        ModuloUsuarioViewModel gmodel = ModuloViewModelById(context, m.Key);
                        model.Modulos.Add(gmodel);
                    }
                }
            }

            return model;
        }


        public static ModuloUsuarioViewModel ModuloViewModelById(FBContext context, long moduloId)
        {
            var ResultModulo = context.Modulo.AsNoTracking().FirstOrDefault(x => x.Habilitado && x.ID == moduloId);
            if (ResultModulo != null)
            {
                ModuloUsuarioViewModel gmodel = new ModuloUsuarioViewModel()
                {
                    Nome = ResultModulo.Nome,
                    Id = ResultModulo.ID,
                    Descricao = ResultModulo.Nome,
                    ClasseIcone = ResultModulo.ClasseIcone,
                    URL = ResultModulo.URL
                };

                return gmodel;
            }
            return null;
        }

        public static ModuloUsuarioViewModel SetCurrentModuloById(HttpContext Httpcontext, FBContext db, long moduloId)
        {
            var gmodel = ModuloViewModelById(db, moduloId);
            Httpcontext.Session.SetObject("CurrentModuloViewModel", gmodel);
            return gmodel;
        }

    }
}
