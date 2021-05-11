using Microsoft.AspNetCore.Mvc;

namespace Facile.BusinessPortal.BusinessRules.Extensions
{
    public static class UrlHelperExtensions
    {
        public static string EmailConfirmationLink(this IUrlHelper urlHelper, string userId, string code, string scheme, string action)
        {
            return urlHelper.Action(action: action, controller: "Account", values: new
            {
                userId,
                code
            }, protocol: scheme);
        }

        public static string ResetPasswordCallbackLink(this IUrlHelper urlHelper, string userId, string code, string scheme, string action)
        {
            return urlHelper.Action(action: action, controller: "Account", values: new
            {
                userId,
                code
            }, protocol: scheme);
        }
    }
}
