using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class SolicitacaoServicoFornecedorItem : Base
    {
        public long SolicitacaoServicoFornecedorID { get; set; }
        [ForeignKey("SolicitacaoServicoFornecedorID")]
        public virtual SolicitacaoServicoFornecedor SolicitacaoServicoFornecedor { get; set; }

        public long SolicitacaoServicoItemID { get; set; }
        [ForeignKey("SolicitacaoServicoItemID")]
        public virtual SolicitacaoServicoItem SolicitacaoServicoItem { get; set; }
    }
}
