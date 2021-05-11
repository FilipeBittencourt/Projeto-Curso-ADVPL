namespace Facile.BusinessPortal.Library.Mail
{
    public class MailUtil
    {
        public static SendMail ConnectMail(MailStruct mparams = null)
        {
            SendMail mail = null;

            var host = "mail.facilesistemas.com.br";
            var port = 587;
            var user = "suporte.biancogres@facilesistemas.com.br";
            var password = "Bi@ncogres";
            var senderEmail = "suporte.biancogres@facilesistemas.com.br";
            var senderDisplayName = "Suporte Facile Cloud Apps";
            var ssl = false;
            var emailCC = "";
            var emailCCO = "";

            if (mparams != null)
            {
                host = mparams.MailHost;
                port = mparams.MailPort;
                user = mparams.MailUser;
                password = mparams.MailPassword;
                senderEmail = mparams.MailSender;
                senderDisplayName = mparams.MailDisplayName;
                ssl = mparams.SSL;
                emailCC = mparams.EmailCC;
                emailCCO = mparams.EmailCCO;
            }

            mail = new SendMail(host, port, user, password, ssl, senderEmail, senderDisplayName, emailCC, emailCCO);

            return mail;
        }

        public static string SendConfirmartionEmail(SendMail mail, string html, string emailDestinatario, string confirmURL, string emailCC = "", string emailCCO = "", string nomeEmpresa = "")
        {
            var send = mail.SenderEmail;

            var destino = emailDestinatario;

            if (string.IsNullOrWhiteSpace(html))
                html = MailHtml.GetHtmlConfirmEmail(confirmURL);

            var mensagem = html;

            var subject = "Confirmação de cadastro no portal " + nomeEmpresa;

            var wfret = mail.EnviaEmailAnexo(send, destino, subject, emailCC, emailCCO, mensagem, "", "", true, mail.SenderDisplayName);

            return wfret.Mensagem;
        }

        public static string SendErrorEmail(SendMail mail, string userId, string title, string description, string details = "", string controller = "", string action = "", string requestPath = "")
        {
            var send = mail.SenderEmail;

            var destino = "suporte@facilesistemas.com.br";

            var html = MailHtml.GetHtmlErrorEmail(title, description, details, userId, controller, action, requestPath);

            var mensagem = html;

            var subject = "ERRO CLOUS APPS SendErrorEmail";

            var wfret = mail.EnviaEmailAnexo(send, destino, subject, "", "suporte@facilesistemas.com.br", mensagem, "", "", true, mail.SenderDisplayName);

            return wfret.Mensagem;
        }
    }
}
