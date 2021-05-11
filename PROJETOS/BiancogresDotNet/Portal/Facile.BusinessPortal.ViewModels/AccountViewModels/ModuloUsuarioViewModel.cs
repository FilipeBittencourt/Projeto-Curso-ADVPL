using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;

namespace Facile.BusinessPortal.ViewModels
{
    [Serializable]
    public class AllModulosUsuarioViewModel
    {
        public List<ModuloUsuarioViewModel> Modulos { get; set; }

        public AllModulosUsuarioViewModel()
        {
            Modulos = new List<ModuloUsuarioViewModel>();
        }
    }


    [Serializable]
    public class ModuloUsuarioViewModel
    {
        public long Id { get; set; }
        public string Nome { get; set; }
        public string Descricao { get; set; }
        public string ClasseIcone { get; set; }
        public string URL { get; set; }
    }

    [Serializable]
    public class UsuarioGrupoViewModel
    {
        public long UsuarioID { get; set; }
        public long UsuarioGrupoID { get; set; }
        public TipoUsuario Tipo { get; set; }
    }
}

