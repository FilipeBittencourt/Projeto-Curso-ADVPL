using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class SolicitacaoServicoFornecedor : Base
    {
        public long SolicitacaoServicoID { get; set; }
        [ForeignKey("SolicitacaoServicoID")]
        public virtual SolicitacaoServico SolicitacaoServico { get; set; }

        public long FornecedorID { get; set; }
        [ForeignKey("FornecedorID")]
        public virtual Fornecedor Fornecedor { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}", ApplyFormatInEditMode = true)]
        public DateTime? DataHoraVisita { get; set; }

        public bool AgendarVisita { get; set; }

        public string Observacao { get; set; }

        public bool Aprovado { get; set; }

        public bool Vencedor { get; set; }

        public string Cotacao { get; set; }
      

    }
}
