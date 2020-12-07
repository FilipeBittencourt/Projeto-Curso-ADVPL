#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://wsrocket.cmsw.com/Rocket_02077546000176/services?wsdl
Gerado em        03/09/20 16:38:21
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _GRJCLKL ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRocketProcessWS
------------------------------------------------------------------------------- */

WSCLIENT WSRocketProcessWS

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD WS_BIANCOGRES_CREDITO_PJ_HOMOLOG
	WSMETHOD WS_BIANCOGRES_CREDITO_PJ_PRD
	WSMETHOD WS_BIANCOGRES_GRUPO_HOMOLOG
	WSMETHOD WS_BIANCOGRES_GRUPO_PRD
	WSMETHOD echo
	WSMETHOD statusProcess

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCNPJ                     AS string
	WSDATA   cTIPO                     AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   cSEGMENTO                 AS string
	WSDATA   cPORTE                    AS string
	WSDATA   cGRUPO                    AS string
	WSDATA   cLOJA                     AS string
	WSDATA   cDATA                     AS string
	WSDATA   cDAT_PRI_COM              AS string
	WSDATA   cLIM_CRE_ATU              AS string
	WSDATA   cVLR_OBRA                 AS string
	WSDATA   cVLR_VAR_19               AS string
	WSDATA   cQTD_VAR_20               AS string
	WSDATA   cVLR_VAR_21               AS string
	WSDATA   cQTD_VAR_22               AS string
	WSDATA   cVLR_VAR_23               AS string
	WSDATA   cVAR_CALC_01              AS string
	WSDATA   cVAR_CALC_02              AS string
	WSDATA   cVAR_CALC_03              AS string
	WSDATA   cVAR_CALC_04              AS string
	WSDATA   cVAR_CALC_05              AS string
	WSDATA   cVAR_CALC_06              AS string
	WSDATA   cVAR_CALC_07              AS string
	WSDATA   cVAR_CALC_08              AS string
	WSDATA   cVAR_CALC_09              AS string
	WSDATA   cVAR_CALC_10              AS string
	WSDATA   cVAR_CALC_11              AS string
	WSDATA   csync                     AS string
	WSDATA   oWSheader                 AS RocketProcessWS_ProcessHeaderVo
	WSDATA   oWSretorno                AS RocketProcessWS_rocketWSReturn
	WSDATA   cORIGEM_GRUPO             AS string
	WSDATA   cLIMITE_SOLICITADO        AS string
	WSDATA   chash                     AS string
	WSDATA   cticket                   AS string
	WSDATA   cstatus_processo          AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRocketProcessWS
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.170117A-20200102] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRocketProcessWS
	::oWSheader          := RocketProcessWS_PROCESSHEADERVO():New()
	::oWSretorno         := RocketProcessWS_ROCKETWSRETURN():New()
Return

WSMETHOD RESET WSCLIENT WSRocketProcessWS
	::cCNPJ              := NIL 
	::cTIPO              := NIL 
	::cCODIGO            := NIL 
	::cSEGMENTO          := NIL 
	::cPORTE             := NIL 
	::cGRUPO             := NIL 
	::cLOJA              := NIL 
	::cDATA              := NIL 
	::cDAT_PRI_COM       := NIL 
	::cLIM_CRE_ATU       := NIL 
	::cVLR_OBRA          := NIL 
	::cVLR_VAR_19        := NIL 
	::cQTD_VAR_20        := NIL 
	::cVLR_VAR_21        := NIL 
	::cQTD_VAR_22        := NIL 
	::cVLR_VAR_23        := NIL 
	::cVAR_CALC_01       := NIL 
	::cVAR_CALC_02       := NIL 
	::cVAR_CALC_03       := NIL 
	::cVAR_CALC_04       := NIL 
	::cVAR_CALC_05       := NIL 
	::cVAR_CALC_06       := NIL 
	::cVAR_CALC_07       := NIL 
	::cVAR_CALC_08       := NIL 
	::cVAR_CALC_09       := NIL 
	::cVAR_CALC_10       := NIL 
	::cVAR_CALC_11       := NIL 
	::csync              := NIL 
	::oWSheader          := NIL 
	::oWSretorno         := NIL 
	::cORIGEM_GRUPO      := NIL 
	::cLIMITE_SOLICITADO := NIL 
	::chash              := NIL 
	::cticket            := NIL 
	::cstatus_processo   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRocketProcessWS
Local oClone := WSRocketProcessWS():New()
	oClone:_URL          := ::_URL 
	oClone:cCNPJ         := ::cCNPJ
	oClone:cTIPO         := ::cTIPO
	oClone:cCODIGO       := ::cCODIGO
	oClone:cSEGMENTO     := ::cSEGMENTO
	oClone:cPORTE        := ::cPORTE
	oClone:cGRUPO        := ::cGRUPO
	oClone:cLOJA         := ::cLOJA
	oClone:cDATA         := ::cDATA
	oClone:cDAT_PRI_COM  := ::cDAT_PRI_COM
	oClone:cLIM_CRE_ATU  := ::cLIM_CRE_ATU
	oClone:cVLR_OBRA     := ::cVLR_OBRA
	oClone:cVLR_VAR_19   := ::cVLR_VAR_19
	oClone:cQTD_VAR_20   := ::cQTD_VAR_20
	oClone:cVLR_VAR_21   := ::cVLR_VAR_21
	oClone:cQTD_VAR_22   := ::cQTD_VAR_22
	oClone:cVLR_VAR_23   := ::cVLR_VAR_23
	oClone:cVAR_CALC_01  := ::cVAR_CALC_01
	oClone:cVAR_CALC_02  := ::cVAR_CALC_02
	oClone:cVAR_CALC_03  := ::cVAR_CALC_03
	oClone:cVAR_CALC_04  := ::cVAR_CALC_04
	oClone:cVAR_CALC_05  := ::cVAR_CALC_05
	oClone:cVAR_CALC_06  := ::cVAR_CALC_06
	oClone:cVAR_CALC_07  := ::cVAR_CALC_07
	oClone:cVAR_CALC_08  := ::cVAR_CALC_08
	oClone:cVAR_CALC_09  := ::cVAR_CALC_09
	oClone:cVAR_CALC_10  := ::cVAR_CALC_10
	oClone:cVAR_CALC_11  := ::cVAR_CALC_11
	oClone:csync         := ::csync
	oClone:oWSheader     :=  IIF(::oWSheader = NIL , NIL ,::oWSheader:Clone() )
	oClone:oWSretorno    :=  IIF(::oWSretorno = NIL , NIL ,::oWSretorno:Clone() )
	oClone:cORIGEM_GRUPO := ::cORIGEM_GRUPO
	oClone:cLIMITE_SOLICITADO := ::cLIMITE_SOLICITADO
	oClone:chash         := ::chash
	oClone:cticket       := ::cticket
	oClone:cstatus_processo := ::cstatus_processo
Return oClone

// WSDL Method WS_BIANCOGRES_CREDITO_PJ_HOMOLOG of Service WSRocketProcessWS

