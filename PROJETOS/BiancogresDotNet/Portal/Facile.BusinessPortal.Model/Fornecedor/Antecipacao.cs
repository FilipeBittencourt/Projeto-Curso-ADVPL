using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Enums;

namespace Facile.BusinessPortal.Model
{
    public class Antecipacao : Base
    {
        public long FornecedorID { get; set; }
        [ForeignKey("FornecedorID")]
        public virtual Fornecedor Fornecedor { get; set; }

        public DateTime DataEmissao { get; set; }

        public DateTime DataRecebimento { get; set; }

        public string Observacao { get; set; }

        public string Contato { get; set; }

        public decimal Taxa { get; set; }

        public OrigemAntecipacao Origem { get; set; }
        public StatusAntecipacao Status { get; set; }

        public virtual List<AntecipacaoItem> AntecipacaoItem { get; set; }
        public virtual List<AntecipacaoHistorico> AntecipacaoHistorico { get; set; }

        public TipoAntecipacao? Tipo { get; set; }
    }
}
