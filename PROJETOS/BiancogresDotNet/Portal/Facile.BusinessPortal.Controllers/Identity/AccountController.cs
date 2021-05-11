#region Using

using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.BusinessRules.Util;
using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Extensions;
using Facile.BusinessPortal.Library.Mail;
using Facile.BusinessPortal.Library.Security;
using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.ViewModels;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
#endregion

namespace Facile.BusinessPortal.Controllers
{

    [Route("[controller]/[action]")]
    [Layout("_LayoutLogin")]
    public class AccountController : Controller
    {
        private readonly IEmailSender _emailSender;
        private readonly ILogger _logger;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly FBContext _appContext;

        [TempData]
        public string ErrorMessage { get; set; }

        public AccountController(UserManager<ApplicationUser> userManager, SignInManager<ApplicationUser> signInManager, IEmailSender emailSender, ILogger<AccountController> logger, FBContext context)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _emailSender = emailSender;
            _logger = logger;
            _appContext = context;
        }

        public IActionResult Index()
        {
            return View();
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> Login(List<string> reterros = null, bool isMailConfirmed = true)
        {
            // Clear the existing external cookie to ensure a clean login process
            HttpContext.Session.SetString("CurrentUserName", string.Empty);
            await HttpContext.SignOutAsync(IdentityConstants.ExternalScheme);

            ViewBag.ListRetMessage = reterros;
            ViewBag.IsEmailConfirmed = isMailConfirmed;

            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            bool goconfirmemail = false;
            List<string> reterros = new List<string>();

            if (ModelState.IsValid)
            {
                var user = await _userManager.FindByNameAsync(model.Usuario);

                if (user == null)
                {
                    reterros.Add("Tentativa de login inválida, verifique seu usuário e senha informados.");
                    return RedirectToAction(nameof(Login), new { reterros });
                }

                var qusuarioBase = from Usuario u in _appContext.Usuario
                                   where u.UserId == user.Id
                                   select u;

                if (!qusuarioBase.Any())
                {
                    reterros.Add("Tentativa de login inválida, verifique seu usuário e senha informados.");
                    return RedirectToAction(nameof(Login), new { reterros });
                }

                var usuarioBase = qusuarioBase.First();

                var emailconfirmed = await _userManager.IsEmailConfirmedAsync(user);
                if (!emailconfirmed)
                {
                    if (string.IsNullOrWhiteSpace(model.Token))
                    {
                        await _signInManager.SignOutAsync();
                        reterros.Add("E-mail não confirmado - verifique sua caixa de e-mail e informe o Token de segurança recebido.");
                        goconfirmemail = true;
                        return RedirectToAction(nameof(Login), new { reterros, isMailConfirmed = !goconfirmemail });
                    }
                    else
                    {
                        if (usuarioBase.TokenConfirm.Trim() == model.Token.Trim() && usuarioBase.TokenValid >= DateTime.Now)
                        {
                            user.EmailConfirmed = true;
                            await _userManager.UpdateAsync(user);

                            reterros.Add("E-mail " + user.Email + " confirmado com sucesso. Por favor cadastre sua nova senha.");
                            return RedirectToAction(nameof(ResetPassword), new { reterros, code = usuarioBase.TokenConfirm });
                        }
                        else
                        {
                            reterros.Add("E-mail não confirmado - TOKEN inválido ou vencido.");
                            goconfirmemail = true;
                            return RedirectToAction(nameof(Login), new { reterros, isMailConfirmed = !goconfirmemail });
                        }
                    }
                }
                else
                {
                    var result = await _signInManager.PasswordSignInAsync(model.Usuario, model.Password, model.RememberMe, lockoutOnFailure: false);

                    if (result.Succeeded)
                    {
                        _logger.LogInformation("User logged in.");

                        //usuario fez login pela ultima vez a mais de 90 dias
                        if (user.LastLoginDate.HasValue && user.LastLoginDate.Value < DateTime.Today.AddDays(-90))
                        {
                            //bloqueia usuario para forçar a alterar senha                    
                            user.EmailConfirmed = false;
                            user.LockoutEnd = new DateTime(2099, 12, 31);
                            user.LastLoginDate = null;
                            await _userManager.UpdateAsync(user);

                            //Se a Empresa estiver em Homologação não enviar e-mail para usuário
                            var mailToken = user.Email;
                            if (usuarioBase.Empresa.Homologacao)
                                mailToken = usuarioBase.Empresa.EmailHomologacao;

                            if (await SendConfirmationEmail(mailToken, user, usuarioBase.Empresa, user.UserName))
                            {
                                reterros.Add("Usuário bloqueado, e-mail de confirmação enviado para: " + user.Email);
                            }
                            else
                            {
                                reterros.Add("Usuário bloqueado, Erro enviando e-mail de confirmação - contate a empresa.");
                            }

                            return RedirectToAction(nameof(Login), new { reterros });
                        }

                        user.LastLoginDate = DateTime.Now;
                        await _userManager.UpdateAsync(user);

                        if (!AccessControl.SaveLastLogin(_appContext, user.Id))
                        {
                            await _signInManager.SignOutAsync();
                            var resultex = IdentityResult.Failed(new IdentityError[] { new IdentityError() { Description = "Erro ao efetuar Login - contate a empresa" } });
                            AddErrors(resultex);
                        }
                        else
                        {
                            //TODO Testar tipo de usuário
                            HttpContext.Session.SetString("u_username", model.Usuario);
                            HttpContext.Session.SetString("u_email", user.Email);

                            return RedirectToAction("Index", "Home");
                        }
                    }
                    else
                    {
                        if (result.IsLockedOut)
                        {
                            if (!string.IsNullOrWhiteSpace(usuarioBase.TokenConfirm) && usuarioBase.TokenValid >= DateTime.Now)
                            {
                                reterros.Add("E-mail " + user.Email + " confirmado com sucesso. Por favor cadastre sua nova senha.");
                                return RedirectToAction(nameof(ResetPassword), new { reterros, code = usuarioBase.TokenConfirm });
                            }
                            else
                            {
                                reterros.Add("Conta do usuário está bloqueada.");
                            }
                        }
                        else
                        {
                            reterros.Add("Usuário ou senha incorreto.");
                        }
                    }
                }
            }

            // If we got this far, something failed, redisplay form
            IEnumerable<ModelError> allErrors = ModelState.Values.SelectMany(v => v.Errors);

            foreach (ModelError error in allErrors)
            {
                reterros.Add(error.ErrorMessage);
            }

            return RedirectToAction(nameof(Login), new { reterros, isMailConfirmed = !goconfirmemail });
        }

        [HttpGet]
        public IActionResult Lockout()
        {
            return View();
        }

        [HttpGet]
        public IActionResult Register()
        {
            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        public async Task<ApplicationUserReturn> SetUserStatusJson([FromBody]ChangeUserModel model)
        {
            var user = new ApplicationUser
            {
                UserName = model.UserName.Trim(),
                Email = model.Email.Trim(),
                SecurityStamp = ""
            };

            if (model.ClientAuth == null)
                return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO SetUserStatusJson USUARIO: AUTENTICAÇÃO - V1"));

            if (!Guid.TryParse(model.ClientAuth.Client_Key, out var guid))
                return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO SetUserStatusJson USUARIO: AUTENTICAÇÃO - V2"));

            var qemp = from Unidade u in _appContext.Unidade
                       where u.Secret_Key == model.ClientAuth.Secret_Key &&
                       u.Empresa.Client_Key == guid &&
                       u.CNPJ == model.ClientAuth.CNPJ
                       select u;

            if (!qemp.Any())
                return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO SetUserStatusJson USUARIO: AUTENTICAÇÃO - V3"));

            using (var transaction = _appContext.Database.BeginTransaction())
            {
                try
                {
                    var usermodel = await _userManager.FindByNameAsync(model.UserName);
                    if (usermodel == null)
                    {
                        transaction.Rollback();
                        return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO SetUserStatusJson USUARIO NAO ENCONTRADO."));
                    }

                    if (!model.IsLocked)
                        usermodel.LockoutEnd = new DateTime(9999, 12, 31);
                    else
                        usermodel.LockoutEnd = DateTimeOffset.Now.AddMinutes(-1);

                    IdentityResult result;

                    if (!usermodel.LockoutEnabled)
                        await _userManager.SetLockoutEnabledAsync(usermodel, true);

                    result = await _userManager.SetLockoutEndDateAsync(usermodel, usermodel.LockoutEnd);

                    if (result.Succeeded)
                    {
                        _logger.LogInformation("Usuário alterado com sucesso: " + user.Id);

                        try
                        {
                            var parms = new ContextParams(HttpContext, _appContext, model.ClientAuth.CNPJ);
                            await UsuarioDAO.ChangeUsuarioAsync(parms, model, usermodel.Id);
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO SetUserStatusJson USUARIO BASE: " + ErroUtil.GetTextoCompleto(ex)));
                        }

                        transaction.Commit();

                        var ret = new ApplicationUserReturn()
                        {
                            Ok = true,
                            UserName = user.UserName,
                            Email = user.Email,
                            Id = usermodel.Id
                        };

                        return ret;
                    }
                    else
                    {
                        transaction.Rollback();

                        string erros = "";
                        foreach (var erro in result.Errors)
                            erros += erro.Description ?? "" + Environment.NewLine;

                        return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO RESULT SetUserStatusJson: " + erros));
                    }
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO SetUserStatusJson: " + ErroUtil.GetTextoCompleto(ex)));
                }
            }
        }

        [HttpPost]
        [AllowAnonymous]
        public async Task<ApplicationUserReturn> RegisterJson([FromBody]CreateUserModel model)
        {
            var user = new ApplicationUser
            {
                UserName = model.UserName.Trim(),
                Email = model.Email.Trim()
            };

            if (model.ClientAuth == null)
                return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO CRIANDO USUARIO: AUTENTICAÇÃO - V1"));

            if (!Guid.TryParse(model.ClientAuth.Client_Key, out var guid))
                return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO CRIANDO USUARIO: AUTENTICAÇÃO - V2"));

            var qemp = from Unidade u in _appContext.Unidade
                       where u.Secret_Key == model.ClientAuth.Secret_Key &&
                       u.Empresa.Client_Key == guid &&
                       u.CNPJ == model.ClientAuth.CNPJ
                       select u;

            if (!qemp.Any())
                return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO CRIANDO USUARIO: AUTENTICAÇÃO - V3"));

            //VERIFICANDO SE JA EXISTE USUARIO PELO EMAIL E DEVOLVE O MESMO USUARIO JA CADASTRADO
            var usermodel = await _userManager.FindByNameAsync(model.UserName);
            if (usermodel != null)
            {
                var ret = new ApplicationUserReturn()
                {
                    Ok = true,
                    UserName = usermodel.UserName,
                    Email = usermodel.Email,
                    Id = usermodel.Id
                };

                return ret;
            }

            using (var transaction = _appContext.Database.BeginTransaction())
            {
                try
                {
                    if (string.IsNullOrWhiteSpace(model.Password))
                        model.Password = "portal1973";  //senha padrao para criacao de usuario novo - vai ser alterada no primeiro login
                    
                    var result = await _userManager.CreateAsync(user, model.Password);

                    if (result.Succeeded)
                    {
                        await _userManager.SetLockoutEndDateAsync(user, DateTime.Today.AddDays(-1));

                        _logger.LogInformation("Usuário criado com sucesso: " + user.Id);

                        ///Se a Empresa estiver em Homologação não enviar e-mail para usuário
                        var mailToken = model.Email;
                        if (qemp.First().Empresa.Homologacao)
                            mailToken = qemp.First().Empresa.EmailHomologacao;

                        try
                        {
                            var parms = new ContextParams(HttpContext, _appContext, model.ClientAuth.CNPJ);
                            await UsuarioDAO.CreateUsuarioAsync(parms, model, user.Id);
                            UsuarioDAO.AddUsuarioGrupo(parms, user.Id, model.GrupoID);
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO CRIANDO USUARIO BASE: " + ErroUtil.GetTextoCompleto(ex)));
                        }

                        if (await SendConfirmationEmail(mailToken, user, qemp.First().Empresa, model.Nome))
                        {
                            //Bloquear o usuário até o reset da senha
                            //bloqueia usuario para forçar a alterar senha
                            user.EmailConfirmed = false;
                            user.LockoutEnd = new DateTime(2099, 12, 31);
                            user.LastLoginDate = null;
                            await _userManager.UpdateAsync(user);

                            _logger.LogInformation("Email de confirmação enviado com sucesso para: " + model.Email);
                        }
                        else
                        {
                            transaction.Rollback();
                            return (ApplicationUserReturn.Erro(user.UserName, user.Email, "Erro enviando e-mail de confirmação - contate o beneficiário."));
                        }

                        transaction.Commit();

                        var ret = new ApplicationUserReturn()
                        {
                            Ok = true,
                            UserName = user.UserName,
                            Email = user.Email,
                            Id = user.Id
                        };

                        return ret;
                    }
                    else
                    {
                        transaction.Rollback();

                        string erros = "";
                        foreach (var erro in result.Errors)
                            erros += erro.Description ?? "" + Environment.NewLine;

                        return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO CRIANDO USUARIO: " + erros));
                    }
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO CRIANDO USUARIO: " + ErroUtil.GetTextoCompleto(ex)));
                }
            }
        }

        [HttpGet]
        public async Task<ApplicationUserReturn> RegisterOrResetAsync(long empresaId, long pessoaId, TipoUsuario tipo)
        {

            var empresa = _appContext.Empresa.FirstOrDefault(e => e.ID == empresaId);

            Pessoa pessoa = null;
            long grupoId = 0;

            if (tipo == TipoUsuario.Cliente)
            {
                pessoa = _appContext.Sacado.Include(x => x.Empresa).FirstOrDefault(e => e.ID == pessoaId);
                
                if (pessoa.Empresa.Homologacao)
                {
                    pessoa.Email = pessoa.Empresa.EmailHomologacao;
                }

                var grupo = _appContext.GrupoUsuario.EmpData(empresa.ID).FirstOrDefault(o => o.Tipo == TipoGrupoUsuario.Cliente);

                if (grupo == null)
                {
                    return (ApplicationUserReturn.Erro("", "", "Erro com os dados informados."));
                }
                else
                    grupoId = grupo.ID;
            }
            else if (tipo == TipoUsuario.Fornecedor)
            {
                pessoa = _appContext.Fornecedor.Include(x => x.Empresa).FirstOrDefault(e => e.ID == pessoaId);
                var RetEmail = pessoa.EmailWorkflow.Split(';');
                if (RetEmail.Length > 0)
                {
                    pessoa.Email = RetEmail[0];
                    if (pessoa.Empresa.Homologacao)
                    {
                        pessoa.Email = pessoa.Empresa.EmailHomologacao;
                    }
                }

                var grupo = _appContext.GrupoUsuario.EmpData(empresa.ID).FirstOrDefault(o => o.Tipo == TipoGrupoUsuario.Fornecedor);

                if (grupo == null)
                {
                    return (ApplicationUserReturn.Erro("", "", "Erro com os dados informados."));
                }
                else
                    grupoId = grupo.ID;
            }

            if (empresa == null || pessoa == null)
            {
                return (ApplicationUserReturn.Erro("", "", "Erro com os dados informados."));
            }

            var model = new CreateUserModel()
            {
                UserName = pessoa.CPFCNPJ,
                Email = pessoa.Email,
                Nome = pessoa.Nome,
                GrupoID = grupoId,
                Tipo = tipo
            };

            if (string.IsNullOrWhiteSpace(model.Password))
                model.Password = "portal1973";  //senha padrao para criacao de usuario novo - vai ser alterada no primeiro login

            //VERIFICANDO SE JA EXISTE USUARIO PELO EMAIL E DEVOLVE O MESMO USUARIO JA CADASTRADO
            var usermodel = await _userManager.FindByNameAsync(model.UserName);
            if (usermodel != null)
            {
                try
                {
                    _logger.LogInformation("Usuário criado com sucesso: " + usermodel.Id);

                    //bloqueia usuario para forçar a alterar senha                    
                    usermodel.EmailConfirmed = false;
                    usermodel.LockoutEnd = new DateTime(2099, 12, 31);
                    usermodel.LastLoginDate = null;
                    await _userManager.UpdateAsync(usermodel);

                    //Se a Empresa estiver em Homologação não enviar e-mail para usuário
                    var mailToken = model.Email;
                    
                    //TODO remover ambiente produção
                   // mailToken = "teste@teste.com";

                    if (empresa.Homologacao)
                        mailToken = empresa.EmailHomologacao;

                    try
                    {
                        var usuario = await UsuarioDAO.CreateUsuarioEmpAsync(_appContext, empresa, model, usermodel.Id, pessoa.ID);
                        UsuarioDAO.AddUsuarioGrupo(_appContext, usermodel.Id, model.GrupoID);
                    }
                    catch (Exception ex)
                    {
                        return (ApplicationUserReturn.Erro(usermodel.UserName, usermodel.Email, "ERRO CRIANDO USUARIO BASE: " + ErroUtil.GetTextoCompleto(ex)));
                    }

                    if (await SendConfirmationEmail(mailToken, usermodel, empresa, model.Nome))
                    {
                        _logger.LogInformation("Email de confirmação enviado com sucesso para: " + model.Email);
                    }
                    else
                    {
                        return (ApplicationUserReturn.Erro(usermodel.UserName, usermodel.Email, "Erro enviando e-mail de confirmação - contate o beneficiário."));
                    }

                    var ret = new ApplicationUserReturn()
                    {
                        Ok = true,
                        UserName = usermodel.UserName,
                        Email = usermodel.Email,
                        Id = usermodel.Id
                    };

                    return ret;
                }
                catch (Exception ex)
                {
                    return (ApplicationUserReturn.Erro(usermodel.UserName, usermodel.Email, "ERRO CRIANDO USUARIO: " + ErroUtil.GetTextoCompleto(ex)));
                }
            }
            else
            {
                using (var transaction = _appContext.Database.BeginTransaction())
                {
                    var user = new ApplicationUser
                    {
                        UserName = model.UserName.Trim(),
                        Email = model.Email.Trim()
                    };

                    try
                    {
                        var result = await _userManager.CreateAsync(user, model.Password);

                        if (result.Succeeded)
                        {
                            //bloqueia usuario para forçar a alterar senha
                            user.EmailConfirmed = false;
                            user.LockoutEnd = new DateTime(2099, 12, 31);
                            user.LastLoginDate = null;
                            await _userManager.UpdateAsync(user);

                            _logger.LogInformation("Usuário criado com sucesso: " + user.Id);

                            ///Se a Empresa estiver em Homologação não enviar e-mail para usuário
                            var mailToken = model.Email;
                            //TODO remover ambiente produção
                            //mailToken = "teste@teste.com";

                            if (empresa.Homologacao)
                                mailToken = empresa.EmailHomologacao;

                            try
                            {
                                var usuario = await UsuarioDAO.CreateUsuarioEmpAsync(_appContext, empresa, model, user.Id, pessoa.ID);
                            }
                            catch (Exception ex)
                            {
                                transaction.Rollback();
                                return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO CRIANDO USUARIO BASE: " + ErroUtil.GetTextoCompleto(ex)));
                            }

                            if (await SendConfirmationEmail(mailToken, user, empresa, model.Nome))
                            {
                                _logger.LogInformation("Email de confirmação enviado com sucesso para: " + model.Email);
                            }
                            else
                            {
                                transaction.Rollback();
                                return (ApplicationUserReturn.Erro(user.UserName, user.Email, "Erro enviando e-mail de confirmação - contate o beneficiário."));
                            }

                            transaction.Commit();

                            var ret = new ApplicationUserReturn()
                            {
                                Ok = true,
                                UserName = user.UserName,
                                Email = user.Email,
                                Id = user.Id
                            };

                            return ret;
                        }
                        else
                        {
                            transaction.Rollback();

                            string erros = "";
                            foreach (var erro in result.Errors)
                                erros += erro.Description ?? "" + Environment.NewLine;

                            return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO CRIANDO USUARIO: " + erros));
                        }
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        return (ApplicationUserReturn.Erro(user.UserName, user.Email, "ERRO CRIANDO USUARIO: " + ErroUtil.GetTextoCompleto(ex)));
                    }
                }
            }
        }

        private async Task<bool> SendConfirmationEmail(string email, ApplicationUser user, Empresa empresa = null, string nomeUsuario = "")
        {
            try
            {
                var qusuarioBase = from Usuario u in _appContext.Usuario
                                   where u.UserId == user.Id
                                   select u;

                MailStruct mparams = null;
                if (empresa != null)
                {
                    var qperfil = from PerfilEmpresa p in _appContext.PerfilEmpresa
                                  where p.EmpresaID == empresa.ID
                                  select p;

                    if (qperfil.Any() && qperfil.First().UseCustomMailServer)
                    {
                        var perfil = qperfil.First();

                        //conta de e-mail geral da empresa
                        var qmail = from Mail m in _appContext.Mail
                                    where m.EmpresaID == empresa.ID &&
                                    !m.UnidadeID.HasValue
                                    select m;
                        
                        if (qusuarioBase.Any())
                        {
                            var usuarioBase = qusuarioBase.First();
                            if (usuarioBase.Tipo == TipoUsuario.Fornecedor)
                            {
                                qmail = qmail.Where(x=>x.EmailModulo == EmailModulo.Antecipacao);
                            }
                        }

                        if (qmail.Any())
                        {
                            var mail = qmail.First();

                            mparams = new MailStruct()
                            {
                                MailHost = mail.Host,
                                MailPort = mail.Port,
                                MailUser = mail.User,
                                MailPassword = mail.Password,
                                MailSender = mail.SenderEmail,
                                MailDisplayName = mail.SenderDisplayName,
                                EmailCC = mail.EmailCC,
                                EmailCCO = mail.EmailCCO,
                                SSL = mail.SSL
                            };
                        }
                    }
                }

               

                if (qusuarioBase.Any())
                {
                    var code = await _userManager.GenerateEmailConfirmationTokenAsync(user);
                    var callbackUrl = Url.EmailConfirmationLink(user.Id, code, Request.Scheme);

                    var token = RandonGenerator.RandomString(10, false) + RandonGenerator.RandomNumber(100000, 999999).ToString();

                    var usuarioBase = qusuarioBase.First();
                    usuarioBase.TokenConfirm = token;
                    usuarioBase.TokenValid = DateTime.Now.AddHours(24);
                    await _appContext.SaveChangesAsync();

                    var TipoEmail = Library.TipoEmail.ConfirmacaoEmail;
                    if (usuarioBase.Tipo == TipoUsuario.Fornecedor)
                    {
                        TipoEmail = Library.TipoEmail.ConfirmacaoEmailFornecedor;
                    }
                    var html = HtmlAdminMail.GetHtmlConfirmMail(_appContext, TipoEmail, empresa, user.UserName, nomeUsuario, token, callbackUrl);

                    await _emailSender.SendEmailConfirmationAsync(email, callbackUrl, html, mparams, usuarioBase.Empresa.NomeEmpresa);
                    return true;
                }
                else
                    return false;
            }
            catch
            {
                return false;
            }
        }

        [HttpGet]
        public async Task<IActionResult> Logout()
        {
            HttpContext.Session.SetString("CurrentUserName", string.Empty);
            await _signInManager.SignOutAsync();
            _logger.LogInformation("User logged out.");
            return RedirectToAction(nameof(HomeController.Index), "Home");
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> ConfirmEmail(string userId, string code)
        {
            if (userId == null || code == null)
            {
                return RedirectToAction(nameof(HomeController.Index), "Home");
            }
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
            {
                return RedirectToAction(nameof(HomeController.Index), "Home");
            }

            var qusuario = from Usuario u in _appContext.Usuario
                           where u.UserId == user.Id
                           select u;

            if (!qusuario.Any())
            {
                return RedirectToAction(nameof(HomeController.Index), "Home");
            }

            var usuario = qusuario.First();

            var result = await _userManager.ConfirmEmailAsync(user, code);

            if (result.Succeeded)
            {
                var reterros = new List<string> { "E-mail " + user.Email + " confirmado com sucesso. Por favor cadastre sua nova senha." };
                return RedirectToAction(nameof(ResetPassword), new { reterros, code = usuario.TokenConfirm });
            }
            else
                return RedirectToAction(nameof(Login));
        }

        [HttpGet]
        public IActionResult ForgotPassword(List<string> reterros = null)
        {
            ViewBag.ListRetMessage = reterros;
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordViewModel model)
        {
            List<string> reterros = new List<string>();

            if (!ModelState.IsValid)
                return View(model);

            var user = await _userManager.FindByNameAsync(model.Usuario);

            if (user == null)
            {
                //Segurança: Nao revelar que o usuario não existe
                reterros.Add("Email de confirmação enviado para o e-mail cadastrado para este usuário.");
                return RedirectToAction("ForgotPassword", new { reterros });
            }

            var qusuario = from Usuario u in _appContext.Usuario
                           where u.UserId == user.Id
                           select u;

            if (!qusuario.Any())
            {
                //Segurança: Nao revelar que o usuario não existe
                reterros.Add("Email de confirmação enviado para o e-mail cadastrado para este usuário.");
                return RedirectToAction("ForgotPassword", new { reterros });
            }

            var usuario = qusuario.First();
            var empresa = usuario.Empresa;

            var mailToken = usuario.Email;
            if (empresa.Homologacao)
                mailToken = empresa.EmailHomologacao;

            if (await SendConfirmationEmail(mailToken, user, empresa, usuario.Nome))
            {
                reterros.Add("Email de confirmação enviado para o e-mail cadastrado para este usuário.");

                //bloqueia usuario para forçar a alterar senha                    
                user.EmailConfirmed = false;
                user.LockoutEnd = new DateTime(2099, 12, 31);
                user.LastLoginDate = null;
                await _userManager.UpdateAsync(user);
            }
            else
            {
                reterros.Add("Erro enviando e-mail de confirmação - contate o beneficiário.");
            }
            return RedirectToAction("Login", new { reterros });
        }

        [HttpGet]
        public IActionResult AprovaAntecipacaoEmail(string email, string token , string chave)
        {
            return null;
        }


        [HttpGet]
        public IActionResult ResetPassword(List<string> reterros = null, string code = "")
        {
            ViewBag.ListRetMessage = reterros;

            var model = new ResetPasswordViewModel();
            if (!string.IsNullOrWhiteSpace(code))
                model.Token = code;

            return View(model);
        }



        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ResetPassword(ResetPasswordViewModel model)
        {
            List<string> reterros = new List<string>();

            if (!ModelState.IsValid)
            {
                foreach (var value in ModelState.Values)
                {
                    foreach (var erro in value.Errors)
                    {
                        reterros.Add(erro.ErrorMessage);
                    }
                }

                return RedirectToAction(nameof(ResetPassword), new { reterros });
            }

            var user = await _userManager.FindByNameAsync(model.Usuario);
            if (user == null)
            {
                //Segurança: Nao revelar que o usuario não existe
                return RedirectToAction(nameof(Login));
            }

            var qusuario = from Usuario u in _appContext.Usuario
                           where u.UserId == user.Id
                           select u;

            if (!qusuario.Any())
            {
                //Segurança: Nao revelar que o usuario não existe
                return RedirectToAction(nameof(Login));
            }

            var usuario = qusuario.First();

            var code = Request.Form["__RequestVerificationToken"].ToString();

            //Ou verifica digitacao do Token de acesso
            if (!(usuario.TokenConfirm == model.Token) || (usuario.TokenValid < DateTime.Now))
            {
                reterros.Add("Usuário e/ou Token inválido.");
                return RedirectToAction(nameof(Login), new { reterros });
            }

            //alterar a senha
            var resetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
            var result = await _userManager.ResetPasswordAsync(user, resetToken, model.Password);

            if (result.Succeeded)
            {
                //liberar usuario
                result = await _userManager.SetLockoutEndDateAsync(user, DateTime.Today.AddDays(-1));

                if (result.Succeeded)
                {
                    reterros.Add("Nova senha cadastrada com sucesso.");
                    return RedirectToAction(nameof(Login), new { reterros });
                }
            }

            AddErrors(result);
            foreach (var erro in result.Errors)
            {
                reterros.Add(erro.Description);
            }

            return RedirectToAction(nameof(ResetPassword), new { reterros });
        }

        private void AddErrors(IdentityResult result)
        {
            foreach (var error in result.Errors)
            {
                ModelState.AddModelError(string.Empty, error.Description);
            }
        }
    }
}
