using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Facile.BusinessPortal.Model;
using System.Threading.Tasks;
using Facile.BusinessPortal.BusinessRules.DAO;
using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Library.Util;
using Microsoft.EntityFrameworkCore;
using System;
using Facile.BusinessPortal.Library;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc.Rendering;
using Facile.BusinessPortal.ViewModels;
using Facile.BusinessPortal.Library.Extensions;
using Facile.BusinessPortal.BusinessRules.Compra;
using Facile.BusinessPortal.BusinessRules.Util;
using System.IO;
using System.Xml;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Facile.BusinessPortal.Controllers
{
    [Authorize]
    [Area("Compra")]
    public class NotaFiscalCompraController : BaseCommonController<Model.NotaFiscalCompra>
    {
        private TipoUsuario Tipo;
        private long UsuarioGrupoID;
        public NotaFiscalCompraController(FBContext context, IHttpContextAccessor contextAccessor) : base(context, contextAccessor)
        {
            this.Tipo = TipoUsuario.Default;
            var UsuarioGrupo = contextAccessor.HttpContext.Session.GetObject<UsuarioGrupoViewModel>("UsuarioGrupo");

            if (UsuarioGrupo != null)
            {
                this.Tipo = UsuarioGrupo.Tipo;
                this.UsuarioGrupoID = UsuarioGrupo.UsuarioGrupoID;
            }
        }

        /*
        public async Task<IActionResult> Agendado()
        {
            return View();
        }

       
        public override async Task<IActionResult> Index()
        {
            var ResultTipoVeiculo = _context.TipoVeiculo.AsNoTracking().
              Where(x => x.Habilitado).Select(x => new SelectListItem { Text = x.Nome, Value = x.ID.ToString() }).ToList();
            var ResultTipoProduto = _context.TipoProduto.AsNoTracking().
                Where(x => x.Habilitado).Select(x => new SelectListItem { Text = x.Nome, Value = x.ID.ToString() }).ToList();
            var ResultLocalEntrega = _context.LocalEntrega.AsNoTracking().
                Where(x => x.Habilitado).Select(x => new SelectListItem { Text = x.Nome, Value = x.ID.ToString() }).ToList();
            var ResultMotorista = _context.Motorista.AsNoTracking().
               Where(x => x.Habilitado).Select(x => new SelectListItem { Text = x.Nome, Value = x.ID.ToString() }).ToList();

            ViewBag.ListaLocalEntrega = ResultLocalEntrega;
            ViewBag.ListaTipoVeiculo = ResultTipoVeiculo;
            ViewBag.ListaTipoProduto = ResultTipoProduto;
            ViewBag.ListaMotorista = ResultMotorista;

            if (Tipo == TipoUsuario.Fornecedor)
            {
                return View("IndexFO");
            }
            else if (Tipo == TipoUsuario.Transportadora)
            {
                return View("IndexTR");
            } else
            {
                return View("Index");
            }
            
        }

        public IActionResult GetDadosTransporteNotaFiscal(int Id)
        {
            var Result = _context.NotaFiscalCompra.AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                x.ID == Id
                                ).
                            Select(x =>
                             new
                             {
                                 MotoristaID = x.MotoristaID,
                                 Placa = x.Placa,
                                 TipoVeiculoID = x.TipoVeiculoID,
                                 TipoProdutoID = x.TipoProdutoID,
                                 TransportadoraID = x.TransportadoraID.HasValue ? x.TransportadoraID.Value : 0
                             }
                            ); ;

            return new JsonResult(new { items = Result });
        }

        public IActionResult GetDadosPedidoNotaFiscal(int Id)
        {
            var Result = _context.NotaFiscalCompra.Include(x=>x.PedidoCompra).AsNoTracking().
                            Where(x =>
                                x.EmpresaID == _empresaId &&
                                x.Habilitado &&
                                x.ID == Id &&
                                x.PedidoCompraID.HasValue
                                ).
                            Select(x =>
                             new
                             {
                                 Numero = x.PedidoCompra.Numero,
                                 NumeroItem = x.PedidoCompra.Item
                             }
                            );

            return new JsonResult(new { items = Result });
        }

        public async Task<IActionResult> SalvarAutorizarEntrega(long ID, long TransportadoraID)
        {
            //TODO acertar permissao
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (!ContextUtil.CheckPermissaoMenu(_context, UsuarioGrupoID, "PedidoCompra"))
            {
                return Json(new { Ok = false, Mensagem = "Usuário não tem permissão = PedidoCompra." });
            }

            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    if (usuario == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
                    }

                    if (Request == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Erro envio das informações." });
                    }

                    if (Tipo != TipoUsuario.Fornecedor && Tipo != TipoUsuario.AdminEmpresa)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Tipo de usuário não autorizado." });
                    }

                    long NotaFiscalCompraID = ID;
                    var notaFiscalCompra = _context.NotaFiscalCompra.FirstOrDefault(o => o.ID == NotaFiscalCompraID && o.EmpresaID == usuario.EmpresaID);
                    if (notaFiscalCompra == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Nota fiscal não encontrada." });
                    }

                    notaFiscalCompra.TransportadoraID = TransportadoraID;
                    notaFiscalCompra.EntregaAutorizada = true; // Acao.Equals("A");
                    _context.Entry(notaFiscalCompra).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                    _context.SaveChanges();

                    transaction.Commit();
                    return Json(new { Ok = true, Mensagem = "" });

                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Erro Interno." });
                }
            }
        }

        public async Task<IActionResult> RemoverPedidoNotaFiscal()
        {
            //TODO acertar permissao
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (!ContextUtil.CheckPermissaoMenu(_context, UsuarioGrupoID, "PedidoCompra"))
            {
                return Json(new { Ok = false, Mensagem = "Usuário não tem permissão = PedidoCompra." });
            }

            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    
                    if (usuario == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
                    }

                    if (Request == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Erro envio das informações." });
                    }

                    if (Tipo != TipoUsuario.Fornecedor && Tipo != TipoUsuario.AdminEmpresa)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Tipo de usuário não autorizado." });
                    }

                    string Id = Request.Form["Id"];

                    if (string.IsNullOrEmpty(Id))
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Id da nota fiscal de compra informada inválida." });
                    }

                    long NotaFiscalCompraID = Convert.ToInt64(Id);
                    var notaFiscalCompra = _context.NotaFiscalCompra.FirstOrDefault(o => o.ID == NotaFiscalCompraID && o.EmpresaID == usuario.EmpresaID);
                    if (notaFiscalCompra == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Nota fiscal não encontrado." });
                    }

                    notaFiscalCompra.PedidoCompraID = null;
                    _context.Entry(notaFiscalCompra).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                    _context.SaveChanges();

                    transaction.Commit();
                    return Json(new { Ok = true, Mensagem = "" });

                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Erro Interno." });
                }
            }
        }

        public async Task<IActionResult> SalvarNotaFiscal()
        {
            //TODO acertar permissao
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    if (Tipo != TipoUsuario.Fornecedor)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Tipo de usuário não autorizado." });
                    }

                    if (Request.Form.Files.Count == 0)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Erro no arquivo XML." });
                    }

                    var arquivo = Request.Form.Files.ElementAt(0);
                    if (arquivo.Length == 0)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Erro no arquivo XML." });
                    }

                    using (var memoryStream = new MemoryStream())
                    {
                        arquivo.CopyTo(memoryStream);
                        XmlDocument doc = new XmlDocument();
                        string result = Encoding.UTF8.GetString((memoryStream as MemoryStream).ToArray());
                        doc.LoadXml(result);

                        XmlNodeList infNFe = doc.GetElementsByTagName("infNFe");
                        if (infNFe.Count == 0)
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Erro no arquivo XML." });
                        }

                        XmlNodeList ide = ((XmlElement)infNFe[0]).GetElementsByTagName("ide");
                        XmlNodeList emit = ((XmlElement)infNFe[0]).GetElementsByTagName("emit");
                        XmlNodeList det = ((XmlElement)infNFe[0]).GetElementsByTagName("det");

                        if (ide.Count == 0 || emit.Count == 0 || det.Count == 0)
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Erro no arquivo XML." });
                        }

                        string ChaveNFE = "";
                        string Numero = ((XmlElement)ide[0]).GetElementsByTagName("nNF")[0].InnerText;
                        string Serie = ((XmlElement)ide[0]).GetElementsByTagName("serie")[0].InnerText;
                        string DataEmissao = ((XmlElement)ide[0]).GetElementsByTagName("dhEmi")[0].InnerText.Substring(0, 10);
                        string FornecedorCNPJ = ((XmlElement)emit[0]).GetElementsByTagName("CNPJ")[0].InnerText;

                        if (((XmlElement)infNFe[0]).Attributes["Id"] != null)
                        {
                            ChaveNFE = ((XmlElement)infNFe[0]).Attributes["Id"].Value.Replace("NFE", "");
                        }

                        var ResultNotaFiscalCompra = _context.NotaFiscalCompra.AsNoTracking().FirstOrDefault(x => x.ChaveNFE.Equals(ChaveNFE) && x.EmpresaID == _empresaId);
                        if (ResultNotaFiscalCompra != null)
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Chave NFe já existe." });
                        }


                        var ResultFornecedor = _context.Fornecedor.FirstOrDefault(x => x.CPFCNPJ.Equals(FornecedorCNPJ) && x.EmpresaID == _empresaId);
                        if (ResultFornecedor == null)
                        {
                            transaction.Rollback();
                            return Json(new { Ok = false, Mensagem = "Fornecedor XML não encontrado." });
                        }

                       //Fornecedor fornecedor = FornecedorDAO.GetFornecedorUsuario(_context, usuario);
                       //if (fornecedor == null)
                       //{
                       //    transaction.Rollback();
                       //    return Json(new { Ok = false, Mensagem = "Fornecedor não encontrado." });
                       //}
                       //
                       //if (ResultFornecedor.ID != fornecedor.ID)
                       //{
                       //    transaction.Rollback();
                       //    return Json(new { Ok = false, Mensagem = "Fornecedor XML diferente do logado." });
                       //}

                        foreach (XmlElement d in det)
                        {
                            string ProdutoItem = d.Attributes["nItem"].Value;

                            XmlNodeList prod = d.GetElementsByTagName("prod");

                            string ProdutoCodigo = ((XmlElement)prod[0]).GetElementsByTagName("cProd")[0].InnerText;
                            string ProdutoNome = ((XmlElement)prod[0]).GetElementsByTagName("xProd")[0].InnerText;
                            string ProdutoUnidade = ((XmlElement)prod[0]).GetElementsByTagName("uCom")[0].InnerText;
                            string Quantidade = ((XmlElement)prod[0]).GetElementsByTagName("qCom")[0].InnerText;
                            string Valor = ((XmlElement)prod[0]).GetElementsByTagName("vProd")[0].InnerText;

                            string Pedido = "";
                            string PedidoItem = "";

                            if (((XmlElement)prod[0]).GetElementsByTagName("xPed").Count != 0)
                            {
                                Pedido = ((XmlElement)prod[0]).GetElementsByTagName("xPed")[0].InnerText;
                            }

                            if (((XmlElement)prod[0]).GetElementsByTagName("nItemPed").Count != 0)
                            {
                                PedidoItem = ((XmlElement)prod[0]).GetElementsByTagName("nItemPed")[0].InnerText; ;
                            }

                            NotaFiscalCompra nf = new NotaFiscalCompra();

                            if (!string.IsNullOrEmpty(Pedido) && !string.IsNullOrEmpty(PedidoItem))
                            {
                                var ResultPedidoCompra = _context.PedidoCompra.FirstOrDefault(
                                    x =>
                                        x.Numero.Equals(Pedido) &&
                                        x.Item.Equals(PedidoItem) &&
                                        !x.Deletado &&
                                        x.EmpresaID == _empresaId
                                    );
                                if (ResultPedidoCompra != null)
                                {
                                    nf.PedidoCompraID = ResultPedidoCompra.ID;
                                }
                            }

                            nf.FornecedorID = ResultFornecedor.ID;
                            nf.StatusIntegracao = 0;
                            nf.EmpresaID = _empresaId;
                            //nf.UnidadeID =  TODO Verificar
                            nf.Deletado = false;
                            nf.DeleteID = 0;
                            nf.InsertDate = DateTime.Now;
                            nf.InsertUser = "USUARIO ID: " + usuario.ID;

                            nf.Numero = Numero.Trim().ToString().PadLeft(9, '0');
                            nf.Serie = Serie;
                            nf.DataEmissao = Convert.ToDateTime(DataEmissao);
                            nf.ItemProduto = ProdutoItem.Trim().PadLeft(4, '0');
                            nf.NomeProduto = ProdutoNome.Trim();
                            nf.CodigoProduto = ProdutoCodigo.Trim();
                            nf.UnidadeProduto = ProdutoUnidade.Trim();

                            if (!string.IsNullOrEmpty(Quantidade))
                            {
                                Quantidade = Quantidade.Replace(".", ",");
                                nf.Quantidade = Convert.ToDecimal(Quantidade);
                            }
                            if (!string.IsNullOrEmpty(Valor))
                            {
                                Valor = Valor.Replace(".", ",");
                                nf.Valor = Convert.ToDecimal(Valor);
                            }

                            nf.ChaveNFE = ChaveNFE;
                            nf.NumeroControleParticipante = "";

                            var validResults = new List<ValidationResult>();
                            var validation = new ValidationContext(nf, null, null);
                            Validator.TryValidateObject(nf, validation, validResults);

                            if (validResults.Count > 0)
                            {
                                string errors = "";
                                foreach (var res in validResults)
                                {
                                    errors += res.ErrorMessage + Environment.NewLine;
                                }
                                transaction.Rollback();
                                return Json(new { Ok = false, Mensagem = "Erro na importação: " + errors });
                            }


                            _context.Add<NotaFiscalCompra>(nf);
                            _context.SaveChanges();

                        }

                        transaction.Commit();
                        return Json(new { Ok = true, Mensagem = "" });

                    }

                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Erro Interno." });
                }
            }
        }

        public async Task<IActionResult> RemoverDadosTransporteNotaFiscal()
        {
            //TODO acertar permissao
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            //if (!ContextUtil.CheckPermissaoMenu(_context, UsuarioGrupoID, "TipoVeiculo"))
          //  {
         //       return Json(new { Ok = false, Mensagem = "Usuário não tem permissão = TipoVeiculo." });
         //   }

            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
            
                    if (usuario == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
                    }

                    if (Request == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Erro envio das informações." });
                    }

                    if (Tipo != TipoUsuario.Fornecedor && Tipo != TipoUsuario.AdminEmpresa || Tipo == TipoUsuario.Transportadora)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Tipo de usuário não autorizado." });
                    }

                    string Id = Request.Form["Id"];

                    if (string.IsNullOrEmpty(Id))
                    {
                        return Json(new { Ok = false, Mensagem = "Id da nota fiscal de compra informada inválida." });
                    }

                    long NotaFiscalCompraID = Convert.ToInt64(Id);
                    var notaFiscalCompra = _context.NotaFiscalCompra.FirstOrDefault(o => o.ID == NotaFiscalCompraID && o.EmpresaID == usuario.EmpresaID);
                    if (notaFiscalCompra == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Nota fiscal não encontrado." });
                    }

                    notaFiscalCompra.TipoProdutoID = null;
                    notaFiscalCompra.TipoVeiculoID = null;
                    notaFiscalCompra.MotoristaID = null;
                    notaFiscalCompra.Placa = "";
                    _context.Entry(notaFiscalCompra).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                    _context.SaveChanges();

                    transaction.Commit();
                    return Json(new { Ok = true, Mensagem = "" });

                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Erro Interno." });
                }
            }
        }

        public async Task<IActionResult> SalvarDadosTransporteNotaFiscal()
        {
            //TODO acertar permissao
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
           //if (!ContextUtil.CheckPermissaoMenu(_context, UsuarioGrupoID, "TipoVeiculo"))
           // {
            //   return Json(new { Ok = false, Mensagem = "Usuário não tem permissão = TipoVeiculo." });
            //}

            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
             
                    if (usuario == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
                    }

                    if (Request == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Erro envio das informações." });
                    }

                    if (Tipo != TipoUsuario.Fornecedor && Tipo != TipoUsuario.AdminEmpresa || Tipo == TipoUsuario.Transportadora)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Tipo de usuário não autorizado." });
                    }

                    string TipoVeiculo = Request.Form["TipoVeiculo"];
                    string TipoProduto = Request.Form["TipoProduto"];
                    string MotoristaID = Request.Form["MotoristaID"];
                    string Placa = Request.Form["Placa"];
                    string Id = Request.Form["Id"];

                    if (string.IsNullOrEmpty(Id))
                    {
                        return Json(new { Ok = false, Mensagem = "Id da nota fiscal de compra informada inválida." });
                    }

                    if (string.IsNullOrEmpty(MotoristaID) && string.IsNullOrEmpty(Placa) && string.IsNullOrEmpty(TipoProduto) && string.IsNullOrEmpty(TipoProduto))
                    {
                        return Json(new { Ok = false, Mensagem = "Nenhum campo preenchido." });
                    }

                    long NotaFiscalCompraID = Convert.ToInt64(Id);
                    var notaFiscalCompra = _context.NotaFiscalCompra.FirstOrDefault(o => o.ID == NotaFiscalCompraID && o.EmpresaID == usuario.EmpresaID);
                    if (notaFiscalCompra == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Nota fiscal não encontrado." });
                    }

                    long IDMotorista = Convert.ToInt64(MotoristaID);
                    var motorista = _context.Motorista.FirstOrDefault(o => o.ID == IDMotorista && o.EmpresaID == usuario.EmpresaID);
                    if (motorista == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Motorista não encontrado." });
                    }

                    notaFiscalCompra.TipoProdutoID = Convert.ToInt64(TipoProduto);
                    notaFiscalCompra.TipoVeiculoID = Convert.ToInt64(TipoVeiculo);
                    notaFiscalCompra.MotoristaID = IDMotorista;
                    notaFiscalCompra.Placa = Placa;
                    _context.Entry(notaFiscalCompra).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                    _context.SaveChanges();

                    transaction.Commit();
                    return Json(new { Ok = true, Mensagem = "" });


                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Erro Interno." });
                }
            }
        }

        public async Task<IActionResult> SalvarLocalEntregaNotaFiscal()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            if (!ContextUtil.CheckPermissaoMenu(_context, UsuarioGrupoID, "LocalEntrega"))
            {
                return Json(new { Ok = false, Mensagem = "Usuário não tem permissão = Local Entrega." });
            }

            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    
                    if (usuario == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
                    }

                    if (Request == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Erro envio das informações." });
                    }

                    if (Tipo != TipoUsuario.AdminEmpresa)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Tipo de usuário não autorizado." });
                    }

                    string LocalEntrega = Request.Form["LocalEntrega"];
                    string Id = Request.Form["Id"];

                    if (string.IsNullOrEmpty(Id))
                    {
                        return Json(new { Ok = false, Mensagem = "Id da nota fiscal de compra não informada." });
                    }

                    if (string.IsNullOrEmpty(LocalEntrega))
                    {
                        return Json(new { Ok = false, Mensagem = "Local Entrega não informado." });
                    }

                    long NotaFiscalCompraID = Convert.ToInt64(Id);
                    var notaFiscalCompra = _context.NotaFiscalCompra.FirstOrDefault(o => o.ID == NotaFiscalCompraID && o.EmpresaID == usuario.EmpresaID);
                    if (notaFiscalCompra == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Nota fiscal não encontrado." });
                    }

                    notaFiscalCompra.LocalEntregaID = Convert.ToInt64(LocalEntrega);
                    _context.Entry(notaFiscalCompra).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                    _context.SaveChanges();

                    var ResultMail = CompraMail.LocalEntregaSendMail(_context, NotaFiscalCompraID);
                    if (!ResultMail.Status)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = ResultMail.Mensagem });
                    }

                    transaction.Commit();
                    return Json(new { Ok = true, Mensagem = "" });

                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Erro Interno." });
                }
            }
        }

        public async Task<IActionResult> SalvarPedidoNotaFiscal()
        {
            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
           

            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {

                    if (usuario == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Usuário não encontrado." });
                    }

                    if (Request == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Erro envio das informações." });
                    }

                    if (Tipo != TipoUsuario.Fornecedor)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Tipo de usuário não autorizado." });
                    }

                    string Pedido = Request.Form["Pedido"];
                    string PedidoItem = Request.Form["PedidoItem"];
                    string Id = Request.Form["Id"];

                    if (string.IsNullOrEmpty(Id))
                    {
                        return Json(new { Ok = false, Mensagem = "Id da nota fiscal de compra não informada." });
                    }

                    if (string.IsNullOrEmpty(Pedido) || string.IsNullOrEmpty(PedidoItem))
                    {
                        return Json(new { Ok = false, Mensagem = "Pedido/Pedido Itemtem não informado." });
                    }

                    long NotaFiscalCompraID = Convert.ToInt64(Id);
                    var notaFiscalCompra = _context.NotaFiscalCompra.FirstOrDefault(o => o.ID == NotaFiscalCompraID && o.EmpresaID == usuario.EmpresaID);
                    if (notaFiscalCompra == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Nota fiscal não encontrado." });
                    }

                    var pedidoCompra = _context.PedidoCompra.FirstOrDefault(o => o.Numero.Trim().Equals(Pedido) && o.Item.Trim().Equals(PedidoItem) && o.EmpresaID == usuario.EmpresaID);
                    if (pedidoCompra == null)
                    {
                        transaction.Rollback();
                        return Json(new { Ok = false, Mensagem = "Pedido/Pedido Item não encontrado." });
                    }

                    notaFiscalCompra.PedidoCompraID = pedidoCompra.ID;
                    _context.Entry(notaFiscalCompra).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                    _context.SaveChanges();

                    transaction.Commit();
                    return Json(new { Ok = true, Mensagem = "" });

                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return Json(new { Ok = false, Mensagem = "Erro Interno." });
                }
            }
        }

        public IActionResult DataTable()
        {
            var draw = Request.Form["draw"].FirstOrDefault();
            var start = Request.Form["start"].FirstOrDefault();
            var length = Request.Form["length"].FirstOrDefault();
            var sortColumn = Request.Form["order[0][column]"].FirstOrDefault();
            var sortColumnDir = Request.Form["order[0][dir]"].FirstOrDefault();
            var searchValue = Request.Form["search[value]"].FirstOrDefault();
            var fieldSearch = Request.Form["FieldSearch"].FirstOrDefault();

            int pageSize = length != null ? Convert.ToInt32(length) : 0;
            int skip = start != null ? Convert.ToInt32(start) : 0;
            int orderby = sortColumn != null ? Convert.ToInt32(sortColumn) + 1 : 1;

            int recordsTotal = 0;
            int recordsFiltered = 0;
            string query = "";
            List<dynamic> data = new List<dynamic>();

            Usuario usuario = UsuarioDAO.GetUsuario(_context, User);
            string queryFiltroUsuario = "";

            if (usuario != null)
            { 
                if (Tipo == TipoUsuario.Fornecedor)
                {
                    var ResultUsuarioFornecedor = _context.UsuarioFornecedor.FirstOrDefault(x => x.UsuarioID == usuario.ID && x.EmpresaID == _empresaId);
                    if (ResultUsuarioFornecedor != null)
                    {
                        var FornecedorId = ResultUsuarioFornecedor.FornecedorID;
                        queryFiltroUsuario += " AND t.FornecedorID = '" + FornecedorId + "'";
                    }
                }
                else if (Tipo == TipoUsuario.Transportadora)
                {
                    var ResultUsuarioTransportadora = _context.UsuarioTransportadora.FirstOrDefault(x => x.UsuarioID == usuario.ID && x.EmpresaID == _empresaId);
                    if (ResultUsuarioTransportadora != null)
                    {
                        var TransportadoraID = ResultUsuarioTransportadora.TransportadoraID;
                        queryFiltroUsuario += " AND p.TransportadoraID = '" + TransportadoraID + "' AND t.EntregaAutorizada = 1";
                    }
                }
            }

            using (var command = _context.Database.GetDbConnection().CreateCommand())
            {
                try
                {
                    _context.Database.OpenConnection();
                    //total de registro
                    query = @"  select COUNT(*) from NotaFiscalCompra t ";
                    query += @"  LEFT JOIN PedidoCompra p ON p.ID = t.PedidoCompraID ";
                    query += @" where t.EmpresaId = '" + _empresaId + "' ";
                    query += queryFiltroUsuario;

                    command.CommandText = query;
                    recordsTotal = Convert.ToInt32(command.ExecuteScalar());

                    //Campos para filtro e retorno
                    var cqfields = "";
                    cqfields += @" t.ID,";
                    cqfields += @" NomeFornecedor = Fornecedor.Nome + ' - ' + Fornecedor.CodigoERP, ";
                    cqfields += @" NumeroSerie = t.Numero+'/'+t.Serie,";
                    cqfields += @" Produto = t.NomeProduto+' - '+t.CodigoProduto, ";
                    cqfields += @" t.Quantidade, ";
                    cqfields += @" t.Valor,  ";
                    cqfields += @" t.ItemProduto, ";
                    cqfields += @" DtEmissao=CONVERT(varchar, t.DataEmissao, 103), ";
                    cqfields += @" t.ChaveNFE,";
                    cqfields += @" StatusPedido=(case when PedidoCompraID is null then 'Aguardando Pedido' else 'Pedido Informado' end), ";
                    cqfields += @" TipoFrete=(case when TipoFrete = 1 then 'CIF' else 'FOB' end), ";
                    cqfields += @" StatusTransporte=(case when EntregaAutorizada = 1 then 'Autorizada' else '' end), ";
                    cqfields += @" StatusAgendamento=(case when PedidoCompraID is not null and DataAgendamento is not null then 'Agendenda' else 'Aguardando Agendamento' end) ";

                    //total filtrado
                    query = $@"SELECT COUNT(*) FROM ( 
                                     select {cqfields} from NotaFiscalCompra t 
                                      JOIN Fornecedor ON Fornecedor.ID = t.FornecedorID
                                      LEFT JOIN PedidoCompra p ON p.ID = t.PedidoCompraID  ";
                    query += @" where t.EmpresaId = '" + _empresaId + "' ";
                    query += queryFiltroUsuario;
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";

                    command.CommandText = query;
                    recordsFiltered = Convert.ToInt32(command.ExecuteScalar());

                    //registros
                    //AND PedidoCompraID IS NULL
                    query = $@"SELECT * FROM ( 
                                    select {cqfields} from NotaFiscalCompra t
                                    JOIN Fornecedor ON Fornecedor.ID = t.FornecedorID
                                    LEFT JOIN PedidoCompra p ON p.ID = t.PedidoCompraID ";
                    query += @" where t.EmpresaId = '" + _empresaId + "'  ";
                    query += queryFiltroUsuario;
                    query += @" ) A";

                    query += @" where (";
                    query += LibraryUtil.NormalizaSearch(fieldSearch);
                    query += @" )";
                    query += @" ORDER BY " + orderby + " " + sortColumnDir + ((pageSize != -1) ? " OFFSET " + (skip) + " ROWS FETCH NEXT " + (pageSize) + " ROWS ONLY" : "");

                    command.CommandText = query;
                    var result = command.ExecuteReader();

                    while (result.Read())
                    {
                        data.Add(new
                        {
                            Id = result["ID"],
                            Fornecedor = result["NomeFornecedor"],
                            NumeroSerie = result["NumeroSerie"],
                            Produto = result["Produto"],
                            Quantidade = result["Quantidade"],
                            Valor = string.Format("{0:C2}", result["Valor"]),
                            Item = result["ItemProduto"],
                            DataEmissao = result["DtEmissao"],
                            ChaveNFE = result["ChaveNFE"],
                            StatusPedido = result["StatusPedido"],
                            StatusTransporte = result["StatusTransporte"],
                            StatusAgendamento = result["StatusAgendamento"],
                            TipoFrete  = result["TipoFrete"],
                            EmpresaID = _empresaId
                        });
                    }
                }
                finally
                {
                    if (_context.Database.GetDbConnection().State == System.Data.ConnectionState.Open)
                    {
                        _context.Database.CloseConnection();
                    }
                }

            }

            return Json(new { draw, recordsFiltered, recordsTotal, data });
        }
    */
    
    }
}
