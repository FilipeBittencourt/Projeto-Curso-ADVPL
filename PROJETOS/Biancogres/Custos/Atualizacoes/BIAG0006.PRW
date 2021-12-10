#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAG0006
@author Gabriel Rossi Mafioletti
@since 23/11/2021
@version 1.1
@description Médias do Orçamento Variável  
@type function
/*/                                                                                               
User Function BIAG0006()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZOO") + SPACE(TAMSX3("ZOO_VERSAO")[1]) + SPACE(TAMSX3("ZOO_REVISA")[1]) + SPACE(TAMSX3("ZOO_ANOREF")[1])
	Local bWhile	    := {|| ZOO_FILIAL + ZOO_VERSAO + ZOO_REVISA + ZOO_ANOREF }

	Local aNoFields     := {"ZOO_VERSAO", "ZOO_REVISA", "ZOO_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZOO_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZOO_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZOO_ANOREF")[1])
	Private _oGAnoRef
	Private _msCtrlAlt := .T.  

	_aSize := MsAdvSize(.T.)      

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração"      , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_BG006EX() }, "Importa Arquivo"        , "Importa Arquivo"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_BG006PRC() }, "Processamento"        , "Processamento"})


	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZOO",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Médias do Orçamento Variável" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBG006A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBG006B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBG006C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE + GD_DELETE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999 /*[ nMax]*/, "U_G06FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_G06DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBG006A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBG006C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBG006B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBG006C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBG006C()

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
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	//TODO Definir a trava do orçamento pois não existe
	If (M001)->CONTAD <> 0
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

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZOO% ZOO
		WHERE ZOO_FILIAL = %xFilial:ZOO%
		AND ZOO_VERSAO = %Exp:_cVersao%
		AND ZOO_REVISA = %Exp:_cRevisa%
		AND ZOO_ANOREF = %Exp:_cAnoRef%
		AND ZOO.%NotDel%
		ORDER BY ZOO.ZOO_VERSAO, ZOO.ZOO_REVISA, ZOO.ZOO_ANOREF,ZOO_ITCUS,ZOO_FORMAT

	EndSql

	ProcRegua(0)

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno() ))))

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZOO_ITCUS,;
			ZOO_FORMAT,;
			ZOO_MED01,;
			ZOO_UMED01,;
			ZOO_MED02,;
			ZOO_UMED02,;
			ZOO_MED03,;
			ZOO_UMED03,;
			ZOO_MED04,;
			ZOO_UMED04,;
			ZOO_MED05,;
			ZOO_UMED05,;
			ZOO_MED06,;
			ZOO_UMED06,;
			ZOO_MED07,;
			ZOO_UMED07,;
			ZOO_MED08,;
			ZOO_UMED08,;
			ZOO_MED09,;
			ZOO_UMED09,;
			ZOO_MED10,;
			ZOO_UMED10,;
			ZOO_MED11,;
			ZOO_UMED11,;
			ZOO_MED12,;
			ZOO_UMED12,;
			"ZOO",;
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
	//Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOO_REC_WT"})
	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1
	Local _cChave	:=	xFilial("ZOO") + _cVersao + _cRevisa + _cAnoRef
	Local _nPosItC	:=	aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOO_ITCUS"})
	Local _nPosForm	:=	aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOO_FORMAT"})


	If _msCtrlAlt

		dbSelectArea('ZOO')
		ZOO->(DbSetOrder(1))		

		For _nI	:=	1 to Len(_oGetDados:aCols)

			If ZOO->(DbSeek(_cChave+_oGetDados:aCols[_nI,_nPosItC]+_oGetDados:aCols[_nI,_nPosForm]))

				Reclock("ZOO",.F.)
				If !_oGetDados:aCols[_nI,nPosDel]

					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZOO->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

				Else

					ZOO->(DbDelete())

				EndIf

				ZOO->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZOO",.T.)

					ZOO->ZOO_FILIAL  := xFilial("ZOO")
					ZOO->ZOO_VERSAO  := _cVersao
					ZOO->ZOO_REVISA  := _cRevisa
					ZOO->ZOO_ANOREF  := _cAnoRef
					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZOO->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

					ZOO->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao		:=	SPACE(TAMSX3("ZOO_VERSAO")[1])
	_cRevisa		:=	SPACE(TAMSX3("ZOO_REVISA")[1])
	_cAnoRef		:=	SPACE(TAMSX3("ZOO_ANOREF")[1])
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

User Function G06FOK()

Return .T.

User Function G06DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de deleção

Return _lRet

