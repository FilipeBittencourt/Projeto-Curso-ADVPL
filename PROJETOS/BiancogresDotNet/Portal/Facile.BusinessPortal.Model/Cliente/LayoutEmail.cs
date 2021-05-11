using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class LayoutEmail : Base
    {
        protected long? CedenteID { get; set; }
        [ForeignKey("CedenteID")]
        public virtual Cedente Cedente { get; set; }

        public TipoEmail TipoEmail { get; set; }
        public string Titulo { get; set; }
        public byte[] BodyHtml { get; set; }
        public byte[] LinhasTabela01Html { get; set; }
        public string LinkImagem01 { get; set; }
        public string LinkImagem02 { get; set; }
        public string LinkImagem03 { get; set; }
        public string LinkFaleConosco { get; set; }
        public bool GeraDivSocial { get; set; }
        public string LinkFacebook { get; set; }
        public string LinkInstagram { get; set; }
        public string LinkYoutube { get; set; }
        public string LinkPinterest { get; set; }
    }
}

