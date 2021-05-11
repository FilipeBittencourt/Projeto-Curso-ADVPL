using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace Facile.BusinessPortal.Model
{
    public class PerfilEmpresa : Base
    {
        public string URLAcesso { get; set; }
        public string Descricao_Reduzida_Portal { get; set; }

        /// <summary>
        /// Dados para contato
        /// </summary>
        public string TelefoneContato { get; set; }
        public string EmailContato { get; set; }


        /// <summary>
        /// Definir o Thema de cores e layout que será aplicado ao acesso da Empresa
        /// </summary>
        public long? ThemeID { get; set; }
        [ForeignKey("ThemeID")]
        public virtual Theme Theme { get; set; }
        
        public string Site_Root_Path { get; set; }

        public string Path_Imagem_Background { get; set; }

        public string MensagemBoasVindas { get; set; }


        /// <summary>
        /// Propriedade para configurar o perfil de envio de e-mail para usuários e demais
        /// </summary>
        public bool UseCustomMailServer { get; set; }     
    }
}
