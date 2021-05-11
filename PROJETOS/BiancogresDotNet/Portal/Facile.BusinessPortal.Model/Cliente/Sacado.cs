using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class Sacado : Pessoa
    {
        public long? GrupoSacadoID { get; set; }
        [ForeignKey("GrupoSacadoID")]
        public virtual GrupoSacado Grupo { get; set; }

        public bool MestreGrupo { get; set; }
    }
}
