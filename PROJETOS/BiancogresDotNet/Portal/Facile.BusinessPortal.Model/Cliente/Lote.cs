using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    /// <summary>
    /// Classe para agrupamento de titulos transmitidos em Lotes para geracao de Borderos / Arquivos de Remessa consolidados
    /// </summary>
    public class Lote : Base
    {
        [Required]
        public string Numero { get; set; }
        public string NomeArquivo { get; set; }
        public bool GerarArquivoRemessa { get; set; }
        public bool ProcessaRetornoAutomatico { get; set; }
        public bool Parcial { get; set; }
        public TipoArquivo TipoArquivo { get; set; }
        public TipoOperacao Operacao { get; set; }
        public virtual ICollection<Boleto> Boletos { get; set; }
        public int NumeroSequencialRemessa { get; set; }

        [NotMapped]
        public bool Reprocessamento { get; set; }
    }
}
