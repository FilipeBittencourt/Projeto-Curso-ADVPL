using Facile.BusinessPortal.Library.Security;

namespace Facile.BusinessPortal.Library.Structs.Post
{
    public class CreateUserModel
    {
        public bool IsFirstAdmin { get; set; } = false;
        public long GrupoID { get; set; }
        public long? EntidadeID { get; set; }
        public long? GrupoEntidadeID { get; set; }
        public TipoUsuario Tipo { get; set; }
        public string UserName { get; set; }
        public string Nome { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public ClientAuth ClientAuth { get; set; }
    }
}
