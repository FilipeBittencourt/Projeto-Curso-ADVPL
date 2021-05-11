using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.BusinessPortal.Library
{
    public enum StatusSolicitacaoServico
    {
        Aguardando = 0,
        LiberadoIntegracao = 1,
        IntegradoBizagi = 2,
        AprovadoBizagi = 3,
        ReprovadoBizagi = 4,
        LiberadoFornecedor = 5,
        Concluido = 6,
    }
}
