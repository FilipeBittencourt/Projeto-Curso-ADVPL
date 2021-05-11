using System.IO;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Extensions;
using System;
using System.Linq;

namespace Facile.BusinessPortal.Web.Middleware
{
    public class LogRequestMiddleware
    {
        private readonly RequestDelegate next;
        private readonly ILogger<LogRequestMiddleware> _logger;
        private readonly Func<string, Exception, string> _defaultFormatter = (state, exception) => state;

        public LogRequestMiddleware(RequestDelegate next, ILogger<LogRequestMiddleware> logger)
        {
            this.next = next;
            _logger = logger;
        }

        public async Task Invoke(HttpContext context)
        {
            var requestBodyStream = new MemoryStream();
            var originalRequestBody = context.Request.Body;

            await context.Request.Body.CopyToAsync(requestBodyStream);
            requestBodyStream.Seek(0, SeekOrigin.Begin);

            var url = UriHelper.GetDisplayUrl(context.Request);

            string usuario = string.Empty;
            if (context.Request.HttpContext.User != null)
            {
                if (context.Request.HttpContext.User.Claims != null && context.Request.HttpContext.User.Claims.Count() > 0)
                {
                    usuario = context.Request.HttpContext.User.Claims.First().Value;
                }
            }

            var remoteIpAddress = context.Request.HttpContext.Connection.RemoteIpAddress != null ? context.Request.HttpContext.Connection.RemoteIpAddress.ToString() : string.Empty;

            var requestBodyText = new StreamReader(requestBodyStream).ReadToEnd();

            _logger.Log(LogLevel.Information, 1, $"REQUEST METHOD: {context.Request.Method}, REQUEST BODY: {requestBodyText}, REQUEST URL: {url}", null, _defaultFormatter);

            //Variaveis de sessao da REQUEST para uso em VIEWS/Controllers
            context.Session.SetString("s_ResquestURL", url);


            //Nao salvar Logs de tentativas de authenticacao
            /*if (!(url.Contains(@"Access/Authenticate")))
            {
                var idLog = LogControl.SaveLogApi(null, 0, 0, usuario, string.Empty, remoteIpAddress, context.Request.Method, requestBodyText, url);
                context.Session.SetString("s_idLogRequest", idLog.ToString());
            }*/

            context.Session.SetString("s_lastRequestBody", requestBodyText);

            requestBodyStream.Seek(0, SeekOrigin.Begin);
            context.Request.Body = requestBodyStream;

            await next(context);
            context.Request.Body = originalRequestBody;
        }
    }
}