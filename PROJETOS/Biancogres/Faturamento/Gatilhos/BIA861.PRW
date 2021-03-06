#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA861
@author Ranisses A. Corona
@since 29/04/2014
@version 1.0
@description Automatiza sequencia do codigo do Cadastro de Cliente
@history 29/04/2014, Ranisses A. Corona, Cria��o do fonte
@history 29/04/2014, Thiago Dantas, Melhoria na funcao para definicao do codigo
@history 18/02/2021, Ranisses A. Corona, Criacao da funcao de fRegCobr
@type function
/*/

User Function BIA861()
Local nSeq := "000000"

If !Empty(Alltrim(M->A1_CGC)) .Or. M->A1_TIPO == "X"
    
    M->A1_YCDGREG := U_fRegCobr(Alltrim(M->A1_EST), Alltrim(M->A1_CGC), Alltrim(M->A1_GRPVEN), Alltrim(M->A1_COD))
    
    If cEmpAnt == "02"
    	nSeq := M->A1_COD
    Else 
	    If U_fValFunc(Alltrim(M->A1_CGC)) //� funcion�rio?
			nSeq := GetSxENum("SA1","A1_COD","SA1_FUN")
		Else
			nSeq := GetSxENum("SA1","A1_COD","SA1_CLI")
		EndIf
	EndIf
	
EndIf

Return(nSeq)
