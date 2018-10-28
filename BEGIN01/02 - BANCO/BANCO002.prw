#Include 'Protheus.ch'
#Include 'Parmtype.ch'

User Function BANCO002()

	Local aArea := SB1->(GetArea())
	Local cMsg  := ''
	
	DbSelectArea("SB1") // SELECT * FROM SB1
	SB1->(DbSetOrder(1)) // order by pelo indice 1
	SB1->(DbGoTop()) // Seleciona o primeiro registro
	
	//posiciona produto	 
	cMsg := Posicione('SB1',1,FWXFilial('SB1')+'000002','B1_DESC')//TABELA,BUSCA O INDICE,CAMPO QUE DESEJA EXIBIR	
	MsgInfo("Descricao produto: " +cMsg)
	
	RestArea(aArea) //FECHA a CONEXAO

Return

