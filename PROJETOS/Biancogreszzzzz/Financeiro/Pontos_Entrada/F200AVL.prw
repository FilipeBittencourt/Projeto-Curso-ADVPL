#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F200AVL
@author Tiago Rossini Coradini - Facile Sistemas
@since 14/05/15
@version 1.0
@description Utilizado para ler a linha do arquivo de retorno do cnab a receber.
@type function
/*/

User Function F200AVL()
Local	lRet := .T.
Local	oRecAnt	:= TRecebimentoAntecipado():New()
Local aVar := Array(1, 14)

	aVar[1] := { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, 0, 0, dDataCred, cOcorr }

	// Verifica se o titulo provisorio foi recebido pelo banco, caso tenha, desconsidera item do arquivo de retorno 
	If oRecAnt:TituloRecBan(aVar)
		
		lRet := .F.		
		__lBaixarPr := .T.
		
	EndIf
	
Return(lRet)
