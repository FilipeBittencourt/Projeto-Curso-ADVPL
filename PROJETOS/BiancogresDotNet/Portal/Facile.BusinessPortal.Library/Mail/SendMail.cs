using System;
using System.IO;
using System.Net;
using System.Net.Mail;

namespace Facile.BusinessPortal.Library.Mail
{
    public class SendMail
    {
        public string Host { get; set; }
        public int Port { get; set; }
        public string UserName { get; set; }
        public string Password { get; set; }
        public bool SSL { get; set; }
        public string SenderEmail { get; set; }
        public string SenderDisplayName { get; set; }
        public string EmailCC { get; set; }
        public string EmailCCO { get; set; }

        public SendMailReturn mailret;

        public SendMail(string _host, int _port, string _userName, string _password, bool _SSL = false, string _senderEmail = "", string _senderDisplayName = "", string emailCC = "", string emailCCO = "")
        {
            Host = _host;
            Port = _port;
            UserName = _userName;
            Password = _password;
            SSL = _SSL;
            SenderEmail = _senderEmail;
            SenderDisplayName = _senderDisplayName;
            EmailCC = emailCC;
            EmailCCO = emailCCO;

            mailret = new SendMailReturn();
        }

        public SendMailReturn EnviaEmailAnexo(string remetente, string destinatario, string assunto, string CC = "", string CCo = "", string mensagem = "", string filePath = "", string filename = "", bool IsHTML = false, string displayName = "")
        {

            // Estancia da Classe de Mensagem
            MailMessage _mailMessage = new MailMessage
            {
                From = new MailAddress(remetente, displayName)
            };

            // Remetente

            // Destinatario
            String[] _dests = destinatario.Split(';');

            foreach (String _dest in _dests)
            {
                if (!String.IsNullOrWhiteSpace(_dest))
                    _mailMessage.To.Add(_dest.Trim());
            }
            //Copia
            if (!String.IsNullOrEmpty(CC))
            {
                String[] _ccdests = CC.Split(';');
                foreach (String _ccdest in _ccdests)
                {
                    if (!String.IsNullOrWhiteSpace(_ccdest))
                        _mailMessage.CC.Add(_ccdest);
                }
            }
            //Copia Oculta
            if (!String.IsNullOrEmpty(CCo))
            {
                String[] _codests = CCo.Split(';');
                foreach (String _codest in _codests)
                {
                    if (!String.IsNullOrWhiteSpace(_codest))
                        _mailMessage.Bcc.Add(_codest);
                }
            }

            // Assunto
            _mailMessage.Subject = assunto;
            // A mensagem é do tipo HTML ou Texto Puro?
            _mailMessage.IsBodyHtml = IsHTML;
            // Corpo da Mensagem
            _mailMessage.Body = mensagem;

            FileStream _FileStream = null;
            try
            {
                //converte string em Buffer
                if (!String.IsNullOrEmpty(filePath))
                {
                    try
                    {
                        var path = @"" + filePath + filename;
                        if (File.Exists(path))
                        {
                            //_FileStream = File.OpenRead(filePath);
                            Attachment _anexo = new Attachment(filePath + filename);//new Attachment(_FileStream, filename);
                            _mailMessage.Attachments.Add(_anexo);
                        }
                    }
                    catch (Exception e)
                    {
                        mailret.Ok = false;
                        mailret.Mensagem = e.Message;
                    }
                }

                // Estancia a Classe de Envio
                SmtpClient _smtpClient = new SmtpClient(Host, Port)
                {
                    EnableSsl = SSL,
                    Timeout = 10000,
                    UseDefaultCredentials = true,
                    Credentials = new NetworkCredential(UserName, Password)
                };
                //_smtpClient.SendAsync();
                try
                {
                    // Envia a mensagem 
                    _smtpClient.Send(_mailMessage);

                    mailret.Ok = true;
                    mailret.Mensagem = String.Empty;
                }
                catch (SmtpException e)
                {
                    mailret.Ok = false;
                    mailret.Mensagem = "FALHA AO ENVIAR MENSAGEM DE EMAIL: " + Environment.NewLine + e.Message;
                }
                catch (Exception e)
                {
                    mailret.Ok = false;
                    mailret.Mensagem = "ERRO DE SMTP: " + Environment.NewLine + e.Message;
                }
            }
            finally
            {
                if (_FileStream != null)
                    _FileStream.Close();
            }

            return mailret;
        }
    }
}
