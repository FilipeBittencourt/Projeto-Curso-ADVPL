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
    public class MotoristaController : BaseCommonController<Model.Motorista>
    {
        public MotoristaController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        protected override void LoadViewBag()
        {
            
        }


        /*
        public IActionResult GetMotorista(string q)
        {
            var Result = _context.Motorista.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                (x.CPF.Contains(q) || x.Nome.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 CPF = x.CPF,
                                 Nome = x.Nome
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public IActionResult GetDadosMotorista(long Id)
        {
            var Result = _context.Motorista.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                x.ID == Id
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Placa = x.Placa,
                                 Nome = x.Nome
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        protected override void LoadViewBag(Motorista o)
        {
           
        }

        public override async Task<IActionResult> Index()
        {
            return View();
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
                    query = @"  select COUNT(*) from Motorista";
                    query += @" where EmpresaId = '" + _empresaId + "' ";

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //Campos para filtro e retorno
                    var cqfields = "ID, Nome, CPF, Placa, CNH, DescricaoStatus=(case when Habilitado = 1 then 'Ativo' else 'Inativo' end) ";

                    //total filtrado
                    query = $@"SELECT COUNT(*) FROM ( 
                                     select {cqfields} from Motorista";
                    query += @" where EmpresaId = '" + _empresaId + "' ";
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";

                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    query = $@"SELECT * FROM ( 
                                    select {cqfields} from Motorista";
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
                            Nome = result["Nome"],
                            CPF = result["CPF"],
                            CNH = result["CNH"],
                            Placa = result["Placa"],
                            DescricaoStatus = result["DescricaoStatus"],
                            EmpresaID = _empresaId
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

          */
    }
}
