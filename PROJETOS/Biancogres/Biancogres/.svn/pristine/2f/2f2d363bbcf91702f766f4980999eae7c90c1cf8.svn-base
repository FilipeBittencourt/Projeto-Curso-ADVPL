#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F370E5F
@author Tiago Rossini Coradini
@since 01/11/2017
@version 1.0
@description Ponto de entrada para filtrar registros na SE5 na contabilização off line 
@type function
/*/

User Function F370E5F()
Local cRet := ParamIxb
	
	If MV_PAR18 == 1
			
		If !Empty(AllTrim(MV_PAR19))
								
			cRet := ' Alltrim(SE5->E5_ARQCNAB) == "'+ Upper(AllTrim(MV_PAR19)) +'" '   
							
		EndIf			
		
	EndIf
	
Return(cRet)