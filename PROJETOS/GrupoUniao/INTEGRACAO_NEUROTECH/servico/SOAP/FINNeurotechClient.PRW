#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://dr-hml.neurotech.com.br/services/soap/porting?wsdl
Gerado em        12/03/18 16:47:02
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SMQBZJV ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWorkflowWebService
------------------------------------------------------------------------------- */

WSCLIENT WSWorkflowWebService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD getVersao
	WSMETHOD executarFluxo
	WSMETHOD executarFluxoComParametros
	WSMETHOD executarFluxoAssincrono
	WSMETHOD recuperarDetalhes
	WSMETHOD alterarStatus
	WSMETHOD obterDecisaoFinal
	WSMETHOD monitorar
	WSMETHOD monitorarVersaoPolitica
	WSMETHOD monitorarComCredenciais
	WSMETHOD recuperarStatusCliente
	WSMETHOD recuperarLayout
	WSMETHOD executarPoliticaEspecialista

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cgetVersaoResult          AS string
	WSDATA   npCdAssociado             AS int
	WSDATA   npCdFilial                AS int
	WSDATA   cpSenha                   AS string
	WSDATA   oWSpFluxo                 AS WorkflowWebService_Fluxo
	WSDATA   oWSexecutarFluxoResult    AS WorkflowWebService_RetornoFluxo
	WSDATA   oWSCredenciais            AS WorkflowWebService_Credenciais
	WSDATA   oWSFluxo                  AS WorkflowWebService_Fluxo
	WSDATA   oWSParametros             AS WorkflowWebService_ArrayOfPropriedade
	WSDATA   oWSexecutarFluxoComParametrosResult AS WorkflowWebService_RetornoFluxoComParametros
	WSDATA   oWSexecutarFluxoAssincronoResult AS WorkflowWebService_RetornoFluxoAssincrono
	WSDATA   npLogId                   AS int
	WSDATA   oWSrecuperarDetalhesResult AS WorkflowWebService_ArrayOfParametroFluxo
	WSDATA   cpNovoStatus              AS string
	WSDATA   oWSalterarStatusResult    AS WorkflowWebService_RetornoAtualizacaoStatus
	WSDATA   oWSobterDecisaoFinalResult AS WorkflowWebService_RetornoDecisaoFinal
	WSDATA   cpNmPolitica              AS string
	WSDATA   oWSmonitorarResult        AS WorkflowWebService_RetornoMonitoramento
	WSDATA   cpVersaoPolitica          AS string
	WSDATA   oWSmonitorarVersaoPoliticaResult AS WorkflowWebService_RetornoMonitoramento
	WSDATA   oWSmonitorarComCredenciaisResult AS WorkflowWebService_RetornoMonitoramento
	WSDATA   npLogIdProposta          AS string // AS long
	WSDATA   oWSrecuperarStatusClienteResult AS WorkflowWebService_ArrayOfRetornoStatusCliente
	WSDATA   oWSrecuperarLayoutResult  AS WorkflowWebService_RetornoLayout
	WSDATA   oWSexecutarPoliticaEspecialistaResult AS WorkflowWebService_RetornoEspecialista

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWorkflowWebService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180727 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWorkflowWebService
	::oWSpFluxo          := WorkflowWebService_FLUXO():New()
	::oWSexecutarFluxoResult := WorkflowWebService_RETORNOFLUXO():New()
	::oWSCredenciais     := WorkflowWebService_CREDENCIAIS():New()
	::oWSFluxo           := WorkflowWebService_FLUXO():New()
	::oWSParametros      := WorkflowWebService_ARRAYOFPROPRIEDADE():New()
	::oWSexecutarFluxoComParametrosResult := WorkflowWebService_RETORNOFLUXOCOMPARAMETROS():New()
	::oWSexecutarFluxoAssincronoResult := WorkflowWebService_RETORNOFLUXOASSINCRONO():New()
	::oWSrecuperarDetalhesResult := WorkflowWebService_ARRAYOFPARAMETROFLUXO():New()
	::oWSalterarStatusResult := WorkflowWebService_RETORNOATUALIZACAOSTATUS():New()
	::oWSobterDecisaoFinalResult := WorkflowWebService_RETORNODECISAOFINAL():New()
	::oWSmonitorarResult := WorkflowWebService_RETORNOMONITORAMENTO():New()
	::oWSmonitorarVersaoPoliticaResult := WorkflowWebService_RETORNOMONITORAMENTO():New()
	::oWSmonitorarComCredenciaisResult := WorkflowWebService_RETORNOMONITORAMENTO():New()
	::oWSrecuperarStatusClienteResult := WorkflowWebService_ARRAYOFRETORNOSTATUSCLIENTE():New()
	::oWSrecuperarLayoutResult := WorkflowWebService_RETORNOLAYOUT():New()
	::oWSexecutarPoliticaEspecialistaResult := WorkflowWebService_RETORNOESPECIALISTA():New()
Return

WSMETHOD RESET WSCLIENT WSWorkflowWebService
	::cgetVersaoResult   := NIL 
	::npCdAssociado      := NIL 
	::npCdFilial         := NIL 
	::cpSenha            := NIL 
	::oWSpFluxo          := NIL 
	::oWSexecutarFluxoResult := NIL 
	::oWSCredenciais     := NIL 
	::oWSFluxo           := NIL 
	::oWSParametros      := NIL 
	::oWSexecutarFluxoComParametrosResult := NIL 
	::oWSexecutarFluxoAssincronoResult := NIL 
	::npLogId            := NIL 
	::oWSrecuperarDetalhesResult := NIL 
	::cpNovoStatus       := NIL 
	::oWSalterarStatusResult := NIL 
	::oWSobterDecisaoFinalResult := NIL 
	::cpNmPolitica       := NIL 
	::oWSmonitorarResult := NIL 
	::cpVersaoPolitica   := NIL 
	::oWSmonitorarVersaoPoliticaResult := NIL 
	::oWSmonitorarComCredenciaisResult := NIL 
	::npLogIdProposta    := NIL 
	::oWSrecuperarStatusClienteResult := NIL 
	::oWSrecuperarLayoutResult := NIL 
	::oWSexecutarPoliticaEspecialistaResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWorkflowWebService
Local oClone := WSWorkflowWebService():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:cgetVersaoResult := ::cgetVersaoResult
	oClone:npCdAssociado := ::npCdAssociado
	oClone:npCdFilial    := ::npCdFilial
	oClone:cpSenha       := ::cpSenha
	oClone:oWSpFluxo     :=  IIF(::oWSpFluxo = NIL , NIL ,::oWSpFluxo:Clone() )
	oClone:oWSexecutarFluxoResult :=  IIF(::oWSexecutarFluxoResult = NIL , NIL ,::oWSexecutarFluxoResult:Clone() )
	oClone:oWSCredenciais :=  IIF(::oWSCredenciais = NIL , NIL ,::oWSCredenciais:Clone() )
	oClone:oWSFluxo      :=  IIF(::oWSFluxo = NIL , NIL ,::oWSFluxo:Clone() )
	oClone:oWSParametros :=  IIF(::oWSParametros = NIL , NIL ,::oWSParametros:Clone() )
	oClone:oWSexecutarFluxoComParametrosResult :=  IIF(::oWSexecutarFluxoComParametrosResult = NIL , NIL ,::oWSexecutarFluxoComParametrosResult:Clone() )
	oClone:oWSexecutarFluxoAssincronoResult :=  IIF(::oWSexecutarFluxoAssincronoResult = NIL , NIL ,::oWSexecutarFluxoAssincronoResult:Clone() )
	oClone:npLogId       := ::npLogId
	oClone:oWSrecuperarDetalhesResult :=  IIF(::oWSrecuperarDetalhesResult = NIL , NIL ,::oWSrecuperarDetalhesResult:Clone() )
	oClone:cpNovoStatus  := ::cpNovoStatus
	oClone:oWSalterarStatusResult :=  IIF(::oWSalterarStatusResult = NIL , NIL ,::oWSalterarStatusResult:Clone() )
	oClone:oWSobterDecisaoFinalResult :=  IIF(::oWSobterDecisaoFinalResult = NIL , NIL ,::oWSobterDecisaoFinalResult:Clone() )
	oClone:cpNmPolitica  := ::cpNmPolitica
	oClone:oWSmonitorarResult :=  IIF(::oWSmonitorarResult = NIL , NIL ,::oWSmonitorarResult:Clone() )
	oClone:cpVersaoPolitica := ::cpVersaoPolitica
	oClone:oWSmonitorarVersaoPoliticaResult :=  IIF(::oWSmonitorarVersaoPoliticaResult = NIL , NIL ,::oWSmonitorarVersaoPoliticaResult:Clone() )
	oClone:oWSmonitorarComCredenciaisResult :=  IIF(::oWSmonitorarComCredenciaisResult = NIL , NIL ,::oWSmonitorarComCredenciaisResult:Clone() )
	oClone:npLogIdProposta := ::npLogIdProposta
	oClone:oWSrecuperarStatusClienteResult :=  IIF(::oWSrecuperarStatusClienteResult = NIL , NIL ,::oWSrecuperarStatusClienteResult:Clone() )
	oClone:oWSrecuperarLayoutResult :=  IIF(::oWSrecuperarLayoutResult = NIL , NIL ,::oWSrecuperarLayoutResult:Clone() )
	oClone:oWSexecutarPoliticaEspecialistaResult :=  IIF(::oWSexecutarPoliticaEspecialistaResult = NIL , NIL ,::oWSexecutarPoliticaEspecialistaResult:Clone() )
