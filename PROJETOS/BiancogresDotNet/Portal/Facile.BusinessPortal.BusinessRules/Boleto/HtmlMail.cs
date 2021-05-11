using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;

namespace Facile.BusinessPortal.BusinessRules.Boleto
{
    public static class HtmlMail
    {

        public static string GetHtmlBody(Model.Cedente cedente, string nomeSacado, List<Financeiro.BoletoNetCore.Boleto> list, Unidade unidade)
        {
            string html = string.Empty;

            CultureInfo culture = new CultureInfo("pt-BR");

            string dia = DateTime.Now.Day.ToString();
            string ano = DateTime.Now.Year.ToString();
            string mes = culture.TextInfo.ToTitleCase(culture.DateTimeFormat.GetMonthName(DateTime.Now.Month));

            html += "<html>" + Environment.NewLine;
            html += "<head>" + Environment.NewLine;
            html += "<title>Workflow Biancogres</title>" + Environment.NewLine;
            html += "<style></style>" + Environment.NewLine;
            html += "</head>" + Environment.NewLine;
            html += "<body>" + Environment.NewLine;
            html += "<img src = 'https://biancogres.com.br/wp-content/uploads/2018/06/logo1-3-1.png' />" + Environment.NewLine;
            html += "<h2>Emissão de Fatura</h2>" + Environment.NewLine;
            html += "<h3><p align = 'right'>" + cedente.Cidade.Trim() + ", " + dia + " de " + mes + " de " + ano + ".</p></h3>" + Environment.NewLine;
            html += "<h3>" + unidade.Nome.ToUpper().Trim() + "</h3>" + Environment.NewLine;
            html += "<b>Informamos a emissão dos boletos bancários referente as Notas Fiscais listadas abaixo:</b>" + Environment.NewLine;

            html += "<br/><br/>" + Environment.NewLine;
            html += "<h2><strong>Prezado Cliente:</strong></h2>" + Environment.NewLine;
            html += "<h4>" + nomeSacado + "</h4>" + Environment.NewLine;
            html += "<h3><strong>Você está recebendo anexo os boletos referentes aos documentos listados abaixo:</strong></h3>" + Environment.NewLine;
            html += "<div align=center>" + Environment.NewLine;
            html += "<table class=MsoNormalTable border=0 cellpadding=0 width='100%' style='width:100.0%'>" + Environment.NewLine;

            //cabecalho da tabela  
            html += "<tr>" + Environment.NewLine;
            html += "<td width = 73 style = 'width:45.0pt;background:#434549;padding:3.75pt 3.75pt 3.75pt 3.75pt' >" + Environment.NewLine;
            html += "<p class=MsoNormal align = center style='text-align:center'><b><span style = 'font-size:9.0pt;color:white' > Documento </span></b></p>" + Environment.NewLine;
            html += "</td>" + Environment.NewLine;
            html += "<td width=55 style='width:63.75pt;background:#434549;padding:3.75pt 3.75pt 3.75pt 3.75pt'>" + Environment.NewLine;
            html += "<p class=MsoNormal align = center style='text-align:center'><b><span style = 'font-size:9.0pt;color:white' > Valor </span></b></p>" + Environment.NewLine;
            html += "</td>" + Environment.NewLine;
            html += "<td width=58 style='width:45.0pt;background:#434549;padding:3.75pt 3.75pt 3.75pt 3.75pt'>" + Environment.NewLine;
            html += "<p class=MsoNormal align = center style='text-align:center'><b><span style = 'font-size:9.0pt;color:white'> Vencimento </span ></b></p>" + Environment.NewLine;
            html += "</td>" + Environment.NewLine;
            html += "</tr>" + Environment.NewLine;

            //linhas da tabela
            foreach (var bol in list)
            {
                html += "<tr>" + Environment.NewLine;
                html += "<td width=73 style='width:45.0pt;background:#F6F6F6;padding:3.75pt 3.75pt 3.75pt 3.75pt'><p class=MsoNormal align=center style='text-align:center'><b><span style='font-size:8.5pt;font-family:'Arial',sans-serif;color:#747474'>" + bol.NumeroDocumento.Trim() + "</span></b></p></td>" + Environment.NewLine;
                html += "<td width=55 style='width:63.75pt;background:#F6F6F6;padding:3.75pt 3.75pt 3.75pt 3.75pt'><p class=MsoNormal align=center style='text-align:center'><b><span style='font-size:8.5pt;font-family:'Arial',sans-serif;color:#747474'>" + bol.ValorTitulo.ToString("C2") + "</span></b></p></td>" + Environment.NewLine;
                html += "<td width=58 style='width:45.0pt;background:#F6F6F6;padding:3.75pt 3.75pt 3.75pt 3.75pt'><p class=MsoNormal align=center style='text-align:center'><b><span style='font-size:8.5pt;font-family:'Arial',sans-serif;color:#747474'>" + bol.DataVencimento.ToShortDateString() + "</span></b></p></td>" + Environment.NewLine;
                html += "</tr>" + Environment.NewLine;
            }

            html += "</table>" + Environment.NewLine;
            html += "</div>" + Environment.NewLine;

            var regiao = !(string.IsNullOrWhiteSpace(cedente.RegiaoCobrancaEmail)) ? cedente.RegiaoCobrancaEmail.Trim() + " " : "";

            html += "<p>Em caso de dúvidas, <a href='https://biancogres.com.br/fale-conosco/' target='_blank'>Fale Conosco</a> ou entre em contato com nossa Central de Cobrança:</p> " + Environment.NewLine;
            html += "<p>" + regiao + cedente.TelCobrancaEmail + Environment.NewLine;
            html += "<p>Atenciosamente,</p>" + Environment.NewLine;
            html += "<p style = 'text - align:center;' > " + unidade.Nome.ToUpper().Trim() + " </p>" + Environment.NewLine;
            html += "<div data - element_type = 'column' style = 'text - align:center; ' >" + Environment.NewLine;
            html += "<div>" + Environment.NewLine;
            html += "<a href = 'http://pinterest.com/biancogres' target = '_blank' >" + Environment.NewLine;
            html += "<img  height = '30' width = '30' src = 'https://image.freepik.com/icones-gratis/pinterest-logotipo-do-circulo_318-40721.jpg' />" + Environment.NewLine;
            html += "</a>" + Environment.NewLine;
            html += "<a href = 'http://instagram.com/biancogres' target = '_blank' >" + Environment.NewLine;
            html += "<img  height = '30' width = '30' src = 'https://image.freepik.com/icones-gratis/logo-instagram_318-84939.jpg' />" + Environment.NewLine;
            html += "</a>" + Environment.NewLine;
            html += "<a href = 'https://www.facebook.com/Biancogres' target = '_blank' >" + Environment.NewLine;
            html += "<img  height = '30' width = '30' src = 'https://image.freepik.com/icones-gratis/facebook-logo-botao_318-84980.jpg' />" + Environment.NewLine;
            html += "</a>" + Environment.NewLine;
            html += "<a href = 'https://www.youtube.com/channel/UCRfiBhipMA3m_RpuobTUO-w' target = '_blank' >" + Environment.NewLine;
            html += "<img  height = '30' width = '30' src = 'https://image.freepik.com/icones-gratis/youtube-logotipo_318-65152.jpg' />" + Environment.NewLine;
            html += "</a>" + Environment.NewLine;
            html += "</div>" + Environment.NewLine;
            html += "</div>" + Environment.NewLine;
            html += "<p style = 'text - align:center;'><img src = 'https://biancogres.com.br/wp-content/uploads/2018/06/logo1-3-1.png' /><p/>" + Environment.NewLine;
            html += "<p style = 'text - align:center;'><img height = '100' width = '100' src = 'https://biancogres.com.br/wp-content/uploads/2018/10/brasao.png' /></p>" + Environment.NewLine;
            html += "</body>" + Environment.NewLine;
            html += "</html>" + Environment.NewLine;

            return html;
        }

