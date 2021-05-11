using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.ViewModels
{
    public class LoginViewModel
    {
        [Required]
        public string Usuario { get; set; }

        [Required]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        /// <summary>
        /// Token de confirmação de E-mail
        /// </summary>
        public string Token { get; set; }

        [Display(Name = "Remember me?")]
        public bool RememberMe { get; set; }
    }
}
