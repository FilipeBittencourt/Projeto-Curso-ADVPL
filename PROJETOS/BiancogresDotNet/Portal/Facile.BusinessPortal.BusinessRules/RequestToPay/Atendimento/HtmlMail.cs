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

namespace Facile.BusinessPortal.BusinessRules.ResquestToPay.Atendimento
{
    public static class HtmlMail
    {
        
        public static string GetHtmlAtendimento(FBContext _context, Model.Empresa empresa, Model.Atendimento atendimento)
        {
            var html = new StringBuilder();
            CultureInfo culture = new CultureInfo("pt-BR");
            string dia = DateTime.Now.Day.ToString();
            string ano = DateTime.Now.Year.ToString();
            string mes = culture.TextInfo.ToTitleCase(culture.DateTimeFormat.GetMonthName(DateTime.Now.Month));

            var qlayout = _context.LayoutEmail.Where(o => o.EmpresaID == empresa.ID);

            qlayout = qlayout.Where(o => o.TipoEmail == TipoEmail.NovoAtendimento);


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

                body = body.Replace("@FORNECEDOR.NOME", atendimento.Fornecedor.Nome.Trim());
              //  body = body.Replace("@DATALIBERACAO", atendimento.DataLiberacao.HasValue?.ToString("dd/MM/yyyy"));
                body = body.Replace("@ATENDIMENTO.NUMERO", atendimento.Numero.ToString());
                body = body.Replace("@ATENDIMENTO.NOMERECLAMANTE", atendimento.NomeReclamante.ToString());
                body = body.Replace("@ATENDIMENTO.TELEFONERECLAMANTE", atendimento.TelefoneReclamante.ToString());
                body = body.Replace("@ATENDIMENTO.ENDERECORECLAMANTE", atendimento.EstadoReclamante+", "+atendimento.CidadeReclamante+", "+ atendimento.BairroReclamante + ", "+ atendimento.EnderecoReclamante);
                
                body = body.Replace("@ATENDIMENTO.PRODUTONOME", atendimento.NomeProduto.ToString());
                body = body.Replace("@ATENDIMENTO.PRODUTOQUANTIDADE", atendimento.QuantidadeProduto.ToString("2")/*string.Format("{0:C2}", )*/);
                body = body.Replace("@ATENDIMENTO.PRODUTOVALOR", string.Format("{0:C2}", atendimento.ValorProduto) );
                body = body.Replace("@ATENDIMENTO.OBSERVACAO", atendimento.Observacao.ToString());

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

        public static string GetHtmlAtendimentoAprovadoReprovado(FBContext _context, Model.Empresa empresa, Model.Atendimento atendimento, TipoEmail Tipo)
        {
            var html = new StringBuilder();
            CultureInfo culture = new CultureInfo("pt-BR");
            string dia = DateTime.Now.Day.ToString();
            string ano = DateTime.Now.Year.ToString();
            string mes = culture.TextInfo.ToTitleCase(culture.DateTimeFormat.GetMonthName(DateTime.Now.Month));

            var qlayout = _context.LayoutEmail.Where(o => o.EmpresaID == empresa.ID);

            qlayout = qlayout.Where(o => o.TipoEmail == Tipo);


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

                body = body.Replace("@FORNECEDOR.NOME", atendimento.Fornecedor.Nome.Trim());
                body = body.Replace("@DATAAREPROVACAO", atendimento.DataMedicao.HasValue? atendimento.DataMedicao.Value.ToString("dd/MM/yyyy"): "");
                body = body.Replace("@ATENDIMENTO.NUMERO", atendimento.Numero.ToString());
                body = body.Replace("@ATENDIMENTO.OBSERVACAO", atendimento.ObservacaoMedicao.ToString());
                

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

        public static string GetHtmlAtendimentoConcluido(FBContext _context, Model.Empresa empresa, Model.Atendimento atendimento)
        {
            var html = new StringBuilder();
            CultureInfo culture = new CultureInfo("pt-BR");
            string dia = DateTime.Now.Day.ToString();
            string ano = DateTime.Now.Year.ToString();
            string mes = culture.TextInfo.ToTitleCase(culture.DateTimeFormat.GetMonthName(DateTime.Now.Month));

            var qlayout = _context.LayoutEmail.Where(o => o.EmpresaID == empresa.ID);

            qlayout = qlayout.Where(o => o.TipoEmail == TipoEmail.AtendimentoConcluido);


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

                body = body.Replace("@FORNECEDOR.NOME", atendimento.Fornecedor.Nome.Trim());
                body = body.Replace("@ATENDIMENTO.NUMERO", atendimento.Numero.ToString());
                

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
