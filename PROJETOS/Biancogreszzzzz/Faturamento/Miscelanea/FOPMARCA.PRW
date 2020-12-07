#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} FOPLINHA
@description Campo OPCOES para MARCA e LINHAS de produtos
@author Fernando / Pedro Facile
@since 21/05/2019
@version 1.0
@type function
/*/
User Function FOPLINHA()

	Local cOpcoes := ""

	cOpcoes += "1=Biancogres;"
	cOpcoes += "2=Incesa;"
	cOpcoes += "3=BellaCasa;"
	cOpcoes += "4=Mundialli;"                                                                                     
	cOpcoes += "5=Pegasus;"
	cOpcoes += "6=Vinilico;"

Return(cOpcoes)


/*/{Protheus.doc} FOPMARCA
@description Campo OPCOES para MARCA e LINHAS de produtos
@author Fernando / Pedro Facile
@since 21/05/2019
@version 1.0
@param _lgr05, , SE ADICIONA MARCAS DA INCESA AGRUPADAS
@param _ldes05, , SE ADICIONA MARCAS DA INCESA DESTACADAS
@param _lTodas, , SE ADICIONA TODAS
@param _lPegasus, , SE ADICIONA PEGASUS
@type function
/*/
User Function FOPMARCA(_lgr05,_ldes05,_lTodas, _lPegasus)

	Local cOpcoes := ""

	default _lgr05 := .F.
	default _ldes05 := .T.
	default _lTodas := .T.
	default _lPegasus := .T.

	cOpcoes += "0101=Biancogres;"
	
	If _lPegasus
	
		cOpcoes += "0199=Pegasus;"
		
	EndIf

	If _lgr05
	
		cOpcoes += "05XX=Incesa/Bellacasa;"
	
	EndIf
	
	If _ldes05
	
		cOpcoes += "0501=Incesa;"
		cOpcoes += "0599=Bellacasa;"
	
	EndIf

	cOpcoes += "1399=Mundialli;"
	cOpcoes += "1302=Vinilico;"
	
	If _lTodas
	
		cOpcoes += "XXXX=Todas;"
		
	EndIf

Return(cOpcoes)