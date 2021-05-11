using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.BusinessPortal.Library.Mail
{
    public class MailStruct
    {
        public string MailHost { get; set; }
        public int MailPort { get; set; }
        public string MailUser { get; set; }
        public string MailPassword { get; set; }
        public string MailSender { get; set; }
        public string MailDisplayName { get; set; }
        public bool SSL { get; set; }
        public string EmailCC { get; set; }
        public string EmailCCO { get; set; }
    }
}
