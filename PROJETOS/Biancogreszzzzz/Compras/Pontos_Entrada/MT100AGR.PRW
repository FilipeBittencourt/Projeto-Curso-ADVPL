#include "rwmake.ch"
#include "topconn.ch"

User Function MT100AGR()

	SetPrvt("WDOC,WSERIE,WFORNECE,WLOJA,CLVL,CCONTRATO")
	SetPrvt("CARQSE2,CINDSE2,CREGSE2,AAREA")
	SetPrvt("CARQSD1,CINDSD1,CREGSD1")

	aArea    := GetArea()
	wAlias   := Alias()
	wDoc     := SF1->F1_DOC		     // Numero da Nota Fiscal
	wSerie   := SF1->F1_SERIE	     // Serie da Nota Fiscal
	wFornece := SF1->F1_FORNECE    // Fornecedor da Nota Fiscal
	wLoja    := SF1->F1_LOJA 	     // Loja do Fornecedor
	kt_Espec := SF1->F1_ESPECIE    // Especie da Nota Fiscal
	kt_ChvNf := SF1->F1_CHVNFE     // Chave da Nota fiscal Eletrônica

	IF cEmpAnt <> '02'

		//Realiza o Rateio de acordo com as notas fiscais de entrada.
		cQuery := "SELECT "
		cQuery := cQuery + "  D1_FILIAL, D1_SERIE, D1_DOC, D1_FORNECE, D1_LOJA, D1_CLVL, D1_CC, D1_YCONTR, SUM(D1_TOTAL) AS D1_TOTAL"
		cQuery := cQuery + "  FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF4")+" SF4 "
		cQuery := cQuery + "  WHERE D1_FILIAL    = '"+xFilial("SD1")+"' "
		cQuery := cQuery + "  AND D1_SERIE       = '"+wSerie+"' "
		cQuery := cQuery + "  AND D1_DOC         = '"+wDoc+"' "
		cQuery := cQuery + "  AND D1_FORNECE     = '"+wFornece+"' "
		cQuery := cQuery + "  AND D1_LOJA        = '"+wLoja+"' "
		cQuery := cQuery + "  AND D1_TES         = F4_CODIGO "
		cQuery := cQuery + "  AND F4_DUPLIC      = 'S' "
		cQuery := cQuery + "  AND D1_YCONTR      <> '' "
		cQuery := cQuery + "  AND SD1.D_E_L_E_T_ = ' ' "
		cQuery := cQuery + "  AND SF4.D_E_L_E_T_ = ' ' "
		cQuery := cQuery + "  GROUP BY D1_FILIAL, D1_SERIE, D1_DOC, D1_FORNECE, D1_LOJA, D1_CLVL, D1_CC, D1_YCONTR "
		cQuery := cQuery + "  ORDER BY D1_FILIAL, D1_SERIE, D1_DOC, D1_FORNECE, D1_LOJA, D1_CLVL, D1_CC, D1_YCONTR "

		TCQUERY cQuery ALIAS "QRY1" NEW

		DbSelectArea("QRY1")
		DbGotop()

		While !EOF()

			//Busca total da NF para rateio do ZZR
			nTotalNF := SF1->F1_VALMERC

			cQuery := "SELECT "
			cQuery := cQuery + "  E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VALOR "
			cQuery := cQuery + "  FROM "+RetSqlName("SE2")+" SE2 "
			cQuery := cQuery + "  WHERE	E2_FILIAL    = '"+QRY1->D1_FILIAL+"' "
			cQuery := cQuery + "  AND E2_PREFIXO     = '"+QRY1->D1_SERIE+"' "
			cQuery := cQuery + "  AND E2_NUM         = '"+QRY1->D1_DOC+"' "
			cQuery := cQuery + "  AND E2_FORNECE     = '"+QRY1->D1_FORNECE+"' "
			cQuery := cQuery + "  AND E2_LOJA        = '"+QRY1->D1_LOJA+"' "
			cQuery := cQuery + "  AND E2_TIPO        = 'NF' "
			cQuery := cQuery + "  AND SE2.D_E_L_E_T_ = ' ' "
			cQuery := cQuery + "  ORDER BY E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA "

			TCQUERY cQuery ALIAS "QRY3" NEW

			DbSelectArea("QRY3")

			While !EOF()

				DbSelectArea("ZZR")
				DbSetOrder(1)
				IF !DbSeek(xFilial("ZZR")+QRY3->E2_PREFIXO+QRY3->E2_NUM+QRY3->E2_PARCELA+QRY3->E2_TIPO+QRY3->E2_FORNECE+QRY3->E2_LOJA+QRY1->D1_CLVL+QRY1->D1_CC+QRY1->D1_YCONTR)
					RecLock("ZZR",.T.)
					ZZR->ZZR_FILIAL := xFilial("ZZR")
					ZZR->ZZR_PREF   := QRY3->E2_PREFIXO
					ZZR->ZZR_NUM    := QRY3->E2_NUM
					ZZR->ZZR_PARC   := QRY3->E2_PARCELA
					ZZR->ZZR_TIPO   := QRY3->E2_TIPO
					ZZR->ZZR_FORNEC := QRY3->E2_FORNECE
					ZZR->ZZR_LOJA   := QRY3->E2_LOJA
					ZZR->ZZR_CC     := QRY1->D1_CC
					ZZR->ZZR_CLVL   := QRY1->D1_CLVL
					ZZR->ZZR_CONTR  := QRY1->D1_YCONTR
					ZZR->ZZR_RATEIO := QRY1->D1_TOTAL / nTotalNF * 100
					MsUnLock("ZZR")
				ENDIF

				cQuery := "SELECT "
				cQuery := cQuery + "  E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VALOR, E2_TITPAI "
				cQuery := cQuery + "  FROM "+RetSqlName("SE2")+" SE2 "
				cQuery := cQuery + "  WHERE E2_TITPAI      = '"+QRY3->E2_PREFIXO+QRY3->E2_NUM+QRY3->E2_PARCELA+QRY3->E2_TIPO+QRY3->E2_FORNECE+QRY3->E2_LOJA+"' "
				cQuery := cQuery + "  AND SE2.D_E_L_E_T_ = ' ' "

				TCQUERY cQuery ALIAS "QRY4" NEW

				DbSelectArea("QRY4")

				While !EOF()

					DbSelectArea("ZZR")
					DbSetOrder(1)
					IF !DbSeek(xFilial("ZZR")+QRY4->E2_PREFIXO+QRY4->E2_NUM+QRY4->E2_PARCELA+QRY4->E2_TIPO+QRY4->E2_FORNECE+QRY4->E2_LOJA+QRY1->D1_CLVL+QRY1->D1_CC+QRY1->D1_YCONTR)
						RecLock("ZZR",.T.)
						ZZR->ZZR_FILIAL := xFilial("ZZR")
						ZZR->ZZR_PREF   := QRY4->E2_PREFIXO
						ZZR->ZZR_NUM    := QRY4->E2_NUM
						ZZR->ZZR_PARC   := QRY4->E2_PARCELA
						ZZR->ZZR_TIPO   := QRY4->E2_TIPO
						ZZR->ZZR_FORNEC := QRY4->E2_FORNECE
						ZZR->ZZR_LOJA   := QRY4->E2_LOJA
						ZZR->ZZR_CC     := QRY1->D1_CC
						ZZR->ZZR_CLVL   := QRY1->D1_CLVL
						ZZR->ZZR_CONTR  := QRY1->D1_YCONTR
						ZZR->ZZR_RATEIO := QRY1->D1_TOTAL / nTotalNF * 100
						MsUnLock("ZZR")
					ENDIF

					DbSelectArea("QRY4")
					DbSkip()
				END

				DbCloseArea("QRY4")

				DbSelectArea("QRY3")
				DbSkip()
			END

			DbCloseArea("QRY3")

			DbSelectArea("QRY1")
			DbSkip()

		END

		DbCloseArea("QRY1")

	ENDIF

	//DESATIVADO EM 23/10/17 POR RANISSES - NÃO É REALIZADO O CALCULO DO MC1
	//EXECUTAR STORED PROCEDURE PARA CALCULO DO D1_YMC1 - FERNANDO ROCHA - 04/11/2010
	//IF (cEmpAnt $ "01#05#07") .AND. TCSPEXIST("GMR_UPD_MC")
	//	_cChaveD1 = SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	//	TCSPEXEC("GMR_UPD_MC",cEmpAnt,DTOS(SF1->F1_DTDIGIT),DTOS(SF1->F1_DTDIGIT),"E",_cChaveD1)
	//ENDIF

	//Fernando/Facile em 04/02/2015 - Gravar o campo D1_OP para entrada de NFs VITCER
	If INCLUI .OR. ALTERA
		U_FOPVCR02()
	EndIf

Return()
