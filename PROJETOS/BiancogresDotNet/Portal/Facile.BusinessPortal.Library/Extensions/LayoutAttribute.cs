#region Using

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

#endregion

namespace Facile.BusinessPortal.Library.Extensions
{
    /// <summary>
    ///     Provides the ability to override the chosen layout for actions.
    /// </summary>
    /// <remarks>
    ///     The layout value will be resolved in the '/Views/Shared/' folder.
    /// </remarks>
    public class LayoutAttribute : ResultFilterAttribute
    {
        /// <summary>
        ///     Specifies the file that will be loaded as the main layout for the rendered view.
        /// </summary>
        public string Layout { get; set; }

        /// <summary>
        ///     Initialize the attribute with the specified <paramref name="layout" /> files to be used for rendering view pages.
        /// </summary>
        /// <param name="layout"></param>
        public LayoutAttribute(string layout) => Layout = layout;

        public override void OnResultExecuting(ResultExecutingContext context)
        {
            // We only want to attempt to override if the know this call is for rendering the view
            if (context.Result is ViewResult viewResult)
            {
                // Set the Layout value to whatever was passed in
                viewResult.ViewData["Layout"] = Layout;
            }
        }
    }
}
