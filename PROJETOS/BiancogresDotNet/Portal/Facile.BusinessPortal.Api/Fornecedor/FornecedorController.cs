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

namespace Facile.BusinessPortal.Api.Cliente
{
    [Route("[controller]")]
    public class FornecedorController : BaseApiController<Model.Fornecedor>
    {
        private readonly string _siteBaseURL;

        public FornecedorController(FBContext db, IHttpContextAccessor contextAccessor, IOptions<AppSettings> appSettings) : base(db, contextAccessor)
        {
            _siteBaseURL = appSettings.Value.SiteBaseURL;
        }


        [HttpPost("SetFornecedor")]
        public async Task<List<SaveDataReturn>> SetFornecedor([FromBody]List<Library.Structs.Post.Fornecedor> ListPost)
        {
            if (ListPost != null)
            {
                ContextParams Params = new ContextParams(HttpContext, db, _userId);
                var ret = await FornecedorDAO.CreateOrUpdateAsync(Params, _siteBaseURL, ListPost);
                return ret;
            }
            string Msg = "Objeto invalido";
            var l = new List<SaveDataReturn>
            {
                SaveDataReturn.ReturnError("", Msg)
            };
            return l;
        }

        [HttpGet("GetTaxa")]
        public async Task<List<TaxaFornecedorGet>> GetTaxa()
        {
            ContextParams Params = new ContextParams(HttpContext, db, _userId);
            var ret = await FornecedorDAO.GetTaxaAsync(Params, _siteBaseURL);
            return ret;
        }

        [HttpPost("UpdateStatusIntegracaoTaxa")]
        public async Task<List<SaveDataReturn>> UpdateStatusIntegracaoTaxa([FromBody]List<Library.Structs.Post.TaxaFornecedorPost> ListPost)
        {
            if (ListPost != null)
            {
                ContextParams Params = new ContextParams(HttpContext, db, _userId);
                var ret = await FornecedorDAO.UpdateStatusIntegracaoTaxaAsync(Params, _siteBaseURL, ListPost);
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
