#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Função: | F70GRSE1																		    |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 13/05/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Ponto de entrada após a baixa a receber 				|
|					| Recebe como parâmetro o código da ocorrência,   |
|					| caso seja uma baixa proveniente do CNAB. 			 	|
|-----------------------------------------------------------|
| OS:			|	1307-15 e 1308-15 - Usuário: Vagner Salles			|
|-----------------------------------------------------------|
*/

User Function F70GRSE1()

	// Tiago Rossini Coradini -- FACILE -- OS: 0035-13
	// Atualiza movimento bancario - Baixa a receber com desconto
	fAtuMovBan()
	
Return()


Static Function fAtuMovBan()

	Local cSQL := ""
	Local cSE5 := RetSQLName("SE5")
	
	/*
	If cEmpAnt $ "01/05"
	
		If AllTrim(SE5->E5_NATUREZ) == "1121" .And. SE5->E5_VLDESCO > 0
		
			cSQL := " UPDATE "+ cSE5 
			cSQL += " SET E5_YSI = "+ ValToSQL(SE1->E1_CLIENTE) +"," 
			cSQL += " E5_CLVLDB = "+ ValToSQL(If (cEmpAnt == "01", "2100", '2200')) +"," 
			cSQL += " E5_ITEMD = 'I0202' "
			cSQL += " WHERE E5_FILIAL = "+ ValToSQL(SE5->E5_FILIAL)
			cSQL += " AND E5_TIPODOC = 'DC' "
			cSQL += " AND E5_PREFIXO = "+ ValToSQL(SE5->E5_PREFIXO)
			cSQL += " AND E5_NUMERO = "+ ValToSQL(SE5->E5_NUMERO)
			cSQL += " AND E5_PARCELA = "+ ValToSQL(SE5->E5_PARCELA)
			cSQL += " AND E5_TIPO = "+ ValToSQL(SE5->E5_TIPO)
			cSQL += " AND E5_DATA = "+ ValToSQL(SE5->E5_DATA)
			cSQL += " AND E5_CLIFOR = "+ ValToSQL(SE5->E5_CLIFOR)
			cSQL += " AND E5_LOJA = "+ ValToSQL(SE5->E5_LOJA)
			cSQL += " AND E5_RECPAG = "+ ValToSQL(SE5->E5_RECPAG)
			cSQL += " AND E5_VALOR = "+ ValToSQL(SE5->E5_VLDESCO)
			cSQL += " AND D_E_L_E_T_ = '' "
			
			TcSQLExec(cSQL)
				
		EndIf
		
	EndIf		
	*/
	
	If SE5->E5_VLDESCO > 0
		
		cSQL := " UPDATE "+ cSE5
		cSQL += " SET 	E5_ITEMD   = " + If(Type("__F70TITITEMD")  <> "U", ValToSQL(__F70TITITEMD) , "E5_ITEMD") + ","
		cSQL += " 		E5_YCTRVER = " + If(Type("__F70TITCTRVER") <> "U", ValToSQL(__F70TITCTRVER), "E5_YCTRVER") + ","
		cSQL += " 		E5_DEBITO  = " + If(Type("__F70TITDEBITO") <> "U", ValToSQL(__F70TITDEBITO), "E5_DEBITO") + ","
		cSQL += " 		E5_CCD	   = " + If(Type("__F70TITCCD")    <> "U", ValToSQL(__F70TITCCD)   , "E5_CCD") + ","
		cSQL += " 		E5_CLVLDB  = " + If(Type("__F70TITCLVLDB") <> "U", ValToSQL(__F70TITCLVLDB), "E5_CLVLDB")
		cSQL += " WHERE E5_FILIAL = "+ ValToSQL(SE5->E5_FILIAL)
		//cSQL += " AND E5_TIPODOC = 'DC' "
		cSQL += " AND E5_PREFIXO = "+ ValToSQL(SE5->E5_PREFIXO)
		cSQL += " AND E5_NUMERO = "+ ValToSQL(SE5->E5_NUMERO)
		cSQL += " AND E5_PARCELA = "+ ValToSQL(SE5->E5_PARCELA)
		cSQL += " AND E5_TIPO = "+ ValToSQL(SE5->E5_TIPO)
		cSQL += " AND E5_DATA = "+ ValToSQL(SE5->E5_DATA)
		cSQL += " AND E5_CLIFOR = "+ ValToSQL(SE5->E5_CLIFOR)
		cSQL += " AND E5_LOJA = "+ ValToSQL(SE5->E5_LOJA)
		cSQL += " AND E5_RECPAG = "+ ValToSQL(SE5->E5_RECPAG)
		//cSQL += " AND E5_VALOR = "+ ValToSQL(SE5->E5_VLDESCO)
		cSQL += " AND D_E_L_E_T_ = '' "
			
		TcSQLExec(cSQL)
				
	EndIf
	
Return()