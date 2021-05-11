using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model
{
    public class Motorista : Base
    {
       
        public string Nome { get; set; }
        public string Placa { get; set; }

        public string CPF { get; set; }
        public string CNH { get; set; }
        public string Telefone { get; set; }

    //    public string Email { get; set; }

        public DateTime DataVencimentoCNH { get; set; }

        public string Status()
        {
            return Habilitado ? "Ativo" : "Inativo";
        }
    }
}
