#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIATH001
@author Thiago Haagensen
@since 10/01/2020
@version 1.0
@description Ponto de entrada após a gravação dos dados na tabela SA5 - Amarração Produto X Fornecedor utilizado para manipular as informações após a gravação dos dados.
@type function
/*/

User Function BIATH001()
Local aArea := GetArea()
Local cSQL := ""
Local cQrySA5 := GetNextAlias()
Local cSA5 := RetSQLName("SA5")
Local cQryAIB := GetNextAlias()
Local cAIB := RetSQLName("AIB")
		
	If Inclui .Or. Altera

		cSQL := " SELECT A5_PRODUTO, A5_FORNECE, A5_LOJA, A5_CODTAB, A5_YPRECO, R_E_C_N_O_ AS RECNO "
		cSQL += " FROM " + cSA5
		cSQL += " WHERE A5_FILIAL = " + ValToSQL(xFilial("SA5"))
		cSQL += " AND A5_PRODUTO = " + ValToSQL(SA5->A5_PRODUTO)
		cSQL += " AND D_E_L_E_T_ = '' "
		
		TcQuery cSQL New Alias (cQrySA5)
		
		While !(cQrySA5)->(Eof())
	
			cSQL := " SELECT TOP 1 AIB_CODTAB, AIB_PRCCOM "
			cSQL += " FROM " + cAIB
			cSQL += " WHERE AIB_FILIAL = " + ValToSQL(xFilial("AIB"))
			cSQL += " AND AIB_CODFOR = " + ValToSQL((cQrySA5)->A5_FORNECE)
			cSQL += " AND AIB_LOJFOR = " + ValToSQL((cQrySA5)->A5_LOJA)
			cSQL += " AND AIB_CODPRO = " + ValToSQL((cQrySA5)->A5_PRODUTO)
			cSQL += " AND D_E_L_E_T_ = '' "
			cSQL += " ORDER BY AIB_DATVIG DESC "
				
			TcQuery cSQL New Alias (cQryAIB)
			
			If !Empty((cQryAIB)->AIB_CODTAB)
			
				If (cQryAIB)->AIB_CODTAB <> (cQrySA5)->A5_CODTAB .Or. (cQryAIB)->AIB_PRCCOM <> (cQrySA5)->A5_YPRECO
					dbSelectArea("SA5")
					dbSetOrder(1)
					If dbSeek(xFilial("SA5")+(cQrySA5)->A5_FORNECE+(cQrySA5)->A5_LOJA+(cQrySA5)->A5_PRODUTO)
						While (!SA5->(Eof()).And. ((cQrySA5)->A5_PRODUTO == SA5->A5_PRODUTO .And. (cQrySA5)->A5_FORNECE == SA5->A5_FORNECE .And. (cQrySA5)->A5_LOJA == SA5->A5_LOJA))
							RecLock("SA5",.F.)
							SA5->A5_CODTAB 	:= (cQryAIB)->AIB_CODTAB
							SA5->A5_YPRECO	:= (cQryAIB)->AIB_PRCCOM
							MsUnlock()
							
							dbSelectArea("SA5")
							SA5->(dbSkip())
						EndDo
					EndIf
					SA5->(dbCloseArea())									
				EndIf
			
			EndIf
			
			(cQryAIB)->(DbCloseArea())
	
			(cQrySA5)->(DbSkip())
			
		EndDo
	
		(cQrySA5)->(DbCloseArea())
		
	EndIf
			
	RestArea(aArea)

Return()
