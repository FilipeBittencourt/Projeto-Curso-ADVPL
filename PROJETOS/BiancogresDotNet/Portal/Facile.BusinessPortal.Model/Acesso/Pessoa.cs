using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Facile.BusinessPortal.Model
{
    public class Pessoa: Base
    {
        [Required]
        public string CPFCNPJ { get; set; }

        [Required]
        public string Nome { get; set; }
        public string Email { get; set; }           //Email unico vinculado ao usuario de acesso
        public string EmailWorkflow { get; set; }   //Email que pode ser mais de 1 para envios de boletos/workflows
        public string Observacoes { get; set; }
        public string CodigoERP { get; set; }


        [Required(ErrorMessage = "Campo CEP requerido.")]
        public string CEP { get; set; }
        [Required]
        public string Logradouro { get; set; }
        public string Numero { get; set; }
        public string Complemento { get; set; }
        public string Bairro { get; set; }
        [Required]
        public string UF { get; set; }
        [Required]
        public string Cidade { get; set; }
    }
}
