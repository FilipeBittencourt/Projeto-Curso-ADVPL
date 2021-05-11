using Facile.BusinessPortal.Library;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class Modulo : Base
    {
        [Required(ErrorMessage = "Nome é obrigatório")]
        public string Nome { get; set; }

        [Required(ErrorMessage = "URL é obrigatório")]
        public string URL { get; set; }

        [Display(Name = "Classe Icone")]
        public string ClasseIcone { get; set; }

        /// <summary>
        /// Se o modulo é customizavel - A Empresa pode incluir e alterar Menus e Funcionalidades especificas para cada Modulo
        /// </summary>
        public bool Customizavel { get; set; }

        /// <summary>
        /// Tipo de Usuario do Modulo - Quando o modulo tem um tipo especifico
        /// </summary>
        public TipoUsuario? TipoUsuario { get; set; }
    }
}
