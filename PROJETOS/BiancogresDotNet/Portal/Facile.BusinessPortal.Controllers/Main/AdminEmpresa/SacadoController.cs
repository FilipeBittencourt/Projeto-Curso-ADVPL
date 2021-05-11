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
using Facile.BusinessPortal.Library.Structs.Post;
using Sacado = Facile.BusinessPortal.Model.Sacado;
using System.Net.Http;
using Newtonsoft.Json;
using Facile.BusinessPortal.Library.Structs.Return;
using System.Net.Http.Headers;
using Facile.BusinessPortal.ViewModels;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("AdminEmpresa")]
    public class SacadoController : BaseCommonController<Model.Sacado>
    {
        public SacadoController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        public override async Task<IActionResult> Index()
        {
            return View();
        }


        public async Task<IActionResult> BoletoPendente()
        {
            List<ViewModelBoletoPendente> Lista = new List<ViewModelBoletoPendente>();

            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();

                    //registros
                    var query = $@"select TOP 100 SacadoID, Quantidade=Count(*) from Boleto
                                    where DataRecebimento is null
                                    and EmpresaID  = '" + _empresaId + "'";
                    query += " group by SacadoID";

                    command.CommandText = query;
                    var result = command.ExecuteReader();

                    while (result.Read())
                    {
                        var SacadoID = Convert.ToInt32(result["SacadoID"]);
                        var Quantidade = Convert.ToInt32(result["Quantidade"]);

                        var Result = _context.Sacado.FirstOrDefault(x => x.ID == SacadoID);
                        var Nome = "";
                        var Email = "";

                        if (Result != null)
                        {
                            Nome = Result.Nome;
                            Email = Result.Email;
                        }
                        Lista.Add(new ViewModelBoletoPendente
                        {
                            Nome = Nome,
                            Email = Email,
                            Quantidade = Quantidade
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

            
            ViewBag.ListaSacado = Lista;

            return View();
        }

        public async Task<IActionResult> BoletoPendenteEnvMail(bool CheckUsuarioSacado=false) {

            var Mensagem = "";
            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();

                    //registros
                    var query = $@"select TOP 500 SacadoID from Boleto
                                    where DataRecebimento is null
                                    and EmpresaID  = '" + _empresaId + "'";
                    if (CheckUsuarioSacado)
                    {
                        query += $@"and not exists(
                                    select NULL from UsuarioSacado US
                                        where US.SacadoID = Boleto.SacadoID
                                    )";
                    }

                    query += " group by SacadoID";

                    command.CommandText = query;
                    var result = command.ExecuteReader();

                    while (result.Read())
                    {
                        var SacadoID = Convert.ToInt32(result["SacadoID"]);

                        var client = new HttpClient();

                        var Query = "?empresaId=" + _empresaId + "&pessoaId=" + SacadoID + "&tipo=2";

                        string baseUrl = string.Format("{0}://{1}{2}", Request.Scheme, Request.Host, Request.PathBase);

                        var Url = baseUrl + @"/Account/RegisterOrResetAsync" + Query;
                        var response = await client.GetAsync(Url);

                        var res = await response.Content.ReadAsStringAsync();

                        var userreturn = JsonConvert.DeserializeObject<ApplicationUserReturn>(res);
                        if (!userreturn.Ok)
                        {
                            Mensagem += userreturn.Message;
                        }
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

            if (string.IsNullOrEmpty(Mensagem))
            {
                return RedirectToAction("Result", new { ClosePage = true });
            }
            else
            {
                return RedirectToAction("Result", new { Mensagem = Mensagem });
            }
        }

        public IActionResult Result(string Mensagem = "", bool ClosePage = false)
        {
            ViewBag.Mensagem = Mensagem;
            ViewBag.ClosePage = ClosePage;

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
                    query = @"  select COUNT(*) from Sacado";
                    query += @" where EmpresaId = '" + _empresaId + "' ";

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //Campos para filtro e retorno
                    var cqfields = "ID, CPFCNPJ, CodigoERP, Nome, Email, Bairro, Cidade, UF";

                    //total filtrado
                    query = $@"SELECT COUNT(*) FROM ( 
                                     select {cqfields} from Sacado";
                    query += @" where EmpresaId = '" + _empresaId + "' ";
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";

                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    query = $@"SELECT * FROM ( 
                                    select {cqfields} from Sacado";
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
                            CodigoERP = result["CodigoERP"],
                            CPFCNPJ = result["CPFCNPJ"],
                            Nome = result["Nome"],
                            Email = result["Email"],
                            Bairro = result["Bairro"],
                            Cidade = result["Cidade"],
                            UF = result["UF"],
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
    }
}
