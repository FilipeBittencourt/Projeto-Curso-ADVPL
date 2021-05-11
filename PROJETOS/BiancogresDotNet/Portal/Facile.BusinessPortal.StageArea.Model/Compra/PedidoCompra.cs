using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Facile.BusinessPortal.StageArea.Model
{
    public class PedidoCompra: Padrao
    {
        public string FornecedorCPFCNPJ { get; set; }
        public string FornecedorLoja { get; set; }
        public string FornecedorCodigoERP { get; set; }

        public string TransportadoraCPFCNPJ { get; set; }

        public DateTime? DataEntrega { get; set; }

        public string Pedido { get; set; }

        public string PedidoItem { get; set; }


        public string ProdutoNome { get; set; }
        public string ProdutoCodigo{ get; set; }
        public string ProdutoUnidade { get; set; }

        public decimal Quantidade { get; set; }
        public decimal Saldo { get; set; }
        public string NumeroControleParticipante { get; set; }

        public int TipoFrete { get; set; }

        public bool Deletado { get; set; }

    }
}
