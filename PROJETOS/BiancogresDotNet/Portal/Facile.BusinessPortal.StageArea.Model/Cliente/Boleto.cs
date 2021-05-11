using Facile.BusinessPortal.Library;
using System;

namespace Facile.BusinessPortal.StageArea.Model
{
    public class Boleto: Padrao
    {
        //Campos chave para relacionamento com outras entidades no Portal
        public string CodigoBanco { get; set; }
        public string Cedente_CPFCNPJ { get; set; }
        public string Cedente_Codigo { get; set; }
        public string Sacado_CPFCNPJ { get; set; }
        //

        public DateTime DataEmissao { get; set; }
        public DateTime DataVencimento { get; set; }
        public DateTime? DataProcessamento { get; set; }
        public DateTime? DataRecebimento { get; set; }
        public decimal ValorTitulo { get; set; }
        public decimal? ValorOutrosAcrescimos { get; set; }
        public string NumeroDocumento { get; set; }
        public TipoEspecieDocumento? EspecieDocumento { get; set; }
        public string MensagemArquivoRemessa { get; set; }
        public string MensagemLivreLinha1 { get; set; }
        public string MensagemLivreLinha2 { get; set; }
        public string MensagemLivreLinha3 { get; set; }
        public string NumeroControleParticipante { get; set; }
        public string NossoNumero { get; set; }
        public int? CodigoMoeda { get; set; }
        public string EspecieMoeda { get; set; }
        public string ValorMoeda { get; set; }
        public TipoCarteira? TipoCarteira { get; set; }
        public string Carteira { get; set; }
        public string VariacaoCarteira { get; set; }
        public string Aceite { get; set; }
        public string CodigoInstrucao1 { get; set; }
        public string CodigoInstrucao2 { get; set; }
        public DateTime? DataDesconto { get; set; }
        public decimal? ValorDesconto { get; set; }
        public DateTime? DataMulta { get; set; }
        public decimal? PercentualMulta { get; set; }
        public decimal? ValorMulta { get; set; }
        public DateTime? DataJuros { get; set; }
        public decimal? PercentualJurosDia { get; set; }
        public decimal? ValorJurosDia { get; set; }
        public TipoCodigoProtesto? CodigoProtesto { get; set; }
        public int? DiasProtesto { get; set; }
        public string EnviarEmailSacado { get; set; }
        public string EnviarEmailCedente { get; set; }
        public string NumeroLote { get; set; }
        public string Reimpressao { get; set; }
        public bool Deletado { get; set; }
    }
}
