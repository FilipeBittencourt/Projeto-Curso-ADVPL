using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Facile.BusinessPortal.StageArea.Model
{
    public class TituloPagar : Padrao
    {
        public string FornecedorCPFCNPJ { get; set; }

        public string NumeroDocumento { get; set; }

        public string Serie { get; set; }

        public string Parcela { get; set; }

        [DataType(DataType.Date)]
        public DateTime DataEmissao { get; set; }

        [DataType(DataType.Date)]
        public DateTime DataVencimento { get; set; }

        public DateTime? DataBaixa { get; set; }

        public string FormaPagamento { get; set; }

        [DataType(DataType.Date)]
        public DateTime? DataPagamento { get; set; }

        public decimal ValorTitulo { get; set; }

        public decimal Saldo { get; set; }

        public string NumeroControleParticipante { get; set; }

        public bool Deletado { get; set; }

        public int TipoDocumento { get; set; }
    }
}
