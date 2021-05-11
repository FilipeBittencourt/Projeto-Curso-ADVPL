using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model
{
    public class BoletoEvento: Base
    {
        public long BoletoID { get; set; }

        [ForeignKey("BoletoID")]
        public virtual Boleto Boleto { get; set; }

        public TipoBoletoEvento TipoBoletoEvento { get; set; }
    }
}
