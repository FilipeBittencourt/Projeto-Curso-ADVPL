#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Rodrigo Ribeiro Agostini
Programa  := MA140BUT
Empresa   := Biancogres Cerâmica S/A
Data      := 25/02/19
Uso       := Controladoria
Aplicação := Incluindo botão em OUTRAS AÇÔES dentro da alteração da PRE-NOTA DE ENTRADA

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function MA140BUT()

Private aButtons := {}

If (ALTERA)
		
	If (Alltrim(CESPECIE) == 'SPED')	
		aadd(aButtons,{ 'NOTE',{|| U_BIARO002()},'Iniciar Processo de Conferência a Cegas', 'Iniciar Processo de Conferência a Cegas' } )
    EndIf
    
    If (Alltrim(CESPECIE) == 'NFS')    
    	aadd(aButtons,{ 'NOTE',{|| U_BIARO003()},'Iniciar Processo de Aprovação NFS', 'Iniciar Processo de Aprovação NFS' } )	
	EndIf
		
EndIf

Return (aButtons)