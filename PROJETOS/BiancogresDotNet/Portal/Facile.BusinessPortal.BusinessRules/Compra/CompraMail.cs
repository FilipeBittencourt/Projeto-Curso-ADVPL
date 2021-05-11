using Facile.BusinessPortal.BusinessRules.Util;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Mail;
using Facile.BusinessPortal.Library.Structs.Interna;
using Facile.BusinessPortal.Model;
using Facile.Financeiro.BoletoNetCore;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace Facile.BusinessPortal.BusinessRules.Compra
{
    public static class CompraMail
    {
        /*
        public static ReturnSendMail LocalEntregaSendMail(FBContext db, long NotaFiscalCompraID)
        {
            try
            {
                var nf = db.NotaFiscalCompra
                    .Include(x => x.Unidade)
                    .Include(x => x.Empresa)
                    .Include(x => x.Fornecedor)
                    .Include(x => x.LocalEntrega)
                    .Include(x => x.PedidoCompra)
                        .ThenInclude(x => x.Transportadora)
                    .AsNoTracking().FirstOrDefault(x => x.ID == NotaFiscalCompraID);
                if (nf != null)
                {
                    var emailServer = MailEmpresa.ConnectMail(db, nf.Unidade);
                    var html = "<p>Local Entrega: "+nf.LocalEntrega.Nome+"</p>";//HtmlMail.GetHtmlLocalEntregaMail(db, nf.Empresa, nf);
                    html += "<p>Data Agendamento: " + nf.DataAgendamento.Value + "</p>";

                    string email = "";
                    if (nf.Empresa.Homologacao)
                    {
                        email = nf.Empresa.EmailHomologacao;
                    }
                    else
                    {
                        if (nf.PedidoCompra != null)
                        {
                            if (nf.PedidoCompra.TipoFrete == TipoFrete.CIF)
                            {
                                email = nf.Fornecedor.EmailWorkflow;
                            } else
                            {
                                email = nf.PedidoCompra.Transportadora.EmailWorkflow;
                            }
                        }
                    }

                    email = "pedro@facilesistemas.com.br;nilmara.luz @biancogres.com.br";

                    var cco = emailServer.EmailCCO;
                    var subject = "Confirmação do Local de Entrega";

                    var wfret = emailServer.EnviaEmailAnexo(emailServer.SenderEmail, email, subject, "", cco, html, "", "", true, emailServer.SenderDisplayName);
                    return new ReturnSendMail()
                    {
                        Status = wfret.Ok,
                        Mensagem = wfret.Mensagem
                    };                       
                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email confirmação local entrega"
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email confirmação local entrega: " + ex.Message
                };
            }
        }


        public static ReturnSendMail NotaFiscalSendMail(FBContext db, long NotaFiscalCompraID, string _html="")
        {
            try
            {
                var nf = db.NotaFiscalCompra
                    .Include(x => x.Unidade)
                    .Include(x => x.Empresa)
                    .Include(x => x.Fornecedor)
                    .Include(x => x.LocalEntrega)
                    .Include(x => x.PedidoCompra)
                        .ThenInclude(x => x.Transportadora)
                    .AsNoTracking().FirstOrDefault(x => x.ID == NotaFiscalCompraID);
                if (nf != null)
                {
                    var emailServer = MailEmpresa.ConnectMail(db, nf.Unidade);
                    var html = "<p>Chave NFe: " + nf.ChaveNFE + "</p>";//HtmlMail.GetHtmlLocalEntregaMail(db, nf.Empresa, nf);
                    html += "<p>Numero/Serie: " + nf.Numero+"/"+ nf.Serie+ "</p>";
                    html += _html;

                    string email = "";
                    if (nf.Empresa.Homologacao)
                    {
                        email = nf.Empresa.EmailHomologacao;
                    }
                    else
                    {
                        if (nf.PedidoCompra != null)
                        {
                            if (nf.PedidoCompra.TipoFrete == TipoFrete.CIF)
                            {
                                email = nf.Fornecedor.EmailWorkflow;
                            }
                            else
                            {
                                email = nf.PedidoCompra.Transportadora.EmailWorkflow;
                            }
                        }
                    }
                    
                    email = "pedro@facilesistemas.com.br;nilmara.luz @biancogres.com.br";

                    var cco = emailServer.EmailCCO;
                    var subject = "Nota Fiscal";

                    var wfret = emailServer.EnviaEmailAnexo(emailServer.SenderEmail, email, subject, "", cco, html, "", "", true, emailServer.SenderDisplayName);
                    return new ReturnSendMail()
                    {
                        Status = wfret.Ok,
                        Mensagem = wfret.Mensagem
                    };
                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email confirmação local entrega"
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email confirmação local entrega: " + ex.Message
                };
            }
        }
        */
    }
}
