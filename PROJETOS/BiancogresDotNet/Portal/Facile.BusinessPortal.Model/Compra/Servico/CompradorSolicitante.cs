using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class CompradorSolicitante : Base
    {
        public long CompradorID { get; set; }
        [ForeignKey("CompradorID")]
        public virtual Comprador Comprador { get; set; }

        public long UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

     
    }
}
