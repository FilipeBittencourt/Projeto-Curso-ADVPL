#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TGDFieldProperties
@author Tiago Rossini Coradini
@since 04/04/2017
@version 2.0
@description Classe com as propriedades dos campos dos objetos GetDados e MsNewGetDados 
@type class
/*/

Class TGDFieldProperties From LongClassName

 	Data cName
 	Data cTitle
	Data cPict
	Data nSize
	Data nDecimal
	Data cValid
	Data cUsed
	Data cType
	Data cF3
	Data cContext
	Data cCbox
	Data cRelation
	Data cWhen
	Data cVisual
	Data cVldUser
	Data cPictVar
	Data lObrigat
	Data nSort // 0=Sem ordenação; 1=Ascendente; 2=Descendente
		
	Method New() Constructor	
	
EndClass


Method New() Class TGDFieldProperties

 	::cName := ""
 	::cTitle := ""
	::cPict := ""
	::nSize := 0
	::nDecimal := 0
	::cValid := ""
	::cUsed := ""
	::cType := ""
	::cF3 := ""
	::cContext := ""
	::cCbox := ""
	::cRelation := ""
	::cWhen := ""
	::cVisual := ""
	::cVldUser := ""
	::cPictVar := ""
	::lObrigat := ""
	::nSort := 0

Return()