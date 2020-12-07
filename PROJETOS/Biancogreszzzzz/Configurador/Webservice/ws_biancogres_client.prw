#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://srv_web_protheus:6868/ws01/BIANCO_BIZAGI.apw?WSDL
Gerado em        01/05/18 09:39:40
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _FNFSFUA ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSBIANCO_BIZAGI
------------------------------------------------------------------------------- */
WSCLIENT WSBIANCO_BIZAGI

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ATUALIZACOTACAO
	WSMETHOD PUTCLIENTE
	WSMETHOD PUTEMBALAGEMALTERACAO
	WSMETHOD PUTEMBALAGEMINCLUSAO
	WSMETHOD PUTNOVOPRODUTO
	WSMETHOD PUTSOLICCREDITO
	WSMETHOD PUTSOLICITACAOCOMPRA
	WSMETHOD PUTTABELAPRECO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSOCOTACAO               AS BIANCO_BIZAGI_COTACAO
	WSDATA   oWSATUALIZACOTACAORESULT  AS BIANCO_BIZAGI_RESULTADO
	WSDATA   oWSOCLIENTE               AS BIANCO_BIZAGI_CLIENTE
	WSDATA   oWSPUTCLIENTERESULT       AS BIANCO_BIZAGI_RESULTADO
	WSDATA   oWSOEMBALTERACAO          AS BIANCO_BIZAGI_EMBALAGEMALTERACAO
	WSDATA   oWSPUTEMBALAGEMALTERACAORESULT AS BIANCO_BIZAGI_RESULTADO
	WSDATA   oWSOEMBINCLUSAO           AS BIANCO_BIZAGI_EMBALAGEMINCLUSAO
	WSDATA   oWSPUTEMBALAGEMINCLUSAORESULT AS BIANCO_BIZAGI_RESULTADO
	WSDATA   oWSLP                     AS BIANCO_BIZAGI_NOVALISTAPRODUTOS
	WSDATA   oWSPUTNOVOPRODUTORESULT   AS BIANCO_BIZAGI_RESULTADO
	WSDATA   oWSOSOLICCREDITO          AS BIANCO_BIZAGI_SOLICCREDITO
	WSDATA   oWSPUTSOLICCREDITORESULT  AS BIANCO_BIZAGI_RESULTADO
	WSDATA   oWSSC                     AS BIANCO_BIZAGI_SOLICITACAOCOMPRA
	WSDATA   oWSPUTSOLICITACAOCOMPRARESULT AS BIANCO_BIZAGI_RESULTADO
	WSDATA   oWSOTABPRECO              AS BIANCO_BIZAGI_TABELAPRECO
	WSDATA   oWSPUTTABELAPRECORESULT   AS BIANCO_BIZAGI_RESULTADO

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSCOTACAO                AS BIANCO_BIZAGI_COTACAO
	WSDATA   oWSCLIENTE                AS BIANCO_BIZAGI_CLIENTE
	WSDATA   oWSEMBALAGEMALTERACAO     AS BIANCO_BIZAGI_EMBALAGEMALTERACAO
	WSDATA   oWSEMBALAGEMINCLUSAO      AS BIANCO_BIZAGI_EMBALAGEMINCLUSAO
	WSDATA   oWSNOVALISTAPRODUTOS      AS BIANCO_BIZAGI_NOVALISTAPRODUTOS
	WSDATA   oWSSOLICCREDITO           AS BIANCO_BIZAGI_SOLICCREDITO
	WSDATA   oWSSOLICITACAOCOMPRA      AS BIANCO_BIZAGI_SOLICITACAOCOMPRA
	WSDATA   oWSTABELAPRECO            AS BIANCO_BIZAGI_TABELAPRECO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSBIANCO_BIZAGI
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20190114 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSBIANCO_BIZAGI
	::oWSOCOTACAO        := BIANCO_BIZAGI_COTACAO():New()
	::oWSATUALIZACOTACAORESULT := BIANCO_BIZAGI_RESULTADO():New()
	::oWSOCLIENTE        := BIANCO_BIZAGI_CLIENTE():New()
	::oWSPUTCLIENTERESULT := BIANCO_BIZAGI_RESULTADO():New()
	::oWSOEMBALTERACAO   := BIANCO_BIZAGI_EMBALAGEMALTERACAO():New()
	::oWSPUTEMBALAGEMALTERACAORESULT := BIANCO_BIZAGI_RESULTADO():New()
	::oWSOEMBINCLUSAO    := BIANCO_BIZAGI_EMBALAGEMINCLUSAO():New()
	::oWSPUTEMBALAGEMINCLUSAORESULT := BIANCO_BIZAGI_RESULTADO():New()
	::oWSLP              := BIANCO_BIZAGI_NOVALISTAPRODUTOS():New()
	::oWSPUTNOVOPRODUTORESULT := BIANCO_BIZAGI_RESULTADO():New()
	::oWSOSOLICCREDITO   := BIANCO_BIZAGI_SOLICCREDITO():New()
	::oWSPUTSOLICCREDITORESULT := BIANCO_BIZAGI_RESULTADO():New()
	::oWSSC              := BIANCO_BIZAGI_SOLICITACAOCOMPRA():New()
	::oWSPUTSOLICITACAOCOMPRARESULT := BIANCO_BIZAGI_RESULTADO():New()
	::oWSOTABPRECO       := BIANCO_BIZAGI_TABELAPRECO():New()
	::oWSPUTTABELAPRECORESULT := BIANCO_BIZAGI_RESULTADO():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSCOTACAO         := ::oWSOCOTACAO
	::oWSCLIENTE         := ::oWSOCLIENTE
	::oWSEMBALAGEMALTERACAO := ::oWSOEMBALTERACAO
	::oWSEMBALAGEMINCLUSAO := ::oWSOEMBINCLUSAO
	::oWSNOVALISTAPRODUTOS := ::oWSLP
	::oWSSOLICCREDITO    := ::oWSOSOLICCREDITO
	::oWSSOLICITACAOCOMPRA := ::oWSSC
	::oWSTABELAPRECO     := ::oWSOTABPRECO
Return

WSMETHOD RESET WSCLIENT WSBIANCO_BIZAGI
	::oWSOCOTACAO        := NIL 
	::oWSATUALIZACOTACAORESULT := NIL 
	::oWSOCLIENTE        := NIL 
	::oWSPUTCLIENTERESULT := NIL 
	::oWSOEMBALTERACAO   := NIL 
	::oWSPUTEMBALAGEMALTERACAORESULT := NIL 
	::oWSOEMBINCLUSAO    := NIL 
	::oWSPUTEMBALAGEMINCLUSAORESULT := NIL 
	::oWSLP              := NIL 
	::oWSPUTNOVOPRODUTORESULT := NIL 
	::oWSOSOLICCREDITO   := NIL 
	::oWSPUTSOLICCREDITORESULT := NIL 
	::oWSSC              := NIL 
	::oWSPUTSOLICITACAOCOMPRARESULT := NIL 
	::oWSOTABPRECO       := NIL 
	::oWSPUTTABELAPRECORESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSCOTACAO         := NIL
	::oWSCLIENTE         := NIL
	::oWSEMBALAGEMALTERACAO := NIL
	::oWSEMBALAGEMINCLUSAO := NIL
	::oWSNOVALISTAPRODUTOS := NIL
	::oWSSOLICCREDITO    := NIL
	::oWSSOLICITACAOCOMPRA := NIL
	::oWSTABELAPRECO     := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSBIANCO_BIZAGI
