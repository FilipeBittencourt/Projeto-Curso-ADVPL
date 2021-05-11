using System;

namespace Facile.Financeiro.BoletoNetCore.Extensions
{
    public static class StringExtensions
    {
        public static string MidVB(this string str, int start, int length)
        {
            return str.Mid(--start,length);
        }

        public static string Mid(this string str, int startIndex, int length)
        {
            if (str.Length <= 0 || startIndex >= str.Length) return string.Empty;
            if (startIndex + length > str.Length)
            {
                length = str.Length - startIndex;
            }
            return str.Substring(startIndex, length);
        }

        public static string CalcularDVCaixa(this string texto)
        {
            string digito;
            int pesoMaximo = 9, soma = 0, peso = 2;
            for (var i = texto.Length - 1; i >= 0; i--)
            {
                soma = soma + Convert.ToInt32(texto.Substring(i, 1)) * peso;
                if (peso == pesoMaximo)
                    peso = 2;
                else
                    peso = peso + 1;
            }
            var resto = soma % 11;
            if (resto <= 1)
                digito = "0";
            else
                digito = (11 - resto).ToString();
            return digito;
        }

        public static string CalcularDVSantander(this string texto)
        {
            string digito;
            int pesoMaximo = 9, soma = 0, peso = 2;
            for (var i = texto.Length - 1; i >= 0; i--)
            {
                soma = soma + Convert.ToInt32(texto.Substring(i, 1)) * peso;
                if (peso == pesoMaximo)
                    peso = 2;
                else
                    peso = peso + 1;
            }
            var resto = soma % 11;
            if (resto <= 1)
                digito = "0";
            else
                digito = (11 - resto).ToString();
            return digito;
        }

        public static string CalcularDVSicoob(this string texto)
        {
            string digito, fatorMultiplicacao = "319731973197319731973";
            int soma = 0;
            for (int i = 0; i < 21; i++)
            {
                soma += Convert.ToInt16(texto.Substring(i, 1)) * Convert.ToInt16(fatorMultiplicacao.Substring(i, 1));
            }
            int resto = (soma % 11);
            if (resto <= 1)
                digito = "0";
            else
                digito = (11 - resto).ToString();
            return digito;
        }

        public static string CalcularDVBradesco(this string texto)
        {
            string digito;
            texto = texto.Trim();
            int pesoMaximo = 7, soma = 0, peso = 2;
            for (var i = texto.Length - 1; i >= 0; i--)
            {
                soma = soma + (int)char.GetNumericValue(texto[i]) * peso;
                if (peso == pesoMaximo)
                    peso = 2;
                else
                    peso = peso + 1;
            }
            var resto = soma % 11;
            switch (resto)
            {
                case 0:
                    digito = "0";
                    break;
                case 1:
                    digito = "P";
                    break;
                default:
                    digito = (11 - resto).ToString();
                    break;
            }
            return digito;
        }

        public static string CalcularDVItau(this string texto)
        {
            string digito;
            int soma = 0, peso = 2, digTmp = 0;
            for (var i = texto.Length - 1; i >= 0; i--)
            {
                digTmp = (int)char.GetNumericValue(texto[i]) * peso;
                if (digTmp > 9)
                    digTmp = (digTmp / 10) + (digTmp % 10);

                soma = soma + digTmp;

                if (peso == 2)
                    peso = 1;
                else
                    peso = peso + 1;
            }
            var resto = (soma % 10);
            if (resto == 0)
                digito = "0";
            else
                digito = (10 - resto).ToString();
            return digito;
        }

        public static string CalcularDVBanestes(this string texto)
        {
            string digito;
            int pesoMaximo = 10, soma = 0, peso = 2;
            for (var i = texto.Length - 1; i >= 0; i--)
            {
                soma = soma + Convert.ToInt32(texto.Substring(i, 1)) * peso;
                if (peso == pesoMaximo)
                    peso = 2;
                else
                    peso = peso + 1;
            }

            var resto = soma % 11;
            if (resto <= 1)
                digito = "0";
            else
                digito = (11 - resto).ToString();
            return digito;
        }

        public static string CalcularDV1ASBACE(this string texto)
        {
            string digito, fatorMultiplicacao = "21212121212121212121212";
            int soma = 0;
            for (int i = 0; i < texto.Length; i++)
            {
                var k = 0;
                var p = Convert.ToInt32(texto.Substring(i, 1)) * Convert.ToInt32(fatorMultiplicacao.Substring(i, 1));
                if (p > 9)
                    k = p - 9;
                else if (p < 10)
                    k = p;

                soma += k;
            }

            int resto = (soma % 10);
            if (resto == 0)
                digito = "0";
            else
                digito = (10 - resto).ToString();
            return digito;
        }

        public static string CheckCalcularDV2ASBACE(this string texto)
        {

            int pesoMaximo = 7, soma = 0, peso = 2;
            for (var i = texto.Length - 1; i >= 0; i--)
            {
                soma = soma + Convert.ToInt32(texto.Substring(i, 1)) * peso;
                if (peso == pesoMaximo)
                    peso = 2;
                else
                    peso = peso + 1;
            }

            var resto = soma % 11;

            var d1 = Convert.ToInt32(texto.Substring(texto.Length - 1, 1));


            if (resto == 1)
            {
                d1 = d1 + 1;
                if (d1 == 10)
                {
                    d1 = 0;
                }
                return d1.ToString();
            }

            return "";
        }

        public static string CalcularDV2ASBACE(this string texto)
        {
            string digito;
            int pesoMaximo = 7, soma = 0, peso = 2;
            for (var i = texto.Length - 1; i >= 0; i--)
            {
                soma = soma + Convert.ToInt32(texto.Substring(i, 1)) * peso;
                if (peso == pesoMaximo)
                    peso = 2;
                else
                    peso = peso + 1;
            }

            var resto = soma % 11;

            var d1 = Convert.ToInt32(texto.Substring(texto.Length - 1, 1));

            if (resto == 0)
            {
                digito = "0";
            }
            else
            {
                digito = (11 - resto).ToString();
            }

            return digito;
        }

    }
}