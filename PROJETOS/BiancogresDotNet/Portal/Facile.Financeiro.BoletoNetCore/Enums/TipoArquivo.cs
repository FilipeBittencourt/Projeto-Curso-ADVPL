using System.ComponentModel;

namespace Facile.Financeiro.BoletoNetCore
{
    public enum TipoArquivo
    {
        [Description("CNAB 240")]
        CNAB240 = 0,

        [Description("CNAB 400")]
        CNAB400 = 1,

        [Description("BB REC390")]
        REC390 = 2
    }
}
