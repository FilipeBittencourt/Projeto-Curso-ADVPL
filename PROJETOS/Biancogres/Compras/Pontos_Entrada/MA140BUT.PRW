#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Rodrigo Ribeiro Agostini
Programa  := MA140BUT
Empresa   := Biancogres Cer鈓ica S/A
Data      := 25/02/19
Uso       := Controladoria
Aplica玢o := Incluindo bot鉶 em OUTRAS A窃ES dentro da altera玢o da PRE-NOTA DE ENTRADA

北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

User Function MA140BUT()

Private aButtons := {}

If (ALTERA)
		
	If (Alltrim(CESPECIE) == 'SPED')	
		aadd(aButtons,{ 'NOTE',{|| U_BIARO002()},'Iniciar Processo de Confer阯cia a Cegas', 'Iniciar Processo de Confer阯cia a Cegas' } )
    EndIf
    
    If (Alltrim(CESPECIE) == 'NFS')    
    	aadd(aButtons,{ 'NOTE',{|| U_BIARO003()},'Iniciar Processo de Aprova玢o NFS', 'Iniciar Processo de Aprova玢o NFS' } )	
	EndIf
		
EndIf

Return (aButtons)