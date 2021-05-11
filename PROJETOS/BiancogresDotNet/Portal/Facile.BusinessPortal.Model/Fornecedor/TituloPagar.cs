using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class TituloPagar : Base
    {
        [Required]
        public Guid OID { get; set; }

        //Documento Gerador do titulo obrigatorio: NF, Fatura, Outros...
        protected long DocumentoPagarID { get; set; }
        [ForeignKey("DocumentoPagarID")]
        public virtual DocumentoPagar DocumentoPagar { get; set; }

        //Relacionar o documento tipo Fatura quando o titulo foi baixado com Fatura
        protected long? FaturaPagamentoID { get; set; }
        [ForeignKey("FaturaPagamentoID")]
        public virtual DocumentoPagar FaturaPagamento { get; set; }

        [Required]
        public string NumeroDocumento { get; set; }

        //[Required]
        public string Parcela { get; set; }

        [Required]
        [DataType(DataType.Date)]
        [Column(TypeName = "Date")]
        public DateTime DataEmissao { get; set; }

        [DataType(DataType.Date)]
        [Column(TypeName = "Date")]
        public DateTime DataVencimento { get; set; }

        public DateTime? DataBaixa { get; set; }

        public FormaPagamento? FormaPagamento { get; set; }

        [DataType(DataType.Date)]
        [Column(TypeName = "Date")]
        public DateTime? DataPagamento { get; set; }

        [Required]
        public decimal ValorTitulo { get; set; }

        [Required]
        public decimal Saldo { get; set; }

        //Numero unico da Empresa para identificacao em APIs de Integracao
        public string NumeroControleParticipante { get; set; }

        public TipoDocumentoPagar? TipoDocumento { get; set; }

    }
}
