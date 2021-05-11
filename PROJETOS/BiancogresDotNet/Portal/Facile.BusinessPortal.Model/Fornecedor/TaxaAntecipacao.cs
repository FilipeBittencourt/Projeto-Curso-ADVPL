using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class TaxaAntecipacao : Base
    {
        public long? FornecedorID { get; set; }
        [ForeignKey("FornecedorID")]
        public virtual Fornecedor Fornecedor { get; set; }

        public decimal PercentualPorDia { get; set; }

        public TipoTaxaAntecipacao? TipoTaxa { get; set; }

        public decimal? Multiplicador { get; set; }
    }
}
