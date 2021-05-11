using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.Model
{
    public class GrupoSacado : Base
    {
        [Required]       
        public string CodigoUnico { get; set; }
        
        public string Nome { get; set; }

        public virtual ICollection<Sacado> Sacados { get; set; }
    }
}
