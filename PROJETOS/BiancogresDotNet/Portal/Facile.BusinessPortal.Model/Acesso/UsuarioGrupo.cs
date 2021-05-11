using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class UsuarioGrupo : Base
    {
        public long GrupoUsuarioID { get; set; }
        [ForeignKey("GrupoUsuarioID")]
        public virtual GrupoUsuario GrupoUsuario { get; set; }

        public long UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

    }
}
