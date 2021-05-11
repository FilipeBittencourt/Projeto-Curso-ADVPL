using Facile.BusinessPortal.Model;
using System.Linq;

namespace Facile.BusinessPortal.BusinessRules.DAO
{
    public static class EmpresaDAO
    {
        public static Unidade GetEmpresa(FBContext db, string CNPJ)
        {
            var unidade = from Unidade u in db.Unidade
                          where u.CNPJ == CNPJ
                          select u;

            return unidade.FirstOrDefault();
        }
    }
}
