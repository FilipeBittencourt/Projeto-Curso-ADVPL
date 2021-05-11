using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.StageArea.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.StageArea.Interface.Fornecedor
{
    public class AntecipacaoInterfacePost : CommonInterface<Library.Structs.Post.AntecipacaoPost, Model.Antecipacao>
    {
        public AntecipacaoInterfacePost(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _logger, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "Antecipacao/UpdateStatusIntegracaoAsync";
        }

        public AntecipacaoInterfacePost(FBSAContext _db, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db,  _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "Antecipacao/UpdateStatusIntegracaoAsync";
        }

        public async Task Sync()
        {

            try
            {
                var qpendentes = (from Model.Antecipacao o in db.Antecipacao
                                  join EmpresaInterface e in db.EmpresaInterface on new { o.EmpresaID, o.UnidadeID } equals new { e.EmpresaID, e.UnidadeID }
                                  where
                                  e.Client_Key.ToString() == client_key &&
                                  e.Secret_Key == secret_key &&
                                  o.StatusIntegracao == StatusIntegracao.Pendente
                                  select o).ToList();

                var listPend = new List<Library.Structs.Post.AntecipacaoPost>();

                foreach (var f in qpendentes)
                {
                    if (Logger != null)
                        Logger.Information("AntecipacaoInterfacePost => iniciando processamento entidade: " + f.ChaveUnica);

                    var post = new Library.Structs.Post.AntecipacaoPost
                    {
                        ChaveUnica = f.ChaveUnica
                    };

                    PropertyCopier<Model.Antecipacao, Library.Structs.Post.AntecipacaoPost>.Copy(f, post);
                    post.Id = Convert.ToInt64(f.ChaveUnica);

                    listPend.Add(post);

                    if (listPend.Count >= 50)
                    {
                        await SendBlock("Antecipacao", listPend);
                        listPend.Clear();
                    }
                }

                if (listPend.Count > 0)
                {
                    await SendBlock("Antecipacao", listPend);
                    listPend.Clear();
                }
            }
            catch (Exception ex)
            {
                if (Logger != null)
                    Logger.Error("AntecipacaoInterfacePost=> Sync => Exception: " + ErroUtil.GetTextoCompleto(ex));
            }

        }
    }
}