using System.Collections.Generic;

namespace Facile.Financeiro.BoletoNetCore
{
    public class Boletos : List<Boleto>
    {
        public IBanco Banco { get; set; }
    }
}
