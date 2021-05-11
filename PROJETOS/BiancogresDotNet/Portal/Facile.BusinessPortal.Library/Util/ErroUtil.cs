using Microsoft.EntityFrameworkCore;
using System;

namespace Facile.BusinessPortal.Library.Util
{
    public static class ErroUtil
    {
        public static string GetTextoCompleto(Exception e)
        {
            var retorno = e.Message;

            if (e is DbUpdateException)
            {
                foreach (var entry in (e as DbUpdateException).Entries)
                {
                    retorno += Environment.NewLine + (e as DbUpdateException).Message;
                }
            }

            if (!string.IsNullOrWhiteSpace(e.StackTrace))
                retorno += Environment.NewLine + "STACK TRACE: " + Environment.NewLine + e.StackTrace;

            if (e.InnerException != null)
            {
                retorno += Environment.NewLine;
                retorno += "INNER EXCEPTION: " + Environment.NewLine;
                retorno += GetTextoCompleto(e.InnerException);
            }

            return retorno;
        }
    }
}
