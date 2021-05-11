using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class AntecipacaoItem: Base
    {
        public long AntecipacaoID { get; set; }
        [ForeignKey("AntecipacaoID")]
        public virtual Antecipacao Antecipacao { get; set; }


        public long TituloPagarID { get; set; }
        [ForeignKey("TituloPagarID")]
        public virtual TituloPagar TituloPagar { get; set; }

        public decimal ValorTitulo { get; set; }
        
        public decimal ValorTituloAntecipado { get; set; }

    }
}
