using Library = Facile.BusinessPortal.Library;
using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.StageArea.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.StageArea.Interface
{
    public class CommonInterface<T, O> where T : StructIntegracao where O : Padrao
    {
        protected readonly FBSAContext db;
        protected Serilog.ILogger Logger { get; set; }
        protected readonly string apiBaseUrl;
        protected string client_key;
        protected string secret_key;

        public string Method { get; set; }

        public CommonInterface(FBSAContext _db, Serilog.ILogger _logger, string _apiBaseUrl, string _client_key, string _secret_key)
        {
            db = _db;
            Logger = _logger;
            apiBaseUrl = _apiBaseUrl;
            client_key = _client_key;
            secret_key = _secret_key;
        }

        public CommonInterface(FBSAContext _db,  string _apiBaseUrl, string _client_key, string _secret_key)
        {
            db = _db;
            Logger = null;
            apiBaseUrl = _apiBaseUrl;
            client_key = _client_key;
            secret_key = _secret_key;
        }

        public async Task<List<T>> GetBlock(string NomeEntidade)
        {
            try
            {
                var client = new ApiClient(apiBaseUrl, client_key, secret_key);
                if (Logger != null)
                    Logger.Information(typeof(T).Name.Trim() + " => iniciando sincronismo com API =>  buscando informações.");
                else
                    Library.FileUtil.GravaLog(typeof(T).Name.Trim() + " => iniciando sincronismo com API =>  buscando informações.");
                
                var type = typeof(List<SaveDataReturn>);

                var ret = await client.GetObjectListAsync<T>(Method);

                if (ret != null)
                {
                    if (Logger != null)
                        Logger.Information("Quantidade regitros => "+ret.Count());
                    else
                        Library.FileUtil.GravaLog("Quantidade regitros => " + ret.Count());
                    return ret;
                }
                else
                {
                    if (Logger != null)
                        Logger.Warning(typeof(T).Name.Trim() + " => Warning: Retorno Null da API");
                    else
                        Library.FileUtil.GravaLog(typeof(T).Name.Trim() + " => Warning: Retorno Null da API");
                }
            }
            catch (Exception ex)
            {
                if (Logger != null)
                    Logger.Error(typeof(T).Name.Trim() + " => GetBlock" + Library.Util.ErroUtil.GetTextoCompleto(ex));
                else
                    Library.FileUtil.GravaLog(typeof(T).Name.Trim() + " => GetBlock" + Library.Util.ErroUtil.GetTextoCompleto(ex));
            }
            return new List<T>();
        }

        public async Task SendBlock(string NomeEntidade, List<T> listPend)
        {
            try
            {
                var client = new ApiClient(apiBaseUrl, client_key, secret_key);

                if (Logger != null)
                    Logger.Information(typeof(T).Name.Trim() + " => iniciando sincronismo com API => " + listPend.Count().ToString() + " registros.");
                else
                    Library.FileUtil.GravaLog(typeof(T).Name.Trim() + " => iniciando sincronismo com API => " + listPend.Count().ToString() + " registros.");

                var type = typeof(List<SaveDataReturn>);
                var ret = await client.PostObjectListAsync(Method, listPend);

                if (ret != null && (ret is List<SaveDataReturn>))
                {
                    foreach (var result in ret)
                    {
                        //if (!long.TryParse(result.Identificador, out var stageId))
                        //{
                        //    Logger.LogWarning(typeof(T).Name.Trim() + " => SendBlock => Error: Retorno " + NomeEntidade + ": " + result.Identificador.Trim() + " > Nao Encontrado/Inválido.");
                        //    continue;
                        //}

                        if (!string.IsNullOrWhiteSpace(result.Identificador))
                        {
                            var myObj = db.Set<O>().FirstOrDefault(o => o.ChaveUnica.Trim() == result.Identificador);

                            if (myObj != null)
                            {
                                //db.Entry(myObj).State = EntityState.Modified;

                                string message = result.Message ?? string.Empty;
                                if (result.ErrorMessages != null)
                                {
                                    foreach (var error in result.ErrorMessages)
                                    {
                                        message += ">>>" + error;
                                    }
                                }

                                if (result.Ok)
                                {
                                    myObj.StatusIntegracao = StatusIntegracao.Sucesso;
                                    myObj.MensagemRetorno = message;
                                }
                                else
                                {
                                    myObj.StatusIntegracao = StatusIntegracao.Erro;
                                    myObj.MensagemRetorno = message;
                                }

                                //var log = new LogIntegracao
                                //{
                                //    EmpresaID = myObj.EmpresaID,
                                //    UnidadeID = myObj.UnidadeID,
                                //    DataHoraIntegracao = DateTime.Now,
                                //    StatusIntegracao = result.Ok ? StatusIntegracao.Sucesso : StatusIntegracao.Erro,
                                //    InsertDate = DateTime.Now,
                                //    MensagemRetorno = message,
                                //    EntidadeNome = NomeEntidade,
                                //    EntidadeID = myObj.ID,
                                //    ChaveUnica = NomeEntidade + "." + myObj.ChaveUnica.Trim()
                                //};
                                //db.LogIntegracao.Add(log);

                                if (result.Ok)
                                    if (Logger != null)
                                        Logger.Information(typeof(T).Name.Trim() + " => Retorno OK: " + NomeEntidade + ": " + result.Identificador.Trim() + " > " + result.Message);
                                    else
                                        Library.FileUtil.GravaLog(typeof(T).Name.Trim() + " => Retorno OK: " + NomeEntidade + ": " + result.Identificador.Trim() + " > " + result.Message);

                                else
                                    if (Logger != null)
                                        Logger.Information(typeof(T).Name.Trim() + " => Retorno ERRO: " + NomeEntidade + ": " + result.Identificador.Trim() + " > " + result.Message);
                                    else
                                        Library.FileUtil.GravaLog(typeof(T).Name.Trim() + " => Retorno ERRO: " + NomeEntidade + ": " + result.Identificador.Trim() + " > " + result.Message);

                            }
                            else
                            {
                                if (Logger != null)
                                    Logger.Warning(typeof(T).Name.Trim() + " => Warning: Retorno " + NomeEntidade + ": " + result.Identificador.Trim() + " > Nao Encontrado.");
                                else
                                    Library.FileUtil.GravaLog(typeof(T).Name.Trim() + " => Warning: Retorno " + NomeEntidade + ": " + result.Identificador.Trim() + " > Nao Encontrado.");

                            }

                            myObj = null;
                        }
                        else
                        {
                            if (Logger != null)
                                Logger.Error(typeof(T).Name.Trim() + " => ERROR: Retorno INVÁLIDO da API");
                            else
                                Library.FileUtil.GravaLog(typeof(T).Name.Trim() + " => ERROR: Retorno INVÁLIDO da API");


                            foreach (var obj in listPend)
                            {
                                var myObj = db.Set<O>().FirstOrDefault(o => o.ChaveUnica.Trim() == obj.ChaveUnica.Trim());
                                if (myObj != null)
                                {
                                    myObj.StatusIntegracao = StatusIntegracao.Erro;
                                    myObj.MensagemRetorno = "Retorno INVÁLIDO da API";
                                }
                            }
                        }
                    }
                    await db.SaveChangesAsync();
                }
                else
                {
                    if (Logger != null)
                        Logger.Error(typeof(T).Name.Trim() + " => ERROR: Retorno INVÁLIDO da API");
                    else
                        Library.FileUtil.GravaLog(typeof(T).Name.Trim() + " => ERROR: Retorno INVÁLIDO da API");


                    foreach (var obj in listPend)
                    {
                        var myObj = db.Set<O>().FirstOrDefault(o => o.ChaveUnica.Trim() == obj.ChaveUnica.Trim());
                        if (myObj != null)
                        {
                            myObj.StatusIntegracao = StatusIntegracao.Erro;
                            myObj.MensagemRetorno = "Retorno INVÁLIDO da API";
                        }
                    }
                }

                client = null;
                if (Logger != null)
                    Logger.Information(typeof(T).Name.Trim() + " => finalizado");
                else
                    Library.FileUtil.GravaLog(typeof(T).Name.Trim() + " => finalizado");

            }
            catch (Exception ex)
            {
                if (Logger != null)
                    Logger.Error(typeof(T).Name.Trim() + " => SendBlock " + Library.Util.ErroUtil.GetTextoCompleto(ex));
                else
                    Library.FileUtil.GravaLog(typeof(T).Name.Trim() + " => SendBlock " + Library.Util.ErroUtil.GetTextoCompleto(ex));

                throw;
            }
        }
    }
}
