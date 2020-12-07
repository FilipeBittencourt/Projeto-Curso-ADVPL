#Include "rwMake.ch"
#Include "Topconn.ch"
#Include "PROTHEUS.CH"

User Function BACP0007(_cNumPed)

	Local _lOk 			:= .T.
	Local cQuery		:= ""
	Public cContador	:= 0		
	Public cContAux		:= 0
	
	SetFunName("BACP0007")
	
	BEGIN TRANSACTION
		
		//limpa os bloqueios problemas na eliminação residuos
		cQuery := "UPDATE "+RetSqlName("SC6")+" SET 											"
		cQuery += " C6_BLQ 			= 'N',														"
		cQuery += " C6_BLOQUEI 		= '',														"
		cQuery += " C6_MSEXP 		= ''														"
		cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+ _cNumPed +"'  		"
		cQuery += " AND C6_BLQ <> 'R' AND D_E_L_E_T_ = '' 										"
		TcSQLExec(cQuery)	
		
		
		//Excluir empenho
		DbSelectArea("SC9")
		SC9->(DbSetOrder(1))
		
		SC9->(DbSeek(xFilial("SC9") + _cNumPed,.F.))
		
		While ( !SC9->(Eof()) .And. SC9->C9_PEDIDO == _cNumPed)
		
			If ( SC9->C9_BLCRED <> "10"  .And. SC9->C9_BLEST <> "10" .And. SC9->C9_BLCRED <> "ZZ"  .And. SC9->C9_BLEST <> "ZZ")
				SC9->(a460Estorna())
			EndIf
			
			SC9->(DbSkip())
			
		EndDo
		
		
		
		
		DbSelectArea('SC6')
		SC6->(DbSetOrder(1))
		SC6->(DbSeek(xFilial('SC6') + _cNumPed))
	  		
		While !SC6->(EOF()) .AND. SC6->C6_FILIAL == xFilial('SC6') .AND. SC6->C6_NUM == _cNumPed  
		 	
		 	//Excluir reserva
			U_FRRT02EX(SC6->C6_NUM, SC6->C6_ITEM, Nil, "EAT")
		 	
		 	
		 	If !(AllTrim(SC6->C6_BLQ) == "R") .And. (SC6->C6_QTDVEN - SC6->C6_QTDENT) > 0    
				_lOk := MaResDoFat(SC6->(RecNo()),.T.,.T.,0) 
	
				If _lOk
					
					RecLock("SC6",.F.)
					
						SC6->C6_YDTRESI := dDataBase
						SC6->C6_YMOTIVO := "218"
						SC6->C6_YOBSMOT := "Cancelamento por rotima automatica(Tela/Email)"
					
					SC6->(MsUnlock())
					
				EndIf
			
			EndIf
			
			If !_lOk
				exit
			EndIf
			
			SC6->(DbSkip()) 
		EndDo
		
		If !_lOk
			DisarmTransaction()
		EndIf

	END TRANSACTION

Return _lOk