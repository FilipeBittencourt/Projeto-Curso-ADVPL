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

namespace Facile.BusinessPortal.Controllers.Main.Fornecedor
{
    [Authorize]
    [Area("Fornecedor")]
    public class HomeController : BaseCommonController<Model.Fornecedor>
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

                long FornecedorID = 0;

                if (usuario.Tipo == TipoUsuario.Fornecedor)
                {
                    var fornecedor =  FornecedorDAO.GetFornecedorUsuario(_context,usuario);

                    FornecedorID = fornecedor.ID;
                    var Result = _context.Antecipacao.Any(
                            x=> x.Status == StatusAntecipacao.AguardandoParecerFornecedor &&
                            x.FornecedorID == FornecedorID &&
                            x.EmpresaID == _empresaId
                            );

                    if (Result)
                    {
                        return RedirectToAction("Index", "Antecipacao", new { area = "Fornecedor" });
                    } else
                    {
                       // HttpContext.Session.SetInt32("RedirectHome", 1);
                        return RedirectToAction("Index", "Analise", new { area = "Fornecedor" });
                    }

                } else if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                {
                    var Result = _context.Antecipacao.Any(
                           x => x.Status == StatusAntecipacao.AguardandoParecerEmpresa &&
                           x.EmpresaID == _empresaId
                           );
                    if (Result)
                    {
                        HttpContext.Session.SetInt32("RedirectHome", 1);
                        return RedirectToAction("Index", "Antecipacao", new { area = "Fornecedor" });
                    }
                    else{
                        HttpContext.Session.SetInt32("RedirectHome", 1);
                        return RedirectToAction("Index", "Analise", new { area = "Fornecedor" });
                    }
                }

               
            }

            return View();
        }
    }
}
