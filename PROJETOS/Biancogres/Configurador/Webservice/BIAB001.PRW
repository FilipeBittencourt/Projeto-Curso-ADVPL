#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://"+cEnvironment+"/webservices/workflowenginesoa.asmx?WSDL
Gerado em        06/29/21 14:10:46
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

#DEFINE cEnvironment If (Upper(AllTrim(GetEnvServer())) == "PRODUCAO", "processos.biancogres.com.br", If (Upper(AllTrim(GetEnvServer())) $ "DADOSTESTE", "nice/BIZAGIHOM", "nice/BIZAGIDEV"))


User Function _IYWMIKK ; Return  // "dummy" function - Internal Use

/* -------------------------------------------------------------------------------
WSDL Service WSWorkflowEngineSOA
------------------------------------------------------------------------------- */

	WSCLIENT WSWorkflowEngineSOA

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ping
	WSMETHOD createCasesAsString
	WSMETHOD performActivityAsString
	WSMETHOD setEventAsString
	WSMETHOD getCasesAsString
	WSMETHOD saveActivityAsString
	WSMETHOD getActivitiesAsString
	WSMETHOD suspendCasesAsString
	WSMETHOD resumeCasesAsString
	WSMETHOD getClosedActivitiesAsString
	WSMETHOD getEventsAsString
	WSMETHOD getWorkflowClassesAsString
	WSMETHOD getCategoriesAsString
	WSMETHOD abortCasesAsString
	WSMETHOD getAssignationLogAsString
	WSMETHOD CheckPassword
	WSMETHOD assignActivityAsString
	WSMETHOD grantCaseAccess
	WSMETHOD revokeCaseAccess
	WSMETHOD cleanTestData
	WSMETHOD createCases
	WSMETHOD evalRule
	WSMETHOD getActivities
	WSMETHOD getAssignationLog
	WSMETHOD getClosedActivities
	WSMETHOD performActivity
	WSMETHOD resumeCases
	WSMETHOD rollbackCase
	WSMETHOD setEvent
	WSMETHOD suspendCases
	WSMETHOD abortCases
	WSMETHOD getApplications
	WSMETHOD getCategories
	WSMETHOD getCategories2
	WSMETHOD getCategoriesFromApplicationName
	WSMETHOD getWorkflowClassesFromCategoryName
	WSMETHOD getCategoriesLocalized
	WSMETHOD getWorkflowClasses
	WSMETHOD getWorkflowClasses2
	WSMETHOD getEvents
	WSMETHOD getCases
	WSMETHOD saveActivity
	WSMETHOD assignActivity

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   csMessage                 AS string
	WSDATA   cpingResult               AS string
	WSDATA   ccasesInfo                AS string
	WSDATA   ccreateCasesAsStringResult AS string
	WSDATA   cactivityInfo             AS string
	WSDATA   cperformActivityAsStringResult AS string
	WSDATA   ceventInfo                AS string
	WSDATA   csetEventAsStringResult   AS string
	WSDATA   ccaseFilters              AS string
	WSDATA   cgetCasesAsStringResult   AS string
	WSDATA   csaveActivityAsStringResult AS string
	WSDATA   cactivityFilters          AS string
	WSDATA   cgetActivitiesAsStringResult AS string
	WSDATA   ccases                    AS string
	WSDATA   csuspendCasesAsStringResult AS string
	WSDATA   cresumeCasesAsStringResult AS string
	WSDATA   ccaseInfo                 AS string
	WSDATA   cgetClosedActivitiesAsStringResult AS string
	WSDATA   cactFilters               AS string
	WSDATA   cgetEventsAsStringResult  AS string
	WSDATA   ccategory                 AS string
	WSDATA   cgetWorkflowClassesAsStringResult AS string
	WSDATA   cappName                  AS string
	WSDATA   cgetCategoriesAsStringResult AS string
	WSDATA   cinfo                     AS string
	WSDATA   cabortCasesAsStringResult AS string
	WSDATA   cgetAssignationLogAsStringResult AS string
	WSDATA   csDomain                  AS string
	WSDATA   csUserName                AS string
	WSDATA   csPassword                AS string
	WSDATA   nCheckPasswordResult      AS int
	WSDATA   cassignActivityAsStringResult AS string
	WSDATA   ccaseAccessXML            AS string
	WSDATA   cgrantCaseAccessResult    AS string
	WSDATA   crevokeCaseAccessResult   AS string
	WSDATA   oWScleanTestDataResult    AS SCHEMA
	WSDATA   oWScreateCasesResult      AS SCHEMA
	WSDATA   oWSassertionInfo          AS SCHEMA
	WSDATA   oWSevalRuleResult         AS SCHEMA
	WSDATA   oWSactivitiesFilters      AS SCHEMA
	WSDATA   oWSgetActivitiesResult    AS SCHEMA
	WSDATA   oWSgetAssignationLogResult AS SCHEMA
	WSDATA   oWSgetClosedActivitiesResult AS SCHEMA
	WSDATA   oWSperformActivityResult  AS SCHEMA
	WSDATA   oWSresumeCasesResult      AS SCHEMA
	WSDATA   oWSrollbackCaseResult     AS SCHEMA
	WSDATA   oWSsetEventResult         AS SCHEMA
	WSDATA   oWSsuspendCasesResult     AS SCHEMA
	WSDATA   oWSabortCasesResult       AS SCHEMA
	WSDATA   oWSgetApplicationsResult  AS SCHEMA
	WSDATA   oWSapplication            AS SCHEMA
	WSDATA   oWSgetCategoriesResult    AS SCHEMA
	WSDATA   capplicationName          AS string
	WSDATA   oWSgetCategories2Result   AS SCHEMA
	WSDATA   oWSgetCategoriesFromApplicationNameResult AS SCHEMA
	WSDATA   ccategoryName             AS string
	WSDATA   oWSgetWorkflowClassesFromCategoryNameResult AS SCHEMA
	WSDATA   ccultureName              AS string
	WSDATA   oWSgetCategoriesLocalizedResult AS SCHEMA
	WSDATA   oWSgetWorkflowClassesResult AS SCHEMA
	WSDATA   oWSgetWorkflowClasses2Result AS SCHEMA
	WSDATA   oWSgetEventsResult        AS SCHEMA
	WSDATA   oWScasesFilters           AS SCHEMA
	WSDATA   oWSgetCasesResult         AS SCHEMA
	WSDATA   oWSsaveActivityResult     AS SCHEMA
	WSDATA   oWSxmlDoc                 AS SCHEMA
	WSDATA   oWSassignActivityResult   AS SCHEMA

	ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWorkflowEngineSOA
