using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.StageArea.Model
{
    public class ProcessoEmpresa: Padrao
    {
        public ProcessoIntegracao ProcessoIntegracao { get; set; }

        public long EmpresaInterfaceID { get; set; }
        [ForeignKey("EmpresaInterfaceID")]
        public virtual EmpresaInterface EmpresaInterface { get; set; }

        public bool Habilitado { get; set; }

        public long? Interval { get; set; }
    }
}
