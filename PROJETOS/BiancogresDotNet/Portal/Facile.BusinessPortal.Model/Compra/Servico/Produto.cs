using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model.Compra.Servico
{
    public class Produto : Base
    {
        public string Codigo { get; set; }
        public string Descricao { get; set; }

        public string UnidadeMedida { get; set; }


        public string ClassificacaoFiscal { get; set; }


    }
}