        public static string GetHtmlBoleto()
        {
            string html = string.Empty;

            return html;
        }

        public static string GetHtmlCedente(FBContext _context, Model.Cedente cedente, TipoEmail tipo, string nomeSacado, List<Financeiro.BoletoNetCore.Boleto> list, Unidade unidade)
        {
            var html = new StringBuilder();
            CultureInfo culture = new CultureInfo("pt-BR");
            string dia = DateTime.Now.Day.ToString();
            string ano = DateTime.Now.Year.ToString();
            string mes = culture.TextInfo.ToTitleCase(culture.DateTimeFormat.GetMonthName(DateTime.Now.Month));

            var qlayout = _context.LayoutEmail.Where(o => o.EmpresaID == unidade.EmpresaID && (!o.UnidadeID.HasValue || o.UnidadeID == unidade.ID) && o.TipoEmail == TipoEmail.FaturaCliente);

            if (qlayout.Any())
            {
                var layout = qlayout.First();

                var head = "<html><head><title>" + layout.Titulo.Trim() + "</title><style></style></head>";

                html.Append(head);

                var body = LibraryUtil.BytesToString(layout.BodyHtml);

                body = body.Replace("@DATAPOREXTENSO", cedente.Cidade.Trim() + ", " + dia + " de " + mes + " de " + ano);

                body = body.Replace("@CEDENTE.NOMEEMPRESA", unidade.Nome.ToUpper().Trim());

                body = body.Replace("@SACADO.NOME", nomeSacado);

                body = body.Replace("@CEDENTE.TELCOBRANCA1", cedente.TelCobrancaEmail);
                body = body.Replace("@CEDENTE.TELCOBRANCA2", cedente.TelCobrancaExtEmail);

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

                if (!string.IsNullOrWhiteSpace(LibraryUtil.BytesToString(layout.LinhasTabela01Html)))
                {
                    var linhasTab01 = new StringBuilder();
                    //linhas da tabela
                    foreach (var bol in list.OrderBy(x => x.NumeroDocumento))
                    {
                        var linha = LibraryUtil.BytesToString(layout.LinhasTabela01Html);

                        linha = linha.Replace("@BOLETO.NumeroDocumento", bol.NumeroDocumento.Trim());
                        linha = linha.Replace("@BOLETO.ValorTitulo", bol.ValorTitulo.ToString("C2"));
                        linha = linha.Replace("@BOLETO.DataVencimento", bol.DataVencimento.ToShortDateString());

                        linhasTab01.Append(linha);
                    }

                    body = body.Replace("@BOLETO.LINHASTABELA01", linhasTab01.ToString());
                }

                html.Append(body);

                html.Append("</html>");
            }


            return html.ToString();
        }

    }
}
