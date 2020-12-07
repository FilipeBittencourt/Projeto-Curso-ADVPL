#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA371
@author Marcos Alberto Soprani
@since 17/09/19
@version 1.0
@description Tela para input do Benefícios Adicionais por Categoria 
@type function
/*/

User Function BIA371()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBD") + SPACE(TAMSX3("ZBD_VERSAO")[1]) + SPACE(TAMSX3("ZBD_REVISA")[1]) + SPACE(TAMSX3("ZBD_ANOREF")[1])
	Local bWhile	    := {|| ZBD_FILIAL + ZBD_VERSAO + ZBD_REVISA + ZBD_ANOREF }                    
	Local aNoFields     := {"ZBD_VERSAO", "ZBD_REVISA", "ZBD_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBD_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBD_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBD_ANOREF")[1])
	Private _oGAnoRef
	Private _msCtrlAlt := .T.  

	aAdd(_aButtons,{"PRODUTO"  ,{|| U_BIA393("E")} , "Layout Integração"          , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"   ,{|| U_B371IEXC() } , "Importa Arquivo"            , "Importa Arquivo"})
	aAdd(_aButtons,{"AUTOM"    ,{|| U_B371RPLC() } , "Replica Registros"          , "Replica Registros"})

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBD",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Benefícios Adicionais p/ Categoria" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA371A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA371B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA371C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, "U_B371TOK()" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B371FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B371DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA371A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA371C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA371B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA371C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA371C()

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
		_oGetDados:lInsert := .F.
		_oGetDados:lUpdate := .T.
		_oGetDados:lDelete := .F.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZBD% ZBD
		INNER JOIN %TABLE:ZB4% ZB4 ON ZB4_CATEGF = ZBD_CATEGF
		AND ZB4.%NotDel%
		WHERE ZBD_FILIAL = %xFilial:ZBD%
		AND ZBD_VERSAO = %Exp:_cVersao%
		AND ZBD_REVISA = %Exp:_cRevisa%
		AND ZBD_ANOREF = %Exp:_cAnoRef%
		AND ZBD.%NotDel%
		ORDER BY ZBD.ZBD_FILIAL, ZBD.ZBD_CATEGF
	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZBD_CATEGF,;
			ZB4_DESCRI,;
			ZBD_BNC002,;
			ZBD_BNC005,;
			ZBD_BNC010,;
			ZBD_BNCB05,;
			ZBD_BNCB10,;
			ZBD_BNCB15,;
			ZBD_BNCB20,;
			ZBD_BNCB25,;
			ZBD_BNCB30,;
			ZBD_BNCB35,;
			ZBD_BNCB40,;
			ZBD_BNCC05,;
			ZBD_BNCC10,;
			"ZBD",;
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

	Local nPosRec   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_REC_WT"})
	Local _msCATEGF := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_CATEGF"})
	Local _msDESCCF := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_DESCCF"})
	Local _msBNC002 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNC002"})
	Local _msBNC005 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNC005"})
	Local _msBNC010 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNC010"})
	Local _msBNCB05 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNCB05"})
	Local _msBNCB10 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNCB10"})
	Local _msBNCB15 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNCB15"})
	Local _msBNCB20 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNCB20"})
	Local _msBNCB25 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNCB25"})
	Local _msBNCB30 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNCB30"})
	Local _msBNCB35 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNCB35"})
	Local _msBNCB40 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNCB40"})
	Local _msBNCC05 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNCC05"})
	Local _msBNCC10 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_BNCC10"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1

	If _msCtrlAlt

		dbSelectArea('ZBD')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZBD->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				If !_oGetDados:aCols[_nI,nPosDel]

					If ZBD->ZBD_VERSAO == _cVersao .and. ZBD->ZBD_REVISA == _cRevisa .and. ZBD->ZBD_ANOREF == _cAnoRef
						Reclock("ZBD",.F.)
					Else
						Reclock("ZBD",.T.)
						ZBD->ZBD_FILIAL  := xFilial("ZBD")
						ZBD->ZBD_VERSAO  := _cVersao
						ZBD->ZBD_REVISA  := _cRevisa
						ZBD->ZBD_ANOREF  := _cAnoRef
					EndIf
					ZBD->ZBD_CATEGF := _oGetDados:aCols[_nI,_msCATEGF]
					ZBD->ZBD_DESCCF := _oGetDados:aCols[_nI,_msDESCCF]
					ZBD->ZBD_BNC002 := _oGetDados:aCols[_nI,_msBNC002]
					ZBD->ZBD_BNC005 := _oGetDados:aCols[_nI,_msBNC005]
					ZBD->ZBD_BNC010 := _oGetDados:aCols[_nI,_msBNC010]
					ZBD->ZBD_BNCB05 := _oGetDados:aCols[_nI,_msBNCB05]
					ZBD->ZBD_BNCB10 := _oGetDados:aCols[_nI,_msBNCB10]
					ZBD->ZBD_BNCB15 := _oGetDados:aCols[_nI,_msBNCB15]
					ZBD->ZBD_BNCB20 := _oGetDados:aCols[_nI,_msBNCB20]
					ZBD->ZBD_BNCB25 := _oGetDados:aCols[_nI,_msBNCB25]
					ZBD->ZBD_BNCB30 := _oGetDados:aCols[_nI,_msBNCB30]
					ZBD->ZBD_BNCB35 := _oGetDados:aCols[_nI,_msBNCB35]
					ZBD->ZBD_BNCB40 := _oGetDados:aCols[_nI,_msBNCB40]
					ZBD->ZBD_BNCC05 := _oGetDados:aCols[_nI,_msBNCC05]
					ZBD->ZBD_BNCC10 := _oGetDados:aCols[_nI,_msBNCC10]
					ZBD->(MsUnlock())

				Else

					Reclock("ZBD",.F.)
					ZBD->(DbDelete())
					ZBD->(MsUnlock())

				EndIf

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZBD",.T.)
					ZBD->ZBD_FILIAL := xFilial("ZBD")
					ZBD->ZBD_VERSAO := _cVersao
					ZBD->ZBD_REVISA := _cRevisa
					ZBD->ZBD_ANOREF := _cAnoRef
					ZBD->ZBD_CATEGF := _oGetDados:aCols[_nI,_msCATEGF]
					ZBD->ZBD_DESCCF := _oGetDados:aCols[_nI,_msDESCCF]
					ZBD->ZBD_BNC002 := _oGetDados:aCols[_nI,_msBNC002]
					ZBD->ZBD_BNC005 := _oGetDados:aCols[_nI,_msBNC005]
					ZBD->ZBD_BNC010 := _oGetDados:aCols[_nI,_msBNC010]
					ZBD->ZBD_BNCB05 := _oGetDados:aCols[_nI,_msBNCB05]
					ZBD->ZBD_BNCB10 := _oGetDados:aCols[_nI,_msBNCB10]
					ZBD->ZBD_BNCB15 := _oGetDados:aCols[_nI,_msBNCB15]
					ZBD->ZBD_BNCB20 := _oGetDados:aCols[_nI,_msBNCB20]
					ZBD->ZBD_BNCB25 := _oGetDados:aCols[_nI,_msBNCB25]
					ZBD->ZBD_BNCB30 := _oGetDados:aCols[_nI,_msBNCB30]
					ZBD->ZBD_BNCB35 := _oGetDados:aCols[_nI,_msBNCB35]
					ZBD->ZBD_BNCB40 := _oGetDados:aCols[_nI,_msBNCB40]
					ZBD->ZBD_BNCC05 := _oGetDados:aCols[_nI,_msBNCC05]
					ZBD->ZBD_BNCC10 := _oGetDados:aCols[_nI,_msBNCC10]
					ZBD->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao		    :=	SPACE(TAMSX3("ZBD_VERSAO")[1])
	_cRevisa		    :=	SPACE(TAMSX3("ZBD_REVISA")[1])
	_cAnoRef		    :=	SPACE(TAMSX3("ZBD_ANOREF")[1])
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

User Function B371FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _ColunaM  := Right(Alltrim(cMenVar),3)

	If !&(Alltrim(cMenVar)) $ "***/" + _ColunaM
		MsgInfo("Preenchimento incorreto do campo. Somente pode ser preenchido com < *** > ou com as três últimas letras no nome do campo - para saber o nome do campo, de <enter> no campo e aperte <F1> !!!")
		Return .F.
	EndIf

