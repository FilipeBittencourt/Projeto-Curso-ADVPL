using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class SolicitacaoServicoCotacaoItem : Base
    {
        public long SolicitacaoServicoCotacaoID { get; set; }
        [ForeignKey("SolicitacaoServicoCotacaoID")]
        public virtual SolicitacaoServicoCotacao SolicitacaoServicoCotacao { get; set; }

        public long SolicitacaoServicoItemID { get; set; }
        [ForeignKey("SolicitacaoServicoItemID")]
        public virtual SolicitacaoServicoItem SolicitacaoServicoItem { get; set; }

      
        public string Observacao { get; set; }

        public string CodigoProduto { get; set; }

        public decimal Preco { get; set; }

        public decimal IPI { get; set; }
        public decimal ValorSubstituicao { get; set; }

        public int PrazoEntrega { get; set; }

        public string Moeda { get; set; }



        public string Marca { get; set; }

        public int AtendeTotalmente { get; set; }
        public int AtendeItem { get; set; }

        public string MoedaDescricao()
        {
            if (this.Moeda.Equals("1"))
            {
                return "Real";
            } else if (this.Moeda.Equals("2"))
            {
                return "Dolar";
            } else if (this.Moeda.Equals("3"))
            {
                return "Euro";
            }
            return "";
        }
    }
}
