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
    public class AtendimentoInterfaceGet : CommonInterface<Library.Structs.Post.Atendimento, Model.Atendimento>
    {
        public AtendimentoInterfaceGet(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _logger, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "Atendimento/GetAtendimento";
        }
        public AtendimentoInterfaceGet(FBSAContext _db, string _apiBaseUrl, string _client_key, string _secret_key) : base(_db, _apiBaseUrl, _client_key, _secret_key)
        {
            Method = "Atendimento/GetAtendimento";
        }

        public async Task Sync()
        {
            try
            {
                var List = await GetBlock("Atendimento");

                var validResults = new List<ValidationResult>();
                foreach (var item in List)
                {
                    using (var tran = await db.Database.BeginTransactionAsync())
                    {
                        try
                        {
                            if (Logger != null)
                                Logger.Information("AtendimentoInterfaceGet => iniciando processamento entidade: " + item.ID);

                            Model.Atendimento atendimento = new Model.Atendimento();
                            var query = (from Model.Atendimento o in db.Atendimento
                                         join EmpresaInterface e in db.EmpresaInterface on new { o.EmpresaID, o.UnidadeID } equals new { e.EmpresaID, e.UnidadeID }
                                         where
                                         e.Client_Key.ToString() == client_key &&
                                         e.Secret_Key == secret_key &&
                                         o.NumeroControleParticipante ==  item.NumeroControleParticipante
                                         select o);


                            if (query.Any())
                            {
                                atendimento = query.First();
                                db.Entry(atendimento).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                                List<Model.AtendimentoMedicao> ListItem = new List<Model.AtendimentoMedicao>();

                                foreach (var o in item.AtendimentoMedicao)
                                {
                                    var atendimentoMedicao = new Model.AtendimentoMedicao();
                                    atendimentoMedicao.AtendimentoID = atendimento.ID;
                                    atendimentoMedicao.ChaveUnica = o.ID.ToString();
                                    atendimentoMedicao.AtendimentoIDPortal = o.AtendimentoID;
                                    atendimentoMedicao.IDPortal = o.ID;

                                    atendimentoMedicao.Arquivo = o.Arquivo;
                                    atendimentoMedicao.Descricao = o.Descricao;
                                    atendimentoMedicao.Tipo = o.Tipo;
                                    atendimentoMedicao.Nome = o.Nome;

                                    ListItem.Add(atendimentoMedicao);
                                }
                                db.AtendimentoMedicao.AddRange(ListItem);
                               
                                validResults = new List<ValidationResult>();

                                var validation = new ValidationContext(atendimento, null, null);
                                Validator.TryValidateObject(atendimento, validation, validResults);

                                if (validResults.Count == 0)
                                {
                                   /* if (atendimento.ID != 0)
                                    {
                                        db.AtendimentoMedicao.RemoveRange(db.AtendimentoMedicao.Where(x => x.AtendimentoID == atendimento.ID));
                                    }*/

                                    atendimento.Status = true;
                                    atendimento.StatusIntegracao = StatusIntegracao.StageOK;

                                    await db.SaveChangesAsync();
                                    tran.Commit();
                                }
                            }
                            
                        }
                        catch (Exception ex)
                        {
                            tran.Rollback();
                            if (Logger != null)
                                Logger.Error("AtendimentoInterfaceGet => SaveBLock => Exception: " + ErroUtil.GetTextoCompleto(ex));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                if (Logger != null)
                    Logger.Error("AtendimentoInterfaceGet => GetBlock => Exception: " + ErroUtil.GetTextoCompleto(ex));
            }
        }
    }
}