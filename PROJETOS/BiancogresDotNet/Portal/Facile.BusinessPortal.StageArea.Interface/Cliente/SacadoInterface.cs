using Facile.BusinessPortal.StageArea.Model;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using System.Linq;
using System;
using System.Collections.Generic;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library.Util;

namespace Facile.BusinessPortal.StageArea.Interface.Cliente
{
    public class SacadoInterface : CommonInterface<Library.Structs.Post.Sacado, Sacado>
    {
        public SacadoInterface(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _logger, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "sacado/SetSacado";
        }

        public SacadoInterface(FBSAContext _db, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db,  _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "sacado/SetSacado";
        }

        public async Task Sync()
        {
            try
            {
                var qpendentes = (from Sacado s in db.Sacado.AsNoTracking()
                                  where s.StatusIntegracao == StatusIntegracao.Pendente
                                  select s).ToList();

                var listPend = new List<Library.Structs.Post.Sacado>();

                foreach (var sacado in qpendentes)
                {
                    if (Logger != null)
                        Logger.Information("SacadoInterface => iniciando processamento entidade: " + sacado.CPFCNPJ);

                    var post = new Library.Structs.Post.Sacado();
                    PropertyCopier<Sacado, Library.Structs.Post.Sacado>.Copy(sacado, post);

                    //TESTE >>> nao criar usuario automatico ao sincronizar sacados
                    //post.CriarUsuario = false;

                    listPend.Add(post);

                    if (listPend.Count >= 50)
                    {
                        await SendBlock("Sacado", listPend);
                        listPend.Clear();
                    }
                }

                if (listPend.Count > 0)
                {
                    await SendBlock("Sacado", listPend);
                    listPend.Clear();
                }
            }
            catch (Exception ex)
            {
                if (Logger != null)
                    Logger.Error("SacadoInterface => SyncSacado => Exception: " + ErroUtil.GetTextoCompleto(ex));
            }
        }
    }
}
