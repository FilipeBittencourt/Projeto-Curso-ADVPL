#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "tbiconn.ch"

User Function A250FSD4()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Marcos Alberto Soprani
Programa  := A250FSD4
Empresa   := Biancogres Cer鈓ica S/A
Data      := 21/10/11
Uso       := PCP / Estoque Custos
Aplica玢o := Ponto de entrada para validar se a quantidade a ser baixada
.            a partir do empenho (SD4) possui saldo em Estoque ou na
.            InterCompany.
.	           Esta rotina s� pode ser processada uma 鷑ica vez por apontamen-
.            to. Por isso esta var韆vel (qw_Varr1) � utilizada.
.	           Esta vari醰el � criada no ponto de entrada A250ITOK como .T.
.            e logo que entra na rotina passa para .F.. Assim atende a ne-
.            cessidade acima descrita.
.            - Um retorno logico (.T.) confirma a requisicao do empenho e
.            um retorno falso nao empenha o produto
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Local ik_Area    := GetArea()
Local xk_Percent := PARAMIXB[1]
Local xk_RetPE   := .T.
Local j, i

// Tratamento efetuando apenas para as Empresas do Grupo que s鉶 industrias at� a data de implementa玢o - 21/12/11
If cEmpAnt $ "01/05/14"
	
	s_RecB1 := SB1->(Recno())
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+SD4->D4_COD))
	s_B1TpIn := SB1->B1_TIPO
	s_B1GrIn := SB1->B1_GRUPO
	
	SC2->(dbSetOrder(1))
	SC2->(dbSeek(xFilial("SC2")+SD4->D4_OP))
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
	s_B1TpPr := SB1->B1_TIPO
	
	SB1->(dbGoTo(s_RecB1))
	// Condi玢o inserida em 05/01/12 enquanto aguarda a entrada de toda a baixa de estoque via apontamento de produ玢o do PA. Caso esta regra n鉶 fosse implementada,
	// ocorreriam poss韛eis baixas em duplicidade.
	If s_B1TpPr $ "PA/PS/PP"
		
		// Implementado tratamento para grupo 107 em 17/01/14 para atender ao setor de compras
		If ( s_B1TpIn == "MP" .and. s_B1GrIn $ "101 " )
			xk_RetPE := .F.
			dbSelectArea("SD4")
			RecLock("SD4",.F.)
			If SD4->D4_QUANT - (SD4->D4_QTDEORI * xk_Percent) > 0
				SD4->D4_QUANT -= SD4->D4_QTDEORI * xk_Percent
			EndIf
			MsUnLock()
		EndIf
		
	EndIf
	
EndIf

RestArea(ik_Area)

Return( xk_RetPE )
