namespace Facile.BusinessPortal.Library.Structs.Return
{
    public class ApplicationUserReturn
    {
        public bool Ok { get; set; }
        public string Message { get; set; }
        public string UserName { get; set; }
        public string Email { get; set; }
        public string Id { get; set; }

        public static ApplicationUserReturn Erro(string userName, string email, string message)
        {
            var erro = new ApplicationUserReturn()
            {
                Ok = false,
                Message = message,
                UserName = userName,
                Email = email
            };

            return erro;
        }
    }
}
