#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA382
@author Marcos Alberto Soprani
@since 13/09/17
@version 1.0
@description Tela para cadastro dos Custos de Exames/Uniformes/EPIs 
@type function
/*/

User Function BIA382()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZB0") + SPACE(TAMSX3("ZB0_VERSAO")[1]) + SPACE(TAMSX3("ZB0_REVISA")[1]) + SPACE(TAMSX3("ZB0_ANOREF")[1])
	Local bWhile	    := {|| ZB0_FILIAL + ZB0_VERSAO + ZB0_REVISA + ZB0_ANOREF }

	Local aNoFields     := {"ZB0_VERSAO", "ZB0_REVISA", "ZB0_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZB0_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZB0_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZB0_ANOREF")[1])
	Private _oGAnoRef
	Private _msCtrlAlt := .T.  

	aAdd(_aButtons,{"PRODUTO"  ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"   ,{|| U_B382IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})
	aAdd(_aButtons,{"AUTOM"    ,{|| U_B382RPLC() }, "Replica Registros" , "Replica Registros"})

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZB0",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Custo de Exames/Uniformes/EPIs" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA382A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA382B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA382C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_INSERT + GD_UPDATE + GD_DELETE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999 /*[ nMax]*/, "U_B382FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B382DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA382A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA382C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA382B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA382C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA382C()

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
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZB0% ZB0
		WHERE ZB0_FILIAL = %xFilial:ZB0%
		AND ZB0_VERSAO = %Exp:_cVersao%
		AND ZB0_REVISA = %Exp:_cRevisa%
		AND ZB0_ANOREF = %Exp:_cAnoRef%
		AND ZB0.%NotDel%
		ORDER BY ZB0.ZB0_VERSAO, ZB0.ZB0_REVISA, ZB0.ZB0_ANOREF, ZB0.ZB0_MATR

	EndSql

	ProcRegua(0)

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno() ))))

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZB0_MATR,;
			Posicione("ZO0", 1, xFilial("ZO0") + _cVersao + _cRevisa + _cAnoRef + ZB0_MATR, "ZO0_NOME" ),;
			ZB0_CLVL,;
			ZB0_MESANI,;
			ZB0_MESADM,;
			ZB0_VEXAME,;
			ZB0_VUNIFO,;
			ZB0_RTUNIF,;
			ZB0_VEPI,;
			"ZB0",;
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

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB0_REC_WT"})
	Local _mMATR   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB0_MATR"})
	Local _mCLVL   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB0_CLVL"})
	Local _mMESANI := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB0_MESANI"})
	Local _mMESADM := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB0_MESADM"})
	Local _mVEXAME := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB0_VEXAME"})
	Local _mVUNIFO := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB0_VUNIFO"})
	Local _mRTUNIF := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB0_RTUNIF"})
	Local _mVEPI   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB0_VEPI"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZB0')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZB0->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				If !_oGetDados:aCols[_nI,nPosDel]

					If ZB0->ZB0_VERSAO == _cVersao .and. ZB0->ZB0_REVISA == _cRevisa .and. ZB0->ZB0_ANOREF == _cAnoRef
						Reclock("ZB0",.F.)
					Else
						Reclock("ZB0",.T.)
						ZB0->ZB0_FILIAL  := xFilial("ZB0")
						ZB0->ZB0_VERSAO  := _cVersao
						ZB0->ZB0_REVISA  := _cRevisa
						ZB0->ZB0_ANOREF  := _cAnoRef
					EndIf
					ZB0->ZB0_MATR    := _oGetDados:aCols[_nI,_mMATR]
					ZB0->ZB0_CLVL    := _oGetDados:aCols[_nI,_mCLVL]
					ZB0->ZB0_MESANI  := _oGetDados:aCols[_nI,_mMESANI]
					ZB0->ZB0_MESADM  := _oGetDados:aCols[_nI,_mMESADM]
					ZB0->ZB0_VEXAME  := _oGetDados:aCols[_nI,_mVEXAME]
					ZB0->ZB0_VUNIFO  := _oGetDados:aCols[_nI,_mVUNIFO]
					ZB0->ZB0_RTUNIF  := _oGetDados:aCols[_nI,_mRTUNIF]
					ZB0->ZB0_VEPI    := _oGetDados:aCols[_nI,_mVEPI]
					ZB0->(MsUnlock())

				Else

					Reclock("ZB0",.F.)
					ZB0->(DbDelete())
					ZB0->(MsUnlock())

				EndIf

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZB0",.T.)
					ZB0->ZB0_FILIAL  := xFilial("ZB0")
					ZB0->ZB0_VERSAO  := _cVersao
					ZB0->ZB0_REVISA  := _cRevisa
					ZB0->ZB0_ANOREF  := _cAnoRef
					ZB0->ZB0_MATR    := _oGetDados:aCols[_nI,_mMATR]
					ZB0->ZB0_CLVL    := _oGetDados:aCols[_nI,_mCLVL]
					ZB0->ZB0_MESANI  := _oGetDados:aCols[_nI,_mMESANI]
					ZB0->ZB0_MESADM  := _oGetDados:aCols[_nI,_mMESADM]
					ZB0->ZB0_VEXAME  := _oGetDados:aCols[_nI,_mVEXAME]
					ZB0->ZB0_VUNIFO  := _oGetDados:aCols[_nI,_mVUNIFO]
					ZB0->ZB0_RTUNIF  := _oGetDados:aCols[_nI,_mRTUNIF]
					ZB0->ZB0_VEPI    := _oGetDados:aCols[_nI,_mVEPI]
					ZB0->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao		:=	SPACE(TAMSX3("ZB0_VERSAO")[1])
	_cRevisa		:=	SPACE(TAMSX3("ZB0_REVISA")[1])
	_cAnoRef		:=	SPACE(TAMSX3("ZB0_ANOREF")[1])
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

