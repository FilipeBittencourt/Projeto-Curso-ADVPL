using System.Collections.Generic;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class GrupoUsuario : Base
    {
        public string Nome { get; set; }
        public virtual ICollection<Permissao> Permissao { get; set; }
        public TipoGrupoUsuario Tipo { get; set; }

        public string Status()
        {
            return Habilitado ? "Ativo" : "Inativo";
        }
    }
}
