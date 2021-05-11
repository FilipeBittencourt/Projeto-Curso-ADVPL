using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class Usuario : Base
    {
        [Required]
        public string UserId { get; set; }
        public string Nome { get; set; }
        public string Email { get; set; }
        public string Senha { get; set; }
        public DateTime? UltimoAcesso { get; set; }
        public TipoUsuario Tipo { get; set; }

        public string TokenConfirm { get; set; }
        public DateTime? TokenValid { get; set; }

        [Display(Name = "Grupo Usuario")]
        public long GrupoUsuarioID { get; set; }
        [ForeignKey("GrupoUsuarioID")]
        public virtual GrupoUsuario GrupoUsuario { get; set; }

        public string Status()
        {
            return Habilitado ? "Ativo" : "Inativo";
        }
        [NotMapped]
        public bool Admin { get; set; }
        [NotMapped]
        public long? UsuarioOrigemID { get; set; }

        [NotMapped]
        public virtual string CPF { get; set; }
        [NotMapped]
        public virtual ICollection<UsuarioGrupo> UsuarioGrupo { get; set; }
    }
}
