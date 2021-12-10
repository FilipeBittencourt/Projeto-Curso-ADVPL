#Include 'Protheus.ch'
#Include 'Parmtype.ch'

User Function BANCO001()

	Local aArea := SB1->(GetArea())
	
	DbSelectArea("SB1") // SELECT * FROM SB1
	SB1->(DbSetOrder(1)) // order by pelo indice 1
	SB1->(DbGoTop()) // Seleciona o primeiro registro
	
	//posiciona produto
	IF (SB1->(DBSeek(FWXFilial("SB1")+"000002")))
		Alert(SB1->B1_DESC)
	ELSE
		MsgInfo("Naoo existe registro para esse codigo")
	ENDIF
	RestArea(aArea) //FECHA a CONEXAO

Return