Return oClone

// WSDL Method getVersao of Service WSWorkflowWebService

WSMETHOD getVersao WSSEND NULLPARAM WSRECEIVE cgetVersaoResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getVersao xmlns="http://neurotech.com.br/">'
cSoap += "</getVersao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/getVersao",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::cgetVersaoResult   :=  WSAdvValue( oXmlRet,"_GETVERSAORESPONSE:_GETVERSAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,"wsdl") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method executarFluxo of Service WSWorkflowWebService

WSMETHOD executarFluxo WSSEND npCdAssociado,npCdFilial,cpSenha,oWSpFluxo WSRECEIVE oWSexecutarFluxoResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<executarFluxo xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("pCdAssociado", ::npCdAssociado, npCdAssociado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pCdFilial", ::npCdFilial, npCdFilial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pSenha", ::cpSenha, cpSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pFluxo", ::oWSpFluxo, oWSpFluxo , "Fluxo", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</executarFluxo>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/executarFluxo",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSexecutarFluxoResult:SoapRecv( WSAdvValue( oXmlRet,"_EXECUTARFLUXORESPONSE:_EXECUTARFLUXORESULT","RetornoFluxo",NIL,NIL,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method executarFluxoComParametros of Service WSWorkflowWebService


WSMETHOD executarFluxoComParametros WSSEND oWSCredenciais,oWSFluxo,oWSParametros WSRECEIVE oWSexecutarFluxoComParametrosResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet
Local cReturn := ""
Local cHeader := "<soap:Envelope xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body>"
Local cFooter := "</soap:Body></soap:Envelope>"

BEGIN WSMETHOD

cSoap += '<executarFluxoComParametros xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("Credenciais", ::oWSCredenciais, oWSCredenciais , "Credenciais", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Fluxo", ::oWSFluxo, oWSFluxo , "Fluxo", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Parametros", ::oWSParametros, oWSParametros , "ArrayOfPropriedade", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</executarFluxoComParametros>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/executarFluxoComParametros",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSexecutarFluxoComParametrosResult:SoapRecv( WSAdvValue( oXmlRet,"_EXECUTARFLUXOCOMPARAMETROSRESPONSE:_EXECUTARFLUXOCOMPARAMETROSRESULT","RetornoFluxoComParametros",Nil,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

cReturn := cHeader+cSoap+cFooter
oXmlRet := NIL	

Return cReturn

// WSDL Method executarFluxoAssincrono of Service WSWorkflowWebService

WSMETHOD executarFluxoAssincrono WSSEND oWSCredenciais,oWSFluxo,oWSParametros WSRECEIVE oWSexecutarFluxoAssincronoResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<executarFluxoAssincrono xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("Credenciais", ::oWSCredenciais, oWSCredenciais , "Credenciais", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Fluxo", ::oWSFluxo, oWSFluxo , "Fluxo", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Parametros", ::oWSParametros, oWSParametros , "ArrayOfPropriedade", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</executarFluxoAssincrono>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/executarFluxoAssincrono",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSexecutarFluxoAssincronoResult:SoapRecv( WSAdvValue( oXmlRet,"_EXECUTARFLUXOASSINCRONORESPONSE:_EXECUTARFLUXOASSINCRONORESULT","RetornoFluxoAssincrono",NIL,NIL,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method recuperarDetalhes of Service WSWorkflowWebService

WSMETHOD recuperarDetalhes WSSEND npCdAssociado,npCdFilial,cpSenha,npLogId WSRECEIVE oWSrecuperarDetalhesResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<recuperarDetalhes xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("pCdAssociado", ::npCdAssociado, npCdAssociado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pCdFilial", ::npCdFilial, npCdFilial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pSenha", ::cpSenha, cpSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pLogId", ::npLogId, npLogId , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</recuperarDetalhes>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/recuperarDetalhes",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSrecuperarDetalhesResult:SoapRecv( WSAdvValue( oXmlRet,"_RECUPERARDETALHESRESPONSE:_RECUPERARDETALHESRESULT","ArrayOfParametroFluxo",NIL,NIL,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method alterarStatus of Service WSWorkflowWebService

WSMETHOD alterarStatus WSSEND npCdAssociado,npCdFilial,cpSenha,npLogId,cpNovoStatus WSRECEIVE oWSalterarStatusResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<alterarStatus xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("pCdAssociado", ::npCdAssociado, npCdAssociado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pCdFilial", ::npCdFilial, npCdFilial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pSenha", ::cpSenha, cpSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pLogId", ::npLogId, npLogId , "long", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pNovoStatus", ::cpNovoStatus, cpNovoStatus , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</alterarStatus>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/alterarStatus",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSalterarStatusResult:SoapRecv( WSAdvValue( oXmlRet,"_ALTERARSTATUSRESPONSE:_ALTERARSTATUSRESULT","RetornoAtualizacaoStatus",NIL,NIL,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obterDecisaoFinal of Service WSWorkflowWebService

WSMETHOD obterDecisaoFinal WSSEND npCdAssociado,npCdFilial,cpSenha,npLogId WSRECEIVE oWSobterDecisaoFinalResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obterDecisaoFinal xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("pCdAssociado", ::npCdAssociado, npCdAssociado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pCdFilial", ::npCdFilial, npCdFilial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pSenha", ::cpSenha, cpSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pLogId", ::npLogId, npLogId , "long", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</obterDecisaoFinal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/obterDecisaoFinal",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSobterDecisaoFinalResult:SoapRecv( WSAdvValue( oXmlRet,"_OBTERDECISAOFINALRESPONSE:_OBTERDECISAOFINALRESULT","RetornoDecisaoFinal",NIL,NIL,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method monitorar of Service WSWorkflowWebService

WSMETHOD monitorar WSSEND npCdAssociado,npCdFilial,cpSenha,cpNmPolitica WSRECEIVE oWSmonitorarResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<monitorar xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("pCdAssociado", ::npCdAssociado, npCdAssociado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pCdFilial", ::npCdFilial, npCdFilial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pSenha", ::cpSenha, cpSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pNmPolitica", ::cpNmPolitica, cpNmPolitica , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</monitorar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/monitorar",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSmonitorarResult:SoapRecv( WSAdvValue( oXmlRet,"_MONITORARRESPONSE:_MONITORARRESULT","RetornoMonitoramento",NIL,NIL,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method monitorarVersaoPolitica of Service WSWorkflowWebService

WSMETHOD monitorarVersaoPolitica WSSEND npCdAssociado,npCdFilial,cpSenha,cpNmPolitica,cpVersaoPolitica WSRECEIVE oWSmonitorarVersaoPoliticaResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<monitorarVersaoPolitica xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("pCdAssociado", ::npCdAssociado, npCdAssociado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pCdFilial", ::npCdFilial, npCdFilial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pSenha", ::cpSenha, cpSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pNmPolitica", ::cpNmPolitica, cpNmPolitica , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pVersaoPolitica", ::cpVersaoPolitica, cpVersaoPolitica , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</monitorarVersaoPolitica>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/monitorarVersaoPolitica",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSmonitorarVersaoPoliticaResult:SoapRecv( WSAdvValue( oXmlRet,"_MONITORARVERSAOPOLITICARESPONSE:_MONITORARVERSAOPOLITICARESULT","RetornoMonitoramento",NIL,NIL,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method monitorarComCredenciais of Service WSWorkflowWebService

WSMETHOD monitorarComCredenciais WSSEND oWSCredenciais,cpNmPolitica,cpVersaoPolitica WSRECEIVE oWSmonitorarComCredenciaisResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<monitorarComCredenciais xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("Credenciais", ::oWSCredenciais, oWSCredenciais , "Credenciais", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pNmPolitica", ::cpNmPolitica, cpNmPolitica , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pVersaoPolitica", ::cpVersaoPolitica, cpVersaoPolitica , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</monitorarComCredenciais>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/monitorarComCredenciais",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSmonitorarComCredenciaisResult:SoapRecv( WSAdvValue( oXmlRet,"_MONITORARCOMCREDENCIAISRESPONSE:_MONITORARCOMCREDENCIAISRESULT","RetornoMonitoramento",NIL,NIL,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method recuperarStatusCliente of Service WSWorkflowWebService

WSMETHOD recuperarStatusCliente WSSEND npCdAssociado,npCdFilial,cpSenha,npLogIdProposta WSRECEIVE oWSrecuperarStatusClienteResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<recuperarStatusCliente xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("pCdAssociado", ::npCdAssociado, npCdAssociado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pCdFilial", ::npCdFilial, npCdFilial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pSenha", ::cpSenha, cpSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pLogIdProposta", ::npLogIdProposta, npLogIdProposta , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</recuperarStatusCliente>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/recuperarStatusCliente",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSrecuperarStatusClienteResult:SoapRecv( WSAdvValue( oXmlRet,"_RECUPERARSTATUSCLIENTERESPONSE:_RECUPERARSTATUSCLIENTERESULT","ArrayOfRetornoStatusCliente",NIL,NIL,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method recuperarLayout of Service WSWorkflowWebService

WSMETHOD recuperarLayout WSSEND npCdAssociado,npCdFilial,cpSenha,cpNmPolitica,cpVersaoPolitica WSRECEIVE oWSrecuperarLayoutResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<recuperarLayout xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("pCdAssociado", ::npCdAssociado, npCdAssociado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pCdFilial", ::npCdFilial, npCdFilial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pSenha", ::cpSenha, cpSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pNmPolitica", ::cpNmPolitica, cpNmPolitica , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pVersaoPolitica", ::cpVersaoPolitica, cpVersaoPolitica , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</recuperarLayout>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/recuperarLayout",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSrecuperarLayoutResult:SoapRecv( WSAdvValue( oXmlRet,"_RECUPERARLAYOUTRESPONSE:_RECUPERARLAYOUTRESULT","RetornoLayout",NIL,NIL,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method executarPoliticaEspecialista of Service WSWorkflowWebService

WSMETHOD executarPoliticaEspecialista WSSEND oWSCredenciais,oWSFluxo,oWSParametros WSRECEIVE oWSexecutarPoliticaEspecialistaResult WSCLIENT WSWorkflowWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<executarPoliticaEspecialista xmlns="http://neurotech.com.br/">'
cSoap += WSSoapValue("Credenciais", ::oWSCredenciais, oWSCredenciais , "Credenciais", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Fluxo", ::oWSFluxo, oWSFluxo , "Fluxo", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Parametros", ::oWSParametros, oWSParametros , "ArrayOfPropriedade", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</executarPoliticaEspecialista>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://neurotech.com.br/executarPoliticaEspecialista",; 
	"DOCUMENT","http://neurotech.com.br/",,,; 
	"")

::Init()
::oWSexecutarPoliticaEspecialistaResult:SoapRecv( WSAdvValue( oXmlRet,"_EXECUTARPOLITICAESPECIALISTARESPONSE:_EXECUTARPOLITICAESPECIALISTARESULT","RetornoEspecialista",NIL,NIL,NIL,NIL,NIL,"wsdl") )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure Fluxo

WSSTRUCT WorkflowWebService_Fluxo
	WSDATA   cNmPolitica               AS string OPTIONAL
	WSDATA   cTagVersaoPolitica        AS string OPTIONAL
	WSDATA   cNmFluxoResultado         AS string OPTIONAL
	WSDATA   cIdProposta               AS string OPTIONAL //AS long 
	WSDATA   oWSLsParametros           AS WorkflowWebService_ArrayOfParametroFluxo OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_Fluxo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_Fluxo
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_Fluxo
	Local oClone := WorkflowWebService_Fluxo():NEW()
	oClone:cNmPolitica          := ::cNmPolitica
	oClone:cTagVersaoPolitica   := ::cTagVersaoPolitica
	oClone:cNmFluxoResultado    := ::cNmFluxoResultado
	oClone:cIdProposta          := ::cIdProposta
	oClone:oWSLsParametros      := IIF(::oWSLsParametros = NIL , NIL , ::oWSLsParametros:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WorkflowWebService_Fluxo
	Local cSoap := ""
	cSoap += WSSoapValue("NmPolitica", ::cNmPolitica, ::cNmPolitica , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TagVersaoPolitica", ::cTagVersaoPolitica, ::cTagVersaoPolitica , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NmFluxoResultado", ::cNmFluxoResultado, ::cNmFluxoResultado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdProposta", ::cIdProposta, ::cIdProposta , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LsParametros", ::oWSLsParametros, ::oWSLsParametros , "ArrayOfParametroFluxo", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure RetornoFluxo

WSSTRUCT WorkflowWebService_RetornoFluxo
	WSDATA   nCdOperacao               AS string //AS long
	WSDATA   cCdMensagem               AS string OPTIONAL
	WSDATA   cDsMensagem               AS string OPTIONAL
	WSDATA   lSucesso                  AS boolean
	WSDATA   cResultado                AS string OPTIONAL
	WSDATA   oWSLsRetorno              AS WorkflowWebService_ArrayOfParametroFluxo OPTIONAL
	WSDATA   cXmlRegras                AS string OPTIONAL
	WSDATA   cXmlConsultas             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RetornoFluxo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RetornoFluxo
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RetornoFluxo
	Local oClone := WorkflowWebService_RetornoFluxo():NEW()
	oClone:nCdOperacao          := ::nCdOperacao
	oClone:cCdMensagem          := ::cCdMensagem
	oClone:cDsMensagem          := ::cDsMensagem
	oClone:lSucesso             := ::lSucesso
	oClone:cResultado           := ::cResultado
	oClone:oWSLsRetorno         := IIF(::oWSLsRetorno = NIL , NIL , ::oWSLsRetorno:Clone() )
	oClone:cXmlRegras           := ::cXmlRegras
	oClone:cXmlConsultas        := ::cXmlConsultas
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RetornoFluxo
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCdOperacao        :=  WSAdvValue( oResponse,"_CDOPERACAO","string",NIL,"Property nCdOperacao as s:string on SOAP Response not found.",NIL,"S",NIL,"wsdl") 
	::cCdMensagem        :=  WSAdvValue( oResponse,"_CDMENSAGEM","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cDsMensagem        :=  WSAdvValue( oResponse,"_DSMENSAGEM","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::lSucesso           :=  WSAdvValue( oResponse,"_SUCESSO","boolean",NIL,"Property lSucesso as s:boolean on SOAP Response not found.",NIL,"L",NIL,"wsdl") 
	::cResultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	oNode6 :=  WSAdvValue( oResponse,"_LSRETORNO","ArrayOfParametroFluxo",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode6 != NIL
		::oWSLsRetorno := WorkflowWebService_ArrayOfParametroFluxo():New()
		::oWSLsRetorno:SoapRecv(oNode6)
	EndIf
	::cXmlRegras         :=  WSAdvValue( oResponse,"_XMLREGRAS","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cXmlConsultas      :=  WSAdvValue( oResponse,"_XMLCONSULTAS","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
Return

// WSDL Data Structure Credenciais

WSSTRUCT WorkflowWebService_Credenciais
	WSDATA   nCodigoAssociado          AS int
	WSDATA   nCodigoFilial             AS int
	WSDATA   cSenha                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_Credenciais
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_Credenciais
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_Credenciais
	Local oClone := WorkflowWebService_Credenciais():NEW()
	oClone:nCodigoAssociado     := ::nCodigoAssociado
	oClone:nCodigoFilial        := ::nCodigoFilial
	oClone:cSenha               := ::cSenha
Return oClone

WSMETHOD SOAPSEND WSCLIENT WorkflowWebService_Credenciais
	Local cSoap := ""
	cSoap += WSSoapValue("CodigoAssociado", ::nCodigoAssociado, ::nCodigoAssociado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoFilial", ::nCodigoFilial, ::nCodigoFilial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Senha", ::cSenha, ::cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure RetornoFluxoComParametros

WSSTRUCT WorkflowWebService_RetornoFluxoComParametros
	WSDATA   nCdOperacao               AS string //AS long
	WSDATA   cCdMensagem               AS string OPTIONAL
	WSDATA   cDsMensagem               AS string OPTIONAL
	WSDATA   lSucesso                  AS boolean
	WSDATA   cResultado                AS string OPTIONAL
	WSDATA   oWSLsRetorno              AS WorkflowWebService_ArrayOfParametroFluxo OPTIONAL
	WSDATA   oWSLsRegra                AS WorkflowWebService_ArrayOfRetornoRegra OPTIONAL
	WSDATA   oWSLsConsulta             AS WorkflowWebService_ArrayOfRetornoConsulta OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RetornoFluxoComParametros
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RetornoFluxoComParametros
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RetornoFluxoComParametros
	Local oClone := WorkflowWebService_RetornoFluxoComParametros():NEW()
	oClone:nCdOperacao          := ::nCdOperacao
	oClone:cCdMensagem          := ::cCdMensagem
	oClone:cDsMensagem          := ::cDsMensagem
	oClone:lSucesso             := ::lSucesso
	oClone:cResultado           := ::cResultado
	oClone:oWSLsRetorno         := IIF(::oWSLsRetorno = NIL , NIL , ::oWSLsRetorno:Clone() )
	oClone:oWSLsRegra           := IIF(::oWSLsRegra = NIL , NIL , ::oWSLsRegra:Clone() )
	oClone:oWSLsConsulta        := IIF(::oWSLsConsulta = NIL , NIL , ::oWSLsConsulta:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RetornoFluxoComParametros
	Local oNode6
	Local oNode7
	Local oNode8
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCdOperacao        :=  WSAdvValue( oResponse,"_CDOPERACAO","string",NIL,"Property nCdOperacao as s:string on SOAP Response not found.",NIL,"S",NIL,"wsdl") 
	::cCdMensagem        :=  WSAdvValue( oResponse,"_CDMENSAGEM","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cDsMensagem        :=  WSAdvValue( oResponse,"_DSMENSAGEM","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::lSucesso           :=  WSAdvValue( oResponse,"_SUCESSO","boolean",NIL,"Property lSucesso as s:boolean on SOAP Response not found.",NIL,"L",NIL,"wsdl") 
	::cResultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	oNode6 :=  WSAdvValue( oResponse,"_LSRETORNO","ArrayOfParametroFluxo",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode6 != NIL
		::oWSLsRetorno := WorkflowWebService_ArrayOfParametroFluxo():New()
		::oWSLsRetorno:SoapRecv(oNode6)
	EndIf
	oNode7 :=  WSAdvValue( oResponse,"_LSREGRA","ArrayOfRetornoRegra",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode7 != NIL
		::oWSLsRegra := WorkflowWebService_ArrayOfRetornoRegra():New()
		::oWSLsRegra:SoapRecv(oNode7)
	EndIf
	oNode8 :=  WSAdvValue( oResponse,"_LSCONSULTA","ArrayOfRetornoConsulta",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode8 != NIL
		::oWSLsConsulta := WorkflowWebService_ArrayOfRetornoConsulta():New()
		::oWSLsConsulta:SoapRecv(oNode8)
	EndIf
Return

// WSDL Data Structure RetornoFluxoAssincrono

WSSTRUCT WorkflowWebService_RetornoFluxoAssincrono
	WSDATA   nCdOperacao               AS string //AS long
	WSDATA   cCdMensagem               AS string OPTIONAL
	WSDATA   cDsMensagem               AS string OPTIONAL
	WSDATA   lSucesso                  AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RetornoFluxoAssincrono
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RetornoFluxoAssincrono
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RetornoFluxoAssincrono
	Local oClone := WorkflowWebService_RetornoFluxoAssincrono():NEW()
	oClone:nCdOperacao          := ::nCdOperacao
	oClone:cCdMensagem          := ::cCdMensagem
	oClone:cDsMensagem          := ::cDsMensagem
	oClone:lSucesso             := ::lSucesso
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RetornoFluxoAssincrono
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCdOperacao        :=  WSAdvValue( oResponse,"_CDOPERACAO","string",NIL,"Property nCdOperacao as s:string on SOAP Response not found.",NIL,"S",NIL,"wsdl") 
	::cCdMensagem        :=  WSAdvValue( oResponse,"_CDMENSAGEM","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cDsMensagem        :=  WSAdvValue( oResponse,"_DSMENSAGEM","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::lSucesso           :=  WSAdvValue( oResponse,"_SUCESSO","boolean",NIL,"Property lSucesso as s:boolean on SOAP Response not found.",NIL,"L",NIL,"wsdl") 
Return

// WSDL Data Structure ArrayOfParametroFluxo

WSSTRUCT WorkflowWebService_ArrayOfParametroFluxo
	WSDATA   oWSParametroFluxo         AS WorkflowWebService_ParametroFluxo OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfParametroFluxo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfParametroFluxo
	::oWSParametroFluxo    := {} // Array Of  WorkflowWebService_PARAMETROFLUXO():New()
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfParametroFluxo
	Local oClone := WorkflowWebService_ArrayOfParametroFluxo():NEW()
	oClone:oWSParametroFluxo := NIL
	If ::oWSParametroFluxo <> NIL 
		oClone:oWSParametroFluxo := {}
		aEval( ::oWSParametroFluxo , { |x| aadd( oClone:oWSParametroFluxo , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WorkflowWebService_ArrayOfParametroFluxo
	Local cSoap := ""
	aEval( ::oWSParametroFluxo , {|x| cSoap := cSoap  +  WSSoapValue("ParametroFluxo", x , x , "ParametroFluxo", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfParametroFluxo
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PARAMETROFLUXO","ParametroFluxo",{},NIL,.T.,"O",NIL,"wsdl") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSParametroFluxo , WorkflowWebService_ParametroFluxo():New() )
			::oWSParametroFluxo[len(::oWSParametroFluxo)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure RetornoAtualizacaoStatus

WSSTRUCT WorkflowWebService_RetornoAtualizacaoStatus
	WSDATA   lSucesso                  AS boolean
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RetornoAtualizacaoStatus
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RetornoAtualizacaoStatus
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RetornoAtualizacaoStatus
	Local oClone := WorkflowWebService_RetornoAtualizacaoStatus():NEW()
	oClone:lSucesso             := ::lSucesso
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RetornoAtualizacaoStatus
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lSucesso           :=  WSAdvValue( oResponse,"_SUCESSO","boolean",NIL,"Property lSucesso as s:boolean on SOAP Response not found.",NIL,"L",NIL,"wsdl") 
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
Return

// WSDL Data Structure RetornoDecisaoFinal

WSSTRUCT WorkflowWebService_RetornoDecisaoFinal
	WSDATA   lSucesso                  AS boolean
	WSDATA   cMensagem                 AS string OPTIONAL
	WSDATA   cResultadoParcial         AS string OPTIONAL
	WSDATA   cResultadoFinal           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RetornoDecisaoFinal
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RetornoDecisaoFinal
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RetornoDecisaoFinal
	Local oClone := WorkflowWebService_RetornoDecisaoFinal():NEW()
	oClone:lSucesso             := ::lSucesso
	oClone:cMensagem            := ::cMensagem
	oClone:cResultadoParcial    := ::cResultadoParcial
	oClone:cResultadoFinal      := ::cResultadoFinal
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RetornoDecisaoFinal
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lSucesso           :=  WSAdvValue( oResponse,"_SUCESSO","boolean",NIL,"Property lSucesso as s:boolean on SOAP Response not found.",NIL,"L",NIL,"wsdl") 
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cResultadoParcial  :=  WSAdvValue( oResponse,"_RESULTADOPARCIAL","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cResultadoFinal    :=  WSAdvValue( oResponse,"_RESULTADOFINAL","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
Return

// WSDL Data Structure RetornoMonitoramento

WSSTRUCT WorkflowWebService_RetornoMonitoramento
	WSDATA   lSucesso                  AS boolean
	WSDATA   cMensagem                 AS string OPTIONAL
	WSDATA   lPingOK                   AS boolean
	WSDATA   nTempoProcessamento       AS long
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RetornoMonitoramento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RetornoMonitoramento
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RetornoMonitoramento
	Local oClone := WorkflowWebService_RetornoMonitoramento():NEW()
	oClone:lSucesso             := ::lSucesso
	oClone:cMensagem            := ::cMensagem
	oClone:lPingOK              := ::lPingOK
	oClone:nTempoProcessamento  := ::nTempoProcessamento
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RetornoMonitoramento
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lSucesso           :=  WSAdvValue( oResponse,"_SUCESSO","boolean",NIL,"Property lSucesso as s:boolean on SOAP Response not found.",NIL,"L",NIL,"wsdl") 
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::lPingOK            :=  WSAdvValue( oResponse,"_PINGOK","boolean",NIL,"Property lPingOK as s:boolean on SOAP Response not found.",NIL,"L",NIL,"wsdl") 
	::nTempoProcessamento :=  WSAdvValue( oResponse,"_TEMPOPROCESSAMENTO","long",NIL,"Property nTempoProcessamento as s:long on SOAP Response not found.",NIL,"N",NIL,"wsdl") 
Return

// WSDL Data Structure ArrayOfRetornoStatusCliente

WSSTRUCT WorkflowWebService_ArrayOfRetornoStatusCliente
	WSDATA   oWSRetornoStatusCliente   AS WorkflowWebService_RetornoStatusCliente OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfRetornoStatusCliente
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfRetornoStatusCliente
	::oWSRetornoStatusCliente := {} // Array Of  WorkflowWebService_RETORNOSTATUSCLIENTE():New()
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfRetornoStatusCliente
	Local oClone := WorkflowWebService_ArrayOfRetornoStatusCliente():NEW()
	oClone:oWSRetornoStatusCliente := NIL
	If ::oWSRetornoStatusCliente <> NIL 
		oClone:oWSRetornoStatusCliente := {}
		aEval( ::oWSRetornoStatusCliente , { |x| aadd( oClone:oWSRetornoStatusCliente , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfRetornoStatusCliente
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETORNOSTATUSCLIENTE","RetornoStatusCliente",{},NIL,.T.,"O",NIL,"wsdl") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRetornoStatusCliente , WorkflowWebService_RetornoStatusCliente():New() )
			::oWSRetornoStatusCliente[len(::oWSRetornoStatusCliente)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure RetornoLayout

WSSTRUCT WorkflowWebService_RetornoLayout
	WSDATA   oWSVariaveisEntrada       AS WorkflowWebService_ArrayOfVariavelFluxoOfDominio OPTIONAL
	WSDATA   oWSVariaveisSaida         AS WorkflowWebService_ArrayOfVariavelFluxoOfDominio OPTIONAL
	WSDATA   oWSVariaveisConfiguracao  AS WorkflowWebService_ArrayOfVariavelFluxoOfDominio OPTIONAL
	WSDATA   oWSVariaveisCalculadas    AS WorkflowWebService_ArrayOfVariavelFluxoOfDominio OPTIONAL
	WSDATA   oWSRegras                 AS WorkflowWebService_ArrayOfRegraFluxo OPTIONAL
	WSDATA   oWSVariaveisGerais        AS WorkflowWebService_ArrayOfVariavelFluxoOfDominio OPTIONAL
	WSDATA   oWSDecisionTrees          AS WorkflowWebService_ArrayOfDecisionTree OPTIONAL
	WSDATA   oWSTelas                  AS WorkflowWebService_ArrayOfTela OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RetornoLayout
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RetornoLayout
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RetornoLayout
	Local oClone := WorkflowWebService_RetornoLayout():NEW()
	oClone:oWSVariaveisEntrada  := IIF(::oWSVariaveisEntrada = NIL , NIL , ::oWSVariaveisEntrada:Clone() )
	oClone:oWSVariaveisSaida    := IIF(::oWSVariaveisSaida = NIL , NIL , ::oWSVariaveisSaida:Clone() )
	oClone:oWSVariaveisConfiguracao := IIF(::oWSVariaveisConfiguracao = NIL , NIL , ::oWSVariaveisConfiguracao:Clone() )
	oClone:oWSVariaveisCalculadas := IIF(::oWSVariaveisCalculadas = NIL , NIL , ::oWSVariaveisCalculadas:Clone() )
	oClone:oWSRegras            := IIF(::oWSRegras = NIL , NIL , ::oWSRegras:Clone() )
	oClone:oWSVariaveisGerais   := IIF(::oWSVariaveisGerais = NIL , NIL , ::oWSVariaveisGerais:Clone() )
	oClone:oWSDecisionTrees     := IIF(::oWSDecisionTrees = NIL , NIL , ::oWSDecisionTrees:Clone() )
	oClone:oWSTelas             := IIF(::oWSTelas = NIL , NIL , ::oWSTelas:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RetornoLayout
	Local oNode1
	Local oNode2
	Local oNode3
	Local oNode4
	Local oNode5
	Local oNode6
	Local oNode7
	Local oNode8
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_VARIAVEISENTRADA","ArrayOfVariavelFluxoOfDominio",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode1 != NIL
		::oWSVariaveisEntrada := WorkflowWebService_ArrayOfVariavelFluxoOfDominio():New()
		::oWSVariaveisEntrada:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_VARIAVEISSAIDA","ArrayOfVariavelFluxoOfDominio",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode2 != NIL
		::oWSVariaveisSaida := WorkflowWebService_ArrayOfVariavelFluxoOfDominio():New()
		::oWSVariaveisSaida:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_VARIAVEISCONFIGURACAO","ArrayOfVariavelFluxoOfDominio",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode3 != NIL
		::oWSVariaveisConfiguracao := WorkflowWebService_ArrayOfVariavelFluxoOfDominio():New()
		::oWSVariaveisConfiguracao:SoapRecv(oNode3)
	EndIf
	oNode4 :=  WSAdvValue( oResponse,"_VARIAVEISCALCULADAS","ArrayOfVariavelFluxoOfDominio",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode4 != NIL
		::oWSVariaveisCalculadas := WorkflowWebService_ArrayOfVariavelFluxoOfDominio():New()
		::oWSVariaveisCalculadas:SoapRecv(oNode4)
	EndIf
	oNode5 :=  WSAdvValue( oResponse,"_REGRAS","ArrayOfRegraFluxo",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode5 != NIL
		::oWSRegras := WorkflowWebService_ArrayOfRegraFluxo():New()
		::oWSRegras:SoapRecv(oNode5)
	EndIf
	oNode6 :=  WSAdvValue( oResponse,"_VARIAVEISGERAIS","ArrayOfVariavelFluxoOfDominio",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode6 != NIL
		::oWSVariaveisGerais := WorkflowWebService_ArrayOfVariavelFluxoOfDominio():New()
		::oWSVariaveisGerais:SoapRecv(oNode6)
	EndIf
	oNode7 :=  WSAdvValue( oResponse,"_DECISIONTREES","ArrayOfDecisionTree",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode7 != NIL
		::oWSDecisionTrees := WorkflowWebService_ArrayOfDecisionTree():New()
		::oWSDecisionTrees:SoapRecv(oNode7)
	EndIf
	oNode8 :=  WSAdvValue( oResponse,"_TELAS","ArrayOfTela",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode8 != NIL
		::oWSTelas := WorkflowWebService_ArrayOfTela():New()
		::oWSTelas:SoapRecv(oNode8)
	EndIf
Return

// WSDL Data Structure RetornoEspecialista

WSSTRUCT WorkflowWebService_RetornoEspecialista
	WSDATA   cTelaAtual                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RetornoEspecialista
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RetornoEspecialista
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RetornoEspecialista
	Local oClone := WorkflowWebService_RetornoEspecialista():NEW()
	oClone:cTelaAtual           := ::cTelaAtual
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RetornoEspecialista
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cTelaAtual         :=  WSAdvValue( oResponse,"_TELAATUAL","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
Return

// WSDL Data Structure ArrayOfRetornoRegra

WSSTRUCT WorkflowWebService_ArrayOfRetornoRegra
	WSDATA   oWSRetornoRegra           AS WorkflowWebService_RetornoRegra OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfRetornoRegra
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfRetornoRegra
	::oWSRetornoRegra      := {} // Array Of  WorkflowWebService_RETORNOREGRA():New()
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfRetornoRegra
	Local oClone := WorkflowWebService_ArrayOfRetornoRegra():NEW()
	oClone:oWSRetornoRegra := NIL
	If ::oWSRetornoRegra <> NIL 
		oClone:oWSRetornoRegra := {}
		aEval( ::oWSRetornoRegra , { |x| aadd( oClone:oWSRetornoRegra , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfRetornoRegra
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETORNOREGRA","RetornoRegra",{},NIL,.T.,"O",NIL,"wsdl") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRetornoRegra , WorkflowWebService_RetornoRegra():New() )
			::oWSRetornoRegra[len(::oWSRetornoRegra)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfRetornoConsulta

WSSTRUCT WorkflowWebService_ArrayOfRetornoConsulta
	WSDATA   oWSRetornoConsulta        AS WorkflowWebService_RetornoConsulta OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfRetornoConsulta
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfRetornoConsulta
	::oWSRetornoConsulta   := {} // Array Of  WorkflowWebService_RETORNOCONSULTA():New()
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfRetornoConsulta
	Local oClone := WorkflowWebService_ArrayOfRetornoConsulta():NEW()
	oClone:oWSRetornoConsulta := NIL
	If ::oWSRetornoConsulta <> NIL 
		oClone:oWSRetornoConsulta := {}
		aEval( ::oWSRetornoConsulta , { |x| aadd( oClone:oWSRetornoConsulta , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfRetornoConsulta
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETORNOCONSULTA","RetornoConsulta",{},NIL,.T.,"O",NIL,"wsdl") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRetornoConsulta , WorkflowWebService_RetornoConsulta():New() )
			::oWSRetornoConsulta[len(::oWSRetornoConsulta)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ParametroFluxo

WSSTRUCT WorkflowWebService_ParametroFluxo
	WSDATA   cNmParametro              AS string OPTIONAL
	WSDATA   cVlParametro              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ParametroFluxo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ParametroFluxo
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ParametroFluxo
	Local oClone := WorkflowWebService_ParametroFluxo():NEW()
	oClone:cNmParametro         := ::cNmParametro
	oClone:cVlParametro         := ::cVlParametro
Return oClone

WSMETHOD SOAPSEND WSCLIENT WorkflowWebService_ParametroFluxo
	Local cSoap := ""
	cSoap += WSSoapValue("NmParametro", ::cNmParametro, ::cNmParametro , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VlParametro", ::cVlParametro, ::cVlParametro , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ParametroFluxo
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNmParametro       :=  WSAdvValue( oResponse,"_NMPARAMETRO","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cVlParametro       :=  WSAdvValue( oResponse,"_VLPARAMETRO","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
Return

// WSDL Data Structure RetornoStatusCliente

WSSTRUCT WorkflowWebService_RetornoStatusCliente
	WSDATA   nCodigoOperacao           AS long
	WSDATA   cDataHora                 AS dateTime
	WSDATA   cNomePolitica             AS string OPTIONAL
	WSDATA   cResultadoParcial         AS string OPTIONAL
	WSDATA   cResultadoFinal           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RetornoStatusCliente
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RetornoStatusCliente
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RetornoStatusCliente
	Local oClone := WorkflowWebService_RetornoStatusCliente():NEW()
	oClone:nCodigoOperacao      := ::nCodigoOperacao
	oClone:cDataHora            := ::cDataHora
	oClone:cNomePolitica        := ::cNomePolitica
	oClone:cResultadoParcial    := ::cResultadoParcial
	oClone:cResultadoFinal      := ::cResultadoFinal
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RetornoStatusCliente
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCodigoOperacao    :=  WSAdvValue( oResponse,"_CODIGOOPERACAO","long",NIL,"Property nCodigoOperacao as s:long on SOAP Response not found.",NIL,"N",NIL,"wsdl") 
	::cDataHora          :=  WSAdvValue( oResponse,"_DATAHORA","dateTime",NIL,"Property cDataHora as s:dateTime on SOAP Response not found.",NIL,"S",NIL,"wsdl") 
	::cNomePolitica      :=  WSAdvValue( oResponse,"_NOMEPOLITICA","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cResultadoParcial  :=  WSAdvValue( oResponse,"_RESULTADOPARCIAL","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cResultadoFinal    :=  WSAdvValue( oResponse,"_RESULTADOFINAL","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
Return

// WSDL Data Structure ArrayOfVariavelFluxoOfDominio

WSSTRUCT WorkflowWebService_ArrayOfVariavelFluxoOfDominio
	WSDATA   oWSVariavelFluxoOfDominio AS WorkflowWebService_VariavelFluxoOfDominio OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfVariavelFluxoOfDominio
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfVariavelFluxoOfDominio
	::oWSVariavelFluxoOfDominio := {} // Array Of  WorkflowWebService_VARIAVELFLUXOOFDOMINIO():New()
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfVariavelFluxoOfDominio
	Local oClone := WorkflowWebService_ArrayOfVariavelFluxoOfDominio():NEW()
	oClone:oWSVariavelFluxoOfDominio := NIL
	If ::oWSVariavelFluxoOfDominio <> NIL 
		oClone:oWSVariavelFluxoOfDominio := {}
		aEval( ::oWSVariavelFluxoOfDominio , { |x| aadd( oClone:oWSVariavelFluxoOfDominio , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfVariavelFluxoOfDominio
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_VARIAVELFLUXOOFDOMINIO","VariavelFluxoOfDominio",{},NIL,.T.,"O",NIL,"wsdl") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSVariavelFluxoOfDominio , WorkflowWebService_VariavelFluxoOfDominio():New() )
			::oWSVariavelFluxoOfDominio[len(::oWSVariavelFluxoOfDominio)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfRegraFluxo

WSSTRUCT WorkflowWebService_ArrayOfRegraFluxo
	WSDATA   oWSRegraFluxo             AS WorkflowWebService_RegraFluxo OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfRegraFluxo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfRegraFluxo
	::oWSRegraFluxo        := {} // Array Of  WorkflowWebService_REGRAFLUXO():New()
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfRegraFluxo
	Local oClone := WorkflowWebService_ArrayOfRegraFluxo():NEW()
	oClone:oWSRegraFluxo := NIL
	If ::oWSRegraFluxo <> NIL 
		oClone:oWSRegraFluxo := {}
		aEval( ::oWSRegraFluxo , { |x| aadd( oClone:oWSRegraFluxo , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfRegraFluxo
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_REGRAFLUXO","RegraFluxo",{},NIL,.T.,"O",NIL,"wsdl") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRegraFluxo , WorkflowWebService_RegraFluxo():New() )
			::oWSRegraFluxo[len(::oWSRegraFluxo)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfDecisionTree

WSSTRUCT WorkflowWebService_ArrayOfDecisionTree
	WSDATA   oWSDecisionTree           AS WorkflowWebService_DecisionTree OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfDecisionTree
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfDecisionTree
	::oWSDecisionTree      := {} // Array Of  WorkflowWebService_DECISIONTREE():New()
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfDecisionTree
	Local oClone := WorkflowWebService_ArrayOfDecisionTree():NEW()
	oClone:oWSDecisionTree := NIL
	If ::oWSDecisionTree <> NIL 
		oClone:oWSDecisionTree := {}
		aEval( ::oWSDecisionTree , { |x| aadd( oClone:oWSDecisionTree , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfDecisionTree
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DECISIONTREE","DecisionTree",{},NIL,.T.,"O",NIL,"wsdl") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDecisionTree , WorkflowWebService_DecisionTree():New() )
			::oWSDecisionTree[len(::oWSDecisionTree)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfTela

WSSTRUCT WorkflowWebService_ArrayOfTela
	WSDATA   oWSTela                   AS WorkflowWebService_Tela OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfTela
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfTela
	::oWSTela              := {} // Array Of  WorkflowWebService_TELA():New()
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfTela
	Local oClone := WorkflowWebService_ArrayOfTela():NEW()
	oClone:oWSTela := NIL
	If ::oWSTela <> NIL 
		oClone:oWSTela := {}
		aEval( ::oWSTela , { |x| aadd( oClone:oWSTela , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfTela
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TELA","Tela",{},NIL,.T.,"O",NIL,"wsdl") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTela , WorkflowWebService_Tela():New() )
			::oWSTela[len(::oWSTela)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure RetornoRegra

WSSTRUCT WorkflowWebService_RetornoRegra
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cFlagStatus               AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cDescricaoAnalitica       AS string OPTIONAL
	WSDATA   cDescricaoSintetica       AS string OPTIONAL
	WSDATA   nCarencia                 AS int
	WSDATA   lCarenciaAtiva            AS boolean
	WSDATA   oWSLsOutrasInformacoes    AS WorkflowWebService_ArrayOfParametroFluxo OPTIONAL
	WSDATA   oWSLsEntradas             AS WorkflowWebService_ArrayOfParametroFluxo OPTIONAL
	WSDATA   cRegraPai                 AS string OPTIONAL
	WSDATA   nDuracao                  AS long
	WSDATA   cStartTime                AS dateTime
	WSDATA   cEndTime                  AS dateTime
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RetornoRegra
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RetornoRegra
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RetornoRegra
	Local oClone := WorkflowWebService_RetornoRegra():NEW()
	oClone:cNome                := ::cNome
	oClone:cFlagStatus          := ::cFlagStatus
	oClone:cDescricao           := ::cDescricao
	oClone:cDescricaoAnalitica  := ::cDescricaoAnalitica
	oClone:cDescricaoSintetica  := ::cDescricaoSintetica
	oClone:nCarencia            := ::nCarencia
	oClone:lCarenciaAtiva       := ::lCarenciaAtiva
	oClone:oWSLsOutrasInformacoes := IIF(::oWSLsOutrasInformacoes = NIL , NIL , ::oWSLsOutrasInformacoes:Clone() )
	oClone:oWSLsEntradas        := IIF(::oWSLsEntradas = NIL , NIL , ::oWSLsEntradas:Clone() )
	oClone:cRegraPai            := ::cRegraPai
	oClone:nDuracao             := ::nDuracao
	oClone:cStartTime           := ::cStartTime
	oClone:cEndTime             := ::cEndTime
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RetornoRegra
	Local oNode8
	Local oNode9
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cFlagStatus        :=  WSAdvValue( oResponse,"_FLAGSTATUS","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cDescricaoAnalitica :=  WSAdvValue( oResponse,"_DESCRICAOANALITICA","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cDescricaoSintetica :=  WSAdvValue( oResponse,"_DESCRICAOSINTETICA","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::nCarencia          :=  WSAdvValue( oResponse,"_CARENCIA","int",NIL,"Property nCarencia as s:int on SOAP Response not found.",NIL,"N",NIL,"wsdl") 
	::lCarenciaAtiva     :=  WSAdvValue( oResponse,"_CARENCIAATIVA","boolean",NIL,"Property lCarenciaAtiva as s:boolean on SOAP Response not found.",NIL,"L",NIL,"wsdl") 
	oNode8 :=  WSAdvValue( oResponse,"_LSOUTRASINFORMACOES","ArrayOfParametroFluxo",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode8 != NIL
		::oWSLsOutrasInformacoes := WorkflowWebService_ArrayOfParametroFluxo():New()
		::oWSLsOutrasInformacoes:SoapRecv(oNode8)
	EndIf
	oNode9 :=  WSAdvValue( oResponse,"_LSENTRADAS","ArrayOfParametroFluxo",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode9 != NIL
		::oWSLsEntradas := WorkflowWebService_ArrayOfParametroFluxo():New()
		::oWSLsEntradas:SoapRecv(oNode9)
	EndIf
	::cRegraPai          :=  WSAdvValue( oResponse,"_REGRAPAI","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::nDuracao           :=  WSAdvValue( oResponse,"_DURACAO","long",NIL,"Property nDuracao as s:long on SOAP Response not found.",NIL,"N",NIL,"wsdl") 
	::cStartTime         :=  WSAdvValue( oResponse,"_STARTTIME","dateTime",NIL,"Property cStartTime as s:dateTime on SOAP Response not found.",NIL,"S",NIL,"wsdl") 
	::cEndTime           :=  WSAdvValue( oResponse,"_ENDTIME","dateTime",NIL,"Property cEndTime as s:dateTime on SOAP Response not found.",NIL,"S",NIL,"wsdl") 
Return

// WSDL Data Structure RetornoConsulta

WSSTRUCT WorkflowWebService_RetornoConsulta
	WSDATA   cIdLog                    AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cStatus                   AS string OPTIONAL
	WSDATA   cDescricaoStatus          AS string OPTIONAL
	WSDATA   cDataHoraRealizacao       AS string OPTIONAL
	WSDATA   cOrigem                   AS string OPTIONAL
	WSDATA   cValidade                 AS string OPTIONAL
	WSDATA   cUrlGateway               AS string OPTIONAL
	WSDATA   cDhInicio                 AS dateTime
	WSDATA   cDhFim                    AS dateTime
	WSDATA   oWSLsResultado            AS WorkflowWebService_ArrayOfParametroFluxo OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RetornoConsulta
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RetornoConsulta
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RetornoConsulta
	Local oClone := WorkflowWebService_RetornoConsulta():NEW()
	oClone:cIdLog               := ::cIdLog
	oClone:cNome                := ::cNome
	oClone:cDescricao           := ::cDescricao
	oClone:cStatus              := ::cStatus
	oClone:cDescricaoStatus     := ::cDescricaoStatus
	oClone:cDataHoraRealizacao  := ::cDataHoraRealizacao
	oClone:cOrigem              := ::cOrigem
	oClone:cValidade            := ::cValidade
	oClone:cUrlGateway          := ::cUrlGateway
	oClone:cDhInicio            := ::cDhInicio
	oClone:cDhFim               := ::cDhFim
	oClone:oWSLsResultado       := IIF(::oWSLsResultado = NIL , NIL , ::oWSLsResultado:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RetornoConsulta
	Local oNode12
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cIdLog             :=  WSAdvValue( oResponse,"_IDLOG","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cStatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cDescricaoStatus   :=  WSAdvValue( oResponse,"_DESCRICAOSTATUS","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cDataHoraRealizacao :=  WSAdvValue( oResponse,"_DATAHORAREALIZACAO","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cOrigem            :=  WSAdvValue( oResponse,"_ORIGEM","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cValidade          :=  WSAdvValue( oResponse,"_VALIDADE","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cUrlGateway        :=  WSAdvValue( oResponse,"_URLGATEWAY","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cDhInicio          :=  WSAdvValue( oResponse,"_DHINICIO","dateTime",NIL,"Property cDhInicio as s:dateTime on SOAP Response not found.",NIL,"S",NIL,"wsdl") 
	::cDhFim             :=  WSAdvValue( oResponse,"_DHFIM","dateTime",NIL,"Property cDhFim as s:dateTime on SOAP Response not found.",NIL,"S",NIL,"wsdl") 
	oNode12 :=  WSAdvValue( oResponse,"_LSRESULTADO","ArrayOfParametroFluxo",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode12 != NIL
		::oWSLsResultado := WorkflowWebService_ArrayOfParametroFluxo():New()
		::oWSLsResultado:SoapRecv(oNode12)
	EndIf
Return

// WSDL Data Structure VariavelFluxoOfDominio

WSSTRUCT WorkflowWebService_VariavelFluxoOfDominio
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSDominioVariavel        AS WorkflowWebService_Dominio OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_VariavelFluxoOfDominio
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_VariavelFluxoOfDominio
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_VariavelFluxoOfDominio
	Local oClone := WorkflowWebService_VariavelFluxoOfDominio():NEW()
	oClone:cNome                := ::cNome
	oClone:cDescricao           := ::cDescricao
	oClone:oWSDominioVariavel   := IIF(::oWSDominioVariavel = NIL , NIL , ::oWSDominioVariavel:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_VariavelFluxoOfDominio
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	oNode3 :=  WSAdvValue( oResponse,"_DOMINIOVARIAVEL","Dominio",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode3 != NIL
		::oWSDominioVariavel := WorkflowWebService_Dominio():New()
		::oWSDominioVariavel:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure RegraFluxo

WSSTRUCT WorkflowWebService_RegraFluxo
	WSDATA   cNomeRegraPai             AS string OPTIONAL
	WSDATA   lRegraPrincipal           AS boolean
	WSDATA   oWSConsultas              AS WorkflowWebService_ArrayOfString OPTIONAL
	WSDATA   oWSOutrasPropriedades     AS WorkflowWebService_ArrayOfPropriedade OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_RegraFluxo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_RegraFluxo
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_RegraFluxo
	Local oClone := WorkflowWebService_RegraFluxo():NEW()
	oClone:cNomeRegraPai        := ::cNomeRegraPai
	oClone:lRegraPrincipal      := ::lRegraPrincipal
	oClone:oWSConsultas         := IIF(::oWSConsultas = NIL , NIL , ::oWSConsultas:Clone() )
	oClone:oWSOutrasPropriedades := IIF(::oWSOutrasPropriedades = NIL , NIL , ::oWSOutrasPropriedades:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_RegraFluxo
	Local oNode3
	Local oNode4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNomeRegraPai      :=  WSAdvValue( oResponse,"_NOMEREGRAPAI","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::lRegraPrincipal    :=  WSAdvValue( oResponse,"_REGRAPRINCIPAL","boolean",NIL,"Property lRegraPrincipal as s:boolean on SOAP Response not found.",NIL,"L",NIL,"wsdl") 
	oNode3 :=  WSAdvValue( oResponse,"_CONSULTAS","ArrayOfString",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode3 != NIL
		::oWSConsultas := WorkflowWebService_ArrayOfString():New()
		::oWSConsultas:SoapRecv(oNode3)
	EndIf
	oNode4 :=  WSAdvValue( oResponse,"_OUTRASPROPRIEDADES","ArrayOfPropriedade",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode4 != NIL
		::oWSOutrasPropriedades := WorkflowWebService_ArrayOfPropriedade():New()
		::oWSOutrasPropriedades:SoapRecv(oNode4)
	EndIf
Return

// WSDL Data Structure DecisionTree

WSSTRUCT WorkflowWebService_DecisionTree
	WSDATA   oWSDesicaoWorkflow        AS WorkflowWebService_ArrayOfDecisionOption OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_DecisionTree
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_DecisionTree
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_DecisionTree
	Local oClone := WorkflowWebService_DecisionTree():NEW()
	oClone:oWSDesicaoWorkflow   := IIF(::oWSDesicaoWorkflow = NIL , NIL , ::oWSDesicaoWorkflow:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_DecisionTree
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DESICAOWORKFLOW","ArrayOfDecisionOption",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode1 != NIL
		::oWSDesicaoWorkflow := WorkflowWebService_ArrayOfDecisionOption():New()
		::oWSDesicaoWorkflow:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure Tela

WSSTRUCT WorkflowWebService_Tela
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cTitulo                   AS string OPTIONAL
	WSDATA   cPergunta                 AS string OPTIONAL
	WSDATA   oWSVariaveis              AS WorkflowWebService_ArrayOfVariavelTela OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_Tela
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_Tela
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_Tela
	Local oClone := WorkflowWebService_Tela():NEW()
	oClone:cNome                := ::cNome
	oClone:cTitulo              := ::cTitulo
	oClone:cPergunta            := ::cPergunta
	oClone:oWSVariaveis         := IIF(::oWSVariaveis = NIL , NIL , ::oWSVariaveis:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_Tela
	Local oNode4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cTitulo            :=  WSAdvValue( oResponse,"_TITULO","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cPergunta          :=  WSAdvValue( oResponse,"_PERGUNTA","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	oNode4 :=  WSAdvValue( oResponse,"_VARIAVEIS","ArrayOfVariavelTela",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode4 != NIL
		::oWSVariaveis := WorkflowWebService_ArrayOfVariavelTela():New()
		::oWSVariaveis:SoapRecv(oNode4)
	EndIf
Return

// WSDL Data Structure Dominio

WSSTRUCT WorkflowWebService_Dominio
	WSDATA   oWSTipoDominio            AS WorkflowWebService_TipoDominio
	WSDATA   cValorDefault             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_Dominio
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_Dominio
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_Dominio
	Local oClone := WorkflowWebService_Dominio():NEW()
	oClone:oWSTipoDominio       := IIF(::oWSTipoDominio = NIL , NIL , ::oWSTipoDominio:Clone() )
	oClone:cValorDefault        := ::cValorDefault
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_Dominio
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_TIPODOMINIO","TipoDominio",NIL,"Property oWSTipoDominio as tns:TipoDominio on SOAP Response not found.",NIL,"O",NIL,"wsdl") 
	If oNode1 != NIL
		::oWSTipoDominio := WorkflowWebService_TipoDominio():New()
		::oWSTipoDominio:SoapRecv(oNode1)
	EndIf
	::cValorDefault      :=  WSAdvValue( oResponse,"_VALORDEFAULT","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
Return

// WSDL Data Structure ArrayOfString

WSSTRUCT WorkflowWebService_ArrayOfString
	WSDATA   cstring                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfString
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfString
	::cstring              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfString
	Local oClone := WorkflowWebService_ArrayOfString():NEW()
	oClone:cstring              := IIf(::cstring <> NIL , aClone(::cstring) , NIL )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfString
	Local oNodes1 :=  WSAdvValue( oResponse,"_STRING","string",{},NIL,.T.,"S",NIL,"wsdl") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::cstring ,  x:TEXT  ) } )
Return

// WSDL Data Structure ArrayOfPropriedade

WSSTRUCT WorkflowWebService_ArrayOfPropriedade
	WSDATA   oWSPropriedade            AS WorkflowWebService_Propriedade OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfPropriedade
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfPropriedade
	::oWSPropriedade       := {} // Array Of  WorkflowWebService_PROPRIEDADE():New()
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfPropriedade
	Local oClone := WorkflowWebService_ArrayOfPropriedade():NEW()
	oClone:oWSPropriedade := NIL
	If ::oWSPropriedade <> NIL 
		oClone:oWSPropriedade := {}
		aEval( ::oWSPropriedade , { |x| aadd( oClone:oWSPropriedade , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WorkflowWebService_ArrayOfPropriedade
	Local cSoap := ""
	aEval( ::oWSPropriedade , {|x| cSoap := cSoap  +  WSSoapValue("Propriedade", x , x , "Propriedade", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfPropriedade
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PROPRIEDADE","Propriedade",{},NIL,.T.,"O",NIL,"wsdl") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPropriedade , WorkflowWebService_Propriedade():New() )
			::oWSPropriedade[len(::oWSPropriedade)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfDecisionOption

WSSTRUCT WorkflowWebService_ArrayOfDecisionOption
	WSDATA   oWSDecisionOption         AS WorkflowWebService_DecisionOption OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfDecisionOption
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfDecisionOption
	::oWSDecisionOption    := {} // Array Of  WorkflowWebService_DECISIONOPTION():New()
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfDecisionOption
	Local oClone := WorkflowWebService_ArrayOfDecisionOption():NEW()
	oClone:oWSDecisionOption := NIL
	If ::oWSDecisionOption <> NIL 
		oClone:oWSDecisionOption := {}
		aEval( ::oWSDecisionOption , { |x| aadd( oClone:oWSDecisionOption , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfDecisionOption
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DECISIONOPTION","DecisionOption",{},NIL,.T.,"O",NIL,"wsdl") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDecisionOption , WorkflowWebService_DecisionOption():New() )
			::oWSDecisionOption[len(::oWSDecisionOption)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfVariavelTela

WSSTRUCT WorkflowWebService_ArrayOfVariavelTela
	WSDATA   oWSVariavelTela           AS WorkflowWebService_VariavelTela OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ArrayOfVariavelTela
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_ArrayOfVariavelTela
	::oWSVariavelTela      := {} // Array Of  WorkflowWebService_VARIAVELTELA():New()
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_ArrayOfVariavelTela
	Local oClone := WorkflowWebService_ArrayOfVariavelTela():NEW()
	oClone:oWSVariavelTela := NIL
	If ::oWSVariavelTela <> NIL 
		oClone:oWSVariavelTela := {}
		aEval( ::oWSVariavelTela , { |x| aadd( oClone:oWSVariavelTela , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ArrayOfVariavelTela
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_VARIAVELTELA","VariavelTela",{},NIL,.T.,"O",NIL,"wsdl") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSVariavelTela , WorkflowWebService_VariavelTela():New() )
			::oWSVariavelTela[len(::oWSVariavelTela)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Enumeration TipoDominio

WSSTRUCT WorkflowWebService_TipoDominio
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_TipoDominio
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "NUMERICO" )
	aadd(::aValueList , "STRING" )
	aadd(::aValueList , "ARRAY" )
	aadd(::aValueList , "MATRIX" )
	aadd(::aValueList , "LISTA" )
Return Self

WSMETHOD SOAPSEND WSCLIENT WorkflowWebService_TipoDominio
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_TipoDominio
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT WorkflowWebService_TipoDominio
Local oClone := WorkflowWebService_TipoDominio():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure Propriedade

WSSTRUCT WorkflowWebService_Propriedade
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cValor                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_Propriedade
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_Propriedade
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_Propriedade
	Local oClone := WorkflowWebService_Propriedade():NEW()
	oClone:cNome                := ::cNome
	oClone:cValor               := ::cValor
Return oClone

WSMETHOD SOAPSEND WSCLIENT WorkflowWebService_Propriedade
	Local cSoap := ""
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Valor", ::cValor, ::cValor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_Propriedade
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::cValor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
Return

// WSDL Data Structure DecisionOption

WSSTRUCT WorkflowWebService_DecisionOption
	WSDATA   oWSDecisao                AS WorkflowWebService_EDecision
	WSDATA   cValor                    AS string OPTIONAL
	WSDATA   oWSNoWorkflow             AS WorkflowWebService_DecisionElement OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_DecisionOption
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_DecisionOption
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_DecisionOption
	Local oClone := WorkflowWebService_DecisionOption():NEW()
	oClone:oWSDecisao           := IIF(::oWSDecisao = NIL , NIL , ::oWSDecisao:Clone() )
	oClone:cValor               := ::cValor
	oClone:oWSNoWorkflow        := IIF(::oWSNoWorkflow = NIL , NIL , ::oWSNoWorkflow:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_DecisionOption
	Local oNode1
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DECISAO","EDecision",NIL,"Property oWSDecisao as tns:EDecision on SOAP Response not found.",NIL,"O",NIL,"wsdl") 
	If oNode1 != NIL
		::oWSDecisao := WorkflowWebService_EDecision():New()
		::oWSDecisao:SoapRecv(oNode1)
	EndIf
	::cValor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	oNode3 :=  WSAdvValue( oResponse,"_NOWORKFLOW","DecisionElement",NIL,NIL,NIL,"O",NIL,"wsdl") 
	If oNode3 != NIL
		::oWSNoWorkflow := WorkflowWebService_DecisionElement():New()
		::oWSNoWorkflow:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure VariavelTela

WSSTRUCT WorkflowWebService_VariavelTela
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   lSomenteLeitura           AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_VariavelTela
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_VariavelTela
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_VariavelTela
	Local oClone := WorkflowWebService_VariavelTela():NEW()
	oClone:cNome                := ::cNome
	oClone:lSomenteLeitura      := ::lSomenteLeitura
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_VariavelTela
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
	::lSomenteLeitura    :=  WSAdvValue( oResponse,"_SOMENTELEITURA","boolean",NIL,"Property lSomenteLeitura as s:boolean on SOAP Response not found.",NIL,"L",NIL,"wsdl") 
Return

// WSDL Data Enumeration EDecision

WSSTRUCT WorkflowWebService_EDecision
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_EDecision
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "EQUALS" )
	aadd(::aValueList , "GREATER_THAN" )
	aadd(::aValueList , "LESS_THAN" )
	aadd(::aValueList , "GREATER_OR_EQUALS_THAN" )
	aadd(::aValueList , "LESS_OR_EQUALS_THAN" )
	aadd(::aValueList , "NOT_EQUALS" )
	aadd(::aValueList , "OTHER" )
Return Self

WSMETHOD SOAPSEND WSCLIENT WorkflowWebService_EDecision
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_EDecision
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT WorkflowWebService_EDecision
Local oClone := WorkflowWebService_EDecision():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure DecisionElement

WSSTRUCT WorkflowWebService_DecisionElement
	WSDATA   oWSNodeType               AS WorkflowWebService_ENodeType
	WSDATA   cNome                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_DecisionElement
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WorkflowWebService_DecisionElement
Return

WSMETHOD CLONE WSCLIENT WorkflowWebService_DecisionElement
	Local oClone := WorkflowWebService_DecisionElement():NEW()
	oClone:oWSNodeType          := IIF(::oWSNodeType = NIL , NIL , ::oWSNodeType:Clone() )
	oClone:cNome                := ::cNome
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_DecisionElement
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_NODETYPE","ENodeType",NIL,"Property oWSNodeType as tns:ENodeType on SOAP Response not found.",NIL,"O",NIL,"wsdl") 
	If oNode1 != NIL
		::oWSNodeType := WorkflowWebService_ENodeType():New()
		::oWSNodeType:SoapRecv(oNode1)
	EndIf
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"wsdl") 
Return

// WSDL Data Enumeration ENodeType

WSSTRUCT WorkflowWebService_ENodeType
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WorkflowWebService_ENodeType
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "ATTRIBUTE" )
	aadd(::aValueList , "PROCEDURE" )
	aadd(::aValueList , "DIALOG" )
	aadd(::aValueList , "DECISION_TREE" )
	aadd(::aValueList , "REPORT" )
	aadd(::aValueList , "CASE" )
	aadd(::aValueList , "RESULT" )
	aadd(::aValueList , "OTHER" )
Return Self

WSMETHOD SOAPSEND WSCLIENT WorkflowWebService_ENodeType
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WorkflowWebService_ENodeType
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT WorkflowWebService_ENodeType
Local oClone := WorkflowWebService_ENodeType():New()
	oClone:Value := ::Value
Return oClone


