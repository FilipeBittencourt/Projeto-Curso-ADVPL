using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class UsuarioCliente: Base
    {
        public long UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

        public long SacadoID { get; set; }
        [ForeignKey("SacadoID")]
        public virtual Sacado Sacado { get; set; }

        public long? GrupoSacadoID { get; set; }
        [ForeignKey("GrupoSacadoID")]
        public virtual GrupoSacado Grupo { get; set; }
    }
}
