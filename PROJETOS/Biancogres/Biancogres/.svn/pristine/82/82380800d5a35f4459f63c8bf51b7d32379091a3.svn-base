#include "rwmake.ch"
#include "TOTVS.ch"

/*/{Protheus.doc} CT105LOK
@description Ponto de entrada para validação da linha dos lançamentos contabeis
@author Marcos Alberto Soprani
@since 12/06/15
@version undefined
@type function
/*/
User Function CT105LOK()

	Local aArea 	:= GetArea()
	Local aAreaCT1 	:= CT1->(GetArea())
	Local lOK := .T.
	Local _lSkip  	:= IIF(Alltrim(FunName()) $ "FINA200",.T.,.F.)

	If _lSkip
		Return(lOK)
	EndIf

	cTipo    := TMP->CT2_DC
	cDebito  := TMP->CT2_DEBITO
	cCredito := TMP->CT2_CREDIT

	cCCcred := TMP->CT2_CCC
	cCCdeb  := TMP->CT2_CCD

	cICcred := TMP->CT2_ITEMC
	cICdeb  := TMP->CT2_ITEMD

	cCVcred := TMP->CT2_CLVLCR
	cCVdeb  := TMP->CT2_CLVLDB

	cATIVDeb	:= TMP->CT2_ATIVDE
	cATIVCrd	:= TMP->CT2_ATIVCR

	DO CASE
		CASE cTipo == "1" .AND. !Empty(cCredito)
		lOK := .F.
		MSGBOX("Lancamento contabil nao pode ser realizado com conta credito para tipo D","CT105LOK","STOP")
		CASE cTipo == "2" .AND. !Empty(cDebito)
		lOK := .F.
		MSGBOX("Lancamento contabil nao pode ser realizado com conta debito  para tipo C","CT105LOK","STOP")
		CASE cTipo == "3" .AND. (Empty(cDebito) .OR. Empty(cCredito))
		lOK := .F.
		MSGBOX("Lancamento contabil nao pode ser realizado com sem preenchimento para tipo X","CT105LOK","STOP")
	ENDCASE

	DO CASE
		CASE cTipo == "1"
		DbSelectArea("CT1")
		DbSeek(xFilial("CT1")+cDebito)
		IF CT1->CT1_CCOBRG == "1" .AND. EMPTY(cCCdeb)
			lOK := .F.
			MSGBOX("Lancamento contabil nao pode ser realizado sem Centro de Custo tipo D","CT105LOK","STOP")
		ENDIF
		CASE cTipo == "2"
		DbSelectArea("CT1")
		DbSeek(xFilial("CT1")+cCredito)
		IF CT1->CT1_CCOBRG == "1" .AND. EMPTY(cCCcred)
			lOK := .F.
			MSGBOX("Lancamento contabil nao pode ser realizado sem Centro de Custo tipo C","CT105LOK","STOP")
		ENDIF
		CASE cTipo == "3"
		DbSelectArea("CT1")
		DbSeek(xFilial("CT1")+cDebito)
		IF CT1->CT1_CCOBRG == "1" .AND. EMPTY(cCCdeb)
			lOK := .F.
			MSGBOX("Lancamento contabil nao pode ser realizado sem Centro de Custo tipo D","CT105LOK","STOP")
		ENDIF
		DbSelectArea("CT1")
		DbSeek(xFilial("CT1")+cCredito)
		IF CT1->CT1_CCOBRG == "1" .AND. EMPTY(cCCcred)
			lOK := .F.
			MSGBOX("Lancamento contabil nao pode ser realizado sem Centro de Custo tipo C","CT105LOK","STOP")
		ENDIF
	ENDCASE

	DO CASE
		CASE cTipo == "1"
		DbSelectArea("CT1")
		DbSeek(xFilial("CT1")+cDebito)
		IF CT1->CT1_CLOBRG == "1" .AND. EMPTY(cCVdeb)
			lOK := .F.
			MSGBOX("Lancamento contabil nao pode ser realizado sem Classe de Valor tipo D","CT105LOK","STOP")
		ENDIF
		CASE cTipo == "2"
		DbSelectArea("CT1")
		DbSeek(xFilial("CT1")+cCredito)
		IF CT1->CT1_CLOBRG == "1" .AND. EMPTY(cCVcred)
			lOK := .F.
			MSGBOX("Lancamento contabil nao pode ser realizado sem Classe de Valor tipo C","CT105LOK","STOP")
		ENDIF
		CASE cTipo == "3"
		DbSelectArea("CT1")
		DbSeek(xFilial("CT1")+cDebito)
		IF CT1->CT1_CLOBRG == "1" .AND. EMPTY(cCVdeb)
			lOK := .F.
			MSGBOX("Lancamento contabil nao pode ser realizado sem Classe de Valor tipo D","CT105LOK","STOP")
		ENDIF
		DbSelectArea("CT1")
		DbSeek(xFilial("CT1")+cCredito)
		IF CT1->CT1_CLOBRG == "1" .AND. EMPTY(cCVcred)
			lOK := .F.
			MSGBOX("Lancamento contabil nao pode ser realizado sem Classe de Valor tipo C","CT105LOK","STOP")
		ENDIF
	ENDCASE

	IF SUBSTR(cCVcred,1,1) == '8'
		IF EMPTY(cICcred)
			lOK := .F.
			MSGBOX("Lancamento contabil com classe de valor de investimento deverá ter item contábil informado.","CT105LOK","STOP")
		ENDIF
	ENDIF

	IF SUBSTR(cCVdeb,1,1) == '8'
		IF EMPTY(cICdeb)
			lOK := .F.
			MSGBOX("Lancamento contabil com classe de valor de investimento deverá ter item contábil informado.","CT105LOK","STOP")
		ENDIF
	ENDIF

	//Fernando em 05/04/2018 - Validacao para informacoes obrigatorio em contas de investimento - Porjeto de Relatorio para gerar SI / Bi 3.0
	IF ( (SUBSTR(cDebito,1,5) $ "31401#31406#31701" .OR. AllTrim(cDebito) == "41301001") .AND. AllTrim(cCCdeb) == "2000" )
		If Empty(cICdeb) .OR. Empty(cCVdeb) .Or. Empty(cATIVDeb)
			lOK := .F.
			MSGBOX("Para Lancamentos nas Contas 31401 ou 31406 ou 41301001 e CC 2000 é obrigatório informar:"+CRLF+"Item Contábil, Classe de Valor e Cliente AI.","CT105LOK","STOP")
		EndIf
	ENDIF

	IF ( (SUBSTR(cCredito,1,5) $ "31401#31406#31701" .OR. AllTrim(cCredito) == "41301001") .AND. AllTrim(cCCcred) == "2000" )
		If Empty(cICcred) .OR. Empty(cCVcred) .Or. Empty(cATIVCrd)
			lOK := .F.
			MSGBOX("Para Lancamentos nas Contas 31401 ou 31406 ou 41301001 e CC 2000 é obrigatório informar:"+CRLF+"Item Contábil, Classe de Valor e Cliente AI.","CT105LOK","STOP")
		EndIf
	ENDIF

	// Incluído por Marcos Alberto Soprani em 09/06/15 para atender ao novo controle de CLVL por empresa
	If lOK
		Conout("CT105LOK -> TESTES -> Controle de Classe de Valor (0) ("+Time()+")")
		lOK := ExecBlock("BIA555", .F., .F., "CT2CTB1")
	Else
		Conout("CT105LOK -> TESTES -> Retornou .F. ("+Time()+")")
	EndIf

	If IsInCallStack('GPEM110') .or. (IsInCallStack('CTBA500') .and. CT5->CT5_LANPAD = "200")

		IF !Empty(cCredito) .And. !Empty(cCVcred)
			TMP->CT2_YDRVCR	:=	U_BFG81DPD()
		EndIf
		IF !Empty(cDebito) .And. !Empty(cCVdeb)
			TMP->CT2_YDRVDB	:=	U_BFG81DPD()
		EndIf

		Do Case
			CASE SUBSTR(cCvCred,1,3) $ '319_329'  .Or. SUBSTR(cCvDeb,1,3) $ '319_329'
			TMP->CT2_YAPLIC	:=	'1'
			CASE SUBSTR(cCvCred,1,1) $ '3' .Or. SUBSTR(cCvDeb,1,1) $ '3'
			TMP->CT2_YAPLIC	:=	'2'
			OtherWise
			TMP->CT2_YAPLIC	:=	'0'
		EndCase

	EndIf

	If (IsInCallStack("MATA103") .AND. MV_PAR01 == 2) .Or. IsInCallStack('MATA330') .Or. IsInCallStack('MATA331')

		fGravaApli()
		
		fGravaSubItem()

	EndIf

	//TICKET 22710 - Incluindo bloco abaixo com intencao de preencher o campo CT2_YAPLIC para LP de Faturamento quando RPV que usa CV de CUSTO
	If IsInCallStack("MATA460A") .Or. IsInCallStack("MATA460") .Or. IsInCallStack('BACP0010') .Or. IsInCallStack('BACP0014') .Or. ( CLOTE == "008820" )

		Do Case
			CASE SUBSTR(cCvCred,1,1) $ '3' .Or. SUBSTR(cCvDeb,1,1) $ '3'
			TMP->CT2_YAPLIC	:=	'1'
			TMP->CT2_TPSALD :=  "1"  //para tentar forçar a não gerar como pre-lancamento
			OtherWise
			TMP->CT2_YAPLIC	:=	'0'
		EndCase

	EndIf
	//FIM >>> TICKET 22710

	If IsInCallStack('U_BIA749')

		msRegSD3 := ""
		If TMP->CT2_LP = '668'.and. "666001 CANC" $ TMP->CT2_ORIGEMBAC
			msRegSD3 := Substr(TMP->CT2_ORIGEM, 50, 8)

		ElseIf TMP->CT2_LP = '668' .and. "668002" $ TMP->CT2_ORIGEM
			msRegSD3 := Substr(TMP->CT2_ORIGEM, 50, 8)

		ElseIf TMP->CT2_LP = '668'
			msRegSD3 := Substr(TMP->CT2_ORIGEM, 51, 8)

		ElseIf TMP->CT2_LP = '666' .and. "666002" $ TMP->CT2_ORIGEM
			msRegSD3 := Substr(TMP->CT2_ORIGEM, 50, 8)

		ElseIf TMP->CT2_LP = '666'
			msRegSD3 := Substr(TMP->CT2_ORIGEM, 51, 8)

		ElseIf TMP->CT2_LP = '66Z'
			msRegSD3 := Substr(TMP->CT2_ORIGEM, 39, 8)

		EndIf

		SD3->(dbGoTo(Val(Alltrim(msRegSD3))))
		_cAplic		:=	SD3->D3_YAPLIC
		_cDriver	:=	SD3->D3_YDRIVER
		
		_cSubItem := SD3->D3_YSUBITE

		If Empty(TMP->CT2_YAPLIC)
			TMP->CT2_YAPLIC   := _cAplic
		EndIf
		If !Empty(TMP->CT2_CLVLCR) .And. Empty(TMP->CT2_YDRVCR)
			TMP->CT2_YDRVCR   := _cDriver
		EndIf
		If !Empty(TMP->CT2_CLVLDB) .And. Empty(TMP->CT2_YDRVDB)
			TMP->CT2_YDRVDB   := _cDriver
		EndIf
		
		// Subitem Projeto
		If !Empty(TMP->CT2_CLVLCR) .And. Empty(TMP->CT2_YSUBCR)
			
			TMP->CT2_YSUBCR := _cSubItem
			
		EndIf
		
		If !Empty(TMP->CT2_CLVLDB) .And. Empty(TMP->CT2_YSUBDB)
			
			TMP->CT2_YSUBDB := _cSubItem
			
		EndIf		

	EndIf

	If !IsInCallStack('GPEM110') .and. !IsInCallStack('U_BIA798') .and. !IsInCallStack('U_BIA554') .and. !IsInCallStack('U_BIA799')

		//Valida Necessidade de Driver Crédito
		If lOk
			If U_BFG81VCL(cCVcred) .And. U_BFG81VCO(cCredito)
				If Empty(TMP->CT2_YDRVCR)
					MSGBOX("A conta e a classe de valor selecionadas(Crédito) exigem que o driver seja informado!","CT105LOK","STOP")
					lOk	:=	.F.
				EndIF
			EndIf
		EndIF

		//Valida Necessidade de Driver Débito
		If lOk
			If U_BFG81VCL(cCVdeb) .And. U_BFG81VCO(cDebito)
				If Empty(TMP->CT2_YDRVDB)
					MSGBOX("A conta e a classe de valor(Crédito) selecionadas exigem que o driver seja informado!","CT105LOK","STOP")
					lOk	:=	.F.
				EndIF
			EndIf

		EndIF

		// Valida Necessidade de Subitem Crédito
		If lOk
			
			If !U_BIAF160(cCVcred, cICcred, TMP->CT2_YSUBCR)
				
				MSGBOX("Lancamento contabil com classe de valor de investimento deverá ter item contábil e Subitem informados.","CT105LOK","STOP")
				
				lOk	:= .F.
				
			EndIf
			
		EndIf

		// Valida Necessidade de Subitem Débito
		If lOk
			
			If !U_BIAF160(cCVdeb, cICdeb, TMP->CT2_YSUBDB)
				
				MSGBOX("Lancamento contabil com classe de valor de investimento deverá ter item contábil e Subitem informados.","CT105LOK","STOP")
				
				lOk	:= .F.
				
			EndIf
			
		EndIf
		
		if !Empty(cDebito) .And. Substr(cDebito,1,1) == '6' .And. !Empty(cCVdeb)
			CTH->(DbSetOrder(1))
			If CTH->(DbSeek(xFilial("CTH")+cCVdeb)) .And. CTH->CTH_YATRIB == 'C' .And. TMP->CT2_YAPLIC $ ' _0'
				MSGBOX("A Conta e a Classe de valor(Débito) exigem que a Aplicação seja Informada e seja diferente de zero!","CT105LOK","STOP")
				lOk	:=	.F.

			endif
		endif

		if !Empty(cCredito) .And. Substr(cCredito,1,1) == '6' .And. !Empty(cCVcred)
			CTH->(DbSetOrder(1))
			If CTH->(DbSeek(xFilial("CTH")+cCVcred)) .And. CTH->CTH_YATRIB == 'C' .And. TMP->CT2_YAPLIC $ ' _0'
				MSGBOX("A Conta e a Classe de valor(Crédito) exigem que a Aplicação seja Informada e seja diferente de zero!","CT105LOK","STOP")
				lOk	:=	.F.

			endif
		endif

	EndIf

	If IsInCallStack('U_BIA474') .or. IsInCallStack('U_BIA129')
		TMP->CT2_YAPLIC := "1"
	EndIf

	If ValType(oGetDb) == "O" 
	
		oGetDb:Refresh()
		
	EndIf

	RestArea(aAreaCT1)
	RestArea(aArea)

