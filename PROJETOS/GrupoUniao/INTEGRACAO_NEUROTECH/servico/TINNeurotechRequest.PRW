#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TINNeurotechRequest
@description Gerar e enviar request para Serviço Neurotech SOAP
@author Fernando Rocha / Facile Sistemas
@since 03/12/2018
@version 1.0
/*/

Class TINNeurotechRequest From LongClassName

	//Dados parametros  
	Data cOutXML
	Data cInXML
	Data oRetorno
	Data aFluxo
 
	
	Method New() Constructor
	Method PostRequest(oNeurotM)
	Method FluxoVar(oNeurotM)

EndClass


Method New() Class TINNeurotechRequest 
 
    ::cOutXML   := ""
	::cInXML	:= ""
	::oRetorno	:= "" 
	::aFluxo    := {}

Return Self

Method FluxoVar(oNeurotM) Class TINNeurotechRequest

	Local aGrupo := {}
	Local nValPed := oNeurotM:nVlrTotVen
	Local nValSoli := 0
	Local nCredCli := 	oNeurotM:oCliente:nCredCli
	Local oVarNeuro := Nil
	Local oVarNeuD := Nil	
	Local oVarNeuroGr := Nil

    oVarNeuD := TINNeurotechDAO():New()
	oVarNeuro := oVarNeuD:FluxoNeuro(oNeurotM)  



	If oNeurotM:oCliente:nCredCli > oVarNeuro:nVlrTotVen + nValPed
		nValSoli := oNeurotM:oCliente:nCredCli
	Else
		nValSoli := oVarNeuro:nVlrTotVen + nValPed 
	EndIf


	 
	::aFluxo := {;
	{"PROP_COD_TOTVS", oVarNeuro:oCliente:cCodigo+oVarNeuro:oCliente:cLoja},;
	{"PROP_CPF_CNPJ", oVarNeuro:oCliente:cCGC},;
	{"PROP_CLIENTE",oVarNeuro:cTipoClien},;
	{"PROP_CLIENTE_ESPECIAL",IIF(oVarNeuro:oCliente:cRisco == "B","B","")},;
	{"PROP_LIMITE_ATUAL",nCredCli},;
	{"PROP_LIMITE_SOLICITADO",nValSoli},; 
	{"PROP_LOJA", GetNewPar("MV_YPROPLJ","Uniao.Atacado")},; 
	{"PROP_OBSERVACAO",oNeurotM:cObserv},;
	{"PROP_CAPITAL_SOCIAL",""},;
	{"PROP_DATA_NASCIMENTO",""},;
	{"PROP_CODIGO_UNICO_PROPOSTA",oNeurotM:nNumProp},;
	{"PROP_IDADE_FUNDACAO",oVarNeuro:cIdadeFund},;
	{"PROP_UF_EMPRESA",oVarNeuro:cUFEmpresa},;
	{"PROP_TIPO_CONTRIBUINTE",oVarNeuro:cTipoContr},;
	{"PROP_CEP_ENTREGA",oVarNeuro:cCEPEntreg},;
	{"PROP_TEMPO_RELACIONAMENTO",oVarNeuro:nTempRelac},;
	{"PROP_VALOR_COMPRA_ATUAL",nValPed},;
	{"PROP_ATRASO_ATUAL",oVarNeuro:nAtrasoAtu},;
	{"PROP_MDA_HIST",oVarNeuro:nMDAHist},;
	{"PROP_MDA_03M",oVarNeuro:nMDA03m},;
	{"PROP_MDA_12M",oVarNeuro:nMDA12m},;
	{"PROP_VALOR_TOTAL_VENCER",oVarNeuro:nVlrTotVen},;
	{"PROP_TEMPO_ULT_COMPRA",oVarNeuro:nTempUltCo},;
	{"PROP_QTDE_COMPRAS_FEITAS_VISTA",oVarNeuro:nQtdCAVist},;
	{"PROP_VALOR_TOT_COMPRA_REALIZADAS",oVarNeuro:nVlrTotCRe},;
	{"PROP_VALOR_TOT_COMPRA_03M",oVarNeuro:nVlrTotC03},;
	{"PROP_VALOR_TOT_COMPRA_12M",oVarNeuro:nVlrTotC12},;
	{"PROP_QTDE_TOT_COMPRA_03M",oVarNeuro:nQtdTotC03},;
	{"PROP_VALOR_TOT_COMPRA_PRAZO_HIST",oVarNeuro:nVlrTotCPH},;
	{"PROP_QTDE_TOT_COMPRA_PRAZO_HIST",oVarNeuro:nQtdTotCPH},;
	{"PROP_QTDE_TOT_COMPRA_PRAZO_12M",oVarNeuro:nQtdTotC12},;
	{"PROP_QTDE_TOT_CANCELAMENTOS",oVarNeuro:nQtdTotCan},;
	{"PROP_ATRASO_MES01",oVarNeuro:nAtraMes01},;
	{"PROP_ATRASO_MES02",oVarNeuro:nAtraMes02},;
	{"PROP_ATRASO_MES03",oVarNeuro:nAtraMes03},;
	{"PROP_ATRASO_MES04",oVarNeuro:nAtraMes04},;
	{"PROP_ATRASO_MES05",oVarNeuro:nAtraMes05},;
	{"PROP_ATRASO_MES06",oVarNeuro:nAtraMes06},;
	{"PROP_ATRASO_MES07",oVarNeuro:nAtraMes07},;
	{"PROP_ATRASO_MES08",oVarNeuro:nAtraMes08},;
	{"PROP_ATRASO_MES09",oVarNeuro:nAtraMes09},;
	{"PROP_ATRASO_MES10",oVarNeuro:nAtraMes10},;
	{"PROP_ATRASO_MES11",oVarNeuro:nAtraMes11},;
	{"PROP_ATRASO_MES12",oVarNeuro:nAtraMes12},;
	{"PROP_MDA_12MESES",oVarNeuro:nMDA12M}}

	oVarNeuroGr := TINNeurotechDAO():New()
	oVarNeuroGr := oVarNeuroGr:GrpNeurot(oNeurotM) 	

	//--- ok ---
	AADD(::aFluxo,{"PROP_LIMITE_CREDITO_UTILIZADO_GRUPO_ECONOMICO",oVarNeuroGr:nLCredUGE})
	AADD(::aFluxo,{"PROP_DESC_GRUPO_ECONOMICO",oVarNeuroGr:cDescGrEco})
	AADD(::aFluxo,{"PROP_LIMITE_CREDITO_GRUPO_ECONOMICO",oVarNeuroGr:nLCredGrp})
	AADD(::aFluxo,{"PROP_CNPJ_CLIENTE",SUBSTR(oVarNeuroGr:cCGC, 0, (LEN(oVarNeuroGr:cCGC)-1))})
	AADD(::aFluxo,{"PROP_NOME_CLIENTE",SUBSTR(oVarNeuroGr:cNomeClie, 0, (LEN(oVarNeuroGr:cNomeClie)-1))})
	AADD(::aFluxo,{"PROP_LIMITE_CREDITO_CLIENTE",SUBSTR(oVarNeuroGr:nLCredCli, 0, (LEN(oVarNeuroGr:nLCredCli)-1))})
	AADD(::aFluxo,{"PROP_LIMITE_CREDITO_SENDO_UTILIZADO",SUBSTR(oVarNeuroGr:nLCredUlt, 0, (LEN(oVarNeuroGr:nLCredUlt)-1))})


	
	AADD(::aFluxo,{"PROP_TIPO_DO_TITULO",SUBSTR(oVarNeuroGr:cE1TIPO, 0, (LEN(oVarNeuroGr:cE1TIPO)-1))})
	AADD(::aFluxo,{"PROP_NUMERO_DO_TITULO",SUBSTR(oVarNeuroGr:cE1NUM, 0, (LEN(oVarNeuroGr:cE1NUM)-1))})
	AADD(::aFluxo,{"PROP_DATA_DE_EMISSAO",SUBSTR(oVarNeuroGr:cE1EMISSAO, 0, (LEN(oVarNeuroGr:cE1EMISSAO)-1))})
	AADD(::aFluxo,{"PROP_DATA_DE_VENCIMENTO",SUBSTR(oVarNeuroGr:cE1VENCREA, 0, (LEN(oVarNeuroGr:cE1VENCREA)-1))})
	AADD(::aFluxo,{"PROP_VALOR_DO_TITULO",SUBSTR(oVarNeuroGr:cE1VALOR, 0, (LEN(oVarNeuroGr:cE1VALOR)-1))})
	AADD(::aFluxo,{"PROP_DIAS_EM_ATRASO",SUBSTR(oVarNeuroGr:cDiasAtra, 0, (LEN(oVarNeuroGr:cDiasAtra)-1))})
 

Return ::aFluxo




/*/{Protheus.doc} PostRequest
@description Enviar requisicao SOAP para o WS Neurotech - metodo executarFluxoComParametros
@author Fernando Rocha
@since 03/12/2018
@version 1.0
@type function
/*/
Method PostRequest(oNeurotM) Class TINNeurotechRequest

	Local oWSNeu		:= WSWorkflowWebService():New()	 
	Local oWSCreden 	:= WorkflowWebService_CREDENCIAIS():New()
	Local oWSFluxo		:= WorkflowWebService_FLUXO():New()	
	Local oWSParam		:= WorkflowWebService_ARRAYOFPROPRIEDADE():New()   
	Local oWSRet := Nil
	Local oGenerec := Nil 
	Local lRet := .F.
	Local nI := 0


	Begin Sequence
		oWSNeu:_URL	                := GetNewPar("MV_YNURL", "https://dr-hml.neurotech.com.br/services/soap/porting")
		oWSCreden:nCodigoAssociado 	:= GetNewPar("MV_YNCODAS",151)
		oWSCreden:nCodigoFilial 	:= GetNewPar("MV_YNCODFI",34)
		oWSCreden:cSenha			:= GetNewPar("MV_YNSENHA","abcd@1234")

			
		oWSFluxo:cTagVersaoPolitica := "" 
		oWSFluxo:cNmPolitica  		:= GetNewPar("MV_YNPOLIT","FORTBRAS_UNIAO")
		oWSFluxo:cNmFluxoResultado	:= GetNewPar("MV_YNFLX","FLX_PRINCIPAL")
		oWSFluxo:cIdProposta     	:= oNeurotM:oCliente:cCGC
		//oNeuroRet := TINRetornoNeutotech():New(AllTrim(cValToChar(oNeurotM:nNumProp)))

		//FLUXO
		oWSFluxo:oWSLsParametros		:= WorkflowWebService_ArrayOfParametroFluxo():New()
 		
		::FluxoVar(oNeurotM)
		For nI := 1 To Len(::aFluxo)
			oGenerec := WorkflowWebService_ParametroFluxo():New()
			oGenerec:cNmParametro	:= ::aFluxo[nI][1]
			oGenerec:cVlParametro	:= cValToChar(::aFluxo[nI][2])
			AAdd(oWSFluxo:oWSLsParametros:oWSParametroFluxo , oGenerec)
		Next nI
	
		//Parametros	
		oGenerec := WorkflowWebService_PROPRIEDADE():New()
		oGenerec:cNome	:= GetNewPar("MV_YNUSER","USUARIO")
		oGenerec:cValor	:= GetNewPar("MV_YNPOLIT","FORTBRAS_UNIAO")
		AAdd(oWSParam:oWSPropriedade, oGenerec)
		
		oGenerec := WorkflowWebService_PROPRIEDADE():New()
		oGenerec:cNome	:= "RETORNO_FILTRO_MODO"
		oGenerec:cValor	:= "inclusao"
		AAdd(oWSParam:oWSPropriedade, oGenerec)
		
		oGenerec := WorkflowWebService_PROPRIEDADE():New()
		oGenerec:cNome	:= "RETORNO_FILTRO_REGEXES"
		oGenerec:cValor	:= "RET_.*;FLX_.*"

		oGenerec := WorkflowWebService_PROPRIEDADE():New()
		oGenerec:cNome	:= "RETORNO_FILTRO_VARIAVEIS"
		oGenerec:cValor	:= "VI_NEUROTECH_CD_OPERACAO"

		AAdd(oWSParam:oWSPropriedade, oGenerec)


		cReturn := oWSNeu:executarFluxoComParametros(oWSCreden, oWSFluxo, oWSParam)
		::oRetorno := oWSNeu:oWSexecutarFluxoComParametrosResult

		If !EMPTY(::oRetorno:NCDOPERACAO)

			::cOutXML  := cReturn
			::cInXML   := FWJsonSerialize(::oRetorno ,.T.,.T.)
	
		EndIf
				
	End Sequence

Return 
