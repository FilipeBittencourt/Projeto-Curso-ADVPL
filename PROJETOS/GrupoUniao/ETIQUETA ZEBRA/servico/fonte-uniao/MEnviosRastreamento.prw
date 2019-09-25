#INCLUDE "PROTHEUS.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "JSON.CH"

/*/{Protheus.doc} MEnviosRastreamento
CLASSE RESPONSAVEL POR BUSCAR O PDF DO MERCADO ENVIOS E URL DE DOWNLOAD DA PLP E RASTRO.
@author WLYSSES CERQUEIRA (FACILE)
@since 29/05/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

#DEFINE ENTER Chr(10) + Chr(13)

Class MEnviosRastreamento From MEnviosAcesso

	Data cCodRastr
    Data cModFrete

	Data cOrdId
	Data cSequen
	Data cIdCart

	Data cApi
	Data cDoc
	Data cSerie
	Data cCliente
	Data cLoja
	Data cEmissao
	Data cServico
	Data cCodPLP

	Method New() CONSTRUCTOR
	Method GetAtuRastro(lCriaRastro)
	Method GetUrlPDF(lCriaRastro)
	Method GetUrlZPL(lCriaRastro)
	Method IsME2(cSequen, cOrdId, cPLP, cPedido)

EndClass

Method New() Class MEnviosRastreamento

	_Super:New()

	::cCodRastr 	:= ""
    ::cModFrete		:= ""

	::cOrdId		:= ""
	::cSequen       := ""
	::cIdCart		:= ""
	::cApi          := ""
	::cDoc          := ""
	::cSerie        := ""
	::cCliente      := ""
	::cLoja         := ""
	::cEmissao      := ""
	::cServico      := ""
	::cCodPLP		:= ""

Return(Self)

Method GetAtuRastro(lCriaRastro,lZPL) Class MEnviosRastreamento

	Local cRespJSON		:= ""
	Local cHeaderRet 	:= ""
	Local cUrl			:= ::cURLBase + "/orders?marketplace_id=" + AllTrim(::cIdCart)
	Local aRet			:= {.F., "Erro na busca no rastro." + ENTER + ENTER + cUrl,""}
	Local nW			:= 0
	Local nX			:= 0
	Local nTentativas	:= 3

	Default lCriaRastro	:= .T.
	Default	lZPL		:= .F.

	Private oJsMPago	:= Nil

	For nW := 1 To nTentativas

		cRespJSON := HTTPGet(cUrl,,30,::aHeadStr, @cHeaderRet)

		If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

			Exit

		Else

			Sleep(3000)

		EndIf

	Next nW

	If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

		//Transforma a string em um Objeto JSON (Array)
		FWJsonDeserialize(cRespJSON, @oJsMPago)

		If Type('oJsMPago:ITEMS') == 'A' .And. Len(oJsMPago:ITEMS) == 1 // Caso seja maior que 1, avaliar e fazer novo tratamento

			For nW := 1 To Len(oJsMPago:ITEMS)

				If Type('oJsMPago:ITEMS['+ cValToChar(nW)+']:MERCADOLIBRE:SHIPPING:MODE') != 'U'
					::cModFrete := UPPER( AllTrim(oJsMPago:ITEMS[nW]:MERCADOLIBRE:SHIPPING:MODE) )
					aRet[1] := .T.
				Else
					aRet := {.F., "Mercado Envios - Não foi possível identificar o modo de envio da mercadoria.",""}
				EndIf

				If aRet[1] .and. ::cModFrete == "ME2"

					//|Busca código do rastreamento |
					If Type('oJsMPago:ITEMS['+cValToChar(nW)+']:FREIGHT:TRACKING') == 'A'
						For nX := 1 To Len(oJsMPago:ITEMS[nW]:FREIGHT:TRACKING)
							::cCodRastr := DecodeUTF8(oJsMPago:ITEMS[nW]:FREIGHT:TRACKING[nX])
						Next nX

					Else
						aRet := {.F., "Mercado Envios - Erro ao obter o código do rastreio. Tag não existe no Json",""}

					EndIf

					If aRet[1]
						If Empty (::cCodRastr)
							aRet := {.F., "Mercado Envios - Erro ao obter o código do rastreio. Tag não existe no Json ou está vazia",""}
						EndIf
					EndIf

					If aRet[1]

						If lZPL	//|ZPL |
							aRet := ::GetUrlZPL(lCriaRastro)
						Else	//|PDF |
							aRet := ::GetUrlPDF(lCriaRastro)
						EndIf

					EndIf

				Elseif aRet[1] .and. ! ::cModFrete == "ME2"
					aRet := {.F., "Mercado Envios - Não foi possível identificar o modo de envio da mercadoria.",""}

				EndIf

			Next nW

		EndIf

		If !aRet[1]
			::EmailErro({aRet[2]})
		endIf

	Else

		aRet := {.F., "Não conseguiu obter retorno após " + cvaltochar(nTentativas) + " tentativas (GetAtuRastro): " + ENTER + ENTER + cUrl + ENTER + If(Valtype(cHeaderRet) == "C",cHeaderRet, "") + ENTER + ENTER + If(Valtype(cRespJSON) == "C",cRespJSON, ""),""}

		::EmailErro({aRet[2]})

	EndIf

	If oJsMPago <> nil

		FreeObj(oJsMPago)

	EndIf

Return(aRet)

Method GetUrlPDF(lCriaRastro) Class MEnviosRastreamento

	Local cRespJSON		:= ""
	Local cHeaderRet 	:= ""
	Local cUrl			:= ::cURLDownlo + "/ml/label/" + AllTrim(::cIdCart) + "?format=pdf"
	Local aRet			:= {.F., "Erro ao retornar a url de download." + ENTER + ENTER + cUrl}
	Local cUrlDownl		:= ""
	Local aAreaVT1 		:= VT1->(GetArea())
	Local nW			:= 0
	Local nTentativas	:= 3
	Local cCodPLP		:= StaticCall(VIXA189, ProxPLPME)

	Private oJsMPago2	:= Nil

	For nW := 1 To nTentativas

		cRespJSON := HTTPGet(cUrl,,,::aHeadStr, @cHeaderRet)

		If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

			Exit

		Else

			Sleep(3000)

		EndIf

	Next nW

	If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

		//Transforma a string em um Objeto JSON (Array)
		FWJsonDeserialize(cRespJSON, @oJsMPago2)

		If Type('oJsMPago2:download_url') <> 'U'

			cUrlDownl := DecodeUTF8(oJsMPago2:download_url)

			aRet := {.T., cUrlDownl}

		Else

			aRet := {.F., "Erro no retorno do HTTPGet: " + ENTER + ENTER + cUrl + ENTER + If(Valtype(cHeaderRet) == "C",cHeaderRet, "") + ENTER + ENTER + If(Valtype(cRespJSON) == "C",cRespJSON, "")}

			::EmailErro({aRet[2]})

		EndIf

	Else

		aRet := {.F., "Erro no retorno do HTTPGet: " + ENTER + ENTER + cUrl + ENTER + If(Valtype(cHeaderRet) == "C",cHeaderRet, "") + ENTER + ENTER + If(Valtype(cRespJSON) == "C",cRespJSON, "")}

		::EmailErro({aRet[2]})

	EndIf

	If oJsMPago2 <> nil

		FreeObj(oJsMPago2)

	EndIf

	If aRet[1] .And. lCriaRastro .And. ! Empty(cUrlDownl)

		RecLock('VT7', .T.)
		VT7->VT7_FILIAL	:= xFilial("VT7")
		VT7->VT7_ORDID	:= ::cOrdId
		VT7->VT7_SEQUEN	:= ::cSequen  //::cIdCart
		VT7->VT7_API  	:= ::cApi
		VT7->VT7_DOC  	:= ::cDoc
		VT7->VT7_SERIE	:= ::cSerie
		VT7->VT7_CODRAS	:= ::cCodRastr
		VT7->(MsUnLock())

		RecLock('ZZB', .T.)
		ZZB->ZZB_FILIAL := xFilial("ZZB")
		ZZB->ZZB_RASTRO := ::cCodRastr
		ZZB->ZZB_PLP    := cCodPLP
		ZZB->ZZB_EMISSA := Date()
		ZZB->ZZB_FECHAM := Date()
		ZZB->ZZB_DOC    := ::cDoc
		ZZB->ZZB_SERIE  := ::cSerie
		ZZB->ZZB_CLIENT := ::cCliente
		ZZB->ZZB_LOJA   := ::cLoja
		ZZB->ZZB_EMISNF := If(ValType(::cEmissao) == "C", SToD(::cEmissao), ::cEmissao)
		ZZB->ZZB_CONTRO := StaticCall(VIXA189, NumeControle)
		ZZB->ZZB_VOLUME := "1/1"
		ZZB->ZZB_SERVIC := ::cServico
		If ZZB->(FieldPos("ZZB_DTPRIN")) > 0
			ZZB->ZZB_DTBIP	:= dDataBase
			ZZB->ZZB_HRBIP	:= SubStr(Time(),1,5)
			ZZB->ZZB_DTPRIN	:= dDataBase
			ZZB->ZZB_HRPRIN	:= SubStr(Time(),1,5)
		EndIf
		ZZB->(MsUnLock())

	EndIf

	RestArea(aAreaVT1)

Return(aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GetUrlZPL
description Metodo para buscar a string ZPL na 00K
@author  Pontin
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetUrlZPL(lCriaRastro) Class MEnviosRastreamento

	Local cRespJSON		:= ""
	Local cHeaderRet 	:= ""
	Local cUrl			:= ::cURLDownlo + "/ml/label/" + AllTrim(::cIdCart) + "?format=zpl2"
	Local aRet			:= {.F., "Erro ao retornar a url de download." + ENTER + ENTER + cUrl}
	Local cUrlDownl		:= ""
	Local aAreaVT1 		:= VT1->(GetArea())
	Local nW			:= 0
	Local nPos			:= ""
	Local cMEPLP		:= ""
	Local nTentativas	:= 3
	Local cStringZPL	:= ""

	::cCodPLP			:= StaticCall(VIXA189, ProxPLPME)

	Private oJsMPago2	:= Nil

	For nW := 1 To nTentativas

		cRespJSON := HTTPGet(cUrl,,30,::aHeadStr, @cHeaderRet)

		If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

			Exit

		Else

			VTAlert("00K NAO ESTA RESPONDENDO!!","Aviso",.T.,2000)

		EndIf

	Next nW

	If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

		//Transforma a string em um Objeto JSON (Array)
		FWJsonDeserialize(cRespJSON, @oJsMPago2)

		If Type('oJsMPago2:download_url') <> 'U'

			cUrlDownl := DecodeUTF8(oJsMPago2:Download_URL)
			cStringZPL := DecodeUTF8(oJsMPago2:string)

			aRet := {.T., cStringZPL, cUrlDownl}

			//|Pega o código da PLP quando for Mercado Envios |
			cMEPLP	:= cStringZPL

			If (nPos := AT("PLP:",cMEPLP)) > 0

				cMEPLP	:= SubString(cMEPLP,(nPos+4),Len(cMEPLP))	//|Pega string do inicio do PLP |
				nPos 	:= AT("^FS",cMEPLP)
				cMEPLP	:= SubString(cMEPLP,1,(nPos-1))	//|Pega o numero do PLP |

			Else
				cMEPLP	:= ""
			EndIf

			If !Empty(cMEPLP)
				::cCodPLP		:= "M" + AllTrim(cMEPLP)
			EndIf

		Else

			aRet := {.F., "Erro no retorno do HTTPGet: " + ENTER + ENTER + cUrl + ENTER + If(Valtype(cHeaderRet) == "C",cHeaderRet, "") + ENTER + ENTER + If(Valtype(cRespJSON) == "C",cRespJSON, "")}

			::EmailErro({aRet[2]})

		EndIf

	Else

		aRet := {.F., "Erro no retorno do HTTPGet: " + ENTER + ENTER + cUrl + ENTER + If(Valtype(cHeaderRet) == "C",cHeaderRet, "") + ENTER + ENTER + If(Valtype(cRespJSON) == "C",cRespJSON, "")}

		::EmailErro({aRet[2]})

	EndIf

	If oJsMPago2 <> nil

		FreeObj(oJsMPago2)

	EndIf

	If aRet[1] .And. lCriaRastro .And. ! Empty(cUrlDownl)

		dbSelectArea("VT7")
		VT7->(dbSetOrder(1))
		If !VT7->(dbSeek(xFilial("VT7") + ::cApi + ::cOrdId + ::cSequen + ::cCodRastr))
			RecLock('VT7', .T.)
			VT7->VT7_FILIAL	:= xFilial("VT7")
			VT7->VT7_ORDID	:= ::cOrdId
			VT7->VT7_SEQUEN	:= ::cSequen  //::cIdCart
			VT7->VT7_API  	:= ::cApi
			VT7->VT7_DOC  	:= ::cDoc
			VT7->VT7_SERIE	:= ::cSerie
			VT7->VT7_CODRAS	:= ::cCodRastr
			VT7->(MsUnLock())
		EndIf

		dbSelectArea("ZZB")
		ZZB->(dbSetOrder(1))
		If !ZZB->(dbSeek(xFilial("ZZB") + PadR(::cCodPLP,TamSX3("ZZB_PLP")[1]) + ::cCodRastr))

			RecLock('ZZB', .T.)
			ZZB->ZZB_FILIAL := xFilial("ZZB")
			ZZB->ZZB_RASTRO := ::cCodRastr
			ZZB->ZZB_PLP    := ::cCodPLP
			ZZB->ZZB_EMISSA := Date()
			ZZB->ZZB_FECHAM := Date()
			ZZB->ZZB_DOC    := ::cDoc
			ZZB->ZZB_SERIE  := ::cSerie
			ZZB->ZZB_CLIENT := ::cCliente
			ZZB->ZZB_LOJA   := ::cLoja
			ZZB->ZZB_EMISNF := If(ValType(::cEmissao) == "C", SToD(::cEmissao), ::cEmissao)
			ZZB->ZZB_CONTRO := StaticCall(VIXA189, NumeControle)
			ZZB->ZZB_VOLUME := "1/1"
			ZZB->ZZB_SERVIC := ::cServico

			If ZZB->(FieldPos("ZZB_DTBIP")) > 0
				ZZB->ZZB_DTBIP	:= dDataBase
				ZZB->ZZB_HRBIP	:= SubStr(Time(),1,5)
				ZZB->ZZB_DTPRIN	:= dDataBase
				ZZB->ZZB_HRPRIN	:= SubStr(Time(),1,5)
			EndIf
			ZZB->(MsUnLock())

		Else
			aRet := {.F., "Etiqueta ja foi impressa anteriormente", ""}
		EndIf

	EndIf

	RestArea(aAreaVT1)

Return(aRet)


Method IsME2(cSequen, cApi, cPLP, cPedido) Class MEnviosRastreamento

	Local lRet 		:= .F.
	Local aAreaVT1 	:= VT1->(GetArea())
	Local aAreaZZB 	:= ZZB->(GetArea())
	Local aAreaSD2 	:= SD2->(GetArea())
	Local aAreaSF2 	:= SF2->(GetArea())
	Local aAreaSA4 	:= SA4->(GetArea())

	Default cSequen := ""
	Default cApi	:= ""
	Default cPLP 	:= ""
	Default cPedido	:= ""

	If ! Empty(cSequen) .And. ! Empty(cApi)

		VT1->(DBSetOrder(2)) // VT1_FILIAL+VT1_SEQUEN+VT1_API

		If VT1->(DBSeek(xFilial("VT1") + cSequen + cApi))

			If AllTrim(VT1->VT1_MODFRE) == "ME2"

				SD2->(DBSetOrder(8)) // D2_FILIAL+D2_PEDIDO+D2_ITEMPV

				If SD2->(DBSeek(xFilial("SD2") + VT1->VT1_NUMPED))

					SF2->(DBSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

					If SF2->(DBSeek(xFilial("SF2") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)))

						SA4->(DBSetOrder(1)) // A4_FILIAL+A4_COD

						If SA4->(DBSeek(xFilial("SA4") + SF2->F2_TRANSP))

							lRet 	   := .T.

							::cOrdId   := VT1->VT1_ORDID
							::cSequen  := VT1->VT1_SEQUEN
							::cIdCart  := VT1->VT1_IDCART
							::cApi     := VT1->VT1_API

							::cDoc     := SF2->F2_DOC
							::cSerie   := SF2->F2_SERIE
							::cCliente := SF2->F2_CLIENTE
							::cLoja    := SF2->F2_LOJA
							::cEmissao := SF2->F2_EMISSAO

							::cServico := SA4->A4_YSERVIC

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	ElseIf ! Empty(cPLP)

		ZZB->(DBSetOrder(1)) // ZZB_FILIAL+ZZB_PLP+ZZB_RASTRO

		If ZZB->(DBSeek(xFilial("ZZB") + cPLP))

			SD2->(DBSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

			If SD2->(DBSeek(xFilial("SD2") + ZZB->ZZB_DOC + ZZB->ZZB_SERIE + ZZB->ZZB_CLIENT + ZZB->ZZB_LOJA))

				VT1->(DBSetOrder(5)) // VT1_FILIAL+VT1_NUMPED

				If VT1->(DBSeek(xFilial("VT1") + SD2->D2_PEDIDO))

					If AllTrim(VT1->VT1_MODFRE) == "ME2"

						SF2->(DBSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

						If SF2->(DBSeek(xFilial("SF2") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)))

							SA4->(DBSetOrder(1)) // A4_FILIAL+A4_COD

							If SA4->(DBSeek(xFilial("SA4") + SF2->F2_TRANSP))

								lRet 	   := .T.

								::cOrdId   := VT1->VT1_ORDID
								::cSequen  := VT1->VT1_SEQUEN
								::cIdCart  := VT1->VT1_IDCART
								::cApi     := VT1->VT1_API

								::cDoc     := SF2->F2_DOC
								::cSerie   := SF2->F2_SERIE
								::cCliente := SF2->F2_CLIENTE
								::cLoja    := SF2->F2_LOJA
								::cEmissao := SF2->F2_EMISSAO

								::cServico := SA4->A4_YSERVIC

							EndIf

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	ElseIf ! Empty(cPedido)

		VT1->(DBSetOrder(5)) // VT1_FILIAL+VT1_NUMPED

		If VT1->(DBSeek(xFilial("VT1") + cPedido))

			If AllTrim(VT1->VT1_MODFRE) == "ME2"

				SD2->(DBSetOrder(8)) // D2_FILIAL+D2_PEDIDO+D2_ITEMPV

				If SD2->(DBSeek(xFilial("SD2") + VT1->VT1_NUMPED))

					SF2->(DBSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

					If SF2->(DBSeek(xFilial("SF2") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)))

						SA4->(DBSetOrder(1)) // A4_FILIAL+A4_COD

						If SA4->(DBSeek(xFilial("SA4") + SF2->F2_TRANSP))

							lRet 	   := .T.

							::cOrdId   := VT1->VT1_ORDID
							::cSequen  := VT1->VT1_SEQUEN
							::cIdCart  := VT1->VT1_IDCART
							::cApi     := VT1->VT1_API

							::cDoc     := SF2->F2_DOC
							::cSerie   := SF2->F2_SERIE
							::cCliente := SF2->F2_CLIENTE
							::cLoja    := SF2->F2_LOJA
							::cEmissao := SF2->F2_EMISSAO

							::cServico := SA4->A4_YSERVIC

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aAreaVT1)
	RestArea(aAreaZZB)
	RestArea(aAreaSD2)
	RestArea(aAreaSF2)
	RestArea(aAreaSA4)

Return(lRet)
