using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.Library.Util;
using Facile.BusinessPortal.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.BusinessRules.DAO.Fornecedor
{
    public static class AntecipacaoDAO
    {
        public static async Task<List<AntecipacaoGet>> GetAsync(ContextParams Params, string _siteBaseURL)
        {
            var db = Params.Database;
            var query = from Model.Antecipacao o in db.Antecipacao.ByParams(Params)
                        where o.StatusIntegracao == StatusIntegracao.Pendente &&
                        o.Status == StatusAntecipacao.Aprovada
                        select o;
            List<AntecipacaoGet> List = new List<AntecipacaoGet>();
            
            foreach (var item in query.ToList())
            {
                var ant = new AntecipacaoGet();
                PropertyCopier<Model.Antecipacao, AntecipacaoGet>.Copy(item, ant);
                ant.FornecedorCPFCNPJ = item.Fornecedor.CPFCNPJ;
                ant.Tipo = item.Tipo.HasValue? item.Tipo.Value: Library.Enums.TipoAntecipacao.Normal;

                List<AntecipacaoItemGet> ListItem = new List<AntecipacaoItemGet>();
                foreach (var o in item.AntecipacaoItem)
                {
                    var antitem = new AntecipacaoItemGet();
                    PropertyCopier<Model.AntecipacaoItem, AntecipacaoItemGet>.Copy(o, antitem);

                    antitem.NumeroDocumento = o.TituloPagar.DocumentoPagar.NumeroDocumento;
                    antitem.Serie = o.TituloPagar.DocumentoPagar.Serie;
                    antitem.Parcela = o.TituloPagar.Parcela;
                    antitem.NumeroControleParticipante = o.TituloPagar.NumeroControleParticipante;

                    ListItem.Add(antitem);
                }
                ant.AntecipacaoItem = ListItem;

                List.Add(ant);
            }

            return List;
        }

        public static async Task<List<SaveDataReturn>> UpdateStatusIntegracaoAsync(ContextParams Params, string _siteBaseURL, List<Library.Structs.Post.AntecipacaoPost> ListPost)
        {
            var db = Params.Database;
            var result = new List<SaveDataReturn>();

            foreach (var post in ListPost)
            {
                using (var tran = await db.Database.BeginTransactionAsync())
                {
                    try
                    {
                        var query = from Model.Antecipacao o in db.Antecipacao.ByParams(Params)
                                    where o.ID == post.Id
                                    select o;

                        Model.Antecipacao antecipacao;

                        if (query.Any())
                        {
                            antecipacao = query.First();
                            db.Entry(antecipacao).State = Microsoft.EntityFrameworkCore.EntityState.Modified;

                            antecipacao.StatusIntegracao = StatusIntegracao.Sucesso;
                            antecipacao.DataHoraIntegracao = DateTime.Now;
                        }
                        await db.SaveChangesAsync();

                      
                        tran.Commit();
                        result.Add(SaveDataReturn.ReturnOk(post.ChaveUnica));
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        result.Add(SaveDataReturn.ReturnException(post.ChaveUnica, ex));
                        continue;
                    }
                }
            }

            return result;
        }

        public static async Task<bool> CreateOrUpdateAsync(FBContext _context, string[] Ids)
        {
            return false;
        }
    }
}
