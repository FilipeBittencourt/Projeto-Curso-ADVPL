#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA386
@author Marcos Alberto Soprani
@since 14/09/17
@version 1.0
@description Tela para cadastro de Controle de Versão Orçamentária 
@type function
/*/

User Function BIA386()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZB5") + SPACE(TAMSX3("ZB5_VERSAO")[1]) + SPACE(TAMSX3("ZB5_REVISA")[1]) + SPACE(TAMSX3("ZB5_ANOREF")[1])
	Local bWhile	    := {||  ZB5_FILIAL + ZB5_VERSAO + ZB5_REVISA + ZB5_ANOREF }                    
	Local aNoFields     := {}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _oComboBox1
	Private _nComboBox1 := ""
	Private _ItCombBox  := {"", "RH", "OBZ", "CAPEX", "RECEITA", "C.VARIAVEL", "CONTABIL"}
	Private xdMarcaSel  := SPACE(TAMSX3("ZBK_MARCA")[1])

	aAdd(_aButtons,{"HISTORIC",{|| U_B386LIBVER()}, "Cancela Integração CONTABIL", "Cancela Integração CONTABIL"})

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZB5",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Cadastro de Controle de Versão" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Orçamento:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,070 MSCOMBOBOX _oComboBox1 VAR _nComboBox1 ITEMS _ItCombBox SIZE 072, 012 OF _oDlg COLORS 0, 16777215 PIXEL VALID fBIA386A()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B386FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B386DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA386A()

	Local _cAlias	:=	GetNextAlias()

	If _nComboBox1 == ""
		MsgInfo("Favor selecionar um dos ORÇAMENTOS presentes na lista!!!")
		Return .F.
	EndIf

	If Alltrim(_nComboBox1) == "RH"
		If !U_ValOper("OR1", .T.)
			Return .F.
		EndIf
	ElseIf Alltrim(_nComboBox1) == "OBZ"
		If !U_ValOper("OR4", .T.)
			Return .F.
		EndIf
	Else
		If !U_ValOper("OR2", .T.)
			Return .F.
		EndIf
	EndIf

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND RTRIM(ZB5_TPORCT) = %Exp:Alltrim(_nComboBox1)%
		AND ZB5.%NotDel%
	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZB5_VERSAO,;
			ZB5_REVISA,;
			ZB5_ANOREF,;
			ZB5_STATUS,;
			stod(ZB5_DTDIGT),;
			stod(ZB5_DTCONS),;
			stod(ZB5_DTENCR),;
			ZB5_DRVATV,;
			"ZB5",;
			R_E_C_N_O_,;
			.F.	}))

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB5_REC_WT"})
	Local _mVERSAO := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB5_VERSAO"})
	Local _mREVISA := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB5_REVISA"})
	Local _mANOREF := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB5_ANOREF"})
	Local _mSTATUS := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB5_STATUS"})
	Local _mDTDIGT := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB5_DTDIGT"})
	Local _mDTCONS := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB5_DTCONS"})
	Local _mDTENCR := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB5_DTENCR"})
	Local _mDRVATV := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB5_DRVATV"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	dbSelectArea('ZB5')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZB5->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZB5",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				ZB5->ZB5_VERSAO := _oGetDados:aCols[_nI,_mVERSAO]
				ZB5->ZB5_REVISA := _oGetDados:aCols[_nI,_mREVISA]
				ZB5->ZB5_ANOREF := _oGetDados:aCols[_nI,_mANOREF]
				ZB5->ZB5_STATUS := _oGetDados:aCols[_nI,_mSTATUS]
				ZB5->ZB5_DTDIGT := _oGetDados:aCols[_nI,_mDTDIGT]
				ZB5->ZB5_DTCONS := _oGetDados:aCols[_nI,_mDTCONS]
				ZB5->ZB5_DTENCR := _oGetDados:aCols[_nI,_mDTENCR]
				ZB5->ZB5_DRVATV := _oGetDados:aCols[_nI,_mDRVATV]
				ZB5->ZB5_TPORCT := Alltrim(_nComboBox1)

			Else

				ZB5->(DbDelete())

			EndIf

			ZB5->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZB5",.T.)
				ZB5->ZB5_FILIAL := xFilial("ZB5")
				ZB5->ZB5_VERSAO := _oGetDados:aCols[_nI,_mVERSAO]
				ZB5->ZB5_REVISA := _oGetDados:aCols[_nI,_mREVISA]
				ZB5->ZB5_ANOREF := _oGetDados:aCols[_nI,_mANOREF]
				ZB5->ZB5_STATUS := _oGetDados:aCols[_nI,_mSTATUS]
				ZB5->ZB5_DTDIGT := _oGetDados:aCols[_nI,_mDTDIGT]
				ZB5->ZB5_DTCONS := _oGetDados:aCols[_nI,_mDTCONS]
				ZB5->ZB5_DTENCR := _oGetDados:aCols[_nI,_mDTENCR]
				ZB5->ZB5_DRVATV := _oGetDados:aCols[_nI,_mDRVATV]
				ZB5->ZB5_TPORCT := Alltrim(_nComboBox1)
				ZB5->(MsUnlock())

			EndIf

		EndIf

	Next

	_nComboBox1         := ""
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGetDados:Refresh()
	_oComboBox1:SetFocus()
	_oComboBox1:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B386FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _gbVERSAO := ""
	Local _gbREVISA := ""
	Local _gbANOREF := ""
	Local _gbStatus := GdFieldGet("ZB5_STATUS",_nAt)

	If _gbStatus == "F" .and. !(Alltrim(cMenVar) == "M->ZB5_DRVATV" .AND. Alltrim(_nComboBox1) == "CONTABIL")

		MsgSTOP("Status da versão orçamentária fechado por rotina automática. Não é permitido reabrí-lo!!!")
		Return .F.

	Else

		Do Case

			Case Alltrim(cMenVar) == "M->ZB5_VERSAO"
			_gbVERSAO := M->ZB5_VERSAO
			_gbREVISA := GdFieldGet("ZB5_REVISA",_nAt)
			_gbANOREF := GdFieldGet("ZB5_ANOREF",_nAt)

			Case Alltrim(cMenVar) == "M->ZB5_REVISA"
			_gbVERSAO := GdFieldGet("ZB5_VERSAO",_nAt)
			_gbREVISA := M->ZB5_REVISA
			_gbANOREF := GdFieldGet("ZB5_ANOREF",_nAt)

			Case Alltrim(cMenVar) == "M->ZB5_ANOREF"
			_gbVERSAO := GdFieldGet("ZB5_VERSAO",_nAt)
			_gbREVISA := GdFieldGet("ZB5_REVISA",_nAt)
			_gbANOREF := M->ZB5_ANOREF

			Case Alltrim(cMenVar) == "M->ZB5_STATUS"

		EndCase

		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _nI <> _nAt .and. !GDdeleted(_nI)

				If !Empty(_gbVERSAO) .and. _gbVERSAO == GdFieldGet("ZB5_VERSAO",_nI)

					If !Empty(_gbREVISA) .and. _gbREVISA == GdFieldGet("ZB5_REVISA",_nI)

						If !Empty(_gbANOREF) .and. _gbANOREF == GdFieldGet("ZB5_ANOREF",_nI)

							MsgInfo("Favor verificar, pois existem registros duplicados que impedem a confirmação do movimento!!!")
							Return .F.

						EndIf

					EndIf

				EndIf

			EndIf

		Next

	EndIf

	RestArea( vfArea )

Return .T.

User Function B386DOK()

	Local _lRet	:=	.T.
	Local _nAt		:=	_oGetDados:nAt
	If GdFieldGet("ZB5_STATUS",_nAt) <> " "

		MsgInfo("O registro está em produção ou já foi encerrado não sendo possível excluir o registros!!!")
		_lRet	:=	.F.

	EndIf

Return _lRet

User Function B386LIBVER()

	Local nfr
	Local _nAt      := _oGetDados:nAt
	Local _nVertor  := _oGetDados:aHeader

	Local _yyVERSAO
	Local _yyREVISA
	Local _yyANOREF
	Local _yySTATUS
	Local _yyPosSts

	If !U_VALOPER("T02")

		Return .F.

	Else

		fgContin := MsgYESNO("Você está prestes a executar o cancelamento da integração com a tabela ZBZ. Deseja continuar???")
		If !fgContin

			MsgALERT("O processamento de cancelamento de integração com tabela ZBZ foi abortado...")
			Return .F.

		EndIf

		If Alltrim(_nComboBox1) == "RECEITA"
			fPerg386()
		EndIf

	EndIf

	For nfr := 1 to Len(_nVertor)

		Do Case

			Case _oGetDados:aHeader[nfr][2] == "ZB5_VERSAO"
			_yyVERSAO := _oGetDados:aCols[_nAt][nfr]

			Case _oGetDados:aHeader[nfr][2] == "ZB5_REVISA"
			_yyREVISA := _oGetDados:aCols[_nAt][nfr]

			Case _oGetDados:aHeader[nfr][2] == "ZB5_ANOREF"
			_yyANOREF := _oGetDados:aCols[_nAt][nfr]

			Case _oGetDados:aHeader[nfr][2] == "ZB5_STATUS"
			_yySTATUS := _oGetDados:aCols[_nAt][nfr]
			_yyPosSts := nfr

		End Case

	Next nfr

	If _yySTATUS == "F"

		fgContin := MsgYESNO("Identificada integração de >>>>> " + Alltrim(_nComboBox1) + " <<<<< com o modelo de OrcaFinal. Confirma a exclusão???")

		If fgContin

			If Alltrim(_nComboBox1) <> "CONTABIL"

				KS001 := " DELETE " + RetSqlName("ZBZ") + " "
				KS001 += "   FROM " + RetSqlName("ZBZ") + " ZBZ "
				KS001 += "  WHERE ZBZ.ZBZ_VERSAO = '" + _yyVERSAO + "' "
				KS001 += "    AND ZBZ.ZBZ_REVISA = '" + _yyREVISA + "' "
				KS001 += "    AND ZBZ.ZBZ_ANOREF = '" + _yyANOREF + "' "
				KS001 += "    AND ZBZ.ZBZ_ORIPRC = '" + Alltrim(_nComboBox1) + "' "
				If !Empty(xdMarcaSel)
					KS001 += "    AND ZBZ.ZBZ_ORIPR2 = 'MARCA_" + xdMarcaSel + "' "
				EndIf
				KS001 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
				U_BIAMsgRun("Aguarde... Apagando registros ZBZ da empresa >>>>> " ,,{|| TcSQLExec(KS001) })

			Else

				KS001 := " DELETE " + RetSqlName("CV1") + " "
				KS001 += "   FROM " + RetSqlName("CV1") + " CV1 "
				KS001 += "  WHERE CV1.CV1_FILIAL = '" + xFilial("CV1") + "' "
				KS001 += "    AND CV1.CV1_DTINI >= '" + _yyANOREF + "0101' "
				KS001 += "    AND CV1.CV1_DTFIM <= '" + _yyANOREF + "1231' "
				KS001 += "    AND CV1.D_E_L_E_T_ = ' ' "
				U_BIAMsgRun("Aguarde... Apagando registros CV1... ",,{|| TcSQLExec(KS001) })

			EndIf

			_oGetDados:aCols[_nAt][_yyPosSts] := "A"

			MsgINFO("Integrações canceladas... Status alterado!!! Pode dar continuidade aos ajustes necessários...")

		Else

			MsgALERT("Processo abortado... Versão continua fechada!!!")

		EndIf

	Else

		MsgINFO("A versão selecionada não se encontra FECHADA. Não há nada a ser feito. Favor verificar!!!")

	EndIf

Return

//Parametros
Static Function fPerg386()

	Local aPergs 	:= {}
	Local cLoad	    := 'B386PERG' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	xdMarcaSel      := SPACE(TAMSX3("ZBK_MARCA")[1]) 

	aAdd( aPergs ,{1,"Marca:"                       ,xdMarcaSel    ,"@!","",''   ,'.T.', TAMSX3("ZBK_MARCA")[1],.F.})	

	If ParamBox(aPergs ,"Selecione uma MARCA",,,,,,,,cLoad,.T.,.T.)      
		xdMarcaSel    := ParamLoad(cFileName,,1,xdMarcaSel) 
	Endif

Return 
