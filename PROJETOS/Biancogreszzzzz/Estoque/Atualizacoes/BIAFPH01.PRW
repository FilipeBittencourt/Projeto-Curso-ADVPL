#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TopConn.ch"

/*-------------------------------------------------------------------------------------------*/




WSSTRUCT TransIndEntrada

	WSDATA Produto		AS STRING //Produto
	WSDATA Quantidade	AS Float //Quantidade
	WSDATA Matricula	AS STRING //Matricula
	WSDATA Devolucao	AS STRING //Devolucao
	
ENDWSSTRUCT	


WSSTRUCT ReqIndEntrada

	WSDATA Produto		AS STRING //Produto
	WSDATA Quantidade	AS Float //Quantidade
	WSDATA ClasseValor	AS STRING //Classe Valor
	WSDATA CodigoTag	AS STRING //Tag
	WSDATA Matricula	AS STRING //Matricula
	
ENDWSSTRUCT	


WSSTRUCT Resposta

	WSDATA Status 		AS BOOLEAN//
	WSDATA Mensagem 	AS STRING //
	WSDATA LogMensagem 	AS STRING //
		
ENDWSSTRUCT	

WSSTRUCT TagsEntrada //
	WSDATA CodigoEmp	AS STRING //
ENDWSSTRUCT	

WSSTRUCT Tag //
	WSDATA Numero 		AS STRING //
	WSDATA ClasseValor 	AS STRING //
	WSDATA Descricao 	AS STRING //
ENDWSSTRUCT	

WSSTRUCT ProdutoEntrada
	WSDATA Codigo		AS STRING //Produto	
ENDWSSTRUCT	

WSSTRUCT ProdutoResposta //
	WSDATA Descricao	AS STRING //
	WSDATA Estoque		AS STRING
ENDWSSTRUCT	

WSSERVICE ControleEstoqueInd Description "<b>Web service para controle estoque de produtos retidos<b>" 

	WSDATA TransIndEntrada 	AS TransIndEntrada
	WSDATA ReqIndEntrada 	AS ReqIndEntrada
	WSDATA Resposta 		AS Resposta
	WSDATA TagsEntrada 		AS TagsEntrada
	WSDATA TagsResposta 	AS Array of Tag
	WSDATA ProdutoEntrada 	AS ProdutoEntrada
	WSDATA ProdutoResposta 	AS ProdutoResposta
	
	WSMETHOD Transferencia	Description "<b>Metodo responsável por realizar transferência industrial.</b>"
	WSMETHOD Requisicao		Description "<b>Metodo responsável por realizar requisição industrial.</b>"
	WSMETHOD Lista_Tags		Description "<b>Metodo responsável por listar as tags.</b>"
	WSMETHOD DadosProduto	Description "<b>Metodo responsável por pegar dados do produto.</b>"
	
ENDWSService

