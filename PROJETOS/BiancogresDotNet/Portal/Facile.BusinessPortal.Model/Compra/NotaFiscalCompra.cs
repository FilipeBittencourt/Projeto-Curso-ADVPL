using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;
using Facile.BusinessPortal.Library;

namespace Facile.BusinessPortal.Model
{
    public class NotaFiscalCompra : Base
    {
        public long FornecedorID { get; set; }
        [ForeignKey("FornecedorID")]
        public virtual Fornecedor Fornecedor { get; set; }

        public long? TransportadoraID { get; set; }
        [ForeignKey("TransportadoraID")]
        public virtual Transportadora Transportadora { get; set; }

        public long? PedidoCompraID { get; set; }
        [ForeignKey("PedidoCompraID")]
        public virtual PedidoCompra PedidoCompra { get; set; }

        public string Numero { get; set; }
        public string Serie { get; set; }

        public DateTime DataEmissao { get; set; }

        public string ItemProduto { get; set; }

        public string NomeProduto { get; set; }
        public string CodigoProduto { get; set; }

        public string UnidadeProduto { get; set; }

        public decimal Quantidade { get; set; }
        public decimal Valor { get; set; }

        public string NumeroControleParticipante { get; set; }
        public string ChaveNFE { get; set; }


        public DateTime? DataRecebimento { get; set; }
        public DateTime? DataAgendamento { get; set; }

        public long? LocalEntregaID { get; set; }
        [ForeignKey("LocalEntregaID")]
        public virtual LocalEntrega LocalEntrega { get; set; }

        public long? TipoVeiculoID { get; set; }
        [ForeignKey("TipoVeiculoID")]
        public virtual TipoVeiculo TipoVeiculo { get; set; }

        public long? TipoProdutoID { get; set; }
        [ForeignKey("TipoProdutoID")]
        public virtual TipoProduto TipoProduto { get; set; }

        //public string Motorista { get; set; }
        public long? MotoristaID { get; set; }
        [ForeignKey("MotoristaID")]
        public virtual Motorista Motorista { get; set; }
        public string Placa { get; set; }

        public bool EntregaAutorizada { get; set; }

    }
}
