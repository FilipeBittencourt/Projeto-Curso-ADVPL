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

namespace Facile.BusinessPortal.Api.Compra
{
    [Route("[controller]")]
    public class NotaFiscalCompraController : BaseApiController<Model.PedidoCompra>
    {
        private readonly string _siteBaseURL;

        public NotaFiscalCompraController(FBContext db, IHttpContextAccessor contextAccessor, IOptions<AppSettings> appSettings) : base(db, contextAccessor)
        {
            _siteBaseURL = appSettings.Value.SiteBaseURL;
        }


        [HttpPost("SetNotaFiscalCompra")]
        public async Task<List<SaveDataReturn>> SetNotaFiscalCompra([FromBody]List<Library.Structs.Post.NotaFiscalCompra> ListPost)
        {
            /*if (ListPost != null)
            {
                ContextParams Params = new ContextParams(HttpContext, db, _userId);
                var ret = await NotaFiscalCompraDAO.CreateOrUpdateAsync(Params, _siteBaseURL, ListPost);
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
