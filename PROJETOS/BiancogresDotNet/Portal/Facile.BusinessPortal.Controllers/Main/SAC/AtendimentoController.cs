using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using System.Linq;
using System;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using Facile.BusinessPortal.BusinessRules.DAO;
using System.Threading.Tasks;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Util;
using Microsoft.AspNetCore.Mvc.Rendering;
using System.IO;
using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.ViewModels;
using Facile.BusinessPortal.BusinessRules.ResquestToPay.Atendimento;
using System.Text;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("SAC")]
    public class AtendimentoController : BaseCommonController<Atendimento>
    {
        public AtendimentoController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {

        }

        public override async Task<IActionResult> Index()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            
            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                return View("IndexFO");
            }
            return View();
        }

        public async Task<IActionResult> SalvarStatus(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                //  if (usuario.Tipo == TipoUsuario.Fornecedor)
                //  {
                //TUDO valida se do fornecedor logado
                try
                {
                    var Atendimento = _context.Atendimento.FirstOrDefault(
                       o => o.ID == Id &&
                       o.EmpresaID == usuario.EmpresaID
                    );

                    if (Atendimento == null)
                    {
                        return Json(new { Ok = false, Mensagem = "Id Informado não encontrado." });
                    }
                    else
                    {
                        var ResultAtendimentoMedicao = _context.AtendimentoMedicao.Where(x => x.AtendimentoID == Id);
                        if (ResultAtendimentoMedicao.Any())
                        {
                            if (Atendimento.Status == StatusAtendimento.Aguardando)
                            {
                                AtendimentoHistorico atendimentoHistorico = new AtendimentoHistorico();
                                atendimentoHistorico.EmpresaID = _empresaId;
                                atendimentoHistorico.UsuarioID = usuario.ID;
                                atendimentoHistorico.DataEvento = DateTime.Now;
                                atendimentoHistorico.EmpresaID = _empresaId;
                                atendimentoHistorico.Observacao = "Serviço Realizado pelo Fornecedor";
                                atendimentoHistorico.Status = Atendimento.Status;
                                atendimentoHistorico.AtendimentoID = Id;

                                _context.Add<AtendimentoHistorico>(atendimentoHistorico);

                                Atendimento.Status = StatusAtendimento.Concluido;
                                _context.Entry(Atendimento).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                                await _context.SaveChangesAsync();

                                var ResultMail = AtendimentoMail.AtendimentoConcluidoSendMail(_context, Atendimento.ID);
                                if (!ResultMail.Status)
                                {
                                    return Json(new { Ok = false, Mensagem = "Erro envio do e-mail." });
                                }

                                return Json(new { Ok = true, Mensagem = "" });
                            }
                            return Json(new { Ok = false, Mensagem = "Atendimento não esta com Status 'Aguardando Serviço'." });
                        }
                        return Json(new { Ok = false, Mensagem = "É preciso informar anexo para concluir o atendimento." });

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

        public async Task<IActionResult> SalvarAnexo()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        string AtendimentoID = Request.Form["AtendimentoID"];

                        if (string.IsNullOrEmpty(AtendimentoID))
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "ID da Atendimento não informado." });
                        }

                        long IDAtendimento = Convert.ToInt64(AtendimentoID);
                        var Atendimento = _context.Atendimento.AsNoTracking().FirstOrDefault(
                               o => o.ID == IDAtendimento &&
                               o.EmpresaID == usuario.EmpresaID
                        );

                        if (Atendimento == null)
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Atendimento não encontrada." });
                        }

                        if (Atendimento.Status != StatusAtendimento.Aguardando)
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Atendimento não esta com Status 'Aguardando Serviço'." });
                        }

                        if (Request.Form.Files.Count == 0)
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Não foi informado nenhum arquivo." });
                        }

                        List<AtendimentoMedicao> Lista = new List<AtendimentoMedicao>();
                        string[] Descricao = Request.Form["Descricao"];

                        int i = 0;
                        foreach (var file in Request.Form.Files)
                        {
                            if (file.Length == 0)
                            {
                                transaction.Rollback();
                                return Json(new { Ok = false, Mensagem = "Erro no arquivo anexado." });
                            }

                            using (var memoryStream = new MemoryStream())
                            {
                                var o = new AtendimentoMedicao();
                                file.CopyTo(memoryStream);
                                o.Arquivo = (memoryStream as MemoryStream).ToArray();
                                o.Descricao = Descricao[i];
                                o.Nome = file.FileName;
                                o.Tipo = file.ContentType;
                                o.AtendimentoID = IDAtendimento;
                                o.EmpresaID = _empresaId;
                                o.InsertDate = DateTime.Now;
                                o.Habilitado = true;
                                _context.Add<AtendimentoMedicao>(o);
                            }
                            i++;
                        }
                        await _context.SaveChangesAsync();

                        transaction.Commit();
                        return Json(new { Ok = true, Mensagem = "" });
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

        public async Task<IActionResult> RemoverAnexo(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
              //  if (usuario.Tipo == TipoUsuario.Fornecedor)
              //  {
                    //TUDO valida se do fornecedor logado
                    var AtendimentoMedicao = _context.AtendimentoMedicao.FirstOrDefault(
                           o => o.ID == Id &&
                           o.EmpresaID == usuario.EmpresaID
                   );
                   
                   if (AtendimentoMedicao == null)
                   {
                        return Json(new { Ok = false, Mensagem = "Id Informado não encontrado." });
                   } 
                   else
                   {
                        _context.Set<AtendimentoMedicao>().Remove(AtendimentoMedicao);
                        await _context.SaveChangesAsync();
                        return Json(new { Ok = true, Mensagem = "" });
                   } 

              //  }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        public async Task<IActionResult> GetListAnexoAtendimento(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                
                //TUDO valida se do fornecedor logado
                var Result = _context.AtendimentoMedicao.Where(o=>
                       o.EmpresaID == usuario.EmpresaID &&
                       o.AtendimentoID == Id
               ).Select(x=>
                  new
                  {
                      Nome = x.Nome,
                      Descricao = x.Descricao,
                      ID = x.ID
                  } 
                ).ToList();
                return Json(new { Ok = true, Result = Result, Mensagem = "" });
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        public async Task<IActionResult> GetAnexoAtendimento(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {

                //TUDO valida se do fornecedor logado
                var Result = _context.AtendimentoMedicao.FirstOrDefault(o =>
                       o.EmpresaID == usuario.EmpresaID &&
                       o.ID == Id
               );

                if (Result != null)
                {
                    return File(Result.Arquivo, Result.Tipo, Result.Nome);
                } else
                {
                    HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, "Anexo não encontrado", ControllerContext));
                    return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
                }
            }
            HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, "Usuário não encontrado", ControllerContext));
            return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
        }

        public async Task<IActionResult> GetTermo(long Id)
        {
            try
            {
                Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
                if (usuario != null)
                {

                    //TUDO valida se do fornecedor logado
                    var Result = _context.Atendimento.FirstOrDefault(o =>
                           o.EmpresaID == usuario.EmpresaID &&
                           o.ID == Id
                   );

                    if (Result != null && Result.Termo != null)
                    {
                        return File(Result.Termo.ToArray(), "application/pdf", "TERMO_" + Result.Numero + ".PDF");
                    }
                    else
                    {
                        HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, "Termo não encontrado", ControllerContext));
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


        public IActionResult DataTable()
        {
            var draw = Request.Form["draw"].FirstOrDefault();
            var start = Request.Form["start"].FirstOrDefault();
            var length = Request.Form["length"].FirstOrDefault();
            var sortColumn = Request.Form["order[0][column]"].FirstOrDefault();
            var sortColumnDir = Request.Form["order[0][dir]"].FirstOrDefault();
            var searchValue = Request.Form["search[value]"].FirstOrDefault();
            var fieldSearch = Request.Form["FieldSearch"].FirstOrDefault();


            int pageSize = length != null ? Convert.ToInt32(length) : 0;
            int skip = start != null ? Convert.ToInt32(start) : 0;
            int orderby = sortColumn != null ? Convert.ToInt32(sortColumn) + 1 : 1;

            int recordsTotal = 0;
            int recordsFiltered = 0;
            string query = "";
            List<dynamic> data = new List<dynamic>();

            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);

            string queryFiltroUsuario = "";
            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                var ResultUsuarioFornecedor = _context.UsuarioFornecedor.FirstOrDefault(x => x.UsuarioID == usuario.ID && x.EmpresaID == _empresaId);
                if (ResultUsuarioFornecedor != null)
                {
                    var FornecedorId = ResultUsuarioFornecedor.FornecedorID;
                    queryFiltroUsuario += " AND Fornecedor.ID = '" + FornecedorId + "'";
                }
            }


            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    //total de registro
                    query = @"select COUNT(*)
                                from Atendimento
                                JOIN Unidade ON Unidade.ID = Atendimento.UnidadeId
                                JOIN Fornecedor ON Fornecedor.ID = Atendimento.FornecedorID ";
                    query += @" where Atendimento.EmpresaId = '" + _empresaId + "' AND Atendimento.Deletado = 0";
                    query += queryFiltroUsuario;

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //Campos para filtro e retorno
                    var cqfields = @"
                                    ID = Atendimento.ID,
                                    Numero = Atendimento.Numero,
                                    NomeFornecedor= Fornecedor.Nome+' - '+Fornecedor.CodigoERP,
                                    NomeReclamante = Atendimento.NomeReclamante,
                                    NomeProduto = Atendimento.NomeProduto,
                                    Quantidade = Atendimento.QuantidadeProduto,
                                   Status = CASE  Status
	                                        WHEN 0 THEN 'Aguardando Serviço' 
	                                        WHEN 1 THEN 'Serviço Realizado' 
	                                        WHEN 2 THEN 'Finalizado' 	 
	                                        ELSE 'Reprovada' 
                                        END
                                    ";

                    //total filtrado
                    query = $@"SELECT COUNT(*) FROM ( 
                                   select {cqfields}
                                     from Atendimento
                                JOIN Unidade ON Unidade.ID = Atendimento.UnidadeId
                                JOIN Fornecedor ON Fornecedor.ID = Atendimento.FornecedorID ";
                    query += @" where Atendimento.EmpresaId = '" + _empresaId + "' AND Atendimento.Deletado = 0 ";
                    query += queryFiltroUsuario;
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";

                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    query = $@"SELECT * FROM ( 
                                select 
                                    {cqfields}
                                   from Atendimento
                                JOIN Unidade ON Unidade.ID = Atendimento.UnidadeId
                                JOIN Fornecedor ON Fornecedor.ID = Atendimento.FornecedorID  ";

                    query += @" where Atendimento.EmpresaId = '" + _empresaId + "' AND Atendimento.Deletado = 0 ";
                    query += queryFiltroUsuario;
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";
                    query += @" ORDER BY " + orderby + " " + sortColumnDir + ((pageSize != -1) ? " OFFSET " + (skip) + " ROWS FETCH NEXT " + (pageSize) + " ROWS ONLY" : "");

                    command.CommandText = query;
                    var result = command.ExecuteReader();

                    while (result.Read())
                    {
                        data.Add(new
                        {
                            Id = result["ID"],
                            Numero = result["Numero"],
                            NomeFornecedor = result["NomeFornecedor"],
                            NomeReclamante = result["NomeReclamante"],
                            NomeProduto = result["NomeProduto"],
                            Quantidade = result["Quantidade"],
                            Status = result["Status"]
                        });
                    }
                }
                finally
                {
                    if (_context.Database.GetDbConnection().State == System.Data.ConnectionState.Open)
                    {
                        _context.Database.CloseConnection();
                    }
                }

            }

            return Json(new { draw, recordsFiltered, recordsTotal, data });
        }
    }
}
