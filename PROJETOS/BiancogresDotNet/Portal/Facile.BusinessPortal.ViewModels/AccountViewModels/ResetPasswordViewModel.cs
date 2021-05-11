using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.ViewModels
{
    public class ResetPasswordViewModel
    {
        [Required]
        public string Usuario { get; set; }

        [Required]
        [StringLength(100, ErrorMessage = "A senha precisa ter pelo menos {2} digitos.", MinimumLength = 6)]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        [DataType(DataType.Password)]
        [Display(Name = "Confirmar senha")]
        [Compare("Password", ErrorMessage = "A senha e a confirmação da senha digitada não conferem.")]
        public string ConfirmPassword { get; set; }

        /// <summary>
        /// Token de confirmação recebido por E-mail
        /// </summary>
        public string Token { get; set; }
    }
}
