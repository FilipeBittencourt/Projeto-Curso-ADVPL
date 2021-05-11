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
using Facile.BusinessPortal.BusinessRules.Compra;

namespace Facile.BusinessPortal.BusinessRules.DAO
{
    public static class NotaFiscalCompraDAO
    {        
     /*
        public static async Task<List<SaveDataReturn>> CreateOrUpdateAsync(ContextParams Params, string _siteBaseURL, List<Library.Structs.Post.NotaFiscalCompra> ListPost)
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
                        Model.NotaFiscalCompra nfc = new Model.NotaFiscalCompra();


                        var queryForn = from Model.Fornecedor o in db.Fornecedor.ByParams(Params)
                                    where o.CPFCNPJ.Equals(post.FornecedorCPFCNPJ)
                                    select o;

                        if (!queryForn.Any())
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnError(post.FornecedorCPFCNPJ, "Fornecedor não cadastrado."));
                            continue;
                        }

                        var queryNFC = from Model.NotaFiscalCompra o in db.NotaFiscalCompra.ByParams(Params)
                                       where
                                              o.Fornecedor.CPFCNPJ.Equals(post.FornecedorCPFCNPJ)
                                             && o.CodigoProduto.Equals(post.ProdutoCodigo)
                                             && o.ItemProduto.Equals(post.ProdutoItem)
                                             && o.Numero.Equals(post.Numero)
                                             && o.Serie.Equals(post.Serie)

                                       select o;

                        if (queryNFC.Any())
                        {
                            nfc = queryNFC.First();
                            db.Entry(nfc).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                        }
                        else
                        {
                            nfc = new BaseDAO<Model.NotaFiscalCompra>().Novo(Params);
                            db.NotaFiscalCompra.Add(nfc);
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
                            nfc.TransportadoraID = queryTrans.First().ID;
                        }

                        if (!string.IsNullOrEmpty(post.PedidoNumero) && !string.IsNullOrEmpty(post.PedidoItem))
                        {
                            var queryPC = from Model.PedidoCompra o in db.PedidoCompra.ByParams(Params)
                                             where o.Numero.Equals(post.PedidoNumero) &&
                                             o.Item.Equals(post.PedidoItem) &&
                                             o.Deletado == post.Deletado
                                             select o;

                            if (!queryPC.Any())
                            {
                                tran.Rollback();
                                result.Add(SaveDataReturn.ReturnError(post.PedidoNumero+'-'+post.PedidoItem, "Número pedido/item não cadastrado."));
                                continue;
                            }
                            nfc.PedidoCompraID = queryPC.First().ID;
                        }

                        


                        nfc.FornecedorID    = queryForn.First().ID;
                        nfc.DataEmissao = post.DataEmissao;
                        nfc.Deletado = post.Deletado;
                        nfc.NumeroControleParticipante = post.NumeroControleParticipante;
                        nfc.Numero = post.Numero;
                        nfc.ItemProduto = post.ProdutoItem;
                        nfc.NomeProduto = post.ProdutoNome;
                        nfc.CodigoProduto = post.ProdutoCodigo;
                        nfc.UnidadeProduto = post.ProdutoUnidade;
                        nfc.Quantidade = post.Quantidade;
                        nfc.Valor = post.Valor;
                        nfc.Numero = post.Numero;
                        nfc.Serie = post.Serie;
                        nfc.ChaveNFE = post.ChaveNFE;
                        
                        var validation = new ValidationContext(nfc, null, null);
                        Validator.TryValidateObject(nfc, validation, validResults);
                        

                        if (validResults.Count > 0)
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnValidationResults(post.ChaveUnica, validResults));
                            continue;
                        }

                        await db.SaveChangesAsync();

                        if (string.IsNullOrEmpty(post.PedidoNumero))
                        {
                            var ResultMail =  CompraMail.NotaFiscalSendMail(db, nfc.ID, "<p>Pedido não informado</p>");
                            if (!ResultMail.Status)
                            {

                            }
                        }

                        
                        

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
