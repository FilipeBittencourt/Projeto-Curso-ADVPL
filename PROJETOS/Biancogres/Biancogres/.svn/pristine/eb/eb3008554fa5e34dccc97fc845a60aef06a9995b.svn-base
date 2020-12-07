#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

/*/{Protheus.doc} BIA934
@author Wlysses Cerqueira (Facile)
@since 04/04/2019
@project Automação Financeira
@version 1.0
@description Classe para efetuar baixa automatica de pagamentos
@type class
/*/

#DEFINE NPOSNOME	1
#DEFINE NPOSBANCOAG	2
#DEFINE NPOSCONTA	3
#DEFINE NPOSVERBA	4
#DEFINE NPOSVALOR	5
#DEFINE NPOSCPF		6
#DEFINE NPOSRECSRQ	7

Class BIA934 From LongClassName

	Data cLogo
	Data oPrint
	Data oSetup
	Data cFilePrint

	Data cCaminho
	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm

	Data oFont08
	Data oFont08N
	Data oFont12N
	Data cRoteiro

	Data nRow
	Data nCol
	Data nBottom
	Data nRight
	Data nLinha01
	Data nColuna01
	Data nColuna02
	Data nColuna03
	Data nColuna04
	Data nColuna05
	Data nColuna06

	Data nTotal
	Data lCalcPag
	Data nTotPage

	Data lConta
	Data cCodBanco
	Data cCodAgenc
	Data cCodConta

	Data lFolha
	Data aLista
	Data lAutonomo
	Data aValBenef
	Data aRoteiros

	Method New() Constructor
	Method Load()
	Method Relatorio()
	Method Processa()
	Method Pergunte()
	Method Print()
	Method SetProperty()
	Method GetPrevTotPag()

	Method Header()
	Method Items()
	Method Footer()
	Method NextPage()
	Method PrintSayBitmap(nRow, nCol, cBitmap, nWidth, nHeight)
	Method PrintLine(nTop, nLeft, nBottom, nRight, nColor, cPixel)
	Method PrintSay(nRow, nCol, cText, oFont, nWidth, nClrText, nAngle)

EndClass

Method New() Class BIA934

	Local cRoteiro := ""
	Local nW := 0

	::oPrint 	:= Nil
	::nTotPage	:= 1
	::nTotal	:= 0
	::aValBenef	:= aClone(aValBenef)
	::aLista	:= aClone(aValBenef)
	::aRoteiros	:= aClone(aRoteiros)	

	For nW := 1 To Len(::aRoteiros)

		cRoteiro += ::aRoteiros[nW][1] + "_"

	Next nW

	::cFilePrint := "Liquido_" + cRoteiro + Dtos(MSDate()) + StrTran(Time(), ":", "")

	If aScan(::aRoteiros, {|x| x[1] $ "FOL|AUT" }) > 0 .and. Len(::aValBenef) > 0
		//If Len(::aRoteiros) == 1 .And. ( ::aRoteiros[1][1] == "FOL" .Or. ::aRoteiros[1][1] == "AUT" )

		::lFolha := aScan(::aRoteiros, {|x| x[1] == "FOL" }) > 0 //::aRoteiros[1][1] == "FOL"

		::lAutonomo := aScan(::aRoteiros, {|x| x[1] == "AUT" }) > 0 //::aRoteiros[1][1] == "AUT"

		For nW := 1 To Len(::aValBenef)

			::nTotal += ::aValBenef[nW][NPOSVALOR]

		Next nW

	Else

		::lFolha := .F.

		::lAutonomo := .F.

	EndIf

	If ::lFolha .Or. ::lAutonomo

		::aLista := Array(1 , Len(::aValBenef[1]))

		For nW := 1 To Len(::aLista[1])

			If ValType(::aValBenef[1][nW]) == "C"

				::aLista[1][nW] := Space(Len(::aValBenef[1][nW]))

			ElseIf ValType(::aValBenef[1][nW]) == "N"

				::aLista[1][nW] := 0

			ElseIf ValType(::aValBenef[1][nW]) == "D"

				::aLista[1][nW] := STOD("  /  /    ")

			ElseIf ValType(::aValBenef[1][nW]) == "L"

				::aLista[1][nW] := .F.

			EndIf

		Next nW

		If ::lAutonomo .And. ::lFolha

			::aLista[1][NPOSNOME]	:= "FOLHA DE PAGAMENTO"

		ElseIf ::lAutonomo

			::aLista[1][NPOSNOME]	:= "AUTONOMOS E PROLABORES"

		ElseIf ::lFolha

			::aLista[1][NPOSNOME]	:= "FOLHA DE PAGAMENTO"

		EndIf

		::aLista[1][NPOSVALOR]	:= ::nTotal

	EndIf

	::SetProperty()

	::GetPrevTotPag()

	::SetProperty()

