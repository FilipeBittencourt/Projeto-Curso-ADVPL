using System;
using System.Collections.Generic;

namespace Facile.BusinessPortal.ViewModels
{
    [Serializable]
    public class AllMenusUsuarioViewModel
    {
        public List<GrupoMenuUsuarioViewModel> Grupos { get; set; }

        public AllMenusUsuarioViewModel()
        {
            Grupos = new List<GrupoMenuUsuarioViewModel>();
        }
    }

    [Serializable]
    public class GrupoMenuUsuarioViewModel
    {
        public string Nome { get; set; }
        public string ClasseIcone { get; set; }
        public string URL { get; set; }
        public string Area { get; set; }

        public List<MenuUsuarioViewModel> Menus { get; set; }

        public GrupoMenuUsuarioViewModel()
        {
            Menus = new List<MenuUsuarioViewModel>();
        }
    }

    [Serializable]
    public class MenuUsuarioViewModel
    {
        public string ControllerName { get; set; }
        public string ActionName { get; set; }
        public string Nome { get; set; }
        public string Descricao { get; set; }
        public long ObjectId { get; set; }
    }
}

