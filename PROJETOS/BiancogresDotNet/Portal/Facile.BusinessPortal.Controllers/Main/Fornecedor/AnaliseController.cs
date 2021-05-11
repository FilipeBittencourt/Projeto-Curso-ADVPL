using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Model;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("Fornecedor")]
    public class AnaliseController : BaseCommonController<TituloPagar>
    {
        public AnaliseController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        public override async Task<IActionResult> Index()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            ViewBag.TipoUsuario = (usuario.Tipo == TipoUsuario.Fornecedor) ? 1 : 2;

            ViewBag.DataInicio = "";
            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                ViewBag.DataInicio = DateTime.Now.AddDays(1).ToString("dd/MM/yyyy");
            }

            ViewBag.Unidades = _context.Unidade.
                            Where(x => x.EmpresaID == _empresaId && x.Habilitado).
                            Select(x => new SelectListItem() {
                                Value = x.ID.ToString(),
                                Text = x.Codigo + " - "+ x.Nome
                            }).OrderBy(x=>x.Text);

            if (usuario.Tipo == TipoUsuario.Fornecedor)
            {
                return View("IndexFO");
            }
            return View();
        }

    }
}
