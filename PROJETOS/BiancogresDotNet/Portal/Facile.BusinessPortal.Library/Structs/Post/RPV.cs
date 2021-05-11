using System;
using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.Library.Structs.Post
{
    public class RPV : StructIntegracao
    {

        public string FornecedorCPFCNPJ { get; set; }
        public string NumeroContrato { get; set; }
        public string Item { get; set; }
        public string CodigoProduto { get; set; }
        public string NomeProduto { get; set; }
        public decimal QuantidadeProduto { get; set; }

        public string Contato { get; set; }
        public string Email { get; set; }
        public string Observacao { get; set; }

        [DataType(DataType.Date)]
        public DateTime DataLiberacao { get; set; }

        public string NumeroControleParticipante { get; set; }

        public bool Deletado { get; set; }

        public bool Status { get; set; }
    }
}
