#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "MSOBJECT.CH" 
#include "TOTVS.CH" 

User Function TECFAT05()    
    
	Local oPoderTerc := Nil  
	
	oPoderTerc := TWCryoPorderTerceiro():New()  
	oPoderTerc:CarregaPropiedadeJanela()
	oPoderTerc:Show()                             	
	 
Return()
  

             