Return()

Method SetProperty() Class BIA934

	Local nW := 0

	::cName := "BIA934"
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.

	::oFont08  := TFont():New('Tahoma',,-10,.T.)
	::oFont08N := TFont():New('Tahoma',,-12,.T., .T.)
	::oFont12N := TFont():New('Tahoma',,-12,.T., .T.)
	::cRoteiro := ""

	::nRow		:= 0
	::nCol		:= 0
	::nBottom	:= 0
	::nRight	:= 0
	::nLinha01	:= 0
	::nColuna01	:= 0
	::nColuna02	:= 0
	::nColuna03	:= 0
	::nColuna04	:= 0
	::nColuna05	:= 0
	::nColuna06	:= 0

	::lCalcPag	:= .F.

	::cCodBanco	:= If(Type("cCodBanco") == "C", cCodBanco, "756")
	::cCodAgenc	:= If(Type("cCodAgenc") == "C", cCodAgenc, "3007")
	::cCodConta	:= If(Type("cCodConta") == "C", cCodConta, "1214144")
	::lConta	:= .T.

	::cCaminho := PadR("c:\temp\", 60)

	If ! File(::cCaminho)

		If MakeDir( ::cCaminho,,.F. ) <> 0

			Conout("BIA934 - Erro ao criar pasta")

		EndIf

	EndIf

	If cEmpAnt == "01"

		::cLogo := "\system\logonfe01.bmp"

	ElseIf cEmpAnt == "05"

		::cLogo := "\system\logonfe05.bmp"

	ElseIf cEmpAnt == "06"

		::cLogo := "\system\lgrl06.bmp"

	ElseIf cEmpAnt == "12"

		::cLogo := "\system\lgrl12.bmp"

	ElseIf cEmpAnt == "13"

		::cLogo := "\system\lgrl13.bmp"

	ElseIf cEmpAnt == "14"

		::cLogo := "\system\logonfe14.bmp"

	Else

		::cLogo := "\system\logonfe07_comprovante_pag.bmp"

	EndIf

Return()

Method Relatorio() Class BIA934

	If !::lCalcPag

		::Load()

		::Processa()

	EndIf

	FreeObj(::oPrint)

	FreeObj(::oSetup)

	::oPrint := Nil

	::oSetup := Nil

Return()

Method Processa() Class BIA934

	If !::lCalcPag

		::oPrint:StartPage()

	EndIf

	::Print()

	If !::lCalcPag

		::oPrint:EndPage()

	EndIf

	If !::lCalcPag

		::oPrint:Preview() //Visualiza antes de imprimir

	EndIf

Return()

Method Load() Class BIA934

	Local lAdjustToLegacy	:= .F.
	Local lDisableSetup		:= .T.

	::oPrint := FWMSPrinter():New(::cFilePrint, IMP_PDF , lAdjustToLegacy, "\spool", lDisableSetup, , ,, .F., .F. )

	::oPrint:SetResolution(78) //Tamanho estipulado para a Danfe
	::oPrint:SetPortrait()
	::oPrint:SetPaperSize(DMPAPER_A4)
	::oPrint:SetMargin(60,60,60,60)
	::oPrint:lServer := .T.

	::oPrint:SetCopies(1)

	::oPrint:cPathPDF := AllTrim(::cCaminho)

Return()

Method Print() Class BIA934

	::Header()

	::Items()

	::Footer()

Return()

Method Header() Class BIA934

	Local cEmisTime := DTOC(dDataBase) + " " + Time()
	Local aArea := SRY->(GetArea())
	Local nW := 0

	::cRoteiro := ""

	::nRow := 005
	::nCol := 005
	::nBottom := 380
	::nRight := 600
	::nLinha01 := 100
	::nColuna01 := 130

	::PrintLine(::nRow, ::nCol, ::nRow, ::nRight)

	::nLinha01 := 15
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna01, "AUTORIZAÇÃO PARA PAGAMENTO", ::oFont12N)

	::PrintSay(::nRow + ::nLinha01, ::nRight - 157, "EMISSÃO: " + cEmisTime, ::oFont12N)

	DBSelectArea("SRY")
	SRY->(DBSetOrder(1))

	For nW := 1 To Len(::aRoteiros)

		If SRY->(DBSeek(xFilial("SRY") + ::aRoteiros[nW][1]))

			::cRoteiro += If(Empty(::cRoteiro), "", If(nW == Len(::aRoteiros), " E ", ", ")) + AllTrim(SRY->RY_DESC)

		EndIf

	Next nW

	::nLinha01 += 10

	::PrintSay(::nRow + ::nLinha01, ::nRight - 49, "Pag: " + If(::lCalcPag, "", cValToChar(::oPrint:nPageCount) + "/" + cValToChar(::nTotPage)), ::oFont12N)

	::PrintSay(::nRow + ::nLinha01, ::nRight - 157, "FILIAL.: " + cEmpAnt + cFilAnt, ::oFont12N)

	::PrintSayBitmap(::nRow+5, ::nRow + 5, ::cLogo, 100, 030)

	::nLinha01 += 15
	::PrintLine(::nRow + ::nLinha01, ::nCol, ::nRow + ::nLinha01, ::nRight)

	If ::lConta

		::nLinha01 += 10
		::PrintSay(::nRow + ::nLinha01, ::nCol + 10, "Banco: " + ::cCodBanco, ::oFont08N)

		::nLinha01 += 10
		::PrintSay(::nRow + ::nLinha01, ::nCol + 10, "Agencia: " + ::cCodAgenc, ::oFont08N)

		::nLinha01 += 10
		::PrintSay(::nRow + ::nLinha01, ::nCol + 10, "Conta: " + ::cCodConta, ::oFont08N)

		If ::lCalcPag

			::lConta := .T.

		Else

			::lConta := .F.

		EndIf

	EndIf

	SRY->(RestArea(aArea))

