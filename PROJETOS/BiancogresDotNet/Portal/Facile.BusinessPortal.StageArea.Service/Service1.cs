using Facile.BusinessPortal.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.StageArea.Service
{
    public partial class Service1 : ServiceBase
    {
        public Service1()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            //EventLog.WriteEntry("Serviço Iniciado: "+ DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToLongTimeString());
            FileUtil.GravaLog("Serviço Iniciado: " + DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToLongTimeString());
            var robo = new Robo();
            robo.Iniciar();
        }

        protected override void OnStop()
        {
            FileUtil.GravaLog("Serviço Finalizado: " + DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToLongTimeString());
            //EventLog.WriteEntry("Serviço Finalizado: " + DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToLongTimeString());
        }
    }
}
