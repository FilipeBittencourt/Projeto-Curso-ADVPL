using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Facile.BusinessPortal.Model;

namespace Facile.BusinessPortal.Api
{
    [Authorize]
    public class ApiController<T> : Controller where T : Padrao
    {
        protected readonly FBContext db;
        protected readonly IHttpContextAccessor _contextAccessor;
        protected readonly string _userId;
        protected readonly long _empresaId;

        public ApiController(FBContext dbcontext, IHttpContextAccessor contextAccessor)
        {
            db = dbcontext;
            _contextAccessor = contextAccessor;

            //Buscando UserId da conexão
            var claimsIdentity = contextAccessor.HttpContext.User.Identity as ClaimsIdentity;
            _userId = claimsIdentity.FindFirst(ClaimTypes.Name)?.Value;

            _empresaId = 0;
        }
    }
}
