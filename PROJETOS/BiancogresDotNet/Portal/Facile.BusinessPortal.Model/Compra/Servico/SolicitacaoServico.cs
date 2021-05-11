using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class SolicitacaoServico : Base
    {

        public string Numero { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}", ApplyFormatInEditMode = true)]

        public DateTime DataEmissao { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}", ApplyFormatInEditMode = true)]
        public DateTime DataNecessidade { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}", ApplyFormatInEditMode = true)]
        public DateTime? DataHoraVisita { get; set; }


        public long ClasseValorID { get; set; }
        [ForeignKey("ClasseValorID")]
        public virtual ClasseValor ClasseValor { get; set; }

        public long PrioridadeServicoID { get; set; }
        [ForeignKey("PrioridadeServicoID")]
        public virtual PrioridadeServico PrioridadeServico { get; set; }

        public long? ContratoID { get; set; }
        [ForeignKey("ContratoID")]
        public virtual Contrato Contrato { get; set; }

        public TipoVisita TipoVisita { get; set; }
        public TipoServico TipoServico { get; set; }

        public StatusSolicitacaoServico Status { get; set; }

        public string Observacao { get; set; }

        public string Descricao { get; set; }

        public string NomeAnexo { get; set; }
        public string TipoAnexo { get; set; }
        public string DescricaoAnexo { get; set; }
        public byte[] ArquivoAnexo { get; set; }

        public virtual ICollection<SolicitacaoServicoFornecedor> SolicitacaoServicoFornecedor { get; set; }
        public virtual ICollection<SolicitacaoServicoItem> SolicitacaoServicoItem { get; set; }


        public long? ItemContaID { get; set; }
        [ForeignKey("ItemContaID")]
        public virtual ItemConta ItemConta { get; set; }


        public long? SubItemContaID { get; set; }
        [ForeignKey("SubItemContaID")]
        public virtual SubItemConta SubItemConta { get; set; }

        public long? SetorAprovacaoID { get; set; }
        [ForeignKey("SetorAprovacaoID")]
        public virtual SetorAprovacao SetorAprovacao { get; set; }

        public long UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

        public long? UsuarioMedicaoID { get; set; }
        [ForeignKey("UsuarioMedicaoID")]
        public virtual Usuario UsuarioMedicao { get; set; }

        public long? UsuarioOrigemID { get; set; }
        [ForeignKey("UsuarioOrigemID")]
        public virtual Usuario UsuarioOrigem { get; set; }

        public virtual ICollection<SolicitacaoServicoMedicaoUnica> SolicitacaoServicoMedicaoUnica { get; set; }
    }

}
