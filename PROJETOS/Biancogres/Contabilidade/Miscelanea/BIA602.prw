#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA602
@author Wlysses Cerqueira (Facile)
@since 25/11/2020
@version 1.0
@description Kardex Orçado - Peso Rateio - Formato p/ Produto.
@type function
@Obs Projeto A-35
/*/

User Function BIA602()

	Local _aSize 		:= {}
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZO7") + SPACE(TAMSX3("ZO7_VERSAO")[1]) + SPACE(TAMSX3("ZO7_REVISA")[1]) + SPACE(TAMSX3("ZO7_ANOREF")[1])
	Local bWhile	    := {|| ZO7_FILIAL + ZO7_VERSAO + ZO7_REVISA + ZO7_ANOREF }

	Local aNoFields     := {"ZO7_VERSAO", "ZO7_REVISA", "ZO7_ANOREF", "ZO7_LINHA"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil

	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZO7_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZO7_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZO7_ANOREF")[1])
	Private _oGAnoRef
	Private _cDataRef	:= ctod("  /  /  ")
	Private _oGDataRef
	Private _oGHistFil

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B602IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZO7",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Kardex Orçado - Peso Rateio - Formato p/ Produto" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA602A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA602B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA602C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, "U_B602LOK()" /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_B602TOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B602DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons)

Return()

Static Function fBIA602A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return(.F.)
	EndIf

	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA602D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return(.T.)

Static Function fBIA602B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return(.F.)
	EndIf

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA602D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return()

Static Function fBIA602C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return(.F.)
	EndIf

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA602D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return()

Static Function fBIA602D()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Local _msc

	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return(.F.)
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual CONTABIL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e menor ou igual DataBase" + msrhEnter
	xfMensCompl += "Data Conciliação igual branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'CONTABIL'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
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

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *,
		(SELECT COUNT(*)
		FROM %TABLE:ZO7% ZO7
		WHERE ZO7_FILIAL = %xFilial:ZO7%
		AND ZO7_VERSAO = %Exp:_cVersao%
		AND ZO7_REVISA = %Exp:_cRevisa%
		AND ZO7_ANOREF = %Exp:_cAnoRef%
		AND ZO7.%NotDel%
		) NUMREG
		FROM %TABLE:ZO7% ZO7
		WHERE ZO7_FILIAL = %xFilial:ZO7%
		AND ZO7_VERSAO = %Exp:_cVersao%
		AND ZO7_REVISA = %Exp:_cRevisa%
		AND ZO7_ANOREF = %Exp:_cAnoRef%
		AND ZO7.%NotDel%
		ORDER BY ZO7_VERSAO, ZO7_REVISA, ZO7_ANOREF, ZO7_PRODUT

	EndSql

	xtrTot :=  (_cAlias)->(NUMREG)
	ProcRegua(xtrTot)

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO7_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZO7"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO7_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				Else
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := &(Alltrim(_oGetDados:aHeader[_msc][2]))

				EndIf			
			Next _msc
			_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := .F.	

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	_oGetDados:Refresh()

Return(.T.)

Static Function fGrvDados()

	Local _nI
	Local _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZO7_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1

	dbSelectArea('ZO7')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZO7->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))

			Reclock("ZO7",.F.)

			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] <> "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO7->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					ElseIf _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] == "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO7->" + Alltrim(_oGetDados:aHeader[_msc][2])) := IIF( Valtype(_oGetDados:aCols[_nI, nPosColG]) == "D", _oGetDados:aCols[_nI, nPosColG], ctod(_oGetDados:aCols[_nI, nPosColG]) )

					EndIf

				Next _msc

			Else

				ZO7->(DbDelete())

			EndIf

			ZO7->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZO7",.T.)

				ZO7->ZO7_FILIAL  := xFilial("ZO7")
				ZO7->ZO7_VERSAO  := _cVersao
				ZO7->ZO7_REVISA  := _cRevisa
				ZO7->ZO7_ANOREF  := _cAnoRef

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] <> "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO7->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					ElseIf _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] == "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO7->" + Alltrim(_oGetDados:aHeader[_msc][2])) := IIF( Valtype(_oGetDados:aCols[_nI, nPosColG]) == "D", _oGetDados:aCols[_nI, nPosColG], ctod(_oGetDados:aCols[_nI, nPosColG]) )

					EndIf

				Next _msc

				ZO7->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao := SPACE(TAMSX3("ZO7_VERSAO")[1])
	_cRevisa := SPACE(TAMSX3("ZO7_REVISA")[1])
	_cAnoRef := SPACE(TAMSX3("ZO7_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return()

User Function B602TOK()

	Local cMenVar    := ReadVar()
	Local _nAt       := _oGetDados:nAt

	If !GDdeleted(_nAt)

		Do Case

			Case Alltrim(cMenVar) == "M->ZO7_PRODUT"
			dbSelectArea("SB1")
			dbSetOrder(1)
			If !SB1->(dbSeek(xFilial("SB1") + M->ZO7_PRODUT))
				MsgINFO("Produto Inexistente. Informe um produto válido!!!")
				Return(.F.)
			EndIf

		EndCase

	EndIf

Return(.T.)

User Function B602LOK()

	Local _lRet	:=	.T.

Return(_lRet)

User Function B602DOK()

	Local _lRet	:=	.T.

Return(_lRet)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B602IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B602IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação dos ajustes orçamentário direto para a tabela ZO7."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi("               * O nome do arquivo não pode ter espaço ou caracter especial"))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Índices...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fPrcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf

Return()

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B602IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return()

//Processa importação
Static Function fPrcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZO7'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb
	Local ny
	Local _msc
	Local nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZO7_REC_WT"})
	Local vtRecGrd := {}

	_ImpaColsBkp  := aClone(_oGetDados:aCols)

	For vnb := 1 to Len(_ImpaColsBkp)
		AADD(vtRecGrd, _ImpaColsBkp[vnb][nPosRec])	
	Next vnb

	If Len(vtRecGrd) == 1
		nPrimeralin := _ImpaColsBkp[Len(_ImpaColsBkp)][nPosRec]
		If nPrimeralin == 0
			_oGetDados:aCols := {}
		EndIf
	EndIf

	ProcRegua(0) 

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZO7_REC_WT"})

				If nPosRec <> 0

					nLinReg := aScan(vtRecGrd,{|x| x == Val(Alltrim(aLinha[nPosRec]))})
					If nLinReg == 0 .or. Val(Alltrim(aLinha[nPosRec])) == 0

						AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
						nLinReg := Len(_oGetDados:aCols)

					EndIf				

					For _msc := 1 to Len(aCampos)

						xkPosCampo := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == aCampos[_msc]})
						If xkPosCampo <> 0
							If _oGetDados:aHeader[xkPosCampo][8] == "N"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Val(Alltrim(aLinha[_msc]))
							Else
								_oGetDados:aCols[nLinReg, xkPosCampo] := aLinha[_msc]
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

Return()
