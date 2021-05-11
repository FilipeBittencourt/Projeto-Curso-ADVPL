using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class ContaBancaria : Base
    {
        public long BancoID { get; set; }
        [ForeignKey("BancoID")]
        public virtual Banco Banco { get; set; }

        [Required]
        [Display(Name = "Agência")]
        public string Agencia { get; set; }

        [Display(Name = "Digito Agência")]
        public string DigitoAgencia { get; set; }

        [Required]
        public string Conta { get; set; }

        [Required]
        [Display(Name = "Digito Conta")]
        public string DigitoConta { get; set; }

        [Display(Name = "Carteira Padrão")]
        public string CarteiraPadrao { get; set; }

        [Display(Name = "Variação Carteira Padrão")]
        public string VariacaoCarteiraPadrao { get; set; }

        [Display(Name = "Tipo Carteira Padrão")]
        public TipoCarteira? TipoCarteiraPadrao { get; set; }

        [Display(Name = "Tipo Forma Cadastramento")]
        public TipoFormaCadastramento? TipoFormaCadastramento { get; set; }

        [Display(Name = "Tipo Impressão Boleto")]
        public TipoImpressaoBoleto? TipoImpressaoBoleto { get; set; }

        [Display(Name = "Especie Documento")]
        public TipoEspecieDocumento? EspecieDocumento { get; set; }

        [Display(Name = "Aceite Padrão")]
        public string AceitePadrao { get; set; }

        [Display(Name = "Especie Moeda")]
        public string EspecieMoeda { get; set; }

        [Display(Name = "FIDC")]
        public int FIDCAtivo { get; set; }

        public long? FIDCID { get; set; }
        [ForeignKey("FIDCID")]
        public virtual FIDC FIDC { get; set; }

    }
}
