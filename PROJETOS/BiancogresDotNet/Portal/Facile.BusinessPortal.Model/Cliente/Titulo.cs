using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class Titulo : Base
    {
        [Required]
        public Guid OID { get; set; }

        [Required]
        [MinLength(3)]
        [MaxLength(3)]
        public string CodigoBanco { get; set; }

        public long BancoID { get; set; }

        [ForeignKey("BancoID")]
        public virtual Banco Banco { get; set; }
        
        public long CedenteID { get; set; }

        [ForeignKey("CedenteID")]
        public virtual Cedente Cedente { get; set; }

        public long SacadoID { get; set; }

        [ForeignKey("SacadoID")]
        public virtual Sacado Sacado { get; set; }
        
        [Required]
        [DataType(DataType.Date)]
        [Column(TypeName = "Date")]
        public DateTime DataEmissao { get; set; }

        [DataType(DataType.Date)]
        [Column(TypeName = "Date")]
        public DateTime? DataProcessamento { get; set; }

        [DataType(DataType.Date)]
        [Column(TypeName = "Date")]
        public DateTime DataVencimento { get; set; }

        [DataType(DataType.Date)]
        [Column(TypeName = "Date")]
        public DateTime? DataRecebimento { get; set; }

        [Required]
        public decimal ValorTitulo { get; set; }

        public decimal? ValorOutrosAcrescimos { get; set; }

        public string NumeroDocumento { get; set; }

        public TipoEspecieDocumento? EspecieDocumento { get; set; }
        
        public string MensagemArquivoRemessa { get; set; }

        public string MensagemInstrucoesCaixa { get; set; }

        public string NumeroControleParticipante { get; set; }

        public long? LoteID { get; set; }

        [ForeignKey("LoteID")]
        public virtual Lote Lote { get; set; }
    }
}
