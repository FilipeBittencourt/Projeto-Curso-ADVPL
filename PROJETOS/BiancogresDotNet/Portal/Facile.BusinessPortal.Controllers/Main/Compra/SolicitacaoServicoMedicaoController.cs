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
    public class SolicitacaoServicoMedicaoController : BaseCommonController<Model.Compra.Servico.SolicitacaoServicoMedicao>
    {
        public SolicitacaoServicoMedicaoController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {

        }

        public override async Task<IActionResult> Index()
        {
            return RedirectToAction("Index", "SolicitacaoServico");
        }

        public async Task<IActionResult> RemoverMedicao(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                //  if (usuario.Tipo == TipoUsuario.Fornecedor)
                //  {
                //TUDO valida se do fornecedor logado
                var SolicitacaoServicoMedicaoItem = _context.SolicitacaoServicoMedicaoItem.FirstOrDefault(
                       o => o.ID == Id &&
                       o.EmpresaID == usuario.EmpresaID
                    );

                if (SolicitacaoServicoMedicaoItem == null)
                {
                    return Json(new { Ok = false, Mensagem = "Id Informado não encontrado." });
                }
                else
                {
                    _context.Set<SolicitacaoServicoMedicaoItem>().Remove(SolicitacaoServicoMedicaoItem);
                    await _context.SaveChangesAsync();
                    return Json(new { Ok = true, Mensagem = "" });
                }

                //  }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        public async Task<IActionResult> GetAnexo(long Id)
        {
            try
            {
                Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
                if (usuario != null)
                {

                    //TUDO valida se do fornecedor logado
                    var SolicitacaoServicoMedicaoItem = _context.SolicitacaoServicoMedicaoItem.FirstOrDefault(
                          o => o.ID == Id &&
                          o.EmpresaID == usuario.EmpresaID
                       );

                    if (SolicitacaoServicoMedicaoItem != null && SolicitacaoServicoMedicaoItem.ArquivoAnexo != null)
                    {
                        return File(SolicitacaoServicoMedicaoItem.ArquivoAnexo.ToArray(), SolicitacaoServicoMedicaoItem.TipoAnexo, SolicitacaoServicoMedicaoItem.NomeAnexo );
                    }
                    else
                    {
                        HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, "Anexo não encontrado", ControllerContext));
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


        public async Task<IActionResult> GetAnexoNotaFiscal(long Id)
        {
            try
            {
                Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
                if (usuario != null)
                {

                    //TUDO valida se do fornecedor logado
                    var SolicitacaoServicoMedicao = _context.SolicitacaoServicoMedicao.FirstOrDefault(
                          o => o.ID == Id &&
                          o.EmpresaID == usuario.EmpresaID
                       );

                    if (SolicitacaoServicoMedicao != null && SolicitacaoServicoMedicao.ArquivoAnexoNotaFiscal != null)
                    {
                        return File(SolicitacaoServicoMedicao.ArquivoAnexoNotaFiscal.ToArray(), SolicitacaoServicoMedicao.TipoAnexoNotaFiscal, SolicitacaoServicoMedicao.NomeAnexoNotaFiscal);
                    }
                    else
                    {
                        HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, "Anexo não encontrado", ControllerContext));
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

        public async Task<IActionResult> SalvarAnexoNotaFiscal()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        string SolicitacaoServicoMedicaoID = Request.Form["SolicitacaoServicoMedicaoID"];

                        if (Request.Form.Files.Count == 0)
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Não foi informado nenhum arquivo." });
                        }

                        if (SolicitacaoServicoMedicaoID == null)
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Medições não informado." });
                        }

                        var IDSolicitacaoServicoMedicao = Convert.ToInt64(SolicitacaoServicoMedicaoID);

                        var SolicitacaoServicoMedicao = _context.SolicitacaoServicoMedicao.FirstOrDefault(
                              o => o.ID == IDSolicitacaoServicoMedicao &&
                              o.EmpresaID == usuario.EmpresaID
                           );

                        if (SolicitacaoServicoMedicao != null)
                        {
                            foreach (var file in Request.Form.Files)
                            {
                                if (file.Length == 0)
                                {
                                    continue;
                                }
                                using (var memoryStream = new MemoryStream())
                                {
                                    file.CopyTo(memoryStream);
                                    SolicitacaoServicoMedicao.ArquivoAnexoNotaFiscal = (memoryStream as MemoryStream).ToArray();
                                    SolicitacaoServicoMedicao.NomeAnexoNotaFiscal = file.FileName;
                                    SolicitacaoServicoMedicao.TipoAnexoNotaFiscal = file.ContentType;
                                }
                            }
                            SolicitacaoServicoMedicao.Status = StatusSolicitacaoServicoMedicao.NotaFiscalAdicionada; //? StatusSolicitacaoServicoMedicao.Aprovada : StatusSolicitacaoServicoMedicao.Concluido;
                            SolicitacaoServicoMedicao.UsuarioID = usuario.ID;
                            _context.Entry(SolicitacaoServicoMedicao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                            _context.Add<SolicitacaoServicoHistorico>(new SolicitacaoServicoHistorico
                            {
                                EmpresaID = _empresaId,
                                UsuarioID = _usuario.ID,
                                SolicitacaoServicoID = SolicitacaoServicoMedicao.SolicitacaoServicoID,
                                DataEvento = DateTime.Now,
                                Observacao = (StatusSolicitacaoServicoMedicao.NotaFiscalAdicionada).ToString() + " a medição"
                            });

                            await _context.SaveChangesAsync();

                            var ResultMail = SolicitacaoServicoMail.EmailMedicao(_context, SolicitacaoServicoMedicao.SolicitacaoServicoID, SolicitacaoServicoMedicao.ID);
                            if (!ResultMail.Status)
                            {
                                return Json(new { Ok = false, Mensagem = "Erro envio do e-mail." });
                            }

                            transaction.Commit();
                            return Json(new { Ok = true, Mensagem = "" });
                        }
                        
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Erro Interno." });
                    }
                }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        public async Task<IActionResult> SalvarStatusNotaFiscal(long Id, int Status, string Observacao)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                //  if (usuario.Tipo == TipoUsuario.Fornecedor)
                //  {
                //TUDO valida se do fornecedor logado
                try
                {
                    var SolicitacaoServicoMedicao = _context.SolicitacaoServicoMedicao.FirstOrDefault(
                       o => o.ID == Id &&
                       o.EmpresaID == usuario.EmpresaID
                    );

                    if (SolicitacaoServicoMedicao == null)
                    {
                        return Json(new { Ok = false, Mensagem = "Id Informado não encontrado." });
                    }
                    else
                    {
                        // if (SolicitacaoServicoMedicaoItem.Status == StatusSolicitacaoServicoMedicao.Aguardando)
                        {

                            SolicitacaoServicoMedicao.Status = (StatusSolicitacaoServicoMedicao)Status; //? StatusSolicitacaoServicoMedicao.Aprovada : StatusSolicitacaoServicoMedicao.Concluido;
                            _context.Entry(SolicitacaoServicoMedicao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                            _context.Add<SolicitacaoServicoHistorico>(new SolicitacaoServicoHistorico
                            {
                                EmpresaID = _empresaId,
                                UsuarioID = _usuario.ID,
                                SolicitacaoServicoID = SolicitacaoServicoMedicao.SolicitacaoServicoID,
                                DataEvento = DateTime.Now,
                                Observacao = ((StatusSolicitacaoServicoMedicao)Status).ToString() + " a medição"
                            });

                            await _context.SaveChangesAsync();

                            var SolicitacaoServicoMedicaoItem = _context.SolicitacaoServicoMedicaoItem.Where(
                              o => o.SolicitacaoServicoMedicaoID == SolicitacaoServicoMedicao.ID);
                            foreach(var item in SolicitacaoServicoMedicaoItem)
                            {
                                item.Status = (StatusSolicitacaoServicoMedicao)Status; //? StatusSolicitacaoServicoMedicao.Aprovada : StatusSolicitacaoServicoMedicao.Concluido;
                                _context.Entry(item).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                            }
                            await _context.SaveChangesAsync();

                            var ResultMail = SolicitacaoServicoMail.EmailMedicaoFornecedor(_context, SolicitacaoServicoMedicao.SolicitacaoServicoID, SolicitacaoServicoMedicao.ID);
                            if (!ResultMail.Status)
                            {
                                return Json(new { Ok = false, Mensagem = "Erro envio do e-mail." });
                            }


                            return Json(new { Ok = true, Mensagem = "" });
                        }
                        //return Json(new { Ok = false, Mensagem = "Medição não esta com Status 'Aguardando'." });
                    }
                }
                catch (Exception ex)
                {
                    return Json(new { Ok = false, Mensagem = "Erro interno: " + ex.Message });
                }


                //  }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        public async Task<IActionResult> SalvarStatus(long Id, int Status, string Observacao)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                //  if (usuario.Tipo == TipoUsuario.Fornecedor)
                //  {
                //TUDO valida se do fornecedor logado
                try
                {
                    var SolicitacaoServicoMedicaoItem = _context.SolicitacaoServicoMedicaoItem.FirstOrDefault(
                       o => o.ID == Id &&
                       o.EmpresaID == usuario.EmpresaID
                    );

                    if (SolicitacaoServicoMedicaoItem == null)
                    {
                        return Json(new { Ok = false, Mensagem = "Id Informado não encontrado." });
                    }
                    else
                    {
                       // if (SolicitacaoServicoMedicaoItem.Status == StatusSolicitacaoServicoMedicao.Aguardando)
                        {

                            SolicitacaoServicoMedicaoItem.Status = (StatusSolicitacaoServicoMedicao)Status; //? StatusSolicitacaoServicoMedicao.Aprovada : StatusSolicitacaoServicoMedicao.Concluido;
                            SolicitacaoServicoMedicaoItem.DataMedicao = DateTime.Now;
                            SolicitacaoServicoMedicaoItem.UsuarioID = usuario.ID;
                            SolicitacaoServicoMedicaoItem.ObservacaoMedicao = Observacao;
                            _context.Entry(SolicitacaoServicoMedicaoItem).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                           

                            _context.Add<SolicitacaoServicoHistorico>(new SolicitacaoServicoHistorico
                            {
                                EmpresaID = _empresaId,
                                UsuarioID = _usuario.ID,
                                SolicitacaoServicoID = SolicitacaoServicoMedicaoItem.SolicitacaoServicoItem.SolicitacaoServicoID,
                                DataEvento = DateTime.Now,
                                Observacao = ((StatusSolicitacaoServicoMedicao)Status).ToString()+" a medição"
                            });

                            await _context.SaveChangesAsync();

                            var Result = _context.SolicitacaoServicoMedicaoItem.Any(
                      o => o.SolicitacaoServicoMedicaoID == SolicitacaoServicoMedicaoItem.SolicitacaoServicoMedicaoID &&
                      o.Status != StatusSolicitacaoServicoMedicao.AguardandoNotaFiscal
                   );

                            if (!Result)
                            {
                                var SolicitacaoServicoMedicao = _context.SolicitacaoServicoMedicao.FirstOrDefault(
                      o => o.ID == SolicitacaoServicoMedicaoItem.SolicitacaoServicoMedicaoID);
                                if (SolicitacaoServicoMedicao != null)
                                {
                                    SolicitacaoServicoMedicao.Status = StatusSolicitacaoServicoMedicao.AguardandoNotaFiscal; //? StatusSolicitacaoServicoMedicao.Aprovada : StatusSolicitacaoServicoMedicao.Concluido;
                                    _context.Entry(SolicitacaoServicoMedicao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                                    await _context.SaveChangesAsync();
                                }
                            }
                            

                            var ResultMail = SolicitacaoServicoMail.EmailItemMedicaoFornecedor(_context, SolicitacaoServicoMedicaoItem.ID);
                            if (!ResultMail.Status)
                            {
                                return Json(new { Ok = false, Mensagem = "Erro envio do e-mail." });
                            }


                            return Json(new { Ok = true, Mensagem = "" });
                        }
                        //return Json(new { Ok = false, Mensagem = "Medição não esta com Status 'Aguardando'." });
                    }
                }
                catch (Exception ex)
                {
                    return Json(new { Ok = false, Mensagem = "Erro interno: " + ex.Message });
                }


                //  }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual IActionResult CreateMedicao(long Id)
        {
            var SolicitacaoServicoItem = _context.SolicitacaoServicoItem.
                            Include(x => x.SolicitacaoServicoMedicaoItem).
                           Where(x =>
                               x.EmpresaID == _empresaId &&
                               x.Habilitado &&
                               x.SolicitacaoServicoID == Id
                               ).ToList();

            ViewBag.ListaSolicitacaoServicoItem = SolicitacaoServicoItem;

            var SolicitacaoServicoMedicao = _context.SolicitacaoServicoMedicao.
                           AsNoTracking().
                           FirstOrDefault(x =>
                               x.EmpresaID == _empresaId &&
                               x.Habilitado &&
                               x.SolicitacaoServicoID == Id &&
                               (
                                x.Status == StatusSolicitacaoServicoMedicao.AguardandoNotaFiscal || 
                                x.Status == StatusSolicitacaoServicoMedicao.NotaFiscalAdicionada 
                                )
                          );

            ViewBag.SolicitacaoServicoMedicao = SolicitacaoServicoMedicao;


            var SolicitacaoServicoFornecedor = _context.SolicitacaoServicoFornecedor.
                           AsNoTracking().
                           FirstOrDefault(x =>
                               x.EmpresaID == _empresaId &&
                               x.Habilitado &&
                               x.SolicitacaoServicoID == Id &&
                               x.Vencedor
                          );

            ViewBag.ListaSolicitacaoServicoCotacaoItem = new List<SolicitacaoServicoCotacaoItem>();

            if (SolicitacaoServicoFornecedor != null)
            {
                long FornecedorId = SolicitacaoServicoFornecedor.FornecedorID;
                var SolicitacaoServicoCotacaoItem = _context.SolicitacaoServicoCotacaoItem.
                        Include(x=>x.SolicitacaoServicoCotacao).
                        AsNoTracking().
                        Where(x =>
                             x.SolicitacaoServicoCotacao.EmpresaID == _empresaId &&
                             x.SolicitacaoServicoCotacao.Habilitado &&
                             x.SolicitacaoServicoCotacao.FornecedorID == FornecedorId &&
                             x.SolicitacaoServicoCotacao.SolicitacaoServicoID == Id
                        ).ToList();
                ViewBag.ListaSolicitacaoServicoCotacaoItem = SolicitacaoServicoCotacaoItem;
            }

            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                return View("CreateMedicaoFO");
            }
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateMedicao(Model.Compra.Servico.SolicitacaoServicoMedicao o)
        {
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

                        o.ID = 0;
                        o.Data = DateTime.Now;
                        o.EmpresaID = _empresaId;
                        o.UsuarioID = _usuario.ID;
                        o.Habilitado = true;
                        o.UnidadeID = SolicitacaoServico.UnidadeID;

                        List<SolicitacaoServicoMedicaoItem> List = new List<SolicitacaoServicoMedicaoItem>();

                        if (o.SolicitacaoServicoMedicaoItem != null)
                        {
                            for (int i = 0; i < o.SolicitacaoServicoMedicaoItem.Count; i++)
                            {
                                List.Add(o.SolicitacaoServicoMedicaoItem.ElementAt(i));
                            }
                        }

                        if (o.SolicitacaoServicoMedicaoItem != null)
                        {
                            for (int i = 0; i < o.SolicitacaoServicoMedicaoItem.Count; i++)
                            {
                                o.SolicitacaoServicoMedicaoItem.ElementAt(i).EmpresaID = _empresaId;
                                o.SolicitacaoServicoMedicaoItem.ElementAt(i).Habilitado = true;
                                o.SolicitacaoServicoMedicaoItem.ElementAt(i).UnidadeID = SolicitacaoServico.UnidadeID;

                                if (Request.Form.Files.Count > 0)
                                {
                                    var file = Request.Form.Files["SolicitacaoServicoMedicaoItem[" + i + "].customFile"];
                                    if (file != null && file.Length != 0)
                                    {
                                        using (var memoryStream = new MemoryStream())
                                        {
                                            file.CopyTo(memoryStream);
                                            o.SolicitacaoServicoMedicaoItem.ElementAt(i).ArquivoAnexo = (memoryStream as MemoryStream).ToArray();
                                            o.SolicitacaoServicoMedicaoItem.ElementAt(i).NomeAnexo = file.FileName;
                                            o.SolicitacaoServicoMedicaoItem.ElementAt(i).TipoAnexo = file.ContentType;
                                        }
                                    }
                                }

                                if (o.SolicitacaoServicoMedicaoItem.ElementAt(i).Medicao == 0 && o.SolicitacaoServicoMedicaoItem.ElementAt(i).Valor == 0)
                                {
                                    List.Remove(o.SolicitacaoServicoMedicaoItem.ElementAt(i));
                                }

                            }
                        }


                        o.SolicitacaoServicoMedicaoItem = List;

                        _context.Add<Model.Compra.Servico.SolicitacaoServicoMedicao>(o);

                        _context.Add<SolicitacaoServicoHistorico>(new SolicitacaoServicoHistorico
                        {
                            EmpresaID = _empresaId,
                            UsuarioID = _usuario.ID,
                            SolicitacaoServicoID = SolicitacaoServico.ID,
                            DataEvento = DateTime.Now,
                            Observacao = "Inclusão de uma nova medição"
                        });

                        await _context.SaveChangesAsync();

                        var ResultMail = SolicitacaoServicoMail.EmailMedicao(_context, o.SolicitacaoServicoID, o.ID);
                        if (!ResultMail.Status)
                        {

                        }


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

        public async Task<IActionResult> ValidarMedicao(Model.Compra.Servico.SolicitacaoServicoMedicao o)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                //  if (usuario.Tipo == TipoUsuario.Fornecedor)
                //  {
                //TUDO valida se do fornecedor logado
                try
                {
                    if (o != null)
                    {
                        if (o.SolicitacaoServicoMedicaoItem != null)
                        {
                            for (int i = 0; i < o.SolicitacaoServicoMedicaoItem.Count; i++)
                            {
                                var SolicitacaoServicoItem = _context.SolicitacaoServicoItem.FirstOrDefault(
                                      x => x.ID == o.SolicitacaoServicoMedicaoItem.ElementAt(i).SolicitacaoServicoItemID &&
                                      x.EmpresaID == usuario.EmpresaID
                                   );

                                if (SolicitacaoServicoItem != null)
                                {
                                    if (SolicitacaoServicoItem.DataInicioContrato.HasValue && SolicitacaoServicoItem.DataFinalContrato.HasValue)
                                    {
                                        if (
                                            o.SolicitacaoServicoMedicaoItem.ElementAt(i).Data.Date >= SolicitacaoServicoItem.DataInicioContrato.Value.Date &&
                                             o.SolicitacaoServicoMedicaoItem.ElementAt(i).Data.Date <= SolicitacaoServicoItem.DataFinalContrato.Value.Date)
                                        {
                                            return Json(new { Ok = true, Mensagem = "" });
                                        }
                                        else
                                        {
                                            return Json(new
                                            {
                                                Ok = false,
                                                Mensagem = "Produto: "+SolicitacaoServicoItem.Descricao+", Data de medição fora do intervalo do contrato: Data Inicio: " + SolicitacaoServicoItem.DataInicioContrato.Value.ToString("dd/MM/yyyy") +
                                                ", Data Final: " + SolicitacaoServicoItem.DataFinalContrato.Value.ToString("dd/MM/yyyy")
                                            }); ;
                                        }
                                    }
                                }
                                return Json(new { Ok = false, Mensagem = "Item da solicitação não encontrado." });

                            }
                        }
                    }
                    return Json(new { Ok = false, Mensagem = "Erro na medição." });
                }
                catch (Exception ex)
                {
                    return Json(new { Ok = false, Mensagem = "Erro interno: " + ex.Message });
                }


                //  }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }
    }
}
