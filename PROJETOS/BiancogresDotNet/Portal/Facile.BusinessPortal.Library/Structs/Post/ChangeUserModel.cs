using Facile.BusinessPortal.Library.Security;

namespace Facile.BusinessPortal.Library.Structs.Post
{
    public class ChangeUserModel
    {
        public string UserName { get; set; }
        public string Email { get; set; }
        public bool IsLocked { get; set; }
        public ClientAuth ClientAuth { get; set; }
    }
}
