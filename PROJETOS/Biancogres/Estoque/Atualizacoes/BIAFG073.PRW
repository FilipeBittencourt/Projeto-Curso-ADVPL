#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFG073
@author Gabriel Mafioletti
@version 1.0
@description Funções para Validação Referentes à Linha x Armazém 
@type function
/*/

/*Valida Se o produto é produzido na Linha*/
User Function BFG73LIN(_cLinha,_cProd,_cLocal,_lTela)

	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()
	Local _lRet		:=	.F.

	Local _cFormae	:=	""

	Default _lTela	:=	.F.

	_cLocal	:=	"" //Sempre será em branco

	If Empty(_cProd)
		Return .T.
	EndIf	

	BeginSql Alias _cAlias

		SELECT TOP 1 ISNULL(ZCN_LOCAL,'') ZCN_LOCAL
		FROM %TABLE:ZCO% ZCO
		JOIN %TABLE:ZCN% ZCN
		ON ZCO.ZCO_SEQUEN = ZCN.ZCN_SEQUEN
		AND ZCN.ZCN_COD = %Exp:_cProd%
		WHERE ZCO_LINHA = %Exp:_cLinha%
		AND ZCO.%NotDel%
		AND ZCN.%NotDel%
	EndSql

	_cLocal	:=	(_cAlias)->ZCN_LOCAL

	If Empty(_cLocal)
		If _lTela
			MsgInfo("Não existe configuração de Linha para o produto: tabela ZCO e ZCN!", "BIAFG073(1)")
		EndIf
		_lRet	:=	.F.
	Else 
		_lRet	:=	.T.
	EndIf

	(_cALias)->(DbCloseArea())

	RestArea(_aArea)

Return _lRet

/*Retorna o Local do Produto x Linha*/
User Function BFG73LOC()

	Local _aArea	:=	GetArea()

	Local _cAlias	:=	GetNextAlias()
	Local _cLocal	:=	""

	Local _cLinha	:=	M->C2_LINHA
	Local _cProd	:=	M->C2_PRODUTO

	BeginSql Alias _cAlias

		SELECT TOP 1 ISNULL(ZCN_LOCAL,'') ZCN_LOCAL
		FROM %TABLE:ZCO% ZCO
		JOIN %TABLE:ZCN% ZCN
		ON ZCO.ZCO_SEQUEN = ZCN.ZCN_SEQUEN
		AND ZCN.ZCN_COD = %Exp:_cProd%
		WHERE ZCO_LINHA = %Exp:_cLinha%
		AND ZCO.%NotDel%
		AND ZCN.%NotDel%
	EndSql

	_cLocal	:=	(_cAlias)->ZCN_LOCAL

	(_cALias)->(DbCloseArea())

	RestArea(_aArea)

Return _cLocal

/*Busca Classe de Valor da OP Mãe*/
User Function BFG73CVM(_cLinha,_cProd,_cClvl,_cLinNew)

	Local _aArea	:=	GetArea()

	Local _cAlias	:=	GetNextAlias()
	Local _cClvl	:=	""
	Local _cLinNew	:=	""

	Local _cFormae	:=	""

	DbSelectArea("SB1")

	SB1->(DbSeek(xFilial("SB1")+_cProd))

	If  SB1->B1_TIPO	==	"PA"
		_cFormae	:=	SB1->B1_YFORMAT
	EndIf

	BeginSql Alias _cAlias

		SELECT TOP 1 ISNULL(ZCS_CLVL, '') ZCS_CLVL, ISNULL(ZCS_NEWLIN, '') ZCS_NEWLIN
		FROM %TABLE:ZCS% ZCS
		WHERE ZCS_FILIAL = %XFILIAL:ZCS%
		AND ZCS_LINMAE = %Exp:_cLinha%
		AND ZCS_TPPROD = %Exp:SB1->B1_TIPO%
		AND ZCS_FORMAE = %Exp:_cFormae%
		AND %NotDel%
	EndSql

	_cClvl	:=	(_cAlias)->ZCS_CLVL
	_cLinNew	:=	(_cAlias)->ZCS_NEWLIN

	(_cALias)->(DbCloseArea())

	RestArea(_aArea)

Return 

/*Busca Classe de Valor da OP Intermediária*/
User Function BFG73CVI(_cProd,_cProdMae,_cLinMae,_cClVl,_cLinNew)

	Local _aArea	:=	GetArea()

	Local _cAlias	:=	GetNextAlias()
	Local _cClvl	:=	""
	Local _cLinNew	:=	""

	Local _cFormae	:=	""
	Local _cTpProd	:=	""

	DbSelectArea("SB1")

	SB1->(DbSeek(xFilial("SB1")+_cProdMae))

	_cFormae	:=	SB1->B1_YFORMAT

	SB1->(DbSeek(xFilial("SB1")+_cProd))

	_cTpProd	:=	SB1->B1_TIPO

	BeginSql Alias _cAlias

		SELECT TOP 1 ISNULL(ZCS_CLVL, '') ZCS_CLVL, ISNULL(ZCS_NEWLIN, '') ZCS_NEWLIN
		FROM %TABLE:ZCS% ZCS
		WHERE ZCS_FILIAL = %XFILIAL:ZCS%
		AND ZCS_LINMAE = %Exp:_cLinMae%
		AND ZCS_TPPROD = %Exp:_cTpProd%
		AND ZCS_FORMAE = %Exp:_cFormae%
		AND %NotDel%
	EndSql

	_cClvl	:=	(_cAlias)->ZCS_CLVL
	_cLinNew	:=	(_cAlias)->ZCS_NEWLIN

	(_cALias)->(DbCloseArea())

	RestArea(_aArea)

Return 

/*Valida Se o produto x linha possui classe de valor*/
User Function BFG73CVV(_cLinha,_cProd,_lTela)

	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()
	Local _lRet		:=	.F.

	Local _cFormae	:=	""

	Default _lTela	:=	.F.

	If Empty(_cProd) .Or. (!IsInCallsTack("U_BIAFG080") .And. M->C2_SEQUEN <> '001')
		Return .T.
	EndIf	

	DbSelectArea("SB1")

	SB1->(DbSeek(xFilial("SB1")+_cProd))

	If  SB1->B1_TIPO	==	"PA"
		_cFormae	:=	SB1->B1_YFORMAT
	EndIf

	BeginSql Alias _cAlias

		SELECT TOP 1 ISNULL(ZCS_CLVL, '') ZCS_CLVL
		FROM %TABLE:ZCS% ZCS
		WHERE ZCS_FILIAL = %XFILIAL:ZCS%
		AND ZCS_LINMAE = %Exp:_cLinha%
		AND ZCS_TPPROD = %Exp:SB1->B1_TIPO%
		AND ZCS_FORMAE = %Exp:_cFormae%
		AND %NotDel%
	EndSql

	If Empty((_cAlias)->ZCS_CLVL)
		If _lTela
			MsgInfo("Não existe configuração de Classe de Valor para a Linha e o produto informados: tabela ZCS!", "BIAFG073(2)")
		EndIf
		_lRet	:=	.F.
	Else 
		_lRet	:=	.T.
	EndIf

	(_cALias)->(DbCloseArea())

	RestArea(_aArea)

Return _lRet
