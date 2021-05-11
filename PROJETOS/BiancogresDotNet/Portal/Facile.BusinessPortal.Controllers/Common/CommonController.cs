using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Facile.BusinessPortal.Model;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    public class CommonController<T> : Controller where T : Padrao
    {
        protected readonly FBContext _context;
        protected readonly IHttpContextAccessor _contextAccessor;
        protected readonly string _userId;
        protected readonly Usuario _usuario;
        protected readonly long _empresaId;

        public CommonController(FBContext context, IHttpContextAccessor contextAccessor)
        {
            _context = context;
            _contextAccessor = contextAccessor;
            _userId = contextAccessor.HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
            _empresaId = 0;

            _usuario = _context.Usuario.First(o => o.UserId == _userId);
            if (_usuario != null)
            {
                _empresaId = _usuario.EmpresaID;
            }
        }

    // GET
    [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual async Task<IActionResult> Index()
        {
            try
            {
                var list = await GetList();
                return View(list);
            }
            catch (Exception ex)
            {
                var msg = ex.Message;
            }
            return View();
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual async Task<List<T>> GetList()
        {            
            LoadViewBag();
            List<T> list = await GetDbSet();
                       
            return list;
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual async Task<List<T>> GetDbSet()
        {
            return await _context.Set<T>().ToListAsync();
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual List<T> GetInitialList(List<T> list)
        {
            list = list.Take(20).ToList();
            return list;
        }

        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual List<T> SearchList(ref List<T> list, string word)
        {
            list = _context.Set<T>().Take(20).ToList();
            return list;
        }

        // GET: T/Details
        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual async Task<IActionResult> Details(long? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var myObject = await _context.Set<T>()
                .SingleOrDefaultAsync(m => m.ID == id);
            if (myObject == null)
            {
                return NotFound();
            }

            return View(myObject);
        }

        // GET: T/Create
        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual IActionResult Create()
        {
            LoadViewBag();
            return View();
        }

        // POST: T/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public virtual async Task<IActionResult> Create(T myObject)
        {
            await CreateSaveData(myObject);
            return RedirectToAction(nameof(Index));
        }

        protected virtual async Task CreateSaveData(T myObject)
        {
            myObject.InsertDate = DateTime.Now;
            _context.Add(myObject);
            await _context.SaveChangesAsync();
        }

        // GET: T/Edit/5
        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual async Task<IActionResult> Edit(long? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var myObject = await _context.Set<T>().SingleOrDefaultAsync(m => m.ID == id);
            if (myObject == null)
            {
                return NotFound();
            }

            LoadViewBag();
            LoadViewBag(myObject);
            return View(myObject);
        }

        // POST: T/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public virtual async Task<IActionResult> Edit(int id, T myObject)
        {
            await EditSaveData(myObject);
            return RedirectToAction(nameof(Index));
        }

        public async Task<T> EditSaveData(T myObject)
        {
            var dbObj = _context.Set<T>().FirstOrDefault(o => o.ID == myObject.ID);


            CopyCommomPropeties(myObject, dbObj);
            _context.Entry(dbObj).State = EntityState.Modified;
            dbObj.LastEditDate = DateTime.Now;
            
            _context.Update(dbObj);

            try
            {
                await _context.SaveChangesAsync();
            }catch (Exception ex)
            {
                var e = ex.Message;
            }
            return dbObj;
        }

        // GET: T/Delete/5
        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual async Task<IActionResult> Delete(long? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var myObject = await _context.Set<T>()
                .SingleOrDefaultAsync(m => m.ID == id);
            if (myObject == null)
            {
                return NotFound();
            }

            return View(myObject);
        }

        // POST: T/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual async Task<IActionResult> DeleteConfirmed(long id)
        {
            var myObject = await _context.Set<T>().SingleOrDefaultAsync(m => m.ID == id);
            _context.Set<T>().Remove(myObject);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        protected bool ObjectExists(long id)
        {
            return _context.Set<T>().Any(e => e.ID == id);
        }

        protected virtual void LoadViewBag()
        {
            ViewBag.NomeModelo = typeof(T).Name;

        }

        protected virtual void LoadViewBag(T o)
        {
        }

        protected static void CopyCommomPropeties(Padrao origem, Padrao destino)
        {
            var props = origem.GetType().GetProperties();

            foreach (var prop in props)
            {
                //!prop.GetGetMethod().IsVirtual  && 
                if (prop.Name.Trim() != "UserId" && 
                    prop.Name.Trim() != "InsertDate")
                {
                    var destP = destino.GetType().GetProperty(prop.Name.Trim());
                    if (destP != null)
                        destP.SetValue(destino, prop.GetValue(origem));
                }
            }
        }
    }
}
