#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF066
@author Tiago Rossini Coradini
@since 13/03/2017
@version 1.0
@description Adiciona filtro SQL na montagem da fatura a receber 
@obs OS: 4031-15 - Clebes Jose
@obs OS: 0089-17 - Clebes Jose
@type function
/*/

User Function BIAF066()
Local aArea := GetArea()
Local cRet := ""
Private oParam := TParBIAF066():New()
Private cNumFat := ""
	
	cRet := " E1_NATUREZ = "+ ValToSQL(cNat)
	
	// Verifica se o cliente da fatura é uma empresa do grupo
	If cCli $ "000481/004536/007871/010064/014395/018410/008615"	 
		
		If oParam:Box()
			
			fUpdate()
			
			cRet += " AND E1_YFATPAG = " + ValToSQL(cNumFat)			
			
		EndIf
		
	EndIf
	
	RestArea(aArea)
		
Return(cRet)


Static Function fUpdate()
Local cSQL := ""

	If Len(Alltrim(oParam:cNumFat)) == 9
		cNumFat	:= Substr(Alltrim(oParam:cNumFat), 4, 6)
	Else
		cNumFat	:= Alltrim(oParam:cNumFat)
	EndIf 

	cSQL := " UPDATE " + RetSQLName("SE1")
	cSQL += " SET "
	cSQL += " E1_YFATPAG = " + ValToSQL(cNumFat)
	
	cSQL += " FROM "+ fGetSE2Ori() +" SE2, "+ RetSQLName("SE1") +" SE1 "
	cSQL += " WHERE E2_FATURA = " + ValToSQL(oParam:cNumFat)
	cSQL += " AND SE1.E1_NUM = SE2.E2_NUM "
	cSQL += " AND SE1.E1_PREFIXO = SE2.E2_PREFIXO "
	cSQL += " AND SE1.E1_PARCELA = SE2.E2_PARCELA "
	cSQL += " AND SE1.E1_TIPO = SE2.E2_TIPO "
	cSQL += " AND SE1.E1_CLIENTE = " + ValToSQL(cCli)
	cSQL += " AND SE2.E2_FORNECE = " + ValToSQL(fGetCodFor())
	cSQL += " AND SE2.D_E_L_E_T_ = '' "
	cSQL += " AND SE1.D_E_L_E_T_ = '' "

	TCSQLExec(cSQL)

Return()


Static Function fGetSE2Ori()
Local cRet := "SE2"

	If cCli == "000481"
		
		cRet += "010"
		
	ElseIf cCli == "004536"
	
		cRet += "050"
		
	ElseIf cCli == "007871"
	
		cRet += "060"
		
	ElseIf cCli == "010064"
	
		cRet += "070"

	ElseIf cCli == "018410"
	
		cRet += "120"
		
	ElseIf cCli == "014395"
	
		cRet += "130"
		
	ElseIf cCli == "008615"
	
		cRet += "140"
	
	EndIf	

Return(cRet)


Static Function fGetCodFor()
Local cRet := ""

	If cEmpAnt == "01"
		
		cRet += "000534"
		
	ElseIf cEmpAnt == "05"
	
		cRet += "002912"
		
	ElseIf cEmpAnt == "06"
	
		cRet += "007437"
		
	ElseIf cEmpAnt == "07"
	
		cRet += "007602"

	ElseIf cEmpAnt == "12"
	
		cRet += "004890"
		
	ElseIf cEmpAnt == "13"
	
		cRet += "004695"
		
	ElseIf cEmpAnt == "14"
	
		cRet += "003721"
	
	EndIf	

Return(cRet)