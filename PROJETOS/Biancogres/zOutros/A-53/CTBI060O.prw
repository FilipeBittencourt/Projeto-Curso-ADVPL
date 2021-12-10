#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "CTBI060O.CH"

//dummy function
Function CTBI060O()
Return

/*/{Protheus.doc} ClassValue

API de integração de ClassValue

@author		Squad Control/CTB
@since		07/11/2018
/*/
WSRESTFUL ClassValue DESCRIPTION STR0001  //"Cadastro de Classe de Valor"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
	WSDATA InternalId		AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION STR0002 ; //"Carrega todos as Classes de Valor"
    WSSYNTAX "/api/ctb/v1/ClassValue/{Order, Page, PageSize, Fields}" ;
    PATH "/api/ctb/v1/ClassValue"

    WSMETHOD POST Main ;
    DESCRIPTION STR0003 ; //"Cadastra uma Nova Classe de Valor"
    WSSYNTAX "/api/ctb/v1/ClassValue/{Fields}" ;
    PATH "/api/ctb/v1/ClassValue"

	WSMETHOD GET InternalId ; //Filial+Code ;
    DESCRIPTION STR0004 ; //"Carrega Classe de Valor específica"
    WSSYNTAX "/api/ctb/v1/ClassValue/{InternalId}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/ctb/v1/ClassValue/{InternalId}"	

	WSMETHOD PUT InternalId ;
    DESCRIPTION  STR0005; //"Altera Classe de Valor específica"
    WSSYNTAX "/api/ctb/v1/ClassValue/{InternalId}/{Fields}" ;
    PATH "/api/ctb/v1/ClassValue/{InternalId}"	

	WSMETHOD DELETE InternalId ;
    DESCRIPTION STR0006 ; //"Deleta Classe de Valor específica"
    WSSYNTAX "/api/ctb/v1/ClassValue/{InternalId}" ;
    PATH "/api/ctb/v1/ClassValue/{InternalId}"		

ENDWSRESTFUL

/*/{Protheus.doc} GET /api/ctb/v1/ClassValue
Retorna todos as Classes de Valor

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE ClassValue

	Local cError			:= ""
	Local aFatherAlias		:= {"CTH", "items", "items"}
	Local cIndexKey			:= "CTH_FILIAL, CTH_CLVL"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIMANAGER():New("CTBS060","1.001") 	
	
	oApiManager:SetApiAdapter("CTBS060") 
	oApiManager:SetApiMap(ApiMap())
 	oApiManager:SetApiAlias(aFatherAlias)
	oApiManager:Activate()

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)
	
	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} POST /api/ctb/v1/ClassValue
Inclui uma nova Classe de Valor

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE ClassValue
	Local aQueryString	:= Self:aQueryString
	Local aFatherAlias		:= {"CTH", "items", "items"}
	Local cIndexKey			:= "CTH_FILIAL, CTH_CLVL"
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIMANAGER():New("CTBS060","1.001")

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CTH","items", "items"})

	lRet := ManutCV(oApiManager, Self:aQueryString, 3,,, cBody)

	If lRet
		aAdd(aQueryString,{"Code",CTH->CTH_CLVL})
		lRet := GetMain(@oApiManager, aQueryString, aFatherAlias,.F.,cIndexKey)
	EndIf

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    FreeObj( oJsonPositions )
	FreeObj( aQueryString )	

Return lRet

/*/{Protheus.doc} GET /api/ctb/v1/ClassValue/{InternalId}
Retorna uma Classe de Valor específica

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/
WSMETHOD GET InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code  WSSERVICE ClassValue

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
    Local aFatherAlias		:= {"CTH", "items", "items"}
	Local cIndexKey			:= "CTH_FILIAL, CTH_CLVL"
	Local oApiManager		:= FWAPIMANAGER():New("CTBS060","1.001")
	Local nLenFil			:= TamSX3("CTH_FILIAL")[1]
	local nLenCV			:= TamSX3("CTH_CLVL")[1]
	Local cFilAux			:= ""
	Local cCVAux			:= ""
	
	Default Self:InternalId:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cCVAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenCV),nLenCV)
	
	oApiManager:SetApiMap(ApiMap()) 
    Self:SetContentType("application/json")

	If Len(cFilAux) >= nLenFil .And. Len(cCVAux) >= nLenCV
		Aadd(aFilter, {"CTH", "items",{"CTH_CLVL  = '"+ cCVAux + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, .F., cIndexKey)
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0007, STR0008+cValToChar(nLenFil+nLenCV)+"caracteres",/*cHelpUrl*/,/*aDetails*/) //"Erro buscar o Classe de Valor!" //"A Classe de Valor deve possuir pelo menos"
	EndIf

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} PUT /api/ctb/v1/ClassValue/{InternalId}
Altera uma classe de valor específica