Return(lOK)


Static Function fGravaApli()

	Local _aArea	:=	GetArea()

	Local _cKey		:=	""
	Local _cAlias	:=	""
	Local _nOrder	:=	0
	Local _cAplic	:=	""
	Local _cDriver	:=	""

	CTL->( dbSetOrder(1) )
	If CTL->( dbSeek( xFilial("CTL") + TMP->CT2_LP ) )

		_cAlias := CTL->CTL_ALIAS
		_nOrder := Val(Alltrim(CTL->CTL_ORDER))
		_cKey   := CTL->CTL_KEY

		If Alltrim(_cAlias) $ "SD3/SD1"

			&(_cAlias)->( dbSetOrder(_nOrder) )
			If &(_cAlias)->( dbSeek( Alltrim(TMP->CT2_KEY) ) )
				If Alltrim(_cAlias) == "SD3"
					_cAplic		:=	SD3->D3_YAPLIC
					_cDriver	:=	SD3->D3_YDRIVER
				ElseIf Alltrim(_cAlias) == "SD1"
					_cAplic		:=	SD1->D1_YAPLIC
					_cDriver	:=	SD1->D1_YDRIVER
				Else
					RestArea(_aArea)
					Return
				EndIf
				TMP->CT2_YAPLIC   := _cAplic
				If !Empty(TMP->CT2_CLVLCR)
					TMP->CT2_YDRVCR   := _cDriver
				ElseIf !Empty(TMP->CT2_CLVLDB)
					TMP->CT2_YDRVDB   := _cDriver
				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(_aArea)

