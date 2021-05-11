using System;
using System.Globalization;
using System.Text;

namespace Facile.BusinessPortal.Library.Mail
{
    public static class MailHtml
    {
        public static string GetHtmlConfirmEmail(string confirmLink)
        {
            string html = string.Empty;

            html += "<p style='text-align:center'><img height='112' src='' width='301'/></p>";
            html += "<h2>Confirma&ccedil;&atilde;o de E-mail</h2>";
            html += "<p>Este é um e-mail de confirmação de cadastro no portal.facilecloud.com.br</p>";
            html += "<p> Clique no link abaixo para come&ccedil;ar a usar os recursos da plataforma:</p>";
            html += "<a href='" + confirmLink + "'>Clique aqui para confirmar seu cadastro.</a>";
            html += "<p> Se voc&ecirc; n&atilde;o se cadastrou em facilecloud.com.br, pode ignorar este e-mail, este cadastro vai ser automaticamente removido.</p>";

            return html;
        }

        public static string GetHtmlErrorEmail(string title, string description, string details = "", string userId = "", string controller = "", string action = "", string requestPath = "")
        {
            string html = string.Empty;

            html += "<h2>" + title + "</h2>";
            html += "<h4> Usuário: " + userId + "</h4>";
            html += "<h4> Path: " + requestPath + "</h4>";
            html += "<h4> Controller: " + controller + "</h4>";
            html += "<h4> Action: " + action + "</h4>";
            html += "<br/>";
            html += "<h5>" + description + "</h5>";
            html += "<h6>" + details + "</h6>";

            return html;
        }

       
    }
}
