using System;
using System.Linq;
using System.Threading.Tasks;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Model;
using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library.Security;
using Microsoft.EntityFrameworkCore;
using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Util;

namespace Facile.BusinessPortal.BusinessRules.DAO
{
    public static class PedidoCompraDAO
    {        
     /*
        public static async Task<List<SaveDataReturn>> CreateOrUpdateAsync(ContextParams Params, string _siteBaseURL, List<Library.Structs.Post.PedidoCompra> ListPost)
        {
            var db = Params.Database;
            var result = new List<SaveDataReturn>();

            foreach (var post in ListPost)
            {
                using (var tran = await db.Database.BeginTransactionAsync())
                {
                    try
                    {
                        var validResults = new List<ValidationResult>();
                        Model.PedidoCompra pc = new Model.PedidoCompra();


                        var queryForn = from Model.Fornecedor o in db.Fornecedor.ByParams(Params)
                                    where o.CPFCNPJ.Equals(post.FornecedorCPFCNPJ)
                                    select o;

                        if (!queryForn.Any())
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnError(post.FornecedorCPFCNPJ, "Fornecedor não cadastrado."));
                            continue;
                        }

                        

                        var queryPC = from Model.PedidoCompra o in db.PedidoCompra.ByParams(Params)
                                    where o.Numero.Equals(post.Pedido) && o.Item.Equals(post.PedidoItem)
                                    select o;

                        if (queryPC.Any())
                        {
                            pc = queryPC.First();
                            db.Entry(pc).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                        }
                        else
                        {
                            pc = new BaseDAO<Model.PedidoCompra>().Novo(Params);
                            db.PedidoCompra.Add(pc);
                        }

                        if (!string.IsNullOrEmpty(post.TransportadoraCPFCNPJ))
                        {
                            var queryTrans = from Model.Transportadora o in db.Transportadora.ByParams(Params)
                                             where o.CPFCNPJ.Equals(post.TransportadoraCPFCNPJ)
                                             select o;

                            if (!queryTrans.Any())
                            {
                                tran.Rollback();
                                result.Add(SaveDataReturn.ReturnError(post.TransportadoraCPFCNPJ, "Transportadora não cadastrado."));
                                continue;
                            }
                            pc.TransportadoraID = queryTrans.First().ID;

                        }

                        pc.FornecedorID    = queryForn.First().ID;
                        pc.DataEntrega = post.DataEntrega;
                        pc.Deletado = post.Deletado;
                        pc.NumeroControleParticipante = post.NumeroControleParticipante;
                        pc.Numero = post.Pedido;
                        pc.Item = post.PedidoItem;
                        pc.NomeProduto = post.ProdutoNome;
                        pc.CodigoProduto = post.ProdutoCodigo;
                        pc.UnidadeProduto = post.ProdutoUnidade;
                        pc.Quantidade = post.Quantidade;
                        pc.Saldo = post.Saldo;
                        pc.TipoFrete = (TipoFrete)post.TipoFrete;
                        

                        var validation = new ValidationContext(pc, null, null);
                        Validator.TryValidateObject(pc, validation, validResults);


                        if (validResults.Count > 0)
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnValidationResults(post.ChaveUnica, validResults));
                            continue;
                        }

                        await db.SaveChangesAsync();

                        tran.Commit();
                        result.Add(SaveDataReturn.ReturnOk(post.ChaveUnica));
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        result.Add(SaveDataReturn.ReturnException(post.ChaveUnica, ex));
                        continue;
                    }
                }
            }
       
            return result;     
        }
     */
    }
}
