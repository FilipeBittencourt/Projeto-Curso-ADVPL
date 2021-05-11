using Facile.BusinessPortal.Library.Mail;
using System.Text.Encodings.Web;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.BusinessRules.Extensions
{
    public static class EmailSenderExtensions
    {
        public static Task SendEmailConfirmationAsync(this IEmailSender emailSender, string email, string link, string html = "", MailStruct mparams = null, string nomeEmpresa = "")
        {
            return emailSender.SendEmailConfirmation(email, HtmlEncoder.Default.Encode(link), html, mparams, nomeEmpresa);
        }
    }
}
