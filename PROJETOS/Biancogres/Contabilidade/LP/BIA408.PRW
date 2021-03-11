#include "rwmake.ch"

/*/{Protheus.doc} BIA408
@author Wanisay William
@since 18/02/08
@version 1.0
@description Ajusta regra 650/001, 655/001, 650/004, 655/004
@type function
/*/

User Function BIA408()

	Private cConta	:= ""
	Private cCodLP  := Paramixb
	Private cCodigo := SPACE(6)
	Private cLoja   := SPACE(2)
	Private cTes    := SPACE(3)
	Private cCFOP   := SPACE(5)
	Private cTpProd := SPACE(2)
	Private cNota := SPACE(9)
	Private cSerie := SPACE(2)

	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0

	Private cArqSD1	:= ""
	Private cIndSD1	:= 0
	Private cRegSD1	:= 0

	Private cArqSA2	:= ""
	Private cIndSA2	:= 0
	Private cRegSA2	:= 0

	Private cArqSB1	:= ""
	Private cIndSB1	:= 0
	Private cRegSB1	:= 0

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SD1")
	cArqSD1 := Alias()
	cIndSD1 := IndexOrd()
	cRegSD1 := Recno()

	DbSelectArea("SD2")
	cArqSD2 := Alias()
	cIndSD2 := IndexOrd()
	cRegSD2 := Recno()

	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()

	IF cCodLP $ '610030_610033'

		cTes     := SD2->D2_TES
		cCodigo  := SD2->D2_CLIENTE
		cLoja    := SD2->D2_LOJA
		cProduto := SD2->D2_COD
		cNfOrig  := SD2->D2_NFORI
		cSeOrig  := SD2->D2_SERIORI
		cItOrig  := SD2->D2_ITEMORI
		cCFOP    := Substr(SD2->D2_CF,2,3)
		cTpProd  := SD2->D2_TP

	ELSE

		cTes    := SD1->D1_TES
		cCodigo := SD1->D1_FORNECE
		cLoja   := SD1->D1_LOJA
		cCFOP   := Substr(SD1->D1_CF,2,3)
		cTpProd := SD1->D1_TP
		cNota := SD1->D1_DOC
		cSerie := SD1->D1_SERIE

	ENDIF

	IF cCodLP $ '650001_655001_610030'
		//Conta Debito
		IF cTes == '201' .AND. SM0->M0_CODIGO == '01' //Definir tambem o TES de devolucao de compras
			DO CASE
				CASE ALLTRIM(Substr(SB1->B1_GRUPO,1,3)) == '204'
				cConta := "21108010"
				CASE ALLTRIM(Substr(SB1->B1_GRUPO,1,3)) == '102'
				cConta := "21108011"
				OTHERWISE
				cConta := "21108012"
			ENDCASE
		ELSE
			IF cCodLP $ '610030'
				DbSelectArea("SD1")
				DbSetOrder(1)
				DbSeek(xFilial("SD1")+cNfOrig+cSeOrig+cCodigo+cLoja+cProduto+cItOrig)
				cConta := SD1->D1_CONTA
			ELSE
				//  Implementado em 20/03/14 por Marcos Alberto Soprani para tratamento de compra
				// de placas cerâmicas para produção própria de rodapé e soleira.
				If cEmpAnt == "14" .and. Alltrim(cCFOP) == "101" .and. cTpProd == "PA"
					cConta := "11304006"
				//Thiago Haagensen - Ticket 29518 - ERRO NA CONTABILIZAÇAO NF DE ENTREGA FUTURA
				Else
					cConta := IIF(ALLTRIM(SD1->D1_CF) $ "1922/2922","16501080",SD1->D1_CONTA) //Para compra e entraga futura cair na conta de adiantamento a fornecedor (Dentro e Fora do estado)
				EndIf
			ENDIF
		ENDIF

		//Fernando/Facile - Ajuste para contratos de verba - LP das notas de debito quando contrato - solicitado pelo JEAN
		IF ( cCodLP $ '650001_655001' .And. RTrim(SD1->D1_ITEMCTA)=="I0202" )

			cConta := U_FCTVLP02(15)

		ENDIF	

	ELSE

		//Conta Credito
		IF cTes == '087' .AND. SM0->M0_CODIGO == '01' //Definir tambem o TES de devolucao de compras

			DO CASE
				CASE ALLTRIM(Substr(SB1->B1_GRUPO,1,3)) == '204'
				cConta := "21108010"
				CASE ALLTRIM(Substr(SB1->B1_GRUPO,1,3)) == '102'
				cConta := "21108011"
				OTHERWISE
				cConta := "21108012"
			ENDCASE

		ELSE

			//|Força o posicionamento na SA2 devido a estar pegando a conta errada em alguns casos |
			If AllTrim(cCodLP) == '610033'
				aAreaSA2	:= SA2->(GetArea())
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2") + SD2->D2_CLIENTE + SD2->D2_LOJA))
				cConta := SA2->A2_CONTA
				RestArea(aAreaSA2)
			Else
				DbSelectArea("SA2")
				cArqSA2 := Alias()
				cIndSA2 := IndexOrd()
				cRegSA2 := Recno()
				//Alterado por Wanisay dia 11/02/09 devido a exclusao de nota fiscal de entrada
				//DbSetOrder(1)
				//DbSeek(xFilial("SA2")+cCodigo+cLoja)
				cConta := SA2->A2_CONTA
			EndIf

		ENDIF

	ENDIF

	If cCodLP $ '660007'

		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4")+SD1->D1_TES)
		// Implementado em 03/06/13 conforme effettivo 0574-13
		If Alltrim(SF1->F1_TIPO) == 'I'
			cConta := SD1->D1_CONTA
		Else
			// Implementado em 03/06/13 conforme effettivo 0232-13
			If Substr(SD1->D1_CF,2,3) $ "911,949,910" .and. SF4->F4_DUPLIC == "N"
				cConta := "41501005"
			EndIf
			//Thiago Haagensen - Ticket 29518 - ERRO NA CONTABILIZAÇAO NF DE ENTREGA FUTURA
			If Substr(SD1->D1_CF,2,3) $ "551/406" .and.  SF4->F4_DUPLIC == "N" //Tratamento para nota fiscal de remessa de venda futura para matar a operacao.
				cConta := "16501080"
			Endif
		EndIf

		// Em 24/08/17... Por Marcos Alberto Soprani... conforme OS effettivo 3096-17
		If SF4->F4_YCCONT == "091"
			cConta := "21113001"
		EndIf
		
		//|Pontin 18.07.18 - OS 6859 |
		If AllTrim(SED->ED_CODIGO) == "2997" //Juros sobre capital proprio 
		
			If AllTrim(SF1->F1_FORNECE) == "004926"
				cConta := "21105001000001"
			ElseIf AllTrim(SF1->F1_FORNECE) == "003198"
				cConta := "21105001000002"
			ElseIf AllTrim(SF1->F1_FORNECE) == "002575"
				cConta := "21105001000003"
			ElseIf AllTrim(SF1->F1_FORNECE) == "004680"
				cConta := "21105001000004"	
			ElseIf AllTrim(SF1->F1_FORNECE) == "000524"
				cConta := "21105001000005"	
			ElseIf AllTrim(SF1->F1_FORNECE) == "003187"
				cConta := "21105001000006"
			ElseIf AllTrim(SF1->F1_FORNECE) == "005135"
				cConta := "21105001000007"
			ElseIf AllTrim(SF1->F1_FORNECE) == "005136"
				cConta := "21105001000008"
			ElseIf AllTrim(SF1->F1_FORNECE) == "005138"
				cConta := "21105001000009"
			ElseIf AllTrim(SF1->F1_FORNECE) == "005137"
				cConta := "21105001000010"
			ElseIf AllTrim(SF1->F1_FORNECE) == "005096"
				cConta := "21105001000011"
			EndIf
				
		EndIf
		
		If AllTrim(SED->ED_CODIGO) == "2998" //Distribuição de lucros
		
			If AllTrim(SF1->F1_FORNECE) == "004926"
				cConta := "21109001000006"
			ElseIf AllTrim(SF1->F1_FORNECE) == "003198"
				cConta := "21109001000001"
			ElseIf AllTrim(SF1->F1_FORNECE) == "002575"
				cConta := "21109001000002"
			ElseIf AllTrim(SF1->F1_FORNECE) == "004680"
				cConta := "21109001000003"	
			ElseIf AllTrim(SF1->F1_FORNECE) == "000524"
				cConta := "21109001000004"	
			ElseIf AllTrim(SF1->F1_FORNECE) == "003187"
				cConta := "21109001000005"
			ElseIf AllTrim(SF1->F1_FORNECE) == "005135"
				cConta := "21109001000010"
			ElseIf AllTrim(SF1->F1_FORNECE) == "005136"
				cConta := "21109001000011"
			ElseIf AllTrim(SF1->F1_FORNECE) == "005138"
				cConta := "21109001000014"
			ElseIf AllTrim(SF1->F1_FORNECE) == "005137"
				cConta := "21109001000012"
			ElseIf AllTrim(SF1->F1_FORNECE) == "005096"
				cConta := "21109001000013"
			EndIf
				
		EndIf
		//|Fim Pontin |

	EndIf

	If cArqSD1 <> ""
		dbSelectArea(cArqSD1)
		dbSetOrder(cIndSD1)
		dbGoTo(cRegSD1)
		RetIndex("SD1")
	EndIf

	If cArqSD2 <> ""
		dbSelectArea(cArqSD2)
		dbSetOrder(cIndSD2)
		dbGoTo(cRegSD2)
		RetIndex("SD2")
	EndIf

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	If cArqSA2 <> ""
		dbSelectArea(cArqSA2)
		dbSetOrder(cIndSA2)
		dbGoTo(cRegSA2)
		RetIndex("SA2")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

Return(cConta)
