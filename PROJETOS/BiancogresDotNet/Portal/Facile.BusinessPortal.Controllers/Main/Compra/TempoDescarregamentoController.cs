using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Facile.BusinessPortal.Model;
using System.Threading.Tasks;
using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Library.Util;
using Microsoft.EntityFrameworkCore;
using System;
using Facile.BusinessPortal.Library;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("Compra")]
    public class TempoDescarregamentoController : BaseCommonController<Model.TempoDescarregamento>
    {
        public TempoDescarregamentoController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }
        /*
        protected override void LoadViewBag()
        {
            var ResultTipoVeiculo = _context.TipoVeiculo.AsNoTracking().
                Where(x => x.Habilitado).Select(x => new SelectListItem { Text = x.Nome, Value = x.ID.ToString() }).ToList();
            var ResultTipoProduto = _context.TipoProduto.AsNoTracking().
                Where(x => x.Habilitado).Select(x => new SelectListItem { Text = x.Nome, Value = x.ID.ToString() }).ToList();

            ViewBag.ListaTipoVeiculo = ResultTipoVeiculo;
            ViewBag.ListaTipoProduto = ResultTipoProduto;
        }

        protected override void LoadViewBag(TempoDescarregamento o)
        {
            var ResultTipoVeiculo = _context.TipoVeiculo.AsNoTracking().
                Where(x => x.Habilitado || x.ID == o.TipoVeiculoID).Select(x => new SelectListItem { Text = x.Nome, Value = x.ID.ToString() }).ToList();
            var ResultTipoProduto = _context.TipoProduto.AsNoTracking().
                Where(x => x.Habilitado || x.ID == o.TipoProdutoID).Select(x => new SelectListItem { Text = x.Nome, Value = x.ID.ToString() }).ToList();

            ViewBag.ListaTipoVeiculo = ResultTipoVeiculo;
            ViewBag.ListaTipoProduto = ResultTipoProduto;
        }

        public override async Task<IActionResult> Index()
        {
            List<TempoDescarregamento> list = new List<TempoDescarregamento>();
            try
            {
                list = await (from TempoDescarregamento u in _context.TempoDescarregamento.
                                AsNoTracking().
                                Include(x => x.TipoVeiculo).
                                Include(x => x.TipoProduto)
                              where u.EmpresaID == _empresaId
                              select u).ToListAsync();

            }
            catch (Exception ex)
            {
                var msg = ex.Message;
            }
            return View(list);
        }

        */
    }
}
