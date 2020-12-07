#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TCopiaDocumentoEntrada
@author Wlysses Cerqueira (Facile)
@since 08/07/2019
@project Automação Financeira
@version 1.0
@description 
@type class
/*/

Class TCopiaDocumentoEntrada From LongClassName
	
	Data cChaveSF1
	Data nOpc
	Data lShow
	Data cDoc
	Data aCabecalho
	Data aItens
	
	Data aFieldCab
	Data aFieldItem
	
	Method New(nOpc, lShow, aFieldCab, aFieldItem) Constructor
	Method Copy()
	Method Show()
	Method GetNextDoc(cDoc, cFor, cLoj)
	Method OrdemSX3(cAlias, aCampos)
	
EndClass

Method New(nOpc, lShow, aFieldCab, aFieldItem) Class TCopiaDocumentoEntrada
	
	Default nOpc := 3
	Default lShow := .T.
	Default aFieldCab := { "F1_FILIAL", "F1_TIPO", "F1_DOC", "F1_SERIE", "F1_COND", "F1_EMISSAO", "F1_FORNECE", "F1_LOJA", "F1_EST", "F1_ESPECIE", "F1_FORMUL" }
	Default aFieldItem := { "D1_FILIAL", "D1_ITEM", "D1_COD", "D1_DOC", "D1_SERIE", "D1_FORNECE", "D1_LOJA", "D1_QUANT", "D1_VUNIT", "D1_TOTAL", "D1_TES", "D1_PEDIDO", "D1_ITEMPC", "D1_CLVL", "D1_CONTA", "D1_LOCAL", "D1_YNATURE"}
	
	::cChaveSF1 := SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
	
	::aFieldCab := ::OrdemSX3("SF1", aFieldCab)
	
	::aFieldItem := ::OrdemSX3("SD1", aFieldItem)
	
	::lShow := lShow
	
	::nOpc := nOpc
	
	::cDoc := ""
	
	::aCabecalho := {}
	
	::aItens := {}
	
Return(Self)


Method OrdemSX3(cAlias, aCampos) Class TCopiaDocumentoEntrada
	
	Local aCamposRet := {}
	Local nPos := 0
	Local aAreaSX3 := SX3->(GetArea())
	
	Default cAlias := ""
	Default aCampos := {}
	
	DBSelectArea("SX3")
	SX3->(DBSetOrder(1)) // X3_ARQUIVO, X3_ORDEM, R_E_C_N_O_, D_E_L_E_T_
	
	If SX3->(DbSeek(cAlias))
	
		While SX3->X3_ARQUIVO == cAlias
		
			nPos := aScan(aCampos, {|x| AllTrim(x) == AllTrim(SX3->X3_CAMPO)})
			
			If nPos > 0 .Or. ( x3uso(SX3->X3_USADO) .and. ((SubStr(BIN2STR(SX3->X3_OBRIGAT),1,1) == "x") .or. VerByte(SX3->X3_RESERV,7)) )
			
				aAdd(aCamposRet, AllTrim(SX3->X3_CAMPO))
				
			EndIf
		
			SX3->(DBSkip())
			
		EndDo
	
	EndIf
	
	RestArea(aAreaSX3)
	
Return(aCamposRet)


Method Show() Class TCopiaDocumentoEntrada
	
	Local aItem := {}
	Local nW := 0
	Local cPath := ""
	Local cFileLog := ""
	Local cErro := ""
		
	Private lMsErroAuto := .F.
	//Private lMsHelpAuto := .F. // para nao mostrar os erro na tela
	//Private lAutoErrNoFile := .F.

	::cDoc := ::GetNextDoc(SF1->F1_DOC, SF1->F1_FORNECE, SF1->F1_LOJA)
	
	For nW := 1 To Len(::aFieldCab)
	
		If AllTrim(::aFieldCab[nW]) == "F1_DOC"
			
			aAdd(::aCabecalho, {::aFieldCab[nW], ::cDoc, NIL, NIL})

		Else
		
			aAdd(::aCabecalho, {::aFieldCab[nW], &(SF1->(::aFieldCab[nW])), NIL, NIL})

		EndIf
		
	Next nW
	
	DBSelectArea("SD1")
	SD1->(DBSetOrder(1)) // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
	SD1->(DBGoTop())
	
	If SD1->(DBSeek(xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
		
		While !SD1->(EOF()) .And. xFilial("SD1") + SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == xFilial("SF1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
			
			aItem := {}
			
			For nW := 1 To Len(::aFieldItem)
			
				If AllTrim(::aFieldItem[nW]) == "D1_DOC"
					
					aAdd(aItem, {::aFieldItem[nW], ::cDoc, NIL, NIL})
							
				ElseIf ( AllTrim(::aFieldItem[nW]) == "D1_PEDIDO" .Or. AllTrim(::aFieldItem[nW]) == "D1_ITEMPC" ) .And. ! Empty(&(SD1->(::aFieldItem[nW])))
		
					aAdd(aItem, {::aFieldItem[nW], &(SF1->(::aFieldItem[nW])), NIL, NIL})
			
				ElseIf !( AllTrim(::aFieldItem[nW]) == "D1_PEDIDO" .Or. AllTrim(::aFieldItem[nW]) == "D1_ITEMPC" )
				
					aAdd(aItem, {::aFieldItem[nW], &(SD1->(::aFieldItem[nW])), NIL, NIL})
		
				EndIf
				
			Next nW
			
			aAdd(::aItens, aItem)
			
			SD1->(DBSkip())
			
		EndDo
	
	EndIf
	
	DBSELECTAREA("SC7")
	
	MSExecAuto({|x,y,z,w| MATA103(x,y,z,w)}, ::aCabecalho, ::aItens, ::nOpc, ::lShow)
	
	If lMsErroAuto
	
		If ::cChaveSF1 == SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
		
			MostraErro()
		
		EndIf
		
	EndIf
	
Return()

Method Copy() Class TCopiaDocumentoEntrada

	::Show()

Return()

Method GetNextDoc(cDoc, cFor, cLoj) Class TCopiaDocumentoEntrada

	Local cRet := ""
	Local aAreaSF1 := SF1->(GetArea())
	
	Default cDoc := ""
	Default cFor := ""
	Default cLoj := ""

	cRet := Soma1(cDoc, TamSx3("F1_DOC")[1])
	
	DBSelectArea("SF1")
	SF1->(DBSetOrder(2)) // F1_FILIAL, F1_FORNECE, F1_LOJA, F1_DOC, R_E_C_N_O_, D_E_L_E_T_
	
	While SF1->(MsSeek(xFilial("SF1") + cFor + cLoj + cRet)) .Or. !MayIUseCode("_SF1_" + xFilial("SF1") + cFor + cLoj + cRet)
	
		cRet := Soma1(cRet)
		
	EndDo
	
	RestArea(aAreaSF1)

Return(cRet)

User Function COPYDOCE()

	Local oObj := Nil
	Local lJob := Select("SX2") == 0 
	
	If lJob
		RpcSetEnv("01", "01")
		
		DBSELECTAREA("SF1")
	
		SF1->(DBGoto(636777))
	
	EndIf
	
	oObj := TCopiaDocumentoEntrada():New()
		
	oObj:Show()

	If lJob
		RpcSetEnv("01", "01")
	EndIf
	
Return()