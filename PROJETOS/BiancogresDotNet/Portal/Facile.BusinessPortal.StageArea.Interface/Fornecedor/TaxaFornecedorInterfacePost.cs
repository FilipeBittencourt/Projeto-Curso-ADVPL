using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.StageArea.Model;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.StageArea.Interface.Fornecedor
{
    public class TaxaFornecedorInterfacePost : CommonInterface<Library.Structs.Post.TaxaFornecedorPost, Model.TaxaAntecipacao>
    {
        public TaxaFornecedorInterfacePost(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _logger, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "Fornecedor/UpdateStatusIntegracaoTaxa";
        }

        public TaxaFornecedorInterfacePost(FBSAContext _db, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db,  _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "Fornecedor/UpdateStatusIntegracaoTaxa";
        }

        public async Task Sync()
        {

            try
            {
                var qpendentes = (from Model.TaxaAntecipacao o in db.TaxaAntecipacao
                                  join EmpresaInterface e in db.EmpresaInterface on new { o.EmpresaID, o.UnidadeID } equals new { e.EmpresaID, e.UnidadeID }
                                  where
                                  e.Client_Key.ToString() == client_key &&
                                  e.Secret_Key == secret_key &&
                                  (
                                    o.StatusIntegracao == StatusIntegracao.Pendente ||
                                    (   
                                    //reenviar confirmação dos gets
                                        o.StatusIntegracao == StatusIntegracao.Sucesso &&
                                        o.DataHoraIntegracao.HasValue
                                    )
                                  )
                                  select o).ToList();

                var listPend = new List<Library.Structs.Post.TaxaFornecedorPost>();

                foreach (var f in qpendentes)
                {
                    if (Logger != null)
                        Logger.Information("TaxaFornecedorInterfacePost => iniciando processamento entidade: " + f.ChaveUnica);

                    var post = new Library.Structs.Post.TaxaFornecedorPost
                    {
                        ChaveUnica = f.ChaveUnica
                    };

                    PropertyCopier<Model.TaxaAntecipacao, Library.Structs.Post.TaxaFornecedorPost>.Copy(f, post);
                    post.Id = Convert.ToInt64(f.ChaveUnica);

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
                    Logger.Error("TaxaFornecedorInterfacePost=> Sync => Exception: " + ErroUtil.GetTextoCompleto(ex));
            }

        }
    }
}