::Init()
	If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.170117A-20200331] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWorkflowEngineSOA
	::oWScleanTestDataResult := NIL 
	::oWScreateCasesResult := NIL 
	::oWSassertionInfo   := NIL 
	::oWSevalRuleResult  := NIL 
	::oWSactivitiesFilters := NIL 
	::oWSgetActivitiesResult := NIL 
	::oWSgetAssignationLogResult := NIL 
	::oWSgetClosedActivitiesResult := NIL 
	::oWSperformActivityResult := NIL 
	::oWSresumeCasesResult := NIL 
	::oWSrollbackCaseResult := NIL 
	::oWSsetEventResult  := NIL 
	::oWSsuspendCasesResult := NIL 
	::oWSabortCasesResult := NIL 
	::oWSgetApplicationsResult := NIL 
	::oWSapplication     := NIL 
	::oWSgetCategoriesResult := NIL 
	::oWSgetCategories2Result := NIL 
	::oWSgetCategoriesFromApplicationNameResult := NIL 
	::oWSgetWorkflowClassesFromCategoryNameResult := NIL 
	::oWSgetCategoriesLocalizedResult := NIL 
	::oWSgetWorkflowClassesResult := NIL 
	::oWSgetWorkflowClasses2Result := NIL 
	::oWSgetEventsResult := NIL 
	::oWScasesFilters    := NIL 
	::oWSgetCasesResult  := NIL 
	::oWSsaveActivityResult := NIL 
	::oWSxmlDoc          := NIL 
	::oWSassignActivityResult := NIL 
Return

