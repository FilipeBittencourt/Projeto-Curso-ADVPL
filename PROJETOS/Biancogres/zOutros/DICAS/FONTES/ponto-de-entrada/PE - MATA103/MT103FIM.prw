#Include 'Protheus.ch'


//PE - MT103FIM - Operação após gravação da NFE
//https://tdn.totvs.com/pages/releaseview.action?pageId=6085406

User Function MT103FIM() 

    Local nOpcao    := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina 
    Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO
    // CUSTOMIZAÇÃO   
	EtBlqLib(nOpcao, nConfirma, SF1->F1_DOC) 

Return .T.



/*/{Protheus.doc} fEndRetorno
Função que controla o ZC2_MSBLQL conforme ação  na entrada da NF.
@author Filipe Facile
@since 18/10/2019
/*/
User Function EtBlqLib(nOpcao, nConfirma, cF1Doc)
	
	Local  cQuery := ""

	If nConfirma == 1

		cQuery += " SELECT  DISTINCT " 
		cQuery += "  SF1.F1_FILIAL " 
		cQuery += " ,SC7.C7_NUM " 
		cQuery += " ,SC7.C7_PRODUTO " 
		cQuery += " ,SC7.C7_OP " 
		cQuery += " ,SC7.C7_YOP " 
		cQuery += " ,SF1.F1_DOC	 " 

		cQuery += " FROM  SF1010 SF1 "
		
		cQuery += " INNER JOIN SD1010 SD1 ON SD1.D1_DOC = SF1.F1_DOC  "
		cQuery += " AND SD1.D1_FILIAL  = '01'  "
		cQuery += " AND SD1.D1_PEDIDO  = '115472'   "
		cQuery += " AND SD1.D_E_L_E_T_ = ''  "

		cQuery += " INNER JOIN SC7010 SC7 ON SD1.D1_PEDIDO = SC7.C7_NUM "
		cQuery += " AND SD1.D1_FILIAL  = '01' "
		cQuery += " AND SD1.D_E_L_E_T_ = '' "

		cQuery += " WHERE SF1.F1_FILIAL = '01' " 
		cQuery += " AND SF1.D_E_L_E_T_  = '' "
		cQuery += " AND SF1.F1_DOC    = '000029163' "
		cQuery += " AND SF1.F1_SERIE  = '1' "	

		TcQuery cQuery new alias "ZC2K" 

		DbSelectArea("ZC2")
		ZC2->(DbSetOrder(7))  // 7 - ZC2_FILIAL, ZC2_OP, R_E_C_N_O_, D_E_L_E_T_	
		ZC2K->(DBGotop())  
		While !ZC2K->(EOF()) 
						
			ZC2->(DbGoTOP())			
			
			If ZC2->(DbSeek(FWxFilial('SF1')+AllTrim(ZC2K->C7_YOP)))
				IF ZC2->ZC2_STATUS == "N" .AND. nOpcao == 3  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
					RecLock( "ZC2", .F.)							
						ZC2->ZC2_MSBLQL := '2' // LIBERAR
					ZC2->(msUnLock())
				ElseIf ZC2->ZC2_STATUS == "N" .AND. nOpcao == 5
					RecLock( "ZC2", .F.)							
						ZC2->ZC2_MSBLQL := '1' // BLOQUEAR
					ZC2->(msUnLock())
				Endif			
			Endif
			
			
			ZC2K->(dbSkip())
		EndDo  
		ZC2->(dbCloseArea())
		ZC2K->(dbCloseArea())		
		 
	EndIf

Return 