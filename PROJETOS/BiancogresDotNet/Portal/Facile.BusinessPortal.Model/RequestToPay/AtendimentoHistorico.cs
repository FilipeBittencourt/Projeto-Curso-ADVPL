using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class AtendimentoHistorico: Base
    {
        public long AtendimentoID { get; set; }
        [ForeignKey("AtendimentoID")]
        public virtual Atendimento Atendimento { get; set; }

        public long UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

        public DateTime DataEvento { get; set; }

        public string Observacao { get; set; }

        public StatusAtendimento Status { get; set; }
    }
}