@param	Code				, caracter, Código 
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/

WSMETHOD PUT InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code WSSERVICE ClassValue

	Local aFilter		:= {}
	Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager	:= FWAPIMANAGER():New("CTBS060","1.001")
	Local cBody 	   	:= Self:GetContent()	
	Local nLenFields	:= TamSX3("CTH_FILIAL")[1] + TamSX3("CTH_CLVL")[1]
	Local nLenFil		:= TamSX3("CTH_FILIAL")[1]
	local nLenCV		:= TamSX3("CTH_CLVL")[1]
	Local cFilAux		:= ""
	Local cCVAux		:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cCVAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenCV),nLenCV)
	
	Self:SetContentType("application/json")

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"CTH","items", "items"})

	If  Len(cFilAux) >= nLenFil .And. Len(cCVAux) >= nLenCV
		If CTH->(Dbseek(cFilAux+cCVAux))
			lRet := ManutCV(@oApiManager, Self:aQueryString, 4,, self:InternalId, cBody)
		Else 
			lRet := .F.
			oApiManager:SetJsonError("404",STR0010, STR0009,/*cHelpUrl*/,/*aDetails*/) //"Classe de Valor não encontrada." //"Erro ao alterar a Classe de VAlor!"
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0012, STR0011 + cValToChar(nLenFields)+"caracteres",/*cHelpUrl*/,/*aDetails*/) //"A Classe de Valor deve possuir pelo menos " //"Erro ao alterar a Classe de Valor!"
	EndIf

	If lRet
		Aadd(aFilter, {"CTH", "items",{"CTH_CLVL = '" + CTH->CTH_CLVL + "'"}})
		oApiManager:SetApiFilter(aFilter) 		
		GetMain(@oApiManager, Self:aQueryString)
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} Delete /api/ctb/v1/ClassValue/{InternalId}
Deleta um proscpect específico

@param	Code				, caracter, Código 
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/

WSMETHOD DELETE InternalId PATHPARAM InternalId WSRECEIVE Order, Page, PageSize, Fields, Code WSSERVICE ClassValue

	Local cResp			:= STR0013 //"Registro Deletado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIMANAGER():New("CTBI060O","1.001")
	Local cBody			:= Self:GetContent()
	Local nLenFields	:= TamSX3("CTH_FILIAL")[1] + TamSX3("CTH_CLVL")[1]
	Local nLenFil		:= TamSX3("CTH_FILIAL")[1]
	local nLenCV		:= TamSX3("CTH_CLVL")[1]
	Local cFilAux		:= ""
	Local cCVAux		:= ""

	cFilAux := Left(self:InternalId,nLenFil)
	cCVAux  := PADR(SubStr(self:InternalId,nLenFil+1,nLenCV),nLenCV)
	
	Self:SetContentType("application/json")
	
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	If Len(cFilAux) >= nLenFil .And. Len(cCVAux) >= nLenCV
		If CTH->(Dbseek(cFilAux+cCVAux))
			lRet := ManutCV(@oApiManager, Self:aQueryString, 5,, self:InternalId, cBody)
		Else
			lRet := .F.
			oApiManager:SetJsonError("404",STR0015, STR0014,/*cHelpUrl*/,/*aDetails*/) //"Classe de valor não encontrada." //"Erro ao deletar a Classe de Valor!"
		EndIf
	Else
		lRet := .F.
		oApiManager:SetJsonError("400",STR0015, STR0008 + cValToChar(nLenFields) + "caracteres",/*cHelpUrl*/,/*aDetails*/) //"Erro ao deletar a Classe de Valor!" //"A Classe de Valor deve possuir pelo menos"
	EndIf

	If lRet
		oJsonPositions['response'] := cResp
		cResp := EncodeUtf8(FwJsonSerialize( oJsonPositions, .T. ))
		Self:SetResponse( cResp )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    FreeObj( oJsonPositions )

