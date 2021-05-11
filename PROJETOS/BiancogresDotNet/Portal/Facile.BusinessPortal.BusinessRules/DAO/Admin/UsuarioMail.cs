using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;
using Facile.BusinessPortal.Library.Mail;
using Microsoft.AspNetCore.Identity;
using Facile.BusinessPortal.Library.Security;
using Facile.BusinessPortal.BusinessRules.Util;
using Microsoft.AspNetCore.Mvc;
using Facile.BusinessPortal.BusinessRules.Extensions;

namespace Facile.BusinessPortal.BusinessRules.DAO.Admin
{
    public class UsuarioMail
    {
        private FBContext _db;
        private UserManager<ApplicationUser> _userManager;
        private IEmailSender _emailSender;
        private ControllerBase _controller;

        public UsuarioMail(FBContext db, UserManager<ApplicationUser> userManager, IEmailSender emailSender, ControllerBase controller)
        {
            this._db = db;
            this._emailSender = emailSender;
            this._userManager = userManager;
            this._controller = controller;
        }


        public async Task<bool> SendConfirmationEmail(string RequestScheme, string email, ApplicationUser user, Empresa empresa = null, string nomeUsuario = "")
        {
            try
            {
             MailStruct mparams = null;
                if (empresa != null)
                {
                    var qperfil = from PerfilEmpresa p in _db.PerfilEmpresa
                                  where p.EmpresaID == empresa.ID
                                  select p;

                    if (qperfil.Any() && qperfil.First().UseCustomMailServer)
                    {
                        var perfil = qperfil.First();

                        //conta de e-mail geral da empresa
                        var qmail = from Mail m in _db.Mail
                                    where m.EmpresaID == empresa.ID &&
                                    !m.UnidadeID.HasValue
                                    select m;

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
                                EmailCCO = mail.EmailCCO
                            };
                        }
                    }
                }

                var qusuarioBase = from Usuario u in _db.Usuario
                                   where u.UserId == user.Id
                                   select u;

                if (qusuarioBase.Any())
                {
                    
                    var code = await _userManager.GenerateEmailConfirmationTokenAsync(user);
                    var callbackUrl = _controller.Url.EmailConfirmationLink(user.Id, code, RequestScheme, "ConfirmEmail");

                    var token = RandonGenerator.RandomString(10, false) + RandonGenerator.RandomNumber(100000, 999999).ToString();

                    var usuarioBase = qusuarioBase.First();
                    usuarioBase.TokenConfirm = token;
                    usuarioBase.TokenValid = DateTime.Now.AddHours(24);
                    await _db.SaveChangesAsync();

                    var html = HtmlAdminMail.GetHtmlConfirmMail(_db, Library.TipoEmail.ConfirmacaoEmail, empresa, user.UserName, nomeUsuario, token, callbackUrl);

                   
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
    }
}
