#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF056
@author Tiago Rossini Coradini
@since 13/12/2016
@version 3.0
@description Bloqueio de eliminação de residuo. 
@obs OS: 3843-16 - Ranisses Corona - Bloqueio de Faturamento na empresa LM, quando as quantidades entregues forem diferentes.
@obs OS: 4575-16 - Ranisses Corona - Bloqueio de Empenho.
@obs OS: 4576-16 - Ranisses Corona - Bloqueio de Empresa LM, liberação somente via ValOper.
@obs Ticket: 12252 - Marcus Vinicius Nascimento - Bloqueio para representantes 
@type function
/*/

User Function BIAF056(cNumPed, cPedOri, cCliPed, cCliOri, cLojOri, cItem)
Local lRet := .T.
	
	Default cItem := ""		
	If Empty(Alltrim(cRepAtu))	
		lRet := fVldQtdEmp(cNumPed, cItem) .And. fVldFatLM(cNumPed, cCliPed, cCliOri, cLojOri, cItem) .And. fVldEmp(cPedOri) //.And. fVldLibLM(cNumPed, cCliPed, cCliOri, cLojOri, cItem)    
	else
		lRet := .F.
		MsgStop("Eliminação de Resíduo não autorizada para representantes", "Bloqueio de Eliminação de Residuo")			
	EndIf	
Return(lRet)


// Valida quantidade empenhada
Static Function fVldQtdEmp(cNumPed, cItem)
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT C6_ITEM, C6_PRODUTO, C6_QTDEMP " 
	cSQL += " FROM "+ RetSQLName("SC5") +" SC5 "
	cSQL += " INNER JOIN "+ RetSQLName("SC6") +" SC6 "
	cSQL += " ON C5_FILIAL = C6_FILIAL "
	cSQL += " AND C5_NUM = C6_NUM "
	cSQL += " WHERE C5_FILIAL = "+ ValToSQL(xFilial("SC5"))
	cSQL += " AND C5_NUM = "+ ValToSQL(cNumPed)
	
	If !Empty(cItem)
		cSQL += " AND C6_ITEM = "+ ValToSQL(cItem)
	EndIf
	
	cSQL += " AND SC5.D_E_L_E_T_ = '' "
	cSQL += " AND SC6.D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof()) .And. lRet	
								
		If (cQry)->C6_QTDEMP > 0 
			
			lRet := .F.
			
			MsgStop("Eliminação de Resíduo não autorizada, o item: "+ (cQry)->C6_ITEM +" - "+ "produto: " + AllTrim((cQry)->C6_PRODUTO) +;
						 " está liberadado para faturamento.", "Bloqueio de Eliminação de Residuo")						
			
		EndIf
		
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())

Return(lRet)


// Valida empresa
Static Function fVldEmp(cPedOri)
Local lRet := .T.
	
	If cEmpAnt == "07" .And. !Empty(cPedOri) .And. !U_ValOper("039", .F.)
		
		lRet := .F.	
		
		MsgStop("Atenção, empresa não autorizada para eliminação de Resíduo.", "OP 039 - Bloqueio de Eliminação de Residuo")		

	EndIf
	
Return(lRet)


// Valida faturamento LM
Static Function fVldFatLM(cNumPed, cCliPed, cCliOri, cLojOri, cItem)
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	If cCliPed == "010064" .And. cEmpAnt $ '01_03_05_13_14'
		
		If !Empty(cCliOri) .And. !Empty(cLojOri)
		 
			cSQL := " SELECT C6_NUM, C6_ITEM, C6_PRODUTO, C6_QTDENT, " 
			cSQL += " ( "
			cSQL += " 	SELECT C6_QTDENT "
			cSQL += " 	FROM SC5070 SC5LM "
			cSQL += " 	INNER JOIN SC6070 SC6LM "
			cSQL += " 	ON C5_FILIAL = C6_FILIAL "
			cSQL += " 	AND C5_NUM = C6_NUM "
			cSQL += " 	WHERE C5_FILIAL = "+ ValToSQL(xFilial("SC5"))
			cSQL += " 	AND C5_YPEDORI = SC5.C5_NUM "
			cSQL += " 	AND C5_CLIENT = SC5.C5_YCLIORI "
			cSQL += " 	AND C5_LOJACLI = SC5.C5_YLOJORI "
			cSQL += " 	AND C6_ITEM = SC6.C6_ITEM "
			cSQL += " 	AND C6_PRODUTO = SC6.C6_PRODUTO "
			cSQL += " 	AND SC5LM.D_E_L_E_T_ = '' "
			cSQL += " 	AND SC6LM.D_E_L_E_T_ = '' "
			cSQL += " ) AS QTDENT_LM "
			cSQL += " FROM "+ RetSQLName("SC5") +" SC5 "
			cSQL += " INNER JOIN "+ RetSQLName("SC6") +" SC6 "
			cSQL += " ON C5_FILIAL = C6_FILIAL "
			cSQL += " AND C5_NUM = C6_NUM "
			cSQL += " WHERE C5_FILIAL = "+ ValToSQL(xFilial("SC5"))
			cSQL += " AND C5_NUM = "+ ValToSQL(cNumPed)
			cSQL += " AND C5_CLIENTE = '010064' "
			cSQL += " AND C5_YCLIORI = "+ ValToSQL(cCliOri)
			cSQL += " AND C5_YLOJORI = "+ ValToSQL(cLojOri)
			
			If !Empty(cItem)
				cSQL += " AND C6_ITEM = "+ ValToSQL(cItem)
			EndIf
			
			cSQL += " AND SC5.D_E_L_E_T_ = '' "
			cSQL += " AND SC6.D_E_L_E_T_ = '' "
			
			TcQuery cSQL New Alias (cQry)
			
			While !(cQry)->(Eof()) .And. lRet	
										
				If (cQry)->C6_QTDENT <> (cQry)->QTDENT_LM 
					
					lRet := .F.
					
					MsgStop("Eliminação de Resíduo não autorizada, o item: "+ (cQry)->C6_ITEM +" - "+ "produto: " + AllTrim((cQry)->C6_PRODUTO) +;
								 " ainda não foi faturado na empresa LM.", "Bloqueio de Eliminação de Residuo")										
					
				EndIf
				
				(cQry)->(DbSkip())
				
			EndDo()
			
			(cQry)->(DbCloseArea())				 	
	
		EndIf
		                 	
	EndIf

Return(lRet)

//Verifica o se o Pedido está Bloqueio de Descontos na LM
Static Function fVldLibLM(cNumPed, cCliPed, cCliOri, cLojOri, cItem)
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

If cCliPed == "010064" .And. cEmpAnt $ '01_03_05_13_14'
	
	If !Empty(cCliOri) .And. !Empty(cLojOri)
	 
	 	cSQL := " SELECT C5_NUM, C6_ITEM, C6_PRODUTO, C6_BLQ			" 
	    cSQL += " FROM SC5070 SC5LM INNER JOIN SC6070 SC6LM ON  		" 
		cSQL += "	C5_FILIAL = C6_FILIAL AND 							" 
		cSQL += "	C5_NUM    = C6_NUM 									" 
		cSQL += " WHERE SC5LM.C5_YPEDORI = '"+cNumPed+"'		 AND 	" 
		cSQL += "	  	SC5LM.C5_CLIENTE = '"+cCliOri+"' 		 AND	" 
		cSQL += "	  	SC5LM.C5_LOJACLI = '"+cLojOri+"' 		 AND	" 
		cSQL += "	  	SC6LM.C6_QTDVEN-SC6LM.C6_QTDENT > 0 	 AND	" 	
		cSQL += "	  	SC6LM.C6_BLQ	 <> 'R' 				 AND	" 	
		If !Empty(cItem)
			cSQL += "	  	SC6LM.C6_ITEM = "+ ValToSQL(cItem)+" AND	"
		EndIf
		cSQL += "	  	SC6LM.D_E_L_E_T_ = '' 					 AND	" 
		cSQL += " 		SC5LM.D_E_L_E_T_ = '' 							" 				
		TcQuery cSQL New Alias (cQry)			
		While !(cQry)->(Eof()) .And. lRet										
			If Alltrim((cQry)->C6_BLQ) == "S" 	
				lRet := .F.					
				MsgStop("Eliminação de Resíduo não autorizada, o item: "+ (cQry)->C6_ITEM +" - "+ "produto: " + AllTrim((cQry)->C6_PRODUTO) + " está com Bloqueio Comercial na empresa LM.", "Bloqueio de Eliminação de Residuo")
			EndIf				
			(cQry)->(DbSkip())				
		EndDo()			
		(cQry)->(DbCloseArea())				 	

			
	EndIf                   	
EndIf     

Return lRet
