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
    [Area("AdminEmpresa")]
    public class GrupoSacadoController : BaseCommonController<GrupoSacado>
    {
        //protected readonly FBContext _context;
        //private long _empresaId = 2;


        public GrupoSacadoController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
          //  _context = context;
        }

        
        public override async Task<IActionResult> Index()
        {
            return View();
        }

        
        protected override void LoadViewBag(GrupoSacado o)
        {
            //ViewBag.ListaSacados = _context.Sacado.
            //                    Where(x=>x.GrupoSacadoID == o.ID).
            //                    Select(x=> new SelectListItem { Text = x.CPFCNPJ+" - "+x.Nome, Value = x.ID.ToString(), Selected=true });

            ViewBag.ListaSacados = _context.Sacado.
                                Where(x=>x.GrupoSacadoID == o.ID);
        }

        public IActionResult GetSacado(string q)
        {
            var Result = _context.Sacado.AsNoTracking().
                            Where(x=>
                                x.EmpresaID == _empresaId && 
                                x.Habilitado &&
                                (x.CPFCNPJ.Contains(q) || x.Nome.Contains(q)) &&
                                !x.GrupoSacadoID.HasValue
                                ).
                            Select(x=>
                             new
                             {
                                 Id = x.ID, 
                                 CPFCNPJ = x.CPFCNPJ,
                                 Nome = x.Nome
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public override async Task<IActionResult> Create(GrupoSacado o)
        {
            string[] Sacados = Request.Form["Sacados"];

            o.CodigoUnico = "x";
            o.InsertUser = _userId;
            o.EmpresaID = _empresaId;
            o.InsertDate = DateTime.Now;
            _context.Add(o);
            await _context.SaveChangesAsync();

            if (Sacados != null)
            {
                if (o.ID != 0)
                {
                    o.CodigoUnico = o.ID.ToString();
                    foreach (var s in Sacados)
                    {
                        var ResultSacado = _context.Sacado.FirstOrDefault(x=>x.ID == Convert.ToInt64(s));
                        if (ResultSacado != null)
                        {
                            _context.Entry(ResultSacado).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                            ResultSacado.GrupoSacadoID = o.ID;
                        }
                    }
                    await _context.SaveChangesAsync();
                }
            }
            
            return RedirectToAction(nameof(Index));
        }

        public override async Task<IActionResult> Edit(int id, GrupoSacado gs)
        {

            var dbObj = _context.Set<GrupoSacado>().FirstOrDefault(o => o.ID == gs.ID);

            CopyCommomPropeties(gs, dbObj);
            _context.Entry(dbObj).State = EntityState.Modified;
            dbObj.LastEditDate = DateTime.Now;

            _context.Update(dbObj);
            await _context.SaveChangesAsync();

            string[] Sacados = Request.Form["Sacados"];

            //remove todos sacodos que tem o grupo
            foreach(var sac in _context.Sacado.Where(x => x.GrupoSacadoID == gs.ID))
            {
                _context.Entry(sac).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
               sac.GrupoSacadoID = null;
            }
            
            if (Sacados != null)
            {
                //adiciona os novos sacados
                foreach (var s in Sacados)
                {
                    var SacadoID = Convert.ToInt32(s);
                    var ResultSacado = _context.Sacado.FirstOrDefault(x => x.ID == SacadoID);
                    if (ResultSacado != null)
                    {
                        _context.Entry(ResultSacado).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                        ResultSacado.GrupoSacadoID = gs.ID;
                    }
                }
            }
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));

            //return  await base.Edit(id, o);
        }
        
        public IActionResult DataTable()
        {
            var draw = Request.Form["draw"].FirstOrDefault();
            var start = Request.Form["start"].FirstOrDefault();
            var length = Request.Form["length"].FirstOrDefault();
            var sortColumn = Request.Form["order[0][column]"].FirstOrDefault();
            var sortColumnDir = Request.Form["order[0][dir]"].FirstOrDefault();
            var searchValue = Request.Form["search[value]"].FirstOrDefault();
            var fieldSearch = Request.Form["FieldSearch"].FirstOrDefault();

            int pageSize = length != null ? Convert.ToInt32(length) : 0;
            int skip = start != null ? Convert.ToInt32(start) : 0;
            int orderby = sortColumn != null ? Convert.ToInt32(sortColumn) + 1 : 1;

            int recordsTotal = 0;
            int recordsFiltered = 0;
            string query = "";
            List<dynamic> data = new List<dynamic>();

            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    //total de registro
                    query = @"  select COUNT(*) from GrupoSacado";
                    query += @" where EmpresaId = '" + _empresaId + "' ";
                    
                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //total filtrado
                    query = @"SELECT COUNT(*) FROM ( 
                                     select ID, Nome from GrupoSacado";
                    query += @" where EmpresaId = '" + _empresaId + "' ";
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";

                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    query = @"SELECT * FROM ( 
                                    select ID, Nome from GrupoSacado";
                    query += @" where EmpresaId = '" + _empresaId + "' ";
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";
                    query += @" ORDER BY " + orderby + " " + sortColumnDir + ((pageSize != -1) ? " OFFSET " + (skip) + " ROWS FETCH NEXT " + (pageSize) + " ROWS ONLY" : "");

                    command.CommandText = query;
                    var result = command.ExecuteReader();

                    while (result.Read())
                    {
                        data.Add(new
                        {
                            Id = result["ID"],
                            Nome = result["Nome"]
                        });
                    }
                }
                finally
                {
                    if (_context.Database.GetDbConnection().State == System.Data.ConnectionState.Open)
                    {
                        _context.Database.CloseConnection();
                    }
                }

            }

            return Json(new { draw, recordsFiltered, recordsTotal, data });
        }
    }
}