Local oClone := WSBIANCO_BIZAGI():New()
	oClone:_URL          := ::_URL 
	oClone:oWSOCOTACAO   :=  IIF(::oWSOCOTACAO = NIL , NIL ,::oWSOCOTACAO:Clone() )
	oClone:oWSATUALIZACOTACAORESULT :=  IIF(::oWSATUALIZACOTACAORESULT = NIL , NIL ,::oWSATUALIZACOTACAORESULT:Clone() )
	oClone:oWSOCLIENTE   :=  IIF(::oWSOCLIENTE = NIL , NIL ,::oWSOCLIENTE:Clone() )
	oClone:oWSPUTCLIENTERESULT :=  IIF(::oWSPUTCLIENTERESULT = NIL , NIL ,::oWSPUTCLIENTERESULT:Clone() )
	oClone:oWSOEMBALTERACAO :=  IIF(::oWSOEMBALTERACAO = NIL , NIL ,::oWSOEMBALTERACAO:Clone() )
	oClone:oWSPUTEMBALAGEMALTERACAORESULT :=  IIF(::oWSPUTEMBALAGEMALTERACAORESULT = NIL , NIL ,::oWSPUTEMBALAGEMALTERACAORESULT:Clone() )
	oClone:oWSOEMBINCLUSAO :=  IIF(::oWSOEMBINCLUSAO = NIL , NIL ,::oWSOEMBINCLUSAO:Clone() )
	oClone:oWSPUTEMBALAGEMINCLUSAORESULT :=  IIF(::oWSPUTEMBALAGEMINCLUSAORESULT = NIL , NIL ,::oWSPUTEMBALAGEMINCLUSAORESULT:Clone() )
	oClone:oWSLP         :=  IIF(::oWSLP = NIL , NIL ,::oWSLP:Clone() )
	oClone:oWSPUTNOVOPRODUTORESULT :=  IIF(::oWSPUTNOVOPRODUTORESULT = NIL , NIL ,::oWSPUTNOVOPRODUTORESULT:Clone() )
	oClone:oWSOSOLICCREDITO :=  IIF(::oWSOSOLICCREDITO = NIL , NIL ,::oWSOSOLICCREDITO:Clone() )
	oClone:oWSPUTSOLICCREDITORESULT :=  IIF(::oWSPUTSOLICCREDITORESULT = NIL , NIL ,::oWSPUTSOLICCREDITORESULT:Clone() )
	oClone:oWSSC         :=  IIF(::oWSSC = NIL , NIL ,::oWSSC:Clone() )
	oClone:oWSPUTSOLICITACAOCOMPRARESULT :=  IIF(::oWSPUTSOLICITACAOCOMPRARESULT = NIL , NIL ,::oWSPUTSOLICITACAOCOMPRARESULT:Clone() )
	oClone:oWSOTABPRECO  :=  IIF(::oWSOTABPRECO = NIL , NIL ,::oWSOTABPRECO:Clone() )
	oClone:oWSPUTTABELAPRECORESULT :=  IIF(::oWSPUTTABELAPRECORESULT = NIL , NIL ,::oWSPUTTABELAPRECORESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSCOTACAO    := oClone:oWSOCOTACAO
	oClone:oWSCLIENTE    := oClone:oWSOCLIENTE
	oClone:oWSEMBALAGEMALTERACAO := oClone:oWSOEMBALTERACAO
	oClone:oWSEMBALAGEMINCLUSAO := oClone:oWSOEMBINCLUSAO
	oClone:oWSNOVALISTAPRODUTOS := oClone:oWSLP
	oClone:oWSSOLICCREDITO := oClone:oWSOSOLICCREDITO
	oClone:oWSSOLICITACAOCOMPRA := oClone:oWSSC
	oClone:oWSTABELAPRECO := oClone:oWSOTABPRECO
Return oClone

// WSDL Method ATUALIZACOTACAO of Service WSBIANCO_BIZAGI

WSMETHOD ATUALIZACOTACAO WSSEND oWSOCOTACAO WSRECEIVE oWSATUALIZACOTACAORESULT WSCLIENT WSBIANCO_BIZAGI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ATUALIZACOTACAO xmlns="http://srv_web_protheus:6868/">'
cSoap += WSSoapValue("OCOTACAO", ::oWSOCOTACAO, oWSOCOTACAO , "COTACAO", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ATUALIZACOTACAO>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://srv_web_protheus:6868/ATUALIZACOTACAO",; 
	"DOCUMENT","http://srv_web_protheus:6868/",,"1.031217",; 
	"http://srv_web_protheus:6868/ws01/BIANCO_BIZAGI.apw")

::Init()
::oWSATUALIZACOTACAORESULT:SoapRecv( WSAdvValue( oXmlRet,"_ATUALIZACOTACAORESPONSE:_ATUALIZACOTACAORESULT","RESULTADO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PUTCLIENTE of Service WSBIANCO_BIZAGI

WSMETHOD PUTCLIENTE WSSEND oWSOCLIENTE WSRECEIVE oWSPUTCLIENTERESULT WSCLIENT WSBIANCO_BIZAGI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTCLIENTE xmlns="http://srv_web_protheus:6868/">'
cSoap += WSSoapValue("OCLIENTE", ::oWSOCLIENTE, oWSOCLIENTE , "CLIENTE", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PUTCLIENTE>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://srv_web_protheus:6868/PUTCLIENTE",; 
	"DOCUMENT","http://srv_web_protheus:6868/",,"1.031217",; 
	"http://srv_web_protheus:6868/ws01/BIANCO_BIZAGI.apw")

::Init()
::oWSPUTCLIENTERESULT:SoapRecv( WSAdvValue( oXmlRet,"_PUTCLIENTERESPONSE:_PUTCLIENTERESULT","RESULTADO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PUTEMBALAGEMALTERACAO of Service WSBIANCO_BIZAGI

WSMETHOD PUTEMBALAGEMALTERACAO WSSEND oWSOEMBALTERACAO WSRECEIVE oWSPUTEMBALAGEMALTERACAORESULT WSCLIENT WSBIANCO_BIZAGI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTEMBALAGEMALTERACAO xmlns="http://srv_web_protheus:6868/">'
cSoap += WSSoapValue("OEMBALTERACAO", ::oWSOEMBALTERACAO, oWSOEMBALTERACAO , "EMBALAGEMALTERACAO", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PUTEMBALAGEMALTERACAO>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://srv_web_protheus:6868/PUTEMBALAGEMALTERACAO",; 
	"DOCUMENT","http://srv_web_protheus:6868/",,"1.031217",; 
	"http://srv_web_protheus:6868/ws01/BIANCO_BIZAGI.apw")

::Init()
::oWSPUTEMBALAGEMALTERACAORESULT:SoapRecv( WSAdvValue( oXmlRet,"_PUTEMBALAGEMALTERACAORESPONSE:_PUTEMBALAGEMALTERACAORESULT","RESULTADO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PUTEMBALAGEMINCLUSAO of Service WSBIANCO_BIZAGI

WSMETHOD PUTEMBALAGEMINCLUSAO WSSEND oWSOEMBINCLUSAO WSRECEIVE oWSPUTEMBALAGEMINCLUSAORESULT WSCLIENT WSBIANCO_BIZAGI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTEMBALAGEMINCLUSAO xmlns="http://srv_web_protheus:6868/">'
cSoap += WSSoapValue("OEMBINCLUSAO", ::oWSOEMBINCLUSAO, oWSOEMBINCLUSAO , "EMBALAGEMINCLUSAO", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PUTEMBALAGEMINCLUSAO>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://srv_web_protheus:6868/PUTEMBALAGEMINCLUSAO",; 
	"DOCUMENT","http://srv_web_protheus:6868/",,"1.031217",; 
	"http://srv_web_protheus:6868/ws01/BIANCO_BIZAGI.apw")

::Init()
::oWSPUTEMBALAGEMINCLUSAORESULT:SoapRecv( WSAdvValue( oXmlRet,"_PUTEMBALAGEMINCLUSAORESPONSE:_PUTEMBALAGEMINCLUSAORESULT","RESULTADO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PUTNOVOPRODUTO of Service WSBIANCO_BIZAGI

WSMETHOD PUTNOVOPRODUTO WSSEND oWSLP WSRECEIVE oWSPUTNOVOPRODUTORESULT WSCLIENT WSBIANCO_BIZAGI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTNOVOPRODUTO xmlns="http://srv_web_protheus:6868/">'
cSoap += WSSoapValue("LP", ::oWSLP, oWSLP , "NOVALISTAPRODUTOS", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PUTNOVOPRODUTO>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://srv_web_protheus:6868/PUTNOVOPRODUTO",; 
	"DOCUMENT","http://srv_web_protheus:6868/",,"1.031217",; 
	"http://srv_web_protheus:6868/ws01/BIANCO_BIZAGI.apw")

::Init()
::oWSPUTNOVOPRODUTORESULT:SoapRecv( WSAdvValue( oXmlRet,"_PUTNOVOPRODUTORESPONSE:_PUTNOVOPRODUTORESULT","RESULTADO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PUTSOLICCREDITO of Service WSBIANCO_BIZAGI

WSMETHOD PUTSOLICCREDITO WSSEND oWSOSOLICCREDITO WSRECEIVE oWSPUTSOLICCREDITORESULT WSCLIENT WSBIANCO_BIZAGI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTSOLICCREDITO xmlns="http://srv_web_protheus:6868/">'
cSoap += WSSoapValue("OSOLICCREDITO", ::oWSOSOLICCREDITO, oWSOSOLICCREDITO , "SOLICCREDITO", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PUTSOLICCREDITO>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://srv_web_protheus:6868/PUTSOLICCREDITO",; 
	"DOCUMENT","http://srv_web_protheus:6868/",,"1.031217",; 
	"http://srv_web_protheus:6868/ws01/BIANCO_BIZAGI.apw")

::Init()
::oWSPUTSOLICCREDITORESULT:SoapRecv( WSAdvValue( oXmlRet,"_PUTSOLICCREDITORESPONSE:_PUTSOLICCREDITORESULT","RESULTADO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PUTSOLICITACAOCOMPRA of Service WSBIANCO_BIZAGI

WSMETHOD PUTSOLICITACAOCOMPRA WSSEND oWSSC WSRECEIVE oWSPUTSOLICITACAOCOMPRARESULT WSCLIENT WSBIANCO_BIZAGI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTSOLICITACAOCOMPRA xmlns="http://srv_web_protheus:6868/">'
cSoap += WSSoapValue("SC", ::oWSSC, oWSSC , "SOLICITACAOCOMPRA", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PUTSOLICITACAOCOMPRA>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://srv_web_protheus:6868/PUTSOLICITACAOCOMPRA",; 
	"DOCUMENT","http://srv_web_protheus:6868/",,"1.031217",; 
	"http://srv_web_protheus:6868/ws01/BIANCO_BIZAGI.apw")

::Init()
::oWSPUTSOLICITACAOCOMPRARESULT:SoapRecv( WSAdvValue( oXmlRet,"_PUTSOLICITACAOCOMPRARESPONSE:_PUTSOLICITACAOCOMPRARESULT","RESULTADO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PUTTABELAPRECO of Service WSBIANCO_BIZAGI

WSMETHOD PUTTABELAPRECO WSSEND oWSOTABPRECO WSRECEIVE oWSPUTTABELAPRECORESULT WSCLIENT WSBIANCO_BIZAGI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTTABELAPRECO xmlns="http://srv_web_protheus:6868/">'
cSoap += WSSoapValue("OTABPRECO", ::oWSOTABPRECO, oWSOTABPRECO , "TABELAPRECO", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PUTTABELAPRECO>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://srv_web_protheus:6868/PUTTABELAPRECO",; 
	"DOCUMENT","http://srv_web_protheus:6868/",,"1.031217",; 
	"http://srv_web_protheus:6868/ws01/BIANCO_BIZAGI.apw")

::Init()
::oWSPUTTABELAPRECORESULT:SoapRecv( WSAdvValue( oXmlRet,"_PUTTABELAPRECORESPONSE:_PUTTABELAPRECORESULT","RESULTADO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure COTACAO

WSSTRUCT BIANCO_BIZAGI_COTACAO
	WSDATA   oWSCABECALHO              AS BIANCO_BIZAGI_CABECALHOCOTACAO
	WSDATA   oWSITEM                   AS BIANCO_BIZAGI_ARRAYOFITEMCOTACAO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_COTACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_COTACAO
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_COTACAO
	Local oClone := BIANCO_BIZAGI_COTACAO():NEW()
	oClone:oWSCABECALHO         := IIF(::oWSCABECALHO = NIL , NIL , ::oWSCABECALHO:Clone() )
	oClone:oWSITEM              := IIF(::oWSITEM = NIL , NIL , ::oWSITEM:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_COTACAO
	Local cSoap := ""
	cSoap += WSSoapValue("CABECALHO", ::oWSCABECALHO, ::oWSCABECALHO , "CABECALHOCOTACAO", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ITEM", ::oWSITEM, ::oWSITEM , "ARRAYOFITEMCOTACAO", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure RESULTADO

WSSTRUCT BIANCO_BIZAGI_RESULTADO
	WSDATA   cCODIGO                   AS string
	WSDATA   cERRO                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_RESULTADO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_RESULTADO
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_RESULTADO
	Local oClone := BIANCO_BIZAGI_RESULTADO():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cERRO                := ::cERRO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT BIANCO_BIZAGI_RESULTADO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cERRO              :=  WSAdvValue( oResponse,"_ERRO","string",NIL,"Property cERRO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure CLIENTE

WSSTRUCT BIANCO_BIZAGI_CLIENTE
	WSDATA   cAVALIACLIENTE            AS string OPTIONAL
	WSDATA   cBACENCODPAIS             AS string
	WSDATA   cCATEGORIA                AS string OPTIONAL
	WSDATA   cCNPJCPF                  AS string
	WSDATA   cCOBBAIRRO                AS string
	WSDATA   cCOBCEP                   AS string
	WSDATA   cCOBEND                   AS string
	WSDATA   cCOBMUN                   AS string
	WSDATA   cCOBNUM                   AS string
	WSDATA   cCOBTPLOG                 AS string OPTIONAL
	WSDATA   cCOBUF                    AS string
	WSDATA   cCODIGO                   AS string OPTIONAL
	WSDATA   cCODMUNZONAFRANCA         AS string OPTIONAL
	WSDATA   cCODREPRESENBELLACASA     AS string OPTIONAL
	WSDATA   cCODREPRESENBIANCO        AS string OPTIONAL
	WSDATA   cCODREPRESENINCESA        AS string OPTIONAL
	WSDATA   cCODREPRESENMUNDIALLI     AS string OPTIONAL
	WSDATA   cCODREPRESENVITCER        AS string OPTIONAL
	WSDATA   cCONTATO                  AS string OPTIONAL
	WSDATA   cDATAVENCLIMITE           AS string OPTIONAL
	WSDATA   cDESCONTOSUFRAMA          AS string OPTIONAL
	WSDATA   cEHCADEXPRES              AS string OPTIONAL
	WSDATA   cEHCONTRIB                AS string
	WSDATA   cEMAILCOBR                AS string OPTIONAL
	WSDATA   cEMAILCONT                AS string OPTIONAL
	WSDATA   cEMAILNF                  AS string
	WSDATA   cENDBAIRRO                AS string
	WSDATA   cENDCEP                   AS string
	WSDATA   cENDCODMUN                AS string
	WSDATA   cENDCOMPLEMENTO           AS string OPTIONAL
	WSDATA   cENDDESC                  AS string
	WSDATA   cENDMUN                   AS string
	WSDATA   cENDNUM                   AS string
	WSDATA   cENDPAIS                  AS string
	WSDATA   cENDTPLOG                 AS string OPTIONAL
	WSDATA   cENDUF                    AS string
	WSDATA   cFAX                      AS string OPTIONAL
	WSDATA   cFOMEZERO                 AS string
	WSDATA   cGRUPOLIMITE              AS string OPTIONAL
	WSDATA   cHOMEPAGE                 AS string OPTIONAL
	WSDATA   cINSCEST                  AS string
	WSDATA   cLIMITECREDITO            AS string OPTIONAL
	WSDATA   cLOJA                     AS string
	WSDATA   cNOME                     AS string
	WSDATA   cNOMEFANT                 AS string
	WSDATA   cNUMPROCESSOBIZAGI        AS string OPTIONAL
	WSDATA   cOBSROMANEIO              AS string OPTIONAL
	WSDATA   cRISCO                    AS string OPTIONAL
	WSDATA   cSEGMENTO                 AS string
	WSDATA   cSUFRAMA                  AS string OPTIONAL
	WSDATA   cTELEFONE                 AS string
	WSDATA   cTPCLI                    AS string
	WSDATA   cTPJ                      AS string OPTIONAL
	WSDATA   cTPLIMITE                 AS string OPTIONAL
	WSDATA   cTPPAG                    AS string
	WSDATA   cTPPESSOA                 AS string
	WSDATA   cTPSEG                    AS string
	WSDATA   cTRATESPECIAL             AS string
	WSDATA   cVALCOMISSBELLACASA       AS string OPTIONAL
	WSDATA   cVALCOMISSBIANCO          AS string OPTIONAL
	WSDATA   cVALCOMISSINCESA          AS string OPTIONAL
	WSDATA   cVALCOMISSMUNDIALLI       AS string OPTIONAL
	WSDATA   cVALCOMISSVITCER          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_CLIENTE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_CLIENTE
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_CLIENTE
	Local oClone := BIANCO_BIZAGI_CLIENTE():NEW()
	oClone:cAVALIACLIENTE       := ::cAVALIACLIENTE
	oClone:cBACENCODPAIS        := ::cBACENCODPAIS
	oClone:cCATEGORIA           := ::cCATEGORIA
	oClone:cCNPJCPF             := ::cCNPJCPF
	oClone:cCOBBAIRRO           := ::cCOBBAIRRO
	oClone:cCOBCEP              := ::cCOBCEP
	oClone:cCOBEND              := ::cCOBEND
	oClone:cCOBMUN              := ::cCOBMUN
	oClone:cCOBNUM              := ::cCOBNUM
	oClone:cCOBTPLOG            := ::cCOBTPLOG
	oClone:cCOBUF               := ::cCOBUF
	oClone:cCODIGO              := ::cCODIGO
	oClone:cCODMUNZONAFRANCA    := ::cCODMUNZONAFRANCA
	oClone:cCODREPRESENBELLACASA := ::cCODREPRESENBELLACASA
	oClone:cCODREPRESENBIANCO   := ::cCODREPRESENBIANCO
	oClone:cCODREPRESENINCESA   := ::cCODREPRESENINCESA
	oClone:cCODREPRESENMUNDIALLI := ::cCODREPRESENMUNDIALLI
	oClone:cCODREPRESENVITCER   := ::cCODREPRESENVITCER
	oClone:cCONTATO             := ::cCONTATO
	oClone:cDATAVENCLIMITE      := ::cDATAVENCLIMITE
	oClone:cDESCONTOSUFRAMA     := ::cDESCONTOSUFRAMA
	oClone:cEHCADEXPRES         := ::cEHCADEXPRES
	oClone:cEHCONTRIB           := ::cEHCONTRIB
	oClone:cEMAILCOBR           := ::cEMAILCOBR
	oClone:cEMAILCONT           := ::cEMAILCONT
	oClone:cEMAILNF             := ::cEMAILNF
	oClone:cENDBAIRRO           := ::cENDBAIRRO
	oClone:cENDCEP              := ::cENDCEP
	oClone:cENDCODMUN           := ::cENDCODMUN
	oClone:cENDCOMPLEMENTO      := ::cENDCOMPLEMENTO
	oClone:cENDDESC             := ::cENDDESC
	oClone:cENDMUN              := ::cENDMUN
	oClone:cENDNUM              := ::cENDNUM
	oClone:cENDPAIS             := ::cENDPAIS
	oClone:cENDTPLOG            := ::cENDTPLOG
	oClone:cENDUF               := ::cENDUF
	oClone:cFAX                 := ::cFAX
	oClone:cFOMEZERO            := ::cFOMEZERO
	oClone:cGRUPOLIMITE         := ::cGRUPOLIMITE
	oClone:cHOMEPAGE            := ::cHOMEPAGE
	oClone:cINSCEST             := ::cINSCEST
	oClone:cLIMITECREDITO       := ::cLIMITECREDITO
	oClone:cLOJA                := ::cLOJA
	oClone:cNOME                := ::cNOME
	oClone:cNOMEFANT            := ::cNOMEFANT
	oClone:cNUMPROCESSOBIZAGI   := ::cNUMPROCESSOBIZAGI
	oClone:cOBSROMANEIO         := ::cOBSROMANEIO
	oClone:cRISCO               := ::cRISCO
	oClone:cSEGMENTO            := ::cSEGMENTO
	oClone:cSUFRAMA             := ::cSUFRAMA
	oClone:cTELEFONE            := ::cTELEFONE
	oClone:cTPCLI               := ::cTPCLI
	oClone:cTPJ                 := ::cTPJ
	oClone:cTPLIMITE            := ::cTPLIMITE
	oClone:cTPPAG               := ::cTPPAG
	oClone:cTPPESSOA            := ::cTPPESSOA
	oClone:cTPSEG               := ::cTPSEG
	oClone:cTRATESPECIAL        := ::cTRATESPECIAL
	oClone:cVALCOMISSBELLACASA  := ::cVALCOMISSBELLACASA
	oClone:cVALCOMISSBIANCO     := ::cVALCOMISSBIANCO
	oClone:cVALCOMISSINCESA     := ::cVALCOMISSINCESA
	oClone:cVALCOMISSMUNDIALLI  := ::cVALCOMISSMUNDIALLI
	oClone:cVALCOMISSVITCER     := ::cVALCOMISSVITCER
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_CLIENTE
	Local cSoap := ""
	cSoap += WSSoapValue("AVALIACLIENTE", ::cAVALIACLIENTE, ::cAVALIACLIENTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("BACENCODPAIS", ::cBACENCODPAIS, ::cBACENCODPAIS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CATEGORIA", ::cCATEGORIA, ::cCATEGORIA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNPJCPF", ::cCNPJCPF, ::cCNPJCPF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COBBAIRRO", ::cCOBBAIRRO, ::cCOBBAIRRO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COBCEP", ::cCOBCEP, ::cCOBCEP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COBEND", ::cCOBEND, ::cCOBEND , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COBMUN", ::cCOBMUN, ::cCOBMUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COBNUM", ::cCOBNUM, ::cCOBNUM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COBTPLOG", ::cCOBTPLOG, ::cCOBTPLOG , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COBUF", ::cCOBUF, ::cCOBUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODIGO", ::cCODIGO, ::cCODIGO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODMUNZONAFRANCA", ::cCODMUNZONAFRANCA, ::cCODMUNZONAFRANCA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODREPRESENBELLACASA", ::cCODREPRESENBELLACASA, ::cCODREPRESENBELLACASA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODREPRESENBIANCO", ::cCODREPRESENBIANCO, ::cCODREPRESENBIANCO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODREPRESENINCESA", ::cCODREPRESENINCESA, ::cCODREPRESENINCESA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODREPRESENMUNDIALLI", ::cCODREPRESENMUNDIALLI, ::cCODREPRESENMUNDIALLI , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODREPRESENVITCER", ::cCODREPRESENVITCER, ::cCODREPRESENVITCER , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONTATO", ::cCONTATO, ::cCONTATO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATAVENCLIMITE", ::cDATAVENCLIMITE, ::cDATAVENCLIMITE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCONTOSUFRAMA", ::cDESCONTOSUFRAMA, ::cDESCONTOSUFRAMA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EHCADEXPRES", ::cEHCADEXPRES, ::cEHCADEXPRES , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EHCONTRIB", ::cEHCONTRIB, ::cEHCONTRIB , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMAILCOBR", ::cEMAILCOBR, ::cEMAILCOBR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMAILCONT", ::cEMAILCONT, ::cEMAILCONT , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMAILNF", ::cEMAILNF, ::cEMAILNF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDBAIRRO", ::cENDBAIRRO, ::cENDBAIRRO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDCEP", ::cENDCEP, ::cENDCEP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDCODMUN", ::cENDCODMUN, ::cENDCODMUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDCOMPLEMENTO", ::cENDCOMPLEMENTO, ::cENDCOMPLEMENTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDDESC", ::cENDDESC, ::cENDDESC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDMUN", ::cENDMUN, ::cENDMUN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDNUM", ::cENDNUM, ::cENDNUM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDPAIS", ::cENDPAIS, ::cENDPAIS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDTPLOG", ::cENDTPLOG, ::cENDTPLOG , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDUF", ::cENDUF, ::cENDUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FAX", ::cFAX, ::cFAX , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FOMEZERO", ::cFOMEZERO, ::cFOMEZERO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("GRUPOLIMITE", ::cGRUPOLIMITE, ::cGRUPOLIMITE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("HOMEPAGE", ::cHOMEPAGE, ::cHOMEPAGE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("INSCEST", ::cINSCEST, ::cINSCEST , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LIMITECREDITO", ::cLIMITECREDITO, ::cLIMITECREDITO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOJA", ::cLOJA, ::cLOJA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NOME", ::cNOME, ::cNOME , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NOMEFANT", ::cNOMEFANT, ::cNOMEFANT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NUMPROCESSOBIZAGI", ::cNUMPROCESSOBIZAGI, ::cNUMPROCESSOBIZAGI , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OBSROMANEIO", ::cOBSROMANEIO, ::cOBSROMANEIO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RISCO", ::cRISCO, ::cRISCO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SEGMENTO", ::cSEGMENTO, ::cSEGMENTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SUFRAMA", ::cSUFRAMA, ::cSUFRAMA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TELEFONE", ::cTELEFONE, ::cTELEFONE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPCLI", ::cTPCLI, ::cTPCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPJ", ::cTPJ, ::cTPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPLIMITE", ::cTPLIMITE, ::cTPLIMITE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPPAG", ::cTPPAG, ::cTPPAG , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPPESSOA", ::cTPPESSOA, ::cTPPESSOA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPSEG", ::cTPSEG, ::cTPSEG , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TRATESPECIAL", ::cTRATESPECIAL, ::cTRATESPECIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALCOMISSBELLACASA", ::cVALCOMISSBELLACASA, ::cVALCOMISSBELLACASA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALCOMISSBIANCO", ::cVALCOMISSBIANCO, ::cVALCOMISSBIANCO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALCOMISSINCESA", ::cVALCOMISSINCESA, ::cVALCOMISSINCESA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALCOMISSMUNDIALLI", ::cVALCOMISSMUNDIALLI, ::cVALCOMISSMUNDIALLI , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALCOMISSVITCER", ::cVALCOMISSVITCER, ::cVALCOMISSVITCER , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure EMBALAGEMALTERACAO

WSSTRUCT BIANCO_BIZAGI_EMBALAGEMALTERACAO
	WSDATA   cCODANTERIOR              AS string
	WSDATA   cCODNOVO                  AS string
	WSDATA   cEMPRESA                  AS string
	WSDATA   cTIPO                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_EMBALAGEMALTERACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_EMBALAGEMALTERACAO
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_EMBALAGEMALTERACAO
	Local oClone := BIANCO_BIZAGI_EMBALAGEMALTERACAO():NEW()
	oClone:cCODANTERIOR         := ::cCODANTERIOR
	oClone:cCODNOVO             := ::cCODNOVO
	oClone:cEMPRESA             := ::cEMPRESA
	oClone:cTIPO                := ::cTIPO
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_EMBALAGEMALTERACAO
	Local cSoap := ""
	cSoap += WSSoapValue("CODANTERIOR", ::cCODANTERIOR, ::cCODANTERIOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODNOVO", ::cCODNOVO, ::cCODNOVO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, ::cEMPRESA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPO", ::cTIPO, ::cTIPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure EMBALAGEMINCLUSAO

WSSTRUCT BIANCO_BIZAGI_EMBALAGEMINCLUSAO
	WSDATA   cDESCNOVA                 AS string
	WSDATA   cNCMANTERIOR              AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_EMBALAGEMINCLUSAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_EMBALAGEMINCLUSAO
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_EMBALAGEMINCLUSAO
	Local oClone := BIANCO_BIZAGI_EMBALAGEMINCLUSAO():NEW()
	oClone:cDESCNOVA            := ::cDESCNOVA
	oClone:cNCMANTERIOR         := ::cNCMANTERIOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_EMBALAGEMINCLUSAO
	Local cSoap := ""
	cSoap += WSSoapValue("DESCNOVA", ::cDESCNOVA, ::cDESCNOVA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NCMANTERIOR", ::cNCMANTERIOR, ::cNCMANTERIOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure NOVALISTAPRODUTOS

WSSTRUCT BIANCO_BIZAGI_NOVALISTAPRODUTOS
	WSDATA   oWSLISTA                  AS BIANCO_BIZAGI_ARRAYOFNEWPRODUCT
	WSDATA   cSOLICITANTE              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_NOVALISTAPRODUTOS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_NOVALISTAPRODUTOS
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_NOVALISTAPRODUTOS
	Local oClone := BIANCO_BIZAGI_NOVALISTAPRODUTOS():NEW()
	oClone:oWSLISTA             := IIF(::oWSLISTA = NIL , NIL , ::oWSLISTA:Clone() )
	oClone:cSOLICITANTE         := ::cSOLICITANTE
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_NOVALISTAPRODUTOS
	Local cSoap := ""
	cSoap += WSSoapValue("LISTA", ::oWSLISTA, ::oWSLISTA , "ARRAYOFNEWPRODUCT", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SOLICITANTE", ::cSOLICITANTE, ::cSOLICITANTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure SOLICCREDITO

WSSTRUCT BIANCO_BIZAGI_SOLICCREDITO
	WSDATA   cCODCLIENTE               AS string
	WSDATA   cCODIGO                   AS string OPTIONAL
	WSDATA   cCONDPAMENTO              AS string OPTIONAL
	WSDATA   cDATAAPROV                AS string OPTIONAL
	WSDATA   cDATASOL                  AS string OPTIONAL
	WSDATA   cEHNOVO                   AS string OPTIONAL
	WSDATA   cEMPRESAPED               AS string OPTIONAL
	WSDATA   cHORASOL                  AS string OPTIONAL
	WSDATA   cOBSERAPROV               AS string OPTIONAL
	WSDATA   cOBSERSOL                 AS string OPTIONAL
	WSDATA   cPEDIDO                   AS string OPTIONAL
	WSDATA   cPRAZO                    AS string OPTIONAL
	WSDATA   cSTATUSSOL                AS string OPTIONAL
	WSDATA   cTPPAGAMENTO              AS string OPTIONAL
	WSDATA   cUSUARIO                  AS string OPTIONAL
	WSDATA   cVALOR                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_SOLICCREDITO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_SOLICCREDITO
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_SOLICCREDITO
	Local oClone := BIANCO_BIZAGI_SOLICCREDITO():NEW()
	oClone:cCODCLIENTE          := ::cCODCLIENTE
	oClone:cCODIGO              := ::cCODIGO
	oClone:cCONDPAMENTO         := ::cCONDPAMENTO
	oClone:cDATAAPROV           := ::cDATAAPROV
	oClone:cDATASOL             := ::cDATASOL
	oClone:cEHNOVO              := ::cEHNOVO
	oClone:cEMPRESAPED          := ::cEMPRESAPED
	oClone:cHORASOL             := ::cHORASOL
	oClone:cOBSERAPROV          := ::cOBSERAPROV
	oClone:cOBSERSOL            := ::cOBSERSOL
	oClone:cPEDIDO              := ::cPEDIDO
	oClone:cPRAZO               := ::cPRAZO
	oClone:cSTATUSSOL           := ::cSTATUSSOL
	oClone:cTPPAGAMENTO         := ::cTPPAGAMENTO
	oClone:cUSUARIO             := ::cUSUARIO
	oClone:cVALOR               := ::cVALOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_SOLICCREDITO
	Local cSoap := ""
	cSoap += WSSoapValue("CODCLIENTE", ::cCODCLIENTE, ::cCODCLIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODIGO", ::cCODIGO, ::cCODIGO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONDPAMENTO", ::cCONDPAMENTO, ::cCONDPAMENTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATAAPROV", ::cDATAAPROV, ::cDATAAPROV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATASOL", ::cDATASOL, ::cDATASOL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EHNOVO", ::cEHNOVO, ::cEHNOVO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPRESAPED", ::cEMPRESAPED, ::cEMPRESAPED , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("HORASOL", ::cHORASOL, ::cHORASOL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OBSERAPROV", ::cOBSERAPROV, ::cOBSERAPROV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OBSERSOL", ::cOBSERSOL, ::cOBSERSOL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PEDIDO", ::cPEDIDO, ::cPEDIDO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRAZO", ::cPRAZO, ::cPRAZO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STATUSSOL", ::cSTATUSSOL, ::cSTATUSSOL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPPAGAMENTO", ::cTPPAGAMENTO, ::cTPPAGAMENTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("USUARIO", ::cUSUARIO, ::cUSUARIO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALOR", ::cVALOR, ::cVALOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure SOLICITACAOCOMPRA

WSSTRUCT BIANCO_BIZAGI_SOLICITACAOCOMPRA
	WSDATA   oWSSCCAB                  AS BIANCO_BIZAGI_CABECSOLICCOMPRA
	WSDATA   oWSSCITEM                 AS BIANCO_BIZAGI_ARRAYOFITEMSOLICITACAO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_SOLICITACAOCOMPRA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_SOLICITACAOCOMPRA
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_SOLICITACAOCOMPRA
	Local oClone := BIANCO_BIZAGI_SOLICITACAOCOMPRA():NEW()
	oClone:oWSSCCAB             := IIF(::oWSSCCAB = NIL , NIL , ::oWSSCCAB:Clone() )
	oClone:oWSSCITEM            := IIF(::oWSSCITEM = NIL , NIL , ::oWSSCITEM:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_SOLICITACAOCOMPRA
	Local cSoap := ""
	cSoap += WSSoapValue("SCCAB", ::oWSSCCAB, ::oWSSCCAB , "CABECSOLICCOMPRA", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SCITEM", ::oWSSCITEM, ::oWSSCITEM , "ARRAYOFITEMSOLICITACAO", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure TABELAPRECO

WSSTRUCT BIANCO_BIZAGI_TABELAPRECO
	WSDATA   oWSTPCAB                  AS BIANCO_BIZAGI_CABECTABELAPRECO
	WSDATA   oWSTPITEM                 AS BIANCO_BIZAGI_ARRAYOFITEMTABELAPRECO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_TABELAPRECO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_TABELAPRECO
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_TABELAPRECO
	Local oClone := BIANCO_BIZAGI_TABELAPRECO():NEW()
	oClone:oWSTPCAB             := IIF(::oWSTPCAB = NIL , NIL , ::oWSTPCAB:Clone() )
	oClone:oWSTPITEM            := IIF(::oWSTPITEM = NIL , NIL , ::oWSTPITEM:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_TABELAPRECO
	Local cSoap := ""
	cSoap += WSSoapValue("TPCAB", ::oWSTPCAB, ::oWSTPCAB , "CABECTABELAPRECO", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPITEM", ::oWSTPITEM, ::oWSTPITEM , "ARRAYOFITEMTABELAPRECO", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure CABECALHOCOTACAO

WSSTRUCT BIANCO_BIZAGI_CABECALHOCOTACAO
	WSDATA   cCODIGOCOTACAO            AS string
	WSDATA   cCONTATO                  AS string
	WSDATA   cDATAVALIDADE             AS string
	WSDATA   cEMPRESACOTACAO           AS string
	WSDATA   cFORMAPAGAMENTO           AS string
	WSDATA   cFORMPAGNEGOCIADO         AS string OPTIONAL
	WSDATA   cFORNECEDOR               AS string
	WSDATA   cLOJAFORNEDOR             AS string
	WSDATA   cORCAMENTO                AS string OPTIONAL
	WSDATA   cTIPOFRETE                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_CABECALHOCOTACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_CABECALHOCOTACAO
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_CABECALHOCOTACAO
	Local oClone := BIANCO_BIZAGI_CABECALHOCOTACAO():NEW()
	oClone:cCODIGOCOTACAO       := ::cCODIGOCOTACAO
	oClone:cCONTATO             := ::cCONTATO
	oClone:cDATAVALIDADE        := ::cDATAVALIDADE
	oClone:cEMPRESACOTACAO      := ::cEMPRESACOTACAO
	oClone:cFORMAPAGAMENTO      := ::cFORMAPAGAMENTO
	oClone:cFORMPAGNEGOCIADO    := ::cFORMPAGNEGOCIADO
	oClone:cFORNECEDOR          := ::cFORNECEDOR
	oClone:cLOJAFORNEDOR        := ::cLOJAFORNEDOR
	oClone:cORCAMENTO           := ::cORCAMENTO
	oClone:cTIPOFRETE           := ::cTIPOFRETE
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_CABECALHOCOTACAO
	Local cSoap := ""
	cSoap += WSSoapValue("CODIGOCOTACAO", ::cCODIGOCOTACAO, ::cCODIGOCOTACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONTATO", ::cCONTATO, ::cCONTATO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATAVALIDADE", ::cDATAVALIDADE, ::cDATAVALIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPRESACOTACAO", ::cEMPRESACOTACAO, ::cEMPRESACOTACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORMAPAGAMENTO", ::cFORMAPAGAMENTO, ::cFORMAPAGAMENTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORMPAGNEGOCIADO", ::cFORMPAGNEGOCIADO, ::cFORMPAGNEGOCIADO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORNECEDOR", ::cFORNECEDOR, ::cFORNECEDOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOJAFORNEDOR", ::cLOJAFORNEDOR, ::cLOJAFORNEDOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ORCAMENTO", ::cORCAMENTO, ::cORCAMENTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPOFRETE", ::cTIPOFRETE, ::cTIPOFRETE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFITEMCOTACAO

WSSTRUCT BIANCO_BIZAGI_ARRAYOFITEMCOTACAO
	WSDATA   oWSITEMCOTACAO            AS BIANCO_BIZAGI_ITEMCOTACAO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMCOTACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMCOTACAO
	::oWSITEMCOTACAO       := {} // Array Of  BIANCO_BIZAGI_ITEMCOTACAO():New()
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMCOTACAO
	Local oClone := BIANCO_BIZAGI_ARRAYOFITEMCOTACAO():NEW()
	oClone:oWSITEMCOTACAO := NIL
	If ::oWSITEMCOTACAO <> NIL 
		oClone:oWSITEMCOTACAO := {}
		aEval( ::oWSITEMCOTACAO , { |x| aadd( oClone:oWSITEMCOTACAO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMCOTACAO
	Local cSoap := ""
	aEval( ::oWSITEMCOTACAO , {|x| cSoap := cSoap  +  WSSoapValue("ITEMCOTACAO", x , x , "ITEMCOTACAO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFNEWPRODUCT

WSSTRUCT BIANCO_BIZAGI_ARRAYOFNEWPRODUCT
	WSDATA   oWSNEWPRODUCT             AS BIANCO_BIZAGI_NEWPRODUCT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_ARRAYOFNEWPRODUCT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_ARRAYOFNEWPRODUCT
	::oWSNEWPRODUCT        := {} // Array Of  BIANCO_BIZAGI_NEWPRODUCT():New()
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_ARRAYOFNEWPRODUCT
	Local oClone := BIANCO_BIZAGI_ARRAYOFNEWPRODUCT():NEW()
	oClone:oWSNEWPRODUCT := NIL
	If ::oWSNEWPRODUCT <> NIL 
		oClone:oWSNEWPRODUCT := {}
		aEval( ::oWSNEWPRODUCT , { |x| aadd( oClone:oWSNEWPRODUCT , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_ARRAYOFNEWPRODUCT
	Local cSoap := ""
	aEval( ::oWSNEWPRODUCT , {|x| cSoap := cSoap  +  WSSoapValue("NEWPRODUCT", x , x , "NEWPRODUCT", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure CABECSOLICCOMPRA

WSSTRUCT BIANCO_BIZAGI_CABECSOLICCOMPRA
	WSDATA   cCENTROCUSTO              AS string OPTIONAL
	WSDATA   cCLASSEVALOR              AS string OPTIONAL
	WSDATA   cCODIGO                   AS string OPTIONAL
	WSDATA   cCONTA                    AS string OPTIONAL
	WSDATA   cCONTRATO                 AS string OPTIONAL
	WSDATA   cDATAAPROVACAO            AS string
	WSDATA   cDATAEMISSAO              AS string
	WSDATA   cEMPRESA                  AS string
	WSDATA   cFILIAL                   AS string
	WSDATA   cINDICACAO                AS string OPTIONAL
	WSDATA   cITEMCONTA                AS string OPTIONAL
	WSDATA   cMATRICULA                AS string
	WSDATA   cMELHORIA                 AS string OPTIONAL
	WSDATA   cNECESSIDADE              AS string
	WSDATA   cNOMESOLICITANTE          AS string
	WSDATA   cPRIORIDADE               AS string
	WSDATA   cSITUACAOAPROVACAO        AS string OPTIONAL
	WSDATA   cSOLICEMPRESA             AS string OPTIONAL
	WSDATA   cSOLICITBIZAGI            AS string OPTIONAL
	WSDATA   cTEMPRODNOVO              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_CABECSOLICCOMPRA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_CABECSOLICCOMPRA
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_CABECSOLICCOMPRA
	Local oClone := BIANCO_BIZAGI_CABECSOLICCOMPRA():NEW()
	oClone:cCENTROCUSTO         := ::cCENTROCUSTO
	oClone:cCLASSEVALOR         := ::cCLASSEVALOR
	oClone:cCODIGO              := ::cCODIGO
	oClone:cCONTA               := ::cCONTA
	oClone:cCONTRATO            := ::cCONTRATO
	oClone:cDATAAPROVACAO       := ::cDATAAPROVACAO
	oClone:cDATAEMISSAO         := ::cDATAEMISSAO
	oClone:cEMPRESA             := ::cEMPRESA
	oClone:cFILIAL              := ::cFILIAL
	oClone:cINDICACAO           := ::cINDICACAO
	oClone:cITEMCONTA           := ::cITEMCONTA
	oClone:cMATRICULA           := ::cMATRICULA
	oClone:cMELHORIA            := ::cMELHORIA
	oClone:cNECESSIDADE         := ::cNECESSIDADE
	oClone:cNOMESOLICITANTE     := ::cNOMESOLICITANTE
	oClone:cPRIORIDADE          := ::cPRIORIDADE
	oClone:cSITUACAOAPROVACAO   := ::cSITUACAOAPROVACAO
	oClone:cSOLICEMPRESA        := ::cSOLICEMPRESA
	oClone:cSOLICITBIZAGI       := ::cSOLICITBIZAGI
	oClone:cTEMPRODNOVO         := ::cTEMPRODNOVO
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_CABECSOLICCOMPRA
	Local cSoap := ""
	cSoap += WSSoapValue("CENTROCUSTO", ::cCENTROCUSTO, ::cCENTROCUSTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CLASSEVALOR", ::cCLASSEVALOR, ::cCLASSEVALOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODIGO", ::cCODIGO, ::cCODIGO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONTA", ::cCONTA, ::cCONTA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONTRATO", ::cCONTRATO, ::cCONTRATO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATAAPROVACAO", ::cDATAAPROVACAO, ::cDATAAPROVACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATAEMISSAO", ::cDATAEMISSAO, ::cDATAEMISSAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, ::cEMPRESA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILIAL", ::cFILIAL, ::cFILIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("INDICACAO", ::cINDICACAO, ::cINDICACAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ITEMCONTA", ::cITEMCONTA, ::cITEMCONTA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, ::cMATRICULA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MELHORIA", ::cMELHORIA, ::cMELHORIA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NECESSIDADE", ::cNECESSIDADE, ::cNECESSIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NOMESOLICITANTE", ::cNOMESOLICITANTE, ::cNOMESOLICITANTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRIORIDADE", ::cPRIORIDADE, ::cPRIORIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SITUACAOAPROVACAO", ::cSITUACAOAPROVACAO, ::cSITUACAOAPROVACAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SOLICEMPRESA", ::cSOLICEMPRESA, ::cSOLICEMPRESA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SOLICITBIZAGI", ::cSOLICITBIZAGI, ::cSOLICITBIZAGI , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TEMPRODNOVO", ::cTEMPRODNOVO, ::cTEMPRODNOVO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFITEMSOLICITACAO

WSSTRUCT BIANCO_BIZAGI_ARRAYOFITEMSOLICITACAO
	WSDATA   oWSITEMSOLICITACAO        AS BIANCO_BIZAGI_ITEMSOLICITACAO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMSOLICITACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMSOLICITACAO
	::oWSITEMSOLICITACAO   := {} // Array Of  BIANCO_BIZAGI_ITEMSOLICITACAO():New()
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMSOLICITACAO
	Local oClone := BIANCO_BIZAGI_ARRAYOFITEMSOLICITACAO():NEW()
	oClone:oWSITEMSOLICITACAO := NIL
	If ::oWSITEMSOLICITACAO <> NIL 
		oClone:oWSITEMSOLICITACAO := {}
		aEval( ::oWSITEMSOLICITACAO , { |x| aadd( oClone:oWSITEMSOLICITACAO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMSOLICITACAO
	Local cSoap := ""
	aEval( ::oWSITEMSOLICITACAO , {|x| cSoap := cSoap  +  WSSoapValue("ITEMSOLICITACAO", x , x , "ITEMSOLICITACAO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure CABECTABELAPRECO

WSSTRUCT BIANCO_BIZAGI_CABECTABELAPRECO
	WSDATA   cAPLICFRETE               AS string
	WSDATA   cAPLICPROD                AS string
	WSDATA   cDATAPREVSUBS             AS string
	WSDATA   cFORMAPAGATUAL            AS string
	WSDATA   cFORMAPAGNOVO             AS string
	WSDATA   cFORNCODLOJAATUAL         AS string
	WSDATA   cFORNCODLOJANOVO          AS string
	WSDATA   cFORNDSCATUAL             AS string
	WSDATA   cFORNDSCNOVO              AS string
	WSDATA   cTIPONEGOC                AS string
	WSDATA   cTIPONEGOCIACAO           AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_CABECTABELAPRECO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_CABECTABELAPRECO
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_CABECTABELAPRECO
	Local oClone := BIANCO_BIZAGI_CABECTABELAPRECO():NEW()
	oClone:cAPLICFRETE          := ::cAPLICFRETE
	oClone:cAPLICPROD           := ::cAPLICPROD
	oClone:cDATAPREVSUBS        := ::cDATAPREVSUBS
	oClone:cFORMAPAGATUAL       := ::cFORMAPAGATUAL
	oClone:cFORMAPAGNOVO        := ::cFORMAPAGNOVO
	oClone:cFORNCODLOJAATUAL    := ::cFORNCODLOJAATUAL
	oClone:cFORNCODLOJANOVO     := ::cFORNCODLOJANOVO
	oClone:cFORNDSCATUAL        := ::cFORNDSCATUAL
	oClone:cFORNDSCNOVO         := ::cFORNDSCNOVO
	oClone:cTIPONEGOC           := ::cTIPONEGOC
	oClone:cTIPONEGOCIACAO      := ::cTIPONEGOCIACAO
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_CABECTABELAPRECO
	Local cSoap := ""
	cSoap += WSSoapValue("APLICFRETE", ::cAPLICFRETE, ::cAPLICFRETE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("APLICPROD", ::cAPLICPROD, ::cAPLICPROD , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATAPREVSUBS", ::cDATAPREVSUBS, ::cDATAPREVSUBS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORMAPAGATUAL", ::cFORMAPAGATUAL, ::cFORMAPAGATUAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORMAPAGNOVO", ::cFORMAPAGNOVO, ::cFORMAPAGNOVO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORNCODLOJAATUAL", ::cFORNCODLOJAATUAL, ::cFORNCODLOJAATUAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORNCODLOJANOVO", ::cFORNCODLOJANOVO, ::cFORNCODLOJANOVO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORNDSCATUAL", ::cFORNDSCATUAL, ::cFORNDSCATUAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORNDSCNOVO", ::cFORNDSCNOVO, ::cFORNDSCNOVO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPONEGOC", ::cTIPONEGOC, ::cTIPONEGOC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPONEGOCIACAO", ::cTIPONEGOCIACAO, ::cTIPONEGOCIACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFITEMTABELAPRECO

WSSTRUCT BIANCO_BIZAGI_ARRAYOFITEMTABELAPRECO
	WSDATA   oWSITEMTABELAPRECO        AS BIANCO_BIZAGI_ITEMTABELAPRECO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMTABELAPRECO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMTABELAPRECO
	::oWSITEMTABELAPRECO   := {} // Array Of  BIANCO_BIZAGI_ITEMTABELAPRECO():New()
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMTABELAPRECO
	Local oClone := BIANCO_BIZAGI_ARRAYOFITEMTABELAPRECO():NEW()
	oClone:oWSITEMTABELAPRECO := NIL
	If ::oWSITEMTABELAPRECO <> NIL 
		oClone:oWSITEMTABELAPRECO := {}
		aEval( ::oWSITEMTABELAPRECO , { |x| aadd( oClone:oWSITEMTABELAPRECO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_ARRAYOFITEMTABELAPRECO
	Local cSoap := ""
	aEval( ::oWSITEMTABELAPRECO , {|x| cSoap := cSoap  +  WSSoapValue("ITEMTABELAPRECO", x , x , "ITEMTABELAPRECO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ITEMCOTACAO

WSSTRUCT BIANCO_BIZAGI_ITEMCOTACAO
	WSDATA   cATENDECOTACAO            AS string OPTIONAL
	WSDATA   lATENDETOTAL              AS boolean
	WSDATA   nDESCONTO                 AS float OPTIONAL
	WSDATA   nDIASENTREGA              AS integer
	WSDATA   nIPI                      AS float
	WSDATA   cMARCA                    AS string OPTIONAL
	WSDATA   nMOEDA                    AS integer
	WSDATA   cOBSERVACAO               AS string OPTIONAL
	WSDATA   nPRECOTOTAL               AS float
	WSDATA   nPRECOUNITARIO            AS float
	WSDATA   cPRODUTO                  AS string
	WSDATA   cPRODUTOFORNECEDOR        AS string OPTIONAL
	WSDATA   nVALORDESCONTO            AS float OPTIONAL
	WSDATA   nVALORSUBST               AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_ITEMCOTACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_ITEMCOTACAO
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_ITEMCOTACAO
	Local oClone := BIANCO_BIZAGI_ITEMCOTACAO():NEW()
	oClone:cATENDECOTACAO       := ::cATENDECOTACAO
	oClone:lATENDETOTAL         := ::lATENDETOTAL
	oClone:nDESCONTO            := ::nDESCONTO
	oClone:nDIASENTREGA         := ::nDIASENTREGA
	oClone:nIPI                 := ::nIPI
	oClone:cMARCA               := ::cMARCA
	oClone:nMOEDA               := ::nMOEDA
	oClone:cOBSERVACAO          := ::cOBSERVACAO
	oClone:nPRECOTOTAL          := ::nPRECOTOTAL
	oClone:nPRECOUNITARIO       := ::nPRECOUNITARIO
	oClone:cPRODUTO             := ::cPRODUTO
	oClone:cPRODUTOFORNECEDOR   := ::cPRODUTOFORNECEDOR
	oClone:nVALORDESCONTO       := ::nVALORDESCONTO
	oClone:nVALORSUBST          := ::nVALORSUBST
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_ITEMCOTACAO
	Local cSoap := ""
	cSoap += WSSoapValue("ATENDECOTACAO", ::cATENDECOTACAO, ::cATENDECOTACAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ATENDETOTAL", ::lATENDETOTAL, ::lATENDETOTAL , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCONTO", ::nDESCONTO, ::nDESCONTO , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DIASENTREGA", ::nDIASENTREGA, ::nDIASENTREGA , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IPI", ::nIPI, ::nIPI , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MARCA", ::cMARCA, ::cMARCA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MOEDA", ::nMOEDA, ::nMOEDA , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OBSERVACAO", ::cOBSERVACAO, ::cOBSERVACAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRECOTOTAL", ::nPRECOTOTAL, ::nPRECOTOTAL , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRECOUNITARIO", ::nPRECOUNITARIO, ::nPRECOUNITARIO , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRODUTO", ::cPRODUTO, ::cPRODUTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRODUTOFORNECEDOR", ::cPRODUTOFORNECEDOR, ::cPRODUTOFORNECEDOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALORDESCONTO", ::nVALORDESCONTO, ::nVALORDESCONTO , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALORSUBST", ::nVALORSUBST, ::nVALORSUBST , "float", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure NEWPRODUCT

WSSTRUCT BIANCO_BIZAGI_NEWPRODUCT
	WSDATA   cANUENTE                  AS string OPTIONAL
	WSDATA   oWSAPDMCARACTERISTICAS    AS BIANCO_BIZAGI_ARRAYOFPDMCARACVAL OPTIONAL
	WSDATA   oWSAPDMMARCAS             AS BIANCO_BIZAGI_ARRAYOFPDMMARCA OPTIONAL
	WSDATA   cAPLICACAODIRETA          AS string OPTIONAL
	WSDATA   cCLASFIS                  AS string OPTIONAL
	WSDATA   cCNV52                    AS string OPTIONAL
	WSDATA   cCODIGO                   AS string OPTIONAL
	WSDATA   cCONTA                    AS string OPTIONAL
	WSDATA   cCONTARESULT              AS string OPTIONAL
	WSDATA   cCONTARESULTADM           AS string OPTIONAL
	WSDATA   cCONTARESULTIND           AS string OPTIONAL
	WSDATA   nCONVPALLETS              AS integer OPTIONAL
	WSDATA   cDESCRICAO                AS string
	WSDATA   cEHCOMUM                  AS string OPTIONAL
	WSDATA   dEMISSAO                  AS date OPTIONAL
	WSDATA   cFAMILIAPDM               AS string OPTIONAL
	WSDATA   cFATOR                    AS string OPTIONAL
	WSDATA   cGRPTRIB                  AS string OPTIONAL
	WSDATA   cGRUPO                    AS string
	WSDATA   cGRUPOPDM                 AS string OPTIONAL
	WSDATA   cICMRET                   AS string OPTIONAL
	WSDATA   cICMS                     AS string OPTIONAL
	WSDATA   cIMPORTADO                AS string OPTIONAL
	WSDATA   cINSS                     AS string OPTIONAL
	WSDATA   cIPI                      AS string OPTIONAL
	WSDATA   cISPDM                    AS string OPTIONAL
	WSDATA   cISS                      AS string OPTIONAL
	WSDATA   cITEM                     AS string OPTIONAL
	WSDATA   cLOCALBIANCO              AS string OPTIONAL
	WSDATA   cLOCALINCESA              AS string OPTIONAL
	WSDATA   cLOCALPADRAO              AS string OPTIONAL
	WSDATA   cMONOCLASSIF              AS string OPTIONAL
	WSDATA   cNCM                      AS string OPTIONAL
	WSDATA   cOBS                      AS string OPTIONAL
	WSDATA   cORIGEM                   AS string OPTIONAL
	WSDATA   nPECASCAIXA               AS integer OPTIONAL
	WSDATA   cPOLITICA                 AS string OPTIONAL
	WSDATA   cSEGUM                    AS string OPTIONAL
	WSDATA   cSUBGRUPOPDM              AS string OPTIONAL
	WSDATA   cTE                       AS string OPTIONAL
	WSDATA   cTIPO                     AS string OPTIONAL
	WSDATA   cTIPOBIANCO               AS string OPTIONAL
	WSDATA   cTIPOPRODCONTAB           AS string OPTIONAL
	WSDATA   cTS                       AS string OPTIONAL
	WSDATA   cUNIDADE                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_NEWPRODUCT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_NEWPRODUCT
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_NEWPRODUCT
	Local oClone := BIANCO_BIZAGI_NEWPRODUCT():NEW()
	oClone:cANUENTE             := ::cANUENTE
	oClone:oWSAPDMCARACTERISTICAS := IIF(::oWSAPDMCARACTERISTICAS = NIL , NIL , ::oWSAPDMCARACTERISTICAS:Clone() )
	oClone:oWSAPDMMARCAS        := IIF(::oWSAPDMMARCAS = NIL , NIL , ::oWSAPDMMARCAS:Clone() )
	oClone:cAPLICACAODIRETA     := ::cAPLICACAODIRETA
	oClone:cCLASFIS             := ::cCLASFIS
	oClone:cCNV52               := ::cCNV52
	oClone:cCODIGO              := ::cCODIGO
	oClone:cCONTA               := ::cCONTA
	oClone:cCONTARESULT         := ::cCONTARESULT
	oClone:cCONTARESULTADM      := ::cCONTARESULTADM
	oClone:cCONTARESULTIND      := ::cCONTARESULTIND
	oClone:nCONVPALLETS         := ::nCONVPALLETS
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:cEHCOMUM             := ::cEHCOMUM
	oClone:dEMISSAO             := ::dEMISSAO
	oClone:cFAMILIAPDM          := ::cFAMILIAPDM
	oClone:cFATOR               := ::cFATOR
	oClone:cGRPTRIB             := ::cGRPTRIB
	oClone:cGRUPO               := ::cGRUPO
	oClone:cGRUPOPDM            := ::cGRUPOPDM
	oClone:cICMRET              := ::cICMRET
	oClone:cICMS                := ::cICMS
	oClone:cIMPORTADO           := ::cIMPORTADO
	oClone:cINSS                := ::cINSS
	oClone:cIPI                 := ::cIPI
	oClone:cISPDM               := ::cISPDM
	oClone:cISS                 := ::cISS
	oClone:cITEM                := ::cITEM
	oClone:cLOCALBIANCO         := ::cLOCALBIANCO
	oClone:cLOCALINCESA         := ::cLOCALINCESA
	oClone:cLOCALPADRAO         := ::cLOCALPADRAO
	oClone:cMONOCLASSIF         := ::cMONOCLASSIF
	oClone:cNCM                 := ::cNCM
	oClone:cOBS                 := ::cOBS
	oClone:cORIGEM              := ::cORIGEM
	oClone:nPECASCAIXA          := ::nPECASCAIXA
	oClone:cPOLITICA            := ::cPOLITICA
	oClone:cSEGUM               := ::cSEGUM
	oClone:cSUBGRUPOPDM         := ::cSUBGRUPOPDM
	oClone:cTE                  := ::cTE
	oClone:cTIPO                := ::cTIPO
	oClone:cTIPOBIANCO          := ::cTIPOBIANCO
	oClone:cTIPOPRODCONTAB      := ::cTIPOPRODCONTAB
	oClone:cTS                  := ::cTS
	oClone:cUNIDADE             := ::cUNIDADE
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_NEWPRODUCT
	Local cSoap := ""
	cSoap += WSSoapValue("ANUENTE", ::cANUENTE, ::cANUENTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("APDMCARACTERISTICAS", ::oWSAPDMCARACTERISTICAS, ::oWSAPDMCARACTERISTICAS , "ARRAYOFPDMCARACVAL", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("APDMMARCAS", ::oWSAPDMMARCAS, ::oWSAPDMMARCAS , "ARRAYOFPDMMARCA", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("APLICACAODIRETA", ::cAPLICACAODIRETA, ::cAPLICACAODIRETA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CLASFIS", ::cCLASFIS, ::cCLASFIS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNV52", ::cCNV52, ::cCNV52 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODIGO", ::cCODIGO, ::cCODIGO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONTA", ::cCONTA, ::cCONTA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONTARESULT", ::cCONTARESULT, ::cCONTARESULT , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONTARESULTADM", ::cCONTARESULTADM, ::cCONTARESULTADM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONTARESULTIND", ::cCONTARESULTIND, ::cCONTARESULTIND , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONVPALLETS", ::nCONVPALLETS, ::nCONVPALLETS , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCRICAO", ::cDESCRICAO, ::cDESCRICAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EHCOMUM", ::cEHCOMUM, ::cEHCOMUM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMISSAO", ::dEMISSAO, ::dEMISSAO , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FAMILIAPDM", ::cFAMILIAPDM, ::cFAMILIAPDM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FATOR", ::cFATOR, ::cFATOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("GRPTRIB", ::cGRPTRIB, ::cGRPTRIB , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("GRUPO", ::cGRUPO, ::cGRUPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("GRUPOPDM", ::cGRUPOPDM, ::cGRUPOPDM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ICMRET", ::cICMRET, ::cICMRET , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ICMS", ::cICMS, ::cICMS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IMPORTADO", ::cIMPORTADO, ::cIMPORTADO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("INSS", ::cINSS, ::cINSS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IPI", ::cIPI, ::cIPI , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ISPDM", ::cISPDM, ::cISPDM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ISS", ::cISS, ::cISS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ITEM", ::cITEM, ::cITEM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOCALBIANCO", ::cLOCALBIANCO, ::cLOCALBIANCO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOCALINCESA", ::cLOCALINCESA, ::cLOCALINCESA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOCALPADRAO", ::cLOCALPADRAO, ::cLOCALPADRAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MONOCLASSIF", ::cMONOCLASSIF, ::cMONOCLASSIF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NCM", ::cNCM, ::cNCM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OBS", ::cOBS, ::cOBS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ORIGEM", ::cORIGEM, ::cORIGEM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PECASCAIXA", ::nPECASCAIXA, ::nPECASCAIXA , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("POLITICA", ::cPOLITICA, ::cPOLITICA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SEGUM", ::cSEGUM, ::cSEGUM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SUBGRUPOPDM", ::cSUBGRUPOPDM, ::cSUBGRUPOPDM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TE", ::cTE, ::cTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPO", ::cTIPO, ::cTIPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPOBIANCO", ::cTIPOBIANCO, ::cTIPOBIANCO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPOPRODCONTAB", ::cTIPOPRODCONTAB, ::cTIPOPRODCONTAB , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TS", ::cTS, ::cTS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UNIDADE", ::cUNIDADE, ::cUNIDADE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ITEMSOLICITACAO

WSSTRUCT BIANCO_BIZAGI_ITEMSOLICITACAO
	WSDATA   cAPLICACAO                AS string OPTIONAL
	WSDATA   cARMAZEM                  AS string OPTIONAL
	WSDATA   cATENDERSERVICO           AS string OPTIONAL
	WSDATA   cCODCLIENTE               AS string OPTIONAL
	WSDATA   cCONTA                    AS string OPTIONAL
	WSDATA   cDESCRICAOPRODUTO         AS string OPTIONAL
	WSDATA   cDRIVER                   AS string OPTIONAL
	WSDATA   cFORNECEDOR               AS string OPTIONAL
	WSDATA   cIMPORTADO                AS string OPTIONAL
	WSDATA   cITEM                     AS string
	WSDATA   cOBSERVACAO               AS string OPTIONAL
	WSDATA   nPRIQUANTIDADE            AS float
	WSDATA   cPRIUNIDADEMEDIDA         AS string OPTIONAL
	WSDATA   cPRODUTO                  AS string
	WSDATA   nSEGQUANTIDADE            AS float OPTIONAL
	WSDATA   cSEGUNIDADEMEDIDA         AS string OPTIONAL
	WSDATA   cTAG                      AS string OPTIONAL
	WSDATA   cTEMANEXO                 AS string OPTIONAL
	WSDATA   nVALORUNITARIO            AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_ITEMSOLICITACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_ITEMSOLICITACAO
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_ITEMSOLICITACAO
	Local oClone := BIANCO_BIZAGI_ITEMSOLICITACAO():NEW()
	oClone:cAPLICACAO           := ::cAPLICACAO
	oClone:cARMAZEM             := ::cARMAZEM
	oClone:cATENDERSERVICO      := ::cATENDERSERVICO
	oClone:cCODCLIENTE          := ::cCODCLIENTE
	oClone:cCONTA               := ::cCONTA
	oClone:cDESCRICAOPRODUTO    := ::cDESCRICAOPRODUTO
	oClone:cDRIVER              := ::cDRIVER
	oClone:cFORNECEDOR          := ::cFORNECEDOR
	oClone:cIMPORTADO           := ::cIMPORTADO
	oClone:cITEM                := ::cITEM
	oClone:cOBSERVACAO          := ::cOBSERVACAO
	oClone:nPRIQUANTIDADE       := ::nPRIQUANTIDADE
	oClone:cPRIUNIDADEMEDIDA    := ::cPRIUNIDADEMEDIDA
	oClone:cPRODUTO             := ::cPRODUTO
	oClone:nSEGQUANTIDADE       := ::nSEGQUANTIDADE
	oClone:cSEGUNIDADEMEDIDA    := ::cSEGUNIDADEMEDIDA
	oClone:cTAG                 := ::cTAG
	oClone:cTEMANEXO            := ::cTEMANEXO
	oClone:nVALORUNITARIO       := ::nVALORUNITARIO
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_ITEMSOLICITACAO
	Local cSoap := ""
	cSoap += WSSoapValue("APLICACAO", ::cAPLICACAO, ::cAPLICACAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ARMAZEM", ::cARMAZEM, ::cARMAZEM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ATENDERSERVICO", ::cATENDERSERVICO, ::cATENDERSERVICO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODCLIENTE", ::cCODCLIENTE, ::cCODCLIENTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONTA", ::cCONTA, ::cCONTA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCRICAOPRODUTO", ::cDESCRICAOPRODUTO, ::cDESCRICAOPRODUTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DRIVER", ::cDRIVER, ::cDRIVER , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORNECEDOR", ::cFORNECEDOR, ::cFORNECEDOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IMPORTADO", ::cIMPORTADO, ::cIMPORTADO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ITEM", ::cITEM, ::cITEM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OBSERVACAO", ::cOBSERVACAO, ::cOBSERVACAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRIQUANTIDADE", ::nPRIQUANTIDADE, ::nPRIQUANTIDADE , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRIUNIDADEMEDIDA", ::cPRIUNIDADEMEDIDA, ::cPRIUNIDADEMEDIDA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRODUTO", ::cPRODUTO, ::cPRODUTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SEGQUANTIDADE", ::nSEGQUANTIDADE, ::nSEGQUANTIDADE , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SEGUNIDADEMEDIDA", ::cSEGUNIDADEMEDIDA, ::cSEGUNIDADEMEDIDA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TAG", ::cTAG, ::cTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TEMANEXO", ::cTEMANEXO, ::cTEMANEXO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALORUNITARIO", ::nVALORUNITARIO, ::nVALORUNITARIO , "float", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ITEMTABELAPRECO

WSSTRUCT BIANCO_BIZAGI_ITEMTABELAPRECO
	WSDATA   cFRETEATUAL               AS string
	WSDATA   cFRETENOVO                AS string
	WSDATA   cPRECOATUAL               AS string
	WSDATA   cPRECONOVO                AS string
	WSDATA   cPRODCODATUAL             AS string
	WSDATA   cPRODCODNOVO              AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_ITEMTABELAPRECO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_ITEMTABELAPRECO
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_ITEMTABELAPRECO
	Local oClone := BIANCO_BIZAGI_ITEMTABELAPRECO():NEW()
	oClone:cFRETEATUAL          := ::cFRETEATUAL
	oClone:cFRETENOVO           := ::cFRETENOVO
	oClone:cPRECOATUAL          := ::cPRECOATUAL
	oClone:cPRECONOVO           := ::cPRECONOVO
	oClone:cPRODCODATUAL        := ::cPRODCODATUAL
	oClone:cPRODCODNOVO         := ::cPRODCODNOVO
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_ITEMTABELAPRECO
	Local cSoap := ""
	cSoap += WSSoapValue("FRETEATUAL", ::cFRETEATUAL, ::cFRETEATUAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FRETENOVO", ::cFRETENOVO, ::cFRETENOVO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRECOATUAL", ::cPRECOATUAL, ::cPRECOATUAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRECONOVO", ::cPRECONOVO, ::cPRECONOVO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRODCODATUAL", ::cPRODCODATUAL, ::cPRODCODATUAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRODCODNOVO", ::cPRODCODNOVO, ::cPRODCODNOVO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFPDMCARACVAL

WSSTRUCT BIANCO_BIZAGI_ARRAYOFPDMCARACVAL
	WSDATA   oWSPDMCARACVAL            AS BIANCO_BIZAGI_PDMCARACVAL OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_ARRAYOFPDMCARACVAL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_ARRAYOFPDMCARACVAL
	::oWSPDMCARACVAL       := {} // Array Of  BIANCO_BIZAGI_PDMCARACVAL():New()
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_ARRAYOFPDMCARACVAL
	Local oClone := BIANCO_BIZAGI_ARRAYOFPDMCARACVAL():NEW()
	oClone:oWSPDMCARACVAL := NIL
	If ::oWSPDMCARACVAL <> NIL 
		oClone:oWSPDMCARACVAL := {}
		aEval( ::oWSPDMCARACVAL , { |x| aadd( oClone:oWSPDMCARACVAL , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_ARRAYOFPDMCARACVAL
	Local cSoap := ""
	aEval( ::oWSPDMCARACVAL , {|x| cSoap := cSoap  +  WSSoapValue("PDMCARACVAL", x , x , "PDMCARACVAL", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFPDMMARCA

WSSTRUCT BIANCO_BIZAGI_ARRAYOFPDMMARCA
	WSDATA   oWSPDMMARCA               AS BIANCO_BIZAGI_PDMMARCA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_ARRAYOFPDMMARCA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_ARRAYOFPDMMARCA
	::oWSPDMMARCA          := {} // Array Of  BIANCO_BIZAGI_PDMMARCA():New()
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_ARRAYOFPDMMARCA
	Local oClone := BIANCO_BIZAGI_ARRAYOFPDMMARCA():NEW()
	oClone:oWSPDMMARCA := NIL
	If ::oWSPDMMARCA <> NIL 
		oClone:oWSPDMMARCA := {}
		aEval( ::oWSPDMMARCA , { |x| aadd( oClone:oWSPDMMARCA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_ARRAYOFPDMMARCA
	Local cSoap := ""
	aEval( ::oWSPDMMARCA , {|x| cSoap := cSoap  +  WSSoapValue("PDMMARCA", x , x , "PDMMARCA", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure PDMCARACVAL

WSSTRUCT BIANCO_BIZAGI_PDMCARACVAL
	WSDATA   cITEM                     AS string
	WSDATA   cSEQUENCIA                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_PDMCARACVAL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_PDMCARACVAL
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_PDMCARACVAL
	Local oClone := BIANCO_BIZAGI_PDMCARACVAL():NEW()
	oClone:cITEM                := ::cITEM
	oClone:cSEQUENCIA           := ::cSEQUENCIA
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_PDMCARACVAL
	Local cSoap := ""
	cSoap += WSSoapValue("ITEM", ::cITEM, ::cITEM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SEQUENCIA", ::cSEQUENCIA, ::cSEQUENCIA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure PDMMARCA

WSSTRUCT BIANCO_BIZAGI_PDMMARCA
	WSDATA   cINFADICIONAL             AS string
	WSDATA   cMARCA                    AS string
	WSDATA   cREFERENCIA               AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BIANCO_BIZAGI_PDMMARCA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BIANCO_BIZAGI_PDMMARCA
Return

WSMETHOD CLONE WSCLIENT BIANCO_BIZAGI_PDMMARCA
	Local oClone := BIANCO_BIZAGI_PDMMARCA():NEW()
	oClone:cINFADICIONAL        := ::cINFADICIONAL
	oClone:cMARCA               := ::cMARCA
	oClone:cREFERENCIA          := ::cREFERENCIA
Return oClone

WSMETHOD SOAPSEND WSCLIENT BIANCO_BIZAGI_PDMMARCA
	Local cSoap := ""
	cSoap += WSSoapValue("INFADICIONAL", ::cINFADICIONAL, ::cINFADICIONAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MARCA", ::cMARCA, ::cMARCA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("REFERENCIA", ::cREFERENCIA, ::cREFERENCIA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap
