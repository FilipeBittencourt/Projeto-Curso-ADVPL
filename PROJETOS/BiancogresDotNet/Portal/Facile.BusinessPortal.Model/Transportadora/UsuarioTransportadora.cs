using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class UsuarioTransportadora : Base
    {
        public long UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

        public long TransportadoraID { get; set; }
        [ForeignKey("TransportadoraID")]
        public virtual Transportadora Transportadora { get; set; }
    }
}
