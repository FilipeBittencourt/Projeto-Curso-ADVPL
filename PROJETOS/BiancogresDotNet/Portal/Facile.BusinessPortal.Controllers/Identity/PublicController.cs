#region Using

using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Linq;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.Collections.Generic;
using Facile.BusinessPortal.Library.Mail;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.ViewModels;
using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.Library.Extensions;
using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.BusinessRules.Util;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Security;
using Microsoft.EntityFrameworkCore;
using Facile.BusinessPortal.BusinessRules;
#endregion

namespace Facile.BusinessPortal.Controllers
{

    [Route("[controller]/[action]")]
    [Layout("_LayoutLogin")]
    public class PublicController : Controller
    {
        private readonly IEmailSender _emailSender;
        private readonly ILogger _logger;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly FBContext _appContext;

        [TempData]
        public string ErrorMessage { get; set; }

        public PublicController(UserManager<ApplicationUser> userManager, SignInManager<ApplicationUser> signInManager, IEmailSender emailSender, ILogger<AccountController> logger, FBContext context)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _emailSender = emailSender;
            _logger = logger;
            _appContext = context;
        }

        public IActionResult Index()
        {
            return View();
        }



        [HttpPost]
        [AllowAnonymous]
        public IActionResult AprovaAntecipacaoEmail(long usuarioid, string chave , long id)
        {
            ViewBag.Mensagem = "";
            try
            {
                var token = _appContext.Token
                             .AsNoTracking().FirstOrDefault(x => x.Chave == chave);
                if (token != null && token.DataHoraVencimento.CompareTo(DateTime.Now) < 0)
                {
                    var usuario = _appContext.Usuario
                            .AsNoTracking().FirstOrDefault(x => x.ID == usuarioid);
                    if (usuario != null)
                    {


                        var antecipacao = _appContext.Antecipacao
                                    .Include(x => x.Unidade)
                                    .Include(x => x.Empresa)
                                    .Include(x => x.Fornecedor)
                                    .Include(x => x.AntecipacaoItem)
                                    .ThenInclude(x => x.TituloPagar)
                                    .FirstOrDefault(x => x.ID == id);
                        if (antecipacao != null)
                        {
                                antecipacao.Status = StatusAntecipacao.Aprovada;
                                AntecipacaoHistorico a = new AntecipacaoHistorico
                                {
                                    EmpresaID = antecipacao.EmpresaID,
                                    Habilitado = true,
                                    InsertDate = DateTime.Now,
                                    AntecipacaoID = antecipacao.ID,
                                    DataEvento = DateTime.Now,
                                    UsuarioID = antecipacao.ID,
                                    Status = StatusAntecipacao.Aprovada,
                                    Observacao = "Aprovação por UsuarioID: " + usuarioid + ", chave: " + chave
                                };

                                _appContext.Entry(antecipacao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                                _appContext.SaveChanges();
                                if (usuario.Tipo == TipoUsuario.Fornecedor)
                                {
                                    //enviar e-mail
                                    //var ResultMail = AntecipacaoMail.NovaAntecipacaoSendMail(_context, Id);
                                    var ResultMail = AntecipacaoMail.AntecipacaoAceitaSendMail(_appContext, antecipacao.ID);
                                }

                            ViewBag.Mensagem = "Antecipação aprovada com sucesso.";
                                return View();
                        }
                        ViewBag.Mensagem = "Antecipação não encontrada.";
                        return View();
                    }
                    ViewBag.Mensagem = "Usuário não encontrado.";
                    return View();
                }
                ViewBag.Mensagem = "Token de aprovação não encontrado.";
                return View();
            }
            catch (Exception ex)
            {
                ViewBag.Mensagem = "Erro na aprovação da antecipação.";
            }
            
            return View();
        }


    }
}
