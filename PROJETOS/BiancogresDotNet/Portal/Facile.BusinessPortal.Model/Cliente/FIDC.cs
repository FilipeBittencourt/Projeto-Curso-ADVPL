using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class FIDC : Base
    {
        [Required]
        public Guid OID { get; set; }

        [Required]
        public string CPFCNPJ { get; set; }

        [Required]
        public string Nome { get; set; }

        [Required]
        public string CEP { get; set; }

        public string Logradouro { get; set; }

        public string Numero { get; set; }

        public string Complemento { get; set; }

        public string Bairro { get; set; }

        public string UF { get; set; }

        public string Cidade { get; set; }

        public string Observacoes { get; set; }

    }
}
