#include "rwmake.ch"        

/*/{Protheus.doc} F100TOK
@description Ponto de Entrada na rotina FINA100 - Validacao TOK do movimento bancario
@author Gustav Koblinger Jr
@since 12/09/2005
@version 1.0
@type function
@version 12 Revisado por Fernando em 05/04/2018 
/*/
User Function F100TOK()       

	Private wRet := .T.

	If !IsBlind()
		If !Alltrim(cEmpAnt) == "02" //Se for Diferente da Empresa Ceramica Incesa 
			If cRecpag == "R" // Movimento Bancario a Receber
				If Empty(M->E5_CLVLCR)
					MsgBox("Movimento Bancario a Receber"+Chr(13)+Chr(10)+"Favor informar Classe de Valor a Crédito","Informar Conta","STOP")
					wRet := .F.
				EndIf
			ElseIf	cRecpag == "P" // Movimento Bancario a Pagar
				If Empty(M->E5_CLVLDB)
					MsgBox("Movimento Bancario a Pagar"+Chr(13)+Chr(10)+"Favor informar Classe de Valor a Débito","Informar Conta","STOP")
					wRet := .F.
				EndIf	
			EndIf
		EndIf

		If M->E5_DATA <= GETMV("MV_DATAFIN")
			MsgBox("Nao e permitida movimentação bancária, com data anterior a "+Dtoc(GetMv("MV_DATAFIN"))+". ","DATA INVALIDA","INFO")
			wRet := .F.
		EndIf
	EndIf

Return wRet