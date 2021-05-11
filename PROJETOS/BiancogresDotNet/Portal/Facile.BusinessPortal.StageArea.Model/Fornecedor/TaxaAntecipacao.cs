using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.BusinessPortal.StageArea.Model
{
    public class TaxaAntecipacao : Padrao
    {
        public string FornecedorCPFCNPJ { get; set; }
        public string CodigoERP { get; set; }

        public decimal Taxa { get; set; }

    }
}