User Function B382FOK()

	Local cMenVar   := ReadVar()
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _zpMatr   := ""

	Do Case

		Case Alltrim(cMenVar) == "M->ZB0_MATR"
		_zpMatr := M->ZB0_MATR

		ZO0->(dbSetOrder(1))
		ZO0->(dbSeek(xFilial("ZO0") + _cVersao + _cRevisa + _cAnoRef + M->ZB0_MATR))
		_mMesNasc := StrZero(Month(ZO0->ZO0_DATNAS + 30),2)
		_mMesAdmi := StrZero(Month(ZO0->ZO0_ADMISS ),2)

		GdFieldPut("ZB0_NOME"   , ZO0->ZO0_NOME  , _nAt)
		GdFieldPut("ZB0_CLVL"   , ZO0->ZO0_CLVL  , _nAt)
		GdFieldPut("ZB0_MESANI" , _mMesNasc      , _nAt)
		GdFieldPut("ZB0_MESADM" , _mMesAdmi      , _nAt)

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_zpMatr) .and. _zpMatr == GdFieldGet("ZB0_MATR",_nI)

				MsgInfo("Não poderá haver a mesma matricula informada mais de uma vez na lista. Na linha: " + Alltrim(Str(_nI)) + " já existe a matricula informada!!!")
				Return .F.

			EndIf

		EndIf

	Next

Return .T.

