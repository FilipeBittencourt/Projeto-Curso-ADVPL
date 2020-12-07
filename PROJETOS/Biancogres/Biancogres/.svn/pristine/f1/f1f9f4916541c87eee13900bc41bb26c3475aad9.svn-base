#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F450VALCON
@author Wlysses Cerqueira (Facile)
@since 13/06/2019
@project Automação Financeira
@version 1.0
@description Ponto de entrada permite a validação após a seleção de títulos..
@type PE
/*/

User Function F450VALCON()
	
	Local nRecTRB_	:= TRB->(Recno())
	Local nVlrRec_	:= 0
	Local nVlrPag_	:= 0
	Local nRet_		:= Nil
	
	DBSelectArea("TRB")
	TRB->(DBGotop())
		
	While TRB->(! EOF())
	
		If TRB->MARCA == cMarca
		
			nVlrRec_ += TRB->RECEBER
			
			nVlrPag_ += TRB->PAGAR
	
		EndIf
	
		TRB->(DBSkip())
		
	EndDo
	
	TRB->(DBGoto(nRecTRB_))
	
	If nVlrPag_ <> nVlrRec_
	
		MsgStop("Total a compensar diferente no pagar e receber!" + CRLF + CRLF + "Valor no receber: " + AllTrim(Transform(nVlrRec_, "@E 999,999,999.99")) + CRLF + "Valor no pagar: " + AllTrim(Transform(nVlrPag_, "@E 999,999,999.99")), "ATENCAO")

		nRet_ := 0
	
	EndIf

Return(nRet_)