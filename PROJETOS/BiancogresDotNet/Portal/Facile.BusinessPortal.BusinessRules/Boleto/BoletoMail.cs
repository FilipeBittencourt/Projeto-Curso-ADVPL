using Facile.BusinessPortal.BusinessRules.Util;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Mail;
using Facile.BusinessPortal.Library.Structs.Interna;
using Facile.BusinessPortal.Model;
using Facile.Financeiro.BoletoNetCore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using Cedente = Facile.BusinessPortal.Model.Cedente;

namespace Facile.BusinessPortal.BusinessRules.Boleto
{
    public static class BoletoMail
    {
        private static Unidade unidade;

        public static string SendAnexo(FBContext db, SendMail mail, string subject, string fileName, string filePath,
            string nomeSacado, string emailDestinatario, List<Financeiro.BoletoNetCore.Boleto> list, Cedente cedente, Unidade unidade,
            string cc = "", string cco = "")
        {
            var send = mail.SenderEmail;

            var destino = emailDestinatario;

            //TODO: TESTES
            //destino = "fernando@facilesistemas.com.br";

            var html = HtmlMail.GetHtmlCedente(db, cedente, TipoEmail.FaturaCliente, nomeSacado, list, unidade);

            var mensagem = html;

            var wfret = mail.EnviaEmailAnexo(send, destino, subject, cc, cco, mensagem, filePath, fileName, true, mail.SenderDisplayName);

            return wfret.Mensagem;
        }

        public static List<ReturnSendMail> BoletoSendMail(FBContext _context, List<Model.Boleto> boletoBase)
        {
            List<ReturnSendMail> ListaReturnSendMail = new List<ReturnSendMail>();

            var distinctSacado = boletoBase.GroupBy(p => p.Sacado.CPFCNPJ).Select(g => g.First().Sacado).ToList();

            foreach (var s in distinctSacado)
            {
                var listBoletoSac = boletoBase.Where(o => o.Sacado.CPFCNPJ == s.CPFCNPJ).ToList();

                if (listBoletoSac.Count > 0)
                {
                    unidade = boletoBase.First().Unidade;

                    var enviaCedente = false;
                    var enviaSacado = true;

                    var listBoletoNet = FactoryBoletoNet.ListBoletoToBoletoNet(listBoletoSac);

                    var sacado = listBoletoSac.First().Sacado;
                    var cedente = listBoletoSac.First().Cedente;

                    bool zip = cedente.BoletoZip;
                    bool boletoSenha = cedente.BoletoSenha;
                    string NomeBasePdfBoleto = cedente.NomeBasePdfBoleto;


                    var pdfMail = BoletoFile.GetPDF(listBoletoNet, NomeBasePdfBoleto, zip, boletoSenha);
                    var fileName = zip ? pdfMail.FileNameZip : pdfMail.FileName;
                    var ResultMail = SendMail(_context, listBoletoNet, sacado, cedente, enviaSacado, enviaCedente, false, fileName, pdfMail.FilePath, "");
                    ListaReturnSendMail.Add(ResultMail);
                }
            }

            return ListaReturnSendMail;
        }


