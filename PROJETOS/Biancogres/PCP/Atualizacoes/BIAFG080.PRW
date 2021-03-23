#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*/{Protheus.doc} BIAFG080
@author Gabriel Rossi Mafioletti
@since 11/03/2019
@version 1.0
@description Alteração de linha de OP Primária
@type function
/*/

User Function BIAFG080()

	Local _cTpProd	:=	""
	Local _cAlias	:=	GetNextAlias()
	Local _aArea	:=	GetArea()
	Local _cLinNew	:=	""
	Local _cClVl	:=	""

	Local _cProdMae	:=	""
	Local _cLinMae	:=	""

	Local lBkpInc	:=	Nil
	Local lBkpAlt	:=	Nil

	Local xBkpMVPAR1	:=	MV_PAR01
	Local xBkpMVPAR2	:=	MV_PAR02

	Private _lIntMes	:=	.F.

	If SC2->C2_SEQUEN <> '001'
		MsgInfo("Somente será possivel alterar a linha de OP's principais!","BIAFG080")
		Return
	EndIf

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
		_cTpProd	:=	SB1->B1_TIPO
	EndIf

	If _cTpProd	== "PA"

		If !ValidPerg()
			MV_PAR01	:=	xBkpMVPAR1
			MV_PAR02	:=	xBkpMVPAR2
			RestArea(_aArea)
			Return
		EndIf

		msRoteiroLn := Substr(MV_PAR02, 2, 1) + IIf( Substr(MV_PAR02, 3, 1) == "A", "1", IIf(Substr(MV_PAR02, 3, 1) == "B", "2", "X") )

		U_BFG73CVM(MV_PAR02,SC2->C2_PRODUTO,@_cClvl,@_cLinNew)
		RecLock("SC2",.F.)
		SC2->C2_LINHA	:=	MV_PAR02
		SC2->C2_CLVL	:=	_cClVl
		If _lIntMes
			SC2->C2_ROTEIRO := msRoteiroLn
			SC2->C2_YITGMES := "S"
		EndIf
		SC2->(MsUnlock())

		_cProdMae	:=	SC2->C2_PRODUTO
		_cLinMae	:=	SC2->C2_LINHA

		If _lIntMes 

			If Type("INCLUI") == "L"
				lBkpInc := INCLUI
			EndIf
			If Type("ALTERA") == "L"
				lBkpAlt := ALTERA
			EndIf
			INCLUI	:=	.F.
			ALTERA	:=	.T.
			If PCPIntgPPI()
				lProcessa := mata650PPI(,,.T.,.T.,.F.)
			EndIf
			INCLUI	:=	lBkpInc
			ALTERA	:=	lBkpAlt

		EndIf

		BeginSql Alias _cAlias

			SELECT * 
			FROM %TABLE:SC2% SC2
			WHERE C2_FILIAL = %XFILIAL:SC2%
			AND C2_NUM = %Exp:SC2->C2_NUM%
			AND C2_SEQUEN <> '001'
			AND %NotDel%

		EndSql

		While (_calias)->(!EOF())

			_cClvl		:=	""
			_cLinNew	:=	""

			U_BFG73CVI((_cAlias)->C2_PRODUTO,_cProdMae,_cLinMae,@_cClVl,@_cLinNew)

			SC2->(DbGoTo((_cAlias)->R_E_C_N_O_))
			IF SC2->(!EOF())
				Reclock("SC2",.F.)
				SC2->C2_LINHA	:=	_cLinNew
				SC2->C2_CLVL	:=	_cClVl
				SC2->(MsUnlock())
			EndIf
			(_cAlias)->(DbSkip())

		EndDo

		(_cAlias)->(DbCloseArea())

	Else

		MsgInfo("Somente poderão ser alteradas OP's de produtos do tipo 'PA'!","BIAFG080")

	EndIf

	MV_PAR01	:=	xBkpMVPAR1
	MV_PAR02	:=	xBkpMVPAR2

	RestArea(_aArea)

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG080" + cEmpAnt
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	SC2->C2_LINHA
	MV_PAR02 := SPACE(3)

	aAdd( aPergs ,{1,"Linha Atual" 		  	,MV_PAR01 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Nova Linha" 		  	,MV_PAR02 ,""  ,"EXISTCPO('ZCO').And.U_BIAFG80V()",'ZCO'  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Troca de Linha de OP",,,,,,,,cLoad,.F.,.F.)

		lRet := .T.

	EndIf

Return lRet

User Function BIAFG80V()

	Local _lRet	:=	.T.

	If U_BFG73CVV(MV_PAR02,SC2->C2_PRODUTO,.T.) //Verifica se o produto da OP Mãe possui classe de valor na linha digitada
		If !fValidRot()
			_lRet	:=	.F.
		EndIf
	Else
		_lRet	:=	.F.
	EndIf

Return _lRet

Static Function fValidRot()

	Local msRetLinha  := MV_PAR02
	Local msRoteiroLn
	Local _aArea	:=	GetArea()
	Local _lret	:=	.T.
	Local _aLinhas
	Local oBItgMes	:=	TIntegracaoMES():New()

	oBItgMes:GetLinha()

	_aLinhas	:=	oBItgMes:aLinhas

	_lIntMes	:=	.F.

	IF MV_PAR01 == MV_PAR02
		If !MsgNOYES("A linha NOVA deverá ser diferente da linha ATUAL. Se o circunstância aqui for ajustar o ROTEIRO, confirme este processamento. Deseja prosseguir?", "BIAFG080")
			Return .F.
		EndIf
	EndIf

	If aScan(_aLinhas,{|x| Alltrim(x) == Alltrim(msRetLinha)}) > 0

		msRoteiroLn := Substr(msRetLinha, 2, 1) + IIf( Substr(msRetLinha, 3, 1) == "A", "1", IIf(Substr(msRetLinha, 3, 1) == "B", "2", "X") )

		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO))

			If SB1->B1_TIPO = "PA" .and. SB1->B1_YCLASSE == "1"

				SG2->(dbSetOrder(1))
				If !SG2->(dbSeek(xFilial("SG2") + SC2->C2_PRODUTO + msRoteiroLn ))
					MSGINFO("Não existe roteiro de operações cadastrado para este Produto / Linha. Favor procurar o departamento Industrial para maiores informações.","BIAFG080")
					_lRet		:=	.F.
				Else
					_lIntMes	:=	.T.
				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(_aArea)

Return _lRet
