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
    public class ResponsavelFornecedorController : BaseCommonController<Model.Compra.Servico.ResponsavelFornecedor>
    {
        public ResponsavelFornecedorController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }
  
        public override async Task<IActionResult> Index()
        {
            return View();
        }

        public override async Task<IActionResult> Create(ResponsavelFornecedor o)
        {
            o.InsertUser = _userId;
            o.EmpresaID = _empresaId;
            o.InsertDate = DateTime.Now;
            _context.Add(o);
            await _context.SaveChangesAsync();

            return RedirectToAction(nameof(Index));
        }

        public override async Task<IActionResult> Edit(int id, ResponsavelFornecedor rf)
        {

            var dbObj = _context.Set<ResponsavelFornecedor>().FirstOrDefault(o => o.ID == rf.ID);

            CopyCommomPropeties(rf, dbObj);
            _context.Entry(dbObj).State = EntityState.Modified;
            dbObj.LastEditDate = DateTime.Now;

            _context.Update(dbObj);

            await _context.SaveChangesAsync();
                        
            return RedirectToAction(nameof(Index));
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
                    query = @"  select COUNT(*) from ResponsavelFornecedor
                            JOIN Usuario ON Usuario.ID = ResponsavelFornecedor.UsuarioID
                            JOIN Fornecedor ON Fornecedor.ID = ResponsavelFornecedor.FornecedorID";
                    query += @" where ResponsavelFornecedor.EmpresaId = '" + _empresaId + "' ";

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //total filtrado
                    query = @"SELECT COUNT(*) FROM ( 
                                     select ResponsavelFornecedor.ID, UsuarioNome=Usuario.Nome, FornecedorNome=Fornecedor.Nome  from ResponsavelFornecedor
                                    JOIN Usuario ON Usuario.ID = ResponsavelFornecedor.UsuarioID
                                JOIN Fornecedor ON Fornecedor.ID = ResponsavelFornecedor.FornecedorID";
                    query += @" where ResponsavelFornecedor.EmpresaId = '" + _empresaId + "' ";
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";

                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    query = @"SELECT * FROM ( 
                                    select ResponsavelFornecedor.ID, UsuarioNome=Usuario.Nome, FornecedorNome=Fornecedor.Nome from ResponsavelFornecedor 
                                    JOIN Usuario ON Usuario.ID = ResponsavelFornecedor.UsuarioID
                                    JOIN Fornecedor ON Fornecedor.ID = ResponsavelFornecedor.FornecedorID";

                    query += @" where ResponsavelFornecedor.EmpresaId = '" + _empresaId + "' ";
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
                            UsuarioNome = result["UsuarioNome"],
                            FornecedorNome = result["FornecedorNome"]
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
