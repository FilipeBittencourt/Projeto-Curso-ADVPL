using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.Model
{
    public class Acao : Base
    {
        [Required(ErrorMessage = "Nome é obrigatório")]
        public string Nome { get; set; }
        [Display(Name = "Código")]
        [Required(ErrorMessage = "Código é obrigatório")]
        public string Codigo { get; set; }
    }
}
