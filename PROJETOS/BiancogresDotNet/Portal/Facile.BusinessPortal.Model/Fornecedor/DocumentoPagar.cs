using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model
{
    public class DocumentoPagar : Base
    {
        [Required]
        public Guid OID { get; set; }

        public long FornecedorID { get; set; }
        [ForeignKey("FornecedorID")]
        public virtual Fornecedor Fornecedor { get; set; }

        [Required]
        public string NumeroDocumento { get; set; }

        public string Serie { get; set; }

        [Required]
        [DataType(DataType.Date)]
        [Column(TypeName = "Date")]
        public DateTime DataEmissao { get; set; }
    }
}
