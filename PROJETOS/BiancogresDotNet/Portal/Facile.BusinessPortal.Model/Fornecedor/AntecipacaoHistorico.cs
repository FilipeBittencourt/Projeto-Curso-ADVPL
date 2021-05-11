using System;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class AntecipacaoHistorico: Base
    {
        public long AntecipacaoID { get; set; }
        [ForeignKey("AntecipacaoID")]
        public virtual Antecipacao Antecipacao { get; set; }

        public long UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

        public DateTime DataEvento { get; set; }

        public string Observacao { get; set; }

        public StatusAntecipacao Status { get; set; }

    }
}
