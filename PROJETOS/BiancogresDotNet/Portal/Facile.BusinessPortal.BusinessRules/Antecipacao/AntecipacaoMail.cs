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

namespace Facile.BusinessPortal.BusinessRules
{
    public static class AntecipacaoMail
    {
        public static ReturnSendMail NovaAntecipacaoSendMail(FBContext db, long AntecipacaoID, string callbackUrl="")
        {
            try
            {
                var antecipacao = db.Antecipacao
                                .Include(x=>x.Unidade)
                                .Include(x => x.Empresa)
                                .Include(x => x.Fornecedor)
                                .Include(x => x.AntecipacaoItem)
                                .ThenInclude(x => x.TituloPagar)
                                .AsNoTracking().FirstOrDefault(x => x.ID == AntecipacaoID);
                if (antecipacao != null)
                {
                    var emailServer = MailEmpresa.ConnectMail(db, antecipacao.Unidade, EmailModulo.Antecipacao);
                    var html = HtmlMail.GetHtmlNovaAntecipacaoMail(db,  antecipacao.Empresa, antecipacao, callbackUrl);

                    string email = "";
                    if (antecipacao.Empresa.Homologacao)
                    {
                        email = antecipacao.Empresa.EmailHomologacao;
                    }
                    else
                    {
                        if (antecipacao.Origem == OrigemAntecipacao.Empresa)
                        {
                            email = antecipacao.Fornecedor.EmailWorkflow;
                        }
                        else
                        {
                            //TODO REMOVER 
                            email = "antecipacao@biancogres.com.br";
                        }
                    }
                    var cco = emailServer.EmailCCO;
                    var subject = "Nova antecipação de pagamento";

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
                    Mensagem = "Erro envio email antecipação"
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email antecipação: " + ex.Message
                };
            }
        }


        public static ReturnSendMail AntecipacaoAceitaSendMail(FBContext db, long AntecipacaoID)
        {
            try
            {
                var antecipacao = db.Antecipacao
                                .Include(x => x.Unidade)
                                .Include(x => x.Empresa)
                                .Include(x => x.Fornecedor)
                                .Include(x => x.AntecipacaoItem)
                                .ThenInclude(x => x.TituloPagar)
                                .AsNoTracking().FirstOrDefault(x => x.ID == AntecipacaoID);
                if (antecipacao != null)
                {
                    var emailServer = MailEmpresa.ConnectMail(db, antecipacao.Unidade, EmailModulo.Antecipacao);
                    var html = HtmlMail.GetHtmlAntecipacaoAceitaMail(db, antecipacao.Empresa, antecipacao);

                    string email = "";
                    if (antecipacao.Empresa.Homologacao)
                    {
                        email = antecipacao.Empresa.EmailHomologacao;
                    }
                    else
                    {
                        //TODO REMOVER 
                        email = "antecipacao@biancogres.com.br";
                    }
                    var cco = emailServer.EmailCCO;
                    var subject = "Antecipação de pagamento Aceita";

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
                    Mensagem = "Erro envio email antecipação aceita."
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email antecipação aceita: " + ex.Message
                };
            }
        }
    }
}