Return lRet

/*/{Protheus.doc} ManutCV
Realiza a manutenção (inclusão/alteração/exclusão) da Classe de Valor

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com Código 
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, Lógico	, Retorna se realizou ou não o processo

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/
Static Function ManutCV(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
	Local aCab				:= {}
	Local cError			:= ""
	Local cClasse			:= ""
	Local cResp				:= ""
    Local lRet				:= .T.
	Local nPosCod			:= 0
	Local nX				:= 0
    Local oJsonPositions	:= JsonObject():New()
	Local oModel			:= Nil

	Default aJson			:= {}
	Default cChave 			:= ""

	Private lAutoErrNoFile	:= .T.
	Private lMsErroAuto 	:= .F.

	If nOpc != 5
		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCab)
		EndIf
	EndIf

	If !Empty(cChave)
		cClasse 	:= SubStr(cChave, TamSX3("CTH_FILIAL")[1] + 1, TamSX3("CTH_CLVL")[1] )
	EndIf

	nPosCod	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "CTH_CLVL"}))

	If nOpc == 4 .Or. nOpc == 5
		If nPosCod == 0
			aAdd( aCab, {'CTH_CLVL' ,cClasse, Nil})
		Else
			aCab[nPosCod][2]  := cClasse
		EndIf
	EndIf

	If lRet
		MSExecAuto({|x, y| CTBA060(x, y)},aCab, nOpc)
		If lMsErroAuto	
			lRet := .F.
			aMsgErro:= GetAutoGRLog()
			cResp	 := ""
			For nX := 1 To Len(aMsgErro)
				If ValType(aMsgErro[nX]) == "C"
					cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
				EndIf
			Next nX	
			oApiManager:SetJsonError("400",STR0016, cResp,/*cHelpUrl*/,/*aDetails*/) //"Erro durante Inclusão/Alteração/Exclusão da Classe de Valor"
		Else	
			CTH->(DbSeek(xFilial("CTH") + CTH->CTH_CLVL))
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get da Classe de Valor

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Control/CTB
@since		07/11/2018
@version	12.1.23
/*/

Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 				:= .T.

	Default oApiManager		:= Nil	
	Default aQueryString	:={,}
	Default lHasNext		:= .T.
	Default cIndexKey		:= ""

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet

/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Contol/CTB
@since		07/11/2018
@version	12.1.23
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrCTH		:= {}

	aStrCTH			:=	{"CTH","Fields","items","items",;
							{;
								{"CompanyId"					, "Exp:cEmpAnt"									},;
								{"BranchId"						, "CTH_FILIAL"									},;
								{"CompanyInternalId"			, "Exp:cEmpAnt, CTH_FILIAL, CTH_CLVL"			},;								
								{"Code"							, "CTH_CLVL"									},;
								{"InternalId"					, "CTH_FILIAL, CTH_CLVL"						},;
								{"RegisterSituation"			, "CTH_BLOQ"									},;
								{"Name"							, "CTH_DESC01"									},;
								{"ShortCode"					, "CTH_RES"										},;
								{"Class"						, "CTH_CLASSE"									},;
								{"TopCode"						, "CTH_CLSUP"									};
							},;
						}

	aStructAlias  := {aStrCTH}

	aApiMap := {"CTBS060","items","1.001","CTBI060O",aStructAlias, "items"}

Return aApiMap
