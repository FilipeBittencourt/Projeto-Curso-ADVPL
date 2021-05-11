using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;

namespace Facile.BusinessPortal.BusinessRules.Util
{
    public static class HtmlAdminMail
    {
        public static string GetHtmlConfirmMail(FBContext _context, TipoEmail tipo, Empresa empresa, string userLogin, string userName, string token, string linkconfirm)
        {
            var html = new StringBuilder();
            CultureInfo culture = new CultureInfo("pt-BR");
            string dia = DateTime.Now.Day.ToString();
            string ano = DateTime.Now.Year.ToString();
            string mes = culture.TextInfo.ToTitleCase(culture.DateTimeFormat.GetMonthName(DateTime.Now.Month));

            var qlayout = _context.LayoutEmail.Where(o => o.EmpresaID == empresa.ID && o.TipoEmail == tipo);

            if (qlayout.Any())
            {
                var layout = qlayout.First();

                var perfil = _context.PerfilEmpresa.FirstOrDefault(o => o.EmpresaID == empresa.ID);

                var head = "<html><head><title>" + layout.Titulo.Trim() + "</title><style></style></head>";

                html.Append(head);

                var body = LibraryUtil.BytesToString(layout.BodyHtml);

                if (perfil != null)
                    body = body.Replace("@NOMEPLATAFORMA", perfil.Descricao_Reduzida_Portal);
                else
                    body = body.Replace("@NOMEPLATAFORMA", "Facile Cloud Apps");

                body = body.Replace("@EMPRESA.NOME", empresa.NomeEmpresa.ToUpper().Trim());

                body = body.Replace("@EMPRESA.TELEFONE", perfil.TelefoneContato.Trim());

                body = body.Replace("@DATAPOREXTENSO", dia + " de " + mes + " de " + ano);

                body = body.Replace("@USUARIO.LOGIN", userLogin.ToUpper().Trim());

                body = body.Replace("@USUARIO.NOME", userName.ToUpper().Trim());

                body = body.Replace("@TOKEN", token);

                body = body.Replace("@CONFIRMLINK", linkconfirm);

                if (!string.IsNullOrWhiteSpace(layout.LinkFaleConosco))
                    body = body.Replace("@LINK.FALECONOSCO", "'" + layout.LinkFaleConosco + "'");

                if (!string.IsNullOrWhiteSpace(layout.LinkImagem01))
                    body = body.Replace("@LINK.IMAGEM01", "'" + layout.LinkImagem01 + "'");

                if (!string.IsNullOrWhiteSpace(layout.LinkImagem02))
                    body = body.Replace("@LINK.IMAGEM02", "'" + layout.LinkImagem02 + "'");

                if (!string.IsNullOrWhiteSpace(layout.LinkImagem03))
                    body = body.Replace("@LINK.IMAGEM03", "'" + layout.LinkImagem03 + "'");

                if (!string.IsNullOrWhiteSpace(layout.LinkPinterest))
                    body = body.Replace("@LINK.PINTEREST", "'" + layout.LinkPinterest + "'");

                if (!string.IsNullOrWhiteSpace(layout.LinkInstagram))
                    body = body.Replace("@LINK.INSTAGRAM", "'" + layout.LinkInstagram + "'");

                if (!string.IsNullOrWhiteSpace(layout.LinkFacebook))
                    body = body.Replace("@LINK.FACEBOOK", "'" + layout.LinkFacebook + "'");

                if (!string.IsNullOrWhiteSpace(layout.LinkYoutube))
                    body = body.Replace("@LINK.YOUTUBE", "'" + layout.LinkYoutube + "'");

                html.Append(body);

                html.Append("</html>");
            }


            return html.ToString();
        }

    }
}
