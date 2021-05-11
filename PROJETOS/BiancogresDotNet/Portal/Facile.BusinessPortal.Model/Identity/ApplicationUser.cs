using Microsoft.AspNetCore.Identity;
using System;

namespace Facile.BusinessPortal.Model
{
    // Add profile data for application users by adding properties to the ApplicationUser class
    public class ApplicationUser : IdentityUser
    {
        [PersonalData]
        public DateTime? CreateDate { get; set; }

        [PersonalData]
        public DateTime? LastLoginDate { get; set; }
    }
}
