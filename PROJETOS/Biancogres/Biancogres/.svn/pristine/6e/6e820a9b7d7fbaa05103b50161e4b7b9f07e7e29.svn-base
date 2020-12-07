#INCLUDE "TOTVS.CH"
#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA744
@author Rodrigo Ribeiro Agostini
@since 15/03/2018
@version 1.0
@description Responsável pelo preencimento da classe de valor do lançamento padrão  530014
@type function
/*/
User Function BIA744()

	Local aArea := GetArea()
	Local cCLVL := ""

	//cCLVL := IIF(cEmpAnt == "01", 1101, IIF(cEmpAnt == "05", 1102,IIF(cEmpAnt == "06", 1155,IIF(cEmpAnt == "07", 1150,IIF(cEmpAnt == "12", 1190,IIF(cEmpAnt == "13", 1180,IIF(cEmpAnt == "14", 1135,IIF(cEmpAnt == "16", 1104,IIF(cEmpAnt == "17", 1103, 0)))))))))
	
	cCLVL := U_BIA478G("ZJ0_CLVLDB", PADR("2923", TamSx3("E5_NATUREZ")[1]), "P")

	RestArea(aArea)

Return(cCLVL)