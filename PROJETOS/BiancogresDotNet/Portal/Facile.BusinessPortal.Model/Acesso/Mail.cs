using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class Mail : Base
    {
        public string Host { get; set; }
        public int Port { get; set; }
        public string User { get; set; }
        public string Password { get; set; }
        public bool SSL { get; set; }
        public string SenderEmail { get; set; }
        public string SenderDisplayName { get; set; }
        public string EmailCC { get; set; }
        public string EmailCCO { get; set; }
        public EmailModulo EmailModulo { get; set; }
    }
}
