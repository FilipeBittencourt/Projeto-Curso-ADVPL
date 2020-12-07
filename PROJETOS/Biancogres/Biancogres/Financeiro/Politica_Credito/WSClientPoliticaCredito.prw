#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://urano:8077/WSSERVERPOLITICACREDITO.apw?WSDL
Gerado em        11/13/20 17:10:56
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _NHUDZKK ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSSERVERPOLITICACREDITO
------------------------------------------------------------------------------- */

WSCLIENT WSWSSERVERPOLITICACREDITO

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CNPJCUSTOMERVARIABLES
	WSMETHOD CUSTOMERVARIABLES

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSOREQUESTCNPJ           AS WSSERVERPOLITICACREDITO_WSSREQUEST_JOINCUSTOMERVARIABLES
	WSDATA   oWSCNPJCUSTOMERVARIABLESRESULT AS WSSERVERPOLITICACREDITO_WSSRESPONSE_CUSTOMERVARIABLES
	WSDATA   oWSOREQUEST               AS WSSERVERPOLITICACREDITO_WSSREQUEST_CUSTOMERVARIABLES
	WSDATA   oWSCUSTOMERVARIABLESRESULT AS WSSERVERPOLITICACREDITO_ARRAYOFWSSRESPONSE_CUSTOMERVARIABLES

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSWSSREQUEST_JOINCUSTOMERVARIABLES AS WSSERVERPOLITICACREDITO_WSSREQUEST_JOINCUSTOMERVARIABLES
	WSDATA   oWSWSSREQUEST_CUSTOMERVARIABLES AS WSSERVERPOLITICACREDITO_WSSREQUEST_CUSTOMERVARIABLES

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSSERVERPOLITICACREDITO
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.170117A-20200331] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSSERVERPOLITICACREDITO
	::oWSOREQUESTCNPJ    := WSSERVERPOLITICACREDITO_WSSREQUEST_JOINCUSTOMERVARIABLES():New()
	::oWSCNPJCUSTOMERVARIABLESRESULT := WSSERVERPOLITICACREDITO_WSSRESPONSE_CUSTOMERVARIABLES():New()
	::oWSOREQUEST        := WSSERVERPOLITICACREDITO_WSSREQUEST_CUSTOMERVARIABLES():New()
	::oWSCUSTOMERVARIABLESRESULT := WSSERVERPOLITICACREDITO_ARRAYOFWSSRESPONSE_CUSTOMERVARIABLES():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSSREQUEST_JOINCUSTOMERVARIABLES := ::oWSOREQUESTCNPJ
	::oWSWSSREQUEST_CUSTOMERVARIABLES := ::oWSOREQUEST
Return

WSMETHOD RESET WSCLIENT WSWSSERVERPOLITICACREDITO
	::oWSOREQUESTCNPJ    := NIL 
	::oWSCNPJCUSTOMERVARIABLESRESULT := NIL 
	::oWSOREQUEST        := NIL 
	::oWSCUSTOMERVARIABLESRESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSSREQUEST_JOINCUSTOMERVARIABLES := NIL
	::oWSWSSREQUEST_CUSTOMERVARIABLES := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSSERVERPOLITICACREDITO
