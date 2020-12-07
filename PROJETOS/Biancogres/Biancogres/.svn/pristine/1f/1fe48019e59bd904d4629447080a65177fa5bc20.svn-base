#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

User Function BIA497()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Wanisay
Programa  := BIA497
Empresa   := Biancogres Cerâmica S/A
Data      := 30/01/13
Uso       := Faturamento
Aplicação := Ajuste de Comissão
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Private Enter := CHR(13)+CHR(10)

Pergunte("BIA497")

cQuery := "SELECT	" + Enter
cQuery := cQuery + "  *  " + Enter
cQuery := cQuery + "  FROM "+RetSqlName("SE3")+" " + Enter
cQuery := cQuery + "  WHERE E3_FILIAL = '"+xFilial('SE3')+"' " + Enter
cQuery := cQuery + "  AND E3_VEND = '"+MV_PAR01+"' " + Enter
cQuery := cQuery + "  AND E3_EMISSAO BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' " + Enter
cQuery := cQuery + "  AND E3_DATA = '' " + Enter
cQuery := cQuery + "  AND D_E_L_E_T_ = ''  " + Enter
cQuery := cQuery + "  ORDER BY E3_COMIS DESC  " + Enter

If chkfile("QRY")
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
TCQUERY cQuery ALIAS "QRY" NEW

DbSelectArea("QRY")
DbGotop()
lPassei := .F.
nSaldo  := MV_PAR04

While ! EOF()
	
	lPassei  := .T.
	cNumero  := QRY->E3_NUM
	cSerie   := QRY->E3_SERIE
	cCliente := QRY->E3_CODCLI
	cLoja    := QRY->E3_LOJA
	cVend    := QRY->E3_VEND
	cEmissao := QRY->E3_EMISSAO
	cTipo    := QRY->E3_TIPO
	
	IF nSaldo >= (QRY->E3_COMIS - 0.01)
		nSaldo := nSaldo - (QRY->E3_COMIS + 0.01)
		nValor := 0.01
	ELSE
		nValor := QRY->E3_COMIS - nSaldo
		nSaldo := 0
	ENDIF
	
	cSQL := "UPDATE "+RetSqlName("SE3")+" SET E3_YVLEMP1 = '"+ALLTRIM(STR(QRY->E3_COMIS))+"', E3_COMIS = '"+ALLTRIM(STR(nValor))+"' " + Enter
	cSQL := cSQL + " WHERE E3_NUM     = '"+cNumero+"' " + Enter
	cSQL := cSQL + " AND   E3_SERIE   = '"+cSerie+"' " + Enter
	cSQL := cSQL + " AND   E3_CODCLI  = '"+cCliente+"' " + Enter
	cSQL := cSQL + " AND   E3_LOJA    = '"+cLoja+"' " + Enter
	cSQL := cSQL + " AND   E3_VEND    = '"+cVend+"' " + Enter
	cSQL := cSQL + " AND   E3_EMISSAO = '"+cEmissao+"' " + Enter
	cSQL := cSQL + " AND   E3_TIPO    = '"+cTipo+"' " + Enter
	TcSqlExec(cSQL)
	
	IF nSaldo == 0
		Exit
	ENDIF
	
	DbSelectArea("QRY")
	DbSkip()
END

IF nSaldo > 0
	MSGBOX("Não foi possível baixar o saldo informado ficando um resíduo de: R$ "+STR(nSaldo,2),"STOP")
ENDIF

IF !lPassei
	MSGBOX("Não foi encontrado nenhum registro de comissão de acordo com os parâmetros informados!","STOP")
ELSE
	MSGBOX("Alteração realizada com sucesso!")
ENDIF

