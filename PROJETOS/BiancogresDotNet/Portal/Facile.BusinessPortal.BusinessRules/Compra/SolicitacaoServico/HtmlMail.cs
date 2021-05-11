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

namespace Facile.BusinessPortal.BusinessRules.Compra.SolicitacaoServico
{
    public static class HtmlMail
    {
        public static string GetLayout(FBContext _context, Model.Empresa empresa, TipoEmail tipoEmail)
        {
            var html = new StringBuilder();
            CultureInfo culture = new CultureInfo("pt-BR");
            string dia = DateTime.Now.Day.ToString();
            string ano = DateTime.Now.Year.ToString();
            string mes = culture.TextInfo.ToTitleCase(culture.DateTimeFormat.GetMonthName(DateTime.Now.Month));

            var qlayout = _context.LayoutEmail.Where(o => o.EmpresaID == empresa.ID);

            qlayout = qlayout.Where(o => o.TipoEmail == tipoEmail);

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
        
        public static string GetHtmlSolicitacaoServicoFornecedor(FBContext _context, Model.Empresa empresa, Model.Compra.Servico.SolicitacaoServicoFornecedor ssf)
        {
            var html = GetLayout(_context, empresa, TipoEmail.SolicitacaoServicoFornecedor);
            html = html.Replace("@FORNECEDOR.NOME", ssf.Fornecedor.Nome.Trim());
            html = html.Replace("@SOLICITACAOSERVICO.NUMERO", ssf.SolicitacaoServico.Numero.ToString());
            return html.ToString();
        }


        public static string GetHtmlSolicitacaoServicoNaoSelecionada(FBContext _context, Model.Empresa empresa, Model.Compra.Servico.SolicitacaoServicoFornecedor ssf)
        {
            var html = GetLayout(_context, empresa, TipoEmail.SolicitacaoServicoNaoSelecionada);
            html = html.Replace("@FORNECEDOR.NOME", ssf.Fornecedor.Nome.Trim());
            html = html.Replace("@SOLICITACAOSERVICO.NUMERO", ssf.SolicitacaoServico.Numero.ToString());
            return html.ToString();
        }

        public static string GetHtmlEmailUsuario(FBContext _context, Model.Compra.Servico.SolicitacaoServico o, TipoEmail tipoEmail)
        {
            var html = GetLayout(_context, o.Empresa, tipoEmail);
            if(tipoEmail == TipoEmail.SolicitacaoServicoUsuarioSolicitanteOrigem)
            {
                html = html.Replace("@USUARIO.NOME", o.UsuarioOrigem.Nome.Trim());
            }else
            {
                html = html.Replace("@USUARIO.NOME", o.UsuarioMedicao.Nome.Trim());
            }
            html = html.Replace("@SOLICITACAOSERVICO.NUMERO", o.Numero.ToString());
            return html.ToString();
        }

        public static string GetHtmlEmailItemMedicao(FBContext _context, Model.Compra.Servico.SolicitacaoServicoMedicaoItem o, Model.Compra.Servico.SolicitacaoServico ss, TipoEmail tipoEmail)
        {
            var html = GetLayout(_context, o.Empresa, tipoEmail);

            html = html.Replace("@USUARIO.NOME", ss.Usuario.Nome);
            html = html.Replace("@MEDICAO.STATUS", o.StatusDescricao());
            html = html.Replace("@PRODUTO.NOME", o.SolicitacaoServicoItem.Produto.Codigo);
            html = html.Replace("@SOLICITACAOSERVICO.NUMERO", o.SolicitacaoServicoItem.SolicitacaoServico.Numero.ToString());

            return html.ToString();
        }

        public static string GetHtmlEmailItemMedicaoFornecedor(FBContext _context, Model.Compra.Servico.SolicitacaoServicoMedicaoItem o, Model.Compra.Servico.SolicitacaoServicoFornecedor ssf, TipoEmail tipoEmail)
        {
            var html = GetLayout(_context, o.Empresa, tipoEmail);

            html = html.Replace("@FORNECEDOR.NOME", ssf.Fornecedor.Nome);
            html = html.Replace("@MEDICAO.STATUS", o.StatusDescricao());
            html = html.Replace("@PRODUTO.NOME", o.SolicitacaoServicoItem.Produto.Codigo);
            html = html.Replace("@SOLICITACAOSERVICO.NUMERO", o.SolicitacaoServicoItem.SolicitacaoServico.Numero.ToString());

            return html.ToString();
        }

        public static string GetHtmlEmailMedicao(FBContext _context, Model.Compra.Servico.SolicitacaoServico o, Model.Compra.Servico.SolicitacaoServicoMedicao ssm, TipoEmail tipoEmail)
        {
            var html = GetLayout(_context, o.Empresa, tipoEmail);

            html = html.Replace("@USUARIO.NOME", o.Usuario.Nome);
            html = html.Replace("@MEDICAO.STATUS", ssm.StatusDescricao());
            html = html.Replace("@SOLICITACAOSERVICO.NUMERO", o.Numero.ToString());

            return html.ToString();
        }

        public static string GetHtmlEmailMedicaoFornecedor(
                    FBContext _context, 
                    Model.Compra.Servico.SolicitacaoServico o, 
                    Model.Compra.Servico.SolicitacaoServicoMedicao ssm,
                     Model.Compra.Servico.SolicitacaoServicoFornecedor ssf,
                    TipoEmail tipoEmail
         )
        {
            var html = GetLayout(_context, o.Empresa, tipoEmail);

            html = html.Replace("@FORENCEDOR.NOME", ssf.Fornecedor.Nome);
            html = html.Replace("@MEDICAO.STATUS", ssm.StatusDescricao());
            html = html.Replace("@SOLICITACAOSERVICO.NUMERO", o.Numero.ToString());

            return html.ToString();
        }

        public static string GetHtmlEmailMedicaoUnica(FBContext _context, Model.Compra.Servico.SolicitacaoServico o, Model.Compra.Servico.SolicitacaoServicoMedicaoUnica ssm, TipoEmail tipoEmail)
        {
            var html = GetLayout(_context, o.Empresa, tipoEmail);

            html = html.Replace("@USUARIO.NOME", o.Usuario.Nome);
            html = html.Replace("@MEDICAO.STATUS", ssm.StatusDescricao());
            html = html.Replace("@SOLICITACAOSERVICO.NUMERO", o.Numero.ToString());

            return html.ToString();
        }

        public static string GetHtmlEmailMedicaoUnicaFornecedor(
                    FBContext _context,
                    Model.Compra.Servico.SolicitacaoServico o,
                    Model.Compra.Servico.SolicitacaoServicoMedicaoUnica ssm,
                     Model.Compra.Servico.SolicitacaoServicoFornecedor ssf,
                    TipoEmail tipoEmail
         )
        {
            var html = GetLayout(_context, o.Empresa, tipoEmail);

            html = html.Replace("@FORENCEDOR.NOME", ssf.Fornecedor.Nome);
            html = html.Replace("@MEDICAO.STATUS", ssm.StatusDescricao());
            html = html.Replace("@SOLICITACAOSERVICO.NUMERO", o.Numero.ToString());

            return html.ToString();
        }
    }
}
