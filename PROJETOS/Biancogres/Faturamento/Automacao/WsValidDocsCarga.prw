#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} WsValidDocsCarga
@description Classe retorna se a carga esta com todos documentos validos
@author Wlysses Cerqueira (Facile)
@since 15/10/2019
@version 1.0
@type class
/*/

WSSERVICE WsValidDocsCarga

	WSDATA oEntradaValidDocs as EntradaValidDocs
	WSDATA oSaidaValidDocs	as SaidaValidDocs
	WSDATA oSaidaValidPrint	as SaidaValidPrint
	
	WSMETHOD Pesquisa
	WSMETHOD SetPrintOk
	
ENDWSSERVICE                 

WSSTRUCT EntradaValidDocs      
        
	WSDATA cCarga as String
	WSDATA cEmp as String
	WSDATA cFil as String	
	                 
ENDWSSTRUCT                 

WSSTRUCT SaidaValidDocs  
                     
	WSDATA lAllReady as Boolean
	
	WSDATA cCarga as String
	WSDATA lNfe as Boolean   
	WSDATA lMdfe as Boolean   
	WSDATA lGnre as Boolean   
	                 
ENDWSSTRUCT                              

WSSTRUCT SaidaValidPrint 
                     
	WSDATA lOk as Boolean  
	                 
ENDWSSTRUCT

WSMETHOD Pesquisa WSRECEIVE oEntradaValidDocs WSSEND oSaidaValidDocs WSSERVICE WsValidDocsCarga
	
	Local oObj := Nil
	Local nW := 0
	
	RPCSETTYPE(3)
	WFPREPENV(::oEntradaValidDocs:cEmp, ::oEntradaValidDocs:cFil)

	::oSaidaValidDocs := WSClassNew("SaidaValidDocs")                                                  

	::oSaidaValidDocs:lAllReady := .F.

	::oSaidaValidDocs:cCarga := ::oEntradaValidDocs:cCarga
	::oSaidaValidDocs:lNfe := .F.
	::oSaidaValidDocs:lMdfe := .F.
	::oSaidaValidDocs:lGnre := .F.
	
	oObj := TFaturamentoMonitor():New()
	
	oObj:CargaOk(::oEntradaValidDocs:cCarga, @::oSaidaValidDocs:lAllReady, @::oSaidaValidDocs:lNfe, @::oSaidaValidDocs:lMdfe, @::oSaidaValidDocs:lGnre)
	
	RpcClearEnv()

Return(.T.)

WSMETHOD SetPrintOk WSRECEIVE oEntradaValidDocs WSSEND oSaidaValidPrint WSSERVICE WsValidDocsCarga
	
	Local oObj := Nil
	Local nW := 0
	
	RPCSETTYPE(3)
	WFPREPENV(::oEntradaValidDocs:cEmp, ::oEntradaValidDocs:cFil)

	::oSaidaValidPrint := WSClassNew("SaidaValidPrint")                                                  

	::oSaidaValidPrint:lOk := .F.
	
	oObj := TFaturamentoMonitor():New()
	
	::oSaidaValidPrint:lOk := oObj:SetPrintOk(::oEntradaValidDocs:cCarga)
	
	RpcClearEnv()

Return(.T.)