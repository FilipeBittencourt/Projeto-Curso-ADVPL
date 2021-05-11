using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.Model
{
    public class Parametro : Base
    {
        [Required(ErrorMessage = "Chave é obrigatório")]
        public string Chave { get; set; }
        [Display(Name = "Valor")]
        [Required(ErrorMessage = "Tipo é obrigatório")]
        public string Tipo { get; set; }
        [Required(ErrorMessage = "Valor é obrigatório")]
        public string Valor { get; set; }
    }
}