User Function BG006EX()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fxPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de Médias do Orçamento Variável"))   
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
	Local cLoad	    := 'BG006EX' + cEmpAnt
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
	Local cTabImp			:= 'ZOO'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb, ny, _msc, nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOO_REC_WT"})
	Local nPosItC	  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOO_ITCUS"})
	Local nPosForm	  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOO_FORMAT"})


	Local vtChvGrd := {}

	_ImpaColsBkp  := aClone(_oGetDados:aCols)

	For vnb := 1 to Len(_ImpaColsBkp)
		AADD(vtChvGrd, {_ImpaColsBkp[vnb][nPosItC],_ImpaColsBkp[vnb][nPosForm]})	
	Next vnb

	If Len(vtChvGrd) == 1
		nPrimeralin := Len(_ImpaColsBkp[Len(_ImpaColsBkp)][nPosForm])
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZOO_REC_WT"})
				nPosItC	  := aScan(aCampos,{|x| AllTrim(x) == "ZOO_ITCUS"})
				nPosForm	  := aScan(aCampos,{|x| AllTrim(x) == "ZOO_FORMAT"})


				If nPosItC <> 0

					nLinReg := aScan(vtChvGrd,{|x| x[1] == Alltrim(aLinha[nPosItC]) .And. x[2] == Alltrim(aLinha[nPosForm])})
					If nLinReg == 0 //.or. Val(Alltrim(aLinha[nPosRec])) == 0

						AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
						nLinReg := Len(_oGetDados:aCols)

					EndIf				

					For _msc := 1 to Len(aCampos)

						If aCampos[_msc] <> "ZOO_REC_WT"

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

User Function BG006PRC()

	If _msCtrlAlt 
		If MsgNoYes("O Processamento Irá Excluir eventuais Dados Referentes aos parâmetros do Orçamento caso Existam. Deseja Prosseguir?")
			U_BIAMsgRun("Aguarde... Processando...",,{|| fProcessa() })
		EndIf
	Else
		MsgStop("Impossível Processar pois não é possível realizar alteração!")
	EndIf
Return


