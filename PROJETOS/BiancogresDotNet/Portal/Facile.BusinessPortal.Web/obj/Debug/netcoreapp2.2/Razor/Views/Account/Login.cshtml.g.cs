#pragma checksum "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml" "{ff1816ec-aa5e-4d10-87f7-6f4963833460}" "cec175a0a5bb764282f16cef85f9f70db988d00f"
// <auto-generated/>
#pragma warning disable 1591
[assembly: global::Microsoft.AspNetCore.Razor.Hosting.RazorCompiledItemAttribute(typeof(AspNetCore.Views_Account_Login), @"mvc.1.0.view", @"/Views/Account/Login.cshtml")]
[assembly:global::Microsoft.AspNetCore.Mvc.Razor.Compilation.RazorViewAttribute(@"/Views/Account/Login.cshtml", typeof(AspNetCore.Views_Account_Login))]
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
#line 1 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\_ViewImports.cshtml"
using Facile.BusinessPortal.Web;

#line default
#line hidden
#line 2 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\_ViewImports.cshtml"
using Microsoft.AspNetCore.Identity;

#line default
#line hidden
#line 3 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\_ViewImports.cshtml"
using Microsoft.Extensions.Options;

#line default
#line hidden
#line 4 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\_ViewImports.cshtml"
using Facile.BusinessPortal.Library;

#line default
#line hidden
#line 5 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\_ViewImports.cshtml"
using Facile.BusinessPortal.ViewModels;

#line default
#line hidden
#line 2 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml"
using Facile.BusinessPortal.BusinessRules.Session;

