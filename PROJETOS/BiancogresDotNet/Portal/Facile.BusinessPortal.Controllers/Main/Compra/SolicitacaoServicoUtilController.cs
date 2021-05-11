using Facile.BusinessPortal.BusinessRules.Compra.SolicitacaoServico;
using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.Controllers.Extensions;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.Model.Compra.Servico;
using Facile.BusinessPortal.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("Compra")]
    public class SolicitacaoServicoUtilController : BaseCommonController<Model.Compra.Servico.SolicitacaoServico>
    {
        public SolicitacaoServicoUtilController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {

        }

        public IActionResult GetProduto(string q)
        {
            var Result = _context.Produto.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                (x.Codigo.Contains(q) || x.Descricao.Contains(q) || x.ClassificacaoFiscal.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Codigo = x.Codigo,
                                 Nome = x.Descricao,
                                 ClassificacaoFiscal = x.ClassificacaoFiscal
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public IActionResult GetCliente(string q)
        {
            var Result = _context.Sacado.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                (x.CodigoERP.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.CodigoERP,
                                 Codigo = x.CodigoERP
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public IActionResult GetDriver(string q, long ClasseValorID)
        {
            var Result = _context.Driver.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                x.ClasseValorID == ClasseValorID &&
                                (x.Codigo.Contains(q) || x.Descricao.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Codigo = x.Codigo,
                                 Descricao = x.Descricao
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public IActionResult GetTag(string q, long ClasseValorID)
        {
            var Result = _context.TAG.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                x.ClasseValorID == ClasseValorID &&
                                (x.Codigo.Contains(q) || x.Descricao.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Codigo = x.Codigo,
                                 Descricao = x.Descricao
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public IActionResult GetContaContabil(string q)
        {
            var Result = _context.ContaContabil.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                (x.Codigo.Contains(q) || x.Descricao.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Codigo = x.Codigo,
                                 Descricao = x.Descricao
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public IActionResult GetContrato(string q)
        {
            var Result = _context.Contrato.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                (x.Codigo.Contains(q) || x.Descricao.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Codigo = x.Codigo,
                                 Descricao = x.Descricao
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public IActionResult GetItemConta(string q)
        {
            var Result = _context.ItemConta.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                (x.Codigo.Contains(q) || x.Descricao.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Codigo = x.Codigo,
                                 Descricao = x.Descricao
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public IActionResult GetSetorAprovacao(string q, long ClasseValorID)
        {
            var Result = _context.SetorAprovacao.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                x.ClasseValorID == ClasseValorID &&
                                (x.Codigo.Contains(q) || x.Descricao.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Codigo = x.Codigo,
                                 Descricao = x.Descricao
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public IActionResult GetSubItemConta(string q, long ClasseValorID, long ItemContaID)
        {
            var Result = _context.SubItemConta.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                x.ClasseValorID == ClasseValorID &&
                                x.ItemContaID == ItemContaID &&
                                (x.Codigo.Contains(q) || x.Descricao.Contains(q))
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Codigo = x.Codigo,
                                 Descricao = x.Descricao
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }

        public IActionResult GetUsuario(string q)
        {
            var Result = _context.Usuario.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                (x.Tipo == TipoUsuario.AdminEmpresa) &&
                                 x.Nome.Contains(q)
                                ).
                            Select(x =>
                             new
                             {
                                 Id = x.ID,
                                 Nome = x.Nome
                             }
                            ).Take(30);

            return new JsonResult(new { items = Result, total_count = Result.Count() });
        }



        [ServiceFilter(typeof(RestrictAccessAttribute))]
        public virtual IActionResult UsuarioMedicao(long Id)
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (usuario != null)
            {
                var SolicitacaoServico = _context.SolicitacaoServico.
                                           Where(x =>
                                               x.EmpresaID == _empresaId &&
                                               x.Habilitado &&
                                               x.ID == Id
                                               ).FirstOrDefault();

                if (SolicitacaoServico != null)
                {
                    if (SolicitacaoServico.UsuarioMedicaoID.HasValue )
                    {
                        if (usuario.ID == SolicitacaoServico.UsuarioMedicaoID.Value)
                        {
                            return new JsonResult(new { Ok = true });
                        }
                        return new JsonResult(new { Ok = false });
                    }

                    if (SolicitacaoServico.UsuarioOrigemID.HasValue)
                    {
                        if (usuario.ID == SolicitacaoServico.UsuarioOrigemID.Value)
                        {
                            return new JsonResult(new { Ok = true });
                        }
                        return new JsonResult(new { Ok = false });
                    } 
                    
                    if (SolicitacaoServico.UsuarioID == usuario.ID)
                    {
                        return new JsonResult(new { Ok = true });
                    }
                }
            }

            return new JsonResult(new { Ok = false });
        }
    }
}
