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
using Facile.BusinessPortal.BusinessRules.Util;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("Fornecedor")]
    public class TituloPagarController : BaseCommonController<TituloPagar>
    {
        public TituloPagarController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        public override async Task<IActionResult> Index()
        {
            return View();
        }

        public static string NormalizaSearchAnalise(HttpRequest request)
        {
            var Analise = request.Form["Analise"].FirstOrDefault();
            var DataVencimentoInicio = request.Form["DataVencimentoInicio"].FirstOrDefault();
            var DataVencimentoFim = request.Form["DataVencimentoFim"].FirstOrDefault();
            var TipoAntecipacaoFornecedor = request.Form["TipoAntecipacaoFornecedor"].FirstOrDefault();
            var Fornecedores = request.Form["Fornecedores"].FirstOrDefault();
            var UnidadeID = request.Form["UnidadeID"].FirstOrDefault();
            var TipoAntecipacao = request.Form["TipoAntecipacao"].FirstOrDefault();


            string Result = "";

            if (Analise != null)
            {
                Result += " AND DataVencimento > GETDATE() ";

                if (!string.IsNullOrEmpty(DataVencimentoInicio) && !string.IsNullOrEmpty(DataVencimentoFim))
                {
                    Result += " AND DataVencimento BETWEEN '" + LibraryUtil.DataSQL(DataVencimentoInicio) + "' AND '" + LibraryUtil.DataSQL(DataVencimentoFim) + "' ";
                } else if (!string.IsNullOrEmpty(DataVencimentoInicio))
                {
                    Result += " AND DataVencimento > '" + LibraryUtil.DataSQL(DataVencimentoInicio) + "'  ";
                }
                else if (!string.IsNullOrEmpty(DataVencimentoFim))
                {
                    Result += " AND DataVencimento < '" + LibraryUtil.DataSQL(DataVencimentoFim) + "' ";
                }


                if (!string.IsNullOrEmpty(TipoAntecipacaoFornecedor))
                {
                    Result += " AND Fornecedor.TipoAntecipacao = '" + TipoAntecipacaoFornecedor + "' ";
                }

                //if (!string.IsNullOrEmpty(TipoAntecipacao))
                //{
                //    Result += " AND Fornecedor.FIDCAtivo = '" + (TipoAntecipacao.Equals("1")?1:0) + "' ";
                //}

                if (!string.IsNullOrEmpty(UnidadeID))
                {
                    var Id = Convert.ToInt64(UnidadeID);
                    Result += " AND TituloPagar.UnidadeID = '" + Id + "' ";
                }

              //  Result += " AND NOT TituloPagar.TipoDocumento = (CASE WHEN Fornecedor.AntecipaServico = 0 THEN '2' ELSE '' END) ";

                if (!string.IsNullOrEmpty(Fornecedores))
                {
                    var Lista = Fornecedores.Split(',');
                    var NovaLista = "";
                    for(var i =0;i<Lista.Length;i++)
                    {
                        if (!string.IsNullOrEmpty(Lista[i]))
                        {
                            if (!string.IsNullOrEmpty(NovaLista))
                            {
                                NovaLista += ",";
                            }
                            NovaLista += Lista[i];
                        }
                    }
                    Result += "  AND Fornecedor.ID IN (" + NovaLista + ") ";
                }

            }
           
            return Result;
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
            var Analise = Request.Form["Analise"].FirstOrDefault();

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

            string DtPagamento = "";
            decimal TaxaPadrao = 0;
            decimal TaxaAntecipacao = 0;

            if (Analise != null) //só existe tela analise
            {
                var DataPagamento = Request.Form["DataPagamento"].FirstOrDefault();
                if (!string.IsNullOrEmpty(DataPagamento))
                {
                    DtPagamento = LibraryUtil.DataSQL(DataPagamento);
                }

                if (!string.IsNullOrEmpty(Request.Form["NovaTaxa"].FirstOrDefault()))
                {
                    TaxaAntecipacao = Convert.ToDecimal(Request.Form["NovaTaxa"].FirstOrDefault());
                }

                var ResultTaxaPadrao = ContextUtil.GetParametroPorChave(_context, "TAXA_PADRAO", _empresaId) ?? 0;
                if (ResultTaxaPadrao != null)
                {
                    TaxaPadrao = Convert.ToDecimal(ResultTaxaPadrao);
                }
            }

            if (Analise == null)//não existe tela titulo pagar
            {
                orderby = (orderby == 6) ? 13 : orderby;
                orderby = (orderby == 7) ? 14 : orderby;
            } else
            {
                orderby = (orderby == 7 || orderby == 8) ? 6 : orderby;
            }

            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    //total de registro
                    query = @"select COUNT(*)
                                from TituloPagar
                                JOIN Unidade ON Unidade.ID = TituloPagar.UnidadeId
	                            JOIN DocumentoPagar ON DocumentoPagar.ID = TituloPagar.DocumentoPagarID
	                            JOIN Fornecedor ON Fornecedor.ID = DocumentoPagar.FornecedorId
	                            JOIN TaxaAntecipacao ON TaxaAntecipacao.FornecedorID = Fornecedor.ID";
                    query += @" where TituloPagar.EmpresaId = '" + _empresaId + "' AND DataPagamento IS NULL AND Saldo > 0 AND TituloPagar.Deletado = 0 ";
                    query += queryFiltroUsuario;
                    query += NormalizaSearchAnalise(Request);

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //total filtrado
                    query = @"SELECT COUNT(*) FROM ( 
                                select
                                    TituloPagar.ID,
                                    NomeFornecedor= Fornecedor.Nome+' - '+Fornecedor.CodigoERP,
                                    NumeroDocumento=TituloPagar.NumeroDocumento+(CASE WHEN TituloPagar.Parcela <> 'x' THEN '/'+Parcela ELSE '' END), 
                                    DtEmissao=CONVERT(varchar, TituloPagar.DataEmissao, 103), 
                                    DtVencimento=CONVERT(varchar, DataVencimento, 103),
                                    Saldo,
                                    NomeUnidade=Unidade.Apelido,
                                    Status = CASE WHEN GETDATE() > DataVencimento THEN 'Vencido' ELSE 'Aguardando' END,
	                                FornecedorId = Fornecedor.ID,
	                                Numero =  DocumentoPagar.NumeroDocumento,
	                                Serie,
	                                PercentualPorDia,
                                    TituloPagar.DataEmissao,
                                    DataVencimento
	                                from TituloPagar
                                    JOIN Unidade ON Unidade.ID = TituloPagar.UnidadeId
	                                JOIN DocumentoPagar ON DocumentoPagar.ID = TituloPagar.DocumentoPagarID
	                                JOIN Fornecedor ON Fornecedor.ID = DocumentoPagar.FornecedorId
	                                JOIN TaxaAntecipacao ON TaxaAntecipacao.FornecedorID = Fornecedor.ID";
                    query += @" where TituloPagar.EmpresaId = '" + _empresaId + "' AND DataPagamento IS NULL AND Saldo > 0 AND TituloPagar.Deletado = 0 ";
                    query += queryFiltroUsuario;
                    query += NormalizaSearchAnalise(Request);
                    query += @" ) A";
                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";
                    query += @" and not exists(
                        select * from AntecipacaoItem
                        JOIN Antecipacao ON Antecipacao.ID = AntecipacaoID
                        Where
                            Status IN (0,1,2)
                            and AntecipacaoItem.TituloPagarID = A.ID
                        )";


                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    query = @"SELECT * ";

                    query += @" FROM ( 
                                select 
                                    TituloPagar.ID,
                                    NomeFornecedor= Fornecedor.Nome+' - '+Fornecedor.CodigoERP,
                                    NumeroDocumento=TituloPagar.NumeroDocumento+(CASE WHEN TituloPagar.Parcela <> 'x' THEN '/'+Parcela ELSE '' END), 
                                    DtEmissao=CONVERT(varchar, TituloPagar.DataEmissao, 103), 
                                    DtVencimento=CONVERT(varchar, DataVencimento, 103),
                                    Saldo,
                                    NomeUnidade=Unidade.Apelido,
                                    Status = CASE WHEN GETDATE() > DataVencimento THEN 'Vencido' ELSE 'Aguardando' END,
	                                FornecedorId = Fornecedor.ID,
	                                Numero =  DocumentoPagar.NumeroDocumento,
	                                Serie,
	                                PercentualPorDia,
                                    TituloPagar.DataEmissao,
                                    DataVencimento
	                                from TituloPagar
                                    JOIN Unidade ON Unidade.ID = TituloPagar.UnidadeId
	                                JOIN DocumentoPagar ON DocumentoPagar.ID = TituloPagar.DocumentoPagarID
	                                JOIN Fornecedor ON Fornecedor.ID = DocumentoPagar.FornecedorId
	                                JOIN TaxaAntecipacao ON TaxaAntecipacao.FornecedorID = Fornecedor.ID";
                    query += @" where TituloPagar.EmpresaId = '" + _empresaId + "' AND DataPagamento IS NULL AND Saldo > 0 AND TituloPagar.Deletado = 0 ";
                    query += queryFiltroUsuario;
                    query += NormalizaSearchAnalise(Request);
                    query += @" ) A";
                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";
                    query += @" and not exists(
                        select* from AntecipacaoItem
                        JOIN Antecipacao ON Antecipacao.ID = AntecipacaoID
                        Where
                           Status IN (0,1,2)

                            and AntecipacaoItem.TituloPagarID = A.ID
                        )";
                    query += @" ORDER BY " + orderby + " " + sortColumnDir + ((pageSize != -1) ? " OFFSET " + (skip) + " ROWS FETCH NEXT " + (pageSize) + " ROWS ONLY" : "");

                    command.CommandText = query;
                    var result = command.ExecuteReader();

                    while (result.Read())
                    {
                        var ValorAntecipado = Convert.ToDecimal(result["Saldo"]);
                        decimal Taxa = 0;
                        
                        Taxa = (Convert.ToDecimal(result["PercentualPorDia"]) != 0) ? Convert.ToDecimal(result["PercentualPorDia"]) : TaxaPadrao;
                        if (TaxaAntecipacao > 0)
                        {
                            Taxa = TaxaAntecipacao;
                        }

                        if (!string.IsNullOrEmpty(DtPagamento))
                        {
                            var Pagamento = Convert.ToDateTime(DtPagamento);
                            var Vencimento = Convert.ToDateTime(result["DataVencimento"]);
                           
                            ValorAntecipado = LibraryUtil.CalculaValorAntecipacao(Vencimento, Pagamento, ValorAntecipado, Taxa);
                        }

                        data.Add(new
                        {
                            Id = result["ID"],
                            NumeroDocumento = result["NumeroDocumento"],
                            DataEmissao = result["DtEmissao"],
                            DataVencimento = result["DtVencimento"],
                            NomeUnidade = result["NomeUnidade"],
                            Status = result["Status"],
                            ValorTitulo = string.Format("{0:C2}", result["Saldo"]),
                            ValorAntecipado = string.Format("{0:C2}", ValorAntecipado),
                            NomeFornecedor = result["NomeFornecedor"],
                            FornecedorId = result["FornecedorId"],
                            Numero = result["Numero"],
                            Serie = result["Serie"],
                            Taxa = String.Format("{0:F2}", Taxa)
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

    }
}
