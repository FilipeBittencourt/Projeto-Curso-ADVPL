#INCLUDE "TOTVS.CH"       
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Função: | MT461VCT																				|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 05/01/16																			  |
|-----------------------------------------------------------|
| Desc.:	|	Ponto de entrada para alterar o valor e o 			|
| 				|	vencimento do título gerado no momento de 			|
| 				|	geração da nota fiscal de saida									|
|-----------------------------------------------------------|
| OBS:		|	Tratamento para adicionar parcela com o Valor do|
|					|	ICMS Interestadual para a UF de destino\origem 	|
|					|	(EC 87/2015) - Ranisses Corona									|
|-----------------------------------------------------------|
*/

User Function MT461VCT()
Local _aVencto := PARAMIXB[1] 
Local _aTitulo := PARAMIXB[2] 
Local nCount := 0
Local nVlrTot := 0
Local nVlrPar := 0
Local nDiaVenc := 0
Local aAreaACY := ACY->(GetArea())

	If SF3->F3_DIFAL > 0 .And. SE4->E4_TIPO == "1" .And. !U_fValidaRA(SF2->F2_COND)
				
		// Pega valor total da nota diretamente do array de parcelas
		For nCount := 1 To Len(_aVencto)
			nVlrTot += _aVencto[nCount,2]
		Next
		
		// Desconta valor do "ICMS DIFAL" e "FUNDO DE POBREZA" do valor total do título
		nVlrTot -= (SF3->F3_DIFAL + SF3->F3_VFCPDIF)
		
		// Calcula valor das parcelas sem o imposto
		nVlrPar := nVlrTot / Len(_aVencto)
	
		For nCount := 1 To Len(_aVencto)
			
			// Soma o valor do "ICMS DIFAL" e "FUNDO DE POBREZA" na primeira parcela
			If nCount == 1
				_aVencto[nCount,2] := nVlrPar + (SF3->F3_DIFAL + SF3->F3_VFCPDIF)
			Else
				_aVencto[nCount,2] := nVlrPar
			EndIf
			
		Next			
	
	EndIf
	
	//@@@ Projeto.: Automacao Financeira
	//@@@ Item....: Vencimento parcelas de Clientes Especiais
	//@@@ Data....: 27/09/2018
	
	If SA1->(FieldPos("A1_YSUMCE")) > 0 .And. SA1->A1_YSUMCE > 0
	
		nDiaVenc := SA1->A1_YSUMCE
	
	ElseIf ACY->(FieldPos("ACY_YSUMCE")) > 0
		
		DBSelectArea("ACY")
		ACY->(DBSetOrder(1)) // ACY_FILIAL, ACY_GRPVEN, R_E_C_N_O_, D_E_L_E_T_
		
		If ACY->(DBSeek(xFilial("ACY") + SA1->A1_GRPVEN))
			
			nDiaVenc := ACY->ACY_YSUMCE
			
		EndIf
	
	EndIf
	
	If nDiaVenc > 0
	
		For nCount := 1 To Len(_aVencto)
			
			_aVencto[nCount, 1] := DataValida(_aVencto[nCount, 1] + nDiaVenc)
			
		Next nCount
	
	EndIf
	
	RestArea(aAreaACY)
	
	//@@@ Projeto.: Automacao Financeira - FIM

Return(_aVencto)