#Include 'Protheus.ch'

/*/{Protheus.doc} CHGX5FIL
@author Jussara Nobrega
@since 12/02/2019
@version 1.0
@description Ponto de Entrada para Filtrar a filial quando SX5 compartilhado, mas tem informação das filiais  
@obs Ticket: 12597
@type Function
/*/

User Function CHGX5FIL()

	Local cFilSX5 := "  "

	If cEmpAnt ==  "06" //JK
		cFilSX5 := cFilAnt

	ElseIf cEmpAnt ==  "01" //Biancogres
		cFilSX5 := cFilAnt

	ElseIf cEmpAnt ==  "07" //.And. ( Upper(AllTrim(getenvserver())) == "DEV-VINILICO" ) //LM //retirar o ENV em producao o vinilico
		cFilSX5 := cFilAnt

	Endif

Return cFilSX5