using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace Facile.BusinessPortal.Model
{
    public class Base : Padrao
    {
        //Todas as tabelas do sistema são relacionadas a Empresa/Unidade Proprietaria
        public long EmpresaID { get; set; }

        [ForeignKey("EmpresaID")]
        public virtual Empresa Empresa { get; set; }

        //Todas as tabelas do sistema são relacionadas a Empresa/Unidade Proprietaria
        //Se o registro for compartilhado para todas unidades, manter null na Unidade
        public long? UnidadeID { get; set; }

        [ForeignKey("UnidadeID")]
        public virtual Unidade Unidade { get; set; }

        public bool Habilitado { get; set; }

        public bool Deletado { get; set; }

        public long DeleteID { get; set; }

        public Guid? IDProcesso { get; set; }

        //ID da tabela na stage area - sicronizador
        public long? StageID { get; set; }
    }
}
