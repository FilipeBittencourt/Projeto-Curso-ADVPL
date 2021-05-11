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
using Facile.BusinessPortal.BusinessRules.Util;
using OfficeOpenXml.FormulaParsing.Excel.Functions.DateTime;
using Microsoft.AspNetCore.Mvc.Rendering;
using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.ViewModels;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("Compra")]
    public class PedidoCompraController : BaseCommonController<Model.PedidoCompra>
    {
        private TipoUsuario Tipo;
        public PedidoCompraController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
            this.Tipo = TipoUsuario.Default;
            var UsuarioGrupo = contextAccessor.HttpContext.Session.GetObject<UsuarioGrupoViewModel>("UsuarioGrupo");

            if (UsuarioGrupo != null)
            {
                this.Tipo = UsuarioGrupo.Tipo;
            }
        }

        /*
        public async Task<IActionResult> Agendado()
        {
            return View();
        }
        public override async Task<IActionResult> Index()
        {
            return View();
        }


        public IActionResult GetNotaFiscal(string q)
        {
            var Result = _context.NotaFiscalCompra.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                q.Contains(x.PedidoCompraID.ToString()) &&
                                x.DataAgendamento.HasValue
                                ).
                            Select(x =>
                             new
                             {
                                 Numero = x.Numero,
                                 Serie = x.Serie,
                                 Pedido = x.PedidoCompra.Numero,
                                 Item = x.PedidoCompra.Item,
                                 DataEmissao = x.DataEmissao.ToString("dd/MM/yyyy"),
                                 Quantidade = x.Quantidade,
                                ID = x.ID
                             }
                            );

            return new JsonResult(new { items = Result });
        }

        public async Task<IActionResult> SalvarAgendamento()
        {
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    Usuario usuario = UsuarioDAO.GetUsuario(_context, User);

                    if (usuario == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
                    }

                    if (Request == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Erro envio das informações." });
                    }

                    string IdNotaFiscais = Request.Form["IdNotaFiscais"];
                    string DataAgendamento = Request.Form["DataAgendamento"];
                    string HoraAgendamento = Request.Form["HoraAgendamento"];
                    string Observacao = Request.Form["Observacao"];

                    if (
                        string.IsNullOrEmpty(IdNotaFiscais)
                        && string.IsNullOrEmpty(DataAgendamento)
                        && string.IsNullOrEmpty(HoraAgendamento)
                    )
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Campo Data/Hora/Notas Fiscais não preenchido." });
                    }

                    var ListaNotaFiscais = IdNotaFiscais.Split(',');
                    var ListaHora = HoraAgendamento.Split(':');
                    DateTime DtAgendamento = Convert.ToDateTime(LibraryUtil.DataSQL(DataAgendamento));
                    if (ListaHora.Length >= 1)
                    {
                        DtAgendamento = DtAgendamento.AddHours(Convert.ToDouble(ListaHora[0]));
                        DtAgendamento = DtAgendamento.AddMinutes(Convert.ToDouble(ListaHora[1]));
                    }

                    var ok = true;
                    foreach (var item in ListaNotaFiscais)
                    {
                        long ID = Convert.ToInt64(item);
                        var notaFiscalCompra = _context.NotaFiscalCompra.AsNoTracking().
                                        FirstOrDefault(x =>
                                                    x.EmpresaID == _empresaId &&
                                                    x.Habilitado &&
                                                    x.ID == ID
                                        );

                        if (notaFiscalCompra != null)
                        {
                            if (!notaFiscalCompra.PedidoCompraID.HasValue)
                            {
                                transaction.Rollback();
                                return Json(new { Ok = false, Mensagem = "Pedido não informado." });
                            }
                           
                            if (!notaFiscalCompra.MotoristaID.HasValue || string.IsNullOrEmpty(notaFiscalCompra.Placa))
                            {
                                transaction.Rollback();
                                return Json(new { Ok = false, Mensagem = "Dados do transporte não informado." });
                            }

                            notaFiscalCompra.DataAgendamento = DtAgendamento;
                            _context.Entry(notaFiscalCompra).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                            _context.SaveChanges();
                        }
                        else
                        {
                            ok = false;
                        }
                    }

                    if (ok)
                    {
                        transaction.Commit();
                        return Json(new { Ok = true, Mensagem = "" });
                    }
                    else
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Nota fiscais não encontradas." });
                    }

                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Erro Interno." });
                }
            }
        }


        public IActionResult VerificarDisponibilidade(string IdNotaFiscais, string DataAgendamento)
        {

            if (string.IsNullOrEmpty(IdNotaFiscais))
            {
                return Json(new { Ok = false, Mensagem = "Nenhum campo preenchido." });
            }

            if (string.IsNullOrEmpty(DataAgendamento))
            {
                return Json(new { Ok = false, Mensagem = "Nenhum campo preenchido." });
            }

            var ListaNotaFiscais = IdNotaFiscais.Split(',');
            DateTime DtAgendamento = Convert.ToDateTime(LibraryUtil.DataSQL(DataAgendamento));

            var ResultQuantidadeHora = ContextUtil.GetParametroPorChave(_context, "QUANTIDADE_HORA_AGENDAMENTO_DIA", _empresaId) ?? 0;
            var QuantidadeHora = Convert.ToDecimal(ResultQuantidadeHora);

            var ResultExcecao = _context.ExcecaoAgenda.Where(x =>
                       x.Data.Date == DtAgendamento.Date &&
                       x.EmpresaID == _empresaId &&
                       x.Habilitado
                   ).FirstOrDefault();

            if (ResultExcecao != null)
            {
                QuantidadeHora = ResultExcecao.HoraDisponivel;
            }

            var ResultAgendado = _context.NotaFiscalCompra.AsNoTracking()
                                .Where(x =>
                                    x.EmpresaID == _empresaId &&
                                    x.Habilitado &&
                                    (x.DataAgendamento.HasValue && x.DataAgendamento.Value.Date.Equals(DtAgendamento.Date))
                                    ).GroupBy(y => new {
                                        y.TipoVeiculoID,
                                        y.TipoProdutoID
                                    });
            
            decimal SomaAgendada = 0;
            foreach(var item in ResultAgendado)
            {
                var ResultTempoCarregamento = _context.TempoDescarregamento.AsNoTracking().
                       Where(
                           x =>
                               x.TipoProdutoID == item.Key.TipoProdutoID &&
                               x.TipoVeiculoID == item.Key.TipoVeiculoID
                       ).FirstOrDefault();

                if (ResultTempoCarregamento != null)
                {
                    SomaAgendada += ResultTempoCarregamento.TempoGasto;
                }
            }

            decimal SomaAgendar = 0;
            foreach (var item in ListaNotaFiscais.Select(x => Convert.ToInt64(x)))
            {
                
                var ResultNotaAgendar = _context.NotaFiscalCompra.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                x.ID == item
                                ).FirstOrDefault();

                if (ResultNotaAgendar != null)
                {
                    var ResultTempoCarregamento = _context.TempoDescarregamento.AsNoTracking().
                        Where(
                            x =>
                                x.TipoProdutoID == ResultNotaAgendar.TipoProdutoID &&
                                x.TipoVeiculoID == ResultNotaAgendar.TipoVeiculoID
                        ).FirstOrDefault();

                    if (ResultTempoCarregamento != null)
                    {
                        SomaAgendar += ResultTempoCarregamento.TempoGasto;
                    }
                    else
                    {
                        return Json(new { Ok = false, Mensagem = "Tempo descarregamento não condigurado: TipoVeiculo: " + ResultNotaAgendar.TipoVeiculoID + " x TipoVeiculo: " + ResultNotaAgendar.TipoVeiculoID + "." });
                    }
                }
            
            }

            if ((SomaAgendar + SomaAgendada) <= QuantidadeHora)
            {
                return Json(new { Ok = true, Mensagem = "" });
            }
            return Json(new { Ok = false, Mensagem = "Capacidade de agendamento atiginda com as notas fiscal." });
            
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
            if (usuario != null)
            {
                if (Tipo == TipoUsuario.Fornecedor)
                {
                    var ResultUsuarioFornecedor = _context.UsuarioFornecedor.FirstOrDefault(x => x.UsuarioID == usuario.ID && x.EmpresaID == _empresaId);
                    if (ResultUsuarioFornecedor != null)
                    {
                        var FornecedorId = ResultUsuarioFornecedor.FornecedorID;
                        queryFiltroUsuario += " AND t.FornecedorID = '" + FornecedorId + "'";
                    }
                }
            }

            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    //total de registro
                    query = @"  select COUNT(*) from PedidoCompra t ";
                    query += @" where EmpresaId = '" + _empresaId + "' ";
                    query += queryFiltroUsuario;
                    //query += @" and exists (select 1 from NotaFiscalCompra where PedidoCompraID = ID)";

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //Campos para filtro e retorno
                    var cqfields = " t.ID, NomeFornecedor = Fornecedor.Nome + ' - ' + Fornecedor.CodigoERP, t.Numero, t.Item, Produto = t.NomeProduto+' - '+t.CodigoProduto, t.Quantidade, t.Saldo";

                    //total filtrado
                    query = $@"SELECT COUNT(*) FROM ( 
                                     select {cqfields} from PedidoCompra t 
                                      JOIN Fornecedor ON Fornecedor.ID = t.FornecedorID";
                    query += @" where t.EmpresaId = '" + _empresaId + "' ";
                    query += queryFiltroUsuario;
                    query += @" ) A";
                   
                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    //query += @" and exists (select 1 from NotaFiscalCompra where PedidoCompraID = A.ID)";
                    query += @" )";
            
                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    query = $@"SELECT * FROM ( 
                                    select {cqfields} from PedidoCompra t
                                    JOIN Fornecedor ON Fornecedor.ID = t.FornecedorID";
                    query += @" where t.EmpresaId = '" + _empresaId + "' ";
                    query += queryFiltroUsuario;
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    
                    //query += @" and exists (select 1 from NotaFiscalCompra where PedidoCompraID = A.ID)";
                    query += @" )";
                    query += @" ORDER BY " + orderby + " " + sortColumnDir + ((pageSize != -1) ? " OFFSET " + (skip) + " ROWS FETCH NEXT " + (pageSize) + " ROWS ONLY" : "");

                    command.CommandText = query;
                    var result = command.ExecuteReader();

                    while (result.Read())
                    {
                        data.Add(new
                        {
                            Id = result["ID"],
                            Fornecedor = result["NomeFornecedor"],
                            Numero = result["Numero"],
                            Item = result["Item"],
                            Produto = result["Produto"],
                            Quantidade = result["Quantidade"],
                            Saldo = result["Saldo"],
                            Status = "",
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


        public decimal GetDisponibilidade(DateTime DtAgendamento)
        {
            var ResultQuantidadeHora = ContextUtil.GetParametroPorChave(_context, "QUANTIDADE_HORA_AGENDAMENTO_DIA", _empresaId) ?? 0;
            var QuantidadeHora = Convert.ToDecimal(ResultQuantidadeHora);

            var ResultExcecao = _context.ExcecaoAgenda.Where(x =>
                       x.Data.Date == DtAgendamento.Date &&
                       x.EmpresaID == _empresaId &&
                       x.Habilitado
                   ).FirstOrDefault();

            if (ResultExcecao != null )
            {
                QuantidadeHora = ResultExcecao.HoraDisponivel;
            }


            var ResultAgendado = _context.NotaFiscalCompra.AsNoTracking()
                                .Where(x =>
                                    x.EmpresaID == _empresaId &&
                                    x.Habilitado &&
                                    x.PedidoCompraID.HasValue &&
                                    (x.DataAgendamento.HasValue && x.DataAgendamento.Value.Date.Equals(DtAgendamento.Date))
                                    
                                    ).GroupBy(y => new {
                                        y.TipoVeiculoID,
                                        y.TipoProdutoID
                                    });

            decimal SomaAgendada = 0;
            foreach (var item in ResultAgendado)
            {
                var ResultTempoCarregamento = _context.TempoDescarregamento.AsNoTracking().
                       Where(
                           x =>
                               x.TipoProdutoID == item.Key.TipoProdutoID &&
                               x.TipoVeiculoID == item.Key.TipoVeiculoID
                       ).FirstOrDefault();

                if (ResultTempoCarregamento != null)
                {
                    SomaAgendada += ResultTempoCarregamento.TempoGasto;
                }
            }

            return (QuantidadeHora - SomaAgendada);
        }

        public async Task<IActionResult> GetAgenda(DateTime Start, DateTime End)
        {
           var Result = _context.NotaFiscalCompra.Where(x =>
                   (
                       x.DataAgendamento.HasValue &&
                       x.DataAgendamento.Value.Date >= Start.Date && x.DataAgendamento.Value.Date <= End.Date
                   ) &&
                       x.EmpresaID == _empresaId &&
                       x.Habilitado &&
                       x.PedidoCompraID.HasValue
                    )
                    .Include(x => x.Fornecedor)
                    .Include(x => x.PedidoCompra);

            var ListaAgenda = Result.ToList<NotaFiscalCompra>();

            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);

            if (usuario != null)
            {
                if (Tipo == TipoUsuario.Fornecedor)
                {
                    var ResultUsuarioFornecedor = _context.UsuarioFornecedor.FirstOrDefault(x => x.UsuarioID == usuario.ID && x.EmpresaID == _empresaId);
                    if (ResultUsuarioFornecedor != null)
                    {
                        ListaAgenda = ListaAgenda.Where(x => x.FornecedorID == ResultUsuarioFornecedor.FornecedorID).ToList();
                    }
                }
                else if (Tipo == TipoUsuario.Transportadora)
                {
                    var ResultUsuarioTransportadora = _context.UsuarioTransportadora.FirstOrDefault(x => x.UsuarioID == usuario.ID && x.EmpresaID == _empresaId);
                    if (ResultUsuarioTransportadora != null)
                    {
                        ListaAgenda = ListaAgenda.Where(x => x.PedidoCompra.TransportadoraID == ResultUsuarioTransportadora.TransportadoraID).ToList();
                    }
                }
            }

            var ResultExcecao = _context.ExcecaoAgenda.Where(x =>
                    (
                        x.Data.Date >= Start.Date && x.Data.Date <= End.Date
                    ) &&
                        x.EmpresaID == _empresaId &&
                        !x.Habilitado
                    )
                    .ToList();

            List<dynamic> Lista = new List<dynamic>();
           

            foreach (var o in ResultExcecao)
            {
                var t = new
                {
                    id = o.ID,
                    title = o.Descricao,
                    start = o.Data.Date.ToString("yyyy-MM-dd"),
                    className = "border-danger bg-danger text-dark not-available",
                };
                Lista.Add(t);
            }


            var dias = (End.Subtract(Start)).Days;
            var Data = Start;
            for (var i = 0; i < dias; i++)
            {
                Data = Data.AddDays(1);
                if (!ResultExcecao.Any(x=>x.Data.Date == Data.Date))
                {
                    var t = new
                    {
                        title = "Qtd. Disponivel: " + GetDisponibilidade(Data.Date),
                        start = Data.Date.ToString("yyyy-MM-dd"),
                        className = "border-warning bg-warning text-dark",
                    };
                    Lista.Add(t);
                }
            }



            foreach (var o in ListaAgenda)
            {
                string ClassName = "";
                
                if (DateTime.Today.CompareTo(o.DataAgendamento.Value) <= 0)
                {
                    ClassName = "label-primary";
                }
                else
                {
                    ClassName = "label-danger";
                }

                
                var t = new
                {
                    id          = o.ID,
                    title       = o.Fornecedor.Nome + "\n" + o.Numero+"/"+o.Serie,
                    start       = o.DataAgendamento.Value,
                    end         = o.DataAgendamento.Value,
                    allDay      = "",
                    className   = ClassName,
                };

                Lista.Add(t);
            }
            return Json(new { Ok = 1, Events = Lista });
        }

        */

    }
}
