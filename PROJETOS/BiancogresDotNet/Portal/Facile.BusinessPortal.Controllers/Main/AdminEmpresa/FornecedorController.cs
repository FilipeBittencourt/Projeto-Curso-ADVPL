using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Facile.BusinessPortal.Model;
using System.Threading.Tasks;
using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Library.Util;
using Microsoft.EntityFrameworkCore;
using System;
using Facile.BusinessPortal.Library;
using System.Collections.Generic;
using System.Linq;
using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.ViewModels;
using System.IO;
using Facile.BusinessPortal.BusinessRules.Util;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("AdminEmpresa")]
    public class FornecedorController : BaseCommonController<Model.Fornecedor>
    {
        public FornecedorController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        public override async Task<IActionResult> Index()
        {
            return View();
        }

        public IActionResult GetFornecedorCNPJ(string q)
        {
            var Result = _context.Fornecedor.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                (x.CPFCNPJ.Contains(q) || x.Nome.Contains(q) || x.RazaoSocial.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 CPFCNPJ = x.CPFCNPJ,
                                 Nome = x.Nome,
                                 RazaoSocial = x.RazaoSocial,
                                 Contato = x.Contato,
                                 Email = x.Email,
                                 Telefone = x.Telefone,
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public IActionResult GetFornecedor(string q)
        {
            var Result = _context.Fornecedor.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                (x.CodigoERP.Contains(q) || x.Nome.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Codigo = x.CodigoERP,
                                 Nome = x.Nome
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
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

            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    //total de registro
                    query = @"  select COUNT(*) from Fornecedor";
                    query += @" where EmpresaId = '" + _empresaId + "' ";

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //Campos para filtro e retorno
                    var cqfields = "ID, CPFCNPJ, CodigoERP, Nome, Email, Bairro, Cidade, UF";

                    //total filtrado
                    query = $@"SELECT COUNT(*) FROM ( 
                                     select {cqfields} from Fornecedor";
                    query += @" where EmpresaId = '" + _empresaId + "' ";
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";

                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    query = $@"SELECT * FROM ( 
                                    select {cqfields} from Fornecedor";
                    query += @" where EmpresaId = '" + _empresaId + "' ";
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
                            CodigoERP = result["CodigoERP"],
                            CPFCNPJ = result["CPFCNPJ"],
                            Nome = result["Nome"],
                            Email = result["Email"],
                            Bairro = result["Bairro"],
                            Cidade = result["Cidade"],
                            UF = result["UF"],
                            EmpresaID = _empresaId
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

        public async Task<IActionResult> SalvarAcoesFIDC()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                try
                {
                    string FornecedorID = Request.Form["FornecedorID"];
                    string FIDCAtivo = Request.Form["FIDCAtivo"];
                    string AntecipaServico = Request.Form["AntecipaServico"];

                    using (var transaction = _context.Database.BeginTransaction())
                    {
                        try
                        {
                            if (string.IsNullOrEmpty(FornecedorID))
                            {
                                transaction.Rollback();
                                return Json(new { Ok = false, Mensagem = "ID do fornecedor não informado." });
                            }

                            long IDFornecedor = Convert.ToInt64(FornecedorID);
                            var Fornecedor = _context.Fornecedor.AsNoTracking().FirstOrDefault(
                                   o => o.ID == IDFornecedor &&
                                   o.EmpresaID == usuario.EmpresaID
                            );

                            if (Fornecedor == null)
                            {
                                transaction.Rollback();
                                return Json(new { Ok = false, Mensagem = "Id Informado não encontrado." });
                            }

                            Fornecedor.FIDCAtivo = FIDCAtivo.Equals("1");
                            Fornecedor.AntecipaServico = AntecipaServico.Equals("1");
                            _context.Entry(Fornecedor).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                            if (Request.Form.Files.Count >= 0)
                            {
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
                                        var o = new FornecedorDocumento();
                                        file.CopyTo(memoryStream);
                                        o.ArquivoAnexo = (memoryStream as MemoryStream).ToArray();
                                        o.NomeAnexo = file.FileName;
                                        o.TipoAnexo = file.ContentType;
                                        o.FornecedorID = IDFornecedor;
                                        o.EmpresaID = _empresaId;
                                        o.InsertDate = DateTime.Now;
                                        o.Habilitado = true;
                                        _context.Add<FornecedorDocumento>(o);
                                    }
                                    i++;
                                }
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
                catch (Exception ex)
                {
                    return Json(new { Ok = false, Mensagem = "Erro interno: " + ex.Message });
                }
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
                var FornecedorDocumento = _context.FornecedorDocumento.FirstOrDefault(
                       o => o.ID == Id &&
                       o.EmpresaID == usuario.EmpresaID
               );

                if (FornecedorDocumento == null)
                {
                    return Json(new { Ok = false, Mensagem = "Id Informado não encontrado." });
                }
                else
                {
                    _context.Set<FornecedorDocumento>().Remove(FornecedorDocumento);
                    await _context.SaveChangesAsync();
                    return Json(new { Ok = true, Mensagem = "" });
                }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        public async Task<IActionResult> GetListAnexo(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                var Result = _context.FornecedorDocumento.Where(o =>
                       o.EmpresaID == usuario.EmpresaID &&
                       o.FornecedorID == Id
               ).Select(x =>
                  new
                  {
                      Nome = x.NomeAnexo,
                      ID = x.ID
                  }
                ).ToList();
                return Json(new { Ok = true, Result = Result, Mensagem = "" });
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        public async Task<IActionResult> SalvarListAnexo(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                var Result = _context.FornecedorDocumento.Include(x=>x.Fornecedor).Where(o =>
                       o.EmpresaID == usuario.EmpresaID &&
                       o.FornecedorID == Id
               ).ToList();


                var PathFIDC = ContextUtil.GetParametroPorChave(_context, "DIRETORIO_PADRAO_ARQUIVO_FIDC", _empresaId) ?? "T:\\Protheus_Data\\P10\\FIDC\\DOCUMENTOS_FORNECEDOR";
                if (PathFIDC != null)
                {
                    foreach (var item in Result)
                    {
                        var NomeArquivo = PathFIDC+"\\"+ DateTime.Now.ToString("ddMMyyyy") + "_" + item.Fornecedor.CPFCNPJ+Path.GetExtension(item.NomeAnexo);

                        if (System.IO.File.Exists(NomeArquivo))
                        {
                            System.IO.File.Delete(NomeArquivo);
                        }
                        using (Stream fileStream = new FileStream(NomeArquivo, FileMode.Create))
                        {
                            MemoryStream stream = new MemoryStream(item.ArquivoAnexo);
                            await stream.CopyToAsync(fileStream);
                        }
                    }

                    return Json(new { Ok = true, Mensagem = "Arquivos salvos no diretório: "+ PathFIDC });
                }
                return Json(new { Ok = false, Mensagem = "Diretório padrão FIDC não encontrado." });

            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        public async Task<IActionResult> GetAcoesFIDC(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                var Result = _context.Fornecedor.Include(x =>x.FornecedorDocumento).Where(o =>
                       o.EmpresaID == usuario.EmpresaID &&
                       o.ID == Id
               ).Select(x =>
                  new
                  {
                      FIDCAtivo = x.FIDCAtivo,
                      AntecipaServico = x.AntecipaServico,
                      Anexo = x.FornecedorDocumento.Select(y=>
                      new {
                          Nome = y.NomeAnexo,
                          ID = y.ID
                      }).ToList()
                  }
                ).FirstOrDefault();
                

                return Json(new { Ok = true, Result = Result, Mensagem = "" });
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        public async Task<IActionResult> GetAnexo(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                var Result = _context.FornecedorDocumento.FirstOrDefault(o =>
                       o.EmpresaID == usuario.EmpresaID &&
                       o.ID == Id
               );

                if (Result != null)
                {
                    return File(Result.ArquivoAnexo, Result.TipoAnexo, Result.NomeAnexo);
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
    }
}
