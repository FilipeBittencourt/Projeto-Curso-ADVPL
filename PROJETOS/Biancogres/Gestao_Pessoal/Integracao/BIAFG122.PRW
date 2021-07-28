#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} BIAFG122
@description Rotina para Gerar Pré-Requisições de EPI
@author Gabriel Mafioletti
@since 23/04/2020
@version 1.0
@type Function
/*/

User Function BIAFG122(_aProds,_cMat,lWs)

	RpcSetType(3)
	RpcSetEnv('01','01')

	fProcessa(_aProds,_cMat,lWs)

	RpcClearEnv()

Return

Static Function fPRocessa(_aProds,_cMat,lWs)

	Local _cClvl	:=	fGetClVl(SUBSTR(_cMat,3))
	Local _nI
	Local _cErro	:=	""
	Local _cSql

	Default lWs	:=	.F.

	If Empty(_cClvl)
		oRespPrq:lOk	:=	.F.
		oRespPrq:cErro	:=	"Funcionário não Possui Classe de Valor Cadastrada"
		Return
	EndIf

	If Len(_aProds) == 0
		oRespPrq:lOk	:=	.F.
		oRespPrq:cErro	:=	"Não Existem Produtos para Serem geradas Pré-Requisições"
		Return	
	EndIf

	DbSelectArea("ZZY")
	ZZY->(DbSetOrder(3))
	If ZZY->(DbSeek(xFilial("ZZY")+_cMat))
		BEGIN TRANSACTION
			RecLock("SZI",.T.)
			SZI->ZI_FILIAL	:=	xFilial("SZI")
			SZI->ZI_DOC		:=	GetSxENum("SZI","ZI_DOC")
			SZI->ZI_TIPO	:=	'RE'
			SZI->ZI_EMISSAO	:=	Date()
			SZI->ZI_CLVL	:=	_cClvl
			SZI->ZI_CC		:=	U_B902BCC(SZI->ZI_CLVL)
			SZI->ZI_MATRIC	:=	_cMat
			SZI->ZI_NOME	:=	ZZY->ZZY_NOME
			SZI->ZI_BAIXA	:=	"N"
			SZI->ZI_EMPRESA	:=	"01"
			SZI->ZI_YLOCAL	:=	_aProds[1,3]
			SZI->ZI_INTSR	:=	"1"
			SZI->ZI_STTSREQ :=	"I"
			SZI->(MsUnlock())

			For _nI	:= 1 to Len(_aProds)

				Reclock("SZJ",.T.)
				SZJ->ZJ_FILIAL	:=	xFilial("SZJ")
				SZJ->ZJ_DOC		:=	SZI->ZI_DOC
				SZJ->ZJ_COD		:=	_aProds[_nI,1]
				SZJ->ZJ_DESCRI	:=	POSICIONE("SB1",1,xFilial("SB1")+PADR(_aProds[_nI,1],Tamsx3("B1_COD")[1]),"B1_DESC")
				SZJ->ZJ_LOCAL	:=	_aProds[_nI,3]
				SZJ->ZJ_UM		:=	POSICIONE("SB1",1,xFilial("SB1")+PADR(_aProds[_nI,1],Tamsx3("B1_COD")[1]),"B1_UM")
				SZJ->ZJ_QUANT	:=	_aProds[_nI,2]
				SZJ->ZJ_VLRTOT	:=	fRetCm(SZJ->ZJ_COD,SZJ->ZJ_LOCAL) * SZJ->ZJ_QUANT
				SZJ->ZJ_APLIC	:=	"4"
				SZJ->ZJ_YLOCALI	:=	Posicione("ZCN",2,xFilial("ZCN")+SZJ->ZJ_COD+SZJ->ZJ_LOCAL,"ZCN_LOCALI")
				SZJ->ZJ_EMPRESA	:=	"01"
				SZJ->ZJ_EMPDEST	:=	"01"
				SZJ->ZJ_CLVL	:=	SZI->ZI_CLVL
				SZJ->ZJ_YPARADA	:=	"N"
				SZJ->ZJ_QTAPROV	:=	SZJ->ZJ_QUANT
				SZJ->ZJ_YDRIVER	:=	U_BFG81DPD()
				SZJ->ZJ_YJTDRV	:=	"DRIVER PREENCHIDO ATRAVES DAS REQUISICAO AUTOMATIZADA"

				SZJ->(MsUnlock())				

				ZDC->(DbSetOrder(1))
				If ZDC->(DbSeek(xFilial("ZDC")+PADR(_aProds[_nI,1],TamSx3("ZDC_COD")[1])))
					_cErro	+=	"Produto: "+ Alltrim(SZJ->ZJ_COD)+ " é um Kit e não poderá ser requisitado!" + CRLF
				Else
					SB2->(DbSetOrder(1))
					If !SB2->(DbSeek(xFilial("SB2")+SZJ->ZJ_COD+SZJ->ZJ_LOCAL))
						CriaSb2(SZJ->ZJ_COD,SZJ->ZJ_LOCAL)
						_cErro	+=	"Produto: "+ Alltrim(SZJ->ZJ_COD)+ " - Estoque Insuficiente - Qtd. Req.: " + Alltrim(Str(SZJ->ZJ_QUANT)) + " - Qtd. Est.: " + Alltrim(Str(0)) + CRLF
					Else
						If SZJ->ZJ_QUANT > (SB2->B2_QATU - SB2->B2_RESERVA)
							_cErro	+=	"Produto: "+ Alltrim(SZJ->ZJ_COD)+ " - Estoque Insuficiente - Qtd. Req.: " + Alltrim(Str(SZJ->ZJ_QUANT)) + " - Qtd. Est.: " + Alltrim(Str(SB2->B2_QATU - SB2->B2_RESERVA)) + CRLF
						EndIf
					EndIf
				EndIf
				_cSql := "UPDATE "+RetSqlName("SB2")+" SET B2_RESERVA = B2_RESERVA + "+Alltrim(Str(SZJ->ZJ_QTAPROV))+" WHERE B2_COD = '"+SZJ->ZJ_COD+"' AND B2_LOCAL = '"+SZJ->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
				TcSQLExec(_cSql)

			Next
			
			If !Empty(_cErro)
				oRespPrq:lOk	:=	.F.
				oRespPrq:cErro	:=	_cErro
				DisarmTransaction()
				Return
			Else
				oRespPrq:lOk	:=	.T.
				oRespPrq:cErro	:=	""

				ConfirmSx8()				
			EndIf

		END TRANSACTION

	Else

		oRespPrq:lOk	:=	.F.
		oRespPrq:cErro	:=	"Matrícula Inexistente no Cadastro de Requisitantes!"
		Return

	EndIf

Return

Static Function fGetClVl(_cMat)

	Local _cClVl	:=	""
	Local _cAlias	:=	GetNextAlias()
	Local _nMat		:=	Val(_cMat)
	Local _cAliasSr	:=	"%" + U_fGetDbSr() + ".dbo.r034fun" + "%"

	BeginSql Alias _cAlias

		%NoParser%

		SELECT codccu RA_CLVL
		FROM %Exp:_cAliasSr% A
		WHERE numemp = 1
		AND tipcol = 1
		AND numcad = %Exp:_nMat%

	EndSql

	If (_cALias)->(!EOF())
		_cClvl	:=	Alltrim((_cAlias)->RA_CLVL)
	EndIF
	(_cAlias)->(DbCloseArea())

Return _cClVl

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
