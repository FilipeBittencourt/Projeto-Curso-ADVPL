using System;
using System.Collections.Generic;

namespace Facile.BusinessPortal.Library.Structs.Post
{
    public class TaxaFornecedorGet : StructIntegracao
    {
        public long ID { get; set; }
        public string InsertUser { get; set; }
        public DateTime? InsertDate { get; set; }
        public string LastEditUser { get; set; }
        public DateTime? LastEditDate { get; set; }

        public long EmpresaID { get; set; }
        public long? UnidadeID { get; set; }
        public bool Habilitado { get; set; }
        public bool Deletado { get; set; }
        public long DeleteID { get; set; }
        public Guid? IDProcesso { get; set; }
        public long? StageID { get; set; }

        public string FornecedorCPFCNPJ { get; set; }
        public decimal Taxa { get; set; }
        public string CodigoERP { get; set; }
    }
}
