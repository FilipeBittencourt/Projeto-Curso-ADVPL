using System;
using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.Model
{
    public class Empresa: Padrao
    {      
        [MinLength(10)]
        [MaxLength(10)]
        [Required]
        public string Codigo { get; set; }

        [Required]
        public Guid Client_Key { get; set; }

        [Required]
        public string NomeEmpresa { get; set; }
        
        public string DiretorioBaseArquivo { get; set; }

        /// <summary>
        /// Marcar se a EMPRESA está em Homologação
        /// </summary>
        public bool Homologacao { get; set; }

        /// <summary>
        /// Lista de E-mails para enviar todas as mensagens enquanto em Homologação
        /// </summary>
        public string EmailHomologacao { get; set; }
    }
}