Local oClone := WSWSSERVERPOLITICACREDITO():New()
	oClone:_URL          := ::_URL 
	oClone:oWSOREQUESTCNPJ :=  IIF(::oWSOREQUESTCNPJ = NIL , NIL ,::oWSOREQUESTCNPJ:Clone() )
	oClone:oWSCNPJCUSTOMERVARIABLESRESULT :=  IIF(::oWSCNPJCUSTOMERVARIABLESRESULT = NIL , NIL ,::oWSCNPJCUSTOMERVARIABLESRESULT:Clone() )
	oClone:oWSOREQUEST   :=  IIF(::oWSOREQUEST = NIL , NIL ,::oWSOREQUEST:Clone() )
	oClone:oWSCUSTOMERVARIABLESRESULT :=  IIF(::oWSCUSTOMERVARIABLESRESULT = NIL , NIL ,::oWSCUSTOMERVARIABLESRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSWSSREQUEST_JOINCUSTOMERVARIABLES := oClone:oWSOREQUESTCNPJ
	oClone:oWSWSSREQUEST_CUSTOMERVARIABLES := oClone:oWSOREQUEST
Return oClone

// WSDL Method CNPJCUSTOMERVARIABLES of Service WSWSSERVERPOLITICACREDITO

WSMETHOD CNPJCUSTOMERVARIABLES WSSEND oWSOREQUESTCNPJ WSRECEIVE oWSCNPJCUSTOMERVARIABLESRESULT WSCLIENT WSWSSERVERPOLITICACREDITO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CNPJCUSTOMERVARIABLES xmlns="http://urano:8077/">'
cSoap += WSSoapValue("OREQUESTCNPJ", ::oWSOREQUESTCNPJ, oWSOREQUESTCNPJ , "WSSREQUEST_JOINCUSTOMERVARIABLES", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CNPJCUSTOMERVARIABLES>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://urano:8077/CNPJCUSTOMERVARIABLES",; 
	"DOCUMENT","http://urano:8077/",,"1.031217",; 
	"http://urano:8077/WSSERVERPOLITICACREDITO.apw")

::Init()
::oWSCNPJCUSTOMERVARIABLESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CNPJCUSTOMERVARIABLESRESPONSE:_CNPJCUSTOMERVARIABLESRESULT","WSSRESPONSE_CUSTOMERVARIABLES",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CUSTOMERVARIABLES of Service WSWSSERVERPOLITICACREDITO

WSMETHOD CUSTOMERVARIABLES WSSEND oWSOREQUEST WSRECEIVE oWSCUSTOMERVARIABLESRESULT WSCLIENT WSWSSERVERPOLITICACREDITO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CUSTOMERVARIABLES xmlns="http://urano:8077/">'
cSoap += WSSoapValue("OREQUEST", ::oWSOREQUEST, oWSOREQUEST , "WSSREQUEST_CUSTOMERVARIABLES", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CUSTOMERVARIABLES>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://urano:8077/CUSTOMERVARIABLES",; 
	"DOCUMENT","http://urano:8077/",,"1.031217",; 
	"http://urano:8077/WSSERVERPOLITICACREDITO.apw")

::Init()
::oWSCUSTOMERVARIABLESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CUSTOMERVARIABLESRESPONSE:_CUSTOMERVARIABLESRESULT","ARRAYOFWSSRESPONSE_CUSTOMERVARIABLES",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure WSSREQUEST_JOINCUSTOMERVARIABLES

WSSTRUCT WSSERVERPOLITICACREDITO_WSSREQUEST_JOINCUSTOMERVARIABLES
	WSDATA   cCCNPJ                    AS string
	WSDATA   cCPROCESS                 AS string
	WSDATA   oWSOAUTH                  AS WSSERVERPOLITICACREDITO_WSSAUTHENTICATION
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSSERVERPOLITICACREDITO_WSSREQUEST_JOINCUSTOMERVARIABLES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSSERVERPOLITICACREDITO_WSSREQUEST_JOINCUSTOMERVARIABLES
Return

WSMETHOD CLONE WSCLIENT WSSERVERPOLITICACREDITO_WSSREQUEST_JOINCUSTOMERVARIABLES
	Local oClone := WSSERVERPOLITICACREDITO_WSSREQUEST_JOINCUSTOMERVARIABLES():NEW()
	oClone:cCCNPJ               := ::cCCNPJ
	oClone:cCPROCESS            := ::cCPROCESS
	oClone:oWSOAUTH             := IIF(::oWSOAUTH = NIL , NIL , ::oWSOAUTH:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSSERVERPOLITICACREDITO_WSSREQUEST_JOINCUSTOMERVARIABLES
	Local cSoap := ""
	cSoap += WSSoapValue("CCNPJ", ::cCCNPJ, ::cCCNPJ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CPROCESS", ::cCPROCESS, ::cCPROCESS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OAUTH", ::oWSOAUTH, ::oWSOAUTH , "WSSAUTHENTICATION", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure WSSRESPONSE_CUSTOMERVARIABLES

WSSTRUCT WSSERVERPOLITICACREDITO_WSSRESPONSE_CUSTOMERVARIABLES
	WSDATA   cCCLIENTE                 AS string
	WSDATA   cCCNPJ                    AS string
	WSDATA   cCCODIGO                  AS string
	WSDATA   cCCODPRO                  AS string
	WSDATA   cCDATA                    AS string
	WSDATA   cCDATPRICOM               AS string
	WSDATA   cCGRPVEN                  AS string
	WSDATA   cCLOJA                    AS string
	WSDATA   cCPORTE                   AS string
	WSDATA   cCSEGMENTO                AS string
	WSDATA   cCTIPO                    AS string
	WSDATA   cNLIMCREATU               AS string
	WSDATA   cNLIMCRESOL               AS string
	WSDATA   cNORIGRP                  AS string
	WSDATA   cNQTD_07                  AS string
	WSDATA   cNQTD_09                  AS string
	WSDATA   cNQTD_11                  AS string
	WSDATA   cNQTD_13                  AS string
	WSDATA   cNQTD_15                  AS string
	WSDATA   cNQTD_17                  AS string
	WSDATA   cNQTD_20                  AS string
	WSDATA   cNQTD_22                  AS string
	WSDATA   cNVLR_08                  AS string
	WSDATA   cNVLR_10                  AS string
	WSDATA   cNVLR_12                  AS string
	WSDATA   cNVLR_14                  AS string
	WSDATA   cNVLR_16                  AS string
	WSDATA   cNVLR_18                  AS string
	WSDATA   cNVLR_19                  AS string
	WSDATA   cNVLR_21                  AS string
	WSDATA   cNVLR_23                  AS string
	WSDATA   cNVLRC_01                 AS string
	WSDATA   cNVLRC_02                 AS string
	WSDATA   cNVLRC_03                 AS string
	WSDATA   cNVLRC_04                 AS string
	WSDATA   cNVLRC_05                 AS string
	WSDATA   cNVLRC_06                 AS string
	WSDATA   cNVLRC_07                 AS string
	WSDATA   cNVLRC_08                 AS string
	WSDATA   cNVLRC_09                 AS string
	WSDATA   cNVLRC_10                 AS string
	WSDATA   cNVLRC_11                 AS string
	WSDATA   cNVLROBR                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSSERVERPOLITICACREDITO_WSSRESPONSE_CUSTOMERVARIABLES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSSERVERPOLITICACREDITO_WSSRESPONSE_CUSTOMERVARIABLES
Return

WSMETHOD CLONE WSCLIENT WSSERVERPOLITICACREDITO_WSSRESPONSE_CUSTOMERVARIABLES
	Local oClone := WSSERVERPOLITICACREDITO_WSSRESPONSE_CUSTOMERVARIABLES():NEW()
	oClone:cCCLIENTE            := ::cCCLIENTE
	oClone:cCCNPJ               := ::cCCNPJ
	oClone:cCCODIGO             := ::cCCODIGO
	oClone:cCCODPRO             := ::cCCODPRO
	oClone:cCDATA               := ::cCDATA
	oClone:cCDATPRICOM          := ::cCDATPRICOM
	oClone:cCGRPVEN             := ::cCGRPVEN
	oClone:cCLOJA               := ::cCLOJA
	oClone:cCPORTE              := ::cCPORTE
	oClone:cCSEGMENTO           := ::cCSEGMENTO
	oClone:cCTIPO               := ::cCTIPO
	oClone:cNLIMCREATU          := ::cNLIMCREATU
	oClone:cNLIMCRESOL          := ::cNLIMCRESOL
	oClone:cNORIGRP             := ::cNORIGRP
	oClone:cNQTD_07             := ::cNQTD_07
	oClone:cNQTD_09             := ::cNQTD_09
	oClone:cNQTD_11             := ::cNQTD_11
	oClone:cNQTD_13             := ::cNQTD_13
	oClone:cNQTD_15             := ::cNQTD_15
	oClone:cNQTD_17             := ::cNQTD_17
	oClone:cNQTD_20             := ::cNQTD_20
	oClone:cNQTD_22             := ::cNQTD_22
	oClone:cNVLR_08             := ::cNVLR_08
	oClone:cNVLR_10             := ::cNVLR_10
	oClone:cNVLR_12             := ::cNVLR_12
	oClone:cNVLR_14             := ::cNVLR_14
	oClone:cNVLR_16             := ::cNVLR_16
	oClone:cNVLR_18             := ::cNVLR_18
	oClone:cNVLR_19             := ::cNVLR_19
	oClone:cNVLR_21             := ::cNVLR_21
	oClone:cNVLR_23             := ::cNVLR_23
	oClone:cNVLRC_01            := ::cNVLRC_01
	oClone:cNVLRC_02            := ::cNVLRC_02
	oClone:cNVLRC_03            := ::cNVLRC_03
	oClone:cNVLRC_04            := ::cNVLRC_04
	oClone:cNVLRC_05            := ::cNVLRC_05
	oClone:cNVLRC_06            := ::cNVLRC_06
	oClone:cNVLRC_07            := ::cNVLRC_07
	oClone:cNVLRC_08            := ::cNVLRC_08
	oClone:cNVLRC_09            := ::cNVLRC_09
	oClone:cNVLRC_10            := ::cNVLRC_10
	oClone:cNVLRC_11            := ::cNVLRC_11
	oClone:cNVLROBR             := ::cNVLROBR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSSERVERPOLITICACREDITO_WSSRESPONSE_CUSTOMERVARIABLES
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCCLIENTE          :=  WSAdvValue( oResponse,"_CCLIENTE","string",NIL,"Property cCCLIENTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCCNPJ             :=  WSAdvValue( oResponse,"_CCNPJ","string",NIL,"Property cCCNPJ as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCCODIGO           :=  WSAdvValue( oResponse,"_CCODIGO","string",NIL,"Property cCCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCCODPRO           :=  WSAdvValue( oResponse,"_CCODPRO","string",NIL,"Property cCCODPRO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCDATA             :=  WSAdvValue( oResponse,"_CDATA","string",NIL,"Property cCDATA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCDATPRICOM        :=  WSAdvValue( oResponse,"_CDATPRICOM","string",NIL,"Property cCDATPRICOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCGRPVEN           :=  WSAdvValue( oResponse,"_CGRPVEN","string",NIL,"Property cCGRPVEN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCLOJA             :=  WSAdvValue( oResponse,"_CLOJA","string",NIL,"Property cCLOJA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCPORTE            :=  WSAdvValue( oResponse,"_CPORTE","string",NIL,"Property cCPORTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCSEGMENTO         :=  WSAdvValue( oResponse,"_CSEGMENTO","string",NIL,"Property cCSEGMENTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCTIPO             :=  WSAdvValue( oResponse,"_CTIPO","string",NIL,"Property cCTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNLIMCREATU        :=  WSAdvValue( oResponse,"_NLIMCREATU","string",NIL,"Property cNLIMCREATU as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNLIMCRESOL        :=  WSAdvValue( oResponse,"_NLIMCRESOL","string",NIL,"Property cNLIMCRESOL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNORIGRP           :=  WSAdvValue( oResponse,"_NORIGRP","string",NIL,"Property cNORIGRP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNQTD_07           :=  WSAdvValue( oResponse,"_NQTD_07","string",NIL,"Property cNQTD_07 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNQTD_09           :=  WSAdvValue( oResponse,"_NQTD_09","string",NIL,"Property cNQTD_09 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNQTD_11           :=  WSAdvValue( oResponse,"_NQTD_11","string",NIL,"Property cNQTD_11 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNQTD_13           :=  WSAdvValue( oResponse,"_NQTD_13","string",NIL,"Property cNQTD_13 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNQTD_15           :=  WSAdvValue( oResponse,"_NQTD_15","string",NIL,"Property cNQTD_15 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNQTD_17           :=  WSAdvValue( oResponse,"_NQTD_17","string",NIL,"Property cNQTD_17 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNQTD_20           :=  WSAdvValue( oResponse,"_NQTD_20","string",NIL,"Property cNQTD_20 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNQTD_22           :=  WSAdvValue( oResponse,"_NQTD_22","string",NIL,"Property cNQTD_22 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLR_08           :=  WSAdvValue( oResponse,"_NVLR_08","string",NIL,"Property cNVLR_08 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLR_10           :=  WSAdvValue( oResponse,"_NVLR_10","string",NIL,"Property cNVLR_10 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLR_12           :=  WSAdvValue( oResponse,"_NVLR_12","string",NIL,"Property cNVLR_12 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLR_14           :=  WSAdvValue( oResponse,"_NVLR_14","string",NIL,"Property cNVLR_14 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLR_16           :=  WSAdvValue( oResponse,"_NVLR_16","string",NIL,"Property cNVLR_16 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLR_18           :=  WSAdvValue( oResponse,"_NVLR_18","string",NIL,"Property cNVLR_18 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLR_19           :=  WSAdvValue( oResponse,"_NVLR_19","string",NIL,"Property cNVLR_19 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLR_21           :=  WSAdvValue( oResponse,"_NVLR_21","string",NIL,"Property cNVLR_21 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLR_23           :=  WSAdvValue( oResponse,"_NVLR_23","string",NIL,"Property cNVLR_23 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLRC_01          :=  WSAdvValue( oResponse,"_NVLRC_01","string",NIL,"Property cNVLRC_01 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLRC_02          :=  WSAdvValue( oResponse,"_NVLRC_02","string",NIL,"Property cNVLRC_02 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLRC_03          :=  WSAdvValue( oResponse,"_NVLRC_03","string",NIL,"Property cNVLRC_03 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLRC_04          :=  WSAdvValue( oResponse,"_NVLRC_04","string",NIL,"Property cNVLRC_04 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLRC_05          :=  WSAdvValue( oResponse,"_NVLRC_05","string",NIL,"Property cNVLRC_05 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLRC_06          :=  WSAdvValue( oResponse,"_NVLRC_06","string",NIL,"Property cNVLRC_06 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLRC_07          :=  WSAdvValue( oResponse,"_NVLRC_07","string",NIL,"Property cNVLRC_07 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLRC_08          :=  WSAdvValue( oResponse,"_NVLRC_08","string",NIL,"Property cNVLRC_08 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLRC_09          :=  WSAdvValue( oResponse,"_NVLRC_09","string",NIL,"Property cNVLRC_09 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLRC_10          :=  WSAdvValue( oResponse,"_NVLRC_10","string",NIL,"Property cNVLRC_10 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLRC_11          :=  WSAdvValue( oResponse,"_NVLRC_11","string",NIL,"Property cNVLRC_11 as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNVLROBR           :=  WSAdvValue( oResponse,"_NVLROBR","string",NIL,"Property cNVLROBR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure WSSREQUEST_CUSTOMERVARIABLES

WSSTRUCT WSSERVERPOLITICACREDITO_WSSREQUEST_CUSTOMERVARIABLES
	WSDATA   cCPROCESS                 AS string
	WSDATA   oWSOAUTH                  AS WSSERVERPOLITICACREDITO_WSSAUTHENTICATION
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSSERVERPOLITICACREDITO_WSSREQUEST_CUSTOMERVARIABLES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSSERVERPOLITICACREDITO_WSSREQUEST_CUSTOMERVARIABLES
Return

WSMETHOD CLONE WSCLIENT WSSERVERPOLITICACREDITO_WSSREQUEST_CUSTOMERVARIABLES
	Local oClone := WSSERVERPOLITICACREDITO_WSSREQUEST_CUSTOMERVARIABLES():NEW()
	oClone:cCPROCESS            := ::cCPROCESS
	oClone:oWSOAUTH             := IIF(::oWSOAUTH = NIL , NIL , ::oWSOAUTH:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSSERVERPOLITICACREDITO_WSSREQUEST_CUSTOMERVARIABLES
	Local cSoap := ""
	cSoap += WSSoapValue("CPROCESS", ::cCPROCESS, ::cCPROCESS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OAUTH", ::oWSOAUTH, ::oWSOAUTH , "WSSAUTHENTICATION", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFWSSRESPONSE_CUSTOMERVARIABLES

WSSTRUCT WSSERVERPOLITICACREDITO_ARRAYOFWSSRESPONSE_CUSTOMERVARIABLES
	WSDATA   oWSWSSRESPONSE_CUSTOMERVARIABLES AS WSSERVERPOLITICACREDITO_WSSRESPONSE_CUSTOMERVARIABLES OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSSERVERPOLITICACREDITO_ARRAYOFWSSRESPONSE_CUSTOMERVARIABLES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSSERVERPOLITICACREDITO_ARRAYOFWSSRESPONSE_CUSTOMERVARIABLES
	::oWSWSSRESPONSE_CUSTOMERVARIABLES := {} // Array Of  WSSERVERPOLITICACREDITO_WSSRESPONSE_CUSTOMERVARIABLES():New()
Return

WSMETHOD CLONE WSCLIENT WSSERVERPOLITICACREDITO_ARRAYOFWSSRESPONSE_CUSTOMERVARIABLES
	Local oClone := WSSERVERPOLITICACREDITO_ARRAYOFWSSRESPONSE_CUSTOMERVARIABLES():NEW()
	oClone:oWSWSSRESPONSE_CUSTOMERVARIABLES := NIL
	If ::oWSWSSRESPONSE_CUSTOMERVARIABLES <> NIL 
		oClone:oWSWSSRESPONSE_CUSTOMERVARIABLES := {}
		aEval( ::oWSWSSRESPONSE_CUSTOMERVARIABLES , { |x| aadd( oClone:oWSWSSRESPONSE_CUSTOMERVARIABLES , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSSERVERPOLITICACREDITO_ARRAYOFWSSRESPONSE_CUSTOMERVARIABLES
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSSRESPONSE_CUSTOMERVARIABLES","WSSRESPONSE_CUSTOMERVARIABLES",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSSRESPONSE_CUSTOMERVARIABLES , WSSERVERPOLITICACREDITO_WSSRESPONSE_CUSTOMERVARIABLES():New() )
			::oWSWSSRESPONSE_CUSTOMERVARIABLES[len(::oWSWSSRESPONSE_CUSTOMERVARIABLES)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure WSSAUTHENTICATION

WSSTRUCT WSSERVERPOLITICACREDITO_WSSAUTHENTICATION
	WSDATA   cCKEY                     AS string
	WSDATA   cCPASS                    AS string
	WSDATA   cCUSER                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSSERVERPOLITICACREDITO_WSSAUTHENTICATION
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSSERVERPOLITICACREDITO_WSSAUTHENTICATION
Return

WSMETHOD CLONE WSCLIENT WSSERVERPOLITICACREDITO_WSSAUTHENTICATION
	Local oClone := WSSERVERPOLITICACREDITO_WSSAUTHENTICATION():NEW()
	oClone:cCKEY                := ::cCKEY
	oClone:cCPASS               := ::cCPASS
	oClone:cCUSER               := ::cCUSER
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSSERVERPOLITICACREDITO_WSSAUTHENTICATION
	Local cSoap := ""
	cSoap += WSSoapValue("CKEY", ::cCKEY, ::cCKEY , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CPASS", ::cCPASS, ::cCPASS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CUSER", ::cCUSER, ::cCUSER , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


