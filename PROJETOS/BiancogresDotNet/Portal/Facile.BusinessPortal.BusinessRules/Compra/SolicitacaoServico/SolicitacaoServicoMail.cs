using Facile.BusinessPortal.BusinessRules.Util;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Structs.Interna;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;

namespace Facile.BusinessPortal.BusinessRules.Compra.SolicitacaoServico
{
    public static class SolicitacaoServicoMail
    {

        private static ReturnSendMail SendEmail(FBContext db, Empresa _empresa, Unidade _unidade, string _email, string _html, string _subject)
        {
            try
            {
                var emailServer = MailEmpresa.ConnectMail(db, _unidade, EmailModulo.Padrao);

                string email = _email;
                if (_empresa.Homologacao)
                {
                    email = _empresa.EmailHomologacao;
                }


                email = "pedro@facilesistemas.com.br;higo.fiorotti@biancogres.com.br;anderson.rodrigues@biancogres.com.br";

                var cco = emailServer.EmailCCO;
                var subject = _subject;


                var wfret = emailServer.EnviaEmailAnexo(emailServer.SenderEmail, email, _subject, "", cco, _html, "", "", true, emailServer.SenderDisplayName);
                return new ReturnSendMail()
                {
                    Status = wfret.Ok,
                    Mensagem = wfret.Mensagem
                };

            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço não selecionada: " + ex.Message
                };
            }
        }

        public static ReturnSendMail NovaSolicitacaoServicoFornecedorSendMail(FBContext db, long SolicitacaoServicoForneccedorID)
        {
            try
            {
                var ssf = db.SolicitacaoServicoFornecedor
                                .Include(x => x.Empresa)
                                .Include(x => x.Fornecedor)
                                .Include(x => x.SolicitacaoServico)
                                    .ThenInclude(x => x.Unidade)
                                .AsNoTracking().FirstOrDefault(x => x.ID == SolicitacaoServicoForneccedorID);
                if (ssf != null)
                {
                    var html = HtmlMail.GetHtmlSolicitacaoServicoNaoSelecionada(db, ssf.Empresa, ssf);
                    return SendEmail(db, ssf.Empresa, ssf.SolicitacaoServico.Unidade, ssf.Fornecedor.EmailWorkflow, html, "Nova Solicitação Serviço");
                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço"
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço: " + ex.Message
                };
            }
        }

        public static ReturnSendMail SolicitacaoServicoNaoSelecionadaSendMail(FBContext db, long SolicitacaoServicoForneccedorID)
        {
            try
            {
                var ssf = db.SolicitacaoServicoFornecedor
                                .Include(x => x.Empresa)
                                .Include(x => x.Fornecedor)
                                .Include(x => x.SolicitacaoServico)
                                    .ThenInclude(x => x.Unidade)
                                .AsNoTracking().FirstOrDefault(x => x.ID == SolicitacaoServicoForneccedorID);
                if (ssf != null)
                {
                    var html = HtmlMail.GetHtmlSolicitacaoServicoNaoSelecionada(db, ssf.Empresa, ssf);
                    return SendEmail(db, ssf.Empresa, ssf.SolicitacaoServico.Unidade, ssf.Fornecedor.EmailWorkflow, html, "Fornecedor não selecionado para cotação");
                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço não selecionada"
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço não selecionada: " + ex.Message
                };
            }
        }


        public static ReturnSendMail EmailUsuarioMedicao(FBContext db, long SolicitacaoServicoID)
        {
            try
            {
                var o = db.SolicitacaoServico
                                .Include(x => x.Empresa)
                                .Include(x => x.Unidade)
                                .Include(x => x.UsuarioMedicao)
                                .AsNoTracking().FirstOrDefault(x => x.ID == SolicitacaoServicoID);
                if (o != null)
                {
                    if (o.UsuarioOrigemID.HasValue)
                    {
                        var html = HtmlMail.GetHtmlEmailUsuario(db, o, TipoEmail.SolicitacaoServicoUsuarioMedicao);
                        return SendEmail(db, o.Empresa, o.Unidade, o.UsuarioMedicao.Email, html, "Usuário Medição");
                    } else
                    {
                        return new ReturnSendMail()
                        {
                            Status = true,
                            Mensagem = ""
                        };
                    }
                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitante origem."
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço não encontrada: " + ex.Message
                };
            }
        }

