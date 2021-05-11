using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class GrupoAcesso : Base
    {
        public long GrupoAcessoID { get; set; }      

        public string Nome { get; set; }
        

    }
}
