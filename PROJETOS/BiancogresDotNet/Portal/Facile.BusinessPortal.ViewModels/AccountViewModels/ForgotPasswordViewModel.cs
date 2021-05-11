using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.ViewModels
{
    public class ForgotPasswordViewModel
    {
        [Required]
        public string Usuario { get; set; }
    }
}
