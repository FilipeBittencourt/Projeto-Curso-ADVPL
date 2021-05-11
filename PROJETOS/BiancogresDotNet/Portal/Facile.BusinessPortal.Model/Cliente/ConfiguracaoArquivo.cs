using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class ConfiguracaoArquivo : Base
    {
        public long CedenteID { get; set; }
        [ForeignKey("CedenteID")]
        public virtual Cedente Cedente { get; set; }

        [Required]
        public TipoOperacao TipoOperacao { get; set; }

        public TipoArquivo TipoArquivo { get; set; }

        [Required]
        public DirecaoArquivo DirecaoArquivo { get; set; }

        [Required]
        public string NomeDiretorio { get; set; }

        public string NomeBase { get; set; }

        public string Extensao { get; set; }

        public int NumeroSequencial { get; set; }
    }
}
