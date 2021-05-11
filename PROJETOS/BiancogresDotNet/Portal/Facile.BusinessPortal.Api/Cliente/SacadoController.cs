using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.BusinessRules.DAO;
using System.Collections.Generic;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Options;
using Facile.BusinessPortal.Api.Services;
using Facile.BusinessPortal.Library.Structs.Return;

namespace Facile.BusinessPortal.Api.Cliente
{
    [Route("[controller]")]
    public class SacadoController : BaseApiController<Sacado>
    {
        private readonly string _siteBaseURL;

        public SacadoController(FBContext db, IHttpContextAccessor contextAccessor, IOptions<AppSettings> appSettings) : base(db, contextAccessor)
        {
            _siteBaseURL = appSettings.Value.SiteBaseURL;
        }

        //POST Sacado
        [HttpPost("SetSacado")]
        public async Task<List<SaveDataReturn>> SetSacado([FromBody]List<Library.Structs.Post.Sacado> sacadoListPost)
        {
            if (sacadoListPost != null)
            {
                ContextParams Params = new ContextParams(HttpContext, db, _userId);
                var ret = await SacadoDAO.CreateOrUpdateAsync(Params, _siteBaseURL, sacadoListPost);
                return ret;
            }
            string Msg = "Objeto invalido";
            var l = new List<SaveDataReturn>
            {
                SaveDataReturn.ReturnError("", Msg)
            };
            return l;
        }

        //POST Sacado
        [HttpGet("Hello")]
        [AllowAnonymous]
        public string Hello([FromBody]List<Library.Structs.Post.Sacado> sacadoListPost)
        {           
            return "TESTE";
        }

        ////DELETE
        //[HttpDelete("{id}")]
        //public void Delete(int id)
        //{
        //}
    }
}
