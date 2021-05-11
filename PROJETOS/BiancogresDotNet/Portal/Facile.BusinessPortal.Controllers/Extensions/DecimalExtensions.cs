using System;

namespace Facile.BusinessPortal.Controllers.Extensions
{
    public static class DecimalExtensions
    {
        public static decimal TruncateEx(this decimal value, int decimalPlaces)
        {
            if (decimalPlaces < 0)
                throw new ArgumentException("decimalPlaces must be greater than or equal to 0.");

            var modifier = Convert.ToDecimal(0.5 / Math.Pow(10, decimalPlaces));
            return Math.Round(value >= 0 ? value - modifier : value + modifier, decimalPlaces);
        }
    }
}
