using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Security;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Security.Policy;
using System.Text;

namespace Facile.BusinessPortal.BusinessRules
{
    public static class HtmlMail
    {
        public static string GetHtmlNovaAntecipacaoMail(FBContext _context, Model.Empresa empresa, Model.Antecipacao antecipacao,  string callbackUrl)
        {
            var html = new StringBuilder();
            CultureInfo culture = new CultureInfo("pt-BR");
            string dia = DateTime.Now.Day.ToString();
            string ano = DateTime.Now.Year.ToString();
            string mes = culture.TextInfo.ToTitleCase(culture.DateTimeFormat.GetMonthName(DateTime.Now.Month));

            var qlayout = _context.LayoutEmail.Where(o => o.EmpresaID == empresa.ID);

            if (antecipacao.Origem == OrigemAntecipacao.Empresa)
            {
                qlayout = qlayout.Where(o => o.TipoEmail == TipoEmail.NovaAntecipacaoEmpresa);
            }
            else
            {
                qlayout = qlayout.Where(o => o.TipoEmail == TipoEmail.NovaAntecipacaoFornecedor);
            }

            var Result = _context.UsuarioFornecedor
                               .AsNoTracking().FirstOrDefault(x => x.FornecedorID == antecipacao.FornecedorID);
            string token = "";
            long ID = 0;

            if (Result != null)
            {
                try
                {
                    token = RandonGenerator.RandomString(10, false) + RandonGenerator.RandomNumber(100000, 999999).ToString();
                    Token t = new Token();
                    t.Chave = token;
                    t.DataHoraVencimento = new DateTime().AddDays(2);
                    t.TipoToken = TipoToken.Antecipacao;
                    t.UsuarioID = Result.UsuarioID;
                    _context.Add<Token>(t);

                    _context.SaveChanges();
                    ID = Result.UsuarioID;
                } catch(Exception ex)
                {

                }
            }

            string LinkAprovar = callbackUrl+ "?usuarioid=" + ID+"&chave="+ token+"&id="+ antecipacao.ID;
            

            if (qlayout.Any())
            {
                var layout = qlayout.First();

                var perfil = _context.PerfilEmpresa.FirstOrDefault(o => o.EmpresaID == empresa.ID);

                var head = "<html><head><title>" + layout.Titulo.Trim() + "</title><style></style></head>";

                html.Append(head);

                var body = LibraryUtil.BytesToString(layout.BodyHtml);

                if (perfil != null)
                {
                    body = body.Replace("@NOMEPLATAFORMA", perfil.Descricao_Reduzida_Portal);
                }
                else
                {
                    body = body.Replace("@NOMEPLATAFORMA", "Facile Cloud Apps");
                }

                body = body.Replace("@EMPRESA.NOMEEMPRESA", empresa.NomeEmpresa.ToUpper().Trim());

                body = body.Replace("@EMPRESA.TELEFONE", perfil.TelefoneContato.Trim());

                body = body.Replace("@DATAPOREXTENSO", dia + " de " + mes + " de " + ano);

                body = body.Replace("@FORNECEDOR.NOME", antecipacao.Fornecedor.Nome.Trim());
                body = body.Replace("@DATAPAGAMENTO", antecipacao.DataRecebimento.ToString("dd/MM/yyyy"));
                body = body.Replace("@TAXA", string.Format("{0:N}", antecipacao.Taxa));


                string HtmlTable = "";
                decimal TotalValor = 0;
                decimal TotalValorAntecipado = 0;
                foreach (var item in antecipacao.AntecipacaoItem)
                {
                    var LinhasTabela01Html = LibraryUtil.BytesToString(layout.LinhasTabela01Html);

                    LinhasTabela01Html = LinhasTabela01Html.Replace("@ANTECIPACAOITEM.NumeroDocumento", item.TituloPagar.NumeroDocumento.ToString());
                    LinhasTabela01Html = LinhasTabela01Html.Replace("@ANTECIPACAOITEM.ValorTitulo", string.Format("{0:C2}", item.ValorTitulo));
                    LinhasTabela01Html = LinhasTabela01Html.Replace("@ANTECIPACAOITEM.ValorAntencipado", string.Format("{0:C2}", item.ValorTituloAntecipado));
                    LinhasTabela01Html = LinhasTabela01Html.Replace("@ANTECIPACAOITEM.DataVencimento", item.TituloPagar.DataVencimento.ToString("dd/MM/yyy"));

                    HtmlTable += LinhasTabela01Html;

                    TotalValor += item.ValorTitulo;
                    TotalValorAntecipado += item.ValorTituloAntecipado;
                }

                body = body.Replace("@VALOR.TOTAL", string.Format("{0:C2}", TotalValor));
                body = body.Replace("@VALOR.ANTECIPACAOTOTAL", string.Format("{0:C2}", TotalValorAntecipado));

                body = body.Replace("@ANTECIPACAOITEM.LINHASTABELA01", HtmlTable);

                body = body.Replace("@LINK.APROVAR", LinkAprovar);

                //

                if (!string.IsNullOrWhiteSpace(layout.LinkFaleConosco))
                {
                    body = body.Replace("@LINK.FALECONOSCO", "'" + layout.LinkFaleConosco + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkImagem01))
                {
                    body = body.Replace("@LINK.IMAGEM01", "'" + layout.LinkImagem01 + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkImagem02))
                {
                    body = body.Replace("@LINK.IMAGEM02", "'" + layout.LinkImagem02 + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkImagem03))
                {
                    body = body.Replace("@LINK.IMAGEM03", "'" + layout.LinkImagem03 + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkPinterest))
                {
                    body = body.Replace("@LINK.PINTEREST", "'" + layout.LinkPinterest + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkInstagram))
                {
                    body = body.Replace("@LINK.INSTAGRAM", "'" + layout.LinkInstagram + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkFacebook))
                {
                    body = body.Replace("@LINK.FACEBOOK", "'" + layout.LinkFacebook + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkYoutube))
                {
                    body = body.Replace("@LINK.YOUTUBE", "'" + layout.LinkYoutube + "'");
                }

                html.Append(body);

                html.Append("</html>");
            }


            return html.ToString();
        }


