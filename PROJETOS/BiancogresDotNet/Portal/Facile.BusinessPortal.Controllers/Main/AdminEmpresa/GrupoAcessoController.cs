using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using System.Linq;
using System;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Globalization;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.BusinessRules.DAO;

namespace Facile.BusinessPortal.Controllers.Main.AdminEmpresa
{
    [Authorize]
    [Area("AdminEmpresa")]   
    public class GrupoAcessoController : BaseCommonController<Model.GrupoAcesso>
    {
        public GrupoAcessoController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {

        }

        public override async Task<IActionResult> Index()
        {
            return View();
        }

        public async Task<IActionResult> Editar()
        {
            return View();
        }


    }
}

    
     
