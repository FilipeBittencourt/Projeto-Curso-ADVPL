using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class MenuAcao : Base
    {
        public long MenuID { get; set; }
        [ForeignKey("MenuID")]
        public virtual Menu Menu { get; set; }

        public long AcaoID { get; set; }
        [ForeignKey("AcaoID")]
        public virtual Acao Acao { get; set; }
    }
}
