#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*/{Protheus.doc} BIAFG097
@author Gabriel Rossi Mafioletti
@since 24/06/2019
@version 1.0
@description Rotina para acerto de OP's X Roteiros
@type function
/*/
User Function BIAFG097()

fProc()

Return

Static Function fProc()

	Local _cAlias	:=	GetNextAlias()
	
	Local _cRoteiro	:=	""
	
	Local _aCabec	:=	{}
	Local _aDados	:=	{}
	
	aAdd(_aCabec,{"PRODUTO","C",15,0})
	aAdd(_aCabec,{"LINHA","C",3,0})
	aAdd(_aCabec,{"ROTEIRO_ANTERIOR","C",2,0})
	aAdd(_aCabec,{"NOVO_ROTEIRO","C",2,0})
	aAdd(_aCabec,{"OP","C",6,0})
	aAdd(_aCabec,{"OPERACAO","C",20,0})

	BeginSql Alias _cAlias
	
		SELECT SC2.*, SC2.R_E_C_N_O_ REC
		FROM %TABLE:SC2% SC2
		JOIN %TABLE:SB1% SB1 ON SC2.C2_PRODUTO = SB1.B1_COD
			AND SB1.B1_MSBLQL <> '1'
			AND SB1.B1_TIPO = 'PA'
			AND SB1.B1_YCLASSE = '1'
			AND SB1.%NotDel%
		WHERE SC2.C2_FILIAL = %XFILIAL:SC2%
			AND SC2.C2_SEQUEN = '001'
			AND SC2.C2_DATRF = ''
			AND SC2.C2_LINHA IN (
								SELECT ZCO_LINHA
								FROM %TABLE:ZCO% ZCO
								WHERE ZCO.ZCO_FILIAL = %xFILIAL:ZCO%
									AND ZCO.ZCO_ITGMES = '1'
									AND ZCO.%NotDel%
								)
			AND SC2.%NotDel%
	
	EndSql
	
	If (_cAlias)->(!EOF())

		While (_cAlias)->(!EOF())
			BEGIN TRANSACTION
				If (_cAlias)->C2_QUJE == 0
					_cRoteiro := Substr((_cAlias)->C2_LINHA, 2, 1) + IIf( Substr((_cAlias)->C2_LINHA, 3, 1) == "A", "1", IIf(Substr((_cAlias)->C2_LINHA, 3, 1) == "B", "2", "X") )
					SG2->(dbSetOrder(1))
					If !SG2->(dbSeek(xFilial("SG2") + (_cAlias)->C2_PRODUTO + _cRoteiro )) 
						If !Empty((_cAlias)->C2_ROTEIRO) .And. (_cAlias)->C2_YITGMES == "S"
							
							SC2->(DbGoTo((_cAlias)->REC))
							IF SC2->(!EOF())
								(_cAlias)->(aAdd(_aDados,{C2_PRODUTO,C2_LINHA,C2_ROTEIRO,"",C2_NUM,"CANCELAMENTO"}))
								
								Reclock("SC2",.F.)
									SC2->C2_ROTEIRO	:=	""
									SC2->C2_YITGMES :=	""
								SC2->(MsUnlock())
								
								
								fCancMes()
							EndIf
							
						EndIf
					ElseIf (_cAlias)->C2_YITGMES <> 'S' .And. Empty((_cAlias)->C2_ROTEIRO)  
			
						SC2->(DbGoTo((_cAlias)->REC))
						IF SC2->(!EOF())
							(_cAlias)->(aAdd(_aDados,{C2_PRODUTO,C2_LINHA,"",_cRoteiro,C2_NUM,"INTEGRADO"}))
						
							Reclock("SC2",.F.)
								SC2->C2_ROTEIRO	:= _cRoteiro
								SC2->C2_YITGMES	:=	"S"
							SC2->(MsUnlock())
						
							fIncMes()
						EndIf
						
					Else
						(_cAlias)->(aAdd(_aDados,{C2_PRODUTO,C2_LINHA,C2_ROTEIRO,C2_ROTEIRO,C2_NUM,"IGNORADO-ROTEIRO"}))
					EndIf
				Else
					(_cAlias)->(aAdd(_aDados,{C2_PRODUTO,C2_LINHA,C2_ROTEIRO,C2_ROTEIRO,C2_NUM,"IGNORADO-INICIADO"}))
				EndIf
			END TRANSACTION
			(_cAlias)->(DbSkip())
		EndDo
		If IsInCallStack("U_BIA736")
			U_BIAXEXCEL(_aDados,_aCabec)
		EndIf
	EndIf
Return


Static Function fCancMes()
	Local lBkpInc
	Local lBkpAlt
	Local cFuncaoAux

	cFuncaoAux := FunName()
	
	SetFunName("MATA650")
	
	If Type("INCLUI") == "L"
		lBkpInc := INCLUI
	EndIf
	If Type("ALTERA") == "L"
		lBkpAlt := ALTERA
	EndIf
	INCLUI	:=	.F.
	ALTERA	:=	.F.
	If PCPIntgPPI()
		lProcessa := mata650PPI(,,.T.,.T.,.T.)
	EndIf
	INCLUI	:=	lBkpInc
	ALTERA	:=	lBkpAlt
		
	SetFunName(cFuncaoAux)	

Return

Static Function fIncMes()

	Local lBkpInc
	Local lBkpAlt
	Local cFuncaoAux

	cFuncaoAux := FunName()
	
	SetFunName("MATA650")
	
	If Type("INCLUI") == "L"
		lBkpInc := INCLUI
	EndIf
	If Type("ALTERA") == "L"
		lBkpAlt := ALTERA
	EndIf
	INCLUI	:=	.F.
	ALTERA	:=	.T.
	If PCPIntgPPI()
		lProcessa :=	mata650PPI(,,.T.,.T.,.F.)
	EndIf
	INCLUI	:=	lBkpInc
	ALTERA	:=	lBkpAlt
		
	SetFunName(cFuncaoAux)	

Return
