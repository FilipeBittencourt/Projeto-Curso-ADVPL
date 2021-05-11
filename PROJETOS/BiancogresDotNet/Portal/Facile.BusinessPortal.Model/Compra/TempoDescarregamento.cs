using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model
{
    public class TempoDescarregamento : Base
    {
        public long TipoProdutoID { get; set; }
        [ForeignKey("TipoProdutoID")]
        public virtual TipoProduto TipoProduto { get; set; }

        public long TipoVeiculoID { get; set; }
        [ForeignKey("TipoVeiculoID")]
        public virtual TipoVeiculo TipoVeiculo { get; set; }

        public decimal TempoGasto { get; set; }

        public string Status()
        {
            return Habilitado ? "Ativo" : "Inativo";
        }
    }
}
