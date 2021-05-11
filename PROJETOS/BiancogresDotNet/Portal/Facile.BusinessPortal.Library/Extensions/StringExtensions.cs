using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.BusinessPortal.Library.Extensions
{
    public static class StringExtensions
    {
        public static string Right(this string value, int length)
        {
            if (String.IsNullOrEmpty(value))
                return string.Empty;
            return value.Length <= length ? value : value.Substring(value.Length - length);
        }
        public static string Left(this string value, int length)
        {
            if (String.IsNullOrEmpty(value))
                return string.Empty;
            return value.Length <= length ? value : value.Substring(0, length);
        }
    }
}
