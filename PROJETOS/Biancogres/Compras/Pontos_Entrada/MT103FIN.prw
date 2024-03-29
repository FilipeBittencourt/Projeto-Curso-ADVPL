#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

User Function MT103FIN()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Marcos Alberto Soprani
Programa  := MT103FIN
Empresa   := Biancogres Cer鈓ica S/A
Data      := 01/12/11
Uso       := Compras
Aplica玢o := Ponto de Entrada Respons醰el pela Valida玢o do Grid Duplicatas
.            Inicialmente para tratamento do vencimento das duplicatas
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Local nCount
Local xaLocHd := PARAMIXB[1]      // aHeader do getdados apresentado no folter Financeiro.
Local xaLocCl := PARAMIXB[2]      // aCols do getdados apresentado no folter Financeiro.
Local xLocRtn := PARAMIXB[3]      // Flag de valida珲es anteriores padr鮡s do sistema.
//                                   Caso este flag esteja como .T., todas as valida珲es
//                                   anteriores foram aceitas com sucesso, no contr醨io, .F.
//                                   indica que alguma valida玢o anterior N肙 foi aceita.

If xLocRtn
	
	If Len(xaLocCl) > 0
	
		For nCount := 1 To Len(xaLocCl)
			
			If !Empty(xaLocCl[nCount][2]) .And. xaLocCl[nCount][2] < dDataBase
				
				MsgBox("O vencimento de uma ou mais duplicatas � menor que a data de digita玢o. Favor verificar!!!","MT103FIN","STOP")
				
				xLocRtn := .F.
				
			EndIf
			
		Next
	
	EndIf
	
EndIf

Return(xLocRtn)
