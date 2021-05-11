using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.Model
{
    public class Unidade : Base
    {
        [Required]
        [MinLength(14)]
        [MaxLength(14)]
        public string CNPJ { get; set; }
        [Required]
        public string Codigo { get; set; }
        [Required]
        public string Nome { get; set; }
        public string Apelido { get; set; }
        public string Secret_Key { get; set; }
    }
}
