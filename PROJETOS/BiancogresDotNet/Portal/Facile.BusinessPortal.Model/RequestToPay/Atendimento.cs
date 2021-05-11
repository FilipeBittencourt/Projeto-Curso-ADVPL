using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class Atendimento: Base
    {
        public long FornecedorID { get; set; }
        [ForeignKey("FornecedorID")]
        public virtual Fornecedor Fornecedor { get; set; }

        public string Numero { get; set; }
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

        public StatusAtendimento Status { get; set; }
        [DataType(DataType.Date)]
        public DateTime? DataMedicao { get; set; }

        public long? UsuarioID { get; set; }
        [ForeignKey("UsuarioID")]
        public virtual Usuario Usuario { get; set; }

        public string ObservacaoMedicao { get; set; }

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
        public virtual ICollection<AtendimentoMedicao> AtendimentoMedicao { get; set; }
    }
}
