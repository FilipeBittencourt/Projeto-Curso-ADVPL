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
    public class SolicitacaoServicoMedicaoUnicaController : BaseCommonController<Model.Compra.Servico.SolicitacaoServicoMedicaoUnica>
    {
        public SolicitacaoServicoMedicaoUnicaController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {

        }

        public override async Task<IActionResult> Index()
        {
            return RedirectToAction("Index", "SolicitacaoServico");
        }

     
        public async Task<IActionResult> GetAnexo(long Id)
        {
            try
            {
                Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
                if (usuario != null)
                {

                    //TUDO valida se do fornecedor logado
                    var SolicitacaoServicoMedicaoUnica = _context.SolicitacaoServicoMedicaoUnica.FirstOrDefault(
                          o => o.ID == Id &&
                          o.EmpresaID == usuario.EmpresaID
                       );

                    if (SolicitacaoServicoMedicaoUnica != null && SolicitacaoServicoMedicaoUnica.ArquivoAnexo != null)
                    {
                        return File(SolicitacaoServicoMedicaoUnica.ArquivoAnexo.ToArray(), SolicitacaoServicoMedicaoUnica.TipoAnexo, SolicitacaoServicoMedicaoUnica.NomeAnexo );
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


        public async Task<IActionResult> SalvarAnexo()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        string SolicitacaoServicoID = Request.Form["SolicitacaoServicoID"];

                        if (Request.Form.Files.Count == 0)
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Não foi informado nenhum arquivo." });
                        }

                        if (SolicitacaoServicoID == null)
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Soliocitação de serviço não informado." });
                        }

                        long IDSolicitacaoServico = Convert.ToInt64(SolicitacaoServicoID);

                        var SolicitacaoServico = _context.SolicitacaoServico.AsNoTracking().FirstOrDefault(x =>
                                   x.EmpresaID == _empresaId
                                   && x.Habilitado
                                   && x.ID == IDSolicitacaoServico);

                        if (SolicitacaoServico != null)
                        {
                            var Result = _context.SolicitacaoServicoMedicaoUnica.FirstOrDefault(o =>
                                        o.SolicitacaoServicoID == IDSolicitacaoServico &&
                                        o.Habilitado &&
                                        o.EmpresaID == usuario.EmpresaID);
                            if (Result != null)
                            {
                                Result.Habilitado = true;
                                _context.Entry(Result).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                            }

                            SolicitacaoServicoMedicaoUnica solicitacaoServicoMedicaoUnica = new SolicitacaoServicoMedicaoUnica();
                            solicitacaoServicoMedicaoUnica.EmpresaID = _empresaId;
                            solicitacaoServicoMedicaoUnica.Habilitado = true;
                            solicitacaoServicoMedicaoUnica.UsuarioID = usuario.ID;
                            solicitacaoServicoMedicaoUnica.UnidadeID = 4;
                            solicitacaoServicoMedicaoUnica.SolicitacaoServicoID = IDSolicitacaoServico;
                            solicitacaoServicoMedicaoUnica.Status = StatusSolicitacaoServicoMedicaoUnica.NotaFiscalAdicionada;

                            if (Request.Form.Files.Count > 0)
                            {
                                var file = Request.Form.Files[0];
                                if (file.Length >= 0)
                                {
                                    using (var memoryStream = new MemoryStream())
                                    {
                                        file.CopyTo(memoryStream);
                                        solicitacaoServicoMedicaoUnica.ArquivoAnexo = (memoryStream as MemoryStream).ToArray();
                                        solicitacaoServicoMedicaoUnica.NomeAnexo = file.FileName;
                                        solicitacaoServicoMedicaoUnica.TipoAnexo = file.ContentType;
                                    }
                                }
                            }
                            _context.Add(solicitacaoServicoMedicaoUnica);
                            await _context.SaveChangesAsync();

                            var ResultMail = SolicitacaoServicoMail.EmailMedicaoUnica(_context, solicitacaoServicoMedicaoUnica.SolicitacaoServicoID, solicitacaoServicoMedicaoUnica.ID);
                            if (!ResultMail.Status)
                            {
                                return Json(new { Ok = false, Mensagem = "Erro envio do e-mail." });
                            }

                            transaction.Commit();
                            return Json(new { Ok = true, Mensagem = "" });
                        }

                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Solicitação de serviço não encontrada." });

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
                    var solicitacaoServicoMedicaoUnica = _context.SolicitacaoServicoMedicaoUnica.FirstOrDefault(
                       o => o.ID == Id &&
                        o.Habilitado &&
                       o.EmpresaID == usuario.EmpresaID
                    );

                    if (solicitacaoServicoMedicaoUnica == null)
                    {
                        return Json(new { Ok = false, Mensagem = "Id Informado não encontrado." });
                    }
                    else
                    {
                        // if (SolicitacaoServicoMedicaoItem.Status == StatusSolicitacaoServicoMedicao.Aguardando)
                        {
                            solicitacaoServicoMedicaoUnica.Observacao = Observacao;
                            solicitacaoServicoMedicaoUnica.Status = (StatusSolicitacaoServicoMedicaoUnica)Status; //? StatusSolicitacaoServicoMedicao.Aprovada : StatusSolicitacaoServicoMedicao.Concluido;
                            _context.Entry(solicitacaoServicoMedicaoUnica).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                            
                            await _context.SaveChangesAsync();

                            
                            var ResultMail = SolicitacaoServicoMail.EmailMedicaoUnicaFornecedor(_context, solicitacaoServicoMedicaoUnica.SolicitacaoServicoID, solicitacaoServicoMedicaoUnica.ID);
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
            var SolicitacaoServicoMedicaoUnica = _context.SolicitacaoServicoMedicaoUnica.
                           FirstOrDefault(x =>
                               x.EmpresaID == _empresaId &&
                               x.Habilitado &&
                               x.SolicitacaoServicoID == Id
                               );

            ViewBag.SolicitacaoServicoID = Id;
            ViewBag.SolicitacaoServicoMedicaoUnica = SolicitacaoServicoMedicaoUnica;


            var SolicitacaoServicoFornecedor = _context.SolicitacaoServicoFornecedor.
                          AsNoTracking().
                          FirstOrDefault(x =>
                              x.EmpresaID == _empresaId &&
                              x.Habilitado &&
                              x.SolicitacaoServicoID == Id &&
                              x.Vencedor
                         );

            ViewBag.SolicitacaoServicoCotacaoItem = new List<SolicitacaoServicoCotacaoItem>();

            if (SolicitacaoServicoFornecedor!= null)
            {
                long FornecedorId = SolicitacaoServicoFornecedor.FornecedorID;
                var SolicitacaoServicoCotacaoItem = _context.SolicitacaoServicoCotacaoItem.
                        Include(x => x.SolicitacaoServicoCotacao).
                        Include(x => x.SolicitacaoServicoItem).
                         ThenInclude(x => x.Produto).
                        AsNoTracking().
                        Where(x =>
                             x.SolicitacaoServicoCotacao.EmpresaID == _empresaId &&
                             x.SolicitacaoServicoCotacao.Habilitado &&
                             x.SolicitacaoServicoCotacao.FornecedorID == FornecedorId &&
                             x.SolicitacaoServicoCotacao.SolicitacaoServicoID == Id
                        ).ToList();

                ViewBag.SolicitacaoServicoCotacaoItem = SolicitacaoServicoCotacaoItem;

            }


            

            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                return View("CreateMedicaoFO");
            }
            return View();
        }

  }
}