Return()

Method Items() Class BIA934

	Local nW := 0

	::nLinha01 += 10

	::PrintLine(::nRow + ::nLinha01, ::nCol, ::nRow + ::nLinha01, ::nRight)

	::nLinha01  += 10
	::nColuna01 := 10
	::nColuna02 := ::nColuna01 + 220
	::nColuna03 := ::nColuna02 + 40
	::nColuna04 := ::nColuna03 + 60
	::nColuna05 := ::nColuna04 + 90
	::nColuna06 := ::nColuna05 + 90

	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna01, "Funcionário"	, ::oFont08N)
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna02, "Banco"			, ::oFont08N)
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna03, "Agencia"		, ::oFont08N)
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna04, "Conta"			, ::oFont08N)
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna05, "CPF"			, ::oFont08N)
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna06, "Valor"			, ::oFont08N)

	::nLinha01 += 10
	::PrintLine(::nRow + ::nLinha01, ::nCol, ::nRow + ::nLinha01, ::nRight)

	::nTotal := 0									  

	For nW := 1 To Len(::aLista)

		::nLinha01 += 10

		::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna01, ::aLista[nW][NPOSNOME], ::oFont08)
		::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna02, SubStr(::aLista[nW][NPOSBANCOAG], 1, 3), ::oFont08)
		::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna03, SubStr(::aLista[nW][NPOSBANCOAG], 4, 100), ::oFont08)
		::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna04, ::aLista[nW][NPOSCONTA], ::oFont08)
		::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna05, Transform(::aLista[nW][NPOSCPF], "@R 999.999.999-99"), ::oFont08)
		::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna06, Transform(::aLista[nW][NPOSVALOR], "@E 999,999,999.99"), ::oFont08)

		::nTotal += ::aLista[nW][NPOSVALOR]

		If ::nLinha01 >= 850

			::NextPage()

		EndIf

	Next nW

	::nLinha01 += 10
	::PrintLine(::nRow + ::nLinha01, ::nCol, ::nRow + ::nLinha01, ::nRight)

	::nLinha01 += 10
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna01, "Total:", ::oFont08)
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna06, Transform(::nTotal, "@E 999,999,999.99"), ::oFont08)

	::nLinha01 += 10
	::PrintLine(::nRow + ::nLinha01, ::nCol, ::nRow + ::nLinha01, ::nRight)

Return()

