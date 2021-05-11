using System;

namespace Facile.BusinessPortal.Library.Structs.Post
{
    public class NotaFiscalCompra : StructIntegracao
    {
        public string FornecedorCPFCNPJ { get; set; }
        public string FornecedorLoja { get; set; }
        public string FornecedorCodigoERP { get; set; }

        public string TransportadoraCPFCNPJ { get; set; }

        public string Numero { get; set; }
        public string Serie { get; set; }

        public DateTime DataEmissao { get; set; }

        public string ProdutoItem { get; set; }

        public string ProdutoNome { get; set; }
        public string ProdutoCodigo { get; set; }

        public string ProdutoUnidade { get; set; }

        public decimal Quantidade { get; set; }
        public decimal Valor { get; set; }

        public string NumeroControleParticipante { get; set; }
        public bool Deletado { get; set; }

        public string PedidoNumero { get; set; }
        public string PedidoItem { get; set; }

        public string ChaveNFE { get; set; }
        
    }
}
