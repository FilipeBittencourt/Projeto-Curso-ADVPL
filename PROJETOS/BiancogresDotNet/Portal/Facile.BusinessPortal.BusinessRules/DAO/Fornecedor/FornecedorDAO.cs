using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Security;
using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.BusinessRules.DAO
{
    public static class FornecedorDAO
    {
        public static Model.Fornecedor GetFornecedorUsuario(FBContext db, Usuario usuario)
        {
            var fornecedor = (from Model.Fornecedor s in db.Fornecedor.AsNoTracking()
                              join UsuarioFornecedor us in db.UsuarioFornecedor.AsNoTracking() on s.ID equals us.FornecedorID
                              where us.UsuarioID == usuario.ID
                              select s).First();
            return fornecedor;
        }
     

        public static async Task<List<SaveDataReturn>> CreateOrUpdateAsync(ContextParams Params, string _siteBaseURL, List<Library.Structs.Post.Fornecedor> ListPost)
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

                        var query = from Model.Fornecedor o in db.Fornecedor.ByParams(Params)
                                    where o.CPFCNPJ.Equals(post.CPFCNPJ)
                                    select o;

                        Model.Fornecedor fornecedor;

                        if (query.Any())
                        {
                            fornecedor = query.First();
                            db.Entry(fornecedor).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                        }
                        else
                        {
                            fornecedor = new BaseDAO<Model.Fornecedor>().Novo(Params);
                            fornecedor.CPFCNPJ = post.CPFCNPJ;
                            db.Fornecedor.Add(fornecedor);
                        }

                        fornecedor.Nome = post.Nome;
                        fornecedor.RazaoSocial = post.RazaoSocial;
                        fornecedor.Email = post.EmailUsuario;
                        fornecedor.EmailWorkflow = post.EmailWorkflow;
                        fornecedor.Observacoes = post.Observacoes;
                        fornecedor.CodigoERP = post.CodigoERP;

                        fornecedor.CEP = post.CEP;
                        fornecedor.Logradouro = post.Logradouro;
                        fornecedor.Numero = post.Numero;
                        fornecedor.Complemento = post.Complemento;
                        fornecedor.Bairro = post.Bairro;
                        fornecedor.UF = post.UF;
                        fornecedor.Cidade = post.Cidade;
                        fornecedor.TipoAntecipacao = post.TipoAntecipacao;

                        fornecedor.Habilitado = post.Habilitado;

                        //TODO VERIFICAR se vem da integração ou apenas portal
                        //fornecedor.AntecipaServico = post.AntecipaServico;
                        //fornecedor.FIDCAtivo = post.FIDCAtivo;

                        var queryTaxa = from Model.TaxaAntecipacao o in db.TaxaAntecipacao.ByParams(Params)
                                    where o.FornecedorID == fornecedor.ID
                                    select o;
                        if (queryTaxa.Any())
                        {
                            var taxaAntecipacao = queryTaxa.First();
                            db.Entry(taxaAntecipacao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                            taxaAntecipacao.PercentualPorDia = post.PercentualPorDia;
                        } else
                        {
                            TaxaAntecipacao taxaAntecipacao = new BaseDAO<TaxaAntecipacao>().Novo(Params);
                            taxaAntecipacao.PercentualPorDia = post.PercentualPorDia;
                            taxaAntecipacao.StatusIntegracao = StatusIntegracao.Sucesso;
                            fornecedor.TaxaAntecipacao = taxaAntecipacao;
                        }

                        var validation = new ValidationContext(fornecedor, null, null);
                        Validator.TryValidateObject(fornecedor, validation, validResults);


                        if (validResults.Count > 0)
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnValidationResults(post.ChaveUnica, validResults));
                            continue;
                        }

                        await db.SaveChangesAsync();

                        if (post.CriarUsuario)
                        {
                            var qUserFornecedor = db.UsuarioFornecedor.Where(u => u.FornecedorID == fornecedor.ID);
                            if (!qUserFornecedor.Any())
                            {
                                try
                                {
                                    var grupo = db.GrupoUsuario.EmpData(Params.Unidade.EmpresaID).FirstOrDefault(o => o.Tipo == TipoGrupoUsuario.Fornecedor);

                                    if (grupo == null)
                                    {
                                        tran.Rollback();
                                        result.Add(SaveDataReturn.ReturnError(post.CPFCNPJ, "GRUPO PORTAL DE FORNECEDOR NAO ENCONTRADO."));
                                        continue;
                                    }

                                    var usermodel = new Library.Structs.Post.CreateUserModel()
                                    {
                                        IsFirstAdmin = true,
                                        GrupoID = grupo.ID,
                                        Tipo = TipoUsuario.Fornecedor,
                                        EntidadeID = fornecedor.ID,
                                        UserName = fornecedor.CPFCNPJ,
                                        Nome = fornecedor.Nome,
                                        Email = fornecedor.Email,
                                        Password = "123456",
                                        ClientAuth = new ClientAuth()
                                        {
                                            Client_Key = Params.Unidade.Empresa.Client_Key.ToString(),
                                            Secret_Key = Params.Unidade.Secret_Key,
                                            CNPJ = Params.Unidade.CNPJ
                                        }
                                    };

                                    var resUser = await UsuarioDAO.ApiCreateUserAsync(usermodel, _siteBaseURL);
                                    if (!resUser.Ok)
                                    {
                                        tran.Rollback();
                                        result.Add(SaveDataReturn.ReturnError(post.CPFCNPJ, "Erro na criacao de Usuario Base: " + resUser.Message));
                                        continue;
                                    }
                                    else
                                    {
                                        var userBase = db.Usuario.FirstOrDefault(u => u.UserId == resUser.Id);
                                        if (userBase != null)
                                        {
                                            var ufornecedor = new BaseDAO<UsuarioFornecedor>().Novo(Params, true);
                                            ufornecedor.UsuarioID = userBase.ID;
                                            ufornecedor.FornecedorID = fornecedor.ID;
                                            db.UsuarioFornecedor.Add(ufornecedor);
                                        }
                                        else
                                        {
                                            tran.Rollback();
                                            result.Add(SaveDataReturn.ReturnError(post.CPFCNPJ, "Erro na criacao de Usuario Base X Sacado: " + resUser.Message));
                                            continue;
                                        }
                                    }
                                }
                                catch (Exception ex)
                                {
                                    throw new Exception("Erro na criacao de Usuario Base.", ex);
                                }
                            }
                            else
                            {
                                var user = qUserFornecedor.First();
                                user.Habilitado = post.Habilitado;

                                var usermodel = new Library.Structs.Post.ChangeUserModel()
                                {
                                    UserName = fornecedor.CPFCNPJ,
                                    Email = fornecedor.Email,
                                    IsLocked = !post.Habilitado,
                                    ClientAuth = new ClientAuth()
                                    {
                                        Client_Key = Params.Unidade.Empresa.Client_Key.ToString(),
                                        Secret_Key = Params.Unidade.Secret_Key,
                                        CNPJ = Params.Unidade.CNPJ
                                    }
                                };

                                var resUser = await UsuarioDAO.ApiSetUserStatusAsync(usermodel, _siteBaseURL);
                                if (!resUser.Ok)
                                {
                                    tran.Rollback();
                                    result.Add(SaveDataReturn.ReturnError(post.CPFCNPJ, "Erro na alteracao de Status de Usuario Base: " + resUser.Message));
                                    continue;
                                }
                            }

                            await db.SaveChangesAsync();
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

        public static async Task<List<TaxaFornecedorGet>> GetTaxaAsync(ContextParams Params, string _siteBaseURL)
        {
            var db = Params.Database;
            var query = from Model.TaxaAntecipacao o in db.TaxaAntecipacao.ByParams(Params)
                        where o.StatusIntegracao == StatusIntegracao.Pendente
                        select o;
            List<TaxaFornecedorGet> List = new List<TaxaFornecedorGet>();

            foreach (var item in query.ToList())
            {
                var ant = new TaxaFornecedorGet();
                PropertyCopier<Model.TaxaAntecipacao, TaxaFornecedorGet>.Copy(item, ant);
                ant.FornecedorCPFCNPJ = item.Fornecedor.CPFCNPJ;
                ant.CodigoERP = item.Fornecedor.CodigoERP;
                ant.Taxa = item.PercentualPorDia;

                List.Add(ant);
            }

            return List;
        }

        public static async Task<List<SaveDataReturn>> UpdateStatusIntegracaoTaxaAsync(ContextParams Params, string _siteBaseURL, List<Library.Structs.Post.TaxaFornecedorPost> ListPost)
        {
            var db = Params.Database;
            var result = new List<SaveDataReturn>();

            foreach (var post in ListPost)
            {
                using (var tran = await db.Database.BeginTransactionAsync())
                {
                    try
                    {
                        var query = from Model.TaxaAntecipacao o in db.TaxaAntecipacao.ByParams(Params)
                                    where o.ID == post.Id
                                    select o;

                        Model.TaxaAntecipacao taxaAntecipacao;

                        if (query.Any())
                        {
                            taxaAntecipacao = query.First();
                            db.Entry(taxaAntecipacao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                            taxaAntecipacao.StatusIntegracao = StatusIntegracao.Sucesso;
                            taxaAntecipacao.DataHoraIntegracao = DateTime.Now;
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
