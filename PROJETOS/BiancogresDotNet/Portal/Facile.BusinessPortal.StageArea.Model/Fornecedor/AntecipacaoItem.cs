using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.BusinessPortal.StageArea.Model
{
    public class AntecipacaoItem : Padrao
    {
        public long AntecipacaoID { get; set; }
        public long TituloPagarID { get; set; }
        public decimal ValorTitulo { get; set; }
        public decimal ValorTituloAntecipado { get; set; }
        public string NumeroDocumento { get; set; }
        public string Serie { get; set; }
        public string Parcela { get; set; }
        public string NumeroControleParticipante { get; set; }
    }
}