WSMETHOD RESET WSCLIENT WSWorkflowEngineSOA
	::csMessage          := NIL 
	::cpingResult        := NIL 
	::ccasesInfo         := NIL 
	::ccreateCasesAsStringResult := NIL 
	::cactivityInfo      := NIL 
	::cperformActivityAsStringResult := NIL 
	::ceventInfo         := NIL 
	::csetEventAsStringResult := NIL 
	::ccaseFilters       := NIL 
	::cgetCasesAsStringResult := NIL 
	::csaveActivityAsStringResult := NIL 
	::cactivityFilters   := NIL 
	::cgetActivitiesAsStringResult := NIL 
	::ccases             := NIL 
	::csuspendCasesAsStringResult := NIL 
	::cresumeCasesAsStringResult := NIL 
	::ccaseInfo          := NIL 
	::cgetClosedActivitiesAsStringResult := NIL 
	::cactFilters        := NIL 
	::cgetEventsAsStringResult := NIL 
	::ccategory          := NIL 
	::cgetWorkflowClassesAsStringResult := NIL 
	::cappName           := NIL 
	::cgetCategoriesAsStringResult := NIL 
	::cinfo              := NIL 
	::cabortCasesAsStringResult := NIL 
	::cgetAssignationLogAsStringResult := NIL 
	::csDomain           := NIL 
	::csUserName         := NIL 
	::csPassword         := NIL 
	::nCheckPasswordResult := NIL 
	::cassignActivityAsStringResult := NIL 
	::ccaseAccessXML     := NIL 
	::cgrantCaseAccessResult := NIL 
	::crevokeCaseAccessResult := NIL 
	::oWScleanTestDataResult := NIL 
	::oWScreateCasesResult := NIL 
	::oWSassertionInfo   := NIL 
	::oWSevalRuleResult  := NIL 
	::oWSactivitiesFilters := NIL 
	::oWSgetActivitiesResult := NIL 
	::oWSgetAssignationLogResult := NIL 
	::oWSgetClosedActivitiesResult := NIL 
	::oWSperformActivityResult := NIL 
	::oWSresumeCasesResult := NIL 
	::oWSrollbackCaseResult := NIL 
	::oWSsetEventResult  := NIL 
	::oWSsuspendCasesResult := NIL 
	::oWSabortCasesResult := NIL 
	::oWSgetApplicationsResult := NIL 
	::oWSapplication     := NIL 
	::oWSgetCategoriesResult := NIL 
	::capplicationName   := NIL 
	::oWSgetCategories2Result := NIL 
	::oWSgetCategoriesFromApplicationNameResult := NIL 
	::ccategoryName      := NIL 
	::oWSgetWorkflowClassesFromCategoryNameResult := NIL 
	::ccultureName       := NIL 
	::oWSgetCategoriesLocalizedResult := NIL 
	::oWSgetWorkflowClassesResult := NIL 
	::oWSgetWorkflowClasses2Result := NIL 
	::oWSgetEventsResult := NIL 
	::oWScasesFilters    := NIL 
	::oWSgetCasesResult  := NIL 
	::oWSsaveActivityResult := NIL 
	::oWSxmlDoc          := NIL 
	::oWSassignActivityResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWorkflowEngineSOA
