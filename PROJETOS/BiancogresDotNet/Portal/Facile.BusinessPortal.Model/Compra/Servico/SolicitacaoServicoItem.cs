using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class SolicitacaoServicoItem : Base
    {
        public SolicitacaoServicoItem():base()
        {
            SolicitacaoServicoMedicaoItem = new List<SolicitacaoServicoMedicaoItem>();
        }

        public long SolicitacaoServicoID { get; set; }
        [ForeignKey("SolicitacaoServicoID")]
        public virtual SolicitacaoServico SolicitacaoServico { get; set; }

        public long ProdutoID { get; set; }
        [ForeignKey("ProdutoID")]
        public virtual Produto Produto { get; set; }

        public string Descricao { get; set; }
        public decimal Quantidade { get; set; }

        public long AplicacaoID { get; set; }
        [ForeignKey("AplicacaoID")]
        public virtual Aplicacao Aplicacao { get; set; }

        public long DriverID { get; set; }
        [ForeignKey("DriverID")]
        public virtual Driver Driver { get; set; }

        public long? TAGID { get; set; }
        [ForeignKey("TAGID")]
        public virtual TAG TAG { get; set; }

        public long ArmazemID { get; set; }
        [ForeignKey("ArmazemID")]
        public virtual Armazem Armazem { get; set; }

        public long? ContaContabilID { get; set; }
        [ForeignKey("ContaContabilID")]
        public virtual ContaContabil ContaContabil { get; set; }

        public string UnidadeMedida { get; set; }
        public string UnidadeMedicao { get; set; }

        public string UnidadeMedidaDescricao()
        {
            if (this.UnidadeMedicao.Equals("1"))
            {
                return "Percentual";
            }
            else if (this.UnidadeMedicao.Equals("2"))
            {
                return "Hora";
            }
            else if (this.UnidadeMedicao.Equals("3"))
            {
                return "M2";
            }
            else if (this.UnidadeMedicao.Equals("4"))
            {
                return "M3";
            }
            else if (this.UnidadeMedicao.Equals("5"))
            {
                return "Quantidade";
            }

            return "";
        }

        public string UnidadeMedicaoDescricao()
        {
            /*if (this.UnidadeMedicao.Equals("1"))
            {
                return "Percentual";
            }
            else if (this.UnidadeMedicao.Equals("2"))
            {
                return "Unidade Referência";
            }
            
            return "";*/

            if (this.UnidadeMedicao.Equals("1"))
            {
                return "Percentual";
            }
            else if (this.UnidadeMedicao.Equals("2"))
            {
                return "Hora";
            }
            else if (this.UnidadeMedicao.Equals("3"))
            {
                return "M2";
            }
            else if (this.UnidadeMedicao.Equals("4"))
            {
                return "M3";
            }
            else if (this.UnidadeMedicao.Equals("5"))
            {
                return "Quantidade";
            }
            return "";
        }

        public string Cotacao { get; set; }
        public string CotacaoItem { get; set; }


        public string Contrato { get; set; }

        public string ContratoItem { get; set; }

        public string Pedido { get; set; }

        public string PedidoItem { get; set; }

        public string Item { get; set; }

        public bool Vencedor { get; set; }

        public virtual ICollection<SolicitacaoServicoMedicaoItem> SolicitacaoServicoMedicaoItem { get; set; }

        //   public virtual ICollection<SolicitacaoServicoItemCotacao> SolicitacaoServicoItemCotacao { get; set; }


        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}", ApplyFormatInEditMode = true)]

        public DateTime? DataInicioContrato { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}", ApplyFormatInEditMode = true)]

        public DateTime? DataFinalContrato { get; set; }

        public string CodigoCliente { get; set; }
    }
}
