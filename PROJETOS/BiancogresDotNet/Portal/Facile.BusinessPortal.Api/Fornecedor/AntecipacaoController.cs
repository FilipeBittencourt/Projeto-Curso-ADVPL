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
using Facile.BusinessPortal.BusinessRules.DAO.Fornecedor;
using Facile.BusinessPortal.Library.Structs.Post;

namespace Facile.BusinessPortal.Api.Fornecedor
{
    [Route("[controller]")]
    public class AntecipacaoController : BaseApiController<Antecipacao>
    {
        private readonly string _siteBaseURL;

        public AntecipacaoController(FBContext db, IHttpContextAccessor contextAccessor, IOptions<AppSettings> appSettings) : base(db, contextAccessor)
        {
            _siteBaseURL = appSettings.Value.SiteBaseURL;
        }

        [HttpGet("GetAntecipacao")]
        public async Task<List<AntecipacaoGet>> GetAntecipacao()
        {
            ContextParams Params = new ContextParams(HttpContext, db, _userId);
            var ret = await AntecipacaoDAO.GetAsync(Params, _siteBaseURL);
            return ret;
        }

        [HttpPost("UpdateStatusIntegracaoAsync")]
        public async Task<List<SaveDataReturn>> UpdateStatusIntegracao([FromBody]List<Library.Structs.Post.AntecipacaoPost> ListPost)
        {
            if (ListPost != null)
            {
                ContextParams Params = new ContextParams(HttpContext, db, _userId);
                var ret = await AntecipacaoDAO.UpdateStatusIntegracaoAsync(Params, _siteBaseURL, ListPost);
                return ret;
            }
            string Msg = "Objeto invalido";
            var l = new List<SaveDataReturn>
            {
                SaveDataReturn.ReturnError("", Msg)
            };
            return l;   
        }
    }
}
