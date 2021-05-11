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
    public static class TransportadoraDAO
    {
        /*
        public static Model.Transportadora GetTransportadoraUsuario(FBContext db, Usuario usuario)
        {
             var transportadora = (from Model.Transportadora s in db.Transportadora.AsNoTracking()
                               join UsuarioPessoa us in db.UsuarioPessoa.AsNoTracking().Where(x=>x.Tipo == Library.TipoUsuario.Transportadora) on s.ID equals us.PessoaID
                               where us.UsuarioID == usuario.ID
                               select s).First();
            return transportadora;
        }
     

        public static async Task<List<SaveDataReturn>> CreateOrUpdateAsync(ContextParams Params, string _siteBaseURL, List<Library.Structs.Post.Transportadora> ListPost)
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

                        var query = from Model.Transportadora o in db.Transportadora.ByParams(Params)
                                    where o.CPFCNPJ.Equals(post.CPFCNPJ)
                                    select o;

                        Model.Transportadora transportadora;

                        if (query.Any())
                        {
                            transportadora = query.First();
                            db.Entry(transportadora).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                        }
                        else
                        {
                            transportadora = new BaseDAO<Model.Transportadora>().Novo(Params);
                            transportadora.CPFCNPJ = post.CPFCNPJ;
                            db.Transportadora.Add(transportadora);
                        }

                        transportadora.Nome = post.Nome;
                        transportadora.Email = post.EmailUsuario;
                        transportadora.Observacoes = post.Observacoes;
                        transportadora.CodigoERP = post.CodigoERP;

                        transportadora.CEP = post.CEP;
                        transportadora.Logradouro = post.Logradouro;
                        transportadora.Numero = post.Numero;
                        transportadora.Complemento = post.Complemento;
                        transportadora.Bairro = post.Bairro;
                        transportadora.UF = post.UF;
                        transportadora.Cidade = post.Cidade;
                        
                        transportadora.Habilitado = post.Habilitado;

                        
                        var validation = new ValidationContext(transportadora, null, null);
                        Validator.TryValidateObject(transportadora, validation, validResults);


                        if (validResults.Count > 0)
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnValidationResults(post.ChaveUnica, validResults));
                            continue;
                        }

                        await db.SaveChangesAsync();

                        if (post.CriarUsuario)
                        {
                            var qUser = db.UsuarioPessoa.Where(u => u.PessoaID == transportadora.ID && u.Tipo == Library.TipoUsuario.Transportadora);
                            if (!qUser.Any())
                            {
                                try
                                {
                                    var grupo = db.GrupoUsuario.EmpData(Params.Unidade.EmpresaID).FirstOrDefault(o => o.Tipo == TipoGrupoUsuario.Transportadora);

                                    if (grupo == null)
                                    {
                                        tran.Rollback();
                                        result.Add(SaveDataReturn.ReturnError(post.CPFCNPJ, "GRUPO PORTAL DE TRANSPORTADORA NAO ENCONTRADO."));
                                        continue;
                                    }

                                    var usermodel = new Library.Structs.Post.CreateUserModel()
                                    {
                                        IsFirstAdmin = true,
                                        GrupoID = grupo.ID,
                                        Tipo = TipoUsuario.Transportadora,
                                        EntidadeID = transportadora.ID,
                                        UserName = transportadora.CPFCNPJ,
                                        Nome = transportadora.Nome,
                                        Email = transportadora.Email,
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
                                            var utransportadora = new BaseDAO<UsuarioPessoa>().Novo(Params, true);
                                            utransportadora.UsuarioID = userBase.ID;
                                            utransportadora.PessoaID = transportadora.ID;
                                            db.UsuarioPessoa.Add(utransportadora);
                                        }
                                        else
                                        {
                                            tran.Rollback();
                                            result.Add(SaveDataReturn.ReturnError(post.CPFCNPJ, "Erro na alteracao de Status de Usuario Base: " + resUser.Message));
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
                                var user = qUser.First();
                                user.Habilitado = post.Habilitado;

                                var usermodel = new Library.Structs.Post.ChangeUserModel()
                                {
                                    UserName = transportadora.CPFCNPJ,
                                    Email = transportadora.Email,
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

       */
    }
}
