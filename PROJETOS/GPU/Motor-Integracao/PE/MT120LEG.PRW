#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
------------------------------------------------------------------------------------------------------------
Função		: MT120LEG
Tipo		: Ponto de Entrada
Descrição	: Manipula apresentação das cores na mBrowse
Uso			: Compras
Parâmetros	: cExp1 = PARAMIXB
Retorno	: Array
------------------------------------------------------------------------------------------------------------
Atualizações:
- 01/10/2015 - Henrique - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
User Function MT120LEG()
	Local aLegend := aClone(PARAMIXB[1])
	Local nI 		:= 0

	nPos := aScan(aLegend, {|x|AllTrim(x[1]) == 'BR_AZUL'}) //Legenda de pedido Bloqueado
	
	aLegend[nPos, 2] := 'Pedido pendente/Não enviado ao fornecedor' 
Return aLegend