User Function B382DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de deleção

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B382IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/09/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento -  SESMET         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B382IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	If !_msCtrlAlt

		MsgInfo("Não é permitido importar dados porque a Versão orçamentária está bloquada.")
		Return

	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de Índices de Variação do C.UNITÁRIO"))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Índices...'), aSays, aButtons ,,,500)

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
	Local cLoad	    := 'B382IEXC' + cEmpAnt
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
	Local cTabImp			:= 'ZB0'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB0_REC_WT"})
	Local vtRecGrd := {}

	Local vnb
	Local ny
	Local _msc
	Local nx

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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZB0_REC_WT"})

				azPosMat  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB0_MATR"})
				vtMatPos  := aScan(aCampos,{|x| AllTrim(x) == "ZB0_MATR"})

				If nPosRec <> 0

					nLinReg := aScan(vtRecGrd,{|x| x == Val(Alltrim(aLinha[nPosRec]))})
					If nLinReg == 0 .or. Val(Alltrim(aLinha[nPosRec])) == 0

						nLinChave := aScan(_oGetDados:aCols,{|x| Alltrim(x[azPosMat]) == Alltrim(aLinha[vtMatPos]) })
						If nLinChave <> 0

							MsgINFO("O chave [Matricula] oriundo do excel, já existe na tela. Linha: " + Alltrim(Str(nLinChave)) + " :[ " + aLinha[vtMatPos] + " ]. O registro será desconsiderado. Atenciosamente!!!")

						Else

							AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
							nLinReg := Len(_oGetDados:aCols)

						EndIf

					EndIf				

					xSMatTxt := Space(6)
					For _msc := 1 to Len(aCampos)

						xkPosCampo := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == aCampos[_msc]})
						If xkPosCampo <> 0

							If Alltrim(aCampos[_msc]) == "ZB0_MATR"
								If _oGetDados:aHeader[xkPosCampo][8] == "N"
									_oGetDados:aCols[nLinReg, xkPosCampo] := StrZero(aLinha[_msc],6)
								Else
									_oGetDados:aCols[nLinReg, xkPosCampo] := StrZero(Val(Alltrim(aLinha[_msc])),6)
								EndIf
								xSMatTxt := _oGetDados:aCols[nLinReg, xkPosCampo]
							ElseIf Alltrim(aCampos[_msc]) == "ZB0_NOME"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Posicione("ZO0", 1, xFilial("ZO0") + _cVersao + _cRevisa + _cAnoRef + xSMatTxt, "ZO0_NOME" )
							ElseIf Alltrim(aCampos[_msc]) == "ZB0_CLVL"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Posicione("ZO0", 1, xFilial("ZO0") + _cVersao + _cRevisa + _cAnoRef + xSMatTxt, "ZO0_CLVL" )
							ElseIf Alltrim(aCampos[_msc]) == "ZB0_MESANI"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Substr(dtos(Posicione("ZO0", 1, xFilial("ZO0") + _cVersao + _cRevisa + _cAnoRef + xSMatTxt, "ZO0_DATNAS" )),5,2)
							ElseIf Alltrim(aCampos[_msc]) == "ZB0_MESADM"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Substr(dtos(Posicione("ZO0", 1, xFilial("ZO0") + _cVersao + _cRevisa + _cAnoRef + xSMatTxt, "ZO0_ADMISS" )),5,2)
							ElseIf _oGetDados:aHeader[xkPosCampo][8] == "N"
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
¦¦¦Funçao    ¦ B382RPLC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09/09/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Replicando Registros da Versão Anterior para Corrente      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B382RPLC()

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

		SELECT ZO0_MAT,
		ZO0_NOME, 
		ZO0_CLVL, 
		SUBSTRING(ZO0_DATNAS, 5, 2) MASANI, 
		SUBSTRING(ZO0_ADMISS, 5, 2) MESADM, 
		ISNULL(ZB0_VEXAME, 0) ZB0_VEXAME, 
		ISNULL(ZB0_VUNIFO, 0) ZB0_VUNIFO, 
		ISNULL(ZB0_RTUNIF, "1") ZB0_RTUNIF, 
		ISNULL(ZB0_VEPI, 0) ZB0_VEPI
		FROM %TABLE:ZO0% ZO0
		LEFT JOIN (SELECT *
		FROM %TABLE:ZB0% ZB0
		WHERE ZB0_FILIAL = %xFilial:ZB0%
		AND ZB0_VERSAO + ZB0_REVISA + ZB0_ANOREF = (SELECT MAX(ZB0_VERSAO + ZB0_REVISA + ZB0_ANOREF)
		FROM %TABLE:ZB0% ZB0
		WHERE ZB0_FILIAL = %xFilial:ZB0%
		AND ZB0_ANOREF < %Exp:_cAnoRef%
		AND ZB0.D_E_L_E_T_ = ' ')
		AND ZB0.D_E_L_E_T_ = ' ') A ON A.ZB0_MATR = ZO0.ZO0_MAT
		WHERE ZO0_FILIAL = %Exp:xFilial("ZO0")%
		AND ZO0_VERSAO = %Exp:_cVersao%
		AND ZO0_REVISA = %Exp:_cRevisa%
		AND ZO0_ANOREF = %Exp:_cAnoRef%
		AND ZO0.D_E_L_E_T_ = ' '
		ORDER BY ZO0_MAT

	EndSql

	If (M002)->(!Eof())

		While (M002)->(!Eof())

			(M002)->(aAdd(_oGetDados:aCols,{ZO0_MAT,;
			ZO0_NOME,;
			ZO0_CLVL,;
			MASANI,;
			MESADM,;
			ZB0_VEXAME,;
			ZB0_VUNIFO,;
			ZB0_RTUNIF,;
			ZB0_VEPI,;
			"ZB0",;
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
