using Facile.BusinessPortal.Api.Services;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Library.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Facile.BusinessPortal.Api.Security
{
    [Authorize]
    [Route("[controller]")]
    [ApiController]
    public class AccessController : ControllerBase
    {
        private IUserService _userService;

        public AccessController(IUserService userService)
        {
            _userService = userService;
        }

        [AllowAnonymous]
        [HttpPost("authenticate")]
        public IActionResult Authenticate([FromBody]ClientAuth auth)
        {
            var accessReturn = _userService.Authenticate(auth);


            if (accessReturn == null || !accessReturn.Ok)
            {
                //Log de controle de requisicoes
                //LogControl.UpdateLogAction(HttpContext, 0, 0, ControllerContext.ActionDescriptor.ControllerName, ControllerContext.ActionDescriptor.ActionName, "Autenticação falha");
                return BadRequest(accessReturn);
            }
            else
            {   //Log de controle de requisicoes
                //LogControl.UpdateLogAction(HttpContext, 0, 0, ControllerContext.ActionDescriptor.ControllerName, ControllerContext.ActionDescriptor.ActionName, "Autenticação ok");
                return Ok(accessReturn);
            }           
        }

        [AllowAnonymous]
        [HttpGet("HelloFacileApi")]
        public string HelloFacileApi()
        {
            return "Hello Facile Api";
        }

    }
}