using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Linq;
using System.IO;
using System.Threading;
using System.Timers;
using Microsoft.EntityFrameworkCore;
using Facile.BusinessPortal.StageArea.Model;
using Facile.BusinessPortal.StageArea.Interface.Cliente;
using Facile.BusinessPortal.Library;
using Facile.BusinessPortal.StageArea.Interface.Fornecedor;

namespace Facile.BusinessPortal.StageArea.SAConsole
{
    public class Robo
    {
        protected IConfigurationRoot Configuration { get; set; }
        protected Serilog.ILogger Logger { get; set; }

        public Robo(Serilog.ILogger _logger)
        {
            Logger = _logger;
        }

        public void Iniciar()
        {
            Logger.Information("INICIANDO Facile.BusinessPortal.StageArea.SAConsole");

            var builder = new ConfigurationBuilder()
              .SetBasePath(Directory.GetCurrentDirectory())
              .AddJsonFile("AppSettings.json", optional: true, reloadOnChange: true);

            IConfigurationRoot configuration = builder.Build();

            var apiURL = configuration.GetSection("ApiBaseURL").Value;

            Logger.Information("SETUP: API URL = " + apiURL);

            var connStr = configuration.GetSection("ConnectionStrings").GetSection("DefaultConnection").Value;
            Logger.Information("SETUP BANCO DE DADOS: " + connStr);

            if (!Directory.Exists(AppContext.BaseDirectory + "\\LOGS"))
            {
                Directory.CreateDirectory(AppContext.BaseDirectory + "\\LOGS");
            }

            var optionsBuilder = new DbContextOptionsBuilder<FBSAContext>();
            optionsBuilder.UseLazyLoadingProxies().UseSqlServer(connStr);
            using (var db = new FBSAContext(optionsBuilder.Options))
            {
                var qprocesso = (from ProcessoEmpresa p in db.ProcessoEmpresa
                                 where p.Habilitado
                                 select p).ToList();

                foreach (var processo in qprocesso)
                {
                    RoboStart(processo.ID, processo.Interval);
                }
            }
        }

        private void RoboStart(long processoId, long? processoInterval)
        {
            Console.WriteLine("Iniciando Thread Processo: " + processoId.ToString());

            var timer = new System.Timers.Timer();
            timer.Elapsed += (sender, e) => OnTimerExecute(sender, e, processoId);

            if (processoInterval.HasValue && processoInterval.Value > 0)
                timer.Interval = processoInterval.Value;
            else
                timer.Interval = 30000;

            GC.KeepAlive(timer);

            timer.Enabled = true;
            timer.Start();
        }


        private void OnTimerExecute(object source, ElapsedEventArgs e, long processoid)
        {
            try
            {
                (source as System.Timers.Timer).Stop();

                ////Check tamanho do LOG e limpar
                //var pathlog = AppContext.BaseDirectory + @"\LOGS\consoleapp.log";
                //if (File.Exists(pathlog))
                //{
                //    var info = new FileInfo(pathlog);
                //    if (info.Length > 10000)
                //    {
                //        FileUtil.BackupAndDelete(pathlog);
                //    }
                //}

                Logger.Information("OnTimerExecute" + DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToLongTimeString());
                StartJob(processoid);

                (source as System.Timers.Timer).Start();
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERRO TIMER PROCESSO ID: " + processoid.ToString() + " EX: " + ex.Message);
                return;
            }
        }

