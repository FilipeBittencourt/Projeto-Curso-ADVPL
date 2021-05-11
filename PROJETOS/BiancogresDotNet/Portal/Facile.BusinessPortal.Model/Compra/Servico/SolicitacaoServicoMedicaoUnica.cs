using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class SolicitacaoServicoMedicaoUnica : Base
    {
        public long SolicitacaoServicoID { get; set; }
        [ForeignKey("SolicitacaoServicoID")]
        public virtual SolicitacaoServico SolicitacaoServico { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}", ApplyFormatInEditMode = true)]
        public DateTime Data { get; set; }

        public StatusSolicitacaoServicoMedicaoUnica Status { get; set; }

        public string StatusDescricao()
        {
            if (this.Status == StatusSolicitacaoServicoMedicaoUnica.AguardandoNotaFiscal)
            {
                return "Aguardando Nota Fiscal";
            }
            else if (this.Status == StatusSolicitacaoServicoMedicaoUnica.NotaFiscalAdicionada)
            {
                return "Nota Fiscal Adicionada";
            }
            else if (this.Status == StatusSolicitacaoServicoMedicaoUnica.Concluido)
            {
                return "Concluido";
            }
            
            return "";
        }

        public long? UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

       public string Observacao { get; set; }

        public string NomeAnexo { get; set; }
        public string TipoAnexo { get; set; }
        public byte[] ArquivoAnexo { get; set; }

       
    }
}
