using Facile.BusinessPortal.Model;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    public class GrupoUsuarioController : BaseCommonController<GrupoUsuario>
    {
        public GrupoUsuarioController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        protected override void LoadViewBag()
        {
            var ResultMenu = _context.Menu.AsNoTracking().
                Include(x => x.MenuAcao).
                    ThenInclude(x => x.Acao).
                Where(x => x.Habilitado);

            ViewBag.ListaMenu = ResultMenu;
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public override async Task<IActionResult> Edit(long? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var myObject = await _context.Set<GrupoUsuario>().
                Include(x => x.Permissao).
                SingleOrDefaultAsync(m => m.ID == id);
            if (myObject == null)
            {
                return NotFound();
            }
            LoadViewBag();
            return View(myObject);
        }

        public override async Task<IActionResult> Create(GrupoUsuario o)
        {
            string[] Menu = Request.Form["Menu"];
            string[] Acao = Request.Form["Acao"];
            string[] Acesso = Request.Form["Acesso"];

            List<Permissao> Lista = new List<Permissao>();
            for (int i = 0; i < Menu.Length; i++)
            {
                if (!string.IsNullOrEmpty(Menu[i]) && !string.IsNullOrEmpty(Acao[i]) && !string.IsNullOrEmpty(Acesso[i]))
                {
                    if (Convert.ToBoolean(Acesso[i]))
                    {
                        Permissao p = new Permissao();
                        p.Habilitado = true;
                        p.InsertDate = DateTime.Now;
                        p.MenuID = Convert.ToInt32(Menu[i]);
                        p.AcaoID = Convert.ToInt32(Acao[i]);
                        p.Acesso = "";

                        Lista.Add(p);
                    }
                }
            }
            o.Permissao = Lista;

            return await base.Create(o);
        }

        public override async Task<IActionResult> Edit(int id, GrupoUsuario o)
        {
            string[] Menu = Request.Form["Menu"];
            string[] Acao = Request.Form["Acao"];
            string[] Acesso = Request.Form["Acesso"];

            List<Permissao> Lista = new List<Permissao>();
            for (int i = 0; i < Menu.Length; i++)
            {
                if (!string.IsNullOrEmpty(Menu[i]) && !string.IsNullOrEmpty(Acao[i]) && !string.IsNullOrEmpty(Acesso[i]))
                {
                    if (Convert.ToBoolean(Acesso[i]))
                    {
                        Permissao p = new Permissao();
                        p.Habilitado = true;
                        p.InsertDate = DateTime.Now;
                        p.MenuID = Convert.ToInt32(Menu[i]);
                        p.AcaoID = Convert.ToInt32(Acao[i]);
                        p.EmpresaID = _empresaId;
                        p.Acesso = "";

                        Lista.Add(p);
                    }
                }
            }

            o.Permissao = Lista;
            _context.Permissao.RemoveRange(_context.Permissao.Where(x => x.GrupoUsuarioID == o.ID));

            return await base.Edit(id, o);
        }
    }
}
