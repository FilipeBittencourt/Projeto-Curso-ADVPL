using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using Microsoft.AspNetCore.Identity;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.Web.IdentityPolicy
{
    public class CustomPasswordPolicy: PasswordValidator<ApplicationUser>
    {
        public override async Task<IdentityResult> ValidateAsync(UserManager<ApplicationUser> manager, ApplicationUser user, string password)
        {
            IdentityResult result = await base.ValidateAsync(manager, user, password);
            List<IdentityError> errors = result.Succeeded ? new List<IdentityError>() : result.Errors.ToList();

            if (password.ToLower().Contains(user.UserName.ToLower()))
            {
                errors.Add(new IdentityError
                {
                    Description = "A senha não pode conter o login do usuário"
                });
            }

            var letters = Regex.Matches(password, @"[a-zA-Z]").Count;
            var digits = Regex.Matches(password, @"[0-9]").Count;

            if (letters <= 0 || digits <= 0)
            {
                errors.Add(new IdentityError
                {
                    Description = "A senha precisa conter letras e numeros"
                });
            }

            if (LibraryUtil.HasSequentialOrRepeating(password))
            {
                errors.Add(new IdentityError
                {
                    Description = "A senha não pode conter caracteres repetidos ou sequenciais"
                });
            }

            return errors.Count == 0 ? IdentityResult.Success : IdentityResult.Failed(errors.ToArray());
        }
    }
}
