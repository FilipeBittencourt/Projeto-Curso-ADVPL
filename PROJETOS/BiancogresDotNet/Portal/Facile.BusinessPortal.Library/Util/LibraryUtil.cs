using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace Facile.BusinessPortal.Library.Util
{
    public static class LibraryUtil
    {
        public static string BytesToString(byte[] bytes)
        {
            string response = string.Empty;

            foreach (byte b in bytes)
            {
                response += (Char)b;
            }

            return response;
        }

        public static string DataSQL(string Data)
        {
            var dt = Data.Substring(6, 4) + '-' + Data.Substring(3, 2) + '-' + Data.Substring(0, 2);
            return dt;
        }

        public static string BinaryToString(string data)
        {
            List<Byte> byteList = new List<Byte>();

            for (int i = 0; i < data.Length; i += 8)
            {
                byteList.Add(Convert.ToByte(data.Substring(i, 8), 2));
            }
            return Encoding.ASCII.GetString(byteList.ToArray());
        }

        public static decimal CalculaValorAntecipacao(DateTime Vencimento, DateTime Pagamento, decimal Valor, decimal PercentualPorDia)
        {
            if (Vencimento != null && Pagamento != null)
            {
                if (Pagamento < Vencimento)
                {
                    var Dias = Convert.ToDecimal(Vencimento.Subtract(Pagamento).TotalDays);
                    var Juros = (PercentualPorDia/100);

                    var Desconto = Valor * ((Juros/30)*Dias);
                    Desconto = Math.Round(Desconto, 2);
                    Valor -= Desconto;
                }
            }
            return Valor;
        }

        public static string GetDescricaoStatusAntecipacao(StatusAntecipacao statusAntecipacao)
        {
            switch(statusAntecipacao)
            {
                case StatusAntecipacao.AguardandoParecerEmpresa:
                    return "Aguardando Parecer Empresa";
                case StatusAntecipacao.AguardandoParecerFornecedor:
                    return "Aguardando Parecer Fornecedor";
                case StatusAntecipacao.Aprovada:
                    return "Aprovada";
                case StatusAntecipacao.Cancelada:
                    return "Cancelada";
                case StatusAntecipacao.Aceite:
                    return "Aceita";
                case StatusAntecipacao.Alteracao:
                    return "Alterada";
                case StatusAntecipacao.Recusa:
                    return "Recusada";
            }
           
            return "";
        }
       

        public static string NormalizaSearch(string fieldSearch)
        {
            
            string Result = "";
            if (fieldSearch != null)
            {
                var ListSearch = fieldSearch.Split('|');
                foreach (var item in ListSearch)
                {
                    if (!string.IsNullOrEmpty(item))
                    {
                        var field = item.Split('=');
                        if (!string.IsNullOrEmpty(Result))
                        {
                            Result += " AND ";
                        }
                        Result += "  " + field[0] + "  LIKE '%" + field[1] + "%'";

                    }
                }

                if (string.IsNullOrEmpty(Result.Trim()))
                {
                    Result = " 1=1 ";
                }
                return Result;
            }
            return " 1=1 ";
        }

        public static bool HasSequentialOrRepeating(string textToValidate)
        {
            var isMatch = HasRepeatingChars(textToValidate);

            if (!isMatch)
            {
                string pattern = @"(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)\1{0,}";

                isMatch = Regex.IsMatch(textToValidate, pattern);

                if (isMatch)
                {
                    Console.WriteLine("HasSequentialOrRepeating > Sequential Letter");
                    return true;
                }
                else
                {
                    var patternup = @"(012|123|234|345|456|567|678|789)\1{0,}";
                    var patterndown = @"(987|876|765|654|543|432|321|210)\1{0,}";

                    isMatch = Regex.IsMatch(textToValidate, patternup) || Regex.IsMatch(textToValidate, patterndown);

                    if (isMatch)
                    {
                        Console.WriteLine("HasSequentialOrRepeating > Sequential Digit");
                        return true;
                    }
                }
            }
            else
                Console.WriteLine("HasSequentialOrRepeating > Repeating");

            return isMatch;
        }


        public static bool HasRepeatingChars(string textToValidate)
        {
            string pattern = @"(.)\1{2,}";

            var isMatch = Regex.IsMatch(textToValidate, pattern);

            //var isMatch = Regex.IsMatch(textToValidate, re);

            return isMatch;
        }
    }
}
