using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Util;
using Microsoft.AspNetCore.Mvc;
using System;

namespace Facile.BusinessPortal.ViewModels
{
   
    public class ViewModelBoletoPendente
    {
        public string Nome { get; set; }
        public string Email { get; set; }
        public int Quantidade { get; set; }    
    }
}
