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
    public class SolicitacaoServicoCotacaoController : BaseCommonController<Model.Compra.Servico.SolicitacaoServicoCotacao>
    {
        public SolicitacaoServicoCotacaoController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {

        }

        public override async Task<IActionResult> Index()
        {
            return RedirectToAction("Index", "SolicitacaoServico");
        }

        public async Task<IActionResult> CheckFornecedorCadastrado(long Id)
        {
            try
            {
                Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
                if (usuario != null)
                {

                    //TUDO valida se do fornecedor logado
                    var Result = _context.SolicitacaoServicoFornecedor.Include(x => x.Fornecedor).Where(o =>
                             o.EmpresaID == usuario.EmpresaID &&
                             o.SolicitacaoServicoID == Id &&
                             o.Fornecedor.CodigoERP.Equals("")
                   ).Select(x=> new {
                       ID = x.Fornecedor.ID,
                       CPFCNPJ = x.Fornecedor.CPFCNPJ,
                       Nome = x.Fornecedor.Nome
                   });

                    return new JsonResult(new { ok = true, result = Result });

                }
                return new JsonResult(new { ok = false });

            }
            catch (Exception ex)
            {
                return new JsonResult(new { ok = false });

            }

        }

        public async Task<IActionResult> GetAnexo(long Id)
        {
            try
            {
                Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
                if (usuario != null)
                {

                    //TUDO valida se do fornecedor logado
                    var Result = _context.SolicitacaoServicoCotacao.FirstOrDefault(o =>
                           o.EmpresaID == usuario.EmpresaID &&
                           o.ID == Id
                   );

                    if (Result != null && Result.ArquivoAnexo != null)
                    {
                        return File(Result.ArquivoAnexo.ToArray(), Result.TipoAnexo, Result.NomeAnexo);
                    }
                    else
                    {
                        HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, "Anexo cotação não encontrado", ControllerContext));
                        return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
                    }
                }
                HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, "Usuário não encontrado", ControllerContext));
                return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
            }
            catch (Exception ex)
            {
                HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, ex.Message, ControllerContext));
                return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
            }

        }

 
        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public IActionResult Select(long Id)
        {
            var ResultSolicitacaoServicoFornecedor = _context.SolicitacaoServicoFornecedor.Include(x=>x.Fornecedor).AsNoTracking().
                           Where(x =>
                               x.EmpresaID == _empresaId &&
                               x.Habilitado &&
                               x.SolicitacaoServicoID == Id
                               ).ToList();

            ViewBag.ListaSolicitacaoServicoFornecedor = ResultSolicitacaoServicoFornecedor;


            var ResultSolicitacaoServicoCotacao = _context.SolicitacaoServicoCotacao.
                    Include(x => x.SolicitacaoServicoCotacaoItem).
                           Where(x =>
                               x.EmpresaID == _empresaId &&
                               x.Habilitado &&
                               x.SolicitacaoServicoID == Id 
                               ).ToList();
            

            ViewBag.ListaSolicitacaoServicoCotacao = ResultSolicitacaoServicoCotacao;

            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Select(List<Model.Compra.Servico.SolicitacaoServicoFornecedor> List)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    if (List.Count > 0)
                    {
                        var SolicitacaoServico = _context.SolicitacaoServico.FirstOrDefault(s => s.ID == List.FirstOrDefault().SolicitacaoServicoID);

                        if (SolicitacaoServico != null)
                        {
                            _context.Add<SolicitacaoServico>(SolicitacaoServico);
                            SolicitacaoServico.Status = StatusSolicitacaoServico.LiberadoIntegracao;
                            _context.Entry(SolicitacaoServico).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                        }


                        for (int i = 0; i < List.Count; i++)
                        {
                            var SolicitacaoServicoFornecedor = _context.SolicitacaoServicoFornecedor.FirstOrDefault(x =>
                                    x.EmpresaID == _empresaId
                                    && x.Habilitado
                                    && x.ID == List.ElementAt(i).ID);

                            if (SolicitacaoServicoFornecedor != null)
                            {
                                SolicitacaoServicoFornecedor.Aprovado = List.ElementAt(i).Aprovado;
                                SolicitacaoServicoFornecedor.Observacao = List.ElementAt(i).Observacao;
                                _context.Entry(SolicitacaoServicoFornecedor).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                                if (List.ElementAt(i).Aprovado)
                                {
                                    var ResultMail = SolicitacaoServicoMail.SolicitacaoServicoNaoSelecionadaSendMail(_context, SolicitacaoServicoFornecedor.ID);
                                    if (!ResultMail.Status)
                                    {

                                    }
                                }

                            }
                        }
                        _context.Add<SolicitacaoServicoHistorico>(new SolicitacaoServicoHistorico
                        {
                            EmpresaID = _empresaId,
                            UsuarioID = _usuario.ID,
                            SolicitacaoServicoID = SolicitacaoServico.ID,
                            DataEvento = DateTime.Now,
                            Observacao = "Liberado integração com bizagi"
                        });

                        await _context.SaveChangesAsync();
                    }
                    transaction.Commit();

                    return RedirectToAction(nameof(Index), "SolicitacaoServico");
                } catch (Exception ex)
                {
                    transaction.Rollback();
                    HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, ex.Message, ControllerContext));
                    return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
                }
            }
        }


        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public override async Task<IActionResult> Edit(long? id)
        {
            if (id == null)
            {
                ControllerContext.HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Validation, "[edit] Operação Inválida.", ControllerContext));
                return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
            }

            var Id = id.Value;
            var Result = _context.SolicitacaoServicoItem.Include(x => x.Produto).AsNoTracking().
                           Where(x =>
                               x.EmpresaID == _empresaId &&
                               x.Habilitado &&
                               x.SolicitacaoServicoID == Id
                               ).ToList();

            ViewBag.ListaSolicitacaoServicoItem = Result;

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

            var ResultSolicitacaoServicoCotacao = _context.SolicitacaoServicoCotacao.Include(x => x.SolicitacaoServicoCotacaoItem).AsNoTracking().
                          FirstOrDefault(x =>
                              x.EmpresaID == _empresaId &&
                              x.Habilitado &&
                              x.FornecedorID == FornecedorId &&
                              x.SolicitacaoServicoID == Id
                              );
            if (ResultSolicitacaoServicoCotacao != null)
            {
                return View(ResultSolicitacaoServicoCotacao);
            }
            var o = new SolicitacaoServicoCotacao()
            {
                SolicitacaoServicoID = Id,
                FornecedorID = FornecedorId
            };
            o.SolicitacaoServicoCotacaoItem = new List<SolicitacaoServicoCotacaoItem>();
            foreach (var item in Result)
            {
                o.SolicitacaoServicoCotacaoItem.Add(new SolicitacaoServicoCotacaoItem() { });
            }
            return View(o);
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public override async Task<IActionResult> Edit(int id, Model.Compra.Servico.SolicitacaoServicoCotacao o)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    var SolicitacaoServico = _context.SolicitacaoServico.AsNoTracking().FirstOrDefault(x =>
                        x.EmpresaID == _empresaId
                        && x.Habilitado
                        && x.ID == o.SolicitacaoServicoID);
                    if (SolicitacaoServico != null)
                    {
                        var SolicitacaoServicoCotacao = _context.SolicitacaoServicoCotacao.FirstOrDefault(x =>
                        x.FornecedorID == o.FornecedorID
                        && x.EmpresaID == _empresaId
                        && x.Habilitado
                        && x.SolicitacaoServicoID == o.SolicitacaoServicoID);

                        string Revisao = "01";

                        //desabilitar ultima cotação
                        if (SolicitacaoServicoCotacao != null)
                        {
                            var ProximaRevisao = Convert.ToInt32(SolicitacaoServicoCotacao.Revisao) + 1;
                            Revisao = ProximaRevisao.ToString().PadLeft(2, '0');

                            SolicitacaoServicoCotacao.Habilitado = false;
                            _context.Entry(SolicitacaoServicoCotacao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                        }

                        //criar uma nova cotação
                        o.ID = 0;
                        o.InsertUser = _userId;
                        o.EmpresaID = _empresaId;
                        o.InsertDate = DateTime.Now;
                        o.UnidadeID = SolicitacaoServico.UnidadeID;//TODO REMOVER
                        o.Habilitado = true;
                        o.Revisao = Revisao;
                        o.Origem = 1;//Portal

                        if (Request.Form.Files.Count == 1)
                        {
                            var file = Request.Form.Files[0];
                            if (file.Length > 0)
                            {
                                using (var memoryStream = new MemoryStream())
                                {
                                    file.CopyTo(memoryStream);
                                    o.ArquivoAnexo = (memoryStream as MemoryStream).ToArray();
                                    o.NomeAnexo = file.FileName;
                                    o.TipoAnexo = file.ContentType;
                                }
                            }
                        }

                        if (o.SolicitacaoServicoCotacaoItem != null)
                        {
                            for (int i = 0; i < o.SolicitacaoServicoCotacaoItem.Count; i++)
                            {
                                o.SolicitacaoServicoCotacaoItem.ElementAt(i).EmpresaID = _empresaId;
                                o.SolicitacaoServicoCotacaoItem.ElementAt(i).Habilitado = true;

                                var ID = o.SolicitacaoServicoCotacaoItem.ElementAt(i).SolicitacaoServicoItemID;
                                if (_context.SolicitacaoServicoItem.AsNoTracking().Any(
                                        x =>
                                        x.ID == ID
                                        && !x.Cotacao.Equals("")
                                        && !x.CotacaoItem.Equals("")
                                        )
                                    )
                                {
                                    var SolicitacaoServicoFornecedor = _context.SolicitacaoServicoFornecedor.FirstOrDefault(
                                         x =>
                                         x.FornecedorID == o.FornecedorID
                                         && x.SolicitacaoServicoID == o.SolicitacaoServicoID
                                         );

                                    SolicitacaoServicoFornecedor.Aprovado = true;
                                    _context.Entry(SolicitacaoServicoFornecedor).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                                }
                            }
                        }

                        _context.Add<SolicitacaoServicoHistorico>(new SolicitacaoServicoHistorico
                        {
                            EmpresaID = _empresaId,
                            UsuarioID = _usuario.ID,
                            SolicitacaoServicoID = SolicitacaoServico.ID,
                            DataEvento = DateTime.Now,
                            Observacao = "Adicionado cotação"
                        });

                        _context.Add(o);
                        await _context.SaveChangesAsync();

                        transaction.Commit();
                    }

                    return RedirectToAction(nameof(Index), "SolicitacaoServico");
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, ex.Message, ControllerContext));
                    return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
                }
            }          
        }

    }
}
