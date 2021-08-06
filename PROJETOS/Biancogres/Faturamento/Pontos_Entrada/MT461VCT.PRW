#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT461VCT
@author Tiago Rossini Coradini - Facile Sistemas
@since 05/01/16
@version 1.0
@description P.E. Tratamento para adicionar parcela com o Valor do ICMS Interestadual para a UF de destino\origem (EC 87/2015) - Ranisses Corona
@type function
/*/

User Function MT461VCT()
Local _aVencto := PARAMIXB[1] 
Local nCount := 0
Local nVlrTot := 0
Local nVlrPar := 0

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
	
Return(_aVencto)
