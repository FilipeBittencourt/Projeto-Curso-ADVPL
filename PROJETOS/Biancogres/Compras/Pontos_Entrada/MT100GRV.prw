#include "rwmake.ch"
#include "topconn.ch"

User Function MT100GRV()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Marcos Alberto Soprani
Programa  := MT100GRV
Empresa   := Biancogres Cer鈓ica S/A
Data      := 11/10/2011
Uso       := Compras
Aplica玢o := PONTO DE ENTRADA executado antes da Inclus鉶 / Dele玢o da nota
.            fiscal de entrada. Valida ou n鉶 a a玢o
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Local fpArea := GetArea()
Local xt_RetOk := .T.
Local xt_DelOk := PARAMIXB[1]

// Processo de Devolu玢o. Inclu韉o por Marcos Alberto em 11/10/11 a pedido da Diretoria.
// Rotinas envolvidas: BIA267, SF1100I, SF1100E, SD1100I, MT100LOK, MT100GRV
If xt_DelOk
	If cTipo == "D"
		
		A0002 := " SELECT DISTINCT Z26_NUMPRC
		A0002 += "   FROM "+ RetSqlName("Z26")
		A0002 += "  WHERE Z26_FILIAL = '"+xFilial("Z26")+"'
		A0002 += "    AND Z26_OBS = '"+cNFiscal+cSerie+"'
		A0002 += "    AND Z26_ITEMNF = 'XX'
		A0002 += "    AND D_E_L_E_T_ = ' '
		TcQuery A0002 New Alias "A002"
		dbSelectArea("A002")
		dbGoTop()
		
		dbSelectArea("Z25")
		dbSetOrder(1)
		If dbSeek(xFilial("Z25")+A002->Z26_NUMPRC)
			If !Empty(Z25->Z25_APRFIS) .or. !Empty(Z25->Z25_APRFIN)
				xt_RetOk := .F.
				MsgBox("N鉶 ser� poss韛el excluir a digita玢o desta nota fiscal de devolu玢o porque o processo de devolu玢o j� passou pelo parecer f韘ico/Financeiro!!!", "MT100LOK", "ALERT")
			Endif
		EndIf
		A002->(dbCloseArea())
		
	EndIf
EndIf

RestArea(fpArea)

//TESTE CONEXAO INICIO
	conout(" ----------------------------------------------- ")
	conout(" ["+ Time() +"] Mensagem Conex鉶NF-e")
	conout(" > MT100GRV:")

	If Type("cEspecie") <> "U"
		conout("    cEspecie: '" + cEspecie + "'")
	else
		conout("    cEspecie n鉶 declarada")
	EndIf

	If Empty(SF1->F1_ESPECIE)
		conout("    SF1->F1_ESPECIE = ''")
	else
		conout("    SF1->F1_ESPECIE = '" + SF1->F1_ESPECIE + "'")
	EndIf
//TESTE CONEXAO FIM

Return( xt_RetOk )
