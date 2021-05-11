using System;

namespace Facile.BusinessPortal.Model
{
    public class LogApiHistorico : Padrao
    {
        public long? EmpresaID { get; set; }
        public long? UnidadeID { get; set; }
        public string Usuario { get; set; }
        public string Controller { get; set; }
        public string Action { get; set; }
        public string RequestIP { get; set; }
        public string RequestMethod { get; set; }
        public string RequestBodyOld { get; set; }
        public string RequestUrl { get; set; }
        public string ResponseBodyOld { get; set; }
        public long? CedenteID { get; set; }
        public long? BoletoID { get; set; }
        public string NossoNumero { get; set; }
        public Guid? IDProcesso { get; set; }
        public byte[] RequestBody { get; set; }
        public byte[] ResponseBody { get; set; }
    }
}
