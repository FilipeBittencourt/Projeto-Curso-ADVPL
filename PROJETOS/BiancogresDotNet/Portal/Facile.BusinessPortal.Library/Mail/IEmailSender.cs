using System.Threading.Tasks;

namespace Facile.BusinessPortal.Library.Mail
{
    public interface IEmailSender
    {
        Task SendEmail(string email, string subject, string message);
        Task SendEmailConfirmation(string email, string link, string html = "", MailStruct mparams = null, string nomeEmpresa = "");
    }
}
