#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} xBIAFG091
@author Gabriel Rossi Mafioletti
@since 27/05/2019
@version 1.0
@description Job para Integração das Pré-Requisições vindas do BIZAGI
@type function
/*/

User Function xBIAFG091()

	fProcessa('01','01')

	fProcessa('14','01')


RETURN

Static Function fProcessa(_cEmp,_cFil)
	Local _cAlias
	Local _aRet
	Local _cSql := ""
	Local _cRecnos	:=	""
	Local _nI
	Local _cPBIZA := ""

	Private _cErro	:=	""

	RpcSetType(3)
	RPCSetEnv(_cEmp, _cFil)

	_cAlias	:=	GetNextAlias()

	_cSql += "  SELECT "  + CRLF
	_cSql += "  ID " + CRLF
	_cSql += " ,CODIGO_PRODUTO AS  PRODUTO "  + CRLF
	_cSql += " ,QUANTIDADE AS QTD "  + CRLF
	_cSql += " ,LOCAL "  + CRLF
	_cSql += " ,CONTA "  + CRLF
	_cSql += " ,TAG "  + CRLF
	_cSql += " ,APLICACAO "  + CRLF
	_cSql += " ,MELHORIA "  + CRLF
	_cSql += " ,DRIVER "  + CRLF
	_cSql += " ,JUSTIFICATIVA_DRIVER as OBSDRIVE "  + CRLF
	_cSql += " ,PARADA "  + CRLF
	_cSql += " ,ISNULL(EMPRESA,'01') "  + CRLF
	_cSql += " ,DADOS_ENTRADA DADOS  "  + CRLF
	_cSql += " ,PROCESSO_BIZAGI PROCBIZ  "  + CRLF
	_cSql += " ,CLASSE_VALOR AS CLVLR  "  + CRLF
	_cSql += " ,MATRICULA AS  MATRIC  "  + CRLF
	_cSql += " ,TIPO  "  + CRLF
	_cSql += " ,CLIENTE_AI as CLIYSI"  + CRLF
	_cSql += " ,SUBITEM_PROJ AS YSUBITE"  + CRLF
	_cSql += " ,ITEM_CONTA AS ITEMCTA"  + CRLF

	_cSql += " FROM BZINTEGRACAO_PRE_REQUISICAO  "  + CRLF
	_cSql += " WHERE  STATUS = 'IB' "  + CRLF
	_cSql += "    AND DADOS_ENTRADA IS NOT NULL "  + CRLF
	_cSql += "    AND ISNULL(EMPRESA,'01') = '"+cEmpAnt+"'"  + CRLF

	_cSql += "  AND NOT EXISTS (SELECT 1  "  + CRLF
	_cSql	+= "  FROM " + RETSQLNAME("SZI") + " (NOLOCK) " +  CRLF
	_cSql += " 	WHERE ZI_YBIZAGI = PROCESSO_BIZAGI "  + CRLF
	_cSql += "  AND D_E_L_E_T_ = '' ) "  + CRLF

	_cSql += " ORDER BY  PROCBIZ"  + CRLF

	TcQuery _cSql New Alias (_cAlias)
	(_cAlias)->(DBGOTOP())
	While (_cAlias)->(!EOF())

		_cErro		:=	""
		_cRecnos	:=	""


		If Empty((_cAlias)->PRODUTO) .Or. Empty((_cAlias)->QTD)
			(_cAlias)->(DbSkip())
			Loop
		EndIF

		BEGIN TRANSACTION
			DbSelectArea("ZZY")
			DbSetOrder(3)
			DbSeek(xFilial("ZZY")+(_cAlias)->LOCAL)


			//Cabeçalho
			if AllTrim((_cAlias)->PROCBIZ) != AllTrim(_cPBIZA)

				_msDocSZI := GetNum()
				RecLock("SZI",.T.)
				SZI->ZI_FILIAL	:=	xFilial("SZI")
				SZI->ZI_DOC		  :=	_msDocSZI
				SZI->ZI_TIPO	  :=	(_cAlias)->TIPO
				SZI->ZI_EMISSAO	:=	Date()
				SZI->ZI_CLVL  	:=	 (_cAlias)->CLVLR
				SZI->ZI_CC		  :=	U_B902BCC(SZI->ZI_CLVL)
				SZI->ZI_MATRIC	:=	(_cAlias)->MATRIC
				SZI->ZI_NOME	  :=	ZZY->ZZY_NOME
				SZI->ZI_BAIXA	  :=	"N"
				SZI->ZI_EMPRESA	:=	cEmpAnt
				SZI->ZI_YLOCAL	:=	(_cAlias)->LOCAL
				SZI->ZI_YSI		  :=	(_cAlias)->CLIYSI
				SZI->ZI_ITEMCTA	:=	(_cAlias)->ITEMCTA
				SZI->ZI_YSUBITE	:=	(_cAlias)->YSUBITE

				If FIELDPOS("ZI_YBIZAGI") > 0
					SZI->ZI_YBIZAGI	:=	(_cAlias)->PROCBIZ
				EndIf

				SZI->(MsUnlock())

				_cRecnos	:=	"{SZI," + Alltrim(Str(SZI->(RECNO()))) + "};{SZJ"

			EndIf

			Reclock("SZJ",.T.)
			SZJ->ZJ_FILIAL	:=	xFilial("SZJ")
			SZJ->ZJ_DOC		  :=	_msDocSZI
			SZJ->ZJ_COD	   	:=	(_cAlias)->PRODUTO
			SZJ->ZJ_DESCRI	:=	POSICIONE("SB1",1,xFilial("SB1")+(_cAlias)->PRODUTO,"B1_DESC")
			SZJ->ZJ_LOCAL	  :=	(_cAlias)->LOCAL
			SZJ->ZJ_UM		  :=	POSICIONE("SB1",1,xFilial("SB1")+(_cAlias)->PRODUTO,"B1_UM")
			SZJ->ZJ_QUANT	  :=	(_cAlias)->QTD
			SZJ->ZJ_VLRTOT	:=	Iif(SZI->ZI_TIPO == "DU",0.01,fRetCm(SZJ->ZJ_COD,SZJ->ZJ_LOCAL) * SZJ->ZJ_QUANT)
			SZJ->ZJ_APLIC	  :=	Iif(Empty((_cAlias)->APLICACAO),'0',(_cAlias)->APLICACAO)
			SZJ->ZJ_TAG		  :=	(_cAlias)->TAG
			SZJ->ZJ_YLOCALI	:=	Posicione("ZCN",2,xFilial("ZCN")+SZJ->ZJ_COD+SZJ->ZJ_LOCAL,"ZCN_LOCALI")
			SZJ->ZJ_YMELHOR	:=	Iif((_cAlias)->MELHORIA == "000000", "", (_cAlias)->MELHORIA) //Verificar Melhoria
			SZJ->ZJ_EMPRESA	:=	cEmpAnt
			SZJ->ZJ_EMPDEST	:=	cEmpAnt
			SZJ->ZJ_CONTA 	:=	(_cAlias)->CONTA
			SZJ->ZJ_CLVL  	:=	SZI->ZI_CLVL
			SZJ->ZJ_YPARADA	:=	Iif(UPPER((_cAlias)->PARADA) == 'TRUE','S','N')
			SZJ->ZJ_QTAPROV	:=	SZJ->ZJ_QUANT
			SZJ->ZJ_YDRIVER	:=	Iif((_cAlias)->DRIVER == "-1","",(_cAlias)->DRIVER)
			SZJ->ZJ_YJTDRV	:=	(_cAlias)->OBSDRIVE


			If len(AllTrim((_cAlias)->MATRIC)) >= 11
				SZJ->ZJ_YMATORI :=  AllTrim((_cAlias)->MATRIC)
			EndIf

			SZJ->(MsUnlock())
			_cRecnos	+=	","+Alltrim(Str(SZJ->(Recno())))

			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(xFilial("SB2")+SZJ->ZJ_COD+SZJ->ZJ_LOCAL))
				CriaSb2(SZJ->ZJ_COD,SZJ->ZJ_LOCAL)
				If !(_cAlias)->TIPO  $ "DU_DN"
					_cErro	+=	"Produto: "+ Alltrim(SZJ->ZJ_COD)+ " - Estoque Insuficiente - Qtd. Req.: " + Alltrim(Str(SZJ->ZJ_QUANT)) + " - Qtd. Est.: " + Alltrim(Str(0)) + CRLF
				EndIf
			Else
				If !(_cAlias)->TIPO $ "DU_DN"
					If SZJ->ZJ_QUANT > (SB2->B2_QATU - SB2->B2_RESERVA)
						_cErro	+=	"Produto: "+ Alltrim(SZJ->ZJ_COD)+ " - Estoque Insuficiente - Qtd. Req.: " + Alltrim(Str(SZJ->ZJ_QUANT)) + " - Qtd. Est.: " + Alltrim(Str(SB2->B2_QATU - SB2->B2_RESERVA)) + CRLF
					EndIf
				EndIf
			EndIf

			If SZI->ZI_TIPO == 'RE'
				_cSql := "UPDATE "+RetSqlName("SB2")+" SET B2_RESERVA = B2_RESERVA + "+Alltrim(Str(SZJ->ZJ_QTAPROV))+" WHERE B2_COD = '"+SZJ->ZJ_COD+"' AND B2_LOCAL = '"+SZJ->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
				TcSQLExec(_cSql)
			EndIf


			_cRecnos	+= "}"

			If !Empty(_cErro)
				DisarmTransaction()
				_cSql	:=	"UPDATE BZINTEGRACAO_PRE_REQUISICAO SET STATUS = 'ER', DADOS_RETORNO = " + ValtoSql(_cErro) + " WHERE ID = " + CValTochar((_cAlias)->ID)
			Else
				//correção feita para evitar erro ocorrido no ticket 22716 - Rodrigo
				_cSql	:=	"UPDATE BZINTEGRACAO_PRE_REQUISICAO SET STATUS = 'AP', DADOS_RETORNO = " + ValtoSql(SZI->ZI_DOC) + ", DATA_INTEGRACAO_PROTHEUS = GetDate(), RECNO_RETORNO = " + ValtoSql(_cRecnos) + " WHERE ID = " + CValTochar((_cAlias)->ID)
			EndIf

			TcSqlExec(_cSql)

		END TRANSACTION

		_cPBIZA   := (_cAlias)->PROCBIZ
		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

	RpcClearEnv()
Return

Static Function fRetCm(_cCod,_cLocal)

	Local _nCm		:=	0
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		%NoParser%
		SELECT ISNULL(B2_CM1,0) B2_CM1
		FROM %TABLE:SB2% (NOLOCK)
		WHERE B2_FILIAL = %XFILIAL:SB2%
		AND B2_COD = %Exp:_cCod%
		AND B2_LOCAL = %Exp:_cLocal%
		AND %NotDel%
	EndSql

	_nCm	:=	(_cAlias)->B2_CM1

	(_cAlias)->(DbCloseArea())

Return _nCm

Static Function fValItens(_aItens)

	Local _lRet	:=	.T.
	Local _nI

	For _nI	:= 1 to Len(_aItens)

		If Len(_aItens[_nI]) < 10
			_lRet	:=	.F.
			Exit
		EndIf
	Next

Return _lRet

STATIC FUNCTION GetNum()

	Local _msDocSZI := ""

	_msDocSZI := GetSxENum("SZI","ZI_DOC")
	SZI->(dbSetOrder(1))
	If SZI->(dbSeek(xFilial("SZI") + _msDocSZI))
		While .T.
			_msDocSZI := GetSxENum("SZI","ZI_DOC")
			SZI->(dbSetOrder(1))
			If !SZI->(dbSeek(xFilial("SZI") + _msDocSZI))
				Exit
			EndIf
		End
	EndIf

Return _msDocSZI

