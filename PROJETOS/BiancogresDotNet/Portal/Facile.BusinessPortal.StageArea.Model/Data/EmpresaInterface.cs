using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Facile.BusinessPortal.StageArea.Model
{
    public class EmpresaInterface: Padrao
    {
        [Required]
        public string Codigo { get; set; }

        [Required]
        public string CNPJ { get; set; }

        public string CodEmpresaERP { get; set; }
        public string CodUnidadeERP { get; set; }

        [Required]
        public Guid Client_Key { get; set; }

        [Required]
        public string Secret_Key { get; set; }
    }
}
