using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class UsuarioFornecedor : Base
    {
        public long UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

        public long FornecedorID { get; set; }
        [ForeignKey("FornecedorID")]
        public virtual Fornecedor Fornecedor { get; set; }
    }
}
