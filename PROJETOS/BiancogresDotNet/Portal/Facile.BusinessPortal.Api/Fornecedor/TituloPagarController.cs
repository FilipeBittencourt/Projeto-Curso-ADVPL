using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.BusinessRules.DAO;
using System.Collections.Generic;
using Facile.BusinessPortal.Library.Structs.Return;

namespace Facile.BusinessPortal.Api.Cliente
{
    [Route("[controller]")]
    public class TituloPagarController : BaseApiController<TituloPagar>
    {
        public TituloPagarController(FBContext db, IHttpContextAccessor contextAccessor) : base(db, contextAccessor)
        {
        }

        //PUT
        [HttpPost("SetTituloPagar")]
        public async Task<List<SaveDataReturn>> SetTituloPagar([FromBody]List<Library.Structs.Post.TituloPagar> ListPost)
        {
            if (ListPost != null)
            {
                ContextParams Params = new ContextParams(HttpContext, db, _userId);
                var ret = await TituloPagarDAO.CreateOrUpdateAsync(Params, ListPost);
                return ret;
            }
            string Msg = "Objeto invalido";
            var l = new List<SaveDataReturn>
            {
                SaveDataReturn.ReturnError("", Msg)
            };
            return l;
        }

        ////DELETE
        //[HttpDelete("{id}")]
        //public void Delete(int id)
        //{
        //}
    }
}
