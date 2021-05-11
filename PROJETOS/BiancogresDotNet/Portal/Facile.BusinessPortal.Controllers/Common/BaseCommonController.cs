using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    public class BaseCommonController<T> : CommonController<T> where T : Base
    {
        protected UserAccessControl<T> _access;
        public BaseCommonController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public override void OnActionExecuting(ActionExecutingContext context)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                _access = new UserAccessControl<T>(userId);
            }
            catch
            {
                throw;
            }

            base.OnActionExecuting(context);
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public override async Task<List<T>> GetDbSet()
        {
            var query = await _context.Set<T>().EmpDataAsync(_empresaId);
            return query.ToList();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public override async Task<IActionResult> Create(T myObject)
        {
            await CreateSaveData(myObject);
            return RedirectToAction(nameof(Index));
        }

        protected override async Task CreateSaveData(T myObject)
        {
            myObject.EmpresaID = _empresaId;
            await base.CreateSaveData(myObject);
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public override async Task<IActionResult> Edit(long? id)
        {
            if (id == null)
            {
                ControllerContext.HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Validation, "[edit] Operação Inválida.", ControllerContext));
                return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
            }
            return await base.Edit(id);
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public override async Task<IActionResult> Delete(long? id)
        {
            if (id == null)
            {
                ControllerContext.HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Validation, "[delete] Operação Inválida.", ControllerContext));
                return await Task.Run(() => new RedirectToActionResult("Index", "Error", null));
            }
            return await base.Delete(id);
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public override async Task<IActionResult> DeleteConfirmed(long id)
        {
            var myObject = await _context.Set<T>().EmpData(_empresaId).SingleOrDefaultAsync(m => m.ID == id);
            if (myObject != null)
            {
                _context.Set<T>().Remove(myObject);
                await _context.SaveChangesAsync();
            }
            else
            {
                ControllerContext.HttpContext.Session.SetObject("ErrorModel", new ErrorViewModel(ErroType.Validation, "[post] Tentativa de excluir objeto inexistente.", ControllerContext));
                return new RedirectToActionResult("Index", "Error", null);
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
