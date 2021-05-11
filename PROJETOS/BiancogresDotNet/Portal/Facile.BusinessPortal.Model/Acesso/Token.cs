using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class Token: Padrao
    {
        public long UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

        [Required]
        public DateTime DataHoraVencimento { get; set; }
        
        public TipoToken TipoToken { get; set; }

        [Required]
        public string Chave { get; set; }
    }
}
