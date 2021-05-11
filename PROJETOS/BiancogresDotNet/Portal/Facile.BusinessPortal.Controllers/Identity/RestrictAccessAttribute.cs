using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Text;

namespace Facile.BusinessPortal.Controllers
{
    public class RestrictAccessAttribute : ActionFilterAttribute
    {
        protected readonly FBContext _context;

        public RestrictAccessAttribute(FBContext context)
        {
            _context = context;
        }

        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            try
            {
                base.OnActionExecuting(filterContext);

                var userId = filterContext.HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
                var controllerName = (string)filterContext.RouteData.Values["Controller"];
                var actionName = (string)filterContext.RouteData.Values["Action"];

                //if (!(AccessControl.CheckAccess(_context, userId, controllerName)))
                //{
                //    var error = new AccessErrorViewModel(controllerName, actionName);

                //    filterContext.HttpContext.Session.SetObject("ErrorModel", error);
                //    filterContext.Result = new RedirectToActionResult("Index", "Error", null);
                //}
            }
            catch (Exception ex)
            {
                filterContext.HttpContext.Session.SetObject("ErrorModel", new AccessErrorViewModel(ex, "", ""));
                filterContext.Result = new RedirectToActionResult("Index", "Error", null);
            }
        }
    }
}
