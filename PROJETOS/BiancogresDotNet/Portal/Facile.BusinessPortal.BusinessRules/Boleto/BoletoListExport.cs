using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Facile.BusinessPortal.BusinessRules
{
    public class BoletoListExport
    {
        [DisplayName("Empresa")]
        public string NomeUnidade { get; set; }

        public string Sacado { get; set; }

        [DisplayName("Número Documento")]
        public string NumeroDocumento { get; set; }

        [DisplayName("Data Emissão")]
        public DateTime DataEmissao { get; set; }

        [DisplayName("Data Vencimento")]
        public DateTime DataVencimento { get; set; }
        public string Status { get; set; }

        [DisplayName("Valor R$")]
        public decimal ValorTitulo { get; set; }
    }
}
