using System;
using System.Collections.Generic;
using System.Linq;

namespace Facile.BusinessPortal.StageArea.Interface
{
    public class PropertyCopier<TParent, TChild> where TParent : class where TChild : class
    {
        
        public static void Copy(TParent parent, TChild child, string nofields="")
        {
            var parentProperties = parent.GetType().GetProperties();
            var childProperties = child.GetType().GetProperties();

            var ListNot = nofields.Split(',').ToList();

            foreach (var parentProperty in parentProperties)
            {
                foreach (var childProperty in childProperties)
                {
                    if (ListNot.Contains(childProperty.Name))
                    {
                        continue;
                    }

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
