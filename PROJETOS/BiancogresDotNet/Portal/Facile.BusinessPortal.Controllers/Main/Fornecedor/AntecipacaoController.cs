using Facile.BusinessPortal.BusinessRules;
using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.BusinessRules.Util;
using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("Fornecedor")]
    public class AntecipacaoController : BaseCommonController<Antecipacao>
    {
        public AntecipacaoController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
            
        }

        public override async Task<IActionResult> Index()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            ViewBag.TipoUsuario = (usuario.Tipo == TipoUsuario.Fornecedor)?1:2;

            ViewBag.FiltroStatus = "";
            if (HttpContext.Session.GetInt32("RedirectHome") != null)
            {
                HttpContext.Session.Remove("RedirectHome");
                if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                {
                    ViewBag.FiltroStatus = LibraryUtil.GetDescricaoStatusAntecipacao(StatusAntecipacao.AguardandoParecerEmpresa);
                }
            }

            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                return View("IndexFO");
            }
            return View();
        }

        public async Task<IActionResult> Cancel(long Id)
        {
            try
            {
                if (Id != 0)
                {
                    Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
                    if (usuario != null)
                    {
                        if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                        {
                            var antecipacao = _context.Antecipacao.FirstOrDefault(o => o.ID == Id && o.EmpresaID == usuario.EmpresaID);

                           // if (antecipacao.Status == StatusAntecipacao.Aprovada)//caso já tiver sido aprovado
                            {
                                CreateHistorico(Id, usuario.ID, "Cancelamento interno antecipação", StatusAntecipacao.Cancelada);

                                antecipacao.Status = StatusAntecipacao.Cancelada;
                                _context.Entry(antecipacao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                                _context.SaveChanges();
                                return Json(new { Ok = true, Mensagem = "Antecipação cancelada com sucesso." });
                            }

                        }
                        return Json(new { Ok = false, Mensagem = "Usuário não permitido Cancelar Antecipação." });
                    }
                }
                
                return Json(new { Ok = false, Mensagem = "Antecipação Invalida" });

            } catch(Exception ex)
            {
                return Json(new { Ok = false, Mensagem="Erro ao cancelar antecipação: " + ex.Message });
            }
        }

        public IActionResult Result(string Mensagem = "", bool ClosePage = false)
        {
            ViewBag.Mensagem = Mensagem;
            ViewBag.ClosePage = ClosePage;

            return View();
        }

        public override async Task<IActionResult> Details(long? Id)
        {
            //TODO adicionar validação usuario

            List<ViewModelAntecipacaoHistorico> Lista = new List<ViewModelAntecipacaoHistorico>();

            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                Antecipacao antecipacao = null;

                if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                {
                    antecipacao = _context.Antecipacao.FirstOrDefault(o => o.ID == Id && o.EmpresaID == usuario.EmpresaID);
                }
                else if (usuario.Tipo == TipoUsuario.Fornecedor)
                {
                    Fornecedor fornecedor = FornecedorDAO.GetFornecedorUsuario(_context, usuario);

                    antecipacao = _context.Antecipacao.FirstOrDefault(
                            o => o.ID == Id &&
                            o.EmpresaID == usuario.EmpresaID && o.FornecedorID == fornecedor.ID
                    );
                }

                if (antecipacao != null)
                {
                    Lista = antecipacao.AntecipacaoHistorico.OrderByDescending(x=>x.ID).Select(
                        x => new ViewModelAntecipacaoHistorico()
                        {
                            Data = x.DataEvento.ToString("dd/MM/yyyy HH:mm"),
                            Usuario = x.Usuario.Nome,
                            Observacao = x.Observacao,
                            Status = LibraryUtil.GetDescricaoStatusAntecipacao(x.Status)
                        }    
                    ).ToList();
                }
            }
            ViewBag.Lista = Lista;
            return View();
        }


        private async Task<IActionResult> AtualizarStatus(long Id, StatusAntecipacao Status, string Observacao="")
        {
            //ContextUtil.CheckPermissao(_context, usuario, "Atualizar", 7);
            //TODO adicionar validação usuario/evento executado
            using (var transaction = _context.Database.BeginTransaction())
            {
                Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
                if (usuario != null)
                {

                    Antecipacao antecipacao = null;

                    if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                    {
                        antecipacao = _context.Antecipacao.FirstOrDefault(o => o.ID == Id && o.EmpresaID == usuario.EmpresaID);
                    }
                    else if (usuario.Tipo == TipoUsuario.Fornecedor)
                    {
                        Fornecedor fornecedor = FornecedorDAO.GetFornecedorUsuario(_context, usuario);

                        antecipacao = _context.Antecipacao.FirstOrDefault(
                                o => o.ID == Id &&
                                o.EmpresaID == usuario.EmpresaID && o.FornecedorID == fornecedor.ID
                        );
                    }



                    if (antecipacao != null)
                    {
                        if (
                            (usuario.Tipo == TipoUsuario.Fornecedor && antecipacao.Status == StatusAntecipacao.AguardandoParecerFornecedor)
                            || (usuario.Tipo == TipoUsuario.AdminEmpresa && antecipacao.Status == StatusAntecipacao.AguardandoParecerEmpresa)
                           
                            )
                        {

                            CreateHistorico(Id, usuario.ID, Observacao, Status);

                            StatusAntecipacao StatusUsuario;
                            if (Status == StatusAntecipacao.Cancelada || Status == StatusAntecipacao.Aprovada)
                            {
                                StatusUsuario = Status;
                            }
                            else
                            { 
                                if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                                {
                                    StatusUsuario = StatusAntecipacao.AguardandoParecerFornecedor;
                                }
                                else
                                {
                                    StatusUsuario = StatusAntecipacao.AguardandoParecerEmpresa;
                                }
                                CreateHistorico(Id, usuario.ID, "", StatusUsuario);
                            }

                            antecipacao.Status = StatusUsuario;
                            _context.Entry(antecipacao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                           
                            _context.SaveChanges();

                            transaction.Commit();

                            if (usuario.Tipo == TipoUsuario.Fornecedor && Status == StatusAntecipacao.Aprovada)
                            {
                                //enviar e-mail
                                //var ResultMail = AntecipacaoMail.NovaAntecipacaoSendMail(_context, Id);
                                var ResultMail = AntecipacaoMail.AntecipacaoAceitaSendMail(_context, Id);
                            }
                            return Json(new { Ok = true, Mensagem = "" });
                        }

                        transaction.Rollback();
                        var status = usuario.Tipo == TipoUsuario.Fornecedor ? "Aguardando Parecer Fornecedor" : "Aguardando Parecer Empresa";
                        return Json(new { Ok = false, Mensagem = "Antecipação não está com status '" + status + "'." });
                    }
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Antecipação não encontrada." });

                }
                transaction.Rollback();
                return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });

            }

        }

        public async Task<IActionResult> Cancelar(long Id)
        {
            return  await AtualizarStatus(Id, StatusAntecipacao.Cancelada);
        }

        public async Task<IActionResult> Aceitar(long Id)
        {
            return await AtualizarStatus(Id, StatusAntecipacao.Aceite);
        }

        public async Task<IActionResult> Recusar(long Id, string Observacao="")
        {
            return await AtualizarStatus(Id, StatusAntecipacao.Recusa, Observacao);
        }

        public async Task<IActionResult> Aprovar(long Id)
        {
            return await AtualizarStatus(Id, StatusAntecipacao.Aprovada);
        }


        public void CreateHistorico(long AntecipacaoId, long UsuarioId, string Observacao, StatusAntecipacao Status)
        {
            AntecipacaoHistorico a = new AntecipacaoHistorico
            {
                EmpresaID = _empresaId,
                Habilitado = true,
                InsertDate = DateTime.Now,
                AntecipacaoID = AntecipacaoId,
                DataEvento = DateTime.Now,
                UsuarioID = UsuarioId,
                Status = Status,
                Observacao = Observacao
            };

            _context.Add<AntecipacaoHistorico>(a);
        }

       
        public IActionResult ListarTitulos(long Id)
        {
            
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {

                var ResultAntecipacaoItem = _context.AntecipacaoItem.
                    Where(o => o.AntecipacaoID == Id && o.EmpresaID == usuario.EmpresaID);

                var Result = ResultAntecipacaoItem.Select(x=>new
                    {
                        Unidade = x.TituloPagar.Unidade.Nome,
                        DataVencimento = x.TituloPagar.DataVencimento.ToString("dd/MM/yyyy"),
                        NumeroDocumento = x.TituloPagar.NumeroDocumento,
                        Parcela = x.TituloPagar.Parcela,
                    Id = x.TituloPagarID,
                        Valor = x.ValorTitulo,
                        ValorAntecipacao = x.ValorTituloAntecipado,
                    });

                var ResultStatus = CheckStatus(Id,"");

                var ResultAntecipacao = _context.Antecipacao.
                    FirstOrDefault(o => o.ID == Id && o.EmpresaID == usuario.EmpresaID);

                string Mensagem = "";
                int Evento = 0;
                OrigemAntecipacao origemAntecipacao = OrigemAntecipacao.Empresa; 
                if (ResultAntecipacao != null)
                {
                     var ResultEvento = ResultAntecipacao.AntecipacaoHistorico.
                       Where(
                           x =>
                           x.Status == StatusAntecipacao.Aceite ||
                            x.Status == StatusAntecipacao.Recusa ||
                             x.Status == StatusAntecipacao.Alteracao
                       ).OrderByDescending(x=>x.DataEvento);

                    if (ResultEvento.Any())
                    {
                        Evento = (int)ResultEvento.First().Status;
                        if (ResultEvento.First().Status == StatusAntecipacao.Alteracao)
                        {
                            Mensagem = ResultEvento.First().Observacao;
                        }
                    }

                    
                    origemAntecipacao = ResultAntecipacao.Origem;
                }
                

                return Json(new { Ok = true, Result= Result, Status = ResultStatus[0].Equals("1"), Evento = Evento, Origem = origemAntecipacao, Mensagem=Mensagem });
            }

            return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
        }



        public IActionResult GetOrigem(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                Antecipacao antecipacao = null;

                if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                {
                    antecipacao = _context.Antecipacao.FirstOrDefault(o => o.ID == Id && o.EmpresaID == usuario.EmpresaID);
                }
                else if (usuario.Tipo == TipoUsuario.Fornecedor)
                {
                    Fornecedor fornecedor = FornecedorDAO.GetFornecedorUsuario(_context, usuario);

                    antecipacao = _context.Antecipacao.FirstOrDefault(
                            o => o.ID == Id &&
                            o.EmpresaID == usuario.EmpresaID && o.FornecedorID == fornecedor.ID
                    );
                }

                if (antecipacao != null)
                {
                    return Json(new { Origem = antecipacao.Origem });
                }

            }
            return Json(new { Origem = -1 });
        }

        private string[] CheckStatus(long Id, string Tipo)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            var Mensagem = "Usuário não encontrado.";
            if (usuario != null)
            {
                Mensagem = "Antecipação não encontrada.";

                Antecipacao ResultAntecipacao = null;

                if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                {
                    ResultAntecipacao = _context.Antecipacao.FirstOrDefault(o => o.ID == Id && o.EmpresaID == usuario.EmpresaID);
                }
                else if (usuario.Tipo == TipoUsuario.Fornecedor)
                {
                    Fornecedor fornecedor = FornecedorDAO.GetFornecedorUsuario(_context, usuario);

                    ResultAntecipacao = _context.Antecipacao.FirstOrDefault(
                            o => o.ID == Id &&
                            o.EmpresaID == usuario.EmpresaID && o.FornecedorID == fornecedor.ID
                    );
                }

                if (ResultAntecipacao != null)
                {
                    if (ResultAntecipacao.Status == StatusAntecipacao.Aprovada || ResultAntecipacao.Status == StatusAntecipacao.Cancelada)
                    {
                        return new string[] { "0", "Não é possivel mais realizar eventos na antecipação Status: Aprovado/Cancelada." };
                    }

                    if (Tipo == "C")
                    {
                        if (ResultAntecipacao.Origem == OrigemAntecipacao.Empresa)
                        {
                            Mensagem = "A antecipação selecionada foi criada por um usuário = 'Empresa'.";
                        }
                        else
                        {
                            Mensagem = "A antecipação selecionada foi criada por um usuário = 'Fornecedor'.";
                        }

                        if (usuario.Tipo == TipoUsuario.AdminEmpresa && ResultAntecipacao.Origem == OrigemAntecipacao.Empresa)
                        {
                            return new string[] { "1", "" };
                        }
                        else if (usuario.Tipo == TipoUsuario.Fornecedor && ResultAntecipacao.Origem == OrigemAntecipacao.Fornecedor)
                        {

                            return new string[] { "1", "" };
                        }

                    }
                    else
                    {
                        if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                        {
                            Mensagem = "A antecipação selecionada precisa está com status = 'Aguardando Parecer Empresa'.";
                        }
                        else if (usuario.Tipo == TipoUsuario.Fornecedor)
                        {
                            Mensagem = "A antecipação selecionada precisa está com status = 'Aguardando Parecer Fornecedor'.";
                        }

                        if (usuario.Tipo == TipoUsuario.AdminEmpresa && ResultAntecipacao.Status == StatusAntecipacao.AguardandoParecerEmpresa)
                        {
                            return new string[] { "1", "" };
                        }
                        if (usuario.Tipo == TipoUsuario.Fornecedor && ResultAntecipacao.Status == StatusAntecipacao.AguardandoParecerFornecedor)
                        {
                            return new string[] { "1", "" };
                        }
                    }

                }
            }
            return new string[] {"0", Mensagem };
        }

        public IActionResult GetStatus(long Id, string Tipo)
        {
            var Result = CheckStatus(Id, Tipo);
            return Json(new { Status = Result[0].Equals("1"), Mensagem = Result[1] });
        }


        public async Task<IActionResult> GetStatusAntecipacao(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            var Mensagem = "Usuário não encontrado.";
            if (usuario != null)
            {
                Mensagem = "Usuário não tem acesso a essa função.";

                if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                {
                    Mensagem = "Antecipação não encontrada.";

                    Antecipacao ResultAntecipacao = null;

                    ResultAntecipacao = _context.Antecipacao.FirstOrDefault(o => o.ID == Id && o.EmpresaID == usuario.EmpresaID);
                
                    if (ResultAntecipacao != null)
                    {
                        if (ResultAntecipacao.Status == StatusAntecipacao.AguardandoParecerEmpresa || ResultAntecipacao.Status == StatusAntecipacao.AguardandoParecerFornecedor)
                        {
                            return Json(new { Status = 1, Mensagem = ""});
                        }
                        return Json(new { Status = 0, Mensagem = "Status antecipação está diferente de 'Aguardando Parecer Fornecedor/Empresa'" });
                    }
                }
            }

            return Json(new { Status =0, Mensagem = Mensagem });
        }


        private bool VerificaData(Usuario usuario,DateTime Data)
        {
            if (usuario.Tipo == TipoUsuario.AdminEmpresa)
            {

                return (Data.Date >= DateTime.Now.Date);
            } else if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                return (Data.Date > DateTime.Now.Date);
            }
            return false;
        }

        public async Task<IActionResult> AtualizarAntecipacao()
        {
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
                    if (usuario != null && Request != null)
                    {
                        if (ContextUtil.CheckPermissao(_context, usuario, "Atualizar", 7))
                        {
                            string NovaTaxa = Request.Form["NovaTaxa"];
                            string Id = Request.Form["Id"];
                            string Observacao = Request.Form["Observacao"];
                            string NovaDataRecebimento = Request.Form["DataRecebimento"];
                            string AtualizarCadastro = Request.Form["AtualizarCadastro"].FirstOrDefault();

                            if (string.IsNullOrEmpty(Id))
                            {
                                return Json(new { Ok = false, Mensagem = "Id antecipação informada inválida." });
                            }

                            if (string.IsNullOrEmpty(NovaTaxa) && string.IsNullOrEmpty(Observacao) && string.IsNullOrEmpty(NovaDataRecebimento))
                            {
                                return Json(new { Ok = false, Mensagem = "Nenhum campo preenchido." });
                            }

                            if (!string.IsNullOrEmpty(NovaDataRecebimento))
                            {
                                DateTime DataRecebimento = Convert.ToDateTime(LibraryUtil.DataSQL(NovaDataRecebimento));
                                if (!VerificaData(usuario, DataRecebimento))
                                {
                                    return Json(new { Ok = false, Mensagem = "Data de recebimento inválida." });
                                }
                            }

                            if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                            {
                                long AntecipacaoId = Convert.ToInt64(Id);
                                var antecipacao = _context.Antecipacao.FirstOrDefault(o => o.ID == AntecipacaoId && o.EmpresaID == usuario.EmpresaID);

                                if (antecipacao != null)
                                {
                                    var obs = "";
                                    decimal Taxa = 0;
                                    if (!string.IsNullOrEmpty(NovaTaxa))
                                    {
                                        Taxa = Convert.ToDecimal(NovaTaxa);
                                        if (Taxa > 0)
                                        {
                                            obs = "Atualização de taxa de: " + String.Format("{0:F2}", antecipacao.Taxa) + " para: " + String.Format("{0:F2}", Taxa);
                                            obs += "<br/>";
                                            antecipacao.Taxa = Taxa;
                                        }
                                    }

                                    if (!string.IsNullOrEmpty(NovaDataRecebimento))
                                    {
                                        DateTime DataRecebimento = Convert.ToDateTime(LibraryUtil.DataSQL(NovaDataRecebimento));

                                        obs += "Atualização da data de recebimento de: " + antecipacao.DataRecebimento.ToString("dd/MM/yyyy") + " para: " + DataRecebimento.ToString("dd/MM/yyyy");
                                        obs += "<br/>";
                                        antecipacao.DataRecebimento = DataRecebimento;
                                    }

                                    Observacao = obs+"<br/>"+ Observacao;
                                    antecipacao.Status = StatusAntecipacao.AguardandoParecerFornecedor;

                                    _context.Entry(antecipacao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                                    CreateHistorico(AntecipacaoId, usuario.ID, Observacao, StatusAntecipacao.Alteracao);
                                    CreateHistorico(AntecipacaoId, usuario.ID, "", antecipacao.Status);

                                    foreach (var ai in antecipacao.AntecipacaoItem)
                                    {
                                        var ValorAntecipado = LibraryUtil.CalculaValorAntecipacao(ai.TituloPagar.DataVencimento.Date, antecipacao.DataRecebimento.Date, ai.ValorTitulo, antecipacao.Taxa);
                                        _context.Entry(ai).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                                        ai.ValorTituloAntecipado = ValorAntecipado;
                                    }

                                    if (AtualizarCadastro != null)
                                    {
                                        //atualizar cadastro do fornecedor
                                        var taxaAntecipacao = _context.TaxaAntecipacao.FirstOrDefault(o => o.FornecedorID == antecipacao.FornecedorID && o.EmpresaID == usuario.EmpresaID);
                                        if (taxaAntecipacao != null)
                                        {
                                            if (Taxa > 0)
                                            {
                                                taxaAntecipacao.PercentualPorDia = Taxa;
                                                taxaAntecipacao.StatusIntegracao = 0;
                                                _context.Entry(taxaAntecipacao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                                            }
                                        }

                                        //Chama web service atualizar cadastro protheus
                                    }

                                    _context.SaveChanges();

                                    transaction.Commit();

                                    return Json(new { Ok = true, Mensagem = "" });
                                }
                            }
                        }                        
                    }
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Erro Interno." });
                }
            }
        }

        public bool CheckTituloPagarUnicoFornecedor(string[] IdTituloPagar)
        {
            var ResultTituloPagar = _context.TituloPagar.
                        Where(x => IdTituloPagar.Contains(x.ID.ToString())).
                        GroupBy(y => y.DocumentoPagar.FornecedorID);

            if (ResultTituloPagar.Count() == 1)
            {
                return true;
            }

            return false;
        }

        public async Task<IActionResult>  CreateAntecipacao()
        {
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
                    if (usuario != null)
                    {
                        string Data = Request.Form["DataPagamento"];
                        string NovaTaxa = Request.Form["NovaTaxa"];
                        string TipoAntecipacao = Request.Form["TipoAntecipacao"];

                        string AtualizarCadastro = Request.Form["AtualizarCadastro"].FirstOrDefault();
                        string[] Ids = Request.Form["Id"];

                        if (Ids == null)
                        {
                            return Json(new { Ok = false, Mensagem = "Titulos informado inválido." });
                        }
                        if (string.IsNullOrEmpty(Data))
                        {
                            return Json(new { Ok = false, Mensagem = "Data informada inválida." });
                        }


                        if (!string.IsNullOrEmpty(Data))
                        {
                            DateTime DataRecebimento = Convert.ToDateTime(LibraryUtil.DataSQL(Data));
                            if (!VerificaData(usuario, DataRecebimento))
                            {
                                return Json(new { Ok = false, Mensagem = "Data de recebimento inválida." });
                            }
                        }
                        
                        decimal NovaTaxaAntecipacao = 0;
                        if (!string.IsNullOrEmpty(NovaTaxa) && usuario.Tipo == TipoUsuario.AdminEmpresa)
                        {
                            NovaTaxaAntecipacao = Convert.ToDecimal(NovaTaxa);
                        }

                        if (usuario.Tipo == TipoUsuario.Fornecedor)
                        {
                            if (!CheckTituloPagarUnicoFornecedor(Ids))
                            {
                                return Json(new { Ok = false, Mensagem = "Titulos selecionados não é apenas um fornecedor." });
                            }
                        }


                       var DataPagamento = Convert.ToDateTime(LibraryUtil.DataSQL(Data));
                       
                        List<long> ListaAntecipacaoID = new List<long>();

                        var ResultTituloPagar = _context.TituloPagar.
                            Where(x => Ids.Contains(x.ID.ToString()));

                        var MenorDataVencimento = ResultTituloPagar.Min(x => x.DataVencimento);
                        if (DataPagamento.Date >= MenorDataVencimento.Date)
                        {
                            return Json(new { Ok = false, Mensagem = "Data de recebimento maior ou igual a data de vencimento do titulo." });
                        }


                        foreach (var f in ResultTituloPagar.GroupBy(y => y.DocumentoPagar.FornecedorID))
                        {
                            var FornecedorId = f.Key;


                            Antecipacao a = new Antecipacao
                            {
                                Habilitado = true,
                                InsertDate = DateTime.Now,
                                DataEmissao = DateTime.Now,
                                EmpresaID = _empresaId
                            };
                            a.FornecedorID = FornecedorId;
                            a.Taxa = 0;
                            a.DataRecebimento = DataPagamento;
                            a.Tipo = (TipoAntecipacao.Equals("0")? Library.Enums.TipoAntecipacao.Normal: Library.Enums.TipoAntecipacao.FIDC);

                            if (usuario.Tipo == TipoUsuario.Fornecedor)
                            {
                                a.Origem = OrigemAntecipacao.Fornecedor;
                                a.Status = StatusAntecipacao.AguardandoParecerEmpresa;
                            }
                            else if (usuario.Tipo == TipoUsuario.AdminEmpresa)
                            {
                                a.Origem = OrigemAntecipacao.Empresa;
                                a.Status = StatusAntecipacao.AguardandoParecerFornecedor;
                            }

                            var ResultFornecedor = _context.Fornecedor.FirstOrDefault(x => x.ID == a.FornecedorID);

                            if (ResultFornecedor != null)
                            {
                                if (string.IsNullOrEmpty(ResultFornecedor.EmailWorkflow))
                                {
                                    transaction.Rollback();
                                    return Json(new { Ok = false, Mensagem = ResultFornecedor.Nome+ " e-mail não cadastrado." });
                                }

                                if (!ResultFornecedor.FIDCAtivo && TipoAntecipacao.Equals("1"))
                                {
                                    transaction.Rollback();
                                    return Json(new { Ok = false, Mensagem = ResultFornecedor.Nome + " antecipação do tipo FIDC não está ativa." });
                                }

                                //se for fidc e tiver titulos de  serviço
                                if (
                                    TipoAntecipacao.Equals("1")
                                    && ResultTituloPagar.Any(x => x.DocumentoPagar.FornecedorID == FornecedorId && x.TipoDocumento == TipoDocumentoPagar.NotaFiscalServico)
                                    && !ResultFornecedor.AntecipaServico
                                    ) {
                                    transaction.Rollback();
                                    return Json(new { Ok = false, Mensagem = ResultFornecedor.Nome + " Está antecipação e do tipo FIDC e contém titulos de serviço, habilite a opção 'Antecipacação Nf Serviço' para conseguir realizar antecipação com titulos de serviço." });
                                }
                                //a.UnidadeID = ResultFornecedor.UnidadeID;

                                var TaxaAntecipacao = _context.TaxaAntecipacao.FirstOrDefault(x => x.FornecedorID == a.FornecedorID);
                                if (TaxaAntecipacao != null)
                                {
                                    
                                    decimal Taxa = 0;
                                    if (TaxaAntecipacao.PercentualPorDia != 0)
                                    {
                                        Taxa = TaxaAntecipacao.PercentualPorDia;
                                    }
                                    else
                                    {
                                        var ResultTaxaMaxima = ContextUtil.GetParametroPorChave(_context, "TAXA_PADRAO", _empresaId) ?? 0;
                                        if (ResultTaxaMaxima != null)
                                        {
                                            Taxa = Convert.ToDecimal(ResultTaxaMaxima);
                                        }
                                    }
                                    //quando a taxa e enviar pela 
                                    if (NovaTaxaAntecipacao > 0)
                                    {
                                        Taxa = NovaTaxaAntecipacao;
                                    }
                                    a.Taxa = Taxa;

                                    if (AtualizarCadastro != null)
                                    {
                                        TaxaAntecipacao.PercentualPorDia = Taxa;
                                        TaxaAntecipacao.StatusIntegracao = 0;
                                        _context.Entry(TaxaAntecipacao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                                    }
                                }
                            }

                            var ResultTituloFornecedor = ResultTituloPagar.Where(x => x.DocumentoPagar.FornecedorID == FornecedorId);
                            long UnidadeIdTitulo = 0;
                            List<AntecipacaoItem> Lista = new List<AntecipacaoItem>();
                            foreach (var ti in ResultTituloFornecedor)
                            {
                                var ValorAntecipado = LibraryUtil.CalculaValorAntecipacao(ti.DataVencimento.Date, a.DataRecebimento.Date, ti.Saldo, a.Taxa);

                                AntecipacaoItem at = new AntecipacaoItem
                                {
                                    Habilitado = true,
                                    InsertDate = DateTime.Now,
                                    TituloPagarID = ti.ID,
                                    EmpresaID = _empresaId,
                                    ValorTitulo = ti.Saldo,
                                    ValorTituloAntecipado = ValorAntecipado,
                                };

                                Lista.Add(at);
                                UnidadeIdTitulo = ti.UnidadeID.HasValue? ti.UnidadeID.Value: 0;
                            }

                            if (UnidadeIdTitulo != 0)
                            {
                                a.UnidadeID = UnidadeIdTitulo;
                            }

                            a.AntecipacaoItem = Lista;

                            _context.Add(a);
                            _context.SaveChanges();

                            if (a.ID != 0)
                            {
                                CreateHistorico(a.ID, usuario.ID, "", a.Status);
                                
                                _context.SaveChanges();
                            }

                            var ResultCreateUser = await CreateUsuarioAntecipacao(a.FornecedorID);
                            if (ResultCreateUser)
                            {
                                ListaAntecipacaoID.Add(a.ID);
                            } else
                            {
                                transaction.Rollback();
                                return Json(new { Ok = false, Mensagem = "Erro na criação do usuário." });
                            }

                        }

                        if (ListaAntecipacaoID.Count > 0)
                        {
                            var Mensagem = "";
                            foreach (var AntecipacaoID in ListaAntecipacaoID)
                            {
                                var callbackUrl = Url.AprovaAntecipacaoEmailCallbackLink(Request.Scheme);
                                var ResultMail = AntecipacaoMail.NovaAntecipacaoSendMail(_context, AntecipacaoID, callbackUrl);
                                if (ResultMail.Status)
                                {
                                    Mensagem = ResultMail.Mensagem;
                                }
                            }
                            
                            if (string.IsNullOrEmpty(Mensagem))
                            {
                                transaction.Commit();
                                return Json(new { Ok = true, Mensagem = "" });
                            }

                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = Mensagem });
                        }

                    }

                    

                    return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
                }
                catch(Exception ex)
                {
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Erro Interno:"+ex.Message });
                }             
            }            
        }

        

        private async Task<bool> CreateUsuarioAntecipacao(long FornecedorID)
        {
            var Result = _context.UsuarioFornecedor
                               .AsNoTracking().FirstOrDefault(x => x.FornecedorID == FornecedorID);

            if (Result == null)
            {
                HttpClientHandler clientHandler = new HttpClientHandler();
                clientHandler.ServerCertificateCustomValidationCallback = (sender, cert, chain, sslPolicyErrors) => { return true; };

                var client = new HttpClient(clientHandler);
                var Query = "?empresaId=" + _empresaId + "&pessoaId=" + FornecedorID + "&tipo=3";

                string baseUrl = string.Format("{0}://{1}{2}", Request.Scheme, Request.Host, Request.PathBase);

                var Url = baseUrl + @"/Account/RegisterOrResetAsync" + Query;
                var response = await client.GetAsync(Url);

                var res = await response.Content.ReadAsStringAsync();

                var userreturn = JsonConvert.DeserializeObject<ApplicationUserReturn>(res);
                return userreturn.Ok;
            }

            return true;
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
                orderby = (orderby == 4) ? 11 : orderby;
                orderby = (orderby == 5) ? 12 : orderby;

                var ResultUsuarioFornecedor = _context.UsuarioFornecedor.FirstOrDefault(x => x.UsuarioID == usuario.ID && x.EmpresaID == _empresaId);
                if (ResultUsuarioFornecedor != null)
                {
                    var FornecedorId = ResultUsuarioFornecedor.FornecedorID;
                    queryFiltroUsuario += " AND Fornecedor.Id = '" + FornecedorId + "'";
                }
            } else
            {
                orderby = (orderby == 5) ? 11 : orderby;
                orderby = (orderby == 6) ? 12 : orderby;
            }


            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    //total de registro
                    query = @"select COUNT(*)
                                 from Antecipacao
                                 join Fornecedor ON Fornecedor.Id = Antecipacao.FornecedorId";
                    query += @" where Antecipacao.EmpresaId = '" + _empresaId + "'";
                    query += queryFiltroUsuario;

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //total filtrado
                    query = @"SELECT COUNT(*) FROM ( 
                                   select 
                                    ID=Ant1.ID,
                                    Fornecedor=Fornecedor.Nome,
                                    Tipo = CASE  
                                        WHEN Tipo=0 THEN 'Normal'  
                                        WHEN Tipo=1 THEN 'FIDC'
                                    END,
                                    DtEmissao=CONVERT(varchar, DataEmissao, 103), 
                                    DtRecebimento=CONVERT(varchar, DataRecebimento, 103),
                                    Taxa,
                                    Valor=ISNULL(
	                                    (select 
		                                    SUM(
			                                    ValorTituloAntecipado
		                                    )
		                                    from AntecipacaoItem
		                                    where AntecipacaoItem.AntecipacaoID = Ant1.ID 
	                                    ), 0
                                    ),
                                    Origem = CASE  
                                        WHEN Origem=1 THEN 'Fornecedor'  
                                        WHEN Origem=0 THEN 'Empresa'
                                    END,
                                    Status = CASE   
                                          WHEN Status=0 THEN 'Aguardando Parecer Empresa'  
                                          WHEN Status=1 THEN 'Aguardando Parecer Fornecedor'
	                                      WHEN Status=2 THEN 'Aprovada'
	                                      WHEN Status=9 THEN 'Cancelada'   
                                    END,
                                    NomeUnidade=Unidade.Apelido,
                                    DataEmissao, 
                                    DataRecebimento
                                    
                                    from Antecipacao Ant1
                                    join Unidade ON Unidade.ID = Ant1.UnidadeID
                                    join Fornecedor ON Fornecedor.ID = Ant1.FornecedorID";
                    query += @" where Ant1.EmpresaId = '" + _empresaId + "'";
                    query += queryFiltroUsuario;
                    query += @" ) A";
                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";

                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    query = @"SELECT * FROM ( 
                                select
                                ID=Ant1.ID,
                                Fornecedor=Fornecedor.Nome,
                                Tipo = CASE  
                                        WHEN Tipo=0 THEN 'Normal'  
                                        WHEN Tipo=1 THEN 'FIDC'
                                        ELSE ''
                                END,
                                DtEmissao=CONVERT(varchar, DataEmissao, 103), 
                                DtRecebimento=CONVERT(varchar, DataRecebimento, 103),
                                Taxa,
                                Origem = CASE  
                                        WHEN Origem=1 THEN 'Fornecedor'  
                                        WHEN Origem=0 THEN 'Empresa'
                                END,
                                Valor=ISNULL(
	                                    (select 
		                                    SUM(
			                                    ValorTituloAntecipado
		                                    )
		                                    from AntecipacaoItem
		                                    where AntecipacaoItem.AntecipacaoID = Ant1.ID 
	                                    ), 0
                                    ),
                                Status = CASE   
                                         WHEN Status=0 THEN 'Aguardando Parecer Empresa'  
                                          WHEN Status=1 THEN 'Aguardando Parecer Fornecedor'
	                                    WHEN Status=2 THEN 'Aprovada'
	                                    WHEN Status=9 THEN 'Cancelada'   
                                END,
                                NomeUnidade=Unidade.Apelido,
                                DataEmissao, 
                                DataRecebimento
                                from Antecipacao Ant1
                                join Unidade ON Unidade.ID = Ant1.UnidadeID
                                join Fornecedor ON Fornecedor.ID = Ant1.FornecedorID";
                    query += @" where Ant1.EmpresaId = '" + _empresaId + "'";
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
                         data.Add(new {
                            Id = result["ID"],
                            Fornecedor = result["Fornecedor"],
                            DataEmissao = result["DtEmissao"],
                            DataRecebimento = result["DtRecebimento"],
                            Valor = string.Format("{0:C2}", result["Valor"]),
                            Taxa = String.Format("{0:F2}", result["Taxa"]),
                            Status = result["Status"],
                            Origem = result["Origem"],
                            NomeUnidade = result["NomeUnidade"],
                            Tipo = result["Tipo"],
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

            return Json(new { draw = draw, recordsFiltered = recordsFiltered, recordsTotal = recordsTotal, data = data });

        }


        public async Task<IActionResult> ExportarExcel(long id)
        {

            string query = "";
            string queryFiltroUsuario = "";
            List<dynamic> data = new List<dynamic>();

            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);

            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                var ResultUsuarioFornecedor = _context.UsuarioFornecedor.FirstOrDefault(x => x.UsuarioID == usuario.ID && x.EmpresaID == _empresaId);
                if (ResultUsuarioFornecedor != null)
                {
                    var FornecedorId = ResultUsuarioFornecedor.FornecedorID;
                    queryFiltroUsuario += " AND Fornecedor.Id = '" + FornecedorId + "'";
                }
            }

            
            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    query = @"SELECT * FROM ( 
                                select
                                ID=Ant1.ID,
                                Fornecedor=Fornecedor.Nome,
                                Tipo = CASE  
                                        WHEN Tipo=0 THEN 'Normal'  
                                        WHEN Tipo=1 THEN 'FIDC'
                                        ELSE ''
                                END,
                                DtEmissao=CONVERT(varchar, DataEmissao, 103), 
                                DtRecebimento=CONVERT(varchar, DataRecebimento, 103),
                                Taxa,
                                Origem = CASE  
                                        WHEN Origem=1 THEN 'Fornecedor'  
                                        WHEN Origem=0 THEN 'Empresa'
                                END,
                                Valor=ISNULL(
	                                    (select 
		                                    SUM(
			                                    ValorTituloAntecipado
		                                    )
		                                    from AntecipacaoItem
		                                    where AntecipacaoItem.AntecipacaoID = Ant1.ID 
	                                    ), 0
                                    ),
                                Status = CASE   
                                         WHEN Status=0 THEN 'Aguardando Parecer Empresa'  
                                          WHEN Status=1 THEN 'Aguardando Parecer Fornecedor'
	                                    WHEN Status=2 THEN 'Aprovada'
	                                    WHEN Status=9 THEN 'Cancelada'   
                                END,
                                NomeUnidade=Unidade.Apelido,
                                DataEmissao, 
                                DataRecebimento
                                from Antecipacao Ant1
                                join Unidade ON Unidade.ID = Ant1.UnidadeID
                                join Fornecedor ON Fornecedor.ID = Ant1.FornecedorID";
                    query += @" where Ant1.EmpresaId = '" + _empresaId + "'";
                    query += queryFiltroUsuario;
                    query += @" ) A";
                    query += @" where ID ="+id;
                    query += @" ORDER BY ID DESC" ;

                    command.CommandText = query;
                    var result = command.ExecuteReader();

                    var stream = new MemoryStream();
                    using (var package = new ExcelPackage(stream))
                    {
                        var workSheet = package.Workbook.Worksheets.Add("Biancogres_Antecipacao_" + DataUtil.DateToSql(DateTime.Today));

                        workSheet.Cells[1, 1].Value = "ID";
                        workSheet.Cells[1, 2].Value = "Fornecedor";
                        workSheet.Cells[1, 3].Value = "Tipo";
                        workSheet.Cells[1, 4].Value = "Data Emissão";
                        workSheet.Cells[1, 5].Value = "Data Recebimento";
                        workSheet.Cells[1, 6].Value = "Valor";
                        workSheet.Cells[1, 7].Value = "Taxa";
                        workSheet.Cells[1, 8].Value = "Status";
                        workSheet.Cells[1, 9].Value = "Origem";

                        int i = 2;
                        while (result.Read())
                        {
                            workSheet.Cells["A" + i].Value = result["ID"];
                            workSheet.Cells["B" + i].Value = result["Fornecedor"];
                            workSheet.Cells["C" + i].Value = result["Tipo"];
                            workSheet.Cells["D" + i].Value = result["DtEmissao"];
                            workSheet.Cells["E" + i].Value = result["DtRecebimento"];
                            workSheet.Cells["F" + i].Value = String.Format("{0:C2}", result["Valor"]);
                            workSheet.Cells["G" + i].Value = String.Format("{0:F2}", result["Taxa"]);
                            workSheet.Cells["H" + i].Value = result["Status"];
                            workSheet.Cells["I" + i].Value = result["NomeUnidade"];

                            i++;
                            workSheet.Cells["A" + i].Value = "";
                            workSheet.Cells["B" + i].Value = "";
                            workSheet.Cells["C" + i].Value = "";
                            workSheet.Cells["D" + i].Value = "";
                            workSheet.Cells["E" + i].Value = "";
                            workSheet.Cells["F" + i].Value = "";
                            workSheet.Cells["G" + i].Value = "";
                            workSheet.Cells["H" + i].Value = "";
                            workSheet.Cells["I" + i].Value = "";


                            long ID = Convert.ToInt64(result["ID"]);
                            var ResultItem = _context.AntecipacaoItem.Include(x => x.TituloPagar).Where(x => x.AntecipacaoID == ID).ToList();

                            i++;
                            workSheet.Cells["A" + i].Value = "Numero";
                            workSheet.Cells["B" + i].Value = "Parcela";
                            workSheet.Cells["C" + i].Value = "Data Emissão";
                            workSheet.Cells["D" + i].Value = "Data Vencimento";
                            workSheet.Cells["E" + i].Value = "Valor";
                            workSheet.Cells["F" + i].Value = "Valor Antecipação";
                            workSheet.Cells["G" + i].Value = "";
                            workSheet.Cells["H" + i].Value = "";
                            workSheet.Cells["I" + i].Value = "";

                            foreach (var item in ResultItem)
                            {
                                i++;
                                workSheet.Cells["A" + i].Value = item.TituloPagar.NumeroDocumento;
                                workSheet.Cells["B" + i].Value = item.TituloPagar.Parcela;
                                workSheet.Cells["C" + i].Value = item.TituloPagar.DataEmissao.ToString("dd/MM/yyyy");
                                workSheet.Cells["D" + i].Value = item.TituloPagar.DataVencimento.ToString("dd/MM/yyyy");
                                workSheet.Cells["E" + i].Value = String.Format("{0:C2}", item.ValorTitulo);
                                workSheet.Cells["F" + i].Value = String.Format("{0:C2}", item.ValorTituloAntecipado);
                                workSheet.Cells["G" + i].Value = "";
                                workSheet.Cells["H" + i].Value = "";
                                workSheet.Cells["I" + i].Value = "";
                            }
                            i++;
                        }


                        package.Save();
                    }

                    stream.Position = 0;
                    string excelName = $"Biancogres_Antecipacao_-{DateTime.Now.ToString("yyyyMMddHHmmssfff")}.xlsx";

                    //return File(stream, "application/octet-stream", excelName);  
                    return File(stream, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", excelName);

                   
                }
                catch (Exception ex)
                {
                    HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Exception, ex.Message, ControllerContext));
                    return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
                }
                finally
                {
                    if (_context.Database.GetDbConnection().State == System.Data.ConnectionState.Open)
                    {
                        _context.Database.CloseConnection();
                    }
                }

            }

        }

        
    }
}
