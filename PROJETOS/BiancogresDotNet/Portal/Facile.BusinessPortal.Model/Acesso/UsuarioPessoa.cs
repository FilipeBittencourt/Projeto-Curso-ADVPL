using Facile.BusinessPortal.Library;
using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class UsuarioPessoa: Base
    {
        public long UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

        public long PessoaID { get; set; }
        
        public TipoUsuario Tipo { get; set; }
    }
}
