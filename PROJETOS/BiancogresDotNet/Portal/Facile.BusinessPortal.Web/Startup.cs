using Facile.BusinessPortal.BusinessRules.Session;
using Facile.BusinessPortal.Controllers;
using Facile.BusinessPortal.Library.Mail;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.Web.IdentityPolicy;
using Facile.BusinessPortal.Web.Middleware;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Reflection;

namespace Facile.BusinessPortal.Web
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.Configure<CookiePolicyOptions>(options =>
            {
                // This lambda determines whether user consent for non-essential cookies is needed for a given request.
                options.CheckConsentNeeded = context => true;
                options.MinimumSameSitePolicy = SameSiteMode.None;
            });

            services.AddDbContextPool<FBContext>(options => options
                .UseLazyLoadingProxies()
                .UseSqlServer(Configuration.GetConnectionString("DefaultConnection")));

            services.AddAuthentication().AddCookie(options =>
            {
                options.Cookie.Expiration = TimeSpan.FromMinutes(10);
                options.Cookie.SameSite = SameSiteMode.Strict;
                options.Cookie.Name = "Facile.BusinessPortal.Web";
                options.LoginPath = "/Account/Login";
                options.AccessDeniedPath = "/Account/Forbidden";
            });

            services.Configure<FormOptions>(options =>
            {
                options.ValueCountLimit = 6000; 
                options.ValueLengthLimit = 1024 * 1024 * 100; // 100MB max len form data
            });

            services.AddScoped<RestrictAccessAttribute>();

            services.AddTransient<IPasswordValidator<ApplicationUser>, CustomPasswordPolicy>();

            services.AddIdentity<ApplicationUser, IdentityRole>(options =>
            {
                options.User.RequireUniqueEmail = false;
                options.Lockout.AllowedForNewUsers = true;
                options.SignIn.RequireConfirmedEmail = true;
                options.Lockout.MaxFailedAccessAttempts = 10;
                options.Password.RequiredLength = 6;
                options.Password.RequireNonAlphanumeric = false;
                options.Password.RequireUppercase = false;
                options.Password.RequireLowercase = false;
            })
           .AddEntityFrameworkStores<FBContext>()
           .AddDefaultTokenProviders();

            services.AddTransient<IEmailSender, EmailSender>();

            //services.AddDefaultIdentity<IdentityUser>()
            //.AddDefaultUI(UIFramework.Bootstrap4)
            //    .AddEntityFrameworkStores<FBContext>();

            var AssemblyControllers = Assembly.Load("Facile.BusinessPortal.Controllers");
            services.AddMvc().AddApplicationPart(AssemblyControllers).AddControllersAsServices();
            services.AddMvc().AddControllersAsServices();

            services.AddSession(options =>
            {
                options.Cookie.HttpOnly = true;
                options.Cookie.IsEssential = true;
                options.IdleTimeout = TimeSpan.FromMinutes(30);
            });

            // We allow our routes to be in lowercase
            services.AddRouting(options => options.LowercaseUrls = true);
            services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_2);

            //Para acesso ao Context
            services.AddHttpContextAccessor();

            services.AddHttpsRedirection(options =>
            {
                options.RedirectStatusCode = StatusCodes.Status308PermanentRedirect;
                options.HttpsPort = 443;
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            //if (env.IsDevelopment())
            //{
            //    app.UseDeveloperExceptionPage();
            //    app.UseDatabaseErrorPage();
            //}
            //else
            //{
            //    app.UseExceptionHandler("/Home/Error");
            //    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
            //    app.UseHsts();
            //}

            var cultureInfo = new CultureInfo("pt-BR");
            cultureInfo.NumberFormat.CurrencySymbol = "R$";
            cultureInfo.NumberFormat.NumberDecimalSeparator = ",";
            cultureInfo.NumberFormat.CurrencyDecimalSeparator = ",";

            CultureInfo.DefaultThreadCurrentCulture = cultureInfo;
            CultureInfo.DefaultThreadCurrentUICulture = cultureInfo;

            // Configure the Localization middleware
            app.UseRequestLocalization(new RequestLocalizationOptions
            {
                DefaultRequestCulture = new RequestCulture(cultureInfo),
                SupportedCultures = new List<CultureInfo>
                {
                    cultureInfo,
                },
                            SupportedUICultures = new List<CultureInfo>
                {
                    cultureInfo,
                }
            });

            app.UseSession();

            using (var serviceScope = app.ApplicationServices.CreateScope())
            {
                var context = serviceScope.ServiceProvider.GetService<FBContext>();

                SessionSettings.Configure(app.ApplicationServices.GetRequiredService<IHttpContextAccessor>(), context);
            }

            app.UseHttpsRedirection();

            app.UseStaticFiles();
            app.UseCookiePolicy();

            app.UseAuthentication();

            // add logging middleware
            app.UseMiddleware<LogResponseMiddleware>();
            app.UseMiddleware<LogRequestMiddleware>();

            app.UseMvc(routes =>
            {
                routes.MapRoute(
                     name: "MyArea",
                     template: "{area:exists}/{controller=Home}/{action=Index}/{id?}");

                routes.MapRoute(
                    name: "default",
                    template: "{controller=Home}/{action=Index}/{id?}");
            });
        }
    }
}