WSMETHOD DadosProduto WSRECEIVE ProdutoEntrada WSSend ProdutoResposta WSSERVICE ControleEstoqueInd
	
	Local cCod			:= ProdutoEntrada:Codigo
	Local cAliasTrab	:= Nil
	Local cQuery		:= ""
	Local _cAlias
	
	RpcSetType(3)
	WfPrepEnv("01", "01")
	
	cAliasTrab := GetNextAlias()
		
	cQuery	+=	"SELECT 								"
	cQuery	+=	" DESCRICAO	= B1_YREF					"
	cQuery	+=	" FROM "+RetSQLName("SB1")+" SB1		"
	cQuery	+=	" WHERE D_E_L_E_T_	= ''			AND	"	
	cQuery	+=	" B1_COD			LIKE '"+cCod+"'	AND	"	
	cQuery	+=	" B1_MSBLQL			<> '1'				"	
	
	TCQuery cQuery New Alias cAliasTrab
	
	ProdutoResposta:Descricao := ""
	
	If !cAliasTrab->(EoF())
		ProdutoResposta:Descricao := AllTrim(cAliasTrab->DESCRICAO)
	EndIf
	
	cAliasTrab->(DbCloseArea())
	
	_cAlias	:=	GetNextAlias()
	
	BeginSql Alias _cAlias
	
		SELECT *
		FROM %TABLE:SB2%
		WHERE B2_FILIAL = %XFILIAL:SB2%
			AND B2_COD = %Exp:cCod%
			AND B2_LOCAL IN ('01','07')
			AND %NotDel%
			AND B2_QATU-B2_RESERVA > 0
		ORDER BY B2_LOCAL
	
	EndSql
	
	ProdutoResposta:Estoque	:=	""
	
	If (_cAlias)->(!EOF())
	
		While (_cAlias)->(!EOF())
			ProdutoResposta:Estoque	+=	"Almox. " + (_cAlias)->B2_LOCAL + ': ' + Alltrim(TRANSFORM((_calias)->(B2_QATU-B2_RESERVA),"@E 999,999,999.9999")) 
			(_cALias)->(DbSkip())
			If (_cAlias)->(!Eof())
				ProdutoResposta:Estoque	+= " / "
			EndIf
		EndDo
	Else
		ProdutoResposta:Estoque	:=	"Sem Estoque"
	EndIf

	(_cAlias)->(DbCloseArea())	
	
	
	RpcClearEnv()
	
Return .T.

WSMETHOD Lista_Tags WSRECEIVE TagsEntrada WSSend TagsResposta WSSERVICE ControleEstoqueInd
	
	Local cCodEmp		:= TagsEntrada:CodigoEmp
	Local cCodFil		:= "01"
	
	Local cAliasTrab	:= Nil
	Local nI			:= 0
	Local cQuery		:= ""
	
	RpcSetType(3)
	WfPrepEnv(cCodEmp, cCodFil)
	
	cAliasTrab := GetNextAlias()
	
		
	cQuery	+=	"SELECT 								"
	cQuery	+=	" NUMERO	= ZC_NUM,					"
	cQuery	+=	" DESCRICAO	= ZC_DESC,					"
	cQuery	+=	" CLASSEVAL	= ZC_CLVL					"
	cQuery	+=	" FROM "+RetSQLName("SZC")+" SZC		"
	cQuery	+=	" WHERE D_E_L_E_T_	= ''		AND		"	
	cQuery	+=	" ZC_REQCOL		= 'S'			AND		"	
	cQuery	+=	" ZC_MSBLQL			<> '1'				"	
	
	TCQuery cQuery New Alias cAliasTrab
	
	nI	:= 1	
	While !cAliasTrab->(EoF())
		
		AAdd(::TagsResposta, WSClassNew("Tag"))
	    ::TagsResposta[nI]:Numero  		:= AllTrim(cAliasTrab->NUMERO)
	    ::TagsResposta[nI]:ClasseValor	:= AllTrim(cAliasTrab->CLASSEVAL)
	    ::TagsResposta[nI]:Descricao    := AllTrim(cAliasTrab->DESCRICAO)
		
		cAliasTrab->(DbSkip())
		nI++
	EndDo
	
	cAliasTrab->(DbCloseArea())
	
	RpcClearEnv()
	
Return .T.

WSMETHOD Transferencia WSRECEIVE TransIndEntrada WSSend Resposta WSSERVICE ControleEstoqueInd
	
	Local cProdOri		:= TransIndEntrada:Produto
	Local nQuantOri		:= TransIndEntrada:Quantidade
	Local cLocalOri		:= ""//almoxorifado transferencia origem
	Local cProdDest		:= cProdOri
	Local cLocalDes		:= ""//almoxorifado transferencia destino 
	Local cDocumento	:= ""	
	Local cItem			:= ""
	Local oItem			:= Nil
	Local lDevol		:=	TransIndEntrada:Devolucao == "1"
	
	RpcSetType(3)
	WfPrepEnv("01", "01")
	
	If lDevol
		cLocalOri		:= GETNEWPAR("MV_YATDETC", "07")
		cLocalDes		:= GETNEWPAR("MV_YATORIC", "01")
	Else
		cLocalOri		:= GETNEWPAR("MV_YATORIC", "01")
		cLocalDes		:= GETNEWPAR("MV_YATDETC", "07")
	EndIf
	
	oItem := TTransferenciaInterna():New(3, cDocumento, cItem, cProdOri, cLocalOri, nQuantOri, cProdDest, cLocalDes)
	oItem:Executar()
	
	Resposta:Status			:= oItem:lOk
	Resposta:Mensagem		:= oItem:cMensagem
	Resposta:LogMensagem	:= oItem:cLog
	
	
	RpcClearEnv()
	
