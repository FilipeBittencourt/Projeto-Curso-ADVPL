#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"

User Function A100DEL()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := A100DEL
Empresa   := Biancogres Ceramica S.A.
Data      := 20/02/13
Uso       := Compras
Aplicação := Valida Exclusão de NF
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local gtRetur := .T.

//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimentações retroativas que poderiam
// acontecer pelo fato de o parâmtro MV_ULMES necessitar permanecer em aberto até que o fechamento de estoque esteja concluído
If SF1->F1_DTDIGIT <= GetMv("MV_YULMES")
	MsgBox("Impossível prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!", "A100DEL", "STOP")
	gtRetur := .F.
EndIf

If GetNewPar("MV_YFATGRP",.F.)
	gtRetur := fVerifOP() //VErifica se a nota possui op's com apontamento
EndIf

If gtRetur .And. !U_BIAFG127(SF1->(RECNO()))

	gtRetur	:=	.F.

EndIF

Return ( gtRetur )


Static Function fVerifOP()

	Local _cAlias	:= GetNextAlias()
	Local _lRet		:=	.T.
	
	BeginSql Alias _cAlias
	
		SELECT COUNT(*) QTD
		FROM %TABLE:SF1% SF1
			JOIN %TABLE:SD1% SD1
				ON SF1.F1_FILIAL = SD1.D1_FILIAL
					AND SF1.F1_DOC = SD1.D1_DOC
					AND SF1.F1_FORNECE = SD1.D1_FORNECE
					AND SF1.F1_LOJA = SD1.D1_LOJA
					AND SD1.D1_OP <> ''
					AND SD1.%NotDel%
			JOIN %TABLE:SD3% SD3
				ON SD3.D3_FILIAL = SF1.F1_FILIAL
					AND SD3.D3_DOC = SF1.F1_DOC
					AND SD3.D3_OP = SD1.D1_OP
					AND SD3.D3_ESTORNO <> 'S'
					AND SD3.D3_TM = '010'
					AND SD3.%NotDel% 
		WHERE F1_FILIAL = %XFILIAL:SF1%
			AND F1_DOC = %Exp:SF1->F1_DOC%
			AND F1_SERIE = %Exp:SF1->F1_SERIE%
			AND F1_FORNECE = %Exp:SF1->F1_FORNECE%
			AND F1_LOJA = %Exp:SF1->F1_LOJA%
			AND SF1.%NOTDEL%
	EndSql

	_lRet := (_cALias)->QTD == 0 

	(_cALias)->(DbCloseArea())

	If !_lRet
		MsgBox("Existem Apontamentos para as Ordens de Produção Contidas no Documento de Entrada. Favor Corrigir!","A100DEL", "INFO")
	EndIf

Return _lRet