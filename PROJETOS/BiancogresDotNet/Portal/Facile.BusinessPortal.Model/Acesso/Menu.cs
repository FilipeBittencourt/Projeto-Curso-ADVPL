using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class Menu : Base
    {
        [Required(ErrorMessage = "Nome é obrigatório")]
        public string Nome { get; set; }
        [Required(ErrorMessage = "Descrição é obrigatório")]
        [Display(Name = "Descrição")]
        public string Descricao { get; set; }
        public int Ordem { get; set; }
        [Display(Name = "Classe Icone")]
        public string ClasseIcone { get; set; }


        //[Required(ErrorMessage = "Menu é obrigatório")]
        [Display(Name = "Menu")]
        public long? MenuSuperiorID { get; set; }
        [ForeignKey("MenuSuperiorID")]
        public virtual Menu MenuSuperior { get; set; }


        [Required(ErrorMessage = "Modulo é obrigatório")]
        [Display(Name = "Modulo")]
        public long ModuloID { get; set; }
        [ForeignKey("ModuloID")]
        public virtual Modulo Modulo { get; set; }


        public virtual ICollection<MenuAcao> MenuAcao { get; set; }
    }
}
