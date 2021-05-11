using Facile.BusinessPortal.Library.Util;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Facile.BusinessPortal.Library.Structs.Return
{
    public class SaveDataReturn
    {
        public bool Ok { get; set; } = false;
        public string Message { get; set; }
        public string Identificador { get; set; }
        public List<string> ErrorMessages { get; set; }

        public static SaveDataReturn ReturnOk(string ident)
        {
            return new SaveDataReturn()
            {
                Ok = true,
                Message = "",
                Identificador = ident
            };
        }

        public static SaveDataReturn ReturnValidationResults(string ident, List<ValidationResult> results)
        {
            string errors = "";
            foreach (var res in results)
            {
                errors += res.ErrorMessage + Environment.NewLine;
            }

            var ret = new SaveDataReturn()
            {
                Ok = false,
                Message = errors,
                Identificador = ident,
                ErrorMessages = new List<string>()
            };

            foreach (var validres in results)
            {
                ret.ErrorMessages.Add(validres.ErrorMessage);
            }

            return ret;
        }

        public static SaveDataReturn ReturnException(string ident, Exception ex)
        {
            return new SaveDataReturn()
            {
                Ok = false,
                Identificador = ident,
                Message = ErroUtil.GetTextoCompleto(ex)
            };
        }

        public static SaveDataReturn ReturnError(string ident, string message)
        {
            return new SaveDataReturn()
            {
                Ok = false,
                Identificador = ident,
                Message = message
            };
        }
    }
}
