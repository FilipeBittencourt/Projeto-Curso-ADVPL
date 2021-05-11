using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.Model
{
    public static class DbSetExtensions
    {
        public static IQueryable<T> EmpData<T>(this DbSet<T> dbSet, long empresaId, long? unidadeId = null) where T : Base
        {
            return dbSet.Where(o => o.EmpresaID == empresaId && o.UnidadeID == unidadeId);
        }

        public static async Task<IQueryable<T>> EmpDataAsync<T>(this DbSet<T> dbSet, long empresaId, long? unidadeId = null) where T : Base
        {
            var list = await dbSet.Where(o => o.EmpresaID == empresaId && o.UnidadeID == unidadeId).ToListAsync();
            return list.AsQueryable();
        }
    }
}
