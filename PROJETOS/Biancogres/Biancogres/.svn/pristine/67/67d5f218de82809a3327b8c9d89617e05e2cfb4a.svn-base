#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Função: | MT060GRV																    			|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 30/07/15																			  |
|-----------------------------------------------------------|
| Desc.:	|	Ponto de entrada após a gravação dos dados    	|
|					|	na tabela SA5 - Amarração Produto X Fornecedor	|
|					|	utilizado para manipular as informações após a 	|
|					|	gravação dos dados.															|
|-----------------------------------------------------------|
| OS:			|	2859-15 - Usuário: Claudia Carvalho							|
|-----------------------------------------------------------|
*/

User Function MT060GRV()
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



// Atualizando Preços de Compra dos Produtos
User Function UpdSA5(lJob)
Default lJob := .T.
	
	If lJob
		fUpdateSA5()
	Else
		U_BIAMsgRun("Atualizando Preços de Compra dos Produtos...", "Aguarde!", {|| fUpdateSA5() })
	EndIf

Return()


Static Function fUpdateSA5()
Local aArea := GetArea()
Local cSQL := ""
Local cQrySA5 := GetNextAlias()
Local cSA5 := RetSQLName("SA5")
Local cQryAIB := GetNextAlias()
Local cAIB := RetSQLName("AIB")
Local cProduto := ""
		
	cSQL := " SELECT A5_PRODUTO, A5_FORNECE, A5_LOJA, A5_CODTAB, A5_YPRECO, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + cSA5
	cSQL += " WHERE A5_FILIAL = " + ValToSQL(xFilial("SA5"))
	//cSQL += " AND A5_PRODUTO = " + ValToSQL(SA5->A5_PRODUTO)
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQrySA5)
	
	While !(cQrySA5)->(Eof())

		cSQL := " SELECT TOP 1 AIB_CODTAB, AIB_PRCCOM "
		cSQL += " FROM " + cAIB
		cSQL += " WHERE AIB_FILIAL = "+ ValToSQL(xFilial("AIB"))
		cSQL += " AND AIB_CODFOR = " + ValToSQL((cQrySA5)->A5_FORNECE)
		cSQL += " AND AIB_LOJFOR = " + ValToSQL((cQrySA5)->A5_LOJA)
		cSQL += " AND AIB_CODPRO = " + ValToSQL((cQrySA5)->A5_PRODUTO)
		cSQL += " AND D_E_L_E_T_ = '' "
		cSQL += " ORDER BY AIB_DATVIG DESC "
			
		TcQuery cSQL New Alias (cQryAIB)
		
		If !Empty((cQryAIB)->AIB_CODTAB)
		
			If (cQryAIB)->AIB_CODTAB <> (cQrySA5)->A5_CODTAB .Or. (cQryAIB)->AIB_PRCCOM <> (cQrySA5)->A5_YPRECO
				
				cSQL :=	" UPDATE "+ cSA5
				cSQL += " SET A5_CODTAB = " + ValToSQL((cQryAIB)->AIB_CODTAB)
				cSQL += " ,A5_YPRECO = " + cValToChar((cQryAIB)->AIB_PRCCOM)
				cSQL += " WHERE A5_FILIAL = " + ValToSQL(xFilial("SA5"))
				cSQL += " AND R_E_C_N_O_ = "+ ValToSQL((cQrySA5)->RECNO)
				cSQL += " AND D_E_L_E_T_ = '' "
						
				TcSQLExec(cSQL)
								
			EndIf
		
		EndIf
		
		(cQryAIB)->(DbCloseArea())

		(cQrySA5)->(DbSkip())
		
	EndDo

	(cQrySA5)->(DbCloseArea())
				
	RestArea(aArea)

Return()