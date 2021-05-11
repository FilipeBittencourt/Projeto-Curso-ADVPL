using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.Model;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;
using System.Security.Claims;

namespace Facile.BusinessPortal.BusinessRules.Security
{
    public class ContextParams
    {
        public FBContext Database { get; set; }
        public HttpContext HttpContext { get; set; }
        public Unidade Unidade { get; set; }
        public string CNPJ { get; set; }
        public Guid IDProcesso { get; set; }

        public ContextParams(HttpContext hc, FBContext db, string cnpj)
        {
            HttpContext = hc;

            Database = db;

            CNPJ = cnpj;

            Unidade = EmpresaDAO.GetEmpresa(db, cnpj);
        }

        public void SetOidProcesso(FBContext db, IDbContextTransaction tran = null)
        {
            //GRAVAR OID DO PROCESSO
            try
            {
                var command = db.Database.GetDbConnection().CreateCommand();

                if (tran != null)
                    command.Transaction = tran.GetDbTransaction();
                else
                {
                    if (db.Database.GetDbConnection().State != System.Data.ConnectionState.Open)
                        db.Database.GetDbConnection().Open();
                }

                command.CommandText = "select newid()";

                using (var result = command.ExecuteReader())
                {
                    result.Read();
                    var oid = result.GetGuid(0);

                    IDProcesso = oid;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                if (tran == null)
                {
                    if (db.Database.GetDbConnection().State == System.Data.ConnectionState.Open)
                        db.Database.GetDbConnection().Close();
                }
            }
        }
    }
}
