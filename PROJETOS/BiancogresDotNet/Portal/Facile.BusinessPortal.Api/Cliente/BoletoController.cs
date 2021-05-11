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
using System;

namespace Facile.BusinessPortal.Api.Cliente
{
    [Route("[controller]")]
    public class BoletoController : BaseApiController<Boleto>
    {
        private readonly string _siteBaseURL;

        public BoletoController(FBContext db, IHttpContextAccessor contextAccessor, IOptions<AppSettings> appSettings) : base(db, contextAccessor)
        {
            _siteBaseURL = appSettings.Value.SiteBaseURL;
        }

        //POST
        [HttpPost("SetBoleto")]
        public async Task<List<SaveDataReturn>> SetBoleto([FromBody]List<Library.Structs.Post.Boleto> postList)
        {
            try
            {
                ContextParams Params = new ContextParams(HttpContext, db, _userId);
                var ret = await BoletoDAO.CreateOrUpdateAsync(Params, _siteBaseURL, postList);
                return ret;
            }
            catch (Exception ex)
            {
                var ret = new List<SaveDataReturn>();
                ret.Add(new SaveDataReturn() { Ok = false, Message = "EXCEPTION: " + ex.Message });
                return ret;
            }
        }

        //GET
        [HttpGet("Hello")]
        [AllowAnonymous]
        public string Hello()
        {
            return "Hello Boleto API";
        }

        ////DELETE
        //[HttpDelete("{id}")]
        //public void Delete(int id)
        //{
        //}
    }
}
