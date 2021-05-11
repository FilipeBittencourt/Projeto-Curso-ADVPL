using Facile.BusinessPortal.Library.Enums;
using System;
using System.Collections.Generic;

namespace Facile.BusinessPortal.Library.Structs.Post
{
    public class AntecipacaoGet : StructIntegracao
    {
        public long ID { get; set; }
        public string InsertUser { get; set; }
        public DateTime? InsertDate { get; set; }
        public string LastEditUser { get; set; }
        public DateTime? LastEditDate { get; set; }

        public long EmpresaID { get; set; }
        public long? UnidadeID { get; set; }
        public bool Habilitado { get; set; }
        public bool Deletado { get; set; }
        public long DeleteID { get; set; }
        public Guid? IDProcesso { get; set; }
        public long? StageID { get; set; }

        public string FornecedorCPFCNPJ { get; set; }
        public DateTime DataEmissao { get; set; }
        public DateTime DataRecebimento { get; set; }
        public string Observacao { get; set; }
        public string Contato { get; set; }
        public decimal Taxa { get; set; }
        public OrigemAntecipacao Origem { get; set; }
        public StatusAntecipacao Status { get; set; }

        public TipoAntecipacao Tipo { get; set; }

        public List<AntecipacaoItemGet> AntecipacaoItem { get; set; }
    }

    public class AntecipacaoItemGet
    {
        public long ID { get; set; }
        public long AntecipacaoID { get; set; }
        public long TituloPagarID { get; set; }
        public decimal ValorTitulo { get; set; }
        public decimal ValorTituloAntecipado { get; set; }
        public string NumeroDocumento { get; set; }
        public string Serie { get; set; }
        public string Parcela { get; set; }
        public string NumeroControleParticipante { get; set; }
        public long EmpresaID { get; set; }
        public long? UnidadeID { get; set; }
    }
}