Static Function fProcessa()

	Local _aRecnos	:=	fGetRegs()
	Local _cQuery	:=	""
	Local _cAlias
	Local _aDados	
	Local _nPos
	Local _cDel	
	
	_cDel	:=	" DELETE FROM " + RetSqlName("ZOO")
	_cDel	+=	" WHERE ZOO_VERSAO = " + ValtoSql(_cVersao)
	_cDel	+=	" 	AND ZOO_REVISA = " + ValtoSql(_cRevisa)
	_cDel	+=	" 	AND ZOO_ANOREF = " + ValtoSql(_cAnoRef)
	_cDel	+=	" 	AND D_E_L_E_T_ = '' " 

	
	TcSqlExec(_cDel)
	
	If Len(_aRecnos) > 0
	
		For _nI	:= 1 To Len(_aRecnos)
	
			ZON->(DbGoto(_aRecnos[_nI]))
			IF ZON->(!EOF())
				_cQuery	:=	fMakeQry(ZON->ZON_QUERY)
				If (TCSQLEXEC(_cQuery) <> 0)
					MsgStop("ERRO AO EXECUTAR NIVEL: " + Alltrim(ZON->ZON_NIVEL) + " ITCUS: " + Alltrim(ZON->ZON_ITCUS) + " SEQ: " + ALLTRIM(ZON->ZON_SEQUEN) + CRLF+;
						TCSQLError(),"BIAG0006")
				Else
					_cAlias	:=	GetNextAlias()
					BeginSql Alias _cAlias
						%NoParser%
						SELECT *
						FROM ##REALVAR
					EndSql
					_aDados	:=	{}
					While (_cAlias)->(!EOF())
						_nPos	:=	aScan(_aDados,{|x| x[1] == (_cAlias)->ITCUS .And. x[2] == (_cAlias)->FORMATO})
						If _nPos > 0
							_aDados[_nPos,3]	+=	(_cAlias)->VLR01
							_aDados[_nPos,4]	+=	(_cAlias)->QTD01
							_aDados[_nPos,5]	+=	(_cAlias)->VLR02
							_aDados[_nPos,6]	+=	(_cAlias)->QTD02
							_aDados[_nPos,7]	+=	(_cAlias)->VLR03
							_aDados[_nPos,8]	+=	(_cAlias)->QTD03
							_aDados[_nPos,9]	+=	(_cAlias)->VLR04
							_aDados[_nPos,10]	+=	(_cAlias)->QTD04
							_aDados[_nPos,11]	+=	(_cAlias)->VLR05
							_aDados[_nPos,12]	+=	(_cAlias)->QTD05
							_aDados[_nPos,13]	+=	(_cAlias)->VLR06
							_aDados[_nPos,14]	+=	(_cAlias)->QTD06
							_aDados[_nPos,15]	+=	(_cAlias)->VLR07
							_aDados[_nPos,16]	+=	(_cAlias)->QTD07
							_aDados[_nPos,17]	+=	(_cAlias)->VLR08
							_aDados[_nPos,18]	+=	(_cAlias)->QTD08
							_aDados[_nPos,19]	+=	(_cAlias)->VLR09
							_aDados[_nPos,20]	+=	(_cAlias)->QTD09
							_aDados[_nPos,21]	+=	(_cAlias)->VLR10
							_aDados[_nPos,22]	+=	(_cAlias)->QTD10
							_aDados[_nPos,23]	+=	(_cAlias)->VLR11
							_aDados[_nPos,24]	+=	(_cAlias)->QTD11
							_aDados[_nPos,25]	+=	(_cAlias)->VLR12
							_aDados[_nPos,26]	+=	(_cAlias)->QTD12
						Else
							aAdd(_aDados,{;
							(_cAlias)->ITCUS,;
							(_cAlias)->FORMATO,;
							(_cAlias)->VLR01,;
							(_cAlias)->QTD01,;
							(_cAlias)->VLR02,;
							(_cAlias)->QTD02,;
							(_cAlias)->VLR03,;
							(_cAlias)->QTD03,;
							(_cAlias)->VLR04,;
							(_cAlias)->QTD04,;
							(_cAlias)->VLR05,;
							(_cAlias)->QTD05,;
							(_cAlias)->VLR06,;
							(_cAlias)->QTD06,;
							(_cAlias)->VLR07,;
							(_cAlias)->QTD07,;
							(_cAlias)->VLR08,;
							(_cAlias)->QTD08,;
							(_cAlias)->VLR09,;
							(_cAlias)->QTD09,;
							(_cAlias)->VLR10,;
							(_cAlias)->QTD10,;
							(_cAlias)->VLR11,;
							(_cAlias)->QTD11,;
							(_cAlias)->VLR12,;
							(_cAlias)->QTD12,;
							})
						EndIf
						(_cAlias)->(DbSkip())
					EndDo
					(_cAlias)->(DbCloseArea())
					If Len(_aDados) > 0
						For _nJ	:= 1 to Len(_aDados)
						
							Reclock("ZOO",.T.)
							ZOO->ZOO_FILIAL	:=	xFilial("ZOO")
							ZOO->ZOO_VERSAO	:=	_cVersao
							ZOO->ZOO_REVISA	:=	_cRevisa
							ZOO->ZOO_ANOREF	:=	_cAnoRef
							ZOO->ZOO_ITCUS	:=	_aDados[_nJ,1]
							ZOO->ZOO_FORMAT	:=	_aDados[_nJ,2]
							ZOO->ZOO_MED01	:=	Iif(_aDados[_nJ,4] > 0,_aDados[_nJ,3]/_aDados[_nJ,4],0)
							ZOO->ZOO_MED02	:=	Iif(_aDados[_nJ,6] > 0,_aDados[_nJ,5]/_aDados[_nJ,6],0)
							ZOO->ZOO_MED03	:=	Iif(_aDados[_nJ,8] > 0,_aDados[_nJ,7]/_aDados[_nJ,8],0)
							ZOO->ZOO_MED04	:=	Iif(_aDados[_nJ,10] > 0,_aDados[_nJ,9]/_aDados[_nJ,10],0)
							ZOO->ZOO_MED05	:=	Iif(_aDados[_nJ,12] > 0,_aDados[_nJ,11]/_aDados[_nJ,12],0)
							ZOO->ZOO_MED06	:=	Iif(_aDados[_nJ,14] > 0,_aDados[_nJ,13]/_aDados[_nJ,14],0)
							ZOO->ZOO_MED07	:=	Iif(_aDados[_nJ,16] > 0,_aDados[_nJ,15]/_aDados[_nJ,16],0)
							ZOO->ZOO_MED08	:=	Iif(_aDados[_nJ,18] > 0,_aDados[_nJ,17]/_aDados[_nJ,18],0)
							ZOO->ZOO_MED09	:=	Iif(_aDados[_nJ,20] > 0,_aDados[_nJ,19]/_aDados[_nJ,20],0)
							ZOO->ZOO_MED10	:=	Iif(_aDados[_nJ,22] > 0,_aDados[_nJ,21]/_aDados[_nJ,22],0)
							ZOO->ZOO_MED11	:=	Iif(_aDados[_nJ,24] > 0,_aDados[_nJ,23]/_aDados[_nJ,24],0)
							ZOO->ZOO_MED12	:=	Iif(_aDados[_nJ,26] > 0,_aDados[_nJ,25]/_aDados[_nJ,26],0)
							ZOO->(MsUnlock())	
						Next
					EndIf
				EndIF
			EndIf		
		Next
	
		_oGetDados:aCols	:=	{}
	
		_cAlias	:=	GetNextAlias()
	
		BeginSql Alias _cAlias
	
			SELECT *
			FROM %TABLE:ZOO% ZOO
			WHERE ZOO_FILIAL = %xFilial:ZOO%
			AND ZOO_VERSAO = %Exp:_cVersao%
			AND ZOO_REVISA = %Exp:_cRevisa%
			AND ZOO_ANOREF = %Exp:_cAnoRef%
			AND ZOO.%NotDel%
			ORDER BY ZOO.ZOO_VERSAO, ZOO.ZOO_REVISA, ZOO.ZOO_ANOREF,ZOO_ITCUS,ZOO_FORMAT
	
		EndSql
	
		If (_cAlias)->(!Eof())
	
			While (_cAlias)->(!Eof())
	
				(_cAlias)->(aAdd(_oGetDados:aCols,{ZOO_ITCUS,;
				ZOO_FORMAT,;
				ZOO_MED01,;
				ZOO_UMED01,;
				ZOO_MED02,;
				ZOO_UMED02,;
				ZOO_MED03,;
				ZOO_UMED03,;
				ZOO_MED04,;
				ZOO_UMED04,;
				ZOO_MED05,;
				ZOO_UMED05,;
				ZOO_MED06,;
				ZOO_UMED06,;
				ZOO_MED07,;
				ZOO_UMED07,;
				ZOO_MED08,;
				ZOO_UMED08,;
				ZOO_MED09,;
				ZOO_UMED09,;
				ZOO_MED10,;
				ZOO_UMED10,;
				ZOO_MED11,;
				ZOO_UMED11,;
				ZOO_MED12,;
				ZOO_UMED12,;
				"ZOO",;
				R_E_C_N_O_,;
				.F.	}))
	
				(_cAlias)->(dbSkip())
	
			EndDo
	
			(_cAlias)->(dbCloseArea())
	
		EndIf	
	
		_oGetDados:Refresh()
	
	EndIf
	


