using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Authorization;
using Facile.BusinessPortal.Model;
using Microsoft.AspNetCore.Identity;

namespace Facile.BusinessPortal.Api
{
    [Authorize]
    public class BaseApiController<T> : ApiController<T> where T : Base
    {
        //private readonly UserManager<ApplicationUser> _userManager;

        public BaseApiController(FBContext db, IHttpContextAccessor contextAccessor) : base(db, contextAccessor)
        {
            //_userManager = userManager;
        } 
    }
}
