using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.BusinessRules.DAO
{
    public static class TituloPagarDAO
    {
        public static async Task<List<SaveDataReturn>> CreateOrUpdateAsync(ContextParams Params, List<Library.Structs.Post.TituloPagar> ListPost)
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

                        Model.Fornecedor fornecedorDocPagar = null;
                        Model.Fornecedor fornecedorFatPagar = null;

                        var queryFornDocPagar = from Model.Fornecedor o in db.Fornecedor//.ByParams(Params, true)
                                                where o.CPFCNPJ == post.DocumentoPagar.Fornecedor && o.EmpresaID == Params.Unidade.EmpresaID
                                                select o;

                        if (!queryFornDocPagar.Any())//caso fornecedor não estiver cadastrado
                        {
                            tran.Rollback();
                            string Msg = "Fornecedor (Documento Pagar): " + post.DocumentoPagar.Fornecedor + " não encontrado.";
                            result.Add(SaveDataReturn.ReturnError(post.ChaveUnica, Msg));
                            continue;
                        }
                        fornecedorDocPagar = queryFornDocPagar.First();

                        if (post.FaturaPagamento != null)
                        {
                            var queryFornFatPagar = from Model.Fornecedor o in db.Fornecedor//.ByParams(Params, true)
                                                    where o.CPFCNPJ == post.FaturaPagamento.Fornecedor && o.EmpresaID == Params.Unidade.EmpresaID
                                                    select o;

                            if (!queryFornFatPagar.Any())//caso fornecedor não estiver cadastrado
                            {
                                tran.Rollback();
                                string Msg = "Fornecedor (Fatura Pagamento): " + post.FaturaPagamento.Fornecedor + " não encontrado.";
                                result.Add(SaveDataReturn.ReturnError(post.ChaveUnica, Msg));
                                continue;
                            }
                            fornecedorFatPagar = queryFornFatPagar.First();
                        }



                        var query = from TituloPagar o in db.TituloPagar.ByParams(Params)
                                    where
                                    o.DocumentoPagar.Fornecedor.CPFCNPJ.Equals(post.DocumentoPagar.Fornecedor)
                                    && o.DocumentoPagar.NumeroDocumento.Equals(post.DocumentoPagar.NumeroDocumento)
                                    && o.DocumentoPagar.Serie.Equals(post.DocumentoPagar.Serie)
                                    && o.NumeroDocumento.Equals(post.NumeroDocumento)
                                    && o.Parcela.Equals(post.Parcela)
                                    //&& o.Deletado.Equals(post.Deletado)
                                    && o.NumeroControleParticipante.Equals(post.NumeroControleParticipante)
                                    select o;

                        TituloPagar tituloPagar;

                        if (query.Any())
                        {
                            tituloPagar = query.First();
                            db.Entry(tituloPagar).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                        }
                        else
                        {
                            tituloPagar = new BaseDAO<TituloPagar>().Novo(Params);
                            db.TituloPagar.Add(tituloPagar);
                        }

                        tituloPagar.DocumentoPagar = new BaseDAO<DocumentoPagar>().Novo(Params);

                        tituloPagar.DocumentoPagar.FornecedorID = fornecedorDocPagar.ID;
                        tituloPagar.DocumentoPagar.NumeroDocumento = post.DocumentoPagar.NumeroDocumento;
                        tituloPagar.DocumentoPagar.Serie = post.DocumentoPagar.Serie;
                        tituloPagar.DocumentoPagar.DataEmissao = post.DocumentoPagar.DataEmissao;

                        if (fornecedorFatPagar != null)
                        {
                            tituloPagar.FaturaPagamento = new BaseDAO<DocumentoPagar>().Novo(Params);

                            tituloPagar.FaturaPagamento.FornecedorID = fornecedorFatPagar.ID;
                            tituloPagar.FaturaPagamento.NumeroDocumento = post.DocumentoPagar.NumeroDocumento;
                            tituloPagar.FaturaPagamento.Serie = post.DocumentoPagar.Serie;
                            tituloPagar.FaturaPagamento.DataEmissao = post.DocumentoPagar.DataEmissao;
                        }

                        tituloPagar.NumeroDocumento = post.NumeroDocumento;
                        tituloPagar.Parcela = post.Parcela;
                        tituloPagar.DataEmissao = post.DataEmissao;
                        tituloPagar.DataVencimento = post.DataVencimento;
                        tituloPagar.DataBaixa = post.DataBaixa;
                        tituloPagar.DataPagamento = post.DataPagamento;
                        tituloPagar.Deletado = post.Deletado;

                        if (post.FormaPagamento.HasValue)
                        {
                            tituloPagar.FormaPagamento = (FormaPagamento)post.FormaPagamento;
                        }

                        tituloPagar.ValorTitulo = post.ValorTitulo;
                        tituloPagar.Saldo = post.Saldo;
                        tituloPagar.NumeroControleParticipante = post.NumeroControleParticipante;
                        tituloPagar.TipoDocumento = (TipoDocumentoPagar)post.TipoDocumento;


                        var validation = new ValidationContext(tituloPagar, null, null);
                        Validator.TryValidateObject(tituloPagar, validation, validResults);
                    
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

    }
}
