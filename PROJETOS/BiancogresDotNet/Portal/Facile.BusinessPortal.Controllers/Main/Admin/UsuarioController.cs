using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using System.Linq;
using System;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Identity;
using Facile.BusinessPortal.Library.Mail;
using Facile.BusinessPortal.BusinessRules.DAO.Admin;
using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.ViewModels;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("Admin")]
    public class UsuarioController : BaseCommonController<Model.Usuario>
    {
        private readonly IEmailSender _emailSender;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly FBContext _appContext;
        private TipoUsuario Tipo;

        public UsuarioController(UserManager<ApplicationUser> userManager, SignInManager<ApplicationUser> signInManager, IEmailSender emailSender, FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _emailSender = emailSender;
            _appContext = context;

            this.Tipo = TipoUsuario.Default;
            var UsuarioGrupo = contextAccessor.HttpContext.Session.GetObject<UsuarioGrupoViewModel>("UsuarioGrupo");

            if (UsuarioGrupo != null)
            {
                this.Tipo = UsuarioGrupo.Tipo;
            }
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public override async Task<IActionResult> Edit(long? id)
        {
            if (id == null)
            {
                ControllerContext.HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Validation, "[edit] Operação Inválida.", ControllerContext));
                return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
            }
            
            var myObject = await _context.Set<Usuario>().SingleOrDefaultAsync(m => m.ID == id && m.EmpresaID == _empresaId);
            if (myObject == null)
            {
                return NotFound();
            }
           
            var user = await _context.Set<ApplicationUser>().SingleOrDefaultAsync(m => m.Id == myObject.UserId);
            if (user != null)
            {
                myObject.CPF = user.UserName; 
            }

            LoadViewBag();
            LoadViewBag(myObject);
            return View(myObject);
        }


        protected override void LoadViewBag()
        {
            var ResultGrupo = _context.GrupoUsuario.AsNoTracking().Where(x => x.Habilitado);
            ViewBag.ListaGrupo = ResultGrupo;
        }

        public override async Task<IActionResult> Create(Usuario o)
        {
            if (Tipo == Library.TipoUsuario.AdminEmpresa || Tipo == Library.TipoUsuario.Fornecedor)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        var _user = await _userManager.FindByNameAsync(o.CPF);

                        if (_user == null)
                        {
                            var user = new ApplicationUser
                            {
                                UserName = o.CPF,
                                Email = o.Email
                            };

                            var result = await _userManager.CreateAsync(user, "portal1973");
                            if (result.Succeeded)
                            {
                                //bloqueia usuario para forçar a alterar senha
                                user.EmailConfirmed = false;
                                user.LockoutEnd = new DateTime(2099, 12, 31);
                                user.LastLoginDate = null;
                                await _userManager.UpdateAsync(user);

                                //salva usuário
                                o.UserId = user.Id;
                                o.Senha = user.PasswordHash;
                                o.Tipo = Library.TipoUsuario.Normal;
                                o.EmpresaID = _empresaId;
                                o.InsertDate = DateTime.Now;
                                o.UsuarioOrigemID = _usuario.ID;
                                _context.Add(o);
                                await _context.SaveChangesAsync();

                                //salva grupo dos usuarios
                                string[] GrupoUsuarioID = Request.Form["GrupoUsuarioID"];
                                if (GrupoUsuarioID != null)
                                {
                                    for (int i = 0; i < GrupoUsuarioID.Length; i++)
                                    {
                                        if (!string.IsNullOrEmpty(GrupoUsuarioID[i]))
                                        {
                                            UsuarioGrupo UsuarioGrupo = new UsuarioGrupo();
                                            UsuarioGrupo.GrupoUsuarioID = Convert.ToInt32(GrupoUsuarioID[i]);
                                            UsuarioGrupo.UsuarioID = o.ID;
                                            UsuarioGrupo.EmpresaID = _empresaId;
                                            UsuarioGrupo.Habilitado = true;
                                            _appContext.Add(UsuarioGrupo);
                                        }
                                    }
                                }
                                
                                //salva empresa usuário
                                UsuarioPessoa up = new UsuarioPessoa();
                                up.EmpresaID = _empresaId;
                                up.Habilitado = true;
                                up.UsuarioID = o.ID;
                                up.InsertDate = DateTime.Now;
                                _appContext.Add(up);
                                await _appContext.SaveChangesAsync();
                                
                                
                                var empresa = _appContext.Empresa.FirstOrDefault(e => e.ID == _empresaId);
                                if (empresa != null)
                                {
                                    UsuarioMail UsuarioMail = new UsuarioMail(_appContext, _userManager, _emailSender, this);
                                    await UsuarioMail.SendConfirmationEmail(Request.Scheme, o.Email, user, empresa, o.Nome);
                                }

                                transaction.Commit();

                                return RedirectToAction(nameof(Index));
                            }

                            foreach (var erro in result.Errors)
                            {
                                ModelState.AddModelError("", erro.Description);
                            }

                        }
                        else
                        {
                            ModelState.AddModelError("CPF", "CPF já cadastrado.");
                        }
                    }
                    catch (Exception ex)
                    {
                        ModelState.AddModelError("", ex.Message);
                    }

                    transaction.Rollback();
                    
                }
            } else
            {
                ModelState.AddModelError("CPF", "Usuário não tem permissão para fazer essa ação");
            }
            LoadViewBag();
            return View(o);
        }
        
        public override async Task<IActionResult> Edit(int id, Usuario o)
        {
            if (Tipo == Library.TipoUsuario.AdminEmpresa || Tipo == Library.TipoUsuario.Fornecedor)
            {
                using (var transaction = _context.Database.BeginTransaction())
                {
                    try
                    {
                        var user = await _userManager.FindByNameAsync(o.CPF);

                        if (user != null)
                        {
                            user.Email = o.Email;
                            o.UserId = user.Id;
                            o.Tipo = Library.TipoUsuario.Normal;

                            if (!o.Habilitado)
                            {
                                user.LockoutEnd = new DateTime(2099, 12, 31);
                            }

                            await _userManager.UpdateAsync(user);

                            //remove os usuários
                            var list = _context.UsuarioGrupo.Where(x => x.UsuarioID.Equals(o.ID));
                            _context.UsuarioGrupo.RemoveRange(list);
                            //salva grupo de usuários
                            string[] GrupoUsuarioID = Request.Form["GrupoUsuarioID"];
                            if (GrupoUsuarioID != null)
                            {
                                for (int i = 0; i < GrupoUsuarioID.Length; i++)
                                {
                                    if (!string.IsNullOrEmpty(GrupoUsuarioID[i]))
                                    {
                                        UsuarioGrupo UsuarioGrupo = new UsuarioGrupo();
                                        UsuarioGrupo.GrupoUsuarioID = Convert.ToInt32(GrupoUsuarioID[i]);
                                        UsuarioGrupo.UsuarioID = id;
                                        UsuarioGrupo.EmpresaID = _empresaId;
                                        UsuarioGrupo.Habilitado = true;

                                        _appContext.Add(UsuarioGrupo);
                                    }
                                }
                                await _appContext.SaveChangesAsync();
                            }

                            await base.EditSaveData(o);

                            transaction.Commit();

                            return RedirectToAction(nameof(Index));

                        }
                    }
                    catch (Exception ex)
                    {
                        ModelState.AddModelError("", ex.Message);
                    }

                    transaction.Rollback();
                }

            }
            else
            {
                ModelState.AddModelError("CPF", "Usuário não tem permissão para fazer essa ação");
            }

            LoadViewBag();
            return View(o);

        }

        public override async Task<IActionResult> Index()
        {
            List<Usuario> list = new List<Usuario>();
            try
            {
                /*if (_usuario.Tipo == Library.TipoUsuario.AdminEmpresa)
                {
                    list = await (from UsuarioEmpresa u in _context.UsuarioEmpresa.AsNoTracking().Include(x=>x.Usuario)
                                  join ApplicationUser au in _context.Users.AsNoTracking() on u.Usuario.UserId equals au.Id
                                  where u.EmpresaID == _empresaId
                                  select new Usuario
                                  {
                                      ID = u.Usuario.ID,
                                      Nome = u.Usuario.Nome,
                                      Email = u.Usuario.Email,
                                      Habilitado = u.Habilitado,
                                      CPF = au.UserName,
                                      EmpresaID = u.Usuario.EmpresaID,
                                      GrupoUsuarioID = u.Usuario.GrupoUsuarioID
                                  }
                                      ).ToListAsync();
                }*/


                //TODO revisar metodo
                list = await (from Usuario u in _context.Usuario.AsNoTracking()
                              join ApplicationUser au in _context.Users.AsNoTracking() on u.UserId equals au.Id
                              where u.EmpresaID == _empresaId && (u.UsuarioOrigemID.HasValue && u.UsuarioOrigemID.Value == _usuario.ID)
                              select new Usuario
                                  {
                                      ID = u.ID,
                                      Nome = u.Nome,
                                      Email = u.Email,
                                      Habilitado = u.Habilitado,
                                      CPF = au.UserName,
                                      EmpresaID = u.EmpresaID,
                                      GrupoUsuarioID = u.GrupoUsuarioID
                                  }
                              ).ToListAsync();

            } catch (Exception ex)
            {
                var msg = ex.Message;
            }
            return View(list);
        }


        public async Task<IActionResult> ResetEmailAsync(int id)
        {
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    var usuario = _appContext.Usuario.FirstOrDefault(e => e.ID == id && e.EmpresaID == _empresaId);

                    if (usuario != null)
                    {
                        var _user = await _context.Set<ApplicationUser>().AsNoTracking().SingleOrDefaultAsync(m => m.Id == usuario.UserId);
                        if (_user != null)
                        {
                            var user = await _userManager.FindByNameAsync(_user.UserName);

                            if (user != null)
                            {
                                //bloqueia usuario para forçar a alterar senha
                                user.EmailConfirmed = false;
                                user.LockoutEnd = new DateTime(2099, 12, 31);
                                user.LastLoginDate = null;
                                await _userManager.UpdateAsync(user);

                                var empresa = _appContext.Empresa.FirstOrDefault(e => e.ID == _empresaId);
                                if (empresa != null)
                                {
                                    UsuarioMail UsuarioMail = new UsuarioMail(_appContext, _userManager, _emailSender, this);
                                    await UsuarioMail.SendConfirmationEmail(Request.Scheme, usuario.Email, user, empresa, usuario.Nome);
                                    transaction.Commit();
                                    return Json(new { Ok = true, Mensagem = "Senha alterada com sucesso." });
                                }
                            }
                        }
                    }

                }
                catch (Exception ex)
                {
                    var msg = ex.Message;
                }
                transaction.Commit();
                return Json(new { Ok = false, Mensagem = "Erro ao alterar senha." });
            }
        }

           

        /*
         * if (_user != null) //TODO VALIDAR cenario 
                    {
                        var usuario = from Usuario u in _context.Usuario
                                       where u.UserId == _user.Id
                                       select u;

                        if (usuario.Any())
                        {
                           //verifica usuário ativo
                           //caso tiver ativo verifica se ele originou de um usuario diferente do atual
                           if (usuario.First().Habilitado )
                           {
                                //desabilita usuário
                                _user.LockoutEnd = new DateTime(2099, 12, 31);
        await _userManager.UpdateAsync(_user);

        _context.Entry(usuario.First()).State = EntityState.Modified;
                                usuario.First().LastEditDate = DateTime.Now;
                                usuario.First().Habilitado = false;

                                _context.Update(usuario);

                                try
                                {
                                    await _context.SaveChangesAsync();
        userok = true;
                                }
                                catch (Exception ex)
                                {
                                    ModelState.AddModelError("", ex.Message);
                                    transaction.Rollback();
                                    LoadViewBag();
                                    return View(o);
}
                            }
                        }
                    }
         */
    }

}