Local oClone := WSWorkflowEngineSOA():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:csMessage     := ::csMessage
	oClone:cpingResult   := ::cpingResult
	oClone:ccasesInfo    := ::ccasesInfo
	oClone:ccreateCasesAsStringResult := ::ccreateCasesAsStringResult
	oClone:cactivityInfo := ::cactivityInfo
	oClone:cperformActivityAsStringResult := ::cperformActivityAsStringResult
	oClone:ceventInfo    := ::ceventInfo
	oClone:csetEventAsStringResult := ::csetEventAsStringResult
	oClone:ccaseFilters  := ::ccaseFilters
	oClone:cgetCasesAsStringResult := ::cgetCasesAsStringResult
	oClone:csaveActivityAsStringResult := ::csaveActivityAsStringResult
	oClone:cactivityFilters := ::cactivityFilters
	oClone:cgetActivitiesAsStringResult := ::cgetActivitiesAsStringResult
	oClone:ccases        := ::ccases
	oClone:csuspendCasesAsStringResult := ::csuspendCasesAsStringResult
	oClone:cresumeCasesAsStringResult := ::cresumeCasesAsStringResult
	oClone:ccaseInfo     := ::ccaseInfo
	oClone:cgetClosedActivitiesAsStringResult := ::cgetClosedActivitiesAsStringResult
	oClone:cactFilters   := ::cactFilters
	oClone:cgetEventsAsStringResult := ::cgetEventsAsStringResult
	oClone:ccategory     := ::ccategory
	oClone:cgetWorkflowClassesAsStringResult := ::cgetWorkflowClassesAsStringResult
	oClone:cappName      := ::cappName
	oClone:cgetCategoriesAsStringResult := ::cgetCategoriesAsStringResult
	oClone:cinfo         := ::cinfo
	oClone:cabortCasesAsStringResult := ::cabortCasesAsStringResult
	oClone:cgetAssignationLogAsStringResult := ::cgetAssignationLogAsStringResult
	oClone:csDomain      := ::csDomain
	oClone:csUserName    := ::csUserName
	oClone:csPassword    := ::csPassword
	oClone:nCheckPasswordResult := ::nCheckPasswordResult
	oClone:cassignActivityAsStringResult := ::cassignActivityAsStringResult
	oClone:ccaseAccessXML := ::ccaseAccessXML
	oClone:cgrantCaseAccessResult := ::cgrantCaseAccessResult
	oClone:crevokeCaseAccessResult := ::crevokeCaseAccessResult
	oClone:capplicationName := ::capplicationName
	oClone:ccategoryName := ::ccategoryName
	oClone:ccultureName  := ::ccultureName
Return oClone

// WSDL Method ping of Service WSWorkflowEngineSOA

