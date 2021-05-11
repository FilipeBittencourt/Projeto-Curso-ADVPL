using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class SolicitacaoServicoMedicao : Base
    {
        public long SolicitacaoServicoID { get; set; }
        [ForeignKey("SolicitacaoServicoID")]
        public virtual SolicitacaoServico SolicitacaoServico { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}", ApplyFormatInEditMode = true)]
        public DateTime Data { get; set; }

        public StatusSolicitacaoServicoMedicao Status { get; set; }

        public long? UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

       public string ObservacaoNotaFiscal { get; set; }

        public string NomeAnexoNotaFiscal { get; set; }
        public string TipoAnexoNotaFiscal { get; set; }
        public byte[] ArquivoAnexoNotaFiscal { get; set; }

        public virtual ICollection<SolicitacaoServicoMedicaoItem> SolicitacaoServicoMedicaoItem { get; set; }

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
    }
}
