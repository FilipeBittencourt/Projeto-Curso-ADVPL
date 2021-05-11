using Facile.BusinessPortal.Library;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class AtendimentoMedicao: Base
    {
        public long AtendimentoID { get; set; }
        [ForeignKey("AtendimentoID")]
        public virtual Atendimento Atendimento { get; set; }
        public string Nome { get; set; }
        public string Tipo { get; set; }
        public string Descricao { get; set; }
        public byte[] Arquivo { get; set; }

    }
}