Return


Static Function fGravaSubItem()
Local _aArea := GetArea()
Local _cKey	:= ""
Local _cAlias	:= ""
Local _nOrder	:= 0
Local _cAplic	:= ""
Local _cDriver :=	""

	CTL->(dbSetOrder(1))
	If CTL->(dbSeek(xFilial("CTL") + TMP->CT2_LP))

		_cAlias := CTL->CTL_ALIAS
		_nOrder := Val(Alltrim(CTL->CTL_ORDER))
		_cKey := CTL->CTL_KEY

		If Alltrim(_cAlias) $ "SD3/SD1/SE2"

			&(_cAlias)->(dbSetOrder(_nOrder))
			If &(_cAlias)->(dbSeek(Alltrim(TMP->CT2_KEY)))
				
				If Alltrim(_cAlias) == "SD3"
				
					_cSubItem	:= SD3->D3_YSUBITE
					
				ElseIf Alltrim(_cAlias) == "SD1"
					
					_cSubItem	:= SD1->D1_YSUBITE
				
				ElseIf Alltrim(_cAlias) == "SE2"
				
					_cSubItem	:= SE2->E2_YSUBITE
										
				Else
					
					RestArea(_aArea)
					
					Return()
					
				EndIf

				If !Empty(TMP->CT2_CLVLCR)
					
					TMP->CT2_YSUBCR := _cSubItem
					
				EndIf
				
				If !Empty(TMP->CT2_CLVLDB)
					
					TMP->CT2_YSUBDB := _cSubItem
					
				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(_aArea)

Return()