#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFRegraComunicacaoBancaria
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe com as regras de comunicação bancaria
@type class
/*/

Class TAFRegraComunicacaoBancaria From LongClassName
		
	Data cTipo // P=Pagar; R=Receber
	Data cOpc // E=Envio; R=Retorno
	Data oLst // Lista de objetos
	Data cIDProc // Identificar do processo
		
	Method New() Constructor
	Method Set()
	Method Get()
	Method Validate()
	
EndClass


Method New() Class TAFRegraComunicacaoBancaria

	::cTipo := "P"
	::cOpc := "E"
	::oLst := Nil
	::cIDProc := ""

Return()


Method Set() Class TAFRegraComunicacaoBancaria
Local oObj := Nil
	
	If ::cOpc == "E"
						
		If ::cTipo == "P"
			
			oObj := TAFRegraComunicacaoBancariaPagar():New()
			
		ElseIf ::cTipo == "R"

			oObj := TAFRegraComunicacaoBancariaReceber():New()
			
		EndIf
		
		oObj:cOpc := ::cOpc
		oObj:oLst := ::oLst
		oObj:cIDProc := ::cIDProc
		
		oObj:Set()
			
	EndIf

Return()


Method Get() Class TAFRegraComunicacaoBancaria
Local oLst := Nil
	
	If ::cOpc == "R"
						
		If ::cTipo == "P"
			
			oObj := TAFRegraComunicacaoBancariaPagar():New()
			
		ElseIf ::cTipo == "R"

			oObj := TAFRegraComunicacaoBancariaReceber():New()
			
		EndIf
		
		oObj:cOpc := ::cOpc
		oObj:cIDProc := ::cIDProc
			
		oLst := oObj:Get()

	EndIf
		
Return(oLst)


Method Validate() Class TAFRegraComunicacaoBancaria
Local lRet := .F.
Local nCount := 1
	
	lRet := aScan(::oLst:ToArray(), {|x| !Empty(x:cBanco) }) > 0

Return(lRet)