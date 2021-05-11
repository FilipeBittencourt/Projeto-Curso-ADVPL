using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.Controllers.Main.Cliente
{
    [Authorize]
    [Area("Cliente")]
    public class HomeController : BaseCommonController<Boleto>
    {
        public HomeController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        public override async Task<IActionResult> Index()
        {
            var modulo = AccessControl.SetCurrentModuloById(HttpContext, _context, 2);
            AccessControl.CriarMenusUsuario(HttpContext, _context, _userId, modulo);

            Usuario usuario = await UsuarioDAO.GetUsuarioAsync(_context, User);

            if (usuario != null)
            {
                var listaSacado = new List<long>();

                if (usuario.Tipo == TipoUsuario.Cliente)
                {
                    listaSacado = SacadoDAO.GetIDListSacadoUsuario(_context, usuario);
                }

                var ListaBoleto = _context.Boleto.Where(
                      x =>
                          x.EmpresaID == usuario.EmpresaID &&
                          listaSacado.Contains(x.SacadoID)
                          && !x.DataRecebimento.HasValue
                          && !x.Deletado
                      );

                ViewBag.QuantidadeTotal = ListaBoleto.Count();

                var qvencidos = from Boleto b in ListaBoleto
                                where DateTime.Now.Date > DataUtil.GetCurrentOrNextWorkingDay(b.DataVencimento.Date)
                                select b;

                var qvencerate15 = from Boleto b in ListaBoleto
                                   where DataUtil.GetCurrentOrNextWorkingDay(b.DataVencimento.Date) >= DateTime.Now.Date
                                       && DataUtil.GetCurrentOrNextWorkingDay(b.DataVencimento.Date) <= DateTime.Now.Date.AddDays(15)
                                   select b;

                var qvencermaior15 = from Boleto b in ListaBoleto
                                   where DataUtil.GetCurrentOrNextWorkingDay(b.DataVencimento.Date) >= DateTime.Now.Date
                                       && DataUtil.GetCurrentOrNextWorkingDay(b.DataVencimento.Date) > DateTime.Now.Date.AddDays(15)
                                   select b;

                ViewBag.TotalVencido = qvencidos.Sum(x => x.ValorTitulo);
                ViewBag.QuantidadeVencido = qvencidos.Count();

                ViewBag.TotalAVencerMenor15 = qvencerate15.Sum(x => x.ValorTitulo);
                ViewBag.QuantidadeAVencerMenor15 = qvencerate15.Count();

                ViewBag.TotalAVencerMaior15 = qvencermaior15.Sum(x => x.ValorTitulo);
                ViewBag.QuantidadeAVencerMaior15 = qvencermaior15.Count();

                ViewBag.ListaBoleto = ListaBoleto.OrderBy(x => x.DataVencimento.Date).Take(10);
            }

            return View();
        }
    }
}
