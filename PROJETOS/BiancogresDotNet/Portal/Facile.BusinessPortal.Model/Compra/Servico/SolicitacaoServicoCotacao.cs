using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class SolicitacaoServicoCotacao : Base
    {
        public long SolicitacaoServicoID { get; set; }
        [ForeignKey("SolicitacaoServicoID")]
        public virtual SolicitacaoServico SolicitacaoServico { get; set; }

        public long FornecedorID { get; set; }
        [ForeignKey("FornecedorID")]
        public virtual Fornecedor Fornecedor { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}", ApplyFormatInEditMode = true)]
        public DateTime DataValidade { get; set; }

        public string NumeroOrcamento { get; set; }

        public string TipoFrete { get; set; }

        public string CondicaoPagamento { get; set; }

        public string Revisao { get; set; }

        public int Origem { get; set; } //1=Portal;2=Protheus


        public string AtendeCotacao { get; set; }

        public string NomeAnexo { get; set; }
        public string TipoAnexo { get; set; }
        public string DescricaoAnexo { get; set; }
        public byte[] ArquivoAnexo { get; set; }

        public virtual ICollection<SolicitacaoServicoCotacaoItem> SolicitacaoServicoCotacaoItem { get; set; }

    }
}