// Rotina implementada por Marcos Alberto Soprani em 30/01/13 para atender ao projeto PROVISÃO DE COMISSÃO.
If MsgNOYES("Deseja efetuar a contabilização deste AJUSTE NA COMISSÃO?")
	
	fgLanPad := "C01"
	fgLotCtb := "007777"
	fgVetCtb := {}
	fgPermDg := .T.
	
	AQ004 := " SELECT E3_NUM,
	AQ004 += "        E3_PREFIXO,
	AQ004 += "        E3_VEND,
	AQ004 += "        E3_COMIS,
	AQ004 += "        E3_YVLEMP1
	AQ004 += "   FROM " + RetSqlName("SE3")
	AQ004 += "  WHERE E3_FILIAL = '"+xFilial("SE3")+"'
	AQ004 += "    AND E3_VEND = '"+MV_PAR01+"'
	AQ004 += "    AND E3_EMISSAO BETWEEN '"+dtos(MV_PAR02)+"' AND '"+dtos(MV_PAR03)+"'
	AQ004 += "    AND E3_DATA = '        '
	AQ004 += "    AND E3_YVLEMP1 <> 0
	AQ004 += "    AND D_E_L_E_T_ = ' '
	AQ004 += "  ORDER BY E3_NUM
	TCQUERY AQ004 New Alias "AQ04"
	dbSelectArea("AQ04")
	dbGoTop()
	While !Eof()
		
		// A definição da classe de valor deve estar sempre em conformidade com a rotina BCt5ClVl.
		// Qualquer alteralção feita aqui deverá refletir lá e vice-versa
		xcCLVL := ""
		If cEmpAnt == "01"
			xcCLVL := "2100"
			
			If AQ04->E3_VEND == "200005"
				xcCLVL := "2113"
			EndIf
			
		ElseIf cEmpAnt == "05"
			If AQ04->E3_PREFIXO == "1  "
				xcCLVL := "2200"
			ElseIf AQ04->E3_PREFIXO == "2  "
				xcCLVL := "2210"
			EndIf
			
		ElseIf cEmpAnt == "07"
			/*If AQ04->E3_PREFIXO == "1  "
			xcCLVL := "2100"
			ElseIf AQ04->E3_PREFIXO == "2  "
			xcCLVL := "2200"
			ElseIf AQ04->E3_PREFIXO == "3  "
			xcCLVL := "2210"
			EndIf
			*/
			
			//(Thiago Dantas - 25/02/15) -> OS 0866-15
			If AllTrim(AQ04->E3_PREFIXO) == "1"
				xcCLVL := "2150"
				
				//Ticket 26656 - Solicitação Jean: Venda na empresa LM filial 05 será lançada na CV 2302
				if(cFilAnt == "05")
					xcCLVL := "2302"
				endif
				
			// Por Marcos Alberto Soprani - OS 2708-15 em 18/08/15
			ElseIf AllTrim(AQ04->E3_PREFIXO) $ "2_4"
				xcCLVL := "2250"
			ElseIf AllTrim(AQ04->E3_PREFIXO) $ "3"
				xcCLVL := "2251"
			EndIf
			
		ElseIf cEmpAnt == "14"
			
			xcCLVL := "2500"
			
		EndIf
		
		// Vetor ==>> Debito, Credito, ClVl_D, ClVl_C, Item_Contab_D, Item_Contab_C, Valor, Histórico
		If AQ04->E3_COMIS > AQ04->E3_YVLEMP1
			Aadd(fgVetCtb, { "31403001", "21106003", xcCLVL, xcCLVL, "", "COM"+AQ04->E3_VEND, AQ04->E3_COMIS-AQ04->E3_YVLEMP1, "AJUSTE PROV COMIS S/ NF "+AQ04->E3_PREFIXO+AQ04->E3_NUM })
		Else
			Aadd(fgVetCtb, { "21106003", "31403001", xcCLVL, xcCLVL, "COM"+AQ04->E3_VEND, "", AQ04->E3_YVLEMP1-AQ04->E3_COMIS, "AJUSTE EXCL. PROV COMIS S/ NF "+AQ04->E3_NUM })
		EndIf
		
		dbSelectArea("AQ04")
		dbSkip()
	End
	AQ04->(dbCloseArea())
	
	U_BiaCtbAV(fgLanPad, fgLotCtb, fgVetCtb, fgPermDg)
	
EndIf

Return()
