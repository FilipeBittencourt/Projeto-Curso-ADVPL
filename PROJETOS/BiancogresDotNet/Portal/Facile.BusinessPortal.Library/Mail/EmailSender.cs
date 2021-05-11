using System;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.Library.Mail
{
    // This class is used by the application to send email for account confirmation and password reset.
    // For more details see https://go.microsoft.com/fwlink/?LinkID=532713
    public class EmailSender : IEmailSender
    {
        public Task SendEmailConfirmation(string email, string link, string html = "", MailStruct mparams = null, string nomeEmpresa = "")
        {
            try
            {
                var mail = MailUtil.ConnectMail(mparams);

                var emailCC = mparams != null ? mparams.EmailCC : "";
                var emailCCO = mparams != null ? mparams.EmailCCO : "";

                var mailret = MailUtil.SendConfirmartionEmail(mail, html, email, link, emailCC, emailCCO, nomeEmpresa);

                if (!string.IsNullOrWhiteSpace(mailret))
                {
                    throw new Exception("Falha enviando e-mail de confirmação de cadastro.");
                }

                return Task.CompletedTask;
            }
            catch
            {
                throw new Exception("Falha enviando e-mail de confirmação de cadastro.");
            }
        }

        public Task SendEmail(string email, string subject, string message)
        {
            return Task.CompletedTask;
        }
    }
}