Return .T.

User Function B371DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de deleção

Return _lRet

User Function B371TOK()

	Local _lRet      := .T.

	// Sem necessidade inicial de controle de Tudo Ok

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B371IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Comissãos REC.I ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B371IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	If !_msCtrlAlt

		MsgInfo("Não é permitido importar dados porque a Versão orçamentária está bloquada.")
		Return

	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação dos percentuais de Comissão para Orçamento RECEITA."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação dos percentuais...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B371IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZBD'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb, ny, _msc, nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBD_REC_WT"})
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZBD_REC_WT"})

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

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B371RPLC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/09/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Replicando Registros da Versão Anterior para Corrente      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B371RPLC()

	Local M002        := GetNextAlias()

	If !_msCtrlAlt

		MsgInfo("Não é permitido importar dados porque a Versão orçamentária está bloquada.")
		Return

	EndIf

	If !Empty(_oGetDados:aCols[1][1])

		MsgInfo("Não é permitido importar dados porque já existem registros contidos nesta revisão.")
		Return

	EndIf

	_oGetDados:aCols	:=	{}

	BeginSql Alias M002

		SELECT *
		FROM %TABLE:ZBD% ZBD
		INNER JOIN %TABLE:ZB4% ZB4 ON ZB4_CATEGF = ZBD_CATEGF
		AND ZB4.%NotDel%		
		WHERE ZBD_VERSAO+ZBD_REVISA+ZBD_ANOREF = (SELECT MAX(ZBD_VERSAO+ZBD_REVISA+ZBD_ANOREF)
		FROM %TABLE:ZBD% ZBD
		WHERE ZBD_ANOREF < %Exp:_cAnoRef%
		AND ZBD.%NotDel%)
		AND ZBD.%NotDel%
		ORDER BY ZBD.ZBD_VERSAO, ZBD.ZBD_REVISA, ZBD.ZBD_ANOREF, ZBD.ZBD_CATEGF

	EndSql

	If (M002)->(!Eof())

		While (M002)->(!Eof())

			(M002)->(aAdd(_oGetDados:aCols,{ZBD_CATEGF,;
			ZB4_DESCRI,;
			ZBD_BNC002,;
			ZBD_BNC005,;
			ZBD_BNC010,;
			ZBD_BNCB05,;
			ZBD_BNCB10,;
			ZBD_BNCB15,;
			ZBD_BNCB20,;
			ZBD_BNCB25,;
			ZBD_BNCB30,;
			ZBD_BNCB35,;
			ZBD_BNCB40,;
			ZBD_BNCC05,;
			ZBD_BNCC10,;
			"ZBD",;
			0,;
			.F.	}))

			(M002)->(dbSkip())

		EndDo

		(M002)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	_oGetDados:Refresh()

	MsgINFO("Replica efetuada com sucesso. Para concluir a gravação é necessário clicar em Confirmar.")

Return
