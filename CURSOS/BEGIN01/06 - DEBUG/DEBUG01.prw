#Include 'Protheus.ch'
#Include 'Parmtype.ch'

User Function DEBUG01()	
	Local aArea := GetArea()	 
	Local aProduto := {}
	Local nCount := 0	
	DbSelectArea("SB1") //Seleciono a tabela de produtos
	SB1->(DbSetOrder(1)) //Seleciona o Indice
	SB1->(DbGoTop()) //Posiciona no primeiro registro
	
	//ALERT(FWXFilial(cAlias))	
	While ! SB1->(EoF()) // Enqunto não for final de arquivo
	
		AADD(aProduto,{SB1->B1_COD, SB1->B1_DESC}) //Adicionando registros no array aProduto
		nCount++
		SB1->(DbSkip()) // Pula para o proximo registro
	EndDo
	Alert("<b>Quantida de produtos cadastrados:</b> "+ cValToChar(nCount))
	nCount := 0
	
	RestArea(aArea)
Return