Return .T.

WSMETHOD Requisicao WSRECEIVE ReqIndEntrada WSSend Resposta WSSERVICE ControleEstoqueInd
	
	Local cProd			:= ReqIndEntrada:Produto
	Local nQuant		:= ReqIndEntrada:Quantidade
	Local cClasseVr		:= ReqIndEntrada:ClasseValor
	Local cLocal		:= "" //almoxorifado requisicao destino 
	Local cTipoMov		:= "502"
	Local cTempo		:=	Time()
	Local dDataEmis		:= Nil
	Local nIdEco		:= 0 
	Local oItem			:= Nil
	Local cLocaliza		:= ""
	Local cOriMov		:= ""
	Local cTag			:= ReqIndEntrada:CodigoTag
	Local cAplica		:= "1"
	Local cMatric		:= ReqIndEntrada:Matricula
	
	Conout("ClasseVr: "+cClasseVr +", cTag: "+cTag+", Matric: "+cMatric)
	
	RpcSetType(3)
	WfPrepEnv("01", "01")
	
	cLocal		:= GETNEWPAR("MV_YARDETC", "07")
	
	dDataEmis		:= Iif(cTempo >= '00:00:00' .And. cTempo <= '05:59:59',DaySub(dDatabase,1),dDataBase)
	
	oItem := TMovimentacaoInterna():New(3, cProd, cLocal, nQuant, cClasseVr, cTipoMov, dDataEmis, nIdEco, cLocaliza, cOriMov, cTag, cAplica, cMatric)
	oItem:Executar()
	
	Resposta:Status			:= oItem:lOk
	Resposta:Mensagem		:= oItem:cMensagem
	Resposta:LogMensagem	:= oItem:cLog
	
	RpcClearEnv()
	
Return .T.


/*-------------------------------------------------------------------------------------------*/

User Function BIAFPH01()
	
	Local cProd			:= '2120499'
	Local nQuant		:= 1
	Local cClasseVr		:= "3136"
	Local cLocal		:= "01"
	Local cTipoMov		:= "502"
	Local dDataEmis		:= Nil
	Local nIdEco		:= 0 
	Local oItem			:= Nil
	Local cLocaliza		:= ""
	Local cOriMov		:= ""
	Local cTag			:= '1111'
	Local cAplica		:= "1"
	Local cMatric		:= '2222'
	
	RpcSetType(3)
	WfPrepEnv("01", "01")
	
	oItem := TMovimentacaoInterna():New(3, cProd, cLocal, nQuant, cClasseVr, cTipoMov, dDataEmis, nIdEco, cLocaliza,cOriMov, cTag, cAplica, cMatric)
	oItem:Executar()
	
	oItem:lOk
	oItem:cMensagem
	oItem:cLog
	
	
	RpcClearEnv()
	*/
	
	/*
	Local cProdOri		:= "2120499"
	Local nQuantOri		:= 100
	Local cLocalOri		:= "01"
	Local cProdDest		:= cProdOri
	Local cLocalDes		:= "07"
	Local cDocumento	:= ""	
	Local cItem			:= ""
	Local oItem			:= Nil
	
	RpcSetType(3)
	WfPrepEnv("01", "01")
	
	oItem := TTransferenciaInterna():New(3, cDocumento, cItem, cProdOri, cLocalOri, nQuantOri, cProdDest, cLocalDes)
	oItem:Executar()
	
	oItem:lOk
	oItem:cMensagem
	oItem:cLog
	
	RpcClearEnv()
	*/
	
Return 