        public static string GetHtmlAntecipacaoAceitaMail(FBContext _context, Model.Empresa empresa, Model.Antecipacao antecipacao)
        {
            var html = new StringBuilder();
            CultureInfo culture = new CultureInfo("pt-BR");
            string dia = DateTime.Now.Day.ToString();
            string ano = DateTime.Now.Year.ToString();
            string mes = culture.TextInfo.ToTitleCase(culture.DateTimeFormat.GetMonthName(DateTime.Now.Month));

            var qlayout = _context.LayoutEmail.Where(o => o.EmpresaID == empresa.ID);

            qlayout = qlayout.Where(o => o.TipoEmail == TipoEmail.AntecipacaoAceitaFornecedor);


            if (qlayout.Any())
            {
                var layout = qlayout.First();

                var perfil = _context.PerfilEmpresa.FirstOrDefault(o => o.EmpresaID == empresa.ID);

                var head = "<html><head><title>" + layout.Titulo.Trim() + "</title><style></style></head>";

                html.Append(head);

                var body = LibraryUtil.BytesToString(layout.BodyHtml);

                if (perfil != null)
                {
                    body = body.Replace("@NOMEPLATAFORMA", perfil.Descricao_Reduzida_Portal);
                }
                else
                {
                    body = body.Replace("@NOMEPLATAFORMA", "Facile Cloud Apps");
                }

                body = body.Replace("@EMPRESA.NOMEEMPRESA", empresa.NomeEmpresa.ToUpper().Trim());

                body = body.Replace("@EMPRESA.TELEFONE", perfil.TelefoneContato.Trim());

                body = body.Replace("@DATAPOREXTENSO", dia + " de " + mes + " de " + ano);

                body = body.Replace("@FORNECEDOR.NOME", antecipacao.Fornecedor.Nome.Trim());
                body = body.Replace("@DATAAPROVACAO", DateTime.Now.ToString("dd/MM/yyyy"));
                body = body.Replace("@ANTECIPACAO.ID", antecipacao.ID.ToString());


                if (!string.IsNullOrWhiteSpace(layout.LinkFaleConosco))
                {
                    body = body.Replace("@LINK.FALECONOSCO", "'" + layout.LinkFaleConosco + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkImagem01))
                {
                    body = body.Replace("@LINK.IMAGEM01", "'" + layout.LinkImagem01 + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkImagem02))
                {
                    body = body.Replace("@LINK.IMAGEM02", "'" + layout.LinkImagem02 + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkImagem03))
                {
                    body = body.Replace("@LINK.IMAGEM03", "'" + layout.LinkImagem03 + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkPinterest))
                {
                    body = body.Replace("@LINK.PINTEREST", "'" + layout.LinkPinterest + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkInstagram))
                {
                    body = body.Replace("@LINK.INSTAGRAM", "'" + layout.LinkInstagram + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkFacebook))
                {
                    body = body.Replace("@LINK.FACEBOOK", "'" + layout.LinkFacebook + "'");
                }

                if (!string.IsNullOrWhiteSpace(layout.LinkYoutube))
                {
                    body = body.Replace("@LINK.YOUTUBE", "'" + layout.LinkYoutube + "'");
                }
                html.Append(body);

                html.Append("</html>");
            }


            return html.ToString();
        }
    }
}
