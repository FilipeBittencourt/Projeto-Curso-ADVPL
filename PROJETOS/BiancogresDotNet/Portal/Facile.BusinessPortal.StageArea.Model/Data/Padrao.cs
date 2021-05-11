using System;
using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.StageArea.Model
{
    //Tabela universais compartilhadas com todas as empresas - tais como o cadastro de Bancos
    public class Padrao
    {
        [Key]
        public long ID { get; set; }

        [Required]
        public string ChaveUnica { get; set; }

        public long EmpresaID { get; set; }
        public long? UnidadeID { get; set; }

        //log do registro
        public string InsertUser { get; set; }
        public DateTime? InsertDate { get; set; }
        public string LastEditUser { get; set; }
        public DateTime? LastEditDate { get; set; }

        public StatusIntegracao StatusIntegracao { get; set; }
        public DateTime? DataHoraIntegracao { get; set; }
        public string MensagemRetorno { get; set; }
    }
}
