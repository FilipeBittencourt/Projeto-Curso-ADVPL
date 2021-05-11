using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.StageArea.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.StageArea.Interface.Fornecedor
{
    public class FornecedorInterface : CommonInterface<Library.Structs.Post.Fornecedor, Model.Fornecedor>
    {
        public FornecedorInterface(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _logger, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "fornecedor/SetFornecedor";
        }

        public FornecedorInterface(FBSAContext _db, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db,  _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "fornecedor/SetFornecedor";
        }

        public async Task Sync()
        {
            try
            {
                var qpendentes = (from Model.Fornecedor o in db.Fornecedor
                                  join EmpresaInterface e in db.EmpresaInterface on new { o.EmpresaID, o.UnidadeID } equals new { e.EmpresaID, e.UnidadeID }
                                  where 
                                  e.Client_Key.ToString() == client_key &&
                                  e.Secret_Key == secret_key &&
                                  o.StatusIntegracao == StatusIntegracao.Pendente
                                  select o).ToList();

                var listPend = new List<Library.Structs.Post.Fornecedor>();

                foreach (var f in qpendentes)
                {
                    if (Logger != null)
                        Logger.Information("FornecedorInterface => iniciando processamento entidade: " + f.ChaveUnica);

                    var post = new Library.Structs.Post.Fornecedor
                    {
                        ChaveUnica = f.ChaveUnica
                    };

                    PropertyCopier<Model.Fornecedor, Library.Structs.Post.Fornecedor>.Copy(f, post);

                    post.EmailUsuario = f.Email;
                  
                    listPend.Add(post);

                    if (listPend.Count >= 50)
                    {
                        await SendBlock("Fornecedor", listPend);
                        listPend.Clear();
                    }
                }

                if (listPend.Count > 0)
                {
                    await SendBlock("Fornecedor", listPend);
                    listPend.Clear();
                }
            }
            catch (Exception ex)
            {
                if (Logger != null)
                    Logger.Error("FornecedorInterface => Sync => Exception: " + ErroUtil.GetTextoCompleto(ex));
            }
        }
    }
}