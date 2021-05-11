using System;
using System.Linq;
using System.Threading.Tasks;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Model;
using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Security;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace Facile.BusinessPortal.BusinessRules.DAO
{
    public static class SacadoDAO
    {
        public static async Task<List<Sacado>> ListSacadosEmpresa(FBContext db, Usuario user)
        {
            //var result = await db.Sacado.ByUserAsync(user);

            var result = await (from Sacado s in db.Sacado.AsQueryable()
                                where s.EmpresaID == user.EmpresaID
                                select s).Take(50).ToListAsync();

            return result;
        }

        public static List<long> GetIDListSacadoUsuario(FBContext db, Usuario usuario)
        {
            var listaSacado = new List<long>();

            var sacado = (from Sacado s in db.Sacado.AsNoTracking()
                          join UsuarioCliente us in db.UsuarioSacado.AsNoTracking() on s.ID equals us.SacadoID
                          where us.UsuarioID == usuario.ID
                          select s).First();

            if (sacado != null)
            {
                if (sacado.GrupoSacadoID.HasValue && sacado.GrupoSacadoID != 0)
                {
                    var sacados = from Sacado s in db.Sacado.AsNoTracking()
                                  where s.EmpresaID == usuario.EmpresaID &&
                                  s.GrupoSacadoID == sacado.GrupoSacadoID
                                  select s;

                    listaSacado.AddRange(sacados.Select(x => x.ID).ToList());
                }
                else
                    listaSacado.Add(sacado.ID);
            }

            return listaSacado;
        }

        public static async Task<List<SaveDataReturn>> CreateOrUpdateAsync(ContextParams Params, string _siteBaseURL, List<Library.Structs.Post.Sacado> sacadoListPost)
        {
            var db = Params.Database;
            var result = new List<SaveDataReturn>();

            foreach (var sacadoPost in sacadoListPost)
            {
                using (var tran = await db.Database.BeginTransactionAsync())
                {
                    try
                    {
                        var validResults = new List<ValidationResult>();

                        var query = from Sacado o in db.Sacado.ByParams(Params, true)
                                    where o.CPFCNPJ == sacadoPost.CPFCNPJ
                                    select o;

                        Sacado sacado;

                        if (query.Any())
                        {
                            sacado = query.First();
                            db.Entry(sacado).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                        }
                        else
                        {
                            sacado = new BaseDAO<Sacado>().Novo(Params, true);
                            sacado.CPFCNPJ = sacadoPost.CPFCNPJ;
                            db.Sacado.Add(sacado);
                        }

                        sacado.Nome = sacadoPost.Nome;
                        sacado.Email = sacadoPost.EmailUsuario;
                        sacado.EmailWorkflow = sacadoPost.EmailWorkflow;
                        sacado.Observacoes = sacadoPost.Observacoes;
                        sacado.CodigoERP = sacadoPost.CodigoERP;

                        sacado.CEP = sacadoPost.CEP;
                        sacado.Logradouro = sacadoPost.Logradouro;
                        sacado.Numero = sacadoPost.Numero;
                        sacado.Complemento = sacadoPost.Complemento;
                        sacado.Bairro = sacadoPost.Bairro;
                        sacado.UF = sacadoPost.UF;
                        sacado.Cidade = sacadoPost.Cidade;

                        sacado.Habilitado = sacadoPost.Habilitado;

                        //Associando o Grupo de Sacado - Clientes com varios CNPJs para consultar boletos de todos no mesmo acesso
                        if (!string.IsNullOrWhiteSpace(sacadoPost.GrupoSacado))
                        {
                            GrupoSacado gsac;
                            var qgsac = db.GrupoSacado.EmpData(Params.Unidade.EmpresaID).Where(o => o.CodigoUnico == sacadoPost.GrupoSacado.Trim());
                            if (!qgsac.Any())
                            {
                                gsac = new BaseDAO<GrupoSacado>().Novo(Params, true);
                                gsac.CodigoUnico = sacadoPost.GrupoSacado.Trim();
                                gsac.Sacados = new List<Sacado>();
                                db.GrupoSacado.Add(gsac);
                                db.SaveChanges();
                            }
                            else
                            {
                                gsac = qgsac.First();
                                db.Entry(gsac).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                            }

                            if (!gsac.Sacados.Any())
                                sacado.MestreGrupo = true;

                            if (!gsac.Sacados.Any(o => o.CPFCNPJ == sacadoPost.CPFCNPJ))

                                gsac.Sacados.Add(sacado);
                        }
                        else
                        {
                            sacado.GrupoSacadoID = null;
                            sacado.MestreGrupo = false;
                        }

                        var validation = new ValidationContext(sacado, null, null);
                        Validator.TryValidateObject(sacado, validation, validResults);

                        if (validResults.Count > 0)
                        {
                            tran.Rollback();
                            result.Add(SaveDataReturn.ReturnValidationResults(sacadoPost.CPFCNPJ, validResults));
                            continue;
                        }

                        await db.SaveChangesAsync();


                        //SE for para criar usuário automaticamente para o Sacado precisa enviar no POST
                        if (sacadoPost.CriarUsuario)
                        {
                            var qUserSacado = db.UsuarioSacado.Where(u => u.SacadoID == sacado.ID);
                            if (!qUserSacado.Any())
                            {
                                try
                                {
                                    var grupoCliente = db.GrupoUsuario.EmpData(Params.Unidade.EmpresaID).FirstOrDefault(o => o.Tipo == TipoGrupoUsuario.Cliente);

                                    if (grupoCliente == null)
                                    {
                                        tran.Rollback();
                                        result.Add(SaveDataReturn.ReturnError(sacadoPost.CPFCNPJ, "GRUPO PORTAL DE CLIENTE NAO ENCONTRADO."));
                                        continue;
                                    }

                                    var usermodel = new Library.Structs.Post.CreateUserModel()
                                    {
                                        IsFirstAdmin = true,
                                        GrupoID = grupoCliente.ID,
                                        Tipo = TipoUsuario.Cliente,
                                        EntidadeID = sacado.ID,
                                        UserName = sacado.CPFCNPJ,
                                        Nome = sacado.Nome,
                                        Email = sacado.Email,
                                        Password = "portal1973",
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
                                        result.Add(SaveDataReturn.ReturnError(sacadoPost.CPFCNPJ, "Erro na criacao de Usuario Base: " + resUser.Message));
                                        continue;
                                    }
                                    else
                                    {
                                        var userBase = db.Usuario.FirstOrDefault(u => u.UserId == resUser.Id);
                                        if (userBase != null)
                                        {
                                            var cli = new BaseDAO<UsuarioCliente>().Novo(Params, true);
                                            cli.UsuarioID = userBase.ID;
                                            cli.SacadoID = sacado.ID;
                                            db.UsuarioSacado.Add(cli);
                                        }
                                        else
                                        {
                                            tran.Rollback();
                                            result.Add(SaveDataReturn.ReturnError(sacadoPost.CPFCNPJ, "Erro na criacao de Usuario Base X Sacado: " + resUser.Message));
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
                                var userSacado = qUserSacado.First();
                                userSacado.Habilitado = sacadoPost.Habilitado;

                                var usermodel = new Library.Structs.Post.ChangeUserModel()
                                {
                                    UserName = sacado.CPFCNPJ,
                                    Email = sacado.Email,
                                    IsLocked = !sacadoPost.Habilitado,
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
                                    result.Add(SaveDataReturn.ReturnError(sacadoPost.CPFCNPJ, "Erro na alteracao de Status de Usuario Base: " + resUser.Message));
                                    continue;
                                }
                            }
                        }

                        await db.SaveChangesAsync();
                        tran.Commit();
                        result.Add(SaveDataReturn.ReturnOk(sacadoPost.CPFCNPJ));
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        result.Add(SaveDataReturn.ReturnException(sacadoPost.CPFCNPJ, ex));
                        continue;
                    }
                }
            }

            return result;
        }

        public static async Task<SaveDataReturn> UpdateGrupoSacadoCNPJAsync(ContextParams Params)
        {
            var db = Params.Database;
            var result = new SaveDataReturn();

            using (var tran = await db.Database.BeginTransactionAsync())
            {
                try
                {




                    result.Ok = true;
                    tran.Commit();
                    return result;
                }
                catch (Exception ex)
                {
                    tran.Rollback();
                    result.Ok = false;
                    result.ErrorMessages.Add("Exception: " + ex.Message);
                    return result;
                }
            }
        }
               
    }
}