Method Footer() Class BIA934

	Local cMsg := ""
	Local aMsg := ""
	Local dData_ := MV_PAR20 - 1
	Local lDate := .F.
	Local nW

	If ::nLinha01 > 390

		::NextPage()

	EndIf

	//::nLinha01 += 30
	//::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna01, AllTrim(Extenso(::nTotal)), ::oFont08)

	cMsg := "SOLICITAMOS A AUTORIZAÇÃO DA LIBERAÇÃO PARA PROCESSAMENTO DO PAGAMENTO "

	cMsg += "DE " + ::cRoteiro + ", NO VALOR DE R$ " + AllTrim(Transform(::nTotal, "@E 999,999,999.99"))

	cMsg += " (" + AllTrim(Extenso(::nTotal)) + ")"

	cMsg += If(::lFolha .Or. ::lAutonomo, ".", " EM FAVOR DOS ACIMA RELACIONADOS.")

	::nLinha01 += 30

	aMsg := StrToKarr(cMsg, " ")

	cMsg := ""

	For nW := 1 To Len(aMsg)

		cMsg += aMsg[nW] + " "

		If Len(cMsg) >= 105 .Or. nW == Len(aMsg)

			::nLinha01 += 10

			::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna01, cMsg, ::oFont08)

			cMsg := ""

		EndIf

	Next nW

	::nLinha01 += 100
	::PrintLine(::nRow + ::nLinha01, ::nCol+200, ::nRow + ::nLinha01, ::nRight-200)

	::nLinha01 += 10
	::PrintSay(::nRow + ::nLinha01, ::nCol+270, "Procurador", ::oFont08)

	::nLinha01 += 50

	While !lDate

		If DataValida(dData_) <> dData_

			dData_--

		Else

			lDate := .T.

		EndIf

	EndDo

	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna01, "Data do débito: " + DTOC(dData_), ::oFont08)

	::nLinha01 += 20
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna01, "Data do crédito: " + DTOC(MV_PAR20), ::oFont08)

	::nLinha01 += 100
	::PrintLine(::nRow + ::nLinha01, ::nCol, ::nRow + ::nLinha01, ::nRight-440)

	::nLinha01 += 10
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna01+30, "Autorização DP", ::oFont08)

	::nLinha01 += 100
	::PrintLine(::nRow + ::nLinha01, ::nCol, ::nRow + ::nLinha01, ::nRight-440)

	::nLinha01 += 10
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna01+40, "Analista DP", ::oFont08)

	::nLinha01 += 20
	::PrintSay(::nRow + ::nLinha01, ::nCol + ::nColuna01+20, "Data:___/___/____", ::oFont08)

Return()

Method NextPage() Class BIA934

	If ::lCalcPag

		::nTotPage++

	Else

		::oPrint:EndPage()

		::oPrint:StartPage()

	EndIf

	::Header()

	::nColuna01 := 10

	::nLinha01 := 50

Return()

Method PrintSayBitmap(nRow, nCol, cBitmap, nWidth, nHeight) Class BIA934

	If !::lCalcPag

		::oPrint:SayBitmap(nRow, nCol, cBitmap, nWidth, nHeight)

	EndIf

Return()

Method PrintLine(nTop, nLeft, nBottom, nRight, nColor, cPixel) Class BIA934

	If !::lCalcPag

		::oPrint:Line(nTop, nLeft, nBottom, nRight)

	EndIf

Return()

Method PrintSay(nRow, nCol, cText, oFont, nWidth, nClrText, nAngle) Class BIA934

	If !::lCalcPag

		::oPrint:Say(nRow, nCol, cText, oFont)

	EndIf

Return()

Method GetPrevTotPag() Class BIA934

	::lCalcPag := .T.

	::Print()

	::lCalcPag := .F.

Return(::nTotPage)

User Function BIA934()

	Local oObj := Nil
	Local lJob := !(Select("SX2") > 0)
	Local nW

	If lJob

		RPCSetType(3)
		RpcSetEnv("01", "01")

	EndIf

	If IsBlind()

		aValBenef := {}

		Pergunte("GPEM080", .F.)

		MV_PAR20 := DDATABASE

		For nW := 1 To 107

			aAdd(aValBenef, {"CAMILA BRANDEMBURG VIEIRA ALVES VICENTINI", "75642102", "000000390054", "", 1000, "09849153709"})

		Next nW

		aRoteiros := {}

		//Aadd(aRoteiros, {"FOL"} )
		//Aadd(aRoteiros, {"FER"} )
		//Aadd(aRoteiros, {"131"} )
		//Aadd(aRoteiros, {"132"} )
		Aadd(aRoteiros, {"RES"} )

	EndIf

	oObj := BIA934():New()

	oObj:Relatorio()

	If lJob

		RpcClearEnv()

	EndIf

Return()