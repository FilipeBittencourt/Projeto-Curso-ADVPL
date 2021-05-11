using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.Financeiro.BoletoNetCore
{
    public class Pagamento
    {
        public string CodigoOcorrencia { get; set; }
        public string DescricaoOcorrencia { get; set; }
        public string CodigoCameraCentralizadora { get; set; }
        public string OcorrenciasRetorno { get; set; }
        

        //Banco/Agencia/Conta do Favorecido/Cedente
        public string CodigoBancoFavorecido { get; set; }
        public string AgenciaFavorecido { get; set; }
        public string DigitoAgenciaFavorecido { get; set; }
        public string ContaFavorecido { get; set; }
        public string DigitoContaFavorecido { get; set; }
        public string SegundoDigitoContaFavorecido { get; set; }

        //Dados Favorecido/Cedente
        public string CPFCNPJFavorecido { get; set; }
        public string NomeFavorecido { get; set; }

        //Dados do Pagamento
        public string NumeroDocumento { get; set; }
        public string CodigoBarras { get; set; }
        public string NumeroDocumentoBanco { get; set; }
       
        //Data Vencimento do Título
        public DateTime DataEmissao { get; set; }
        public DateTime DataVencimento { get; set; }
        public DateTime DataPagamento { get; set; }
        public DateTime DataEfetivacao { get; set; }
        public DateTime DataAgendamento { get; set; }

        //Valores do Título/Movimento
        public decimal ValorTitulo { get; set; }
        public decimal ValorDesconto { get; set; }
        public decimal ValorMulta { get; set; }
        public decimal ValorAtualizacaoMonetaria { get; set; }
        public decimal ValorJuros { get; set; }
        public decimal ValorTotal { get; set; }
        public decimal ValorPago { get; set; }
        public decimal PercentualJurosDia { get; set; }
        
        public string OutrasInformacoes { get; set; }

        //Carteira
        public string Carteira { get; set; }
        public TipoEspecieDocumento EspecieDocumento { get; set; } = TipoEspecieDocumento.NaoDefinido;

        //Comprovante de Pagamento
        public string AutenticacaoBancaria { get; set; }
        public string AutorizacaoDebito { get; set; }
        public string NumeroAgendamentoRemessa { get; set; }

        //GNRE
        public string CodigoUF { get; set; }
        public string IdentificadorGuia { get; set; }
        public string CodigoReceita { get; set; }
        public string PeriodoReferencia { get; set; }

        //Extrato Bancario
        public string Natureza { get; set; }
        public string TipoComplemento { get; set; }
        public string Complemento { get; set; }
        public DateTime DataContabil { get; set; }
        public DateTime DataLancamento { get; set; }
        public string TipoLancamento { get; set; }
        public string Categoria { get; set; }
        public string CodigoHistorico { get; set; }
        public string DescricaoHistorico { get; set; }

        public string RegistroArquivoRetorno { get; set; } = string.Empty;
    }
}