        private static ReturnSendMail SendMail(
            FBContext context, List<Financeiro.BoletoNetCore.Boleto> listBoleto, Model.Sacado sacado, Model.Cedente cedente,
                                        bool enviaEmailSacado, bool enviaEmailCedente, bool reimpressao, string fileName,
                                        string filePath, string emailCopia = "", string emailCCO = "")
        {
            if (listBoleto.Count <= 0)
            {
                return new ReturnSendMail()
                {
                    Status = true,
                    Mensagem = "Nenhum registro encontrado."
                };
            }

            //Email do Sacado
            string emailSacado = string.Empty;
            if (!string.IsNullOrWhiteSpace(sacado.Email))
            {
                emailSacado = sacado.Email.Trim();
            }

            //Email de homologação do Cedente
            if (cedente.Homologacao)
            {
                if (!string.IsNullOrWhiteSpace(cedente.EmailHomologacao))
                {
                    emailSacado = cedente.EmailHomologacao.Trim();
                }
                else
                {
                    return new ReturnSendMail()
                    {
                        Status = false,
                        Mensagem = cedente.Nome + " : EMAIL DE HOMOLOGAÇÃO CEDENTE NÃO CADASTRADO."
                    };
                }
            }

            if (!enviaEmailSacado)
            {
                emailSacado = string.Empty;
            }

            //Email do Cedente
            string emailCedente = string.Empty;
            if (enviaEmailCedente && !string.IsNullOrWhiteSpace(cedente.Email))
            {
                emailCedente = cedente.Email.Trim();

                //se sacado sem email ou não envia - enviar somente para o cedente
                if (string.IsNullOrWhiteSpace(emailSacado))
                {
                    emailSacado = emailCedente;
                    emailCedente = string.Empty;
                }
            }

            if (!string.IsNullOrWhiteSpace(emailSacado))
            {
                string assunto = "[Portal]";
                // listBoleto.First().;
                if (!string.IsNullOrWhiteSpace(unidade.Nome))
                    assunto = "[" + unidade.Nome.ToUpper().Trim() + "]";

                if (reimpressao)
                {
                    assunto += " " + ContextUtil.GetParametroPorChave(context, "ASSUNTO_EMAIL_BOLETO_2VIA", unidade.EmpresaID) ?? "Segunda via de boleto de cobrança";
                }
                else
                {
                    assunto += " " + ContextUtil.GetParametroPorChave(context, "ASSUNTO_EMAIL_BOLETO", unidade.EmpresaID) ?? "Envio de boleto de cobrança";
                }

                var emailServer = MailEmpresa.ConnectMail(context, unidade);

                if (emailServer != null)
                {
                    if (cedente.Homologacao)
                    {
                        assunto = "[TESTE PORTAL] " + assunto;
                    }

                    emailCopia = string.IsNullOrWhiteSpace(emailCopia) ? emailServer.EmailCC : emailCopia;
                    emailCCO = string.IsNullOrWhiteSpace(emailCCO) ? emailServer.EmailCCO : emailCCO;

                    var retMail = SendAnexo(context, emailServer, assunto, fileName, filePath, sacado.Nome, emailSacado, listBoleto, cedente, unidade, emailCopia, emailCCO);
                    if (!string.IsNullOrEmpty(retMail))
                    {
                        foreach (var bol in listBoleto)
                        {
                            if (bol.Banco.Codigo == 21)//banestes
                            {
                                var qbolbase = from Model.Boleto b in context.Boleto
                                               where b.EmpresaID == cedente.EmpresaID &&
                                               b.CedenteID == cedente.ID &&
                                               b.CodigoBanco == cedente.ContaBancaria.Banco.Codigo &&
                                               b.NossoNumero.Substring(0, 8) == bol.NossoNumero &&
                                               !b.Deletado
                                               select b;

                                if (qbolbase.Any() && qbolbase.Count() == 1)
                                {
                                    qbolbase.First().EmailEnviado = false;
                                    qbolbase.First().MensagemRetorno = "ERRO ENVIAR EMAIL: " + retMail;
                                }

                            } else
                            {
                                var qbolbase = from Model.Boleto b in context.Boleto
                                               where b.EmpresaID == cedente.EmpresaID &&
                                               b.CedenteID == cedente.ID &&
                                               b.CodigoBanco == cedente.ContaBancaria.Banco.Codigo &&
                                               b.NossoNumero == bol.NossoNumero &&
                                               !b.Deletado
                                               select b;

                                if (qbolbase.Any() && qbolbase.Count() == 1)
                                {
                                    qbolbase.First().EmailEnviado = false;
                                    qbolbase.First().MensagemRetorno = "ERRO ENVIAR EMAIL: " + retMail;
                                }
                            }
                            
                        }
                        context.SaveChanges();

                        return new ReturnSendMail()
                        {
                            Status = false,
                            Mensagem = "ERRO ENVIAR EMAIL: " + retMail
                        };
                    }
                    else
                    {
                        foreach(var bol in listBoleto)
                        {
                            if (bol.Banco.Codigo == 21)//banestes
                            {
                                var qbolbase = from Model.Boleto b in context.Boleto
                                               where b.EmpresaID == cedente.EmpresaID &&
                                               b.CedenteID == cedente.ID &&
                                               b.CodigoBanco == cedente.ContaBancaria.Banco.Codigo &&
                                               b.NossoNumero.Substring(0, 8) == bol.NossoNumero &&
                                               !b.Deletado
                                               select b;

                                if (qbolbase.Any() && qbolbase.Count() == 1)
                                {
                                    qbolbase.First().EmailEnviado = true;
                                }

                            } else
                            {
                                var qbolbase = from Model.Boleto b in context.Boleto
                                               where b.EmpresaID == cedente.EmpresaID &&
                                               b.CedenteID == cedente.ID &&
                                               b.CodigoBanco == cedente.ContaBancaria.Banco.Codigo &&
                                               b.NossoNumero == bol.NossoNumero &&
                                               !b.Deletado
                                               select b;

                                if (qbolbase.Any() && qbolbase.Count() == 1)
                                {
                                    qbolbase.First().EmailEnviado = true;
                                }
                            }
                            
                        }
                        context.SaveChanges();

                        return new ReturnSendMail()
                        {
                            Status = true,
                            Mensagem = "E-mail enviado com sucesso."
                        };
                    }
                }
                else
                {
                    return new ReturnSendMail()
                    {
                        Status = false,
                        Mensagem = "SERVIDOR/CONTA DE E-MAIL NÃO CONFIGURADA PARA A UNIDADE."
                    };
                }
            }
            else
            {
                return new ReturnSendMail()
                {
                    Status = false,
                    Mensagem = "ERRO ENVIAR EMAIL: NENHUM EMAIL CONFIGURADO PARA ENVIO."
                };
            }
        }


    }
}
