using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class SolicitacaoServicoMedicaoItem : Base
    {
        public long? SolicitacaoServicoMedicaoID { get; set; }
        [ForeignKey("SolicitacaoServicoMedicaoID")]
        public virtual SolicitacaoServicoMedicao SolicitacaoServicoMedicao { get; set; }


        public long SolicitacaoServicoItemID { get; set; }
        [ForeignKey("SolicitacaoServicoItemID")]
        public virtual SolicitacaoServicoItem SolicitacaoServicoItem { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}", ApplyFormatInEditMode = true)]
        public DateTime Data { get; set; }
        public string UnidadeMedicao { get; set; }

        public decimal Quantidade { get; set; }

        public decimal SaldoMedicao { get; set; }

        public decimal ValorServico { get; set; }

        public decimal Medicao { get; set; }
        public decimal Valor { get; set; }

        public StatusSolicitacaoServicoMedicao Status { get; set; }


        public string StatusDescricao()
        {
            if (this.Status == StatusSolicitacaoServicoMedicao.Aguardando)
            {
                return "Aguardando";
            }
            else if (this.Status == StatusSolicitacaoServicoMedicao.Concluido)
            {
                return "Concluido";
            }
            else if (this.Status == StatusSolicitacaoServicoMedicao.AguardandoNotaFiscal)
            {
                return "Aguardando Nota Fiscal";
            }
            else if (this.Status == StatusSolicitacaoServicoMedicao.NotaFiscalAdicionada)
            {
                return "Nota Fiscal Adicionada";
            }
            else if (this.Status == StatusSolicitacaoServicoMedicao.Aprovada)
            {
                return "Aprovada";
            }

            return "";
        }

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

            /*if (this.UnidadeMedicao.Equals("1"))
            {
                return "Percentual";
            }
            else if (this.UnidadeMedicao.Equals("2"))
            {
                return "Unidade Referência";
            }

            return "";*/
        }

        [DataType(DataType.Date)]
        public DateTime? DataMedicao { get; set; }

        public long? UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

        public string ObservacaoMedicao { get; set; }


        public string Observacao { get; set; }

        public string NomeAnexo { get; set; }
        public string TipoAnexo { get; set; }
   
        public byte[] ArquivoAnexo { get; set; }


        public string ObservacaoNotaFiscal { get; set; }

        public string NomeAnexoNotaFiscal { get; set; }
        public string TipoAnexoNotaFiscal { get; set; }
        public byte[] ArquivoAnexoNotaFiscal { get; set; }


        public string NumeroAE { get; set; }
        public string ItemAE { get; set; }

    }
}
