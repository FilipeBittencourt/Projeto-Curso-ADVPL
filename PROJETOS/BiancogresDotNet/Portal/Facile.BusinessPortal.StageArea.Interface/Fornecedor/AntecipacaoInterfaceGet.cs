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
    public class AntecipacaoInterfaceGet : CommonInterface<Library.Structs.Post.AntecipacaoGet, Model.Antecipacao>
    {
        public AntecipacaoInterfaceGet(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _logger, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "Antecipacao/GetAntecipacao";
        }
        public AntecipacaoInterfaceGet(FBSAContext _db, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "Antecipacao/GetAntecipacao";
        }

        public async Task Sync()
        {
            try
            {
                var List =  await GetBlock("Antecipacao");

                var validResults = new List<ValidationResult>();
                foreach (var item in List)
                {
                    using (var tran = await db.Database.BeginTransactionAsync())
                    {
                        try
                        {
                            if (Logger != null)
                                Logger.Information("AntecipacaoInterfaceGet => iniciando processamento entidade: " + item.ID);

                            Model.Antecipacao a = new Model.Antecipacao();
                            var query = (from Model.Antecipacao o in db.Antecipacao
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
                               
                                db.Antecipacao.Add(a);
                            }

                            validResults = new List<ValidationResult>();


                            PropertyCopier<AntecipacaoGet, Model.Antecipacao>.Copy(item, a, "ID");
                            a.ChaveUnica = item.ID.ToString();


                            var EmpresaInterface = (from Model.EmpresaInterface o in db.EmpresaInterface
                                                    where
                                                    o.Client_Key.ToString() == client_key &&
                                                    o.Secret_Key == secret_key
                                                    select o).FirstOrDefault();

                            if (EmpresaInterface != null)
                            {
                                a.UnidadeID = EmpresaInterface.UnidadeID;
                                a.EmpresaID = EmpresaInterface.EmpresaID;

                            }

                            var validation = new ValidationContext(a, null, null);
                            Validator.TryValidateObject(a, validation, validResults);


                            if (validResults.Count == 0)
                            {
                                List<AntecipacaoItem> ListItem = new List<AntecipacaoItem>();

                                foreach (var o in item.AntecipacaoItem)
                                {
                                    var antitem = new AntecipacaoItem();
                                    PropertyCopier<AntecipacaoItemGet, Model.AntecipacaoItem>.Copy(o, antitem, "ID");
                                    antitem.ChaveUnica = o.ID.ToString();
                                    validResults = new List<ValidationResult>();

                                    validation = new ValidationContext(antitem, null, null);
                                    Validator.TryValidateObject(antitem, validation, validResults);

                                    if (validResults.Count == 0)
                                    {
                                        ListItem.Add(antitem);
                                    }
                                }

                                if (ListItem.Count == item.AntecipacaoItem.Count)
                                {
                                    if (a.ID != 0)
                                    {
                                        var IDAntecipacao = Convert.ToInt64(a.ChaveUnica);
                                        db.AntecipacaoItem.RemoveRange(db.AntecipacaoItem.Where(x=>x.AntecipacaoID == IDAntecipacao));
                                    }
                                    db.AntecipacaoItem.AddRange(ListItem);
                                    await db.SaveChangesAsync();
                                    tran.Commit();
                                }
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