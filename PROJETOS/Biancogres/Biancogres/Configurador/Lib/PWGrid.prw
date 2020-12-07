#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TGDField
@author Tiago Rossini Coradini
@since 19/10/2016
@version 1.0
@description Classe para manipulação de campos em objetos GetDados e MsNewGetDados 
@type class
/*/

Class PWGrid From LongClassName	
	
	Data nRow
	Data nCol
	Data nWidth
	Data nHeight
	Data oOwner	
	Data Fields	
	Data oBrowse
	
	Method New() Constructor
	Method Init()	

EndClass


Method New(oOwner) Class PWGrid	

	Default oOwner := GetWndDefault()	
	
	::nRow := 0
	::nCol := 0 
	::nWidth := 0
	::nHeight := 0
	::oOwner := oOwner
	
	::oBrowse := TCBrowse():New(::nRow, ::nCol, ::nWidth, ::nHeight,,,,::oOwner)	
	
	::Fields := HashTable():New()	
	
Return()


Method Init() Class PWGrid

Return() 