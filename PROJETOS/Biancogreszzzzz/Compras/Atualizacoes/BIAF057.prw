#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF057
@author Tiago Rossini Coradini
@since 12/12/2016
@version 2.0
@description Atualização da tabela de preço de compras, associada a amarração de produto x fornecedor 
@obs OS: 2859-16 - Claudia Carvalho
@type function
/*/

User Function BIAF057(cCodPrd)
Local cSQL := ""
Local cQrySA5 := GetNextAlias()
Local cQryAIB := GetNextAlias()
Local _aArea	:= GetArea()

	cSQL := " SELECT A5_PRODUTO, A5_FORNECE, A5_LOJA, A5_CODTAB, A5_YPRECO, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("SA5")
	cSQL += " WHERE A5_FILIAL = " + ValToSQL(xFilial("SA5"))
	cSQL += " AND A5_PRODUTO = " + ValToSQL(cCodPrd)
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQrySA5)
	
	While !(cQrySA5)->(Eof())

		cSQL := " SELECT TOP 1 AIB_CODTAB, AIB_PRCCOM "
		cSQL += " FROM " + RetSQLName("AIB")
		cSQL += " WHERE AIB_FILIAL = " + ValToSQL(xFilial("AIB"))
		cSQL += " AND AIB_CODFOR = " + ValToSQL((cQrySA5)->A5_FORNECE)
		cSQL += " AND AIB_LOJFOR = " + ValToSQL((cQrySA5)->A5_LOJA)
		cSQL += " AND AIB_CODPRO = " + ValToSQL((cQrySA5)->A5_PRODUTO)
		cSQL += " AND D_E_L_E_T_ = '' "
		cSQL += " ORDER BY AIB_DATVIG DESC "
			
		TcQuery cSQL New Alias (cQryAIB)
		
		If !Empty((cQryAIB)->AIB_CODTAB)
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
		EndIf
		
		(cQryAIB)->(DbCloseArea())

		(cQrySA5)->(DbSkip())
		
	EndDo

	(cQrySA5)->(DbCloseArea())
	
	RestArea(_aArea)	
	
Return()