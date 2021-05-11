using Facile.BusinessPortal.BusinessRules.Compra.SolicitacaoServico;
using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.Model.Compra.Servico;
using Facile.BusinessPortal.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("Compra")]
    public class SolicitacaoServicoFornecedorVisitanteController : BaseCommonController<Model.Compra.Servico.SolicitacaoServicoFornecedorVisitante>
    {
        public SolicitacaoServicoFornecedorVisitanteController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {

        }

        public override async Task<IActionResult> Index()
        {
            return RedirectToAction("Index", "SolicitacaoServico");
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public async Task<IActionResult> CreateVisitante(long Id)
        {
            
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            long FornecedorId = 0;
            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                var ResultUsuarioFornecedor = _context.UsuarioFornecedor.FirstOrDefault(x => x.UsuarioID == usuario.ID && x.EmpresaID == _empresaId);
                if (ResultUsuarioFornecedor != null)
                {
                    FornecedorId = ResultUsuarioFornecedor.FornecedorID;
                }
            }

            var Result = _context.SolicitacaoServicoFornecedor.AsNoTracking().
                           FirstOrDefault(x =>
                               x.EmpresaID == _empresaId &&
                               x.Habilitado &&
                               x.SolicitacaoServicoID == Id &&
                               x.FornecedorID == FornecedorId
                               );

            ViewBag.SolicitacaoServicoFornecedorID = 0;
            ViewBag.SolicitacaoServicoFornecedorVisitante = new List<Model.Compra.Servico.SolicitacaoServicoFornecedorVisitante>();
            if (Result != null)
            {
                ViewBag.SolicitacaoServicoFornecedorID = Result.ID;
                var ResultVisitante = _context.SolicitacaoServicoFornecedorVisitante.AsNoTracking().
                          Where(x =>
                              x.EmpresaID == _empresaId &&
                              x.Habilitado &&
                              x.SolicitacaoServicoFornecedorID == Result.ID
                              );
                ViewBag.SolicitacaoServicoFornecedorVisitante = ResultVisitante;
            }

            return View();
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateVisitante(List<Model.Compra.Servico.SolicitacaoServicoFornecedorVisitante> List)
        {
            try
            {
                 for (int i = 0; i <List.Count; i++)
                 {
                    List.ElementAt(i).EmpresaID = _empresaId;
                    List.ElementAt(i).Habilitado = true;
                    _context.Add(List.ElementAt(i));
                 }

                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index),"SolicitacaoServico");
            }
            catch (Exception ex)
            {
                HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, ex.Message, ControllerContext));
                return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
            }
        }


        public async Task<IActionResult> Remover(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                //  if (usuario.Tipo == TipoUsuario.Fornecedor)
                //  {
                //TUDO valida se do fornecedor logado
                var SolicitacaoServicoFornecedorVisitante = _context.SolicitacaoServicoFornecedorVisitante.FirstOrDefault(
                       o => o.ID == Id &&
                       o.EmpresaID == usuario.EmpresaID
               );

                if (SolicitacaoServicoFornecedorVisitante == null)
                {
                    return Json(new { Ok = false, Mensagem = "Id Informado não encontrado." });
                }
                else
                {
                    _context.Set<Model.Compra.Servico.SolicitacaoServicoFornecedorVisitante>().Remove(SolicitacaoServicoFornecedorVisitante);
                    await _context.SaveChangesAsync();
                    return Json(new { Ok = true, Mensagem = "" });
                }

                //  }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }
    }
}
