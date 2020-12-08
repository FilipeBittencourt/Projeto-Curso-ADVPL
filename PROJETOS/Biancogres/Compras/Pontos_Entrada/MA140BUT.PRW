#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"

/*��������������������������������������������������������������������������
Autor     := Rodrigo Ribeiro Agostini
Programa  := MA140BUT
Empresa   := Biancogres Cer�mica S/A
Data      := 25/02/19
Uso       := Controladoria
Aplica��o := Incluindo bot�o em OUTRAS A��ES dentro da altera��o da PRE-NOTA DE ENTRADA

���������������������������������������������������������������������������*/

User Function MA140BUT()

Private aButtons := {}

If (ALTERA)
		
	If (Alltrim(CESPECIE) == 'SPED')	
		aadd(aButtons,{ 'NOTE',{|| U_BIARO002()},'Iniciar Processo de Confer�ncia a Cegas', 'Iniciar Processo de Confer�ncia a Cegas' } )
    EndIf
    
    If (Alltrim(CESPECIE) == 'NFS')    
    	aadd(aButtons,{ 'NOTE',{|| U_BIARO003()},'Iniciar Processo de Aprova��o NFS', 'Iniciar Processo de Aprova��o NFS' } )	
	EndIf
		
EndIf

Return (aButtons)