WSMETHOD ping WSSEND csMessage WSRECEIVE cpingResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ping xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("sMessage", ::csMessage, csMessage , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ping>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/ping",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cpingResult        :=  WSAdvValue( oXmlRet,"_PINGRESPONSE:_PINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method createCasesAsString of Service WSWorkflowEngineSOA

WSMETHOD createCasesAsString WSSEND ccasesInfo WSRECEIVE ccreateCasesAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<createCasesAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("casesInfo", ::ccasesInfo, ccasesInfo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</createCasesAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/createCasesAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::ccreateCasesAsStringResult :=  WSAdvValue( oXmlRet,"_CREATECASESASSTRINGRESPONSE:_CREATECASESASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method performActivityAsString of Service WSWorkflowEngineSOA

WSMETHOD performActivityAsString WSSEND cactivityInfo WSRECEIVE cperformActivityAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<performActivityAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("activityInfo", ::cactivityInfo, cactivityInfo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</performActivityAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/performActivityAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cperformActivityAsStringResult :=  WSAdvValue( oXmlRet,"_PERFORMACTIVITYASSTRINGRESPONSE:_PERFORMACTIVITYASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method setEventAsString of Service WSWorkflowEngineSOA

WSMETHOD setEventAsString WSSEND ceventInfo WSRECEIVE csetEventAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<setEventAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("eventInfo", ::ceventInfo, ceventInfo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</setEventAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/setEventAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::csetEventAsStringResult :=  WSAdvValue( oXmlRet,"_SETEVENTASSTRINGRESPONSE:_SETEVENTASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getCasesAsString of Service WSWorkflowEngineSOA

WSMETHOD getCasesAsString WSSEND ccaseFilters WSRECEIVE cgetCasesAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getCasesAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("caseFilters", ::ccaseFilters, ccaseFilters , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getCasesAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getCasesAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cgetCasesAsStringResult :=  WSAdvValue( oXmlRet,"_GETCASESASSTRINGRESPONSE:_GETCASESASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method saveActivityAsString of Service WSWorkflowEngineSOA

WSMETHOD saveActivityAsString WSSEND cactivityInfo WSRECEIVE csaveActivityAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<saveActivityAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("activityInfo", ::cactivityInfo, cactivityInfo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</saveActivityAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/saveActivityAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::csaveActivityAsStringResult :=  WSAdvValue( oXmlRet,"_SAVEACTIVITYASSTRINGRESPONSE:_SAVEACTIVITYASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getActivitiesAsString of Service WSWorkflowEngineSOA

WSMETHOD getActivitiesAsString WSSEND cactivityFilters WSRECEIVE cgetActivitiesAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getActivitiesAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("activityFilters", ::cactivityFilters, cactivityFilters , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getActivitiesAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getActivitiesAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cgetActivitiesAsStringResult :=  WSAdvValue( oXmlRet,"_GETACTIVITIESASSTRINGRESPONSE:_GETACTIVITIESASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method suspendCasesAsString of Service WSWorkflowEngineSOA

WSMETHOD suspendCasesAsString WSSEND ccases WSRECEIVE csuspendCasesAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<suspendCasesAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("cases", ::ccases, ccases , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</suspendCasesAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/suspendCasesAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::csuspendCasesAsStringResult :=  WSAdvValue( oXmlRet,"_SUSPENDCASESASSTRINGRESPONSE:_SUSPENDCASESASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method resumeCasesAsString of Service WSWorkflowEngineSOA

WSMETHOD resumeCasesAsString WSSEND ccases WSRECEIVE cresumeCasesAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<resumeCasesAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("cases", ::ccases, ccases , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</resumeCasesAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/resumeCasesAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cresumeCasesAsStringResult :=  WSAdvValue( oXmlRet,"_RESUMECASESASSTRINGRESPONSE:_RESUMECASESASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getClosedActivitiesAsString of Service WSWorkflowEngineSOA

WSMETHOD getClosedActivitiesAsString WSSEND ccaseInfo WSRECEIVE cgetClosedActivitiesAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getClosedActivitiesAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("caseInfo", ::ccaseInfo, ccaseInfo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getClosedActivitiesAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getClosedActivitiesAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cgetClosedActivitiesAsStringResult :=  WSAdvValue( oXmlRet,"_GETCLOSEDACTIVITIESASSTRINGRESPONSE:_GETCLOSEDACTIVITIESASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getEventsAsString of Service WSWorkflowEngineSOA

WSMETHOD getEventsAsString WSSEND cactFilters WSRECEIVE cgetEventsAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getEventsAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("actFilters", ::cactFilters, cactFilters , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getEventsAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getEventsAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cgetEventsAsStringResult :=  WSAdvValue( oXmlRet,"_GETEVENTSASSTRINGRESPONSE:_GETEVENTSASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getWorkflowClassesAsString of Service WSWorkflowEngineSOA

WSMETHOD getWorkflowClassesAsString WSSEND ccategory WSRECEIVE cgetWorkflowClassesAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getWorkflowClassesAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("category", ::ccategory, ccategory , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getWorkflowClassesAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getWorkflowClassesAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cgetWorkflowClassesAsStringResult :=  WSAdvValue( oXmlRet,"_GETWORKFLOWCLASSESASSTRINGRESPONSE:_GETWORKFLOWCLASSESASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getCategoriesAsString of Service WSWorkflowEngineSOA

WSMETHOD getCategoriesAsString WSSEND cappName WSRECEIVE cgetCategoriesAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getCategoriesAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("appName", ::cappName, cappName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getCategoriesAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getCategoriesAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cgetCategoriesAsStringResult :=  WSAdvValue( oXmlRet,"_GETCATEGORIESASSTRINGRESPONSE:_GETCATEGORIESASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method abortCasesAsString of Service WSWorkflowEngineSOA

WSMETHOD abortCasesAsString WSSEND cinfo WSRECEIVE cabortCasesAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<abortCasesAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("info", ::cinfo, cinfo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</abortCasesAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/abortCasesAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cabortCasesAsStringResult :=  WSAdvValue( oXmlRet,"_ABORTCASESASSTRINGRESPONSE:_ABORTCASESASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAssignationLogAsString of Service WSWorkflowEngineSOA

WSMETHOD getAssignationLogAsString WSSEND cinfo WSRECEIVE cgetAssignationLogAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getAssignationLogAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("info", ::cinfo, cinfo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getAssignationLogAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getAssignationLogAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cgetAssignationLogAsStringResult :=  WSAdvValue( oXmlRet,"_GETASSIGNATIONLOGASSTRINGRESPONSE:_GETASSIGNATIONLOGASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CheckPassword of Service WSWorkflowEngineSOA

WSMETHOD CheckPassword WSSEND csDomain,csUserName,csPassword WSRECEIVE nCheckPasswordResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CheckPassword xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("sDomain", ::csDomain, csDomain , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sUserName", ::csUserName, csUserName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sPassword", ::csPassword, csPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CheckPassword>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/CheckPassword",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::nCheckPasswordResult :=  WSAdvValue( oXmlRet,"_CHECKPASSWORDRESPONSE:_CHECKPASSWORDRESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method assignActivityAsString of Service WSWorkflowEngineSOA

WSMETHOD assignActivityAsString WSSEND cinfo WSRECEIVE cassignActivityAsStringResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<assignActivityAsString xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("info", ::cinfo, cinfo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</assignActivityAsString>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/assignActivityAsString",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cassignActivityAsStringResult :=  WSAdvValue( oXmlRet,"_ASSIGNACTIVITYASSTRINGRESPONSE:_ASSIGNACTIVITYASSTRINGRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method grantCaseAccess of Service WSWorkflowEngineSOA

WSMETHOD grantCaseAccess WSSEND ccaseAccessXML WSRECEIVE cgrantCaseAccessResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<grantCaseAccess xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("caseAccessXML", ::ccaseAccessXML, ccaseAccessXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</grantCaseAccess>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/grantCaseAccess",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::cgrantCaseAccessResult :=  WSAdvValue( oXmlRet,"_GRANTCASEACCESSRESPONSE:_GRANTCASEACCESSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method revokeCaseAccess of Service WSWorkflowEngineSOA

WSMETHOD revokeCaseAccess WSSEND ccaseAccessXML WSRECEIVE crevokeCaseAccessResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<revokeCaseAccess xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("caseAccessXML", ::ccaseAccessXML, ccaseAccessXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</revokeCaseAccess>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/revokeCaseAccess",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::crevokeCaseAccessResult :=  WSAdvValue( oXmlRet,"_REVOKECASEACCESSRESPONSE:_REVOKECASEACCESSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method cleanTestData of Service WSWorkflowEngineSOA

WSMETHOD cleanTestData WSSEND oWScaseInfo WSRECEIVE oWScleanTestDataResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<cleanTestData xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("caseInfo", ::oWScaseInfo, oWScaseInfo , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</cleanTestData>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/cleanTestData",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWScleanTestDataResult :=  WSAdvValue( oXmlRet,"_CLEANTESTDATARESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method createCases of Service WSWorkflowEngineSOA

WSMETHOD createCases WSSEND oWScasesInfo WSRECEIVE oWScreateCasesResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<createCases xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("casesInfo", ::oWScasesInfo, oWScasesInfo , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</createCases>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/createCases",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWScreateCasesResult :=  WSAdvValue( oXmlRet,"_CREATECASESRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method evalRule of Service WSWorkflowEngineSOA

WSMETHOD evalRule WSSEND oWSassertionInfo WSRECEIVE oWSevalRuleResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<evalRule xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("assertionInfo", ::oWSassertionInfo, oWSassertionInfo , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</evalRule>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/evalRule",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSevalRuleResult  :=  WSAdvValue( oXmlRet,"_EVALRULERESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getActivities of Service WSWorkflowEngineSOA

WSMETHOD getActivities WSSEND oWSactivitiesFilters WSRECEIVE oWSgetActivitiesResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getActivities xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("activitiesFilters", ::oWSactivitiesFilters, oWSactivitiesFilters , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getActivities>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getActivities",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetActivitiesResult :=  WSAdvValue( oXmlRet,"_GETACTIVITIESRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAssignationLog of Service WSWorkflowEngineSOA

WSMETHOD getAssignationLog WSSEND oWScaseInfo WSRECEIVE oWSgetAssignationLogResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getAssignationLog xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("caseInfo", ::oWScaseInfo, oWScaseInfo , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getAssignationLog>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getAssignationLog",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetAssignationLogResult :=  WSAdvValue( oXmlRet,"_GETASSIGNATIONLOGRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getClosedActivities of Service WSWorkflowEngineSOA

WSMETHOD getClosedActivities WSSEND oWScaseInfo WSRECEIVE oWSgetClosedActivitiesResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getClosedActivities xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("caseInfo", ::oWScaseInfo, oWScaseInfo , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getClosedActivities>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getClosedActivities",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetClosedActivitiesResult :=  WSAdvValue( oXmlRet,"_GETCLOSEDACTIVITIESRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method performActivity of Service WSWorkflowEngineSOA

WSMETHOD performActivity WSSEND oWSactivityInfo WSRECEIVE oWSperformActivityResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<performActivity xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("activityInfo", ::oWSactivityInfo, oWSactivityInfo , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</performActivity>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/performActivity",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSperformActivityResult :=  WSAdvValue( oXmlRet,"_PERFORMACTIVITYRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method resumeCases of Service WSWorkflowEngineSOA

WSMETHOD resumeCases WSSEND oWScases WSRECEIVE oWSresumeCasesResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<resumeCases xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("cases", ::oWScases, oWScases , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</resumeCases>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/resumeCases",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSresumeCasesResult :=  WSAdvValue( oXmlRet,"_RESUMECASESRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method rollbackCase of Service WSWorkflowEngineSOA

WSMETHOD rollbackCase WSSEND oWScaseInfo WSRECEIVE oWSrollbackCaseResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<rollbackCase xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("caseInfo", ::oWScaseInfo, oWScaseInfo , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</rollbackCase>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/rollbackCase",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSrollbackCaseResult :=  WSAdvValue( oXmlRet,"_ROLLBACKCASERESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method setEvent of Service WSWorkflowEngineSOA

WSMETHOD setEvent WSSEND oWSeventInfo WSRECEIVE oWSsetEventResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<setEvent xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("eventInfo", ::oWSeventInfo, oWSeventInfo , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</setEvent>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/setEvent",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSsetEventResult  :=  WSAdvValue( oXmlRet,"_SETEVENTRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method suspendCases of Service WSWorkflowEngineSOA

WSMETHOD suspendCases WSSEND oWScases WSRECEIVE oWSsuspendCasesResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<suspendCases xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("cases", ::oWScases, oWScases , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</suspendCases>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/suspendCases",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSsuspendCasesResult :=  WSAdvValue( oXmlRet,"_SUSPENDCASESRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method abortCases of Service WSWorkflowEngineSOA

WSMETHOD abortCases WSSEND oWScasesInfo WSRECEIVE oWSabortCasesResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<abortCases xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("casesInfo", ::oWScasesInfo, oWScasesInfo , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</abortCases>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/abortCases",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSabortCasesResult :=  WSAdvValue( oXmlRet,"_ABORTCASESRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getApplications of Service WSWorkflowEngineSOA

WSMETHOD getApplications WSSEND NULLPARAM WSRECEIVE oWSgetApplicationsResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getApplications xmlns="http://tempuri.org/">'
cSoap += "</getApplications>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getApplications",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetApplicationsResult :=  WSAdvValue( oXmlRet,"_GETAPPLICATIONSRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getCategories of Service WSWorkflowEngineSOA

WSMETHOD getCategories WSSEND oWSapplication WSRECEIVE oWSgetCategoriesResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getCategories xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("application", ::oWSapplication, oWSapplication , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getCategories>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getCategories",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetCategoriesResult :=  WSAdvValue( oXmlRet,"_GETCATEGORIESRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getCategories2 of Service WSWorkflowEngineSOA

WSMETHOD getCategories2 WSSEND capplicationName WSRECEIVE oWSgetCategories2Result WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getCategories2 xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("applicationName", ::capplicationName, capplicationName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getCategories2>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getCategories2",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetCategories2Result :=  WSAdvValue( oXmlRet,"_GETCATEGORIES2RESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getCategoriesFromApplicationName of Service WSWorkflowEngineSOA

WSMETHOD getCategoriesFromApplicationName WSSEND capplicationName WSRECEIVE oWSgetCategoriesFromApplicationNameResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getCategoriesFromApplicationName xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("applicationName", ::capplicationName, capplicationName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getCategoriesFromApplicationName>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getCategoriesFromApplicationName",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetCategoriesFromApplicationNameResult :=  WSAdvValue( oXmlRet,"_GETCATEGORIESFROMAPPLICATIONNAMERESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getWorkflowClassesFromCategoryName of Service WSWorkflowEngineSOA

WSMETHOD getWorkflowClassesFromCategoryName WSSEND ccategoryName WSRECEIVE oWSgetWorkflowClassesFromCategoryNameResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getWorkflowClassesFromCategoryName xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("categoryName", ::ccategoryName, ccategoryName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getWorkflowClassesFromCategoryName>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getWorkflowClassesFromCategoryName",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetWorkflowClassesFromCategoryNameResult :=  WSAdvValue( oXmlRet,"_GETWORKFLOWCLASSESFROMCATEGORYNAMERESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getCategoriesLocalized of Service WSWorkflowEngineSOA

WSMETHOD getCategoriesLocalized WSSEND capplicationName,ccultureName WSRECEIVE oWSgetCategoriesLocalizedResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getCategoriesLocalized xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("applicationName", ::capplicationName, capplicationName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cultureName", ::ccultureName, ccultureName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getCategoriesLocalized>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getCategoriesLocalized",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetCategoriesLocalizedResult :=  WSAdvValue( oXmlRet,"_GETCATEGORIESLOCALIZEDRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getWorkflowClasses of Service WSWorkflowEngineSOA

WSMETHOD getWorkflowClasses WSSEND oWScategory WSRECEIVE oWSgetWorkflowClassesResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getWorkflowClasses xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("category", ::oWScategory, oWScategory , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getWorkflowClasses>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getWorkflowClasses",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetWorkflowClassesResult :=  WSAdvValue( oXmlRet,"_GETWORKFLOWCLASSESRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getWorkflowClasses2 of Service WSWorkflowEngineSOA

WSMETHOD getWorkflowClasses2 WSSEND ccategoryName WSRECEIVE oWSgetWorkflowClasses2Result WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getWorkflowClasses2 xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("categoryName", ::ccategoryName, ccategoryName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getWorkflowClasses2>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getWorkflowClasses2",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetWorkflowClasses2Result :=  WSAdvValue( oXmlRet,"_GETWORKFLOWCLASSES2RESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getEvents of Service WSWorkflowEngineSOA

WSMETHOD getEvents WSSEND oWSactivitiesFilters WSRECEIVE oWSgetEventsResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getEvents xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("activitiesFilters", ::oWSactivitiesFilters, oWSactivitiesFilters , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getEvents>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getEvents",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetEventsResult :=  WSAdvValue( oXmlRet,"_GETEVENTSRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getCases of Service WSWorkflowEngineSOA

WSMETHOD getCases WSSEND oWScasesFilters WSRECEIVE oWSgetCasesResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getCases xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("casesFilters", ::oWScasesFilters, oWScasesFilters , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</getCases>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/getCases",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSgetCasesResult  :=  WSAdvValue( oXmlRet,"_GETCASESRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method saveActivity of Service WSWorkflowEngineSOA

WSMETHOD saveActivity WSSEND oWSactivityInfo WSRECEIVE oWSsaveActivityResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<saveActivity xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("activityInfo", ::oWSactivityInfo, oWSactivityInfo , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</saveActivity>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/saveActivity",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSsaveActivityResult :=  WSAdvValue( oXmlRet,"_SAVEACTIVITYRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method assignActivity of Service WSWorkflowEngineSOA

WSMETHOD assignActivity WSSEND oWSxmlDoc WSRECEIVE oWSassignActivityResult WSCLIENT WSWorkflowEngineSOA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<assignActivity xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("xmlDoc", ::oWSxmlDoc, oWSxmlDoc , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</assignActivity>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/assignActivity",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://"+cEnvironment+"/webservices/workflowenginesoa.asmx")

::Init()
::oWSassignActivityResult :=  WSAdvValue( oXmlRet,"_ASSIGNACTIVITYRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.
