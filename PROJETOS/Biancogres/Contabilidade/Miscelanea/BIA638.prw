#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA638
@author Wlysses Cerqueira (Facile)
@since 18/12/2020
@version 1.0
@description Tela para cadastro de variáveis diversas que servirão de base para algum cálculo no processo orçamentário 
@type function
/*/

User Function BIA638()

	Local _aSize 		:= {}
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}
	Local _aCols		:= {}
	Local _aButtons	    := {}

	Local cSeek	        := xFilial("ZOE") + Space(TamSX3("ZOE_VERSAO")[1]) + Space(TamSX3("ZOE_REVISA")[1]) + Space(TamSX3("ZOE_ANOREF")[1])
	Local bWhile	    := {|| ZOE_FILIAL + ZOE_VERSAO + ZOE_REVISA + ZOE_ANOREF }
	Local aNoFields     := {"ZOE_VERSAO", "ZOE_REVISA", "ZOE_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0

	Private _oDlg       := Nil
	Private _oGetDados	:= Nil
	Private _oGVersao   := Nil
	Private _oGRevisa   := Nil
	Private _oGAnoRef   := Nil

	Private _cVersao	:= Space(TamSX3("ZOE_VERSAO")[1])
	Private _cRevisa	:= Space(TamSX3("ZOE_REVISA")[1])
	Private _cAnoRef	:= Space(TamSX3("ZOE_ANOREF")[1])

	Private _msCtrlAlt := .F.

	_aSize := MsAdvSize(.T.)

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZOE",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)

	Define MsDialog _oDlg Title "Cadastro de Variáveis Diversas" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA638A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA638B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA638C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, "+++ZOE_SEQUEN" /*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B638FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B638DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons)

Return()

Static Function fBIA638A()

	If Empty(_cVersao)

		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")

		Return(.F.)

	EndIf

	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF

	If !Empty(_cVersao) .And. !Empty(_cRevisa) .And. !Empty(_cAnoRef)

		_oGetDados:oBrowse:SetFocus()

		Processa({ || fBIA638C() }, "Aguarde...", "Carregando dados...",.F.)

	EndIf

Return(.T.)

Static Function fBIA638B()

	If Empty(_cRevisa)

		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")

		Return(.F.)

	EndIf

	If !Empty(_cVersao) .And. !Empty(_cRevisa) .And. !Empty(_cAnoRef)

		_oGetDados:oBrowse:SetFocus()

		Processa({ || fBIA638C() }, "Aguarde...", "Carregando dados...",.F.)

	EndIf

Return()

Static Function fBIA638C()

	Local _cAlias       := GetNextAlias()
	Local M001          := GetNextAlias()
	Private msrhEnter   := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)

		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")

		Return(.F.)

	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RH" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação igual a branco" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001

		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RH'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT = ''
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%

	EndSql

	(M001)->(dbGoTop())

	If (M001)->CONTAD <> 1

		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")

		_msCtrlAlt := .F.

		_oGetDados:lInsert := .F.
		_oGetDados:lUpdate := .F.
		_oGetDados:lDelete := .F.

	Else

		_msCtrlAlt := .T.

		_oGetDados:lInsert := .T.
		_oGetDados:lUpdate := .T.
		_oGetDados:lDelete := .T.

	EndIf

	(M001)->(dbCloseArea())

	_oGetDados:aCols :=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZOE% ZOE
		WHERE ZOE_FILIAL = %xFilial:ZOE%
		AND ZOE_VERSAO   = %Exp:_cVersao%
		AND ZOE_REVISA   = %Exp:_cRevisa%
		AND ZOE_ANOREF   = %Exp:_cAnoRef%
		AND ZOE.%NotDel%

	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,;
				{;
				(_cAlias)->ZOE_SEQUEN,;
				(_cAlias)->ZOE_VARIAV,;
				(_cAlias)->ZOE_DESCR,;
				(_cAlias)->ZOE_MES01,;
				(_cAlias)->ZOE_MES02,;
				(_cAlias)->ZOE_MES03,;
				(_cAlias)->ZOE_MES04,;
				(_cAlias)->ZOE_MES05,;
				(_cAlias)->ZOE_MES06,;
				(_cAlias)->ZOE_MES07,;
				(_cAlias)->ZOE_MES08,;
				(_cAlias)->ZOE_MES09,;
				(_cAlias)->ZOE_MES10,;
				(_cAlias)->ZOE_MES11,;
				(_cAlias)->ZOE_MES12,;
				"ZOE",;
				R_E_C_N_O_,;
				.F.;
				}))

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		(_cAlias)->(aAdd(_oGetDados:aCols, {"001", "ySomaSaldoAntRec"		, "Valor a Ser Somado ao Saldo Anterior a Receber (posso ser negativo ou positivo conforme necessidade de ajuste"	, -20000000.00000000    , 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"002", "yPercRecSaldoAnterior"	, "Percetual a ser aplicado sobre o Saldo Anterior a Receber"                                                       ,  0.32000000 		    , 0.18000000 	, 0.12000000 	, 0.03000000 	, 0.03000000 	, 0.03000000 	, 0.02000000 	, 0.01000000 	, 0.01000000 	, 0.03000000 	, 0.00500000 	, 0.00000000   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"003", "yPercAplcMesesOrca"	    , "Percentual a ser aplicado sobre os Recebíveis do Tempo Orçamentário - Fora MES"                                  ,  0.35000000 		    , 0.30000000 	, 0.25000000 	, 0.05000000 	, 0.03000000 	, 0.01000000 	, 0.01000000    , 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"004", "yGiroMedio"			    , "Giro Médio para cálculo de rubricas do BP"                                                                       ,  1.00000000 		    , 2.00000000 	, 3.00000000 	, 4.00000000 	, 5.00000000 	, 6.00000000 	, 7.00000000 	, 8.00000000 	, 9.00000000 	, 10.00000000 	, 11.00000000 	, 12.00000000  , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"005", "yDiasDeCaixa"			, "Días de Caixa para cálculo de rubricas do BP"                                                                    ,  13.13314723		    , 1.70000000 	, 1.70000000 	, 1.70000000 	, 1.70000000 	, 1.70000000 	, 1.70000000 	, 1.70000000 	, 1.70000000 	, 1.70000000 	, 1.70000000 	, 1.70000000   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"006", "yGiroFornecedor"		, "Giro de Fornecedor para cálculo da rubricas 21102"                                                               ,  23.00000000		    , 15.00000000 	, 10.00000000 	, 7.00000000 	, 6.00000000 	, 5.00000000 	, 4.00000000 	, 3.50000000 	, 3.00000000 	, 3.00000000 	, 2.50000000 	, 2.50000000   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"007", "yProj11101"			    , "Percentual para Projeção da rubrica Específica 11101"                                                            ,  0.01000000 		    , 0.01000000 	, 0.01000000 	, 0.01000000 	, 0.01000000 	, 0.01000000 	, 0.01000000 	, 0.01000000 	, 0.01000000 	, 0.01000000 	, 0.01000000 	, 0.01000000   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"008", "yProj11102"			    , "Percentual para Projeção da rubrica Específica 11102"                                                            ,  0.99000000 		    , 0.99000000 	, 0.99000000 	, 0.99000000 	, 0.99000000 	, 0.99000000 	, 0.99000000 	, 0.99000000 	, 0.99000000 	, 0.99000000 	, 0.99000000 	, 0.99000000   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"009", "yProj11104"			    , "Percentual para Projeção da rubrica Específica 11104"                                                            , -0.01000000 		    , -0.01000000 	, -0.01000000 	, -0.01000000 	, -0.01000000 	, -0.01000000 	, -0.01000000 	, -0.01000000 	, -0.01000000 	, -0.01000000 	, -0.01000000 	, -0.01000000  , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"010", "yProj11202"			    , "Percentual para Projeção da rubrica Específica 11202"                                                            ,  0.03200000 		    , 0.03000000 	, 0.02500000 	, 0.03000000 	, 0.02800000 	, 0.02800000 	, 0.03000000 	, 0.01500000 	, 0.01500000 	, 0.01500000 	, 0.01500000 	, 0.01500000   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"011", "yProj11203"			    , "Percentual para Projeção da rubrica Específica 11203"                                                            ,  0.00116271 		    , 0.00116271 	, 0.00116271 	, 0.00116271 	, 0.00116271 	, 0.00116271 	, 0.00116271 	, 0.00116271 	, 0.00116271 	, 0.00116271 	, 0.00116271 	, 0.00116271   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"012", "yProj11204"			    , "Percentual para Projeção da rubrica Específica 11204"                                                            ,  0.20819706 		    , 0.20819706 	, 0.20819706 	, 0.20819706 	, 0.20819706 	, 0.20819706 	, 0.20819706 	, 0.20819706 	, 0.20819706 	, 0.20819706 	, 0.20819706 	, 0.20819706   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"013", "yProj11301"			    , "Percentual para Projeção da rubrica Específica 11301"                                                            ,  0.42956162 		    , 0.42956162 	, 0.42956162 	, 0.42956162 	, 0.42956162 	, 0.42956162 	, 0.42956162 	, 0.42956162 	, 0.42956162 	, 0.42956162 	, 0.42956162 	, 0.42956162   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"014", "yProj11302"			    , "Percentual para Projeção da rubrica Específica 11302"                                                            ,  0.15316781 		    , 0.15316781 	, 0.15316781 	, 0.15316781 	, 0.15316781 	, 0.15316781 	, 0.15316781 	, 0.15316781 	, 0.15316781 	, 0.15316781 	, 0.15316781 	, 0.15316781   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"015", "yProj11303"			    , "Percentual para Projeção da rubrica Específica 11303"                                                            ,  0.03584621 		    , 0.03584621 	, 0.03584621 	, 0.03584621 	, 0.03584621 	, 0.03584621 	, 0.03584621 	, 0.03584621 	, 0.03584621 	, 0.03584621 	, 0.03584621 	, 0.03584621   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"016", "yProj11304"			    , "Percentual para Projeção da rubrica Específica 11304"                                                            ,  0.18698118 		    , 0.18698118 	, 0.18698118 	, 0.18698118 	, 0.18698118 	, 0.18698118 	, 0.18698118 	, 0.18698118 	, 0.18698118 	, 0.18698118 	, 0.18698118 	, 0.18698118   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"017", "yProj11305"			    , "Percentual para Projeção da rubrica Específica 11305"                                                            ,  0.19444319 		    , 0.19444319 	, 0.19444319 	, 0.19444319 	, 0.19444319 	, 0.19444319 	, 0.19444319 	, 0.19444319 	, 0.19444319 	, 0.19444319 	, 0.19444319 	, 0.19444319   , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"018", "yProj21106"			    , "Percentual para Projeção da rubrica Específica 21106"                                                            , -0.63000000 		    , -0.70000000 	, -0.49000000 	, -0.55000000 	, -0.55000000 	, -0.55000000 	, -0.55000000 	, -0.55000000	, -0.55000000 	, -0.55000000 	, -0.55000000	, -0.55000000  , "ZOE", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"019", "yProj21108"			    , "Percentual para Projeção da rubrica Específica 21108"                                                            , -0.33000000 	        , 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000	, 0.00000000   , "ZOE", 0, .F. }))

	EndIf

	_oGetDados:Refresh()

Return(.T.)

Static Function fGrvDados()

	Local _nI       := 0
	Local nPosRec   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_REC_WT"})
	Local nPosDel   :=	Len(_oGetDados:aHeader) + 1

	If _msCtrlAlt

		DBSelectArea('ZOE')

		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZOE->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))

				Reclock("ZOE",.F.)

				If !_oGetDados:aCols[_nI,nPosDel]

					ZOE->ZOE_SEQUEN := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_SEQUEN"})]
					ZOE->ZOE_VARIAV := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_VARIAV"})]
					ZOE->ZOE_DESCR  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_DESCR" })]
					ZOE->ZOE_MES01  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES01" })]
					ZOE->ZOE_MES02  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES02" })]
					ZOE->ZOE_MES03  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES03" })]
					ZOE->ZOE_MES04  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES04" })]
					ZOE->ZOE_MES05  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES05" })]
					ZOE->ZOE_MES06  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES06" })]
					ZOE->ZOE_MES07  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES07" })]
					ZOE->ZOE_MES08  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES08" })]
					ZOE->ZOE_MES09  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES09" })]
					ZOE->ZOE_MES10  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES10" })]
					ZOE->ZOE_MES11  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES11" })]
					ZOE->ZOE_MES12  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES12" })]

				Else

					ZOE->(DbDelete())

				EndIf

				ZOE->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZOE",.T.)
					ZOE->ZOE_FILIAL := xFilial("ZOE")
					ZOE->ZOE_VERSAO := _cVersao
					ZOE->ZOE_REVISA := _cRevisa
					ZOE->ZOE_ANOREF := _cAnoRef
					ZOE->ZOE_SEQUEN := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_SEQUEN"})]
					ZOE->ZOE_VARIAV := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_VARIAV"})]
					ZOE->ZOE_DESCR  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_DESCR" })]
					ZOE->ZOE_MES01  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES01" })]
					ZOE->ZOE_MES02  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES02" })]
					ZOE->ZOE_MES03  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES03" })]
					ZOE->ZOE_MES04  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES04" })]
					ZOE->ZOE_MES05  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES05" })]
					ZOE->ZOE_MES06  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES06" })]
					ZOE->ZOE_MES07  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES07" })]
					ZOE->ZOE_MES08  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES08" })]
					ZOE->ZOE_MES09  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES09" })]
					ZOE->ZOE_MES10  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES10" })]
					ZOE->ZOE_MES11  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES11" })]
					ZOE->ZOE_MES12  := _oGetDados:aCols[_nI, aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOE_MES12" })]
					ZOE->(MsUnlock())

				EndIf

			EndIf

		Next _nI

	EndIf

	_cVersao := Space(TamSX3("ZOE_VERSAO")[1])
	_cRevisa := Space(TamSX3("ZOE_REVISA")[1])
	_cAnoRef := Space(TamSX3("ZOE_ANOREF")[1])

	_oGetDados:aCols :=	{}

	_oGetDados:AddLine(.F., .F.)

	_oGVersao:SetFocus()

	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	If _msCtrlAlt

		MsgInfo("Registro Incluído com Sucesso!")

	Else

		Alert("Registros não incluidos!")

	EndIf

Return()

User Function B638FOK()

	// Local cMenVar   := ReadVar()
	// Local vfArea    := GetArea()
	// Local _cAlias   := ""
	// Local _nAt		:= _oGetDados:nAt
	// Local _nI       := 0
	// Local _gbVCHEIO := 0

Return(.T.)

User Function B638DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de deleção

Return(_lRet)
