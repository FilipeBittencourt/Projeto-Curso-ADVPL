using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using System.Linq;
using System;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.Library;
using System.Collections.Generic;
using System.Threading.Tasks;
using Facile.BusinessPortal.BusinessRules.DAO;
using Microsoft.EntityFrameworkCore;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model.Compra.Servico;

namespace Facile.BusinessPortal.Controllers.Compra
{
    [Authorize]
    [Area("Compra")]
    public class CompradorController : BaseCommonController<Model.Compra.Servico.Comprador>
    {
        public CompradorController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }
  
        public override async Task<IActionResult> Index()
        {
            return View();
        }

        public IActionResult GetSolicitante(string q)
        {
            var Result = _context.Usuario.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Nome = x.Nome
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public override async Task<IActionResult> Create(Comprador o)
        {
            string[] Solicitante = Request.Form["Solicitante"];

            o.InsertUser = _userId;
            o.EmpresaID = _empresaId;
            o.InsertDate = DateTime.Now;
            _context.Add(o);
            await _context.SaveChangesAsync();

            if (Solicitante != null)
            {
                if (o.ID != 0)
                {
                    foreach (var s in Solicitante)
                    {
                        if (!string.IsNullOrEmpty(s))
                        {
                            Model.Compra.Servico.CompradorSolicitante compradorSolicitante = new Model.Compra.Servico.CompradorSolicitante();
                            compradorSolicitante.EmpresaID = _empresaId;
                            compradorSolicitante.CompradorID = o.ID;
                            compradorSolicitante.Habilitado = true;
                            compradorSolicitante.UsuarioID = Convert.ToInt64(s);
                            _context.Add<Model.Compra.Servico.CompradorSolicitante>(compradorSolicitante);

                        }
                    }
                    await _context.SaveChangesAsync();
                }
            }

            return RedirectToAction(nameof(Index));
        }

        public override async Task<IActionResult> Edit(int id, Comprador com)
        {

            var dbObj = _context.Set<Comprador>().FirstOrDefault(o => o.ID == com.ID);

            CopyCommomPropeties(com, dbObj);
            _context.Entry(dbObj).State = EntityState.Modified;
            dbObj.LastEditDate = DateTime.Now;

            _context.Update(dbObj);

            _context.CompradorSolicitante.RemoveRange(_context.CompradorSolicitante.Where(X => X.CompradorID == dbObj.ID));

            await _context.SaveChangesAsync();

            string[] Solicitante = Request.Form["Solicitante"];
            if (Solicitante != null)
            {
                if (com.ID != 0)
                {
                    foreach (var s in Solicitante)
                    {
                        if (!string.IsNullOrEmpty(s))
                        {
                            Model.Compra.Servico.CompradorSolicitante compradorSolicitante = new Model.Compra.Servico.CompradorSolicitante();
                            compradorSolicitante.EmpresaID = _empresaId;
                            compradorSolicitante.CompradorID = com.ID;
                            compradorSolicitante.Habilitado = true;
                            compradorSolicitante.UsuarioID = Convert.ToInt64(s);
                            _context.Add<Model.Compra.Servico.CompradorSolicitante>(compradorSolicitante);

                        }
                    }
                    await _context.SaveChangesAsync();
                }
            }

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
                    query = @"  select COUNT(*) from Comprador
                            JOIN Usuario ON Usuario.ID = Comprador.UsuarioID";
                    query += @" where Comprador.EmpresaId = '" + _empresaId + "' ";

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //total filtrado
                    query = @"SELECT COUNT(*) FROM ( 
                                     select Comprador.ID, Nome from Comprador
                                    JOIN Usuario ON Usuario.ID = Comprador.UsuarioID";
                    query += @" where Comprador.EmpresaId = '" + _empresaId + "' ";
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";

                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    query = @"SELECT * FROM ( 
                                    select Comprador.ID, Usuario.Nome from Comprador 
                                    JOIN Usuario ON Usuario.ID = Comprador.UsuarioID";
                    query += @" where Comprador.EmpresaId = '" + _empresaId + "' ";
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
