#Include 'Protheus.ch'
/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ M410LIOK ¦ Autor ¦ Filipe     ¦ Data ¦ 17.07.2019          ¦¦¦
¦¦¦Descrição ¦Ponto de Entrada utilizado no Pedido de Venda               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function M410LIOK()
    
	Local lRet := .T.	
	IF M->C5_YTPOPER $ "29,31"
		FOR nI := 1 TO Len(aCols)
			If Empty(gdFieldGet("C6_YDETPED",nI))
				ALERT("A coluna 'Motivo Assis' no item "+cValToChar(nI)+" precisa ser preenchida, se a operação do pedido for de 'Assistência técnica'. ")
				lRet := .F.
			EndIf
		NEXT nI
	EndIf

Return lRet