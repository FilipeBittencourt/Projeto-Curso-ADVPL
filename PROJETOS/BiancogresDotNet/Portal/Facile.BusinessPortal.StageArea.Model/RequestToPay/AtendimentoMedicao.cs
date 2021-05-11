using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Facile.BusinessPortal.StageArea.Model
{
    public class AtendimentoMedicao : Padrao
    {
        public long AtendimentoID { get; set; }
        public long AtendimentoIDPortal { get; set; }
        public long IDPortal { get; set; }

        public string Nome { get; set; }
        public string Tipo { get; set; }
        public string Descricao { get; set; }
        public byte[] Arquivo { get; set; }
    }
}