        private void StartJob(long processoId)
        {
            Logger.Information("INICIANDO Facile.BusinessPortal.StageArea.SAConsole");

            var builder = new ConfigurationBuilder()
              .SetBasePath(Directory.GetCurrentDirectory())
              .AddJsonFile("AppSettings.json", optional: true, reloadOnChange: true);

            IConfigurationRoot configuration = builder.Build();

            var apiURL = configuration.GetSection("ApiBaseURL").Value;
            var connStr = configuration.GetSection("ConnectionStrings").GetSection("DefaultConnection").Value;

            var optionsBuilder = new DbContextOptionsBuilder<FBSAContext>();
            optionsBuilder.UseLazyLoadingProxies().UseSqlServer(connStr);
            using (var db = new FBSAContext(optionsBuilder.Options))
            {
                var processo = db.ProcessoEmpresa.FirstOrDefault(o => o.ID == processoId);

                if (processo != null )
                {
                    var empresa = processo.EmpresaInterface;
                    Logger.Information("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> PROCESSO: " + processo.ProcessoIntegracao.ToString());

                    var client_key = empresa.Client_Key;
                    var secret_key = empresa.Secret_Key;
                   
                    
                    /*if (processo.ProcessoIntegracao == ProcessoIntegracao.Sacado)
                    {
                        Logger.Information("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: SACADO");
                        var sacadoInterface = new SacadoInterface(db, Logger, apiURL, client_key.ToString(), secret_key);
                        sacadoInterface.Sync().Wait();
                    }

                    if (processo.ProcessoIntegracao == ProcessoIntegracao.Boleto)
                    {
                        Logger.Information("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: BOLETO");
                        var boletoInterface = new BoletoInterface(db, Logger, apiURL, client_key.ToString(), secret_key);
                        boletoInterface.Sync().Wait();
                    }
                    */

                    /*
                    if (processo.ProcessoIntegracao == ProcessoIntegracao.Fornecedor)
                    {
                        Logger.Information("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: FORNECEDOR");
                        var fornecedorInterface = new FornecedorInterface(db, Logger, apiURL, client_key.ToString(), secret_key);
                        fornecedorInterface.Sync().Wait();
                    }
                    */

                    if (processo.ProcessoIntegracao == ProcessoIntegracao.TituloPagar)
                    {
                        Logger.Information("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: TITULO PAGAR");
                        var tituloPagarInterface = new TituloPagarInterface(db, Logger, apiURL, client_key.ToString(), secret_key);
                        tituloPagarInterface.Sync().Wait();
                    }
                    

                    if (processo.ProcessoIntegracao == ProcessoIntegracao.Antecipacao)
                    {
                        Logger.Information("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: Antecipacao");

                        var antecipacaoInterfaceGet = new AntecipacaoInterfaceGet(db, Logger, apiURL, client_key.ToString(), secret_key);
                        antecipacaoInterfaceGet.Sync().Wait();

                        var antecipacaoInterfacePost = new AntecipacaoInterfacePost(db, Logger, apiURL, client_key.ToString(), secret_key);
                        antecipacaoInterfacePost.Sync().Wait();
                    }

                    if (processo.ProcessoIntegracao == ProcessoIntegracao.TaxaFornecedor)
                    {
                        Logger.Information("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: Taxa Fornecedor");

                        var taxaFornecedorInterfaceGet = new TaxaFornecedorInterfaceGet(db, Logger, apiURL, client_key.ToString(), secret_key);
                        taxaFornecedorInterfaceGet.Sync().Wait();

                        var taxaFornecedorInterfacePost = new TaxaFornecedorInterfacePost(db, Logger, apiURL, client_key.ToString(), secret_key);
                        taxaFornecedorInterfacePost.Sync().Wait();
                    }
                    
                    /*  if (processo.ProcessoIntegracao == ProcessoIntegracao.RPV)
                      {
                          FileUtil.GravaLog("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: Atendimento");
                          var rpvInterface = new AtendimentoInterface(db, apiURL, client_key.ToString(), secret_key);
                          rpvInterface.Sync().Wait();

                          var rpvInterfaceGet = new AtendimentoInterfaceGet(db, apiURL, client_key.ToString(), secret_key);
                          rpvInterfaceGet.Sync().Wait();

                          var rpvInterfacePost = new AtendimentoInterfacePost(db, apiURL, client_key.ToString(), secret_key);
                          rpvInterfacePost.Sync().Wait();
                      }
                     */
                    processo.LastEditDate = DateTime.Now;
                    db.SaveChanges();
                }
            }
        }
    }
}