#line default
#line hidden
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"cec175a0a5bb764282f16cef85f9f70db988d00f", @"/Views/Account/Login.cshtml")]
    [global::Microsoft.AspNetCore.Razor.Hosting.RazorSourceChecksumAttribute(@"SHA1", @"4f40a4fd222a160b6254cae15e96a46b61c6c1f6", @"/Views/_ViewImports.cshtml")]
    public class Views_Account_Login : global::Microsoft.AspNetCore.Mvc.Razor.RazorPage<LoginViewModel>
    {
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_0 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("asp-action", "ForgotPassword", global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_1 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("id", new global::Microsoft.AspNetCore.Html.HtmlString("js-login"), global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_2 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("novalidate", new global::Microsoft.AspNetCore.Html.HtmlString(""), global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_3 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("asp-controller", "Account", global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_4 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("asp-action", "Login", global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_5 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("method", "post", global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_6 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("src", new global::Microsoft.AspNetCore.Html.HtmlString("~/smartadmin/js/vendors.bundle.js"), global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
        private static readonly global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute __tagHelperAttribute_7 = new global::Microsoft.AspNetCore.Razor.TagHelpers.TagHelperAttribute("src", new global::Microsoft.AspNetCore.Html.HtmlString("~/smartadmin/js/app.bundle.js"), global::Microsoft.AspNetCore.Razor.TagHelpers.HtmlAttributeValueStyle.DoubleQuotes);
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
        private global::Microsoft.AspNetCore.Mvc.TagHelpers.FormTagHelper __Microsoft_AspNetCore_Mvc_TagHelpers_FormTagHelper;
        private global::Microsoft.AspNetCore.Mvc.TagHelpers.RenderAtEndOfFormTagHelper __Microsoft_AspNetCore_Mvc_TagHelpers_RenderAtEndOfFormTagHelper;
        private global::Microsoft.AspNetCore.Mvc.TagHelpers.AnchorTagHelper __Microsoft_AspNetCore_Mvc_TagHelpers_AnchorTagHelper;
        private global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.UrlResolutionTagHelper __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper;
        #pragma warning disable 1998
        public async override global::System.Threading.Tasks.Task ExecuteAsync()
        {
            BeginContext(157, 599, true);
            WriteLiteral(@"
<div class=""page-wrapper"">
    <div class=""page-inner bg-brand-gradient"">
        <div class=""page-content-wrapper bg-transparent m-0"">
            <div class=""height-10 w-100 shadow-lg px-4 bg-brand-gradient"">
                <div class=""d-flex align-items-center container p-0"">
                    <div class=""page-logo width-mobile-auto m-0 align-items-center justify-content-center p-0 bg-transparent bg-img-none shadow-0 height-9"">
                        <a href=""javascript:void(0)"" class=""page-logo-link press-scale-down d-flex align-items-center"">
                            <img");
            EndContext();
            BeginWriteAttribute("src", " src=\"", 756, "\"", 818, 1);
#line 12 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml"
WriteAttributeValue("", 762, Html.Raw(SessionSettings.Empresa_LogoMini_Image_return), 762, 56, false);

#line default
#line hidden
            EndWriteAttribute();
            BeginContext(819, 104, true);
            WriteLiteral(" alt=\"Icon\" aria-roledescription=\"logo\">\r\n                            <span class=\"page-logo-text mr-1\">");
            EndContext();
            BeginContext(924, 45, false);
#line 13 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml"
                                                         Write(Html.Raw(SessionSettings.Empresa_Nome_Portal));

#line default
#line hidden
            EndContext();
            BeginContext(969, 142, true);
            WriteLiteral("</span>\r\n                        </a>\r\n                    </div>\r\n                </div>\r\n            </div>\r\n            <div class=\"flex-1\"");
            EndContext();
            BeginWriteAttribute("style", " style=\"", 1111, "\"", 1248, 10);
            WriteAttributeValue("", 1119, "background:", 1119, 11, true);
            WriteAttributeValue(" ", 1130, "url(", 1131, 5, true);
#line 18 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml"
WriteAttributeValue("", 1135, Html.Raw(SessionSettings.Empresa_Login_Background_Image), 1135, 57, false);

#line default
#line hidden
            WriteAttributeValue("", 1192, ")", 1192, 1, true);
            WriteAttributeValue(" ", 1193, "no-repeat", 1194, 10, true);
            WriteAttributeValue(" ", 1203, "center", 1204, 7, true);
            WriteAttributeValue(" ", 1210, "bottom", 1211, 7, true);
            WriteAttributeValue(" ", 1217, "fixed;", 1218, 7, true);
            WriteAttributeValue(" ", 1224, "background-size:", 1225, 17, true);
            WriteAttributeValue(" ", 1241, "cover;", 1242, 7, true);
            EndWriteAttribute();
            BeginContext(1249, 409, true);
            WriteLiteral(@">
                <div class=""container py-4 py-lg-5 my-lg-5 px-4 px-sm-0"">
                    <div class=""row"">
                        <div class=""col col-md-6 col-lg-7 hidden-sm-down"">
                            <h2 class=""fs-xxl fw-500 mt-4 text-white bg-brand-gradient"" style=""opacity: 0.8"">
                                <small class=""h3 fw-300 mt-3 mb-5"">
                                    ");
            EndContext();
            BeginContext(1659, 49, false);
#line 24 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml"
                               Write(Html.Raw(SessionSettings.Empresa_Welcome_Message));

#line default
#line hidden
            EndContext();
            BeginContext(1708, 846, true);
            WriteLiteral(@"
                                </small>
                            </h2>
                            <a href=""#"" class=""fs-lg fw-500 text-white opacity-70""></a>
                            <div class=""d-sm-flex flex-column align-items-center justify-content-center d-md-block"">
                                <div class=""px-0 py-1 mt-5 text-white fs-nano opacity-50"">

                                </div>
                            </div>
                        </div>
                        <div class=""col-sm-12 col-md-6 col-lg-5 col-xl-4 ml-auto"">
                            <h1 class=""text-white fw-300 mb-3 d-sm-block d-md-none"">
                                Login Usuário
                            </h1>
                            <div class=""card p-4 rounded-plus bg-faded"">
                                ");
            EndContext();
            BeginContext(2554, 3474, false);
            __tagHelperExecutionContext = __tagHelperScopeManager.Begin("form", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "cec175a0a5bb764282f16cef85f9f70db988d00f12220", async() => {
                BeginContext(2646, 1121, true);
                WriteLiteral(@"
                                    <div class=""form-group"">
                                        <label class=""form-label"" for=""username"">Usuário/CNPJ</label>
                                        <input name=""Usuario"" type=""text"" id=""usuario"" class=""form-control form-control-lg"" placeholder=""digite seu Usuário/CNPJ"" value="""" required>
                                        <div class=""invalid-feedback"">Usuário/CNPJ obrigatório.</div>
                                        <div class=""help-block""></div>
                                    </div>
                                    <div class=""form-group"">
                                        <label class=""form-label"" for=""password"">Senha</label>
                                        <input name=""Password"" type=""password"" id=""password"" class=""form-control form-control-lg"" placeholder=""digite sua senha"" value="""" required>
                                        <div class=""invalid-feedback"">Senha obrigatória.</div>
                     ");
                WriteLiteral("                   <div class=\"help-block\"></div>\r\n                                    </div>\r\n\r\n");
                EndContext();
#line 53 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml"
                                     if (ViewBag.IsEmailConfirmed != null && !(bool)ViewBag.IsEmailConfirmed)
                                    {

#line default
#line hidden
                BeginContext(3917, 407, true);
                WriteLiteral(@"                                        <div class=""form-group"">
                                            <label class=""form-label"" for=""password"">Token</label>
                                            <input name=""Token"" type=""text"" id=""token"" class=""form-control form-control-lg"" placeholder=""digite o token recebido por e-mail"" value="""" required>
                                        </div>
");
                EndContext();
#line 59 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml"
                                    }

                                    

#line default
#line hidden
                BeginContext(4882, 36, true);
                WriteLiteral("                                    ");
                EndContext();
#line 67 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml"
                                     if (Context.Request != null)
                                    {

#line default
#line hidden
                BeginContext(4988, 66, true);
                WriteLiteral("                                        <div class=\"form-group\">\r\n");
                EndContext();
#line 70 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml"
                                              
                                                var reterros = Context.Request.Query["reterros"];
                                                

#line default
#line hidden
                BeginContext(5250, 18, false);
#line 72 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml"
                                           Write(Html.Raw(reterros));

#line default
#line hidden
                EndContext();
                BeginContext(5317, 48, true);
                WriteLiteral("                                        </div>\r\n");
                EndContext();
#line 75 "D:\Trabalho\Repositories\GitHub\_MeusProjetos\Projeto-Curso-ADVPL\PROJETOS\BiancogresDotNet\Portal\Facile.BusinessPortal.Web\Views\Account\Login.cshtml"
                                    }

#line default
#line hidden
                BeginContext(5404, 485, true);
                WriteLiteral(@"                                    <div class=""row no-gutters"">
                                        <div class=""col-lg-12 pr-lg-1 my-2"">
                                            <button type=""submit"" id=""js-login-btn"" class=""btn btn-primary btn-block btn-lg"">Acessar</button>
                                        </div>
                                    </div>
                                    <div class=""row no-gutters"">
                                        ");
                EndContext();
                BeginContext(5889, 54, false);
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("a", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "cec175a0a5bb764282f16cef85f9f70db988d00f17348", async() => {
                    BeginContext(5920, 19, true);
                    WriteLiteral("Esqueci minha senha");
                    EndContext();
                }
                );
                __Microsoft_AspNetCore_Mvc_TagHelpers_AnchorTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.AnchorTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_AnchorTagHelper);
                __Microsoft_AspNetCore_Mvc_TagHelpers_AnchorTagHelper.Action = (string)__tagHelperAttribute_0.Value;
                __tagHelperExecutionContext.AddTagHelperAttribute(__tagHelperAttribute_0);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                EndContext();
                BeginContext(5943, 78, true);
                WriteLiteral("\r\n                                    </div>\r\n                                ");
                EndContext();
            }
            );
            __Microsoft_AspNetCore_Mvc_TagHelpers_FormTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.FormTagHelper>();
            __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_FormTagHelper);
            __Microsoft_AspNetCore_Mvc_TagHelpers_RenderAtEndOfFormTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.TagHelpers.RenderAtEndOfFormTagHelper>();
            __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_TagHelpers_RenderAtEndOfFormTagHelper);
            __tagHelperExecutionContext.AddHtmlAttribute(__tagHelperAttribute_1);
            __tagHelperExecutionContext.AddHtmlAttribute(__tagHelperAttribute_2);
            __Microsoft_AspNetCore_Mvc_TagHelpers_FormTagHelper.Controller = (string)__tagHelperAttribute_3.Value;
            __tagHelperExecutionContext.AddTagHelperAttribute(__tagHelperAttribute_3);
            __Microsoft_AspNetCore_Mvc_TagHelpers_FormTagHelper.Action = (string)__tagHelperAttribute_4.Value;
            __tagHelperExecutionContext.AddTagHelperAttribute(__tagHelperAttribute_4);
            __Microsoft_AspNetCore_Mvc_TagHelpers_FormTagHelper.Method = (string)__tagHelperAttribute_5.Value;
            __tagHelperExecutionContext.AddTagHelperAttribute(__tagHelperAttribute_5);
            await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
            if (!__tagHelperExecutionContext.Output.IsContentModified)
            {
                await __tagHelperExecutionContext.SetOutputContentAsync();
            }
            Write(__tagHelperExecutionContext.Output);
            __tagHelperExecutionContext = __tagHelperScopeManager.End();
            EndContext();
            BeginContext(6028, 537, true);
            WriteLiteral(@"
                            </div>
                        </div>
                    </div>
                    <div class=""position-absolute pos-bottom pos-left pos-right p-3 text-center text-white"">
                        2019 © Facile Cloud Apps by&nbsp;<a href=""https://www.facilesistemas.com.br"" class=""text-white opacity-40 fw-500"" title=""www.facilesistemas.com.br"" target=""_blank"">www.facilesistemas.com.br</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

");
            EndContext();
            DefineSection("Scripts", async() => {
                BeginContext(6583, 6, true);
                WriteLiteral("\r\n    ");
                EndContext();
                BeginContext(6589, 57, false);
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("script", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "cec175a0a5bb764282f16cef85f9f70db988d00f21462", async() => {
                }
                );
                __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.UrlResolutionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper);
                __tagHelperExecutionContext.AddHtmlAttribute(__tagHelperAttribute_6);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                EndContext();
                BeginContext(6646, 6, true);
                WriteLiteral("\r\n    ");
                EndContext();
                BeginContext(6652, 53, false);
                __tagHelperExecutionContext = __tagHelperScopeManager.Begin("script", global::Microsoft.AspNetCore.Razor.TagHelpers.TagMode.StartTagAndEndTag, "cec175a0a5bb764282f16cef85f9f70db988d00f22718", async() => {
                }
                );
                __Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper = CreateTagHelper<global::Microsoft.AspNetCore.Mvc.Razor.TagHelpers.UrlResolutionTagHelper>();
                __tagHelperExecutionContext.Add(__Microsoft_AspNetCore_Mvc_Razor_TagHelpers_UrlResolutionTagHelper);
                __tagHelperExecutionContext.AddHtmlAttribute(__tagHelperAttribute_7);
                await __tagHelperRunner.RunAsync(__tagHelperExecutionContext);
                if (!__tagHelperExecutionContext.Output.IsContentModified)
                {
                    await __tagHelperExecutionContext.SetOutputContentAsync();
                }
                Write(__tagHelperExecutionContext.Output);
                __tagHelperExecutionContext = __tagHelperScopeManager.End();
                EndContext();
                BeginContext(6705, 449, true);
                WriteLiteral(@"
    <script>
        $(""#js-login-btn"").click(function (event) {

            // Fetch form to apply custom Bootstrap validation
            var form = $(""#js-login"")


            if (form[0].checkValidity() === false) {
                event.preventDefault()
                event.stopPropagation()
            }

            form.addClass('was-validated');
            // Perform ajax submit here...
        });

    </script>
");
                EndContext();
            }
            );
        }
        #pragma warning restore 1998
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public SignInManager<Facile.BusinessPortal.Model.ApplicationUser> SignInManager { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.ViewFeatures.IModelExpressionProvider ModelExpressionProvider { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IUrlHelper Url { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.IViewComponentHelper Component { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IJsonHelper Json { get; private set; }
        [global::Microsoft.AspNetCore.Mvc.Razor.Internal.RazorInjectAttribute]
        public global::Microsoft.AspNetCore.Mvc.Rendering.IHtmlHelper<LoginViewModel> Html { get; private set; }
    }
}
#pragma warning restore 1591
