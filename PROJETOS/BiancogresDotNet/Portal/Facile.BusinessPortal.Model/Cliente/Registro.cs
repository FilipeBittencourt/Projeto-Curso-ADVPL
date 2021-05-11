using System;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class Registro : Base
    {
        //identificar arquivo
        protected long ArquivoID { get; set; }
        [ForeignKey("ArquivoID")]
        public virtual Arquivo Arquivo { get; set; }

        //identificador do registro
        public Guid? TituloOID { get; set; }
        public string TipoRegistro { get; set; }
        public string Segmento { get; set; }

        //Identificar Sacado/Cedente/Favorecido
        public string Pessoa_CPFCNPJ { get; set; }
        public string Pessoa_Nome { get; set; }

        public string Pessoa_CodigoBanco { get; set; }
        public string Pessoa_Agencia { get; set; }
        public string Pessoa_DigitoAgencia { get; set; }
        public string Pessoa_Conta { get; set; }
        public string Pessoa_DigitoConta { get; set; }
        public string Pessoa_SegundoDigitoConta{ get; set; }

        //Campos identificados do boleto/documento
        public string NumeroControleParticipante { get; set; }
        public string CodigoBarras { get; set; }
        public TipoEspecieDocumento Especie { get; set; }
        public DateTime? DataEmissao { get; set; }
        public DateTime? DataVencimento { get; set; }
        public decimal? ValorTitulo { get; set; }

        //Propriedade para Ocorrencias
        public string CodigoOcorrencia { get; set; }
        public string DescricaoOcorrencia { get; set; }
        public string CodigoOcorrenciaAuxiliar { get; set; }
        public string CodigoCamaraCentralizadora { get; set; }
        public string OcorrenciasRetorno { get; set; }

        //propriedades exclusivas do retorno a receber
        public string NossoNumero { get; set; }
        public string NumeroDocumento { get; set; }

        public decimal? ValorTarifas { get; set; }
        public decimal? ValorOutrasDespesas { get; set; }
        public decimal? ValorIOF { get; set; }
        public decimal? ValorAbatimento { get; set; }
        public decimal? ValorDesconto { get; set; }
        public decimal? ValorPago { get; set; }
        public decimal? ValorJurosDia { get; set; }
        public decimal? ValorOutrosCreditos { get; set; }
        public decimal? ValorMulta { get; set; }
        public decimal? ValorAtualizacaoMonetaria { get; set; }
        public decimal? ValorJuros { get; set; }
        public decimal? ValorTotal { get; set; }
        public DateTime? DataProcessamento { get; set; }
        public DateTime? DataCredito { get; set; }
        
        //GNRE
        public string CodigoUF { get; set; }
        public string IdentificadorGuia { get; set; }
        public string CodigoReceita { get; set; }
        public string PeriodoReferencia { get; set; }

        public string AutorizacaoDebito { get; set; }
        public string NumeroAgendamentoRemessa { get; set; }
        public DateTime? DataAgendamento { get; set; }

        //Campos para comprovante
        public string AutenticacaoBancaria { get; set; }

        //Campos Extrato Bancario
        public string Natureza { get; set; }
        public string TipoComplemento { get; set; }
        public string Complemento { get; set; }
        public DateTime? DataContabil { get; set; }
        public DateTime? DataLancamento { get; set; }
        public string TipoLancamento { get; set; }
        public string Categoria { get; set; }
        public string CodigoHistorico { get; set; }
        public string DescricaoHistorico { get; set; }

        //Registro completo lido do arquivo
        public string RegistroArquivoRetorno { get; set; }
    }
}
