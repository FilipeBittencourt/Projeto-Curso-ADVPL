using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class Boleto : Titulo
    {
        [Required]
        public string NossoNumero { get; set; }

        public string NossoNumeroDV { get; set; } = string.Empty;

        public string NossoNumeroFormatado { get; set; } = string.Empty;

        public string CodigoDeBarras { get; set; }

        public string LinhaDigitavel { get; set; } 

        public string CampoLivre { get; set; }

        public long FatorVencimento { get; set; }

        public string DigitoVerificador { get; set; }

        public int CodigoMoeda { get; set; } = 9;

        public string EspecieMoeda { get; set; }

        public int QuantidadeMoeda { get; set; }

        public string ValorMoeda { get; set; } = string.Empty;

        public TipoCarteira? TipoCarteira { get; set; }

        public string Carteira { get; set; } = string.Empty;

        public string VariacaoCarteira { get; set; } = string.Empty;

        public string CarteiraComVariacao => string.IsNullOrEmpty(Carteira) || string.IsNullOrEmpty(VariacaoCarteira) ? $"{Carteira}{VariacaoCarteira}" : $"{Carteira}/{VariacaoCarteira}";

        public string Aceite { get; set; }

        public string UsoBanco { get; set; } = string.Empty;

        public string CodigoInstrucao1 { get; set; }

        public string CodigoInstrucao2 { get; set; }

        [DataType(DataType.Date)]
        [Column(TypeName = "Date")]
        public DateTime? DataDesconto { get; set; }

        public decimal? ValorDesconto { get; set; }

        [DataType(DataType.Date)]
        [Column(TypeName = "Date")]
        public DateTime? DataMulta { get; set; }

        public decimal? PercentualMulta { get; set; }

        public decimal? ValorMulta { get; set; }

        [DataType(DataType.Date)]
        [Column(TypeName = "Date")]
        public DateTime? DataJuros { get; set; }

        public decimal? PercentualJurosDia { get; set; }

        public decimal? ValorJurosDia { get; set; }

        public TipoCodigoProtesto? CodigoProtesto { get; set; }

        public int? DiasProtesto { get; set; }

        public bool EnviarEmailSacado { get; set; }

        public bool EnviarEmailCedente { get; set; }

        public bool RegistroOnline { get; set; }

        public StatusAPI StatusAPIRegistro { get; set; }

        public string MensagemRetornoAPI { get; set; }

        public bool EmailEnviado { get; set; }
    }
}
