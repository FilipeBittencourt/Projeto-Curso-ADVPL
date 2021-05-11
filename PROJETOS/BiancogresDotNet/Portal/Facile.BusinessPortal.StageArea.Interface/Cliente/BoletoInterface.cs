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
    public class BoletoInterface : CommonInterface<Library.Structs.Post.Boleto, Boleto>
    {
        public BoletoInterface(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _logger, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "boleto/SetBoleto";
        }
        public BoletoInterface(FBSAContext _db, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db,  _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "boleto/SetBoleto";
        }

        public async Task Sync()
        {
            try
            {
                var qpendentes = (from Boleto o in db.Boleto
                                  join EmpresaInterface e in db.EmpresaInterface on new { o.EmpresaID, o.UnidadeID } equals new { e.EmpresaID, e.UnidadeID }
                                  join Sacado s in db.Sacado on new { o.EmpresaID, CPFCNPJ = o.Sacado_CPFCNPJ } equals new { s.EmpresaID, s.CPFCNPJ }
                                  where e.Client_Key.ToString() == client_key &&
                                  e.Secret_Key == secret_key &&
                                  o.StatusIntegracao == StatusIntegracao.Pendente &&
                                  s.StatusIntegracao == StatusIntegracao.Sucesso
                                  select o).ToList();

                var listPend = new List<Library.Structs.Post.Boleto>();

                if (Logger != null)
                    Logger.Information("BoletoInterface => processando boletos: pendentes = " + qpendentes.Count);

                var distinctSacado = qpendentes.GroupBy(p => p.Sacado_CPFCNPJ).Select(g => g.First().Sacado_CPFCNPJ).ToList();

                if (Logger != null)
                    Logger.Information("BoletoInterface => processando boletos: pendentes distinct sacados = " + distinctSacado.Count);

                foreach (var sacadoCPFCNPJ in distinctSacado)
                {
                    if (Logger != null)
                        Logger.Information("BoletoInterface => processando boletos: processando sacado = " + sacadoCPFCNPJ);

                    var listBoletoSac = qpendentes.Where(o => o.Sacado_CPFCNPJ == sacadoCPFCNPJ).ToList();

                    foreach (var boleto in listBoletoSac)
                    {
                        if (Logger != null)
                            Logger.Information("BoletoInterface => iniciando processamento entidade: " + boleto.ChaveUnica);

                        var post = new Library.Structs.Post.Boleto
                        {
                            ChaveUnica = boleto.ChaveUnica
                        };

                        PropertyCopier<Boleto, Library.Structs.Post.Boleto>.Copy(boleto, post);

                        listPend.Add(post);

                        if (listPend.Count >= 40)
                        {
                            if (Logger != null)
                                Logger.Information("BoletoInterface => enviando block de dados: "+ listPend.Count);

                            await SendBlock("Boleto", listPend);
                            listPend.Clear();
                        }

                    }

                    if (listPend.Count > 0 )
                    {
                        if (Logger != null)
                            Logger.Information("BoletoInterface => enviando block de dados: " + listPend.Count);
                        await SendBlock("Boleto", listPend);
                        listPend.Clear();
                    }
                    
                }

                listPend = null;
                qpendentes = null;
            }
            catch (Exception ex)
            {
                if (Logger != null)
                    Logger.Error("BoletoInterface => Sync => Exception: " + ErroUtil.GetTextoCompleto(ex));
            }
        }
    }
}