        public static ReturnSendMail EmailSolicitanteOrigem(FBContext db, long SolicitacaoServicoID)
        {
            try
            {
                var o = db.SolicitacaoServico
                                .Include(x => x.Empresa)
                                .Include(x => x.Unidade)
                                 .Include(x => x.UsuarioOrigem)
                                .AsNoTracking().FirstOrDefault(x => x.ID == SolicitacaoServicoID);
                if (o != null)
                {

                    if (o.UsuarioOrigemID.HasValue)
                    {
                        var html = HtmlMail.GetHtmlEmailUsuario(db, o, TipoEmail.SolicitacaoServicoUsuarioSolicitanteOrigem);
                        return SendEmail(db, o.Empresa, o.Unidade, o.UsuarioOrigem.Email, html, "Solicitante Origem");
                    }
                    else
                    {
                        return new ReturnSendMail()
                        {
                            Status = true,
                            Mensagem = ""
                        };
                    }

                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitante origem."
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço não encontrada: " + ex.Message
                };
            }
        }


        public static ReturnSendMail EmailItemMedicao(FBContext db, long ID)
        {
            try
            {
                var o = db.SolicitacaoServicoMedicaoItem
                                .Include(x => x.Empresa)
                                .Include(x => x.Unidade)
                                .Include(x => x.Unidade)
                                .Include(x => x.Unidade)
                                 .Include(x => x.SolicitacaoServicoItem)
                                    .ThenInclude(x => x.SolicitacaoServico)
                                 .Include(x => x.SolicitacaoServicoItem)
                                    .ThenInclude(x => x.Produto)
                                .AsNoTracking().FirstOrDefault(x => x.ID == ID);
                if (o != null)
                {
                    var Result = db.SolicitacaoServico.Include(x => x.Usuario).Include(x => x.UsuarioMedicao).Include(x => x.UsuarioOrigem).FirstOrDefault(
                       x => x.ID == o.SolicitacaoServicoItem.SolicitacaoServicoID
                       );

                    var Email = "";

                    if (Result.UsuarioMedicaoID.HasValue)
                    {
                        Email = Result.UsuarioMedicao.Email;
                    }
                    else if (Result.UsuarioOrigemID.HasValue)
                    {
                        Email = Result.UsuarioOrigem.Email;
                    }
                    else
                    {
                        Email = Result.Usuario.Email;
                    }

                    if (Result != null)
                    {
                        var html = HtmlMail.GetHtmlEmailItemMedicao(db, o, Result, TipoEmail.SolicitacaoServicoItemMedicaoStatus);
                        return SendEmail(db, o.Empresa, o.Unidade, Email, html, "Status Medição");

                    }

                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitante origem."
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço não encontrada: " + ex.Message
                };
            }
        }

        public static ReturnSendMail EmailItemMedicaoFornecedor(FBContext db, long ID)
        {
            try
            {
                var o = db.SolicitacaoServicoMedicaoItem
                                .Include(x => x.Empresa)
                                .Include(x => x.Unidade)
                                 .Include(x => x.SolicitacaoServicoItem)
                                    .ThenInclude(x => x.SolicitacaoServico)
                                 .Include(x => x.SolicitacaoServicoItem)
                                    .ThenInclude(x => x.Produto)
                                .AsNoTracking().FirstOrDefault(x => x.ID == ID);
                if (o != null)
                {
                    var Result = db.SolicitacaoServicoFornecedor.Include(x => x.Fornecedor).FirstOrDefault(
                        x => x.SolicitacaoServicoID == o.SolicitacaoServicoItem.SolicitacaoServicoID &&
                        x.Vencedor
                        );
                    if (Result != null)
                    {
                        var html = HtmlMail.GetHtmlEmailItemMedicaoFornecedor(db, o, Result, TipoEmail.SolicitacaoServicoItemMedicaoStatusFornecedor);
                        return SendEmail(db, o.Empresa, o.Unidade, Result.Fornecedor.Email, html, "Status Medição");

                    }

                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitante origem."
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço não encontrada: " + ex.Message
                };
            }
        }


        public static ReturnSendMail EmailMedicao(FBContext db, long ID, long SolicitacaoServicoMedicaoID)
        {
            try
            {
                var o = db.SolicitacaoServico
                                .Include(x => x.Empresa)
                                .Include(x => x.Unidade)
                                .Include(x => x.Usuario)
                                .Include(x => x.UsuarioOrigem)
                                .Include(x => x.UsuarioMedicao)
                                .Include(x => x.SolicitacaoServicoItem)
                                .ThenInclude(x => x.Produto)
                                .AsNoTracking().FirstOrDefault(x => x.ID == ID);

                var Result = db.SolicitacaoServicoMedicao
                                .AsNoTracking().FirstOrDefault(x => x.ID == SolicitacaoServicoMedicaoID);
                if (o != null && Result != null)
                {
                    var Email = "";

                    if (o.UsuarioMedicaoID.HasValue)
                    {
                        Email = o.UsuarioMedicao.Email;
                    } else if (o.UsuarioOrigemID.HasValue)
                    {
                        Email = o.UsuarioOrigem.Email;
                    } else
                    {
                        Email = o.Usuario.Email;
                    }

                    var html = HtmlMail.GetHtmlEmailMedicao(db, o, Result, TipoEmail.SolicitacaoServicoMedicaoStatus);
                     return SendEmail(db, o.Empresa, o.Unidade, Email, html, "Status Medição Nota Fiscal");
                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email status medição nota fiscal."
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço não encontrada: " + ex.Message
                };
            }
        }


