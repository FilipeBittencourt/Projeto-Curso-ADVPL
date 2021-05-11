using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Facile.BusinessPortal.Model;
using System.Threading.Tasks;
using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Library.Util;
using Microsoft.EntityFrameworkCore;
using System;
using Facile.BusinessPortal.Library;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("Compra")]
    public class LocalEntregaController : BaseCommonController<Model.LocalEntrega>
    {
        public LocalEntregaController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        protected override void LoadViewBag()
        {
            
        }

        protected override void LoadViewBag(LocalEntrega o)
        {
           
        }


    }
}
