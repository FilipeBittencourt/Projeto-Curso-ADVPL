using Facile.BusinessPortal.Library;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class Cedente : Base
    {
        [Required]
        public string CPFCNPJ { get; set; }

        [Required]
        public string Nome { get; set; }

        /// <summary>
        /// Codigo Unico para Identificar nos POSTS para a API - Definido pela Empresa ou Gerado uma Chave Randomica
        /// </summary>
        [Required]
        public string Codigo { get; set; }

        /// <summary>
        /// Codigo do Convenio/Contrato Bancario
        /// </summary>
        public string CodigoCedenteBanco { get; set; }

      

        /// <summary>
        /// Identificado para processamento de arquivos de Retorno Bancario
        /// </summary>
        public string IdUnicoCedenteBancoRetorno { get; set; }
        
        public string Email { get; set; }

        public long ContaBancariaID { get; set; }

        [ForeignKey("ContaBancariaID")]
        public virtual ContaBancaria ContaBancaria { get; set; }
        
        public virtual ICollection<ConfiguracaoArquivo> ConfiguracoesArquivos { get; set; }

        public string NomeBasePdfBoleto { get; set; }

        public bool Homologacao { get; set; }

        public bool DownloadRetorno { get; set; }

        public string EmailHomologacao { get; set; }

        public string RegiaoCobrancaEmail { get; set; }

        public string TelCobrancaEmail { get; set; }

        public string TelCobrancaExtEmail { get; set; }

        [Required]
        public string CEP { get; set; }

        [Required]
        public string Logradouro { get; set; }

        public string Numero { get; set; }

        public string Complemento { get; set; }

        public string Bairro { get; set; }

        [Required]
        public string UF { get; set; }

        [Required]
        public string Cidade { get; set; }

       // public string Numero { get; set; }

       // public string Complemento { get; set; }

        /// <summary>
        /// Campos para controle se o Sacado recebe boleto por e-mail após o cadastro/registro na API
        /// </summary>
        public bool EnviaBoletoPDF { get; set; }

        /// <summary>
        /// Se envia o boleto Zipado
        /// </summary>
        public bool BoletoZip { get; set; }

        /// <summary>
        /// Se envia o PDF ou ZIP com senha para abertura
        /// </summary>
        public bool BoletoSenha { get; set; }

        /// <summary>
        /// Tipo de Senha
        /// </summary>
        public TipoGeracaoSenha? TipoGeracaoSenha { get; set; }
    }
}
