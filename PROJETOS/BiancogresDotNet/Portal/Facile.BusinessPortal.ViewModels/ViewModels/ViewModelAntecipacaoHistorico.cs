using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Util;
using Microsoft.AspNetCore.Mvc;
using System;

namespace Facile.BusinessPortal.ViewModels
{
    public class ViewModelAntecipacaoHistorico
    {
        public string Data { get; set; }
        public string Usuario { get; set; }
        public string Observacao { get; set; }
        public string Status { get; set; }
    }
}
