#INCLUDE "TOTVS.CH"

/*
|------------------------------------------------------------|
| Função:	| MTA094RO														
| Autor:	|	Gabriel Rossi Mafioletti
| Data:		| 24/10/17																				 |
|------------------------------------------------------------|
| Desc.:	|	Ponto de entrada para adicionar rotinas no menu  |
| 				| de liberação de Documentos
|------------------------------------------------------------|
|------------------------------------------------------------|
*/

User Function MTA094RO()
Local _aOpcs	:=	PARAMIXB[1]
	//aAdd(_aOpcs, {"Hist. Preço", "U_BIAF002('MATA094')", 0, 8, 0, .F.})
	aAdd(_aOpcs, {"E-Mail Informações", "U_BIAFG038()", 0, 8, 0, .F. })
	
	// VALOPER(cFuncao,lShowMsg,lAdmLib,cMsg)
	If  U_VALOPER("PZ0",.F.)
			Aadd(_aOpcs,{'Conhecimento',"U_MSdoc()", 0, 9,0,NIL}) 
	EndIf

	Return(_aOpcs)
	
	User Function MSdoc()
	Private aRotina := FWloadmenudef('MATA094')
		MsDocument('AC9',AC9->(RecNo()), 4)	
	return .t.
