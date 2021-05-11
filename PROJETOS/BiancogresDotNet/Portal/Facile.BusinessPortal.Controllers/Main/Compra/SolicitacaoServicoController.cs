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
    public class SolicitacaoServicoController : BaseCommonController<Model.Compra.Servico.SolicitacaoServico>
    {
        public SolicitacaoServicoController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {

        }

        protected override void LoadViewBag()
        {
            ViewBag.NomeModelo = typeof(Model.Compra.Servico.SolicitacaoServico).Name;
            ViewBag.ListaPrioridadeServico = _context.PrioridadeServico.
                            Where(x => x.EmpresaID == _empresaId && x.Habilitado).
                            Select(x => new SelectListItem()
                            {
                                Value = x.ID.ToString(),
                                Text = x.Codigo + " - " + x.Descricao
                            }).OrderBy(x => x.Text);

            ViewBag.ListaClasseValor = _context.ClasseValor.
                            Where(x => x.EmpresaID == _empresaId && x.Habilitado).
                            Select(x => new SelectListItem()
                            {
                                Value = x.ID.ToString(),
                                Text = x.Codigo + " - " + x.Descricao
                            }).OrderBy(x => x.Text);

            ViewBag.ListaAplicacaoServico = _context.Aplicacao.
                            Where(x => x.EmpresaID == _empresaId && x.Habilitado).
                            Select(x => new SelectListItem()
                            {
                                Value = x.ID.ToString(),
                                Text = x.Codigo + " - " + x.Descricao
                            }).OrderBy(x => x.Text);


            ViewBag.ListaArmazemServico = _context.Armazem.
                            Where(x => x.EmpresaID == _empresaId && x.Habilitado).
                            Select(x => new SelectListItem()
                            {
                                Value = x.ID.ToString(),
                                Text = x.Codigo
                            }).OrderBy(x => x.Text);

            ViewBag.Unidades = _context.Unidade.
                            Where(x => x.EmpresaID == _empresaId && x.Habilitado).
                            Select(x => new SelectListItem()
                            {
                                Value = x.ID.ToString(),
                                Text = x.Codigo + " - " + x.Nome
                            }).OrderBy(x => x.Text);

        }

        protected override void LoadViewBag(Model.Compra.Servico.SolicitacaoServico o)
        {
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public override async Task<IActionResult> Details(long? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var myObject = await _context.Set<Model.Compra.Servico.SolicitacaoServico>().SingleOrDefaultAsync(m => m.ID == id);
            if (myObject == null)
            {
                return NotFound();

            }
            
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                return View("DetailsFO",myObject);
            }
            return View(myObject);

        }

        public override async Task<IActionResult> Index()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);

            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                return  View("IndexFO");
            }
            return View();
        }

        public async Task<IActionResult> IndexHistorico(long? id)
        {
            var Result = new List<SolicitacaoServicoHistorico>();
            if (id != null)
            {
                Result = _context.Set<SolicitacaoServicoHistorico>().Where(x => x.SolicitacaoServicoID == id.Value).ToList();
            }

            return View(Result);
        }


        public override IActionResult Create()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario.Tipo == TipoUsuario.AdminEmpresa)
            {
                LoadViewBag();
                return View();
            }
            HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Access, "Usuário invalido para operação.", ControllerContext));
            return new RedirectToActionResult("Index", "Error", null);
        }


        public override async Task<IActionResult> Create(Model.Compra.Servico.SolicitacaoServico o)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario.Tipo == TipoUsuario.AdminEmpresa)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        
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
                        
                        if (o.TipoVisita != TipoVisita.UNICA)
                        {
                            o.DataHoraVisita = null;
                        }

                        o.InsertUser = _userId;
                        o.EmpresaID = _empresaId;
                        o.UsuarioID = _usuario.ID;
                        o.InsertDate = DateTime.Now;
                       // o.UnidadeID = 4;//TODO REMOVER
                        o.Habilitado = true;

                        if (o.SolicitacaoServicoItem != null)
                        {
                            for (int i = 0; i < o.SolicitacaoServicoItem.Count; i++)
                            {
                                o.SolicitacaoServicoItem.ElementAt(i).EmpresaID = _empresaId;
                                o.SolicitacaoServicoItem.ElementAt(i).Habilitado = true;
                                o.SolicitacaoServicoItem.ElementAt(i).Item = (i + 1).ToString().PadLeft(4, '0');
                                if (o.TipoServico != TipoServico.Contrato)
                                {
                                    o.SolicitacaoServicoItem.ElementAt(i).DataInicioContrato = null;
                                    o.SolicitacaoServicoItem.ElementAt(i).DataFinalContrato = null;
                                }
                            }
                        }

                        if (o.SolicitacaoServicoFornecedor != null)
                        {
                            for (int i = 0; i < o.SolicitacaoServicoFornecedor.Count; i++)
                            {
                                o.SolicitacaoServicoFornecedor.ElementAt(i).EmpresaID = _empresaId;
                                o.SolicitacaoServicoFornecedor.ElementAt(i).Habilitado = true;
                            }
                        }

                        
                        _context.Add(o);
                        await _context.SaveChangesAsync();

                        o.Numero = "SS-" + o.ID.ToString().PadLeft(7, '0');
                        
                        if (o.UsuarioOrigemID != 0) 
                        {
                            SolicitacaoServicoMail.EmailSolicitanteOrigem(_context, o.ID);
                        }
                        if (o.UsuarioMedicaoID != 0)
                        {
                            SolicitacaoServicoMail.EmailUsuarioMedicao(_context, o.ID);
                        }

                        _context.Add<SolicitacaoServicoHistorico>(new SolicitacaoServicoHistorico
                        { 
                            EmpresaID = _empresaId,
                            UsuarioID = _usuario.ID,
                            SolicitacaoServicoID = o.ID,
                            DataEvento = DateTime.Now,
                            Observacao = "Inclusão solicitação de serviço"
                        });

                        await _context.SaveChangesAsync();
                        transaction.Commit();
                        return RedirectToAction(nameof(Index));
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, ex.Message, ControllerContext));
                        return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
                    }
                }
            }
            HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Access, "Usuário invalido para operação.", ControllerContext));
            return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public override async Task<IActionResult> Edit(int id, Model.Compra.Servico.SolicitacaoServico o)
        {
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    var dbObj = _context.Set<SolicitacaoServico>().FirstOrDefault(x => x.ID == o.ID);
                    if (dbObj != null && dbObj.Status == StatusSolicitacaoServico.Aguardando)
                    {
                        o.Numero = dbObj.Numero;
                        o.EmpresaID = dbObj.EmpresaID;
                        o.UsuarioID = _usuario.ID;
                        //o.UnidadeID = dbObj.UnidadeID;
                        o.Habilitado = dbObj.Habilitado;
                        o.Usuario = dbObj.Usuario;

                        var SolicitacaoServicoItem = new List<SolicitacaoServicoItem>();
                        var SolicitacaoServicoFornecedor = new List<SolicitacaoServicoFornecedor>();

                        if (o.SolicitacaoServicoItem != null)
                        {
                            SolicitacaoServicoItem = o.SolicitacaoServicoItem.Select(x => x).ToList();
                            o.SolicitacaoServicoItem.Clear();
                        }

                        if (o.SolicitacaoServicoFornecedor != null)
                        {
                            SolicitacaoServicoFornecedor = o.SolicitacaoServicoFornecedor.Select(x => x).ToList();
                            o.SolicitacaoServicoFornecedor.Clear();
                        }

                        CopyCommomPropeties(o, dbObj);
                        _context.Entry(dbObj).State = EntityState.Modified;
                        dbObj.LastEditDate = DateTime.Now;
                        dbObj.LastEditUser = _userId;
                        dbObj.Habilitado = true;

                        if (Request.Form.Files.Count == 1)
                        {
                            var file = Request.Form.Files[0];
                            if (file.Length > 0)
                            {
                                using (var memoryStream = new MemoryStream())
                                {
                                    file.CopyTo(memoryStream);
                                    dbObj.ArquivoAnexo = (memoryStream as MemoryStream).ToArray();
                                    dbObj.NomeAnexo = file.FileName;
                                    dbObj.TipoAnexo = file.ContentType;
                                }
                            }
                        }

                        if (o.TipoVisita != TipoVisita.UNICA)
                        {
                            dbObj.DataHoraVisita = null;
                        }
                        _context.Update(dbObj);

                        _context.SolicitacaoServicoItem.RemoveRange(_context.SolicitacaoServicoItem.Where(X => X.SolicitacaoServicoID == dbObj.ID));
                        if (SolicitacaoServicoItem != null)
                        {
                            for (int i = 0; i < SolicitacaoServicoItem.Count; i++)
                            {
                                SolicitacaoServicoItem.ElementAt(i).SolicitacaoServico = null;
                                SolicitacaoServicoItem.ElementAt(i).SolicitacaoServicoID = o.ID;
                                SolicitacaoServicoItem.ElementAt(i).EmpresaID = _empresaId;
                                SolicitacaoServicoItem.ElementAt(i).Habilitado = true;
                                SolicitacaoServicoItem.ElementAt(i).Item = (i + 1).ToString().PadLeft(4, '0');
                                if (o.TipoServico != TipoServico.Contrato)
                                {
                                    SolicitacaoServicoItem.ElementAt(i).DataInicioContrato = null;
                                    SolicitacaoServicoItem.ElementAt(i).DataFinalContrato = null;
                                }
                                SolicitacaoServicoItem.ElementAt(i).ID = 0;
                                _context.Add<Model.Compra.Servico.SolicitacaoServicoItem>(SolicitacaoServicoItem.ElementAt(i));
                            }
                        }
                        _context.SolicitacaoServicoFornecedor.RemoveRange(_context.SolicitacaoServicoFornecedor.Where(X => X.SolicitacaoServicoID == dbObj.ID));
                        if (SolicitacaoServicoFornecedor != null)
                        {
                            for (int i = 0; i < SolicitacaoServicoFornecedor.Count; i++)
                            {
                                SolicitacaoServicoFornecedor.ElementAt(i).SolicitacaoServico = null;
                                SolicitacaoServicoFornecedor.ElementAt(i).SolicitacaoServicoID = o.ID;
                                SolicitacaoServicoFornecedor.ElementAt(i).EmpresaID = _empresaId;
                                SolicitacaoServicoFornecedor.ElementAt(i).Habilitado = true;
                                SolicitacaoServicoFornecedor.ElementAt(i).ID = 0;

                                _context.Add<Model.Compra.Servico.SolicitacaoServicoFornecedor>(SolicitacaoServicoFornecedor.ElementAt(i));
                            }
                        }

                        if (o.UsuarioOrigemID != 0)
                        {
                            SolicitacaoServicoMail.EmailSolicitanteOrigem(_context, o.ID);
                        }
                        if (o.UsuarioMedicaoID != 0)
                        {
                            SolicitacaoServicoMail.EmailUsuarioMedicao(_context, o.ID);
                        }

                        _context.Add<SolicitacaoServicoHistorico>(new SolicitacaoServicoHistorico
                        {
                            EmpresaID = _empresaId,
                            UsuarioID = _usuario.ID,
                            SolicitacaoServicoID = o.ID,
                            DataEvento = DateTime.Now,
                            Observacao = "Edição solicitação de serviço"
                        });

                        await _context.SaveChangesAsync();
                        transaction.Commit();
                        return RedirectToAction(nameof(Index));
                    }
                    transaction.Rollback();
                    HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Access, "Solicitação de serviço não encontrado/Status solicitação do serviço não está aguardando.", ControllerContext));
                    return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, ex.Message, ControllerContext));
                    return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
                }
            }
        }

       
        public async Task<IActionResult> GetEscopo(long Id)
        {
            try
            {
                Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
                if (usuario != null)
                {

                    //TUDO valida se do fornecedor logado
                    var Result = _context.SolicitacaoServico.FirstOrDefault(o =>
                           o.EmpresaID == usuario.EmpresaID &&
                           o.ID == Id
                   );

                    if (Result != null && Result.ArquivoAnexo != null)
                    {
                        return File(Result.ArquivoAnexo.ToArray(), Result.TipoAnexo, Result.NomeAnexo);
                    }
                    else
                    {
                        HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, "Escopo não encontrado", ControllerContext));
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

   
        public async Task<IActionResult> IntegracaoBizagi(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                //  if (usuario.Tipo == TipoUsuario.Fornecedor)
                //  {
                //TUDO valida se do fornecedor logado
                try
                {
                    
                    var SolicitacaoServico = _context.SolicitacaoServico.FirstOrDefault(
                       o =>
                       o.EmpresaID == usuario.EmpresaID &&
                       o.ID == Id
                    );

                    _context.Add<SolicitacaoServico>(SolicitacaoServico);

                    SolicitacaoServico.Status = StatusSolicitacaoServico.LiberadoIntegracao;
                    _context.Entry(SolicitacaoServico).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                    _context.Add<SolicitacaoServicoHistorico>(new SolicitacaoServicoHistorico
                    {
                        EmpresaID = _empresaId,
                        UsuarioID = _usuario.ID,
                        SolicitacaoServicoID = SolicitacaoServico.ID,
                        DataEvento = DateTime.Now,
                        Observacao = "Liberado integração bizagi"
                    });

                    await _context.SaveChangesAsync();
                    return Json(new { Ok = true, Mensagem = "E-mail enviado com sucesso." });
                }
                catch (Exception ex)
                {
                    return Json(new { Ok = false, Mensagem = "Erro interno: " + ex.Message });
                }


                //  }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        public async Task<IActionResult> EnviarEmailFornecedor(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                //  if (usuario.Tipo == TipoUsuario.Fornecedor)
                //  {
                //TUDO valida se do fornecedor logado
                try
                {
                    var Lista = _context.SolicitacaoServicoFornecedor.Where(
                       o => 
                       o.EmpresaID == usuario.EmpresaID &&
                       o.SolicitacaoServicoID == Id
                    );

                    foreach(var item in Lista)
                    {
                        var ResultMail = SolicitacaoServicoMail.NovaSolicitacaoServicoFornecedorSendMail(_context, item.ID);
                        if (!ResultMail.Status)
                        {
                            return Json(new { Ok = false, Mensagem = "Erro envio do e-mail." });
                        }
                    }

                    var SolicitacaoServico = _context.SolicitacaoServico.FirstOrDefault(
                       o =>
                       o.EmpresaID == usuario.EmpresaID &&
                       o.ID == Id
                    );

                    _context.Add<SolicitacaoServico>(SolicitacaoServico);

                    SolicitacaoServico.Status = StatusSolicitacaoServico.LiberadoFornecedor;
                    _context.Entry(SolicitacaoServico).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                    _context.Add<SolicitacaoServicoHistorico>(new SolicitacaoServicoHistorico
                    {
                        EmpresaID = _empresaId,
                        UsuarioID = _usuario.ID,
                        SolicitacaoServicoID = SolicitacaoServico.ID,
                        DataEvento = DateTime.Now,
                        Observacao = "Enviado e-mail para os fornecedores"
                    });

                    await _context.SaveChangesAsync();
                    return Json(new { Ok = true, Mensagem = "E-mail enviado com sucesso." });
                }
                catch (Exception ex)
                {
                    return Json(new { Ok = false, Mensagem = "Erro interno: " + ex.Message });
                }


                //  }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }


        public async Task<IActionResult> LiberarIntegracaoBizagi(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                //  if (usuario.Tipo == TipoUsuario.Fornecedor)
                //  {
                //TUDO valida se do fornecedor logado
                try
                {
                    

                    var SolicitacaoServico = _context.SolicitacaoServico.FirstOrDefault(
                       o =>
                       o.EmpresaID == usuario.EmpresaID &&
                       o.ID == Id
                    );

                    if (SolicitacaoServico != null )
                    {
                        if (SolicitacaoServico.Status == StatusSolicitacaoServico.Aguardando)
                        {
                            _context.Add<SolicitacaoServico>(SolicitacaoServico);

                            SolicitacaoServico.Status = StatusSolicitacaoServico.LiberadoIntegracao;
                            _context.Entry(SolicitacaoServico).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                            await _context.SaveChangesAsync();
                            return Json(new { Ok = true, Mensagem = "Integração liberada com sucesso." });
                        }
                        return Json(new { Ok = false, Mensagem = "Status da solicitação de serviço diferente de 'Aguardando'." });
                    }
                    return Json(new { Ok = false, Mensagem = "Solicitação de serviço não encontrada." });

                }
                catch (Exception ex)
                {
                    return Json(new { Ok = false, Mensagem = "Erro interno: " + ex.Message });
                }


                //  }
            }
            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }

        /*public async Task<IActionResult> SalvarAgendaFornecedor()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                long FornecedorId = 0;
                if (usuario.Tipo == TipoUsuario.Fornecedor)
                {
                    var ResultUsuarioFornecedor = _context.UsuarioFornecedor.FirstOrDefault(x => x.UsuarioID == usuario.ID && x.EmpresaID == _empresaId);
                    if (ResultUsuarioFornecedor != null)
                    {
                        FornecedorId = ResultUsuarioFornecedor.FornecedorID;
                    }
                }

                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        string SolicitacaoServicoID = Request.Form["SolicitacaoServicoID"];
                        string Data = Request.Form["DataVisita"];

                        if (string.IsNullOrEmpty(SolicitacaoServicoID))
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "ID da Solicitação de Serviço não informado." });
                        }

                        if (string.IsNullOrEmpty(Data))
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Data Visita não informado." });
                        }


                        long IDSolicitacaoServico = Convert.ToInt64(SolicitacaoServicoID);
                        

                        var SolicitacaoServicoFornecedor = _context.SolicitacaoServicoFornecedor.FirstOrDefault(x => 
                            x.SolicitacaoServicoID == IDSolicitacaoServico &&
                            x.EmpresaID == usuario.EmpresaID &&
                            x.FornecedorID == FornecedorId
                            );

                        if (SolicitacaoServicoFornecedor != null)
                        {
                            _context.Add<SolicitacaoServicoFornecedor>(SolicitacaoServicoFornecedor);

                            SolicitacaoServicoFornecedor.DataHoraVisita = Convert.ToDateTime(Data); 
                            _context.Entry(SolicitacaoServicoFornecedor).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                        }

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
        }*/

        [HttpPost]
        public async Task<IActionResult> NovoFornecedor(Fornecedor o)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                      if (o != null)
                      {
                            var Fornecedor = _context.Fornecedor.AsNoTracking().FirstOrDefault(
                               x => x.CPFCNPJ.Equals(o.CPFCNPJ) &&
                               x.EmpresaID == usuario.EmpresaID
                            );

                            if (Fornecedor == null)
                            {
                                o.EmpresaID = _empresaId;
                                o.Habilitado = true;
                                o.StatusIntegracao = 0;
                                _context.Add<Fornecedor>(o);
                                await _context.SaveChangesAsync();
                                transaction.Commit();
                                return Json(new { Ok = true, Mensagem = "" });
                            }
                            return Json(new { Ok = true, Mensagem = "CNPJ já cadastrado." });
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
            if (usuario != null )
            {
                queryFiltroUsuario += " and (UsuarioID = '" + usuario.ID + "' Or  UsuarioMedicaoID = '" + usuario.ID + "' Or  UsuarioOrigemID = '" + usuario.ID + "' )";
            }


            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    //total de registro
                    query = @"select COUNT(*)
                                from SolicitacaoServico
                                LEFT JOIN Usuario U_ORI ON U_ORI.ID = UsuarioOrigemID
                                ";
                  //  JOIN Unidade ON Unidade.ID = SolicitacaoServico.UnidadeId
                    query += @" where SolicitacaoServico.EmpresaId = '" + _empresaId + "' AND SolicitacaoServico.Deletado = 0";
                    query += queryFiltroUsuario;

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //Campos para filtro e retorno
                    var cqfields = @"
                                    ID = SolicitacaoServico.ID,
                                    Numero = SolicitacaoServico.Numero,
                                   DataEmissao=CONVERT(varchar, SolicitacaoServico.InsertDate, 103), 
                                    NomeSolicitanteReal = U_ORI.Nome,
                                    DataNecessidade=CONVERT(varchar, DataNecessidade, 103),
                                    Descricao,
                                    TipoVisita = CASE  TipoVisita
                                            WHEN 0 THEN 'Sem Visita' 
	                                        WHEN 1 THEN 'Unica' 
	                                        WHEN 2 THEN 'Individual' 
	                                        ELSE '' 
                                        END,
                                    TipoServico = CASE  TipoServico
	                                        WHEN 1 THEN 'Contrato' 
	                                        WHEN 2 THEN 'Pedido' 
	                                        ELSE '' 
                                        END,
                                    Status = CASE  Status
	                                        WHEN 0 THEN 'Aguardando' 
                                            WHEN 1 THEN 'Liberado Integração'     
	                                        WHEN 2 THEN 'Integrado Bizagi' 
                                            WHEN 3 THEN 'Aprovado Bizagi' 
                                            WHEN 4 THEN 'Reprovado Bizagi' 
                                            WHEN 5 THEN 'Liberado Fornecedor' 
                                            WHEN 6 THEN 'Cotação Incluida' 
	                                        ELSE '' 
                                        END,
                                    DataVisita=CASE WHEN  DataHoraVisita is not null then CONVERT(varchar, DataHoraVisita, 103)+' ' + CONVERT(VARCHAR, DataHoraVisita, 108)  else '' END,
                                    QuantFornecedor= (select count(*) from SolicitacaoServicoFornecedor SSF where SSF.SolicitacaoServicoID = SolicitacaoServico.ID)
                                    ";


                      //total filtrado
                      query = $@"SELECT COUNT(*) FROM ( 
                                   select {cqfields}
                                     from SolicitacaoServico
                                     LEFT JOIN Usuario U_ORI ON U_ORI.ID = UsuarioOrigemID   
                                ";
                    //JOIN Unidade ON Unidade.ID = SolicitacaoServico.UnidadeId
                    query += @" where SolicitacaoServico.EmpresaId = '" + _empresaId + "' AND SolicitacaoServico.Deletado = 0 ";
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
                                   from SolicitacaoServico
                                   LEFT JOIN Usuario U_ORI ON U_ORI.ID = UsuarioOrigemID 
                                ";
                    //JOIN Unidade ON Unidade.ID = SolicitacaoServico.UnidadeId 
                    query += @" where SolicitacaoServico.EmpresaId = '" + _empresaId + "' AND SolicitacaoServico.Deletado = 0 ";
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
                            DataEmissao = result["DataEmissao"],
                            NomeSolicitanteReal = result["NomeSolicitanteReal"],
                            DataNecessidade = result["DataNecessidade"],
                            TipoVisita = result["TipoVisita"],
                            TipoServico = result["TipoServico"],
                            Status = result["Status"],
                            DataVisita = result["DataVisita"],
                            QuantFornecedor = result["QuantFornecedor"],
                            Descricao = result["Descricao"],

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


        public IActionResult DataTableFornecedor()
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
            long FornecedorId = 0;
            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                var ResultUsuarioFornecedor = _context.UsuarioFornecedor.FirstOrDefault(x => x.UsuarioID == usuario.ID && x.EmpresaID == _empresaId);
                if (ResultUsuarioFornecedor != null)
                {
                    FornecedorId = ResultUsuarioFornecedor.FornecedorID;
                    queryFiltroUsuario += " and exists (                                        ";
                    queryFiltroUsuario += " select 1 from SolicitacaoServicoFornecedor where    ";
                    queryFiltroUsuario += " FornecedorID = '" + FornecedorId + "' AND           ";
                    queryFiltroUsuario += " SolicitacaoServicoID = SS.ID        ";
                    queryFiltroUsuario += " )                                                   ";
                }
            }

            


            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    //total de registro
                    query = @"select COUNT(*)
                                from SolicitacaoServico SS
                                JOIN Usuario ON Usuario.ID = SS.UsuarioID
                                LEFT JOIN Usuario U_ORI ON U_ORI.ID = SS.UsuarioOrigemID ";
                    //JOIN Unidade ON Unidade.ID = SolicitacaoServico.UnidadeId
                    query += @" where SS.EmpresaId = '" + _empresaId + "' AND SS.Deletado = 0  AND Status != 0";
                     query += queryFiltroUsuario;

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //Campos para filtro e retorno
                    var cqfields = @"
                                    ID = SS.ID,
                                    Numero = SS.Numero,
                                     DataEmissao=CONVERT(varchar, SS.InsertDate, 103), 
                                    NomeSolicitante = Usuario.Nome,
                                    NomeSolicitanteReal = U_ORI.Nome,
                                    DataNecessidade=CONVERT(varchar, DataNecessidade, 103),
 Descricao,
                                    TipoVisita = CASE  TipoVisita
	                                        WHEN 0 THEN 'Sem Visita' 
	                                        WHEN 1 THEN 'Unica' 
	                                        WHEN 2 THEN 'Individual' 
	                                        ELSE '' 
                                        END,
                                    TipoServico = CASE  TipoServico
	                                        WHEN 1 THEN 'Contrato' 
	                                        WHEN 2 THEN 'Pedido' 
	                                        ELSE '' 
                                        END,
                                    Status = CASE  Status
	                                        WHEN 0 THEN 'Aguardando' 
                                            WHEN 1 THEN 'Liberado Integração'     
	                                        WHEN 2 THEN 'Integrado Bizagi' 
                                            WHEN 3 THEN 'Aprovado Bizagi' 
                                            WHEN 4 THEN 'Reprovado Bizagi' 
                                            WHEN 5 THEN 'Liberado Fornecedor' 
                                            WHEN 6 THEN 'Cotação Incluida' 
	                                        ELSE '' 
                                        END,
                                              DataVisita=CASE WHEN  SS.DataHoraVisita is not null then CONVERT(varchar, SS.DataHoraVisita, 103)+' ' + CONVERT(VARCHAR, SS.DataHoraVisita, 108)  else '' END,
                                        Vencedor

                                    ";
                   

                    //total filtrado
                    query = $@"SELECT COUNT(*) FROM ( 
                                   select {cqfields}
                                     from SolicitacaoServico SS
                                JOIN Usuario ON Usuario.ID = SS.UsuarioID
                                LEFT JOIN Usuario U_ORI ON U_ORI.ID = SS.UsuarioOrigemID";
                   
                    query += " JOIN SolicitacaoServicoFornecedor SSF ON  SSF.SolicitacaoServicoID = SS.ID AND SSF.FornecedorID = '" + FornecedorId + "'";
                    
                    //JOIN Unidade ON Unidade.ID = SolicitacaoServico.UnidadeId
                    query += @" where SS.EmpresaId = '" + _empresaId + "' AND SS.Deletado = 0  AND Status != 0";
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
                                   from SolicitacaoServico SS
                                JOIN Usuario ON Usuario.ID = SS.UsuarioID
                                LEFT JOIN Usuario U_ORI ON U_ORI.ID = SS.UsuarioOrigemID ";
                    //JOIN Unidade ON Unidade.ID = SolicitacaoServico.UnidadeId 
                    query += " JOIN SolicitacaoServicoFornecedor SSF ON  SSF.SolicitacaoServicoID = SS.ID AND SSF.FornecedorID = '" + FornecedorId + "'";

                    query += @" where SS.EmpresaId = '" + _empresaId + "' AND SS.Deletado = 0  AND Status != 0";
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
                            DataEmissao = result["DataEmissao"],
                            Numero = result["Numero"],
                            DataNecessidade = result["DataNecessidade"],
                            NomeSolicitante = result["NomeSolicitante"],
                            NomeSolicitanteReal = result["NomeSolicitanteReal"],
                            ContatoSolicitante = "",
                            TipoVisita = result["TipoVisita"],
                            TipoServico = result["TipoServico"],
                            Status = result["Status"],
                            DataVisita = result["DataVisita"],
                            Vencedor = result["Vencedor"],
                            Descricao = result["Descricao"],

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
