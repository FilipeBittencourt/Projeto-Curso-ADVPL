using Facile.BusinessPortal.Model;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Linq;

using System.Collections.Generic;
using System.Text;
using System.IO;
using Microsoft.DotNet.PlatformAbstractions;

namespace Facile.BusinessPortal.BusinessRules.Session
{
    public static class SessionSettings
    {
        private static IHttpContextAccessor _httpContextAccessor;
        private static FBContext _db;

        public static HttpContext Context => _httpContextAccessor.HttpContext;

        public static void Configure(IHttpContextAccessor httpContextAccessor, FBContext db)
        {
            _httpContextAccessor = httpContextAccessor;
            _db = db;
        }

        public static string Empresa_Nome_Portal
        {
            get
            {
                var value = Context.Session.GetString("s_ResquestURL");
                var emp_value = Context.Session.GetString("e_Descricao_Reduzida_Portal");

                if (string.IsNullOrWhiteSpace(emp_value))
                {
                    var qperfil = from PerfilEmpresa e in _db.PerfilEmpresa.AsNoTracking()
                                  where !string.IsNullOrWhiteSpace(e.URLAcesso) &&
                                  value.Contains(e.URLAcesso.ToLower().Trim())
                                  select e;

                    if (qperfil.Any())
                    {
                        var result = qperfil.First().Descricao_Reduzida_Portal.Trim();
                        Context.Session.SetString("e_Descricao_Reduzida_Portal", result);
                        return result;
                    }
                    else
                        return "Facile Cloud Apps";
                }
                else
                    return emp_value.Trim();
            }
        }

        public static string Empresa_Login_Background_Image
        {
            get
            {
                var value = Context.Session.GetString("s_ResquestURL");
                var emp_value = Context.Session.GetString("e_Login_Background_Image");

                if (string.IsNullOrWhiteSpace(emp_value))
                {
                    var qperfil = from PerfilEmpresa e in _db.PerfilEmpresa.AsNoTracking()
                                  where !string.IsNullOrWhiteSpace(e.URLAcesso) &&
                                  value.Contains(e.URLAcesso.ToLower().Trim())
                                  select e;

                    if (qperfil.Any())
                    {
                        if (!string.IsNullOrWhiteSpace(qperfil.First().Path_Imagem_Background))
                        {
                            var result = qperfil.First().Path_Imagem_Background.Trim();
                            Context.Session.SetString("e_Login_Background_Image", result);
                            return result;
                        }
                        else
                            return string.Empty;
                    }
                    else
                        return string.Empty;
                }
                else
                    return emp_value.Trim();
            }
        }

        public static string Empresa_LogoMini_Image_return
        {
            get
            {
                return Empresa_LogoMini_Image;
            }
        }

        private static string Empresa_LogoMini_Image
        {
            get
            {
                var root = Context.Session.GetString("e_Site_Rootpath");
                if (string.IsNullOrWhiteSpace(root))
                    root = "https://portal.facilecloud.com.br/";

                var value = Context.Session.GetString("s_ResquestURL");
                var emp_value = Context.Session.GetString("e_LogoMini_Image");
                var def_path = "imagens/facile/facile_icon.png";
                var basePath = ApplicationEnvironment.ApplicationBasePath;

                if (string.IsNullOrWhiteSpace(emp_value))
                {
                    var qperfil = from PerfilEmpresa e in _db.PerfilEmpresa
                                  where !string.IsNullOrWhiteSpace(e.URLAcesso) &&
                                  value.Contains(e.URLAcesso.ToLower().Trim())
                                  select e;

                    if (qperfil.Any())
                    {
                        var cempresa = qperfil.First().Empresa.Codigo.Trim();

                        root = qperfil.First().Site_Root_Path.Trim();
                        Context.Session.SetString("e_Site_Rootpath", root);

                        var rpath = $"empresas/{cempresa}/imagens/logo_mini.png";

                        var pathi = Path.Combine(basePath, rpath);
                                                
                        Context.Session.SetString("e_LogoMini_Image", rpath);

                        return root + rpath;
                    }
                    else
                        return root + def_path;
                }
                else
                    return root + emp_value.Trim();
            }
        }

        public static string Empresa_Theme_Path
        {
            get
            {
                var deftheme = "/smartadmin/css/themes/cust-theme-1.css";

                var value = Context.Session.GetString("s_ResquestURL");
                var emp_value = Context.Session.GetString("e_Theme_Path");

                if (string.IsNullOrWhiteSpace(emp_value))
                {
                    var qperfil = from PerfilEmpresa e in _db.PerfilEmpresa.AsNoTracking()
                                  where !string.IsNullOrWhiteSpace(e.URLAcesso) &&
                                  value.Contains(e.URLAcesso.ToLower().Trim())
                                  select e;

                    if (qperfil.Any())
                    {
                        var idtema = qperfil.First().ThemeID ?? 0;

                        if (idtema > 0)
                        {
                            var theme = from Theme t in _db.Theme.AsNoTracking()
                                        where t.ID == idtema
                                        select t;

                            if (theme.Any())
                            {
                                Context.Session.SetString("e_Theme_Path", theme.First().CssPath);
                                return theme.First().CssPath;
                            }
                            else
                                return deftheme;

                        }
                        return deftheme;
                    }
                    else
                        return deftheme;
                }
                else
                    return emp_value.Trim();
            }
        }

        public static string Empresa_Welcome_Message
        {
            get
            {
                var defresult = "Plataforma de ferramentas e aplicativos coorporativos para agilizar os processos e integração da sua empresa, clientes, fornecedores, representantes e outros parceiros.";

                var value = Context.Session.GetString("s_ResquestURL");
                var emp_value = Context.Session.GetString("e_Welcome_Message");

                if (string.IsNullOrWhiteSpace(emp_value))
                {
                    var qperfil = from PerfilEmpresa e in _db.PerfilEmpresa.AsNoTracking()
                                  where !string.IsNullOrWhiteSpace(e.URLAcesso) &&
                                  value.Contains(e.URLAcesso.ToLower().Trim())
                                  select e;

                    if (qperfil.Any())
                    {
                        var mensagem = qperfil.First().MensagemBoasVindas;

                        if (!string.IsNullOrWhiteSpace(mensagem))
                        {
                            Context.Session.SetString("e_Welcome_Message", mensagem);
                            return mensagem;
                        }
                        return defresult;
                    }
                    else
                        return defresult;
                }
                else
                    return emp_value.Trim();
            }
        }

        public static string CurrentUserName
        {
            get
            {
                var value = Context.Session.GetString("u_username");
                return value;
            }
        }

        public static string CurrentUserEmail
        {
            get
            {
                var value = Context.Session.GetString("u_email");
                return value;
            }
        }
    }
}
