using System;
using System.Collections.Generic;
using System.Text;

namespace Facile.BusinessPortal.Library.Util
{
    public class PropertyCopier<TParent, TChild> where TParent : class where TChild : class
    {
        public static void Copy(TParent parent, TChild child)
        {
            var parentProperties = parent.GetType().GetProperties();
            var childProperties = child.GetType().GetProperties();

            foreach (var parentProperty in parentProperties)
            {
                foreach (var childProperty in childProperties)
                {
                    if (parentProperty.Name == childProperty.Name && parentProperty.PropertyType == childProperty.PropertyType)
                    {
                        Object content;

                        if (child.GetType() == typeof(String))
                        {
                            content = parentProperty.GetValue(parent).ToString().Trim();
                        }
                        else
                            content = parentProperty.GetValue(parent);

                        childProperty.SetValue(child, content);

                        break;
                    }
                }
            }
        }
    }
}
