using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class Arquivo : Base
    {
        public string Nome { get; set; }
        public string Path { get; set; }
        protected long? CedenteID { get; set; }
        [ForeignKey("CedenteID")]
        public virtual Cedente Cedente { get; set; }
        public TipoOperacao? TipoOperacao { get; set; }
        public TipoArquivo? TipoArquivo { get; set; }
        public DirecaoArquivo? DirecaoArquivo { get; set; }
        public virtual ICollection<Registro> Registros { get; set; }
    }
}
