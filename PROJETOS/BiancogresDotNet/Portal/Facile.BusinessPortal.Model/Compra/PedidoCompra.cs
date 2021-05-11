using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model
{
    public class PedidoCompra : Base
    {
        public long FornecedorID { get; set; }
        [ForeignKey("FornecedorID")]
        public virtual Fornecedor Fornecedor { get; set; }

        public long? TransportadoraID { get; set; }
        [ForeignKey("TransportadoraID")]
        public virtual Transportadora Transportadora { get; set; }

        public DateTime DataEntrega { get; set; }

        public string Numero { get; set; }
        public string Item { get; set; }

        public string NomeProduto { get; set; }
        public string CodigoProduto { get; set; }

        public string UnidadeProduto { get; set; }

        public decimal Quantidade { get; set; }
        public decimal Saldo { get; set; }
        public string NumeroControleParticipante { get; set; }

        public virtual ICollection<NotaFiscalCompra> NotaFiscais { get; set; }

        public TipoFrete TipoFrete { get; set; }
    }
}
