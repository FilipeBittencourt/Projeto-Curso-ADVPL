namespace Facile.BusinessPortal.Library.Security
{
    public class AccessReturn
    {
        public bool Ok { get; set; } = true;
        public string CNPJ { get; set; }
        public string Nome { get; set; }
        public string Token { get; set; }
        public string Message { get; set; } = "";
    }
}
