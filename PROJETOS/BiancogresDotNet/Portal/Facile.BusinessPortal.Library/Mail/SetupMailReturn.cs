using System;

namespace Facile.BusinessPortal.Library.Mail
{
    public struct SetupMailSMTP
    {
        public String host;
        public String port;
        public String username;
        public String password;
        public String auth;
    }

    public struct SetupMailPerson
    {
        public String remetente;
        public String destinatario;
    }
}
