using Facile.BusinessPortal.Library;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.Model
{
    public class Fornecedor : Pessoa
    {
        public virtual TaxaAntecipacao TaxaAntecipacao { get; set; }

        public TipoAntecipacaoFornecedor TipoAntecipacao { get; set; }

        public string Contato { get; set; }
        public string Telefone { get; set; }

        public string RazaoSocial { get; set; }

        public bool AntecipaServico { get; set; }

        public bool FIDCAtivo { get; set; }

        public virtual List<FornecedorDocumento> FornecedorDocumento { get; set; }

    }
}
