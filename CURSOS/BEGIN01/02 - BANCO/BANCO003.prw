#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TopConn.ch' //permite executar codigos no fonte

User Function BANCO003()

	Local aArea  := SB1->(GetArea())
	Local cQuery := ''
	Local aDados := {}
	
	cQuery := " SELECT "
	cQuery += " B1_COD AS CODIGO, "
	cQuery += " B1_DESC AS DESCRICAO "
	cQuery += " FROM "
	//para quando não for de uma empresa especifica -- RetSQLName("SB1")
	cQuery += " "+RetSQLName("SB1")+ "SB1"
	cQuery += " WHERE  B1_MSBLQL != '1' "
	
	//executando a query
	TCQuery cQuery New Alias "TMPSQL"	
	
	//Add dados no array aDados o retorno 
	While TMPSQL->(EoF())
		AADD(aDados,TMPSQL->CODIGO)
		AADD(aDados,TMPSQL->DESCRICAO)
		TMPSQL->(DbSkip()) //pula para o proximo resgistro
	EndDo
	Alert(Len(aDados))
	
	//Vizualiza os dados no ARRAY aDados
	For nI := 1 To Len(aDados)
		MsgInfo(aDados[nI])
	Next nI 
	
	
	TMPSQL->(DbCloseArea()) //FECHA a CONEXAO  da query em questão
	RestArea(aArea) //Liberar a tabela
 
	
Return

