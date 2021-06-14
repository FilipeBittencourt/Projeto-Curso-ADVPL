#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF140
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Função para gravacoes adicionais apos o confirmacao do fornecedor  
@obs Ticket: 21359
@type function
/*/

User Function BIAF140(nOpc)

	RecLock('SA2', .F.)

	SA2->A2_NOME := U_fDelTab(SA2->A2_NOME)
	SA2->A2_NREDUZ := U_fDelTab(SA2->A2_NREDUZ)
	SA2->A2_NUMCON := U_fDelTab(SA2->A2_NUMCON)
	SA2->A2_END := U_fDelTab(SA2->A2_END)
	SA2->A2_TEL := U_fDelTab(SA2->A2_TEL)
	SA2->A2_TELEX	:= U_fDelTab(SA2->A2_TELEX)
	SA2->A2_FAX := U_fDelTab(SA2->A2_FAX)
	SA2->A2_CONTATO	:= U_fDelTab(SA2->A2_CONTATO)
	SA2->A2_EMAIL	:= U_fDelTab(SA2->A2_EMAIL)
	SA2->A2_HPAGE	:= U_fDelTab(SA2->A2_HPAGE)
	SA2->A2_COMPLEM	:= U_fDelTab(SA2->A2_COMPLEM)

	If nOpc == 3

		SA2->A2_YUSER := cUserName

	EndIf

	If Substr(SA2->A2_COD, 1, 1) $ '1234567890'

		If cEmpAnt <> "02"

			If  AllTrim(SA2->A2_CONTA) <> '21102001' + AllTrim(SA2->A2_COD)

				SA2->A2_CONTA := '21102001' + AllTrim(SA2->A2_COD)

				MsgInfo("Conta contabil informada incorretamente! O sistema realizara a correção automaticamente", "BIAF140", "INFO")

			EndIf

		EndIf

	EndIf


	SA2->(MsUnLock())

	fAddCTB()

	fSendWF()

Return()


// Adiciona informacoes contabeis
Static Function fAddCTB()
	Local cCodRe  := ""
	Local cVersao := "A"

	DbSelectArea("CT1")
	CT1->(DbSetOrder(2))
	CT1->(DbGoBottom())
	cCodRe := Soma1(CT1->CT1_RES)

	CT1->(dbSetOrder(1))
	If !CT1->(dbSeek(xFilial('CT1') + SA2->A2_CONTA))

		RecLock("CT1", .T.)

		CT1->CT1_FILIAL := xFilial("CT1")
		CT1->CT1_CONTA := SA2->A2_CONTA
		CT1->CT1_DESC01 := SA2->A2_NOME
		CT1->CT1_CLASSE := "2"
		CT1->CT1_NORMAL := "2"
		CT1->CT1_BLOQ := "2"
		CT1->CT1_RES := cCodRe

		If cEmpAnt == "02"

			CT1->CT1_CTASUP := "21101"

		Else

			CT1->CT1_CTASUP := "21102001"

		EndIf

		CT1->CT1_GRUPO := "2"
		CT1->CT1_CVD02 := "5"
		CT1->CT1_CVD03 := "5"
		CT1->CT1_CVD04 := "5"
		CT1->CT1_CVD05 := "5"
		CT1->CT1_CVC02 := "5"
		CT1->CT1_CVC03 := "5"
		CT1->CT1_CVC04 := "5"
		CT1->CT1_CVC05 := "5"
		CT1->CT1_DC := CTBDIGCONT(CT1->CT1_CONTA)
		CT1->CT1_BOOK := "001"
		CT1->CT1_CCOBRG	:= "2"
		CT1->CT1_ITOBRG	:= "2"
		CT1->CT1_CLOBRG	:= "2"
		CT1->CT1_LALUR := "0"
		CT1->CT1_DTEXIS	:= dDataBase
		CT1->CT1_INDNAT	:= "2"
		CT1->CT1_NTSPED	:= "02"
		CT1->CT1_SPEDST	:= "2"

		CT1->(MsUnLock())

		sPlRef := "001   "
		sCtRef := "2.01.01.01.00"

		DbSelectArea("CVN")
		CVN->(dbSetOrder(2))
		CVN->(dbSeek(xFilial('CVN') + sPlRef + sCtRef))

		DbSelectArea("CVD")
		CVD->(dbSetOrder(2))
		If !CVD->(dbSeek(xFilial('CVD')+sPlRef+sCtRef+SA2->A2_CONTA))

			RecLock("CVD", .T.)
			CVD->CVD_FILIAL	:= XFILIAL("CVD")
			CVD->CVD_ENTREF	:= CVN->CVN_ENTREF
			CVD->CVD_CODPLA	:= CVN->CVN_CODPLA
			CVD->CVD_CONTA	:= SA2->A2_CONTA
			CVD->CVD_CTAREF	:= CVN->CVN_CTAREF
			CVD->CVD_YDESC	:= CVN->CVN_DSCCTA
			CVD->CVD_TPUTIL	:= CVN->CVN_TPUTIL
			CVD->CVD_CLASSE	:= CVN->CVN_CLASSE
			CVD->CVD_NATCTA	:= CVN->CVN_NATCTA
			CVD->CVD_CTASUP	:= CVN->CVN_CTASUP
			CVD->CVD_VERSAO := cVersao
			CVD->(MsUnLock())

		EndIf

		sPlRef := "002   "
		sCtRef := "2.01.01.03.01"

		DbSelectArea("CVN")
		CVN->(dbSetOrder(2))
		CVN->(dbSeek(xFilial('CVN')+sPlRef+sCtRef))

		DbSelectArea("CVD")
		CVD->(dbSetOrder(2))
		If !CVD->(dbSeek(xFilial('CVD')+sPlRef+sCtRef+SA2->A2_CONTA))

			RecLock("CVD", .T.)
			CVD->CVD_FILIAL	:= XFILIAL("CVD")
			CVD->CVD_ENTREF	:= CVN->CVN_ENTREF
			CVD->CVD_CODPLA	:= CVN->CVN_CODPLA
			CVD->CVD_CONTA	:= SA2->A2_CONTA
			CVD->CVD_CTAREF	:= CVN->CVN_CTAREF
			CVD->CVD_YDESC	:= CVN->CVN_DSCCTA
			CVD->CVD_TPUTIL	:= CVN->CVN_TPUTIL
			CVD->CVD_CLASSE	:= CVN->CVN_CLASSE
			CVD->CVD_NATCTA	:= CVN->CVN_NATCTA
			CVD->CVD_CTASUP	:= CVN->CVN_CTASUP
			CVD->CVD_VERSAO := cVersao
			CVD->(MsUnLock())

		EndIf

	EndIf

Return()


Static Function fSendWF()
	Local cHtml := ""

	If Empty(SA2->A2_CONTA)

		cHtml := '<html xmlns="http://www.w3.org/1999/xhtml">'
		cHtml += '<head>'
		cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
		cHtml += '<title>Inclusão de Fornecedor sem Conta Contábil</title>'
		cHtml += '</head>'
		cHtml += '<body>'
		cHtml += '	<p>Inclusão de Fornecedor sem Conta Contábil</p>'
		cHtml += '  <p>Fornecedor: </p>'
		cHtml += '	<p>Código: ' + AllTrim(SA2->A2_COD) + '</p>'
		cHtml += '	<p>Razão Social: ' + AllTrim(SA2->A2_NOME) + '</p>'
		cHtml += '	<p>Nome Fantasia: ' + AllTrim(SA2->A2_NREDUZ) + '</p>'
		cHtml += '	<p>&nbsp;</p>'
		cHtml += '  <p>by Protheus (MT20FOPOS)</p>'
		cHtml += '</body>'
		cHtml += '</html>'

		U_BIAEnvMail(, U_EmailWF('MT20FOPOS', cEmpAnt , xCLVL), "Inclusão de Fornecedor sem Conta Contábil", cHtml)

	EndIf

Return()
