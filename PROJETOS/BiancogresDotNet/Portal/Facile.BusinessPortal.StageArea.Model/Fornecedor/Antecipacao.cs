using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.BusinessPortal.StageArea.Model
{
    public class Antecipacao : Padrao
    {
        public string FornecedorCPFCNPJ { get; set; }
        public DateTime DataEmissao { get; set; }

        public DateTime DataRecebimento { get; set; }

        public string Observacao { get; set; }

        public string Contato { get; set; }

        public decimal Taxa { get; set; }

        public OrigemAntecipacao Origem { get; set; }
        public StatusAntecipacao Status { get; set; }

        public TipoAntecipacao Tipo { get; set; }

    }
}
