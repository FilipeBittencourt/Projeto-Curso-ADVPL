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
    public class NotaFiscalCompraInterface : CommonInterface<Library.Structs.Post.NotaFiscalCompra, Model.NotaFiscalCompra>
    {
        public NotaFiscalCompraInterface(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _logger, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "notaFiscalCompra/SetNotaFiscalCompra";
        }

        public async Task Sync()
        {
            /*
            try
            {
                var qpendentes = (from Model.NotaFiscalCompra o in db.NotaFiscalCompra
                                  join EmpresaInterface e in db.EmpresaInterface on new { o.EmpresaID, o.UnidadeID } equals new { e.EmpresaID, e.UnidadeID }
                                  where 
                                  e.Client_Key.ToString() == client_key &&
                                  e.Secret_Key == secret_key &&
                                  o.StatusIntegracao == StatusIntegracao.Pendente
                                  select o).ToList();

                var listPend = new List<Library.Structs.Post.NotaFiscalCompra>();

                foreach (var f in qpendentes)
                {
                    Logger.Information("NotaFiscalCompraInterface => iniciando processamento entidade: " + f.ChaveUnica);

                    var post = new Library.Structs.Post.NotaFiscalCompra
                    {
                        ChaveUnica = f.ChaveUnica
                    };

                    PropertyCopier<Model.NotaFiscalCompra, Library.Structs.Post.NotaFiscalCompra>.Copy(f, post);

                  
                    listPend.Add(post);

                    if (listPend.Count >= 50)
                    {
                        await SendBlock("NotaFiscalCompra", listPend);
                        listPend.Clear();
                    }
                }

                if (listPend.Count > 0)
                {
                    await SendBlock("NotaFiscalCompra", listPend);
                    listPend.Clear();
                }
            }
            catch (Exception ex)
            {
                Logger.Error("NotaFiscalCompraInterface => Sync => Exception: " + ErroUtil.GetTextoCompleto(ex));
            }  */
        }
          
    }
}