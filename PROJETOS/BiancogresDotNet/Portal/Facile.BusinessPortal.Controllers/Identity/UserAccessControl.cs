using Facile.BusinessPortal.Model;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.Controllers
{
    public class UserAccessControl<T> where T : Base
    {
        public long EmpresaId { get; set; }
        public string UserId { get; set; }

        public UserAccessControl(string userId)
        {
            UserId = userId;
        }

        public async Task<List<T>> ExecuteUserQueryAsync(IQueryable<T> query)
        {
            List<T> result;

            if (EmpresaId > 0)
            {
                result = await (from T m in query
                                where m.EmpresaID == EmpresaId
                                select m).ToListAsync();
            }
            else
            {
                return null;
            }

            return result;
        }

        public async Task<List<T>> ExecuteUserQueryAsync(FBContext context)
        {
            List<T> result;

            if (EmpresaId > 0)
            {
                result = await (from T m in context.Set<T>().AsQueryable()
                                where m.EmpresaID == EmpresaId
                                select m).ToListAsync();
            }
            else
            {
                return null;
            }

            return result;
        }

        public static bool CheckControllerAccess(FBContext context, string controllerName, long empresaId)
        {
            var hasAccess = false;

            var qaccess = from Menu m in context.Menu
                          join p in context.Permissao on m.ID equals p.MenuID
                          join g in context.GrupoUsuario on p.GrupoUsuarioID equals g.ID
                          join u in context.Usuario on g.ID equals u.GrupoUsuarioID
                          where m.Nome == controllerName
                          && u.EmpresaID == empresaId
                          select new { ok = true };

            hasAccess = qaccess.Any();

            return hasAccess;
        }
    }
}
