using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.BusinessRules.DAO;
using System.Collections.Generic;
using Facile.BusinessPortal.Api.Services;
using Microsoft.Extensions.Options;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library.Structs.Post;

namespace Facile.BusinessPortal.Api.Trasportadora
{
    [Route("[controller]")]
    public class TransportadoraController : BaseApiController<Model.Transportadora>
    {
        private readonly string _siteBaseURL;

        public TransportadoraController(FBContext db, IHttpContextAccessor contextAccessor, IOptions<AppSettings> appSettings) : base(db, contextAccessor)
        {
            _siteBaseURL = appSettings.Value.SiteBaseURL;
        }

        [HttpPost("SetTransportadora")]
        public async Task<List<SaveDataReturn>> SetTransportadora([FromBody]List<Library.Structs.Post.Transportadora> ListPost)
        {
            /*if (ListPost != null)
            {
                ContextParams Params = new ContextParams(HttpContext, db, _userId);
                var ret = await TransportadoraDAO.CreateOrUpdateAsync(Params, _siteBaseURL, ListPost);
                return ret;
            }*/
            string Msg = "Objeto invalido";
            var l = new List<SaveDataReturn>
            {
                SaveDataReturn.ReturnError("", Msg)
            };
            return l;
        }

    }
}
