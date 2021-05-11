//------------------------------------------------------------------------------
// <gerado automaticamente>
//     Esse código foi gerado por uma ferramenta.
//     //
//     As alterações no arquivo poderão causar comportamento incorreto e serão perdidas se
//     o código for gerado novamente.
// </gerado automaticamente>
//------------------------------------------------------------------------------

namespace WsProtheusAntecipacaoPagamento
{
    
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("dotnet-svcutil", "1.0.0.0")]
    [System.ServiceModel.ServiceContractAttribute(Namespace="http://192.168.20.7:6879/", ConfigurationName="WsProtheusAntecipacaoPagamento.ANTECIPACAOPAGAMENTOSOAP")]
    public interface ANTECIPACAOPAGAMENTOSOAP
    {
        
        [System.ServiceModel.OperationContractAttribute(Action="http://192.168.20.7:6879/INCLUIR", ReplyAction="*")]
        [System.ServiceModel.XmlSerializerFormatAttribute(SupportFaults=true)]
        System.Threading.Tasks.Task<WsProtheusAntecipacaoPagamento.INCLUIRResponse> INCLUIRAsync(WsProtheusAntecipacaoPagamento.INCLUIRRequest request);
    }
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("dotnet-svcutil", "1.0.0.0")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.Xml.Serialization.XmlTypeAttribute(Namespace="http://192.168.20.7:6879/")]
    public partial class ANTECIPACAOENTRADA
    {
        
        private ANTECIPACAOITEMENTRADA[] aNTECIPACAOITEMField;
        
        private System.DateTime dATARECEBIMENTOField;
        
        private string eMPRESAField;
        
        private string fILIALField;
        
        /// <remarks/>
        [System.Xml.Serialization.XmlArrayAttribute(Order=0)]
        [System.Xml.Serialization.XmlArrayItemAttribute(IsNullable=false)]
        public ANTECIPACAOITEMENTRADA[] ANTECIPACAOITEM
        {
            get
            {
                return this.aNTECIPACAOITEMField;
            }
            set
            {
                this.aNTECIPACAOITEMField = value;
            }
        }
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(DataType="date", Order=1)]
        public System.DateTime DATARECEBIMENTO
        {
            get
            {
                return this.dATARECEBIMENTOField;
            }
            set
            {
                this.dATARECEBIMENTOField = value;
            }
        }
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Order=2)]
        public string EMPRESA
        {
            get
            {
                return this.eMPRESAField;
            }
            set
            {
                this.eMPRESAField = value;
            }
        }
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Order=3)]
        public string FILIAL
        {
            get
            {
                return this.fILIALField;
            }
            set
            {
                this.fILIALField = value;
            }
        }
    }
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("dotnet-svcutil", "1.0.0.0")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.Xml.Serialization.XmlTypeAttribute(Namespace="http://192.168.20.7:6879/")]
    public partial class ANTECIPACAOITEMENTRADA
    {
        
        private float dESCONTOField;
        
        private string iDTITULOField;
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Order=0)]
        public float DESCONTO
        {
            get
            {
                return this.dESCONTOField;
            }
            set
            {
                this.dESCONTOField = value;
            }
        }
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(DataType="integer", Order=1)]
        public string IDTITULO
        {
            get
            {
                return this.iDTITULOField;
            }
            set
            {
                this.iDTITULOField = value;
            }
        }
    }
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("dotnet-svcutil", "1.0.0.0")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.Xml.Serialization.XmlTypeAttribute(Namespace="http://192.168.20.7:6879/")]
    public partial class RESPOSTA
    {
        
        private string lOGMENSAGEMField;
        
        private string mENSAGEMField;
        
        private bool sTATUSField;
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Order=0)]
        public string LOGMENSAGEM
        {
            get
            {
                return this.lOGMENSAGEMField;
            }
            set
            {
                this.lOGMENSAGEMField = value;
            }
        }
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Order=1)]
        public string MENSAGEM
        {
            get
            {
                return this.mENSAGEMField;
            }
            set
            {
                this.mENSAGEMField = value;
            }
        }
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(Order=2)]
        public bool STATUS
        {
            get
            {
                return this.sTATUSField;
            }
            set
            {
                this.sTATUSField = value;
            }
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("dotnet-svcutil", "1.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="INCLUIR", WrapperNamespace="http://192.168.20.7:6879/", IsWrapped=true)]
    public partial class INCLUIRRequest
    {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://192.168.20.7:6879/", Order=0)]
        public WsProtheusAntecipacaoPagamento.ANTECIPACAOENTRADA ANTECIPACAOENTRADA;
        
        public INCLUIRRequest()
        {
        }
        
        public INCLUIRRequest(WsProtheusAntecipacaoPagamento.ANTECIPACAOENTRADA ANTECIPACAOENTRADA)
        {
            this.ANTECIPACAOENTRADA = ANTECIPACAOENTRADA;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("dotnet-svcutil", "1.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="INCLUIRRESPONSE", WrapperNamespace="http://192.168.20.7:6879/", IsWrapped=true)]
    public partial class INCLUIRResponse
    {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://192.168.20.7:6879/", Order=0)]
        public WsProtheusAntecipacaoPagamento.RESPOSTA INCLUIRRESULT;
        
        public INCLUIRResponse()
        {
        }
        
        public INCLUIRResponse(WsProtheusAntecipacaoPagamento.RESPOSTA INCLUIRRESULT)
        {
            this.INCLUIRRESULT = INCLUIRRESULT;
        }
    }
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("dotnet-svcutil", "1.0.0.0")]
    public interface ANTECIPACAOPAGAMENTOSOAPChannel : WsProtheusAntecipacaoPagamento.ANTECIPACAOPAGAMENTOSOAP, System.ServiceModel.IClientChannel
    {
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("dotnet-svcutil", "1.0.0.0")]
    public partial class ANTECIPACAOPAGAMENTOSOAPClient : System.ServiceModel.ClientBase<WsProtheusAntecipacaoPagamento.ANTECIPACAOPAGAMENTOSOAP>, WsProtheusAntecipacaoPagamento.ANTECIPACAOPAGAMENTOSOAP
    {
        
    /// <summary>
    /// Implemente este método parcial para configurar o ponto de extremidade de serviço.
    /// </summary>
    /// <param name="serviceEndpoint">O ponto de extremidade a ser configurado</param>
    /// <param name="clientCredentials">As credenciais do cliente</param>
    static partial void ConfigureEndpoint(System.ServiceModel.Description.ServiceEndpoint serviceEndpoint, System.ServiceModel.Description.ClientCredentials clientCredentials);
        
        public ANTECIPACAOPAGAMENTOSOAPClient() : 
                base(ANTECIPACAOPAGAMENTOSOAPClient.GetDefaultBinding(), ANTECIPACAOPAGAMENTOSOAPClient.GetDefaultEndpointAddress())
        {
            this.Endpoint.Name = EndpointConfiguration.ANTECIPACAOPAGAMENTOSOAP.ToString();
            ConfigureEndpoint(this.Endpoint, this.ClientCredentials);
        }
        
        public ANTECIPACAOPAGAMENTOSOAPClient(EndpointConfiguration endpointConfiguration) : 
                base(ANTECIPACAOPAGAMENTOSOAPClient.GetBindingForEndpoint(endpointConfiguration), ANTECIPACAOPAGAMENTOSOAPClient.GetEndpointAddress(endpointConfiguration))
        {
            this.Endpoint.Name = endpointConfiguration.ToString();
            ConfigureEndpoint(this.Endpoint, this.ClientCredentials);
        }
        
        public ANTECIPACAOPAGAMENTOSOAPClient(EndpointConfiguration endpointConfiguration, string remoteAddress) : 
                base(ANTECIPACAOPAGAMENTOSOAPClient.GetBindingForEndpoint(endpointConfiguration), new System.ServiceModel.EndpointAddress(remoteAddress))
        {
            this.Endpoint.Name = endpointConfiguration.ToString();
            ConfigureEndpoint(this.Endpoint, this.ClientCredentials);
        }
        
        public ANTECIPACAOPAGAMENTOSOAPClient(EndpointConfiguration endpointConfiguration, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(ANTECIPACAOPAGAMENTOSOAPClient.GetBindingForEndpoint(endpointConfiguration), remoteAddress)
        {
            this.Endpoint.Name = endpointConfiguration.ToString();
            ConfigureEndpoint(this.Endpoint, this.ClientCredentials);
        }
        
        public ANTECIPACAOPAGAMENTOSOAPClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(binding, remoteAddress)
        {
        }
        
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
        System.Threading.Tasks.Task<WsProtheusAntecipacaoPagamento.INCLUIRResponse> WsProtheusAntecipacaoPagamento.ANTECIPACAOPAGAMENTOSOAP.INCLUIRAsync(WsProtheusAntecipacaoPagamento.INCLUIRRequest request)
        {
            return base.Channel.INCLUIRAsync(request);
        }
        
        public System.Threading.Tasks.Task<WsProtheusAntecipacaoPagamento.INCLUIRResponse> INCLUIRAsync(WsProtheusAntecipacaoPagamento.ANTECIPACAOENTRADA ANTECIPACAOENTRADA)
        {
            WsProtheusAntecipacaoPagamento.INCLUIRRequest inValue = new WsProtheusAntecipacaoPagamento.INCLUIRRequest();
            inValue.ANTECIPACAOENTRADA = ANTECIPACAOENTRADA;
            return ((WsProtheusAntecipacaoPagamento.ANTECIPACAOPAGAMENTOSOAP)(this)).INCLUIRAsync(inValue);
        }
        
        public virtual System.Threading.Tasks.Task OpenAsync()
        {
            return System.Threading.Tasks.Task.Factory.FromAsync(((System.ServiceModel.ICommunicationObject)(this)).BeginOpen(null, null), new System.Action<System.IAsyncResult>(((System.ServiceModel.ICommunicationObject)(this)).EndOpen));
        }
        
        public virtual System.Threading.Tasks.Task CloseAsync()
        {
            return System.Threading.Tasks.Task.Factory.FromAsync(((System.ServiceModel.ICommunicationObject)(this)).BeginClose(null, null), new System.Action<System.IAsyncResult>(((System.ServiceModel.ICommunicationObject)(this)).EndClose));
        }
        
        private static System.ServiceModel.Channels.Binding GetBindingForEndpoint(EndpointConfiguration endpointConfiguration)
        {
            if ((endpointConfiguration == EndpointConfiguration.ANTECIPACAOPAGAMENTOSOAP))
            {
                System.ServiceModel.BasicHttpBinding result = new System.ServiceModel.BasicHttpBinding();
                result.MaxBufferSize = int.MaxValue;
                result.ReaderQuotas = System.Xml.XmlDictionaryReaderQuotas.Max;
                result.MaxReceivedMessageSize = int.MaxValue;
                result.AllowCookies = true;
                return result;
            }
            throw new System.InvalidOperationException(string.Format("Não foi possível encontrar o ponto de extremidade com o nome \'{0}\'.", endpointConfiguration));
        }
        
        private static System.ServiceModel.EndpointAddress GetEndpointAddress(EndpointConfiguration endpointConfiguration)
        {
            if ((endpointConfiguration == EndpointConfiguration.ANTECIPACAOPAGAMENTOSOAP))
            {
                return new System.ServiceModel.EndpointAddress("http://192.168.20.7:6879/ws01/ANTECIPACAOPAGAMENTO.apw");
            }
            throw new System.InvalidOperationException(string.Format("Não foi possível encontrar o ponto de extremidade com o nome \'{0}\'.", endpointConfiguration));
        }
        
        private static System.ServiceModel.Channels.Binding GetDefaultBinding()
        {
            return ANTECIPACAOPAGAMENTOSOAPClient.GetBindingForEndpoint(EndpointConfiguration.ANTECIPACAOPAGAMENTOSOAP);
        }
        
        private static System.ServiceModel.EndpointAddress GetDefaultEndpointAddress()
        {
            return ANTECIPACAOPAGAMENTOSOAPClient.GetEndpointAddress(EndpointConfiguration.ANTECIPACAOPAGAMENTOSOAP);
        }
        
        public enum EndpointConfiguration
        {
            
            ANTECIPACAOPAGAMENTOSOAP,
        }
    }
}