        public static ReturnSendMail EmailMedicaoFornecedor(FBContext db, long ID, long SolicitacaoServicoMedicaoID)
        {
            try
            {
                var o = db.SolicitacaoServico
                                .Include(x => x.Empresa)
                                .Include(x => x.Unidade)
                                .Include(x => x.Usuario)
                                .Include(x => x.SolicitacaoServicoItem)
                                .ThenInclude(x => x.Produto)
                                .AsNoTracking().FirstOrDefault(x => x.ID == ID);

                var Result = db.SolicitacaoServicoMedicao
                                .AsNoTracking().FirstOrDefault(x => x.ID == SolicitacaoServicoMedicaoID);
                if (o != null && Result != null)
                {
                    var ResultFornecedor = db.SolicitacaoServicoFornecedor.Include(x => x.Fornecedor).FirstOrDefault(
                       x => x.SolicitacaoServicoID == ID &&
                       x.Vencedor
                       );

                    var html = HtmlMail.GetHtmlEmailMedicaoFornecedor(db, o, Result, ResultFornecedor, TipoEmail.SolicitacaoServicoMedicaoStatusFornecedor);
                    return SendEmail(db, o.Empresa, o.Unidade, ResultFornecedor.Fornecedor.Email, html, "Status Medição Nota Fiscal");
                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email status medição nota fiscal."
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço não encontrada: " + ex.Message
                };
            }
        }


        public static ReturnSendMail EmailMedicaoUnica(FBContext db, long ID, long SolicitacaoServicoMedicaoUnicaID)
        {
            try
            {
                var o = db.SolicitacaoServico
                                .Include(x => x.Empresa)
                                .Include(x => x.Unidade)
                                .Include(x => x.Usuario)
                                .Include(x => x.UsuarioOrigem)
                                .Include(x => x.UsuarioMedicao)
                                .Include(x => x.SolicitacaoServicoItem)
                                .ThenInclude(x => x.Produto)
                                .AsNoTracking().FirstOrDefault(x => x.ID == ID);

                var Result = db.SolicitacaoServicoMedicaoUnica
                                .AsNoTracking().FirstOrDefault(x => x.ID == SolicitacaoServicoMedicaoUnicaID);
                if (o != null && Result != null)
                {
                    var Email = "";

                    if (o.UsuarioMedicaoID.HasValue)
                    {
                        Email = o.UsuarioMedicao.Email;
                    }
                    else if (o.UsuarioOrigemID.HasValue)
                    {
                        Email = o.UsuarioOrigem.Email;
                    }
                    else
                    {
                        Email = o.Usuario.Email;
                    }

                    var html = HtmlMail.GetHtmlEmailMedicaoUnica(db, o, Result, TipoEmail.SolicitacaoServicoMedicaoStatus);
                    return SendEmail(db, o.Empresa, o.Unidade, Email, html, "Status Nota Fiscal Pedido");
                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email status medição nota fiscal."
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço não encontrada: " + ex.Message
                };
            }
        }

        public static ReturnSendMail EmailMedicaoUnicaFornecedor(FBContext db, long ID, long SolicitacaoServicoMedicaoUnicaID)
        {
            try
            {
                var o = db.SolicitacaoServico
                                .Include(x => x.Empresa)
                                .Include(x => x.Unidade)
                                .Include(x => x.Usuario)
                                .Include(x => x.SolicitacaoServicoItem)
                                .ThenInclude(x => x.Produto)
                                .AsNoTracking().FirstOrDefault(x => x.ID == ID);

                var Result = db.SolicitacaoServicoMedicaoUnica
                                .AsNoTracking().FirstOrDefault(x => x.ID == SolicitacaoServicoMedicaoUnicaID);
                if (o != null && Result != null)
                {
                    var ResultFornecedor = db.SolicitacaoServicoFornecedor.Include(x => x.Fornecedor).FirstOrDefault(
                       x => x.SolicitacaoServicoID == ID &&
                       x.Vencedor
                       );

                    var html = HtmlMail.GetHtmlEmailMedicaoUnicaFornecedor(db, o, Result, ResultFornecedor, TipoEmail.SolicitacaoServicoMedicaoStatusFornecedor);
                    return SendEmail(db, o.Empresa, o.Unidade, ResultFornecedor.Fornecedor.Email, html, "Status Nota Fiscal Pedido");
                }

                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email status medição nota fiscal."
                };
            }
            catch (Exception ex)
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "Erro envio email solicitação serviço não encontrada: " + ex.Message
                };
            }
        }

    }
}
