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
    public class TaxaFornecedorInterfaceGet : CommonInterface<Library.Structs.Post.TaxaFornecedorGet, Model.TaxaAntecipacao>
    {
        public TaxaFornecedorInterfaceGet(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _logger, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "Fornecedor/GetTaxa";
        }

        public TaxaFornecedorInterfaceGet(FBSAContext _db, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db,  _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "Fornecedor/GetTaxa";
        }

        public async Task Sync()
        {
            try
            {
                var List =  await GetBlock("Fornecedor");

                var validResults = new List<ValidationResult>();
                foreach (var item in List)
                {
                    using (var tran = await db.Database.BeginTransactionAsync())
                    {
                        try
                        {
                            if (Logger != null)
                                Logger.Information("TaxaFornecedorInterfaceGet => iniciando processamento entidade: " + item.ID);

                            Model.TaxaAntecipacao a = new Model.TaxaAntecipacao();
                            var query = (from Model.TaxaAntecipacao o in db.TaxaAntecipacao
                                        join EmpresaInterface e in db.EmpresaInterface on new { o.EmpresaID, o.UnidadeID } equals new { e.EmpresaID, e.UnidadeID }
                                        where
                                        e.Client_Key.ToString() == client_key &&
                                        e.Secret_Key == secret_key &&
                                        o.ChaveUnica.Equals(item.ID.ToString())
                                        select o);
                           

                            if (query.Any())
                            {
                                a = query.First();
                                db.Entry(a).State = Microsoft.EntityFrameworkCore.EntityState.Modified;
                            }
                            else
                            {
                               
                                db.TaxaAntecipacao.Add(a);
                            }

                            validResults = new List<ValidationResult>();


                            PropertyCopier<TaxaFornecedorGet, Model.TaxaAntecipacao>.Copy(item, a, "ID");
                            a.ChaveUnica = item.ID.ToString();
                            a.StatusIntegracao = StatusIntegracao.Sucesso;
                            a.DataHoraIntegracao = DateTime.Now;
                            var validation = new ValidationContext(a, null, null);
                            Validator.TryValidateObject(a, validation, validResults);

                            if (validResults.Count == 0)
                            {
                                await db.SaveChangesAsync();
                                tran.Commit();
                            }
                        
                        }
                        catch (Exception ex)
                        {
                            tran.Rollback();
                            if (Logger != null)
                                Logger.Error("AntecipacaoInterface => SaveBLock => Exception: " + ErroUtil.GetTextoCompleto(ex));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                if (Logger != null)
                    Logger.Error("AntecipacaoInterface => GetBlock => Exception: " + ErroUtil.GetTextoCompleto(ex));
            }
        }
    }
}