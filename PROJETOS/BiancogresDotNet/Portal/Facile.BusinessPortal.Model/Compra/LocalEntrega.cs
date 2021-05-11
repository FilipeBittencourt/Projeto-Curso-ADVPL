﻿using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.BusinessPortal.Model
{
    public class LocalEntrega : Base
    {
        public string Nome { get; set; }
        public string Status()
        {
            return Habilitado ? "Ativo" : "Inativo";
        }
    }
}
