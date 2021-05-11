using System;

namespace Facile.BusinessPortal.Library.Structs.Post
{
    public class TituloPagar : StructIntegracao
    {
        public DocumentoPagar DocumentoPagar { get; set; }
        public DocumentoPagar FaturaPagamento { get; set; }
        public string NumeroDocumento { get; set; }
        public string Parcela { get; set; }
        public DateTime DataEmissao { get; set; }
        public DateTime DataVencimento { get; set; }
        public DateTime? DataBaixa { get; set; }
        public FormaPagamento? FormaPagamento { get; set; }
        public DateTime? DataPagamento { get; set; }
        public decimal ValorTitulo { get; set; }
        public decimal Saldo { get; set; }
        public string NumeroControleParticipante { get; set; }
        public bool Deletado { get; set; }
        public int TipoDocumento { get; set; }
    }

    public class DocumentoPagar
    {
        public string Fornecedor { get; set; }
        public string NumeroDocumento { get; set; }
        public string Serie { get; set; }
        public DateTime DataEmissao { get; set; }
    }
    public enum FormaPagamento
    {
        Boleto = 1,
        DDA = 2,
        DebitoEmConta = 3,
        Fatura = 4
    }
}
