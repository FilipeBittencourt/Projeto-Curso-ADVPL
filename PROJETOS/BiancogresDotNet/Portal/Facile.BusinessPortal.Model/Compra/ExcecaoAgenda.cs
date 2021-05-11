using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model
{
    public class ExcecaoAgenda : Base
    {
        public string Descricao { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}", ApplyFormatInEditMode = true)]

        public DateTime Data { get; set; }

        public decimal HoraDisponivel { get; set; }

        public string Status()
        {
            return Habilitado ? "Ativo" : "Inativo";
        }
    }
}
