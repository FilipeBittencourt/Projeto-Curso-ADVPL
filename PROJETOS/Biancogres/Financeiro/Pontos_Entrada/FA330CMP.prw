#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TContaContabil
@author Wlysses Cerqueira (Facile)
@since 15/07/2019
@project Automação Financeira
@version 1.0
@description 
@type class
/*/

User Function FA330CMP()

	Local oContaCont := TContaContabil():New()
	Local nPos := 0
	Local nW := 0
	Local cCliente := ""
	Local cLoja := ""
	Local cTipo := ""
	Local cMail :=  "filipe.bittencourt@facilesistemas.com.br;nadine.araujo@biancogres.com.br"
	Local cHtml := ""


	For nW := 1 To Len(aTitulos)

		If aTitulos[nW][8]

			nPos := Rat("-", aTitulos[nW][10])

			If nPos > 0 // Compensacao com RA de outro cliente

				cCliente   := SubStr(aTitulos[nW][10], 1, nPos - 1)
				cLoja      := SubStr(aTitulos[nW][10], nPos + 1)
				cTipo      := aTitulos[nW][4]
				cCContabil := oContaCont:SetContContab("C", cCliente, cLoja, cTipo)
				//oContaCont:SetContContab("C", SubStr(aTitulos[nW][10], 1, nPos - 1), SubStr(aTitulos[nW][10], nPos + 1), aTitulos[nW][4])

			Else

				cCliente   := SE1->E1_CLIENTE
				cLoja      := SE1->E1_LOJA
				cTipo      := aTitulos[nW][4]
				cCContabil := oContaCont:SetContContab("C", cCliente, cLoja, cTipo)
				//oContaCont:SetContContab("C", SE1->E1_CLIENTE, SE1->E1_LOJA, aTitulos[nW][4])

			EndIf


			If EMPTY(cCContabil) //ticket - https://suporteti.biancogres.com.br/Ticket/Edit/32125
				cHtml := " <html>"
				cHtml += " <body>"
				cHtml += " Empresa: "+AllTrim(SM0->M0_NOME)+" - "+AllTrim(SM0->M0_CODIGO)+"/"+AllTrim(SM0->M0_CODFIL)+" <br />"
				cHtml += " Cliente: "+cCliente+" - "+cLoja+" <br />"
				cHtml += " Motivo.: Conta Contábil não foi criada <br />"
				cHtml += " </body>"
				cHtml += " </html>"
				U_BIAEnvMail(,cMail,'Erro na Rotina Automatica de Compensação de Titulos (FA330CMP)',cHtml)
			EndIf

		EndIf

	Next nW

Return()

User Function BF330CMP()

	Local cConta := ""
	Local aAreaSA1 := SA1->(GetArea())

	If PARAMIXB[1] == 1 // Inclusao da compensacao - Debito

		DBSelectArea("SA1")
		SA1->(DBSetOrder(1)) // A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_

		If SA1->(DBSeek(xFilial("SA1") + SE5->E5_CLIFOR + SE5->E5_LOJA))

			cConta := SA1->A1_YCTAADI

		EndIf

	ElseIf PARAMIXB[1] == 2 // Inclusao da compensacao - Credito

		If SA1->A1_EST == "EX"

			cConta := "11201002"
		Else

			cConta := SA1->A1_CONTA

		EndIf

	ElseIf PARAMIXB[1] == 3 // Estorno da compensacao - Debito

		DBSelectArea("SA1")
		SA1->(DBSetOrder(1)) // A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_

		If SA1->(DBSeek(xFilial("SA1") + SE5->E5_CLIFOR + SE5->E5_LOJA))

			cConta := SA1->A1_CONTA

		EndIf

	ElseIf PARAMIXB[1] == 4 // Estorno da compensacao - Credito

		cConta := SA1->A1_YCTAADI

	EndIf

	RestArea(aAreaSA1)

Return(cConta)