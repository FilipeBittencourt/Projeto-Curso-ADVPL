using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Facile.BusinessPortal.StageArea.Model
{
    public class Atendimento : Padrao
    {
        public string Numero { get; set; }
        public string FornecedorCPFCNPJ { get; set; }
        public string NumeroContrato { get; set; }
        public string Item { get; set; }
        public string CodigoProduto { get; set; }
        public string NomeProduto { get; set; }
        public decimal QuantidadeProduto { get; set; }

        public decimal ValorProduto { get; set; }

        public string Contato { get; set; }
        public string Email { get; set; }
        public string Observacao { get; set; }

        [DataType(DataType.Date)]
        public DateTime? DataLiberacao { get; set; }

        public string NumeroControleParticipante { get; set; }

        public bool Deletado { get; set; }

        public bool Status { get; set; }

        public string NomeReclamante { get; set; }
        public string CepReclamante { get; set; }
        public string EnderecoReclamante { get; set; }
        public string EstadoReclamante { get; set; }
        public string BairroReclamante { get; set; }
        public string CidadeReclamante { get; set; }
        public string TelefoneReclamante { get; set; }
        public string ContatoReclamante { get; set; }
        public string HorarioContatoReclamante { get; set; }

        public byte[] Termo { get; set; }
    }
}
