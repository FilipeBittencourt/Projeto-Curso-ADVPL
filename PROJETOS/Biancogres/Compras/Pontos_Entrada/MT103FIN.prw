#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

User Function MT103FIN()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := MT103FIN
Empresa   := Biancogres Cerâmica S/A
Data      := 01/12/11
Uso       := Compras
Aplicação := Ponto de Entrada Responsável pela Validação do Grid Duplicatas
.            Inicialmente para tratamento do vencimento das duplicatas
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local nCount
Local xaLocHd := PARAMIXB[1]      // aHeader do getdados apresentado no folter Financeiro.
Local xaLocCl := PARAMIXB[2]      // aCols do getdados apresentado no folter Financeiro.
Local xLocRtn := PARAMIXB[3]      // Flag de validações anteriores padrões do sistema.
//                                   Caso este flag esteja como .T., todas as validações
//                                   anteriores foram aceitas com sucesso, no contrário, .F.
//                                   indica que alguma validação anterior NÃO foi aceita.

If xLocRtn
	
	If Len(xaLocCl) > 0
	
		For nCount := 1 To Len(xaLocCl)
			
			If !Empty(xaLocCl[nCount][2]) .And. xaLocCl[nCount][2] < dDataBase
				
				MsgBox("O vencimento de uma ou mais duplicatas é menor que a data de digitação. Favor verificar!!!","MT103FIN","STOP")
				
				xLocRtn := .F.
				
			EndIf
			
		Next
	
	EndIf
	
EndIf

Return(xLocRtn)
