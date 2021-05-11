using Facile.BusinessPortal.BusinessRules.Boleto;
using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.BusinessRules.Util;
using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Structs.Interna;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Boleto = Facile.BusinessPortal.Model.Boleto;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("Cliente")]
    public class BoletoController : BaseCommonController<Model.Boleto>
    {
        public BoletoController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        public override async Task<IActionResult> Index()
        {
            ViewBag.AcaoImprimir = false;
            ViewBag.AcaoAtualizar = false;
            ViewBag.AcaoEnviarEmail = false;
            ViewBag.AcaoAtualizarEnviarEmail = false;
            ViewBag.AcaoExportaExcel = true;

            Usuario Usuario = await UsuarioDAO.GetUsuarioAsync(_context, User);

            if (Usuario != null)
            {
                ViewBag.AcaoImprimir = true;
                ViewBag.AcaoAtualizar = true;
                ViewBag.AcaoEnviarEmail = true;
                ViewBag.AcaoAtualizarEnviarEmail = true;

                if (Usuario.Tipo == TipoUsuario.Cliente)
                {
                    ViewBag.AcaoImprimir = ContextUtil.CheckPermissao(_context, Usuario, "Imprimir" ,5);
                    ViewBag.AcaoAtualizar = ContextUtil.CheckPermissao(_context, Usuario, "Atualizar", 5);
                    ViewBag.AcaoEnviarEmail = ContextUtil.CheckPermissao(_context, Usuario, "EnviarEmail", 5);
                    ViewBag.AcaoAtualizarEnviarEmail = ContextUtil.CheckPermissao(_context, Usuario, "AtualizarEnviarEmail", 5);
                }
            }

            return View();
        }


        public void BoletoSendMail()
        {
            var listBoleto = _context.Boleto.Where(
                        x =>
                            x.CodigoBanco.Equals("237") &&
                            !x.DataRecebimento.HasValue &&
                            !x.EmailEnviado &&
                            x.EmpresaID == _empresaId &&
                           // x.NossoNumero.Length == 10 &&
                           x.CedenteID == 35 && 
                          // x.NossoNumero.StartsWith("0") &&
                            !x.Deletado
                        ).ToList();
            BoletoMail.BoletoSendMail(_context, listBoleto);
        }

        private List<Model.Boleto> GetBoletos(string listaIdsBoleto)
        {
            var lista = listaIdsBoleto.Split(',');
            List<Model.Boleto> Lista = new List<Model.Boleto>();

            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);

            foreach (var o in lista)
            {
                try
                {
                    if (string.IsNullOrEmpty(o))
                    {
                        continue;
                    }

                    long BoletoId = Convert.ToInt64(o);
                    var Boleto = _context.Boleto.FirstOrDefault(
                        x =>
                            x.ID == BoletoId &&
                            x.EmpresaID == _empresaId
                        );
                    if (Boleto != null)
                    {
                        if (usuario.Tipo == TipoUsuario.Cliente)
                        {
                            var listaSacado = SacadoDAO.GetIDListSacadoUsuario(_context, usuario);
                            if (listaSacado.Contains(Boleto.SacadoID))
                            {
                                Lista.Add(Boleto);
                            }
                        }
                        else //outros usuários
                        {
                            Lista.Add(Boleto);
                        }
                    }
                }
                catch (Exception ex) //TODO TRATAR
                {
                    //return null;
                }
            }
            return Lista;
        }

        private DateTime DataValida(DateTime d)
        {
            while ((d.DayOfWeek == DayOfWeek.Saturday) || (d.DayOfWeek == DayOfWeek.Sunday))
            {
                var day = d.AddDays(1);
            }
            return d;
        }

        private string VerificarAtualizacao(List<Model.Boleto> ListaBoleto, DateTime? Data = null)
        {
            string Mensagem = "";
            Usuario Usuario = UsuarioDAO.GetUsuario(_context, User);

            DateTime DataLimite = DateTime.MaxValue;
            int Dias = 0;
            if (Usuario != null)
            {
                if (Usuario.Tipo == TipoUsuario.Cliente)
                {
                    var Ret = ContextUtil.GetParametroPorChave(_context, "DIAS_VENCIMENTO_ATUALIZAR", _empresaId) ?? 0;
                    Dias = Convert.ToInt32(Ret);
                    DataLimite = DateTime.Now.AddDays(Dias).Date;
                }
            }

            var DataBase = Data ?? DateTime.Now;

            foreach (var b in ListaBoleto)
            {
                if (b.DataVencimento.Date >= DataLimite || DataBase > DataLimite)
                {
                    Mensagem += "Não e possivel atualizar a data de vencimento do boleto: " + b.NumeroDocumento + ". Data Limite permitida: " + DataLimite.ToString("dd/MM/yyyy");
                }
            }

            return Mensagem;
        }

        private List<Model.Boleto> AtualizaBoleto(List<Model.Boleto> ListaBoleto, DateTime? Data = null)
        {
            var d = DateTime.Now.Date;

            var DataBase = Data ?? d;

            foreach (var b in ListaBoleto)
            {
                if (b.DataVencimento.Date <= d)
                {
                    int dias = (DataBase.Date.Subtract(b.DataVencimento.Date)).Days;
                    decimal valorJuros = (((b.PercentualJurosDia ?? 0) * b.ValorTitulo) / 100) * dias;

                    b.MensagemInstrucoesCaixa = "VÁLIDO PARA PAGAMENTO SOMENTE ATÉ O DIA " + DataBase.ToString("dd/MM/yyyy");
                    b.MensagemInstrucoesCaixa += "<br/> VENCIMENTO ORIGINAL: " + b.DataVencimento.ToString("dd/MM/yyyy");

                    if (valorJuros > 0)
                    {
                        b.MensagemInstrucoesCaixa += " VALOR ORIGINAL: " + b.ValorTitulo.ToString("R$ ##,##0.00");

                        b.MensagemInstrucoesCaixa += " <br/> ENCARGOS: " + valorJuros.ToString("R$ ##,##0.00");
                    }

                    b.DataVencimento = DataBase;
                    b.DataProcessamento = d;
                    b.ValorTitulo += valorJuros;
                }
            }
            return ListaBoleto;
        }

        public IActionResult Imprimir(string Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);

            if (ContextUtil.CheckPermissao(_context, usuario, "Imprimir", 5) || usuario.Tipo != TipoUsuario.Cliente)
            {
                try
                {
                    var Lista = GetBoletos(Id);
                    if (Lista.Count > 0)
                    {
                        foreach (var bol in Lista)
                        {
                            if (!CheckDiasBoleto(bol))
                            {
                                return RedirectToAction("Result", new { Mensagem = "Não é possível imprimir algum dos boletos selecionados. Entre em contato com o Beneficiário: " + bol.Cedente.TelCobrancaEmail });
                            }
                        }

                        var ListaBoletoNet = FactoryBoletoNet.ListBoletoToBoletoNet(Lista);
                        var Boleto = BoletoFile.GetPDF(ListaBoletoNet);
                        var Path = Boleto.FilePath + @"\" + Boleto.FileName;
                        return File(Boleto.Pdf, "application/pdf");
                    }
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Result", new { Mensagem = "Não é possível imprimir algum boleto selecionado. Entrar em contao com a empresa. Erro: " + ex.Message });
                }
            }
            return RedirectToAction("Result", new { Mensagem = "Usuário não tem acesso a essa funcionalidade." });
        }

        public IActionResult Result(string Mensagem = "", bool ClosePage = false)
        {
            ViewBag.Mensagem = Mensagem;
            ViewBag.ClosePage = ClosePage;

            return View();
        }


        public IActionResult Atualizar(string Id, string DataAtualizacao = "")
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);

            if (ContextUtil.CheckPermissao(_context, usuario, "Atualizar", 5) || usuario.Tipo != TipoUsuario.Cliente)
            {
                var Lista = GetBoletos(Id);
                if (Lista.Count > 0)
                {
                    DateTime? Data = null;

                    if (!string.IsNullOrEmpty(DataAtualizacao))
                    {
                        Data = DataUtil.StringDateToBR(DataAtualizacao);
                    }

                    var Mensagem = VerificarAtualizacao(Lista, Data);

                    if (string.IsNullOrEmpty(Mensagem))
                    {
                        Lista = AtualizaBoleto(Lista, Data);

                        var ListaBoletoNet = FactoryBoletoNet.ListBoletoToBoletoNet(Lista);

                        var Boleto = BoletoFile.GetPDF(ListaBoletoNet);
                        var Path = Boleto.FilePath + @"\" + Boleto.FileName;
                        return File(Boleto.Pdf, "application/pdf");
                    }
                    else
                    {

                        return RedirectToAction("Result", new { Mensagem = Mensagem });
                    }

                }
            }
            return RedirectToAction("Result", new { Mensagem = "Usuário não tem acesso a essa funcionalidade." });

            /*Usuario usuario = UsuarioDAO.GetUsuario(_context, User);

            if (ContextUtil.CheckPermissao(_context, usuario, "Atualizar"))
            {
                var Lista = GetBoletos(Id);
                if (Lista.Count > 0)
                {
                    Lista = AtualizaBoleto(Lista);
                    var ListaBoletoNet = FactoryBoletoNet.ListBoletoToBoletoNet(Lista);
                    BoletoFile.RenderBrowserPDF(ListaBoletoNet, HttpContext);
                }
            }*/
        }

        public IActionResult EnviarEmail(string Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (ContextUtil.CheckPermissao(_context, usuario, "EnviarEmail", 5) || usuario.Tipo != TipoUsuario.Cliente)
            {
                try
                {
                    var Lista = GetBoletos(Id);
                    if (Lista.Count > 0)
                    {
                        List<ReturnSendMail> ListaReturnSendMail = BoletoMail.BoletoSendMail(_context, Lista);
                        var Mensagem = "";
                        var Success = false;
                        foreach (var m in ListaReturnSendMail)
                        {
                            Mensagem += m.Mensagem;
                            Success = m.Status;
                        }
                        if (Success)
                        {
                            return RedirectToAction("Result", new { ClosePage = true });
                        }
                        else
                        {
                            return RedirectToAction("Result", new { Mensagem = Mensagem });
                        }
                    }
                }
                catch
                {
                    return RedirectToAction("Result", new { Mensagem = "Não é possível imprimir algum boleto selecionado. Entrar em contao com a empresa." });
                }
            }
            return RedirectToAction("Result", new { Mensagem = "Usuário não tem acesso a essa funcionalidade." });
        }

        public IActionResult AtualizarEnviarEmail(string Id, string DataAtualizacao = "")
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (ContextUtil.CheckPermissao(_context, usuario, "AtualizarEnviarEmail", 5) || usuario.Tipo != TipoUsuario.Cliente)
            {
                var Lista = GetBoletos(Id);
                if (Lista.Count > 0)
                {

                    DateTime? Data = null;

                    if (!string.IsNullOrEmpty(DataAtualizacao))
                    {
                        Data = DataUtil.StringDateToBR(DataAtualizacao);
                    }

                    var Mensagem = VerificarAtualizacao(Lista, Data);

                    if (string.IsNullOrEmpty(Mensagem))
                    {
                        Lista = AtualizaBoleto(Lista, Data);

                        List<ReturnSendMail> ListaReturnSendMail = BoletoMail.BoletoSendMail(_context, Lista);

                        Mensagem = "";
                        var Success = false;
                        foreach (var m in ListaReturnSendMail)
                        {
                            Mensagem += m.Mensagem;
                            Success = m.Status;
                        }
                        if (Success)
                        {
                            return RedirectToAction("Result", new { ClosePage = true });
                        }
                        else
                        {
                            return RedirectToAction("Result", new { Mensagem = Mensagem });
                        }

                    }
                    else
                    {

                        return RedirectToAction("Result", new { Mensagem = Mensagem });
                    }

                    /*
                    Lista = AtualizaBoleto(Lista);

                    List<ReturnSendMail> ListaReturnSendMail = BoletoMail.BoletoSendMail(_context, Lista);

                    var Mensagem = "";
                    var Success = false;
                    foreach (var m in ListaReturnSendMail)
                    {
                        Mensagem += m.Mensagem;
                        Success = m.Status;
                    }
                    if (Success)
                    {
                        return RedirectToAction("Result", new { ClosePage = true });
                    }
                    else
                    {
                        return RedirectToAction("Result", new { Mensagem = Mensagem });
                    }

                    */
                    //return RedirectToAction("Result", new { Mensagem = "E-mail enviado com sucesso." });
                }
            }
            return RedirectToAction("Result", new { Mensagem = "Usuário não tem acesso a essa funcionalidade." });
        }

        public IActionResult CheckVencido()
        {
            string[] Id = Request.Form["Id"];

            if (Id != null)
            {
                var Lista = GetBoletos(string.Join(",", Id));

                var d = DateTime.Today.Date;
                foreach (var b in Lista)
                {
                    if (b.DataVencimento.Date < d)
                    {
                        return new JsonResult(new { Ok = true });
                    }
                }

                return new JsonResult(new { Ok = false });
            }

            return new JsonResult(new { Ok = false });
        }

        public IActionResult CheckAtualizacao()
        {
            string[] Id = Request.Form["Id"];

            Usuario Usuario = UsuarioDAO.GetUsuario(_context, User);

            if (Usuario != null)
            {
                if (Usuario.Tipo == TipoUsuario.Cliente)
                {
                    if (Id != null)
                    {
                        var Lista = GetBoletos(string.Join(",", Id));

                        foreach (var b in Lista)
                        {
                            if (!CheckDiasBoleto(b, true))
                            {
                                return new JsonResult(new { Ok = false, Mensagem = "Boleto não disponível. Favor contactar o beneficiário. Tel.: " + b.Cedente.TelCobrancaEmail });
                            }
                        }

                        return new JsonResult(new { Ok = true });
                    }
                }
                else
                    return new JsonResult(new { Ok = true });
            }

            return new JsonResult(new { Ok = false, Mensagem = "Não foi encontrado registro." });
        }

        public IActionResult CheckImprimir()
        {
            string[] Id = Request.Form["Id"];

            Usuario Usuario = UsuarioDAO.GetUsuario(_context, User);

            if (Usuario != null)
            {
                if (Usuario.Tipo == TipoUsuario.Cliente)
                {
                    if (Id != null)
                    {
                        var Lista = GetBoletos(string.Join(",", Id));

                        foreach (var b in Lista)
                        {
                            if (!CheckDiasBoleto(b))
                            {
                                return new JsonResult(new { Ok = false, Mensagem = "Boleto não disponível. Favor contactar o beneficiário. Tel.: " + b.Cedente.TelCobrancaEmail });
                            }
                        }

                        return new JsonResult(new { Ok = true });
                    }
                }
                else
                    return new JsonResult(new { Ok = true });
            }

            return new JsonResult(new { Ok = false, Mensagem = "Não foi encontrado registro." });
        }

        private bool CheckDiasBoleto(Boleto bol, bool atualizar = false)
        {
            var parametro = "DIAS_VENCIMENTO_IMPRIMIR";
            if (atualizar)
                parametro = "DIAS_VENCIMENTO_ATUALIZAR";

            var Ret = ContextUtil.GetParametroPorChave(_context, parametro, _empresaId) ?? 0;

            var dias = Convert.ToInt32(Ret);
            var d = DateTime.Now.AddDays(-dias).Date;

            if (bol.DataVencimento.Date < d)
            {
                return false;
            }

            return true;
        }


        public async Task<IActionResult> ExportarExcel(string bolIds)
        {
            try
            {
                var usuario = await UsuarioDAO.GetUsuarioAsync(_context, User);
                var list = await BoletoDAO.ListaPorUsuario(_context, _empresaId, usuario, bolIds);
                list = list.OrderBy(o => o.DataVencimento).ToList();

                var stream = new MemoryStream();
                using (var package = new ExcelPackage(stream))
                {
                    var workSheet = package.Workbook.Worksheets.Add("Biancogres_Boletos_" + DataUtil.DateToSql(DateTime.Today));
                    workSheet.Cells.LoadFromCollection(list, true);

                    workSheet.Column(4).Style.Numberformat.Format = "dd/mm/yyyy";
                    workSheet.Column(5).Style.Numberformat.Format = "dd/mm/yyyy";

                    package.Save();
                }

                stream.Position = 0;
                string excelName = $"Biancogres_Boletos-{DateTime.Now.ToString("yyyyMMddHHmmssfff")}.xlsx";

                //return File(stream, "application/octet-stream", excelName);  
                return File(stream, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", excelName);
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
            if (usuario.Tipo == TipoUsuario.Cliente)
            {
                var listaSacado = SacadoDAO.GetIDListSacadoUsuario(_context, usuario);

                if (listaSacado != null)
                {
                    var qids = "";
                    foreach (var id in listaSacado)
                    {
                        if (!string.IsNullOrWhiteSpace(qids))
                            qids += ",";
                        qids += id.ToString();
                    }

                    queryFiltroUsuario += " AND Boleto.SacadoId IN (" + qids + ") ";
                }
                else
                {
                    //erro usuario tipo cliente tem que ter um sacado
                    queryFiltroUsuario = " AND 1 = 2 ";
                }
            }

            orderby = (orderby == 5) ? 9 : orderby;
            orderby = (orderby == 6) ? 10 : orderby;

            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    //total de registro
                    query = @"select COUNT(*)
                                from Boleto
                                JOIN Unidade ON Unidade.ID = Boleto.UnidadeId";
                    query += @" where Boleto.EmpresaId = '" + _empresaId + "' AND DataRecebimento IS NULL AND ValorTitulo > 0 AND Boleto.Deletado = 0";
                    query += queryFiltroUsuario;

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //Campos para filtro e retorno
                    var cqfields = @"Boleto.ID,
                                    NomeUnidade = Unidade.Apelido,
                                    Sacado = Sacado.CPFCNPJ + ' - ' + RTRIM(Sacado.Nome) + ' [' + RTRIM(Sacado.CodigoERP) + ']',
                                    NumeroDocumento, 
                                    DataEmissao = CONVERT(varchar, DataEmissao, 103), 
                                    DataVencimento = CONVERT(varchar, DataVencimento, 103),
                                    Status = CASE WHEN convert(date, GETDATE()) > DataVencimento THEN 'Vencido' ELSE 'Aguardando pagamento' END,
                                    ValorTitulo,
                                    DtEmissao = DataEmissao,    
                                    DtVencimento = DataVencimento
                                    ";

                    //total filtrado
                    query = $@"SELECT COUNT(*) FROM ( 
                                   select {cqfields}
                                    from Boleto
                                    JOIN Unidade ON Unidade.ID = Boleto.UnidadeId
                                    JOIN Sacado ON Sacado.ID = Boleto.SacadoId";
                    query += @" where Boleto.EmpresaId = '" + _empresaId + "' AND DataRecebimento IS NULL AND ValorTitulo > 0 AND Boleto.Deletado = 0";
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
                                    from Boleto
                                    JOIN Unidade ON Unidade.ID = Boleto.UnidadeId
                                    JOIN Sacado ON Sacado.ID = Boleto.SacadoId";

                    query += @" where Boleto.EmpresaId = '" + _empresaId + "' AND DataRecebimento IS NULL AND ValorTitulo > 0 AND Boleto.Deletado = 0";
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
                            Id = result["Id"],
                            NumeroDocumento = result["NumeroDocumento"],
                            DataEmissao = result["DataEmissao"],
                            DataVencimento = result["DataVencimento"],
                            ValorTitulo = string.Format("{0:C2}", result["ValorTitulo"]),
                            NomeUnidade = result["NomeUnidade"],
                            Status = result["Status"],
                            Sacado = result["Sacado"],
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