Return


Static Function fMakeQry(_cQuery)

	Local nPosQP
	Local msTamVar
	Local msAlias
	Local _cDataIni	:=	Alltrim(Str(VAL(_cAnoRef) - 1))+'0101'
	Local _cDataFim	:=	Alltrim(Str(VAL(_cAnoRef) - 1))+'1231'
	Local _cItCIni
	Local _cItCFim

	If !Empty(_cQuery)
	
		While "@ALIAS" $ _cQuery
			nPosQP = AT("@ALIAS#", _cQuery)
			msTamVar := Len("@ALIAS#")
			If nPosQP > 0
				msAlias := Substr(_cQuery, nPosQP + msTamVar, 3) 
				_cQuery = Replace(_cQuery, Substr(_cQuery, nPosQP, 3 + msTamVar) , RetSqlName(msAlias))
			Else
				Exit
			EndIf
		End

		While "@XFILIAL" $ _cQuery
			nPosQP = AT("@XFILIAL#", _cQuery)
			msTamVar := Len("@XFILIAL#")
			If nPosQP > 0
				msAlias := Substr(_cQuery, nPosQP + msTamVar, 3) 
				_cQuery = Replace(_cQuery, Substr(_cQuery, nPosQP, 3 + msTamVar) , xFilial(msAlias))
			Else
				Exit
			EndIf
		End

		If	EMPTY(ZON->ZON_ITCUS)
			_cItCIni	:=	""
			_cItCFim	:=	'ZZZ'
		Else
			_cItCIni	:=	ZON->ZON_ITCUS
			_cItCFim	:=	ZON->ZON_ITCUS
		EndIf
		
		_cQuery := Replace(_cQuery, "@DATAINI" , _cDataIni)
		_cQuery := Replace(_cQuery, "@DATAFIM" , _cDataFim)
		_cQuery := Replace(_cQuery, "@ITCUSINI" , _cItCIni)
		_cQuery := Replace(_cQuery, "@ITCUSFIM" , _cItCFim)
		_cQuery := Replace(_cQuery, "@VERSAO" , _cVersao)
		_cQuery := Replace(_cQuery, "@REVISAO" , _cRevisa)
		_cQuery := Replace(_cQuery, "@ANOREF" , _cAnoRef)		

	EndIf

	

Return _cQuery

Static Function fGetRegs()

	Local _aRecs	:=	{}
	Local _cAlias	:=	GetNextAlias()
	
	BeginSql Alias _cAlias
	
		SELECT R_E_C_N_O_ REG
		FROM %TABLE:ZON% ZON
		WHERE ZON_FILIAL = %XFILIAL:ZON%
			AND ZON_SEQUEN = '1'
			AND ZON_NIVEL = '1'
			AND %NotDel%
	
	EndSql
	
	While (_cAlias)->(!EOF())
		aAdd(_aRecs,(_cAlias)->REG)
		(_cAlias)->(DbSkip())
	EndDo
	(_cAlias)->(DbCloseArea())
Return _aRecs