using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Mail;
using Facile.BusinessPortal.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Facile.BusinessPortal.BusinessRules.Util
{
    public static class MailEmpresa
    {
        public static SendMail ConnectMail(FBContext db, Unidade unidade, EmailModulo emailModulo = 0)
        {
            SendMail mail = null;
            MailStruct mparams = null;

            //conta de e-mail geral da empresa
            var qmail = from Mail m in db.Mail
                        where m.EmpresaID == unidade.EmpresaID &&
                        (!m.UnidadeID.HasValue || m.UnidadeID == unidade.ID) &&
                         m.EmailModulo == emailModulo
                        select m;

            if (qmail.Any())
            {
                var mailBase = qmail.First();

                mparams = new MailStruct
                {
                    MailHost = mailBase.Host,
                    MailPort = mailBase.Port,
                    MailUser = mailBase.User,
                    MailPassword = mailBase.Password,
                    SSL = mailBase.SSL,
                    MailSender = mailBase.SenderEmail ?? "",
                    MailDisplayName = mailBase.SenderDisplayName ?? "",
                    EmailCC = mailBase.EmailCC,
                    EmailCCO = mailBase.EmailCCO,
                    
                };
            }
            else
            {
                var host = "mail.facilesistemas.com.br";
                var port = 587;
                var user = "suporte.biancogres@facilesistemas.com.br";
                var password = "Bi@ncogres";
                var senderEmail = "suporte.biancogres@facilesistemas.com.br";
                var senderDisplayName = "Suporte Facile Cloud Apps";
                var ssl = false;

                mparams = new MailStruct
                {
                    MailHost = host,
                    MailPort = port,
                    MailUser = user,
                    MailPassword = password,
                    SSL = ssl,
                    MailSender = senderEmail,
                    MailDisplayName = senderDisplayName,
                    EmailCC = "",
                    EmailCCO = ""
                };
            }

            mail = MailUtil.ConnectMail(mparams);
            return mail;
        }
    }
}
