#include "rwmake.ch"
#include "topconn.ch"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} M410FSQL
@description Ponto de Entrada utilizado para filtrar os pedidos de acordo com cada representante
@author Ranisses A. Corona / Revisado por Fernando na V12
@since 30/01/2014
@version undefined
@type function
/*/
User Function M410FSQL()
	
	Local aArea 	:= GetArea()        
	Local cFiltro 	:= ""
	Local A00 		:= ""
	Local _cVend 	:= ""
	Local oAceTela 	:= TAcessoTelemarketing():New()

	If !Empty(Alltrim(cRepAtu))
		//cFiltro := " C5_FILIAL = '"+xFilial("SC5")+"' AND C5_VEND1 = '"+cRepAtu+"' AND C5_EMISSAO >= '"+Dtos(ddatabase - 90)+"' "
		
		cFiltro := " C5_FILIAL = '"+xFilial("SC5")+"' .AND. C5_VEND1 = '"+cRepAtu+"' .AND. DTOS(C5_EMISSAO) >= '"+DTOS(ddatabase - 90)+"' "
			  
	EndIf

	If (oAceTela:UserTelemaketing())
		cFiltro := oAceTela:FiltroSC5()	
	EndIf	
   
	RestArea(aArea)
Return(cFiltro)