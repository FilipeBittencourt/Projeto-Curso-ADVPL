#pragma checksum "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Areas\AdminEmpresa\Views\Transportadora\Index.cshtml" "{ff1816ec-aa5e-4d10-87f7-6f4963833460}" "a6cd24d3b27624e4b63fa52e7c929592bc5e84f8"
// <auto-generated/>
#pragma warning disable 1591
[assembly: global::Microsoft.AspNetCore.Razor.Hosting.RazorCompiledItemAttribute(typeof(AspNetCore.Areas_AdminEmpresa_Views_Transportadora_Index), @"mvc.1.0.view", @"/Areas/AdminEmpresa/Views/Transportadora/Index.cshtml")]
[assembly:global::Microsoft.AspNetCore.Mvc.Razor.Compilation.RazorViewAttribute(@"/Areas/AdminEmpresa/Views/Transportadora/Index.cshtml", typeof(AspNetCore.Areas_AdminEmpresa_Views_Transportadora_Index))]
namespace AspNetCore
{
    #line hidden
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.AspNetCore.Mvc.Rendering;
    using Microsoft.AspNetCore.Mvc.ViewFeatures;
#line 1 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Areas\_ViewImports.cshtml"
using Facile.BusinessPortal.Web;

#line default
#line hidden
#line 2 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Areas\_ViewImports.cshtml"
using Microsoft.AspNetCore.Identity;

#line default
#line hidden
#line 3 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Areas\_ViewImports.cshtml"
using Microsoft.Extensions.Options;

#line default
#line hidden
#line 4 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Areas\_ViewImports.cshtml"
using Facile.BusinessPortal.Library;

#line default
#line hidden
#line 5 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Areas\_ViewImports.cshtml"
using Facile.BusinessPortal.ViewModels;

#line default
#line hidden
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"a6cd24d3b27624e4b63fa52e7c929592bc5e84f8", @"/Areas/AdminEmpresa/Views/Transportadora/Index.cshtml")]
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"4f40a4fd222a160b6254cae15e96a46b61c6c1f6", @"/Areas/_ViewImports.cshtml")]
    public class Areas_AdminEmpresa_Views_Transportadora_Index : global::Microsoft.AspNetCore.Mvc.Razor.RazorPage<IEnumerable<Facile.BusinessPortal.Model.Transportadora>>
    {
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_0 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("src", "~/js/Util.js", global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_1 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("src", "~/js/Transportadora.js", global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        #line hidden
        #pragma warning disable 0169
        private string __tagHelperStringValueBuffer;
        #pragma warning restore 0169
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperExecutionContext __tagHelperExecutionContext;
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperRunner __tagHelperRunner = new global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperRunner();
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperScopeManager __backed__tagHelperScopeManager = null;
        private global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperScopeManager __tagHelperScopeManager
        {
            get
            {
                if (__backed__tagHelperScopeManager == null)
                {
                    __backed__tagHelperScopeManager = new global::Microsoft.AspNetCore.Razor.Runtime.TagHelpers.TagHelperScopeManager(StartTagHelperWritingScope, EndTagHelperWritingScope);
                }
                return __backed__tagHelperScopeManager;
            }
        }
        private global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.UrlResolutionTagHelper __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper;
        private global::Microsoft.AspNetCore.Mvc.TagHelpers.ScriptTagHelper __Microsoft_AspNetCore_Mvc_TagHelpers_ScriptTagHelper;
        #pragma warning disable 1998
        public async override global::System.Threading.Tasks.Task ExecuteAsync()
        {
            BeginContext(140, 2, true);
            WriteLiteral("\r\n");
            EndContext();
#line 4 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Areas\AdminEmpresa\Views\Transportadora\Index.cshtml"
  
    ViewData["Title"] = "Lista de Transportadoras";

#line default
#line hidden
            BeginContext(202, 2227, true);
            WriteLiteral(@"
<div class=""row"">
    <div class=""col-xl-12"">
        <div id=""panel-1"" class=""panel"">
            <div class=""panel-hdr"">
                <h2>
                    Transportadoras
                </h2>
                <div class=""panel-toolbar"">
                    <button class=""btn btn-panel"" data-action=""panel-collapse"" data-toggle=""tooltip"" data-offset=""0,10"" data-original-title=""Minimizar""></button>
                    <button class=""btn btn-panel"" data-action=""panel-fullscreen"" data-toggle=""tooltip"" data-offset=""0,10"" data-original-title=""Tela Cheia""></button>
                </div>
            </div>
            <div class=""panel-container show"">
                <div class=""panel-content"">
                    <!-- datatable start -->
                    <!-- class=""bg-highlight""-->
                    <table id=""dt-registro"" class=""table table-bordered table-hover table-striped w-100"">
                        <thead class=""bg-primary-600"">
                            <tr>
         ");
            WriteLiteral(@"                       <th>CPF/CNPJ</th>
                                <th>Codigo ERP</th>
                                <th width=""30%"">Nome</th>
                                <th >E-mail</th>
                                <th>Bairro</th>
                                <th>Cidade</th>
                                <th>UF</th>
                                <th width=""5%"">Ações</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                        <tfoot>
                            <tr>
                                <th></th>
                                <th></th>
                                <th></th>
                                <th></th>
                                <th></th>
                                <th></th>
                                <th></th>
                                <th></th>
                            </tr>
                        </tfoot>
                    </table>");
            WriteLiteral("\r\n                    <!-- datatable end -->\r\n                </div>\r\n            </div>\r\n        </div>\r\n    </div>\r\n</div>\r\n\r\n<input type=\"hidden\" name=\"FieldSearch\" value=\"\">\r\n");
            EndContext();
            DefineSection("Scripts", async() => {
                BeginContext(2447, 6, true);
                WriteLiteral("\r\n    ");
                EndContext();
                BeginContext(2453, 62, false);
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("script", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "a6cd24d3b27624e4b63fa52e7c929592bc5e84f88044", async() => {
                }
                );
                __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.UrlResolutionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper);
                __Microsoft_AspNetCore_Mvc_TagHelpers_ScriptTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.ScriptTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_ScriptTagHelper);
                __Microsoft_AspNetCore_Mvc_TagHelpers_ScriptTagHelper.Src = (string)__tagHelperAttribute_0.Value;
                __tagHelperExecutionContext.AddTagHelperAttribute(__tagHelperAttribute_0);
#line 60 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Areas\AdminEmpresa\Views\Transportadora\Index.cshtml"
__Microsoft_AspNetCore_Mvc_TagHelpers_ScriptTagHelper.AppendVersion = true;

#line default
#line hidden
                __tagHelperExecutionContext.AddTagHelperAttribute("asp-append-version", __Microsoft_AspNetCore_Mvc_TagHelpers_ScriptTagHelper.AppendVersion, global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                EndContext();
                BeginContext(2515, 6, true);
                WriteLiteral("\r\n    ");
                EndContext();
                BeginContext(2521, 72, false);
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("script", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "a6cd24d3b27624e4b63fa52e7c929592bc5e84f810218", async() => {
                }
                );
                __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.UrlResolutionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper);
                __Microsoft_AspNetCore_Mvc_TagHelpers_ScriptTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.ScriptTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_ScriptTagHelper);
                __Microsoft_AspNetCore_Mvc_TagHelpers_ScriptTagHelper.Src = (string)__tagHelperAttribute_1.Value;
                __tagHelperExecutionContext.AddTagHelperAttribute(__tagHelperAttribute_1);
#line 61 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Areas\AdminEmpresa\Views\Transportadora\Index.cshtml"
__Microsoft_AspNetCore_Mvc_TagHelpers_ScriptTagHelper.AppendVersion = true;

#line default
#line hidden
                __tagHelperExecutionContext.AddTagHelperAttribute("asp-append-version", __Microsoft_AspNetCore_Mvc_TagHelpers_ScriptTagHelper.AppendVersion, global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                EndContext();
                BeginContext(2593, 2, true);
                WriteLiteral("\r\n");
                EndContext();
            }
            );
        }
        #pragma warning restore 1998
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public Microsoft.AspNetCore.Http.IHttpContextAccessor HttpContextAccessor { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.ViewFeatures.IModelExpressionProvider ModelExpressionProvider { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IUrlHelper Url { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IViewComponentHelper Component { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IJsonHelper Json { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IHtmlHelper<IEnumerable<Facile.BusinessPortal.Model.Transportadora>> Html { get; private set; }
    }
}
#pragma warning restore 1591
