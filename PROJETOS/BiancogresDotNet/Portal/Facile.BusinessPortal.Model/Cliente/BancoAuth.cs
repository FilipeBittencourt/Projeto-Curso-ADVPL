using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class BancoAuth : Base
    {
        [Required]
        public long CedenteID { get; set; }
        [ForeignKey("CedenteID")]
        public virtual Cedente Cedente { get; set; }
        public MetodoBanco MetodoBanco { get; set; }
        public bool Homologacao { get; set; }
        public string EndPoint { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
    }
}
