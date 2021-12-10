#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG149
@author Gabriel Rossi Mafioletti
@since 17/06/21
@version 1.1
@description Escalas de Trabalho para Orçamento  
@type function
/*/                                                                                               
User Function BIAFG149()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZOK") + SPACE(TAMSX3("ZOK_VERSAO")[1]) + SPACE(TAMSX3("ZOK_REVISA")[1]) + SPACE(TAMSX3("ZOK_ANOREF")[1])
	Local bWhile	    := {|| ZOK_FILIAL + ZOK_VERSAO + ZOK_REVISA + ZOK_ANOREF }

	Local aNoFields     := {"ZOK_VERSAO", "ZOK_REVISA", "ZOK_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZOK_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZOK_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZOK_ANOREF")[1])
	Private _oGAnoRef
	Private _msCtrlAlt := .T.  

	_aSize := MsAdvSize(.T.)      

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração"      , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_BFG149EX() }, "Importa Arquivo"        , "Importa Arquivo"})

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZOK",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Escalas de Trabalho para Orçamento" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBFG149A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBFG149B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBFG149C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE + GD_DELETE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999 /*[ nMax]*/, "U_FG149FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_FG149DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBFG149A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBFG149C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBFG149B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBFG149C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBFG149C()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
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
		fIntegra()
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZOK% ZOK
		WHERE ZOK_FILIAL = %xFilial:ZOK%
		AND ZOK_VERSAO = %Exp:_cVersao%
		AND ZOK_REVISA = %Exp:_cRevisa%
		AND ZOK_ANOREF = %Exp:_cAnoRef%
		AND ZOK.%NotDel%
		ORDER BY ZOK.ZOK_VERSAO, ZOK.ZOK_REVISA, ZOK.ZOK_ANOREF,ZOK_CODESC

	EndSql

	ProcRegua(0)

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno() ))))

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZOK_CODESC,;
			ZOK_DESCRI,;
			ZOK_HORAS,;
			"ZOK",;
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
	Local _msc
	//Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOK_REC_WT"})
	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1
	Local _cChave	:=	xFilial("ZOK") + _cVersao + _cRevisa + _cAnoRef
	Local _nPosEsc	:=	aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOK_CODESC"})

	If _msCtrlAlt

		dbSelectArea('ZOK')
		ZOK->(DbSetOrder(1))		

		For _nI	:=	1 to Len(_oGetDados:aCols)

			If !Empty(_oGetDados:aCols[_nI,_nPosEsc]) 

				If ZOK->(DbSeek(_cChave+_oGetDados:aCols[_nI,_nPosEsc]))

					Reclock("ZOK",.F.)
					If !_oGetDados:aCols[_nI,nPosDel]

						For _msc := 1 to Len(_oGetDados:aHeader)

							If _oGetDados:aHeader[_msc][10] == "R"

								nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
								&("ZOK->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

							EndIf

						Next _msc

					Else

						ZOK->(DbDelete())

					EndIf

					ZOK->(MsUnlock())

				Else

					If !_oGetDados:aCols[_nI,nPosDel]

						Reclock("ZOK",.T.)

						ZOK->ZOK_FILIAL  := xFilial("ZOK")
						ZOK->ZOK_VERSAO  := _cVersao
						ZOK->ZOK_REVISA  := _cRevisa
						ZOK->ZOK_ANOREF  := _cAnoRef
						For _msc := 1 to Len(_oGetDados:aHeader)

							If _oGetDados:aHeader[_msc][10] == "R"

								nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
								&("ZOK->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

							EndIf

						Next _msc

						ZOK->(MsUnlock())

					EndIf

				EndIf

			EndIf

		Next

	EndIf

	_cVersao		:=	SPACE(TAMSX3("ZOK_VERSAO")[1])
	_cRevisa		:=	SPACE(TAMSX3("ZOK_REVISA")[1])
	_cAnoRef		:=	SPACE(TAMSX3("ZOK_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	If _msCtrlAlt

		MsgInfo("Registro Incluído com Sucesso!")

	Else

		MsgALERT("Nenhum registro foi atualizado!")

	EndIf

Return

User Function FG149FOK()

Return .T.

User Function FG149DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de deleção

Return _lRet

Static Function fIntegra()

	Local _cAlias	:=	GetNextAlias()
	Local _cAliasSr	:=	"%" + U_fGetDbSr() + ".dbo.r006esc" + "%"

	BeginSql Alias _cAlias

		%NoParser%
		SELECT ESC.codesc CODESC
		,ESC.nomesc DESCRI
		FROM %Exp:_cAliasSr% ESC(NOLOCK)
		WHERE NOT EXISTS (
		SELECT 1
		FROM %TABLE:ZOK% ZOK(NOLOCK)
		WHERE ZOK.ZOK_FILIAL = %XFILIAL:ZOK%
		AND ZOK.ZOK_VERSAO = %Exp:_cVersao%
		AND ZOK.ZOK_REVISA = %Exp:_cRevisa%
		AND ZOK.ZOK_ANOREF = %Exp:_cAnoRef%
		AND ZOK.ZOK_CODESC = ESC.codesc
		AND ZOK.%NotDel%
		)
		ORDER BY 1

	EndSql

	While (_cAlias)->(!EOF())

		Reclock("ZOK",.T.)
		ZOK->ZOK_FILIAL	:=	xFilial("ZOK")
		ZOK->ZOK_VERSAO	:=	_cVersao
		ZOK->ZOK_REVISA	:=	_cRevisa
		ZOK->ZOK_ANOREF	:=	_cAnoRef
		ZOK->ZOK_CODESC	:=	Alltrim(Str((_cAlias)->CODESC)) // nao se poe zeros a esquerda porque a senior nao tem zeros a esquerda.PADL(Alltrim(Str((_cAlias)->CODESC)),TAMSX3("ZOK_CODESC")[1],"0")
		ZOK->ZOK_DESCRI	:=	UPPER((_cAlias)->DESCRI)
		ZOK->(MsUnlock())
		(_cAlias)->(DbSkip())
	EndDo
	(_cAlias)->(DbCloseArea())

Return

User Function BFG149EX()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fxPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de Horas para adicional Noturno"))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fxPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Índices...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fPrcImprtExc() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

//Parametros
Static Function fxPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'BFG149EX' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importação
Static Function fPrcImprtExc()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZOK'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb, ny, _msc, nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOK_REC_WT"})
	Local nPosEsc	  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOK_CODESC"})

	Local vtEscGrd := {}

	_ImpaColsBkp  := aClone(_oGetDados:aCols)

	For vnb := 1 to Len(_ImpaColsBkp)
		AADD(vtEscGrd, _ImpaColsBkp[vnb][nPosEsc])	
	Next vnb

	If Len(vtEscGrd) == 1
		nPrimeralin := _ImpaColsBkp[Len(_ImpaColsBkp)][nPosEsc]
		If nPrimeralin == 0
			_oGetDados:aCols := {}
		EndIf
	EndIf

	ProcRegua(0) 

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:NewGetArq(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If Len(aArquivo) > 0 

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		aWorksheet 	:= aArquivo[1]	
		nTotLin		:= len(aWorksheet)

		ProcRegua(nTotLin)

		For nx := 1 to len(aWorksheet) 

			IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

			If nx == 1

				aCampos := aWorksheet[nx]
				For ny := 1 to len(aCampos)
					cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp+'_',UPPER(aCampos[ny])),10)
					aCampos[ny] := cTemp
				Next ny

			Else

				aLinha    := aWorksheet[nx]
				aItem     := {}
				cConteudo := ''

				nLinReg   := 0
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZOK_REC_WT"})
				nPosEsc	  := aScan(aCampos,{|x| AllTrim(x) == "ZOK_CODESC"})

				If nPosEsc <> 0

					nLinReg := aScan(vtEscGrd,{|x| x == Alltrim(aLinha[nPosEsc])})
					If nLinReg == 0 //.or. Val(Alltrim(aLinha[nPosRec])) == 0

						AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
						nLinReg := Len(_oGetDados:aCols)

					EndIf				

					For _msc := 1 to Len(aCampos)

						If aCampos[_msc] <> "ZOK_REC_WT"

							xkPosCampo := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == aCampos[_msc]})
							If xkPosCampo <> 0
								If _oGetDados:aHeader[xkPosCampo][8] == "N"
									_oGetDados:aCols[nLinReg, xkPosCampo] := Val(Alltrim(aLinha[_msc]))
								ElseIf _oGetDados:aHeader[xkPosCampo][8] == "D"
									_oGetDados:aCols[nLinReg, xkPosCampo] := Stod(Alltrim(aLinha[_msc]))
								Else
									_oGetDados:aCols[nLinReg, xkPosCampo] := aLinha[_msc]
								EndIf
							EndIf

						EndIf

					Next _msc

					_oGetDados:aCols[nLinReg, Len(_oGetDados:aHeader)+1] := .F.	
					nImport ++

				Else

					MsgALERT("Erro no Layout do Arquivo de Importação!!!")
					nImport := 0
					Exit

				EndIf

			EndIf

		Next nx

	EndIf

	If nImport > 0 

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importação dos registros")
		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf

	RestArea(aArea)

Return
