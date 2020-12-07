#include "rwmake.ch"

/*/{Protheus.doc} BIA916
@author RANISSES A. CORONA
@since 24/09/03
@version 1.0
@description Determina que nao pode ter quantidade quebrada na Mov.Interno
@obs Em 09/03/17... Por Marcos Alberto Soprani ajuste em atendimento a OS effettivo 0889-17
@type function
/*/

User Function BIA916()

	//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO
	IF Type("_IViaEAuto") <> "U"
		Return(M->D3_QUANT)
	ENDIF

	//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA241
	If Type("_ExecAutoII") <> "U"
		Return(Gdfieldget("D3_QUANT",n))
	EndIf

	//Por Marcos Alberto Soprani em 25/05/12 para atender a integração com o programa BIA292 quando executado via Schedule
	If Type("_ExcAut292") <> "U"
		Return(M->D3_QUANT)
	EndIf

	IF IsInCallStack("MATA250") //Alltrim(funname())=="MATA250"
		Return(M->D3_QUANT)
	ENDIF

	// Incluida regra por Marcos Alberto em 24/08/11 para atender o apontamento automático de Esmalte
	If Upper(Alltrim(funname())) $ "BIA257/BIA271/MATA240/BIA292/BIA294/BIA701/BIA742/BIA785/BIA570" .Or. IsInCallsTack("U_BIAFG120")
		Return(M->D3_QUANT)
	EndIf

	// Incluida regra por Marcos Alberto em 28/02/14. Ajustada em 09/03/17 - OS 0889-17
	If __cUserID $ "000553/000605/000974/000821/001331/000067"
		Return(M->D3_QUANT)
	EndIf

	// Em 01/08/18, liberado que os movimentos de C1 do local 07 permita quantidade fracionada. Por Marcos Alberto Soprani
	If Upper(Alltrim(funname())) $ "MATA241/MATA242"
		If Substr(Gdfieldget("D3_COD",n),1,2) == "C1" .and. Gdfieldget("D3_LOCAL",n) == "07"
			Return(Gdfieldget("D3_QUANT",n))
		EndIf
	EndIf

	// Em 14/08/18, liberado que os movimentos de C1 do local 07 permita quantidade fracionada. Por Marcos Alberto Soprani
	If Upper(Alltrim(funname())) $ "MATA261"
		Return(Gdfieldget("D3_QUANT",n))
	EndIf

	// Implementado tratamento para aceitar quantidade de caixa fracionada em 24/01/14 por Marcos Alberto Soprani quando for material de amostra.
	If Upper(Alltrim(funname())) $ "MATA241/MATA242"
		If Gdfieldget("D3_LOCAL",n) == "05"
			Return(Gdfieldget("D3_QUANT",n))
		EndIf
	EndIf

	// Implementado tratamento para aceitar quantidade fracionada para empresa JK - Projeto Jazidas
	If cEmpAnt == "06"
		Return(Gdfieldget("D3_QUANT",n))
	EndIf

	wAlias   := Alias()
	wnProduto:= ""      // Produto
	wnQtdven := 0       // Retorno da Qtde Vendida
	wnQtdOrig:= 0       // Qtde Orignal
	wnUnsven := 0       // Qtde na Segunda Unidade de Medida
	wxInteiro:= 0       // Total Interio
	wxDecimal:= 0       // Total Decimal
	yyn      := n

	wnProduto	:= Gdfieldget("D3_COD"     ,yyn)
	wnQtdven	:= Gdfieldget("D3_QUANT"   ,yyn)
	wnQtdOrig	:= Gdfieldget("D3_QUANT"   ,yyn)
	wnUnsven	:= Gdfieldget("D3_QTSEGUM" ,yyn)

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+wnProduto,.T.)

	IF SUBSTR(SB1->B1_COD,4,4) <> '0000'
		If AllTrim(wnProduto) <> "0000C500" .And. AllTrim(wnProduto) <> "0000C700" .And. AllTrim(wnProduto) <> "0000C800"

			If SB1->B1_TIPCONV == "D"
				wnUnsven:= (wnQtdven / SB1->B1_CONV)
			Else
				wnUnsven:= (wnQtdven * SB1->B1_CONV)
			EndIf

			If SB1->B1_TIPO == "PA"
				wxInteiro := INT(wnUnsven)
				wxDecimal := (wnUnsven - INT(wnUnsven))

				If wxDecimal == 0
					wnQtdven	:= Gdfieldget("D3_QUANT",yyn)
				Else
					wnUnsven := wxInteiro + 1
					If SB1->B1_TIPCONV == "D"
						wnQtdven := (wnUnsven * SB1->B1_CONV)
					Else
						wnQtdven := (wnUnsven / SB1->B1_CONV)
					EndIf
				EndIf
			EndIf

			Gdfieldput("D3_QTSEGUM",wnUnsven,yyn)
			Gdfieldput("D3_QUANT",wnQtdven,yyn)

			If wnQtdven <> wnQtdOrig
				MsgAlert("Quantidade Original na 1a. Unidade: "+str(wnQtdOrig,10,2)+", alterada para "+str(wnQtdven,10,2),"BIA916")
			EndIf

		EndIf

	ENDIF

Return(wnQtdven)
