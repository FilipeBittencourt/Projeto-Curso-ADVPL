using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.BusinessPortal.Library.Util
{
    public static class DataUtil
    {
        public static string DateTimeToDots(DateTime date)
        {
            return date.ToString("dd.MM.yyyy");
        }

        public static string DateTimeToStrBR(DateTime? date)
        {
            if (date.HasValue)
                return date.Value.ToString("dd/MM/yyyy");
            else
                return string.Empty;
        }

        public static DateTime StringDateToBR(string Data)
        {

            var dt = Data.Substring(6, 4) + '-' + Data.Substring(3, 2) + '-' + Data.Substring(0, 2);
            return Convert.ToDateTime(dt);

        }

        public static string DateTimeToHora(DateTime? date)
        {
            if (date.HasValue)
                return date.Value.Hour.ToString().PadLeft(2, '0') + ":" + date.Value.Minute.ToString().PadLeft(2, '0') + ":" + date.Value.Second.ToString().PadLeft(2, '0');
            else
                return string.Empty;
        }

        public static string DateToSql(DateTime? date)
        {
            if (date.HasValue)
                return string.Empty;
            else
                return date.Value.Year.ToString().PadLeft(4, '0') + date.Value.Month.ToString().PadLeft(2, '0') + date.Value.Day.ToString().PadLeft(2, '0');
        }

        public static DateTime SQLToDate(string value)
        {
            try
            {
                int ano = Convert.ToInt32(value.Substring(0, 4));
                int mes = Convert.ToInt32(value.Substring(4, 2));
                int dia = Convert.ToInt32(value.Substring(6, 2));
                return new DateTime(ano, mes, dia);
            }
            catch
            {
                return new DateTime(1, 1, 1);
            }
        }

        public static DateTime GetCurrentOrNextWorkingDay(DateTime date)
        {
            while (IsHoliday(date) || IsWeekEnd(date))
            {
                date = date.AddDays(1);
            }

            return date;
        }

        public static bool IsWeekEnd(DateTime date)
        {
            return date.DayOfWeek == DayOfWeek.Saturday
                || date.DayOfWeek == DayOfWeek.Sunday;
        }


        private static bool IsHoliday(DateTime date)
        {
            var Holidays = new List<DateTime>();
            Holidays.Add(new DateTime(DateTime.Now.Year, 1, 1));
            Holidays.Add(new DateTime(DateTime.Now.Year, 5, 1));
            Holidays.Add(new DateTime(DateTime.Now.Year, 9, 7));
            Holidays.Add(new DateTime(DateTime.Now.Year, 11, 15));
            Holidays.Add(new DateTime(DateTime.Now.Year, 12, 25));

            return Holidays.Contains(date);
        }

    }
}
