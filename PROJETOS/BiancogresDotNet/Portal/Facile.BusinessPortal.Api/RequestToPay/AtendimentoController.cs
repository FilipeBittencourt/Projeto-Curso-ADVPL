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

namespace Facile.BusinessPortal.Api.RequestToPay
{
    [Route("[controller]")]
    public class AtendimentoController : BaseApiController<Model.Atendimento>
    {
        private readonly string _siteBaseURL;

        public AtendimentoController(FBContext db, IHttpContextAccessor contextAccessor, IOptions<AppSettings> appSettings) : base(db, contextAccessor)
        {
            _siteBaseURL = appSettings.Value.SiteBaseURL;
        }

        [HttpPost("SetAtendimento")]
        public async Task<List<SaveDataReturn>> SetAtendimento([FromBody]List<Library.Structs.Post.Atendimento> ListPost)
        {
            if (ListPost != null)
            {
                ContextParams Params = new ContextParams(HttpContext, db, _userId);
                var ret = await AtendimentoDAO.CreateOrUpdateAsync(Params, _siteBaseURL, ListPost);
                return ret;
            }
            string Msg = "Objeto invalido";
            var l = new List<SaveDataReturn>
            {
                SaveDataReturn.ReturnError("", Msg)
            };
            return l;
        }

        [HttpGet("GetAtendimento")]
        public async Task<List<Library.Structs.Post.Atendimento>> GetAtendimento()
        {
            ContextParams Params = new ContextParams(HttpContext, db, _userId);
            var ret = await AtendimentoDAO.GetAsync(Params, _siteBaseURL);
            return ret;
        }

        [HttpPost("UpdateStatusIntegracaoAtendimento")]
        public async Task<List<SaveDataReturn>> UpdateStatusIntegracao([FromBody] List<Library.Structs.Post.Atendimento> ListPost)
        {
            if (ListPost != null)
            {
                ContextParams Params = new ContextParams(HttpContext, db, _userId);
                var ret = await AtendimentoDAO.UpdateStatusIntegracaoAsync(Params, _siteBaseURL, ListPost);
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
