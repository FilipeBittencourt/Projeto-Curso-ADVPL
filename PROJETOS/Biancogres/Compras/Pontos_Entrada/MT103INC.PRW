#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} MT103INC
@description Este ponto de entrada pertence ao MATA103X (funções de validação e controle de interface do documento de entrada). É executado na rotina que verifica se o documento de entrada pode ser  incluído ou classificado, NFEVLDINI()
@author Fernando Rocha
@since 29/06/2018
@version 1.0
@type function
/*/

User Function MT103INC

	Local aArea 	:= GetArea()
	Local aAreaD1	:= SD1->(GetArea())
	Local _lClass 	:= ParamIXB
	Local _lContinua := .T.

	IF ( _lClass .And. SF1->(FieldPos("F1_YSERAPR")) > 0 )

		SD1->(DbSetOrder(1))
		If SD1->(DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))) .And. SubStr(SD1->D1_COD,1,3) == "306" .And. SF1->F1_YSERAPR <> "S"

			U_FROPMSG("NF de Serviço (MT103INC)", "Esta NF não teve o serviço CONFIRMADO, não é possível Classificar.")
			_lContinua := .F.			

		EndIf

	ENDIF

	RestArea(aArea)
	RestArea(aAreaD1)

Return( _lContinua )