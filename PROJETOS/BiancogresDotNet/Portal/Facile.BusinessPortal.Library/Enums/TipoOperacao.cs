using System.ComponentModel;

namespace Facile.BusinessPortal.Library
{
    public enum TipoOperacao
    {
        [Description("Recebimento")]
        Recebimento = 1,

        [Description("Pagamento")]
        Pagamento = 2,

        [Description("Conciliacao")]
        Conciliacao = 3
    }
}