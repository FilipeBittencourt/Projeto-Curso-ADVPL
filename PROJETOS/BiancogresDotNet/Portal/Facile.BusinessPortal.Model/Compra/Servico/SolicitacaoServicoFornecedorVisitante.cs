using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class SolicitacaoServicoFornecedorVisitante : Base
    {
        public long SolicitacaoServicoFornecedorID { get; set; }
        [ForeignKey("SolicitacaoServicoFornecedorID")]
        public virtual SolicitacaoServicoFornecedor SolicitacaoServicoFornecedor { get; set; }

        public string Nome { get; set; }
        public string CPF { get; set; }
    }
}
