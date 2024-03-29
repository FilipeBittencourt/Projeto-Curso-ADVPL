#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA630
@author Marcos Alberto Soprani
@since 28/09/17
@version 1.0
@description Tela para cadastro do �ndice de Varia��o da Quantidade da Pre-Estrutura 
@type function
/*/

User Function BIA630()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBR") + SPACE(TAMSX3("ZBR_VERSAO")[1]) + SPACE(TAMSX3("ZBR_REVISA")[1]) + SPACE(TAMSX3("ZBR_ANOREF")[1])
	Local bWhile	    := {|| ZBR_FILIAL + ZBR_VERSAO + ZBR_REVISA + ZBR_ANOREF }   

	Local aNoFields     := {"ZBR_VERSAO", "ZBR_REVISA", "ZBR_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBR_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBR_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBR_ANOREF")[1])
	Private _oGAnoRef

	Private _msCtrlAlt := .T.  

	//aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A")}, "Exporta p/Excel"   , "Exporta p/Excel"})
	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integra��o" , "Layout Integra��o"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B630IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B630EXCL() }, "Exclui Registros"   , "Exclui Registros"})	


	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBR",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Ajustes de Quantidade para Custo Vari�vel" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Vers�o:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA630A()

	@ 050,110 SAY "Revis�o:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA630B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA630C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_B630FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B630DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA630A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Vers�o � Obrigat�rio!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA630D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA630B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revis�o � Obrigat�rio!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA630D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA630C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano � Obrigat�rio!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA630D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA630D()

	Local _msc
	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)	

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Or�amento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digita��o diferente de branco" + msrhEnter
	xfMensCompl += "Data Concilia��o diferente de branco e menor ou igual a DataBase" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTCONS <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A vers�o informada n�o est� ativa para execu��o deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de vers�o conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o respons�vel pelo processo Or�ament�rio!!!")
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
		FROM %TABLE:ZBR% ZBR
		WHERE ZBR_FILIAL = %xFilial:ZBR%
		AND ZBR_VERSAO = %Exp:_cVersao%
		AND ZBR_REVISA = %Exp:_cRevisa%
		AND ZBR_ANOREF = %Exp:_cAnoRef%
		AND ZBR.%NotDel%
		) NUMREG
		FROM %TABLE:ZBR% ZBR
		WHERE ZBR_FILIAL = %xFilial:ZBR%
		AND ZBR_VERSAO = %Exp:_cVersao%
		AND ZBR_REVISA = %Exp:_cRevisa%
		AND ZBR_ANOREF = %Exp:_cAnoRef%
		AND ZBR.%NotDel%
		ORDER BY ZBR_VERSAO, ZBR_REVISA, ZBR_ANOREF, ZBR_COD, ZBR_COMP
	EndSql

	xtrTot :=  (_cAlias)->(NUMREG)
	ProcRegua(xtrTot)

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBR_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZBR"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBR_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBR_DCOD"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Substr(Posicione("SB1", 1, xFilial("SB1") + (_cAlias)->ZBR_COD,  "B1_DESC"), 1, 100)

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBR_DCOMP"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Substr(Posicione("SB1", 1, xFilial("SB1") + (_cAlias)->ZBR_COMP, "B1_DESC"), 1, 100)

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

Return .T.

Static Function fGrvDados()

	Local _nI

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBR_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	
	
	Local _msc

	dbSelectArea('ZBR')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZBR->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZBR",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZBR->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

			Else

				ZBR->(DbDelete())

			EndIf

			ZBR->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZBR",.T.)

				ZBR->ZBR_FILIAL  := xFilial("ZBR")
				ZBR->ZBR_VERSAO  := _cVersao
				ZBR->ZBR_REVISA  := _cRevisa
				ZBR->ZBR_ANOREF  := _cAnoRef
				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZBR->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

				ZBR->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao        := SPACE(TAMSX3("ZBR_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZBR_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZBR_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Inclu�do com Sucesso!")

Return

User Function B630FOK()

	Local cMenVar    := ReadVar()
	Local vfArea     := GetArea()
	Local _cAlias
	Local _nAt       := _oGetDados:nAt
	Local _nI
	Local _zpCOD     := ""
	Local _zpCOMP    := ""
	Local _zpTRT     := ""
	Local _zpINIREV  := ""
	Local _zpFIMREV  := ""

	Do Case

		Case Alltrim(cMenVar) == "M->ZBR_COD"
		_zpCOD     := M->ZBR_COD
		_zpCOMP    := GdFieldGet("ZBR_COMP",_nAt)
		_zpTRT     := GdFieldGet("ZBR_TRT",_nAt)
		_zpINIREV  := GdFieldGet("ZBR_REVINI",_nAt)
		_zpFIMREV  := GdFieldGet("ZBR_REVFIM",_nAt)
		GdFieldPut("ZBR_DCOD"     , Substr(Posicione("SB1", 1, xFilial("SB1") + _zpCOD , "B1_DESC"), 1, 100) , _nAt)

		Case Alltrim(cMenVar) == "M->ZBR_COMP"
		_zpCOD     := GdFieldGet("ZBR_COD",_nAt)
		_zpCOMP    := M->ZBR_COMP
		_zpTRT     := GdFieldGet("ZBR_TRT",_nAt)
		_zpINIREV  := GdFieldGet("ZBR_REVINI",_nAt)
		_zpFIMREV  := GdFieldGet("ZBR_REVFIM",_nAt)
		GdFieldPut("ZBR_DCOMP"    , Substr(Posicione("SB1", 1, xFilial("SB1") + _zpCOMP, "B1_DESC"), 1, 100) , _nAt)

		Case Alltrim(cMenVar) == "M->ZBR_TRT"
		_zpCOD     := GdFieldGet("ZBR_COD",_nAt)
		_zpCOMP    := GdFieldGet("ZBR_COMP",_nAt)
		_zpTRT     := M->ZBR_TRT
		_zpINIREV  := GdFieldGet("ZBR_REVINI",_nAt)
		_zpFIMREV  := GdFieldGet("ZBR_REVFIM",_nAt)

		Case Alltrim(cMenVar) == "M->ZBR_REVINI"
		_zpCOD     := GdFieldGet("ZBR_COD",_nAt)
		_zpCOMP    := GdFieldGet("ZBR_COMP",_nAt)
		_zpTRT     := GdFieldGet("ZBR_TRT",_nAt)
		_zpINIREV  := M->ZBR_REVINI
		_zpFIMREV  := GdFieldGet("ZBR_REVFIM",_nAt)

		Case Alltrim(cMenVar) == "M->ZBR_REVFIM"
		_zpCOD     := GdFieldGet("ZBR_COD",_nAt)
		_zpCOMP    := GdFieldGet("ZBR_COMP",_nAt)
		_zpTRT     := GdFieldGet("ZBR_TRT",_nAt)
		_zpINIREV  := GdFieldGet("ZBR_REVINI",_nAt)
		_zpFIMREV  := M->ZBR_REVFIM

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_zpCOD) .and. _zpCOD == GdFieldGet("ZBR_COD",_nI)

				If !Empty(_zpCOMP) .and. _zpCOMP == GdFieldGet("ZBR_COMP",_nI)

					If !Empty(_zpTRT) .and. _zpTRT == GdFieldGet("ZBR_TRT",_nI)

						If !Empty(_zpINIREV) .and. _zpINIREV == GdFieldGet("ZBR_REVINI",_nI)

							If !Empty(_zpFIMREV) .and. _zpFIMREV == GdFieldGet("ZBR_REVFIM",_nI)

								MsgInfo("A chave informada nesta linha s� pode existir uma �nica vez. Na linha: " + Alltrim(Str(_nI)) + " j� existe esta chave informada!!!")
								Return .F.

							EndIf

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	Next

Return .T.

User Function B630DOK()

	Local _lRet	:=	.T.

	// Incluir neste ponto o controle de dele��o para os casos em que j� existir registro de or�amento associado, ser� necess�rio primeiro retirar de l�

Return _lRet

/*___________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun�ao    � B630IEXC � Autor � Marcos Alberto S      � Data � 21/06/17 ���
��+----------+------------------------------------------------------------���
���Descri��o � Importa��o planilha Excel para Or�amento - Custo Vari�vel  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function B630IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	If !_msCtrlAlt

		MsgInfo("N�o � permitido importar dados porque a Vers�o or�ament�ria est� bloquada.")
		Return

	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importa��o de �ndices de Varia��o da Quantidade da Pre-Estr."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os par�metros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> n�o � permitido importar arquivos que esteja com prote��o"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importa��o de �ndices...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importa��o!')
		EndIf

	EndIf	

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B630IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importa��o: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importa��o
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZBR'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBR_REC_WT"})
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZBR_REC_WT"})

				azPosCOD  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBR_COD"})
				azPosCOMP := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBR_COMP"})
				vtCODPos  := aScan(aCampos,{|x| AllTrim(x) == "ZBR_COD"})
				vtCOMPPos := aScan(aCampos,{|x| AllTrim(x) == "ZBR_COMP"})

				If nPosRec <> 0

					nLinReg := aScan(vtRecGrd,{|x| x == Val(Alltrim(aLinha[nPosRec]))})
					If nLinReg == 0 .or. Val(Alltrim(aLinha[nPosRec])) == 0

						nLinChave := aScan(_oGetDados:aCols,{|x| Alltrim(x[azPosCOD]) == Alltrim(aLinha[vtCODPos]) .and. Alltrim(x[azPosCOMP]) == Alltrim(aLinha[vtCOMPPos]) })
						If nLinChave <> 0

							MsgINFO("O chave [produto + componente] oriundo do excel, j� existe na tela. Linha: " + Alltrim(Str(nLinChave)) + " :[ " + aLinha[vtCODPos] + " || " + aLinha[vtCOMPPos] + " ]. O registro ser� desconsiderado. Atenciosamente!!!")

						Else

							AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
							nLinReg := Len(_oGetDados:aCols)

						EndIf

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

					MsgALERT("Erro no Layout do Arquivo de Importa��o!!!")
					nImport := 0
					Exit

				EndIf

			EndIf

		Next nx

	EndIf

	If nImport > 0 

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importa��o dos registros")
		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf

	RestArea(aArea)

Return

User Function B630EXCL()

	Local _nI
	Local _nPosDel	:=	Len(_oGetDados:aHeader) + 1

	If !_msCtrlAlt  
		MsgInfo("N�o � permitido alterar dados porque a Vers�o or�ament�ria est� bloquada.")
	Else
		If MsgNoYes("A op��o escolhida marcar� os registros carregados para exclus�o e ser� completada somente ap�s clicar em salvar na janela principal. Deseja Prosseguir?","Exclus�o de Registros")

			For _nI := 1 to Len(_oGetDados:aCols)

				_oGetDados:aCols[_nI,_nPosDel]	:=	.T.

			Next
		EndIF
	EndIf


	_oGetDados:Refresh()
Return