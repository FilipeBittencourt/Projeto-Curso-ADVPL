using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.StageArea.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.StageArea.Interface.Compra
{
    public class PedidoCompraInterface : CommonInterface<Library.Structs.Post.PedidoCompra, Model.PedidoCompra>
    {
        public PedidoCompraInterface(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _logger, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "pedidoCompra/SetPedidoCompra";
        }

        public PedidoCompraInterface(FBSAContext _db, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "pedidoCompra/SetPedidoCompra";
        }

        public async Task Sync()
        {
            /*
            try
            {
                var qpendentes = (from Model.PedidoCompra o in db.PedidoCompra
                                  join EmpresaInterface e in db.EmpresaInterface on new { o.EmpresaID, o.UnidadeID } equals new { e.EmpresaID, e.UnidadeID }
                                  where 
                                  e.Client_Key.ToString() == client_key &&
                                  e.Secret_Key == secret_key &&
                                  o.StatusIntegracao == StatusIntegracao.Pendente
                                  select o).ToList();

                var listPend = new List<Library.Structs.Post.PedidoCompra>();

                foreach (var f in qpendentes)
                {
                    if (Logger != null)
                        Logger.Information("PedidoCompraInterface => iniciando processamento entidade: " + f.ChaveUnica);

                    var post = new Library.Structs.Post.PedidoCompra
                    {
                        ChaveUnica = f.ChaveUnica
                    };

                    PropertyCopier<Model.PedidoCompra, Library.Structs.Post.PedidoCompra>.Copy(f, post);

                    listPend.Add(post);

                    if (listPend.Count >= 50)
                    {
                        await SendBlock("PedidoCompra", listPend);
                        listPend.Clear();
                    }
                }

                if (listPend.Count > 0)
                {
                    await SendBlock("PedidoCompra", listPend);
                    listPend.Clear();
                }
            }
            catch (Exception ex)
            {
                if (Logger != null)
                    Logger.Error("PedidoCompraInterface => Sync => Exception: " + ErroUtil.GetTextoCompleto(ex));
            }
            */
        }
    }
}