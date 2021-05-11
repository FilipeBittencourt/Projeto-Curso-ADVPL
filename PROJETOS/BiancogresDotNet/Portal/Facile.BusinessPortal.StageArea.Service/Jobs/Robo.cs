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
using Facile.BusinessPortal.StageArea.Interface.Compra;
using System.Diagnostics;
using System.ServiceProcess;

namespace Facile.BusinessPortal.StageArea.Service
{
    public class Robo
    {
        protected IConfigurationRoot Configuration { get; set; }
        private int QuantidadeExecucao { get; set; }
      
        public Robo()
        {
        }


        public void Iniciar()
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(AppContext.BaseDirectory)
                .AddJsonFile("AppSettings.json", optional: true, reloadOnChange: true);

            IConfigurationRoot configuration = builder.Build();

            var apiURL = configuration.GetSection("ApiBaseURL").Value;
            FileUtil.GravaLog("SETUP: API URL = " + apiURL);
            
            var connStr = configuration.GetSection("ConnectionStrings").GetSection("DefaultConnection").Value;
            FileUtil.GravaLog("SETUP BANCO DE DADOS: " + connStr);

            try
            {
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
            } catch (Exception ex)
            {
                FileUtil.GravaLog("Erro: " + ex);
            }

        }

        private void RoboStart(long processoId, long? processoInterval)
        {
            FileUtil.GravaLog("Iniciando Thread Processo: " + processoId.ToString());
            
            var timer = new System.Timers.Timer();
            timer.Elapsed += (sender, e) => OnTimerExecute(sender, e, processoId);

            if (processoInterval.HasValue && processoInterval.Value > 0)
                timer.Interval = processoInterval.Value;
            else
                timer.Interval = 100000;
                //timer.Interval = 30000;
            

            GC.KeepAlive(timer);

            timer.Enabled = true;
            timer.Start();
        }


        private void OnTimerExecute(object source, ElapsedEventArgs e, long processoid)
        {
            try
            {
                (source as System.Timers.Timer).Stop();
                
                StartJob(processoid);

                (source as System.Timers.Timer).Start();
            }
            catch (Exception ex)
            {
                FileUtil.GravaLog("ERRO TIMER PROCESSO ID: " + processoid.ToString() + " EX: " + ex.Message);
                return;
            }
        }

        private void StartJob(long processoId)
        {
            FileUtil.GravaLog("StartJob: " + DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToLongTimeString());

            var builder = new ConfigurationBuilder()
                .SetBasePath(AppContext.BaseDirectory)
                .AddJsonFile("AppSettings.json", optional: true, reloadOnChange: true);

            IConfigurationRoot configuration = builder.Build();

            var apiURL = configuration.GetSection("ApiBaseURL").Value;
            var connStr = configuration.GetSection("ConnectionStrings").GetSection("DefaultConnection").Value;

            var optionsBuilder = new DbContextOptionsBuilder<FBSAContext>();
            optionsBuilder.UseLazyLoadingProxies().UseSqlServer(connStr);
            using (var db = new FBSAContext(optionsBuilder.Options))
            {
                var processo = db.ProcessoEmpresa.FirstOrDefault(o => o.ID == processoId);

                if (processo != null)
                {
                    var empresa = processo.EmpresaInterface;
                    FileUtil.GravaLog("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> PROCESSO: " + processo.ProcessoIntegracao.ToString());

                    var client_key = empresa.Client_Key;
                    var secret_key = empresa.Secret_Key;

                    
                    /*if (processo.ProcessoIntegracao == ProcessoIntegracao.Sacado)
                    {
                        FileUtil.GravaLog("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: SACADO");
                        var sacadoInterface = new SacadoInterface(db,  apiURL, client_key.ToString(), secret_key);
                        sacadoInterface.Sync().Wait();
                    }

                    if (processo.ProcessoIntegracao == ProcessoIntegracao.Boleto)
                    {
                        FileUtil.GravaLog("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: BOLETO");
                        var boletoInterface = new BoletoInterface(db, apiURL, client_key.ToString(), secret_key);
                        boletoInterface.Sync().Wait();
                    }


                    if (processo.ProcessoIntegracao == ProcessoIntegracao.Fornecedor)
                    {
                        FileUtil.GravaLog("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: FORNECEDOR");
                        var fornecedorInterface = new FornecedorInterface(db, apiURL, client_key.ToString(), secret_key);
                        fornecedorInterface.Sync().Wait();
                    }

                    if (processo.ProcessoIntegracao == ProcessoIntegracao.TituloPagar)
                    {
                        FileUtil.GravaLog("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: TITULO PAGAR");
                        var tituloPagarInterface = new TituloPagarInterface(db, apiURL, client_key.ToString(), secret_key);
                        tituloPagarInterface.Sync().Wait();
                    }


                    if (processo.ProcessoIntegracao == ProcessoIntegracao.Antecipacao)
                    {
                        FileUtil.GravaLog("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: Antecipacao");
                        var antecipacaoInterfaceGet = new AntecipacaoInterfaceGet(db,  apiURL, client_key.ToString(), secret_key);
                        antecipacaoInterfaceGet.Sync().Wait();

                        var antecipacaoInterfacePost = new AntecipacaoInterfacePost(db,  apiURL, client_key.ToString(), secret_key);
                        antecipacaoInterfacePost.Sync().Wait();
                    }

                    if (processo.ProcessoIntegracao == ProcessoIntegracao.TaxaFornecedor)
                    {
                        FileUtil.GravaLog("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: Taxa Fornecedor");
                        
                        var taxaFornecedorInterfaceGet = new TaxaFornecedorInterfaceGet(db, apiURL, client_key.ToString(), secret_key);
                        taxaFornecedorInterfaceGet.Sync().Wait();

                        var taxaFornecedorInterfacePost = new TaxaFornecedorInterfacePost(db,  apiURL, client_key.ToString(), secret_key);
                        taxaFornecedorInterfacePost.Sync().Wait();
                    }
                    */
                    /*if (processo.ProcessoIntegracao == ProcessoIntegracao.RPV)
                    {
                        FileUtil.GravaLog("INICIANDO SINCRONISMO - EMPRESA: " + empresa.ChaveUnica + " >>> Entidade: RPV");
                        var rpvInterface = new AtendimentoInterface(db,  apiURL, client_key.ToString(), secret_key);
                        rpvInterface.Sync().Wait();

                        var rpvInterfaceGet = new AtendimentoInterfaceGet(db, apiURL, client_key.ToString(), secret_key);
                        rpvInterfaceGet.Sync().Wait();

                        var rpvInterfacePost = new AtendimentoInterfacePost(db, apiURL, client_key.ToString(), secret_key);
                        rpvInterfacePost.Sync().Wait();
                    }*/

                    processo.LastEditDate = DateTime.Now;
                    db.SaveChanges();
                }
            }
        }
    }
}
