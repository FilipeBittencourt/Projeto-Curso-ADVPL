using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Linq;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Structs;
using System.Security.Claims;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.BusinessRules.DAO
{
    public static class UsuarioDAO
    {
        public static async Task<Usuario> GetUsuarioAsync(FBContext db, ClaimsPrincipal _userClaim)
        {
            var user = _userClaim.FindFirstValue(ClaimTypes.NameIdentifier);

            if (db.Usuario.Any(o => o.UserId == user))
            {
                Usuario usuario = await db.Usuario.FirstOrDefaultAsync(o => o.UserId == user);
                return usuario;
            }
            return null;
        }

        public static Usuario GetUsuario(FBContext db, ClaimsPrincipal _userClaim)
        {
            var result = Task.Run(async () => await GetUsuarioAsync(db, _userClaim)).Result;
            return result;
        }

        public static async Task<ApplicationUserReturn> ApiCreateUserAsync(CreateUserModel userModel, string baseUrl)
        {
            try
            {
                var client = new HttpClient();

                var myContent = JsonConvert.SerializeObject(userModel);
                var content = new StringContent(myContent);
                content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

                var response = await client.PostAsync(baseUrl + @"Account/registerjson", content);

                var res = await response.Content.ReadAsStringAsync();

                var userreturn = JsonConvert.DeserializeObject<ApplicationUserReturn>(res);

                return userreturn;
            }
            catch (Exception ex)
            {
                return (ApplicationUserReturn.Erro(userModel.UserName, userModel.Email, "ERRO CRIANDO USUARIO > ApiCreateUserAsync: " + ex.Message));
            }
        }

        public static async Task<ApplicationUserReturn> ApiSetUserStatusAsync(ChangeUserModel userModel, string baseUrl)
        {
            try
            {
                var client = new HttpClient();

                var myContent = JsonConvert.SerializeObject(userModel);
                var content = new StringContent(myContent);
                content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

                var response = await client.PostAsync(baseUrl + @"Account/SetUserStatusJson", content);

                var res = await response.Content.ReadAsStringAsync();

                var userreturn = JsonConvert.DeserializeObject<ApplicationUserReturn>(res);

                return userreturn;
            }
            catch (Exception ex)
            {
                return (ApplicationUserReturn.Erro(userModel.UserName, userModel.Email, "ERRO CRIANDO USUARIO > ApiSetUserStatusAsync: " + ex.Message));
            }
        }

        public static async Task<Usuario> CreateUsuarioAsync(ContextParams parms, CreateUserModel userModel, string userId)
        {

            if (!parms.Database.Usuario.Any(o => o.UserId == userId))
            {
                var usuarioBase = new BaseDAO<Usuario>().Novo(parms, true);
                usuarioBase.Nome = userModel.Nome;
                usuarioBase.UserId = userId;
                usuarioBase.Email = userModel.Email;
                usuarioBase.GrupoUsuarioID = userModel.GrupoID;
                usuarioBase.Tipo = userModel.Tipo;

                parms.Database.Usuario.Add(usuarioBase);

                await parms.Database.SaveChangesAsync();
                return usuarioBase;
            }
            else
                return parms.Database.Usuario.First(o => o.UserId == userId);
        }

        public static async Task<Usuario> CreateUsuarioEmpAsync(FBContext db, Empresa empresa, CreateUserModel userModel, string userId, long? pessoaId = null)
        {
            if (!db.Usuario.Any(o => o.UserId == userId))
            {
                var usuarioBase = new BaseDAO<Usuario>().Novo(empresa);
                usuarioBase.Nome = userModel.Nome;
                usuarioBase.UserId = userId;
                usuarioBase.Email = userModel.Email;
                usuarioBase.GrupoUsuarioID = userModel.GrupoID;
                usuarioBase.Tipo = userModel.Tipo;
                //usuarioBase.UsuarioGrupo = new List<UsuarioGrupo>();

                db.Usuario.Add(usuarioBase);
                
                if (userModel.Tipo == TipoUsuario.Cliente && pessoaId.HasValue)
                {
                    var userperson = new BaseDAO<UsuarioCliente>().Novo(empresa);
                    userperson.UsuarioID = usuarioBase.ID;
                    userperson.SacadoID = pessoaId.Value;
                    db.UsuarioSacado.Add(userperson);
                }
                else if (userModel.Tipo == TipoUsuario.Fornecedor && pessoaId.HasValue)
                {
                    var userperson = new BaseDAO<UsuarioFornecedor>().Novo(empresa);
                    userperson.UsuarioID = usuarioBase.ID;
                    userperson.FornecedorID = pessoaId.Value;
                    db.UsuarioFornecedor.Add(userperson);
                }

                /*var userpessoa = new BaseDAO<UsuarioPessoa>().Novo(empresa);
                userpessoa.UsuarioID = usuarioBase.ID;
                userpessoa.PessoaID = pessoaId.Value;
                db.UsuarioPessoa.Add(userpessoa);
                */

                await db.SaveChangesAsync();
                return usuarioBase;
            }
            else
                return db.Usuario.First(o => o.UserId == userId);
        }

        public static void AddUsuarioGrupo(ContextParams parms, string userId, long GrupoID)
        {
           /* var Usuario = parms.Database.Usuario.FirstOrDefault(o => o.UserId == userId);
            if (Usuario != null)
            {
                var UsuarioGrupo = new UsuarioGrupo()
                {
                    GrupoUsuarioID = GrupoID,
                    UsuarioID = Usuario.ID,
                    EmpresaID = Usuario.EmpresaID
                };

                parms.Database.UsuarioGrupo.Add(UsuarioGrupo);
                parms.Database.SaveChanges();
            }*/
        }

        public static void AddUsuarioGrupo(FBContext parms, string userId, long GrupoID)
        {
            /*var Usuario = parms.Usuario.FirstOrDefault(o => o.UserId == userId);
            if (Usuario != null)
            {
                if (!parms.UsuarioGrupo.Any(o => o.UsuarioID == Usuario.ID && o.GrupoUsuarioID == GrupoID))
                {
                    var UsuarioGrupo = new UsuarioGrupo()
                    {
                        GrupoUsuarioID = GrupoID,
                        UsuarioID = Usuario.ID,
                        EmpresaID = Usuario.EmpresaID
                    };

                    parms.UsuarioGrupo.Add(UsuarioGrupo);
                    parms.SaveChanges();
                }
            }*/
        }

        public static async Task ChangeUsuarioAsync(ContextParams parms, ChangeUserModel userModel, string userId)
        {
            var qusuario = parms.Database.Usuario.Where(o => o.UserId == userId);
            if (qusuario.Any())
            {
                var usuarioBase = qusuario.First();

                if (userModel.IsLocked)
                    usuarioBase.Habilitado = false;

                if (!string.IsNullOrWhiteSpace(userModel.Email))
                    usuarioBase.Email = userModel.Email;

                await parms.Database.SaveChangesAsync();
            }
        }

        public static async Task<GrupoUsuario> CreateGrupoAdminAsync(ContextParams parms)
        {
            var db = parms.Database;

            var grupo = new BaseDAO<GrupoUsuario>().Novo(parms, true);
            grupo.Nome = "Administradores";
            db.GrupoUsuario.Add(grupo);
            db.SaveChanges();

            var query = from Modulo mod in db.Modulo.AsNoTracking()
                        join Menu menu in db.Menu.AsNoTracking() on mod.ID equals menu.ModuloID
                        join MenuAcao ma in db.MenuAcao.AsNoTracking() on menu.ID equals ma.MenuID
                        join Acao acao in db.Acao on ma.AcaoID equals acao.ID
                        select new { MenuID = menu.ID, AcaoID = acao.ID };

            foreach (var obj in query)
            {
                var permissao = new BaseDAO<Permissao>().Novo(parms, true);
                permissao.GrupoUsuarioID = grupo.ID;
                permissao.MenuID = obj.MenuID;
                permissao.AcaoID = obj.AcaoID;

                db.Permissao.Add(permissao);
            }

            await db.SaveChangesAsync();
            return grupo;
        }
    }
}
