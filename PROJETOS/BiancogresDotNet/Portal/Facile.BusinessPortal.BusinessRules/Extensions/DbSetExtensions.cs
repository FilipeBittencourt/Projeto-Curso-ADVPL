using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.BusinessRules
{
    public static class DbSetExtensions
    {
        public static IQueryable<T> ByParams<T>(this DbSet<T> dbSet, ContextParams Params, bool IsEmpShared = false) where T : Base
        {
            long? unidadeId = null;
            if (!IsEmpShared)
                unidadeId = Params.Unidade.ID;

            var list = dbSet.EmpData<T>(Params.Unidade.EmpresaID, unidadeId);
            return list;
        }

        public static IQueryable<T> ByUser<T>(this DbSet<T> dbSet, Usuario User, long? unidadeId = null) where T : Base
        {
            long empresaId = User.EmpresaID;
            var list = dbSet.EmpData<T>(empresaId, unidadeId);
            return list;
        }

        public static async Task<IQueryable<T>> ByUserAsync<T>(this DbSet<T> dbSet, Usuario User, long? unidadeId = null) where T : Base
        {
            long empresaId = User.EmpresaID;
            var list = await dbSet.EmpDataAsync<T>(empresaId, unidadeId);
            return list;
        }
    }
}
