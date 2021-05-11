namespace Facile.BusinessPortal.Library.Structs.Post
{
    public class Transportadora : StructIntegracao
    {
        public string CodigoERP { get; set; }
        public string CPFCNPJ { get; set; }
        public string Nome { get; set; }
        public string EmailUsuario { get; set; }
        public string Observacoes { get; set; }

        public string CEP { get; set; }
        public string Logradouro { get; set; }
        public string Numero { get; set; }
        public string Complemento { get; set; }
        public string Bairro { get; set; }
        public string UF { get; set; }
        public string Cidade { get; set; }

        public bool Habilitado { get; set; } = false;
        public bool CriarUsuario { get; set; } = false;
    }
}
