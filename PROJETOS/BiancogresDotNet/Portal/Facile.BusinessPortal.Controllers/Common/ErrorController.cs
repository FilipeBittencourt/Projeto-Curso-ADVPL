using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using System.Diagnostics;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.Library.Mail;
using Facile.BusinessPortal.ViewModels;

namespace FRTech.SmartInvestor.Controllers
{
    public class ErrorController : Controller
    {
        protected readonly FBContext _context;

        public ErrorController(FBContext context)
        {
            _context = context;
        }

        [AllowAnonymous]
        public virtual async Task<IActionResult> Index()
        {
            var model = HttpContext.Session.GetObject<ErrorViewModel>("ErrorModel");

            if (model != null)
            {
                model.UserId = ControllerContext.HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
                model.RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier;
                await Task.Run(() => ErrorSendMail(model));
                return View("Error", model);
            }

            return View("Error", new ErrorViewModel(ErroType.Exception, ControllerContext));
        }

        protected void ErrorSendMail(ErrorViewModel model)
        {
            var mail = MailUtil.ConnectMail();
            MailUtil.SendErrorEmail(mail, model.UserId, model.ErrorTitle, model.ErrorDescription, model.ErrorDetails, model.ControllerName, model.ControllerAction, model.RequestPath);
        }
    }
}
