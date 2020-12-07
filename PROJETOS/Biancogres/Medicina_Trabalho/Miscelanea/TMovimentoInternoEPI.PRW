#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0034; Return()

/*
|-----------------------------------------------------------|
| Classe: | TIMovimentoInternoEPI														|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 25/05/16																			  |
|-----------------------------------------------------------|
| Desc.:	|	Classe para manipulacao das informacoes da 			|
| 				|	movimentação interna (SD3) de EPI 							|
|-----------------------------------------------------------|
| OS:			|	1130-16 - Carlos Junqueira											|
|-----------------------------------------------------------|
*/


Class TMovimentoInternoEPI From LongClassName
	
	Data oLst // Lista de movimentos internos
	
	Method New() Constructor
	Method Add(cNumDoc) // Adiciona movimentos interno a lista
	Method Get(cCodEPI, nQtdEnt, nCusMed, cNumSeq) // Retorna o numero sequencial (SD3), referente ao registro de EPI (TNF)
	
EndClass


Method New() Class TMovimentoInternoEPI
	
	::oLst := ArrayList():New()
			
Return()


Method Add(cNumDoc) Class TMovimentoInternoEPI
Local oIT := TIMovimentoInternoEPI():New()
		 	
	// Busca dados da Movimentação Interna
	DbSelectArea("SD3")
	DbSetOrder(2)
	If SD3->(DbSeek(xFilial("SD3") + cNumDoc))
	
		While !SD3->(Eof()) .And. SD3->D3_DOC == cNumDoc
		
			// Identifica que é movimento de estoque de EPI
			If SD3->D3_YAPLIC == "4"
				
				oIT:cCodEPI := SD3->D3_COD
				oIT:nQtdEnt := SD3->D3_QUANT
				oIT:cNumSeq := SD3->D3_NUMSEQ
				oIT:nCusMed := SD3->D3_CUSTO1
				oIT:lRegUtl := .F.
				
				::oLst:Add(oIT)
				
			EndIf
			
			SD3->(DbSkip())
						
		EndDo
	
	EndIf
	
Return()


Method Get(cCodEPI, nQtdEnt, nCusMed, cNumSeq) Class TMovimentoInternoEPI
Local nCount := 0

	For nCount := 1 To ::oLst:GetCount()
				
		If !::oLst:GetItem(nCount):lRegUtl
		
			If ::oLst:GetItem(nCount):cCodEPI == cCodEPI .And. ::oLst:GetItem(nCount):nQtdEnt == nQtdEnt
				
				::oLst:GetItem(nCount):lRegUtl := .T.
				
				nCusMed := ::oLst:GetItem(nCount):nCusMed
				cNumSeq := ::oLst:GetItem(nCount):cNumSeq
				
			EndIf
			
		EndIf
		
	Next

Return()