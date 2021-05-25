#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TContaContabil
@author Wlysses Cerqueira (Facile)
@since 04/07/2019
@project Automação Financeira
@version 1.0
@description 
@type class
/*/

#DEFINE NPOSCONTA	1
#DEFINE NPOSCTARF	2
#DEFINE NPOSCLASSE	3

Class TContaContabil From LongClassName

	Method New() Constructor
	Method SetContContab(cCad, cCliFor, cLoja, cTipo)
	Method CreateConta(cCad)

EndClass

Method New() Class TContaContabil

Return()

Method SetContContab(cCad, cCliFor, cLoja, cTipo) Class TContaContabil

	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaSA2 := SA2->(GetArea())
	Local cContConta := ""

	Default cCad := ""
	Default cCliFor := ""
	Default cLoja := ""
	Default cTipo := ""

	If cCad == "C" .And. cTipo $ MVRECANT

		DBSelectArea("SA1")
		SA1->(DBSetOrder(1)) // A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_

		If SA1->(DBSeek(xFilial("SA1") + cCliFor + cLoja))

			If Empty(SA1->A1_YCTAADI)

				cContConta := ::CreateConta(cCad)

				RecLock("SA1", .F.)
				SA1->A1_YCTAADI := cContConta
				SA1->(MsUnlock())

			Else

				cContConta := SA1->A1_YCTAADI

			EndIf

		EndIf

	EndIf

	If cCad == "F" .And. cTipo $ MVPAGANT

		DBSelectArea("SA2")
		SA2->(DBSetOrder(1)) // A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_

		If SA2->(DBSeek(xFilial("SA2") + cCliFor + cLoja))

			If Empty(SA2->A2_YCTAADI)

				cContConta := ::CreateConta(cCad)

				RecLock("SA2", .F.)
				SA2->A2_YCTAADI := cContConta
				SA2->(MsUnlock())

			Else

				cContConta := SA2->A2_YCTAADI

			EndIf

		EndIf

	EndIf

	RestArea(aAreaSA1)
	RestArea(aAreaSA2)

Return(cContConta)

Method CreateConta(cCad) Class TContaContabil

	Local aAreaCT1 := CT1->(GetArea())
	Local aAreaCVD := CVD->(GetArea())
	Local aAreaCVN := CVN->(GetArea())

	Local nW := 0
	Local cDescRef := ""
	Local xCodRe := ""
	Local cContConta := ""
	Local cContaRef := ""
	Local cClasse := ""
	Local aConta := {}

	Default cCad := ""

	DbSelectArea("CT1")
	CT1->(DBSetOrder(2)) // CT1_FILIAL, CT1_RES, R_E_C_N_O_, D_E_L_E_T_
	CT1->(DbGoBottom())

	xCodRe := Soma1(CT1->CT1_RES)

	DbSelectArea("CT1")
	CT1->(DBSetOrder(1)) // CT1_FILIAL, CT1_CONTA, R_E_C_N_O_, D_E_L_E_T_

	If cCad == "C"

		aConta := {{"21108980", "2.01.01.05", "1"}, {"21108980" + SA1->A1_COD, "2.01.01.05.01", "2"}}

		For nW := 1 To Len(aConta)

			cContConta := aConta[nW][NPOSCONTA]
			cContaRef := aConta[nW][NPOSCTARF]
			cClasse := aConta[nW][NPOSCLASSE]

			If !CT1->(DBSeek(xFilial("CT1") + cContConta))

				RecLock("CT1",.T.)
				CT1->CT1_FILIAL		:= xFilial("CT1")
				CT1->CT1_CONTA		:= cContConta
				CT1->CT1_DESC01		:= SA1->A1_NOME
				CT1->CT1_CLASSE		:= cClasse
				CT1->CT1_NORMAL		:= "2"
				CT1->CT1_BLOQ 		:= "2"
				CT1->CT1_RES    	:= xCodRe
				CT1->CT1_NATCTA   	:= "02"
				CT1->CT1_CTASUP   	:= "21108980"
				CT1->CT1_GRUPO		:= "2"
				CT1->CT1_CVD02		:= "5"
				CT1->CT1_CVD03		:= "5"
				CT1->CT1_CVD04		:= "5"
				CT1->CT1_CVD05		:= "5"
				CT1->CT1_CVC02   	:= "5"
				CT1->CT1_CVC03   	:= "5"
				CT1->CT1_CVC04   	:= "5"
				CT1->CT1_CVC05   	:= "5"
				CT1->CT1_DC			:= CTBDIGCONT(CT1->CT1_CONTA)
				CT1->CT1_BOOK		:= "001"
				CT1->CT1_CCOBRG		:= "2"
				CT1->CT1_ITOBRG		:= "2"
				CT1->CT1_CLOBRG		:= "2"
				CT1->CT1_LALUR		:= "0"
				CT1->CT1_DTEXIS		:= dDataBase
				CT1->CT1_INDNAT		:= "2"
				CT1->CT1_NTSPED		:= "02"
				CT1->CT1_SPEDST		:= "2"
				CT1->(MsUnlock())

				DBSelectArea("CVN")
				CVN->(DBSetOrder(2)) // CVN_FILIAL, CVN_CODPLA, CVN_CTAREF, CVN_VERSAO, R_E_C_N_O_, D_E_L_E_T_

				If CVN->(DBSeek(xFilial("CVN") + "002   " + cContaRef))

					cDescRef := CVN->CVN_DSCCTA

				EndIf

				RecLock("CVD",.T.)
				CVD->CVD_FILIAL	:= xFilial("CVD")
				CVD->CVD_ENTREF	:= "10"
				CVD->CVD_CODPLA	:= "002"
				CVD->CVD_YDESC	:= cDescRef
				CVD->CVD_CONTA	:= cContConta
				CVD->CVD_CTAREF	:= cContaRef
				CVD->CVD_VERSAO := "0001"
				CVD->(MsUnlock())

			EndIf

		Next nW

	EndIf

	If cCad == "F"

		aConta := {{"11202980", "1.01.02.01", "1"}, {"11202980" + SA2->A2_COD, "1.01.02.01.01", "2"}}

		For nW := 1 To Len(aConta)

			cContConta := aConta[nW][NPOSCONTA]
			cContaRef := aConta[nW][NPOSCTARF]
			cClasse := aConta[nW][NPOSCLASSE]

			If !CT1->(DBSeek(xFilial("CT1") + cContConta))

				RecLock("CT1",.T.)
				CT1->CT1_FILIAL		:= xFilial("CT1")
				CT1->CT1_CONTA		:= cContConta
				CT1->CT1_DESC01		:= SA2->A2_NOME
				CT1->CT1_CLASSE		:= cClasse
				CT1->CT1_NORMAL		:= "1"
				CT1->CT1_BLOQ 		:= "2"
				CT1->CT1_RES    	:= xCodRe
				CT1->CT1_CTASUP   	:= "11202980"
				CT1->CT1_NATCTA   	:= "01"
				CT1->CT1_GRUPO   	:= "1"
				CT1->CT1_CVD02   	:= "5"
				CT1->CT1_CVD03   	:= "5"
				CT1->CT1_CVD04   	:= "5"
				CT1->CT1_CVD05   	:= "5"
				CT1->CT1_CVC02   	:= "5"
				CT1->CT1_CVC03   	:= "5"
				CT1->CT1_CVC04   	:= "5"
				CT1->CT1_CVC05   	:= "5"
				CT1->CT1_DC			:= CTBDIGCONT(CT1->CT1_CONTA)
				CT1->CT1_BOOK		:= "001"
				CT1->CT1_CCOBRG		:= "2"
				CT1->CT1_ITOBRG		:= "2"
				CT1->CT1_CLOBRG		:= "2"
				CT1->CT1_LALUR		:= "0"
				CT1->CT1_DTEXIS		:= dDataBase
				CT1->CT1_INDNAT		:= "1"
				CT1->CT1_NTSPED		:= "01"
				CT1->CT1_SPEDST		:= "2"
				CT1->(MsUnlock())

				DBSelectArea("CVN")
				CVN->(DBSetOrder(2)) // CVN_FILIAL, CVN_CODPLA, CVN_CTAREF, CVN_VERSAO, R_E_C_N_O_, D_E_L_E_T_

				If CVN->(DBSeek(xFilial("CVN") + "002   " + cContaRef))

					cDescRef := CVN->CVN_DSCCTA

				EndIf

				RecLock("CVD",.T.)
				CVD->CVD_FILIAL	:= xFilial("CVD")
				CVD->CVD_ENTREF	:= "10"
				CVD->CVD_CODPLA	:= "002"
				CVD->CVD_YDESC	:= cDescRef
				CVD->CVD_CONTA	:= cContConta
				CVD->CVD_CTAREF	:= cContaRef
				CVD->CVD_VERSAO := "0001"
				CVD->(MsUnlock())

			EndIf

		Next nW

	EndIf

	RestArea(aAreaCT1)
	RestArea(aAreaCVN)
	RestArea(aAreaCVD)

Return(cContConta)