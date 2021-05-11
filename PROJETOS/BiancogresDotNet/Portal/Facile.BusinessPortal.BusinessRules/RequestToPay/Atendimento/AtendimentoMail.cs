using Facile.BusinessPortal.BusinessRules.Util;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Structs.Interna;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;

namespace Facile.BusinessPortal.BusinessRules.ResquestToPay.Atendimento
{
    public static class AtendimentoMail
    {
        public static ReturnSendMail NovoAtendimentoSendMail(FBContext db, long AtendimentoID)
        {
            try
            {
                var atendimento = db.Atendimento
                                .Include(x=>x.Unidade)
                                .Include(x => x.Empresa)
                                .Include(x => x.Fornecedor)
                                .AsNoTracking().FirstOrDefault(x => x.ID == AtendimentoID);
                if (atendimento != null)
                {
                    var emailServer = MailEmpresa.ConnectMail(db, atendimento.Unidade, EmailModulo.Padrao);
                    var html = HtmlMail.GetHtmlAtendimento(db, atendimento.Empresa, atendimento);

                    string email = "";
                    if (atendimento.Empresa.Homologacao)
                    {
                        email = atendimento.Empresa.EmailHomologacao;
                    }
                    else
                    {
                        email = atendimento.Fornecedor.EmailWorkflow;
                    }

                    email = "pedro@facilesistemas.com.br;raquel.rangel@biancogres.com.br";

                    var cco = emailServer.EmailCCO;
                    var subject = "Novo Atendimento";

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
                    Mensagem = "Erro envio email atendimento reprovado"
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email atendimento: " + ex.Message
                };
            }
        }


        public static ReturnSendMail AtendimentoReprovadoSendMail(FBContext db, long AtendimentoID)
        {
            try
            {
                var atendimento = db.Atendimento
                                .Include(x => x.Unidade)
                                .Include(x => x.Empresa)
                                .Include(x => x.Fornecedor)
                                .AsNoTracking().FirstOrDefault(x => x.ID == AtendimentoID);
                if (atendimento != null)
                {
                    var emailServer = MailEmpresa.ConnectMail(db, atendimento.Unidade, EmailModulo.Padrao);
                    var html = HtmlMail.GetHtmlAtendimentoAprovadoReprovado(db, atendimento.Empresa, atendimento, TipoEmail.AtendimentoReprovado);

                    string email = "";
                    if (atendimento.Empresa.Homologacao)
                    {
                        email = atendimento.Empresa.EmailHomologacao;
                    }
                    else
                    {
                        email = atendimento.Fornecedor.EmailWorkflow;
                    }
                    email = "pedro@facilesistemas.com.br;raquel.rangel@biancogres.com.br";

                    var cco = emailServer.EmailCCO;
                    var subject = "Atendimento Reprovado";

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
                    Mensagem = "Erro envio email atendimento reprovado"
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email atendimento: " + ex.Message
                };
            }
        }

        public static ReturnSendMail AtendimentoAprovadoSendMail(FBContext db, long AtendimentoID)
        {
            try
            {
                var atendimento = db.Atendimento
                                .Include(x => x.Unidade)
                                .Include(x => x.Empresa)
                                .Include(x => x.Fornecedor)
                                .AsNoTracking().FirstOrDefault(x => x.ID == AtendimentoID);
                if (atendimento != null)
                {
                    var emailServer = MailEmpresa.ConnectMail(db, atendimento.Unidade, EmailModulo.Padrao);
                    var html = HtmlMail.GetHtmlAtendimentoAprovadoReprovado(db, atendimento.Empresa, atendimento, TipoEmail.AtendimentoAprovado);

                    string email = "";
                    if (atendimento.Empresa.Homologacao)
                    {
                        email = atendimento.Empresa.EmailHomologacao;
                    }
                    else
                    {
                        email = atendimento.Fornecedor.EmailWorkflow;
                    }
                    email = "pedro@facilesistemas.com.br;raquel.rangel@biancogres.com.br";

                    var cco = emailServer.EmailCCO;
                    var subject = "Atendimento Aprovado";

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
                    Mensagem = "Erro envio email atendimento aprovado"
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email atendimento: " + ex.Message
                };
            }
        }

        public static ReturnSendMail AtendimentoConcluidoSendMail(FBContext db, long AtendimentoID)
        {
            try
            {
                var atendimento = db.Atendimento
                                .Include(x => x.Unidade)
                                .Include(x => x.Empresa)
                                .Include(x => x.Fornecedor)
                                .AsNoTracking().FirstOrDefault(x => x.ID == AtendimentoID);
                if (atendimento != null)
                {
                    var emailServer = MailEmpresa.ConnectMail(db, atendimento.Unidade, EmailModulo.Padrao);
                    var html = HtmlMail.GetHtmlAtendimentoConcluido(db, atendimento.Empresa, atendimento);

                    string email = "";
                    if (atendimento.Empresa.Homologacao)
                    {
                        email = atendimento.Empresa.EmailHomologacao;
                    }
                    else
                    {
                        email = atendimento.Fornecedor.EmailWorkflow;
                    }
                    email = "pedro@facilesistemas.com.br;raquel.rangel@biancogres.com.br";

                    var cco = emailServer.EmailCCO;
                    var subject = "Serviço Realizado Pelo Fornecedor";

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
                    Mensagem = "Erro envio email atendimento concluido"
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email atendimento: " + ex.Message
                };
            }
        }
    }
}
