#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF018
@author Tiago Rossini Coradini
@since 07/03/2019
@project Automação Financeira
@version 1.0
@description Rotina para atualizar dados financeiros do fornecedor
@type function
/*/

User Function BAF018()
Local aArea := GetArea()
Local aCpo := {}
Local aCpoAlt := {}
Local aRotBkp := {}

	If Type("aRotina") == "A"
	
		aRotBkp := aRotina
	
	EndIf
	
	Private aRotina := { {"Alterar"		,"AxAltera",0,1},;
 						 {"Alterar"		,"AxAltera",0,2},;
  						 {"Alterar"		,"AxAltera",0,3},;
						 {"Alterar"		,"AxAltera",0,4} } 
						 
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	If SA2->(DbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))

		aCpo := {"A2_COD", "A2_LOJA", "A2_NOME", "A2_NREDUZ", "A2_BANCO", "A2_AGENCIA", "A2_YDVAG", "A2_YDVCTA", "A2_NUMCON", "A2_YDVCTA", "A2_YTPCONT", "A2_YCDGREG", "NOUSER"}
		
		aCpoAlt := {"A2_BANCO", "A2_AGENCIA", "A2_YDVAG", "A2_YDVCTA", "A2_NUMCON", "A2_YDVCTA", "A2_YTPCONT", "A2_YCDGREG"}

		AxAltera("SA2", SA2->(RecNo()), 4, aCpo, aCpoAlt)

	EndIf
	
	If Len(aRotBkp) > 0
	
		aRotina := aRotBkp
	
	EndIf

	RestArea(aArea)
	
Return()