using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class Permissao : Base
    {
        public long GrupoUsuarioID { get; set; }
        [ForeignKey("GrupoUsuarioID")]
        public virtual GrupoUsuario GrupoUsuario { get; set; }

        public long MenuID { get; set; }
        [ForeignKey("MenuID")]
        public virtual Menu Menu { get; set; }

        public long AcaoID { get; set; }
        [ForeignKey("AcaoID")]
        public virtual Acao Acao { get; set; }

        public string Acesso { get; set; }
    }
}