WSMETHOD WS_BIANCOGRES_CREDITO_PJ_HOMOLOG WSSEND cCNPJ,cTIPO,cCODIGO,cSEGMENTO,cPORTE,cGRUPO,cLOJA,cDATA,cDAT_PRI_COM,cLIM_CRE_ATU,cVLR_OBRA,cVLR_VAR_19,cQTD_VAR_20,cVLR_VAR_21,cQTD_VAR_22,cVLR_VAR_23,cVAR_CALC_01,cVAR_CALC_02,cVAR_CALC_03,cVAR_CALC_04,cVAR_CALC_05,cVAR_CALC_06,cVAR_CALC_07,cVAR_CALC_08,cVAR_CALC_09,cVAR_CALC_10,cVAR_CALC_11,csync,oWSheader WSRECEIVE oWSretorno WSCLIENT WSRocketProcessWS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WS_BIANCOGRES_CREDITO_PJ_HOMOLOG xmlns="http://interfaces.webservice.rocket.cmsoftware.com.br">'
cSoap += WSSoapValue("CNPJ", ::cCNPJ, cCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TIPO", ::cTIPO, cTIPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODIGO", ::cCODIGO, cCODIGO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SEGMENTO", ::cSEGMENTO, cSEGMENTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PORTE", ::cPORTE, cPORTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("GRUPO", ::cGRUPO, cGRUPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOJA", ::cLOJA, cLOJA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DATA", ::cDATA, cDATA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DAT_PRI_COM", ::cDAT_PRI_COM, cDAT_PRI_COM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LIM_CRE_ATU", ::cLIM_CRE_ATU, cLIM_CRE_ATU , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLR_OBRA", ::cVLR_OBRA, cVLR_OBRA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLR_VAR_19", ::cVLR_VAR_19, cVLR_VAR_19 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("QTD_VAR_20", ::cQTD_VAR_20, cQTD_VAR_20 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLR_VAR_21", ::cVLR_VAR_21, cVLR_VAR_21 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("QTD_VAR_22", ::cQTD_VAR_22, cQTD_VAR_22 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLR_VAR_23", ::cVLR_VAR_23, cVLR_VAR_23 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_01", ::cVAR_CALC_01, cVAR_CALC_01 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_02", ::cVAR_CALC_02, cVAR_CALC_02 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_03", ::cVAR_CALC_03, cVAR_CALC_03 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_04", ::cVAR_CALC_04, cVAR_CALC_04 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_05", ::cVAR_CALC_05, cVAR_CALC_05 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_06", ::cVAR_CALC_06, cVAR_CALC_06 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_07", ::cVAR_CALC_07, cVAR_CALC_07 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_08", ::cVAR_CALC_08, cVAR_CALC_08 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_09", ::cVAR_CALC_09, cVAR_CALC_09 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_10", ::cVAR_CALC_10, cVAR_CALC_10 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_11", ::cVAR_CALC_11, cVAR_CALC_11 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sync", ::csync, csync , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("header", ::oWSheader, oWSheader , "ProcessHeaderVo", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WS_BIANCOGRES_CREDITO_PJ_HOMOLOG>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"",; 
	"DOCUMENT","http://interfaces.webservice.rocket.cmsoftware.com.br",,,; 
	"http://wsrocket.cmsw.com:80/Rocket_02077546000176/services")

::Init()
::oWSretorno:SoapRecv( WSAdvValue( oXmlRet,"_WS_BIANCOGRES_CREDITO_PJ_HOMOLOGRESPONSE:_RETORNO","rocketWSReturn",NIL,NIL,NIL,NIL,NIL,"tns") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WS_BIANCOGRES_CREDITO_PJ_PRD of Service WSRocketProcessWS

WSMETHOD WS_BIANCOGRES_CREDITO_PJ_PRD WSSEND cCNPJ,cTIPO,cCODIGO,cSEGMENTO,cPORTE,cGRUPO,cLOJA,cDATA,cDAT_PRI_COM,cLIM_CRE_ATU,cVLR_OBRA,cVLR_VAR_19,cQTD_VAR_20,cVLR_VAR_21,cQTD_VAR_22,cVLR_VAR_23,cVAR_CALC_01,cVAR_CALC_02,cVAR_CALC_03,cVAR_CALC_04,cVAR_CALC_05,cVAR_CALC_06,cVAR_CALC_07,cVAR_CALC_08,cVAR_CALC_09,cVAR_CALC_10,cVAR_CALC_11,cORIGEM_GRUPO,cLIMITE_SOLICITADO,csync,oWSheader WSRECEIVE oWSretorno WSCLIENT WSRocketProcessWS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WS_BIANCOGRES_CREDITO_PJ_PRD xmlns="http://interfaces.webservice.rocket.cmsoftware.com.br">'
cSoap += WSSoapValue("CNPJ", ::cCNPJ, cCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TIPO", ::cTIPO, cTIPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODIGO", ::cCODIGO, cCODIGO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SEGMENTO", ::cSEGMENTO, cSEGMENTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PORTE", ::cPORTE, cPORTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("GRUPO", ::cGRUPO, cGRUPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOJA", ::cLOJA, cLOJA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DATA", ::cDATA, cDATA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DAT_PRI_COM", ::cDAT_PRI_COM, cDAT_PRI_COM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LIM_CRE_ATU", ::cLIM_CRE_ATU, cLIM_CRE_ATU , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLR_OBRA", ::cVLR_OBRA, cVLR_OBRA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLR_VAR_19", ::cVLR_VAR_19, cVLR_VAR_19 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("QTD_VAR_20", ::cQTD_VAR_20, cQTD_VAR_20 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLR_VAR_21", ::cVLR_VAR_21, cVLR_VAR_21 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("QTD_VAR_22", ::cQTD_VAR_22, cQTD_VAR_22 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLR_VAR_23", ::cVLR_VAR_23, cVLR_VAR_23 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_01", ::cVAR_CALC_01, cVAR_CALC_01 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_02", ::cVAR_CALC_02, cVAR_CALC_02 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_03", ::cVAR_CALC_03, cVAR_CALC_03 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_04", ::cVAR_CALC_04, cVAR_CALC_04 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_05", ::cVAR_CALC_05, cVAR_CALC_05 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_06", ::cVAR_CALC_06, cVAR_CALC_06 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_07", ::cVAR_CALC_07, cVAR_CALC_07 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_08", ::cVAR_CALC_08, cVAR_CALC_08 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_09", ::cVAR_CALC_09, cVAR_CALC_09 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_10", ::cVAR_CALC_10, cVAR_CALC_10 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VAR_CALC_11", ::cVAR_CALC_11, cVAR_CALC_11 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ORIGEM_GRUPO", ::cORIGEM_GRUPO, cORIGEM_GRUPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LIMITE_SOLICITADO", ::cLIMITE_SOLICITADO, cLIMITE_SOLICITADO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sync", ::csync, csync , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("header", ::oWSheader, oWSheader , "ProcessHeaderVo", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WS_BIANCOGRES_CREDITO_PJ_PRD>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"",; 
	"DOCUMENT","http://interfaces.webservice.rocket.cmsoftware.com.br",,,; 
	"http://wsrocket.cmsw.com:80/Rocket_02077546000176/services")

::Init()
::oWSretorno:SoapRecv( WSAdvValue( oXmlRet,"_WS_BIANCOGRES_CREDITO_PJ_PRDRESPONSE:_RETORNO","rocketWSReturn",NIL,NIL,NIL,NIL,NIL,"tns") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WS_BIANCOGRES_GRUPO_HOMOLOG of Service WSRocketProcessWS

WSMETHOD WS_BIANCOGRES_GRUPO_HOMOLOG WSSEND cCNPJ,cCODIGO,cDATA,cGRUPO,cLIMITE_SOLICITADO,cLIM_CRE_ATU,cLOJA,cSEGMENTO,cTIPO,cVLR_OBRA,csync,oWSheader WSRECEIVE oWSretorno WSCLIENT WSRocketProcessWS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WS_BIANCOGRES_GRUPO_HOMOLOG xmlns="http://interfaces.webservice.rocket.cmsoftware.com.br">'
cSoap += WSSoapValue("CNPJ", ::cCNPJ, cCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODIGO", ::cCODIGO, cCODIGO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DATA", ::cDATA, cDATA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("GRUPO", ::cGRUPO, cGRUPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LIMITE_SOLICITADO", ::cLIMITE_SOLICITADO, cLIMITE_SOLICITADO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LIM_CRE_ATU", ::cLIM_CRE_ATU, cLIM_CRE_ATU , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOJA", ::cLOJA, cLOJA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SEGMENTO", ::cSEGMENTO, cSEGMENTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TIPO", ::cTIPO, cTIPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLR_OBRA", ::cVLR_OBRA, cVLR_OBRA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sync", ::csync, csync , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("header", ::oWSheader, oWSheader , "ProcessHeaderVo", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WS_BIANCOGRES_GRUPO_HOMOLOG>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"",; 
	"DOCUMENT","http://interfaces.webservice.rocket.cmsoftware.com.br",,,; 
	"http://wsrocket.cmsw.com:80/Rocket_02077546000176/services")

::Init()
::oWSretorno:SoapRecv( WSAdvValue( oXmlRet,"_WS_BIANCOGRES_GRUPO_HOMOLOGRESPONSE:_RETORNO","rocketWSReturn",NIL,NIL,NIL,NIL,NIL,"tns") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WS_BIANCOGRES_GRUPO_PRD of Service WSRocketProcessWS

WSMETHOD WS_BIANCOGRES_GRUPO_PRD WSSEND cCNPJ,cTIPO,cCODIGO,cSEGMENTO,cGRUPO,cLOJA,cDATA,cLIM_CRE_ATU,cVLR_OBRA,cLIMITE_SOLICITADO,csync,oWSheader WSRECEIVE oWSretorno WSCLIENT WSRocketProcessWS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WS_BIANCOGRES_GRUPO_PRD xmlns="http://interfaces.webservice.rocket.cmsoftware.com.br">'
cSoap += WSSoapValue("CNPJ", ::cCNPJ, cCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TIPO", ::cTIPO, cTIPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODIGO", ::cCODIGO, cCODIGO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SEGMENTO", ::cSEGMENTO, cSEGMENTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("GRUPO", ::cGRUPO, cGRUPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOJA", ::cLOJA, cLOJA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DATA", ::cDATA, cDATA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LIM_CRE_ATU", ::cLIM_CRE_ATU, cLIM_CRE_ATU , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLR_OBRA", ::cVLR_OBRA, cVLR_OBRA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LIMITE_SOLICITADO", ::cLIMITE_SOLICITADO, cLIMITE_SOLICITADO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sync", ::csync, csync , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("header", ::oWSheader, oWSheader , "ProcessHeaderVo", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</WS_BIANCOGRES_GRUPO_PRD>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"",; 
	"DOCUMENT","http://interfaces.webservice.rocket.cmsoftware.com.br",,,; 
	"http://wsrocket.cmsw.com:80/Rocket_02077546000176/services")

::Init()
::oWSretorno:SoapRecv( WSAdvValue( oXmlRet,"_WS_BIANCOGRES_GRUPO_PRDRESPONSE:_RETORNO","rocketWSReturn",NIL,NIL,NIL,NIL,NIL,"tns") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method echo of Service WSRocketProcessWS

WSMETHOD echo WSSEND NULLPARAM WSRECEIVE cecho WSCLIENT WSRocketProcessWS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<echo xmlns="http://interfaces.webservice.rocket.cmsoftware.com.br">'
cSoap += "</echo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"",; 
	"DOCUMENT","http://interfaces.webservice.rocket.cmsoftware.com.br",,,; 
	"http://wsrocket.cmsw.com:80/Rocket_02077546000176/services")

::Init()
::cecho              :=  WSAdvValue( oXmlRet,"_ECHORESPONSE:_ECHO:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method statusProcess of Service WSRocketProcessWS

WSMETHOD statusProcess WSSEND chash,cticket WSRECEIVE cstatus_processo WSCLIENT WSRocketProcessWS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<statusProcess xmlns="http://interfaces.webservice.rocket.cmsoftware.com.br">'
cSoap += WSSoapValue("hash", ::chash, chash , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticket", ::cticket, cticket , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</statusProcess>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"",; 
	"DOCUMENT","http://interfaces.webservice.rocket.cmsoftware.com.br",,,; 
	"http://wsrocket.cmsw.com:80/Rocket_02077546000176/services")

::Init()
::cstatus_processo   :=  WSAdvValue( oXmlRet,"_STATUSPROCESSRESPONSE:_STATUS_PROCESSO:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure rocketWSReturn

WSSTRUCT RocketProcessWS_rocketWSReturn
	WSDATA   oWSprovedor               AS RocketProcessWS_provedor OPTIONAL
	WSDATA   oWSprocessReturn          AS RocketProcessWS_ProcessReturnVo OPTIONAL
	WSDATA   cnote                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_rocketWSReturn
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_rocketWSReturn
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_rocketWSReturn
	Local oClone := RocketProcessWS_rocketWSReturn():NEW()
	oClone:oWSprovedor          := IIF(::oWSprovedor = NIL , NIL , ::oWSprovedor:Clone() )
	oClone:oWSprocessReturn     := IIF(::oWSprocessReturn = NIL , NIL , ::oWSprocessReturn:Clone() )
	oClone:cnote                := ::cnote
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_rocketWSReturn
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_PROVEDOR","provedor",NIL,NIL,NIL,"O",NIL,"tns") 
	If oNode1 != NIL
		::oWSprovedor := RocketProcessWS_provedor():New()
		::oWSprovedor:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_PROCESSRETURN","ProcessReturnVo",NIL,NIL,NIL,"O",NIL,"tns") 
	If oNode2 != NIL
		::oWSprocessReturn := RocketProcessWS_ProcessReturnVo():New()
		::oWSprocessReturn:SoapRecv(oNode2)
	EndIf
	::cnote              :=  WSAdvValue( oResponse,"_NOTE","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure provedor

WSSTRUCT RocketProcessWS_provedor
	WSDATA   cidProvedor               AS string OPTIONAL
	WSDATA   cidOutput                 AS string OPTIONAL
	WSDATA   ckey                      AS string OPTIONAL
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   oWSvariaveisOut           AS RocketProcessWS_variavel OPTIONAL
	WSDATA   oWSlistas                 AS RocketProcessWS_lista OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_provedor
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_provedor
	::oWSvariaveisOut      := {} // Array Of  RocketProcessWS_VARIAVEL():New()
	::oWSlistas            := {} // Array Of  RocketProcessWS_LISTA():New()
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_provedor
	Local oClone := RocketProcessWS_provedor():NEW()
	oClone:cidProvedor          := ::cidProvedor
	oClone:cidOutput            := ::cidOutput
	oClone:ckey                 := ::ckey
	oClone:cnome                := ::cnome
	oClone:oWSvariaveisOut := NIL
	If ::oWSvariaveisOut <> NIL 
		oClone:oWSvariaveisOut := {}
		aEval( ::oWSvariaveisOut , { |x| aadd( oClone:oWSvariaveisOut , x:Clone() ) } )
	Endif 
	oClone:oWSlistas := NIL
	If ::oWSlistas <> NIL 
		oClone:oWSlistas := {}
		aEval( ::oWSlistas , { |x| aadd( oClone:oWSlistas , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_provedor
	Local nRElem5, oNodes5, nTElem5
	Local nRElem6, oNodes6, nTElem6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cidProvedor        :=  WSAdvValue( oResponse,"_IDPROVEDOR","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cidOutput          :=  WSAdvValue( oResponse,"_IDOUTPUT","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ckey               :=  WSAdvValue( oResponse,"_KEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cnome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"tns") 
	oNodes5 :=  WSAdvValue( oResponse,"_VARIAVEISOUT","variavel",{},NIL,.T.,"O",NIL,"tns") 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSvariaveisOut , RocketProcessWS_variavel():New() )
			::oWSvariaveisOut[len(::oWSvariaveisOut)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
	oNodes6 :=  WSAdvValue( oResponse,"_LISTAS","lista",{},NIL,.T.,"O",NIL,"tns") 
	nTElem6 := len(oNodes6)
	For nRElem6 := 1 to nTElem6 
		If !WSIsNilNode( oNodes6[nRElem6] )
			aadd(::oWSlistas , RocketProcessWS_lista():New() )
			::oWSlistas[len(::oWSlistas)]:SoapRecv(oNodes6[nRElem6])
		Endif
	Next
Return

// WSDL Data Structure ProcessReturnVo

WSSTRUCT RocketProcessWS_ProcessReturnVo
	WSDATA   cticket                   AS string OPTIONAL
	WSDATA   chash                     AS string OPTIONAL
	WSDATA   cstatus                   AS string OPTIONAL
	WSDATA   oWSprocessHeader          AS RocketProcessWS_ProcessHeaderVo OPTIONAL
	WSDATA   cidWorkProcesso           AS string OPTIONAL
	WSDATA   oWSprovedores             AS RocketProcessWS_provedor OPTIONAL
	WSDATA   oWSvariaveisContexto      AS RocketProcessWS_variaveisContexto OPTIONAL
	WSDATA   oWSlistQuiz               AS RocketProcessWS_listQuiz OPTIONAL
	WSDATA   oWSvariaveisInput         AS RocketProcessWS_variavel OPTIONAL
	WSDATA   oWSdataExtractor          AS RocketProcessWS_lista OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_ProcessReturnVo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_ProcessReturnVo
	::oWSprovedores        := {} // Array Of  RocketProcessWS_PROVEDOR():New()
	::oWSlistQuiz          := {} // Array Of  RocketProcessWS_LISTQUIZ():New()
	::oWSvariaveisInput    := {} // Array Of  RocketProcessWS_VARIAVEL():New()
	::oWSdataExtractor     := {} // Array Of  RocketProcessWS_LISTA():New()
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_ProcessReturnVo
	Local oClone := RocketProcessWS_ProcessReturnVo():NEW()
	oClone:cticket              := ::cticket
	oClone:chash                := ::chash
	oClone:cstatus              := ::cstatus
	oClone:oWSprocessHeader     := IIF(::oWSprocessHeader = NIL , NIL , ::oWSprocessHeader:Clone() )
	oClone:cidWorkProcesso      := ::cidWorkProcesso
	oClone:oWSprovedores := NIL
	If ::oWSprovedores <> NIL 
		oClone:oWSprovedores := {}
		aEval( ::oWSprovedores , { |x| aadd( oClone:oWSprovedores , x:Clone() ) } )
	Endif 
	oClone:oWSvariaveisContexto := IIF(::oWSvariaveisContexto = NIL , NIL , ::oWSvariaveisContexto:Clone() )
	oClone:oWSlistQuiz := NIL
	If ::oWSlistQuiz <> NIL 
		oClone:oWSlistQuiz := {}
		aEval( ::oWSlistQuiz , { |x| aadd( oClone:oWSlistQuiz , x:Clone() ) } )
	Endif 
	oClone:oWSvariaveisInput := NIL
	If ::oWSvariaveisInput <> NIL 
		oClone:oWSvariaveisInput := {}
		aEval( ::oWSvariaveisInput , { |x| aadd( oClone:oWSvariaveisInput , x:Clone() ) } )
	Endif 
	oClone:oWSdataExtractor := NIL
	If ::oWSdataExtractor <> NIL 
		oClone:oWSdataExtractor := {}
		aEval( ::oWSdataExtractor , { |x| aadd( oClone:oWSdataExtractor , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_ProcessReturnVo
	Local oNode4
	Local nRElem6, oNodes6, nTElem6
	Local oNode7
	Local nRElem8, oNodes8, nTElem8
	Local nRElem9, oNodes9, nTElem9
	Local nRElem10, oNodes10, nTElem10
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cticket            :=  WSAdvValue( oResponse,"_TICKET","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::chash              :=  WSAdvValue( oResponse,"_HASH","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,"tns") 
	oNode4 :=  WSAdvValue( oResponse,"_PROCESSHEADER","ProcessHeaderVo",NIL,NIL,NIL,"O",NIL,"tns") 
	If oNode4 != NIL
		::oWSprocessHeader := RocketProcessWS_ProcessHeaderVo():New()
		::oWSprocessHeader:SoapRecv(oNode4)
	EndIf
	::cidWorkProcesso    :=  WSAdvValue( oResponse,"_IDWORKPROCESSO","string",NIL,NIL,NIL,"S",NIL,"tns") 
	oNodes6 :=  WSAdvValue( oResponse,"_PROVEDORES","provedor",{},NIL,.T.,"O",NIL,"tns") 
	nTElem6 := len(oNodes6)
	For nRElem6 := 1 to nTElem6 
		If !WSIsNilNode( oNodes6[nRElem6] )
			aadd(::oWSprovedores , RocketProcessWS_provedor():New() )
			::oWSprovedores[len(::oWSprovedores)]:SoapRecv(oNodes6[nRElem6])
		Endif
	Next
	oNode7 :=  WSAdvValue( oResponse,"_VARIAVEISCONTEXTO","variaveisContexto",NIL,NIL,NIL,"O",NIL,"tns") 
	If oNode7 != NIL
		::oWSvariaveisContexto := RocketProcessWS_variaveisContexto():New()
		::oWSvariaveisContexto:SoapRecv(oNode7)
	EndIf
	oNodes8 :=  WSAdvValue( oResponse,"_LISTQUIZ","listQuiz",{},NIL,.T.,"O",NIL,"tns") 
	nTElem8 := len(oNodes8)
	For nRElem8 := 1 to nTElem8 
		If !WSIsNilNode( oNodes8[nRElem8] )
			aadd(::oWSlistQuiz , RocketProcessWS_listQuiz():New() )
			::oWSlistQuiz[len(::oWSlistQuiz)]:SoapRecv(oNodes8[nRElem8])
		Endif
	Next
	oNodes9 :=  WSAdvValue( oResponse,"_VARIAVEISINPUT","variavel",{},NIL,.T.,"O",NIL,"tns") 
	nTElem9 := len(oNodes9)
	For nRElem9 := 1 to nTElem9 
		If !WSIsNilNode( oNodes9[nRElem9] )
			aadd(::oWSvariaveisInput , RocketProcessWS_variavel():New() )
			::oWSvariaveisInput[len(::oWSvariaveisInput)]:SoapRecv(oNodes9[nRElem9])
		Endif
	Next
	oNodes10 :=  WSAdvValue( oResponse,"_DATAEXTRACTOR","lista",{},NIL,.T.,"O",NIL,"tns") 
	nTElem10 := len(oNodes10)
	For nRElem10 := 1 to nTElem10 
		If !WSIsNilNode( oNodes10[nRElem10] )
			aadd(::oWSdataExtractor , RocketProcessWS_lista():New() )
			::oWSdataExtractor[len(::oWSdataExtractor)]:SoapRecv(oNodes10[nRElem10])
		Endif
	Next
Return

// WSDL Data Structure variavel

WSSTRUCT RocketProcessWS_variavel
	WSDATA   cidCampo                  AS string OPTIONAL
	WSDATA   cidOutput                 AS string OPTIONAL
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   cdesc                     AS string OPTIONAL
	WSDATA   ctipoCampo                AS string OPTIONAL
	WSDATA   cvalor                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_variavel
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_variavel
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_variavel
	Local oClone := RocketProcessWS_variavel():NEW()
	oClone:cidCampo             := ::cidCampo
	oClone:cidOutput            := ::cidOutput
	oClone:cnome                := ::cnome
	oClone:cdesc                := ::cdesc
	oClone:ctipoCampo           := ::ctipoCampo
	oClone:cvalor               := ::cvalor
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_variavel
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cidCampo           :=  WSAdvValue( oResponse,"_IDCAMPO","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cidOutput          :=  WSAdvValue( oResponse,"_IDOUTPUT","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cnome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cdesc              :=  WSAdvValue( oResponse,"_DESC","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ctipoCampo         :=  WSAdvValue( oResponse,"_TIPOCAMPO","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cvalor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure lista

WSSTRUCT RocketProcessWS_lista
	WSDATA   cchave                    AS string OPTIONAL
	WSDATA   cidArray                  AS string OPTIONAL
	WSDATA   cidListOutput             AS string OPTIONAL
	WSDATA   cdesc                     AS string OPTIONAL
	WSDATA   oWSregistros              AS RocketProcessWS_registro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_lista
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_lista
	::oWSregistros         := {} // Array Of  RocketProcessWS_REGISTRO():New()
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_lista
	Local oClone := RocketProcessWS_lista():NEW()
	oClone:cchave               := ::cchave
	oClone:cidArray             := ::cidArray
	oClone:cidListOutput        := ::cidListOutput
	oClone:cdesc                := ::cdesc
	oClone:oWSregistros := NIL
	If ::oWSregistros <> NIL 
		oClone:oWSregistros := {}
		aEval( ::oWSregistros , { |x| aadd( oClone:oWSregistros , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_lista
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cchave             :=  WSAdvValue( oResponse,"_CHAVE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cidArray           :=  WSAdvValue( oResponse,"_IDARRAY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cidListOutput      :=  WSAdvValue( oResponse,"_IDLISTOUTPUT","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cdesc              :=  WSAdvValue( oResponse,"_DESC","string",NIL,NIL,NIL,"S",NIL,"tns") 
	oNodes5 :=  WSAdvValue( oResponse,"_REGISTROS","registro",{},NIL,.T.,"O",NIL,"tns") 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSregistros , RocketProcessWS_registro():New() )
			::oWSregistros[len(::oWSregistros)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
Return

// WSDL Data Structure ProcessHeaderVo

WSSTRUCT RocketProcessWS_ProcessHeaderVo
	WSDATA   cempresa                  AS string OPTIONAL
	WSDATA   cusuario                  AS string OPTIONAL
	WSDATA   csenha                    AS string OPTIONAL
	WSDATA   chash                     AS string OPTIONAL
	WSDATA   cfluxo                    AS string OPTIONAL
	WSDATA   cticket                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_ProcessHeaderVo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_ProcessHeaderVo
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_ProcessHeaderVo
	Local oClone := RocketProcessWS_ProcessHeaderVo():NEW()
	oClone:cempresa             := ::cempresa
	oClone:cusuario             := ::cusuario
	oClone:csenha               := ::csenha
	oClone:chash                := ::chash
	oClone:cfluxo               := ::cfluxo
	oClone:cticket              := ::cticket
Return oClone

WSMETHOD SOAPSEND WSCLIENT RocketProcessWS_ProcessHeaderVo
	Local cSoap := ""
	cSoap += WSSoapValue("empresa", ::cempresa, ::cempresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("usuario", ::cusuario, ::cusuario , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("senha", ::csenha, ::csenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("hash", ::chash, ::chash , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("fluxo", ::cfluxo, ::cfluxo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ticket", ::cticket, ::cticket , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_ProcessHeaderVo
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cempresa           :=  WSAdvValue( oResponse,"_EMPRESA","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cusuario           :=  WSAdvValue( oResponse,"_USUARIO","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::csenha             :=  WSAdvValue( oResponse,"_SENHA","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::chash              :=  WSAdvValue( oResponse,"_HASH","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cfluxo             :=  WSAdvValue( oResponse,"_FLUXO","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cticket            :=  WSAdvValue( oResponse,"_TICKET","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure variaveisContexto

WSSTRUCT RocketProcessWS_variaveisContexto
	WSDATA   oWSvariavelContexto       AS RocketProcessWS_variavel OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_variaveisContexto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_variaveisContexto
	::oWSvariavelContexto  := {} // Array Of  RocketProcessWS_VARIAVEL():New()
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_variaveisContexto
	Local oClone := RocketProcessWS_variaveisContexto():NEW()
	oClone:oWSvariavelContexto := NIL
	If ::oWSvariavelContexto <> NIL 
		oClone:oWSvariavelContexto := {}
		aEval( ::oWSvariavelContexto , { |x| aadd( oClone:oWSvariavelContexto , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_variaveisContexto
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_VARIAVELCONTEXTO","variavel",{},NIL,.T.,"O",NIL,"tns") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSvariavelContexto , RocketProcessWS_variavel():New() )
			::oWSvariavelContexto[len(::oWSvariavelContexto)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure listQuiz

WSSTRUCT RocketProcessWS_listQuiz
	WSDATA   cdesc                     AS string OPTIONAL
	WSDATA   oWSlistaQuestionarios     AS RocketProcessWS_questionario OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_listQuiz
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_listQuiz
	::oWSlistaQuestionarios := {} // Array Of  RocketProcessWS_QUESTIONARIO():New()
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_listQuiz
	Local oClone := RocketProcessWS_listQuiz():NEW()
	oClone:cdesc                := ::cdesc
	oClone:oWSlistaQuestionarios := NIL
	If ::oWSlistaQuestionarios <> NIL 
		oClone:oWSlistaQuestionarios := {}
		aEval( ::oWSlistaQuestionarios , { |x| aadd( oClone:oWSlistaQuestionarios , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_listQuiz
	Local nRElem2, oNodes2, nTElem2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdesc              :=  WSAdvValue( oResponse,"_DESC","string",NIL,NIL,NIL,"S",NIL,"tns") 
	oNodes2 :=  WSAdvValue( oResponse,"_LISTAQUESTIONARIOS","questionario",{},NIL,.T.,"O",NIL,"tns") 
	nTElem2 := len(oNodes2)
	For nRElem2 := 1 to nTElem2 
		If !WSIsNilNode( oNodes2[nRElem2] )
			aadd(::oWSlistaQuestionarios , RocketProcessWS_questionario():New() )
			::oWSlistaQuestionarios[len(::oWSlistaQuestionarios)]:SoapRecv(oNodes2[nRElem2])
		Endif
	Next
Return

// WSDL Data Structure registro

WSSTRUCT RocketProcessWS_registro
	WSDATA   oWScolunas                AS RocketProcessWS_coluna OPTIONAL
	WSDATA   oWSprovedoresLoop         AS RocketProcessWS_provedorLoop OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_registro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_registro
	::oWScolunas           := {} // Array Of  RocketProcessWS_COLUNA():New()
	::oWSprovedoresLoop    := {} // Array Of  RocketProcessWS_PROVEDORLOOP():New()
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_registro
	Local oClone := RocketProcessWS_registro():NEW()
	oClone:oWScolunas := NIL
	If ::oWScolunas <> NIL 
		oClone:oWScolunas := {}
		aEval( ::oWScolunas , { |x| aadd( oClone:oWScolunas , x:Clone() ) } )
	Endif 
	oClone:oWSprovedoresLoop := NIL
	If ::oWSprovedoresLoop <> NIL 
		oClone:oWSprovedoresLoop := {}
		aEval( ::oWSprovedoresLoop , { |x| aadd( oClone:oWSprovedoresLoop , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_registro
	Local nRElem1, oNodes1, nTElem1
	Local nRElem2, oNodes2, nTElem2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_COLUNAS","coluna",{},NIL,.T.,"O",NIL,"tns") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWScolunas , RocketProcessWS_coluna():New() )
			::oWScolunas[len(::oWScolunas)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
	oNodes2 :=  WSAdvValue( oResponse,"_PROVEDORESLOOP","provedorLoop",{},NIL,.T.,"O",NIL,"tns") 
	nTElem2 := len(oNodes2)
	For nRElem2 := 1 to nTElem2 
		If !WSIsNilNode( oNodes2[nRElem2] )
			aadd(::oWSprovedoresLoop , RocketProcessWS_provedorLoop():New() )
			::oWSprovedoresLoop[len(::oWSprovedoresLoop)]:SoapRecv(oNodes2[nRElem2])
		Endif
	Next
Return

// WSDL Data Structure questionario

WSSTRUCT RocketProcessWS_questionario
	WSDATA   cidConfig                 AS string OPTIONAL
	WSDATA   cidRisco                  AS string OPTIONAL
	WSDATA   cdescRisco                AS string OPTIONAL
	WSDATA   oWSlistaPerguntas         AS RocketProcessWS_pergunta OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_questionario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_questionario
	::oWSlistaPerguntas    := {} // Array Of  RocketProcessWS_PERGUNTA():New()
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_questionario
	Local oClone := RocketProcessWS_questionario():NEW()
	oClone:cidConfig            := ::cidConfig
	oClone:cidRisco             := ::cidRisco
	oClone:cdescRisco           := ::cdescRisco
	oClone:oWSlistaPerguntas := NIL
	If ::oWSlistaPerguntas <> NIL 
		oClone:oWSlistaPerguntas := {}
		aEval( ::oWSlistaPerguntas , { |x| aadd( oClone:oWSlistaPerguntas , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_questionario
	Local nRElem4, oNodes4, nTElem4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cidConfig          :=  WSAdvValue( oResponse,"_IDCONFIG","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cidRisco           :=  WSAdvValue( oResponse,"_IDRISCO","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cdescRisco         :=  WSAdvValue( oResponse,"_DESCRISCO","string",NIL,NIL,NIL,"S",NIL,"tns") 
	oNodes4 :=  WSAdvValue( oResponse,"_LISTAPERGUNTAS","pergunta",{},NIL,.T.,"O",NIL,"tns") 
	nTElem4 := len(oNodes4)
	For nRElem4 := 1 to nTElem4 
		If !WSIsNilNode( oNodes4[nRElem4] )
			aadd(::oWSlistaPerguntas , RocketProcessWS_pergunta():New() )
			::oWSlistaPerguntas[len(::oWSlistaPerguntas)]:SoapRecv(oNodes4[nRElem4])
		Endif
	Next
Return

// WSDL Data Structure coluna

WSSTRUCT RocketProcessWS_coluna
	WSDATA   cchave                    AS string OPTIONAL
	WSDATA   cidCampo                  AS string OPTIONAL
	WSDATA   ctipoCampo                AS string OPTIONAL
	WSDATA   cdesc                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_coluna
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_coluna
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_coluna
	Local oClone := RocketProcessWS_coluna():NEW()
	oClone:cchave               := ::cchave
	oClone:cidCampo             := ::cidCampo
	oClone:ctipoCampo           := ::ctipoCampo
	oClone:cdesc                := ::cdesc
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_coluna
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cchave             :=  WSAdvValue( oResponse,"_CHAVE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cidCampo           :=  WSAdvValue( oResponse,"_IDCAMPO","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ctipoCampo         :=  WSAdvValue( oResponse,"_TIPOCAMPO","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cdesc              :=  WSAdvValue( oResponse,"_DESC","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure provedorLoop

WSSTRUCT RocketProcessWS_provedorLoop
	WSDATA   cidProvedor               AS string OPTIONAL
	WSDATA   cidOutput                 AS string OPTIONAL
	WSDATA   ckey                      AS string OPTIONAL
	WSDATA   cnome                     AS string OPTIONAL
	WSDATA   oWSvariaveisOut           AS RocketProcessWS_variavel OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_provedorLoop
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_provedorLoop
	::oWSvariaveisOut      := {} // Array Of  RocketProcessWS_VARIAVEL():New()
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_provedorLoop
	Local oClone := RocketProcessWS_provedorLoop():NEW()
	oClone:cidProvedor          := ::cidProvedor
	oClone:cidOutput            := ::cidOutput
	oClone:ckey                 := ::ckey
	oClone:cnome                := ::cnome
	oClone:oWSvariaveisOut := NIL
	If ::oWSvariaveisOut <> NIL 
		oClone:oWSvariaveisOut := {}
		aEval( ::oWSvariaveisOut , { |x| aadd( oClone:oWSvariaveisOut , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_provedorLoop
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cidProvedor        :=  WSAdvValue( oResponse,"_IDPROVEDOR","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cidOutput          :=  WSAdvValue( oResponse,"_IDOUTPUT","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ckey               :=  WSAdvValue( oResponse,"_KEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cnome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"tns") 
	oNodes5 :=  WSAdvValue( oResponse,"_VARIAVEISOUT","variavel",{},NIL,.T.,"O",NIL,"tns") 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSvariaveisOut , RocketProcessWS_variavel():New() )
			::oWSvariaveisOut[len(::oWSvariaveisOut)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
Return

// WSDL Data Structure pergunta

WSSTRUCT RocketProcessWS_pergunta
	WSDATA   cdescricao                AS string OPTIONAL
	WSDATA   cflagAcerto               AS string OPTIONAL
	WSDATA   cflagAcertoObrigatorio    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RocketProcessWS_pergunta
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RocketProcessWS_pergunta
Return

WSMETHOD CLONE WSCLIENT RocketProcessWS_pergunta
	Local oClone := RocketProcessWS_pergunta():NEW()
	oClone:cdescricao           := ::cdescricao
	oClone:cflagAcerto          := ::cflagAcerto
	oClone:cflagAcertoObrigatorio := ::cflagAcertoObrigatorio
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RocketProcessWS_pergunta
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cflagAcerto        :=  WSAdvValue( oResponse,"_FLAGACERTO","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cflagAcertoObrigatorio :=  WSAdvValue( oResponse,"_FLAGACERTOOBRIGATORIO","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return


