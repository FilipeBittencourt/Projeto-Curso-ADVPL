#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFG072
@author Gabriel Mafioletti
@version 1.0
@description Tela para Importação dos dados de Custo 
@type function
/*/

User Function BIAFG072()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZCH") + SPACE(TAMSX3("ZCH_VERSAO")[1]) + SPACE(TAMSX3("ZCH_REVISA")[1]) + SPACE(TAMSX3("ZCH_ANOREF")[1])
	Local bWhile	    := {|| ZCH_FILIAL + ZCH_VERSAO + ZCH_REVISA + ZCH_ANOREF }   

	Local aNoFields     := {"ZCH_DATREF","ZCH_QATU","ZCH_CM1","ZCH_DULENT","ZCH_VULENT",;
	"ZCH_YCTREF","ZCH_CUSMAN","ZCH_VERSAO","ZCH_REVISA","ZCH_ANOREF",;
	"ZCH_HISTOR","ZCH_VLIQ","ZCH_VFRET","ZCH_VBRUT","ZCH_DATIMP","ZCH_OBSERV",;
	"ZCH_USER","ZCH_HORIMP","ZCH_FILEIN","ZCH_GRPPRO"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZCH_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZCH_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZCH_ANOREF")[1])
	Private _oGAnoRef
	Private _cFileIN    := SPACE(TAMSX3("ZCH_FILEIN")[1])
	Private _oGFileIN
	Private _cForeCast  := SPACE(1)
	Private _oForeCast

	Private _msCtrlAlt := .F.
	Private cArquivo   := space(100)

	Private msrhEnter  := CHR(13) + CHR(10)

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_BFG72IEX() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZCH",2,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Importação de Custos" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBFG072A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBFG072B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBFG072C()

	@ 050,310 SAY "Arquivo:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oGFileIN VAR _cFileIN  SIZE 150, 11 OF _oDlg PIXEL VALID fBFG072I()

	@ 050,510 SAY "ForeCast(S/N):" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,570 MSGET _oForeCast VAR _cForeCast  SIZE 10, 11 OF _oDlg PIXEL VALID fBFG072J()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_BFG72FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_BFG72DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBFG072A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cForeCast)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBFG072D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBFG072B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cForeCast)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBFG072D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBFG072C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cForeCast)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBFG072D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBFG072I()

	Local cMaskDir := "Arquivos Excel (*.xlsx) |*.xlsx|"
	Local cTitTela := "Arquivo para a integracao"
	Local lInfoOpen := .T.
	Local lDirServidor := .T.
	Local cOldFile := cArquivo

	_cFileIN := cGetFile(cMaskDir,cTitTela,,cArquivo,lInfoOpen, (GETF_LOCALHARD+GETF_NETWORKDRIVE) ,lDirServidor)

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBFG072D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBFG072J()

	If Empty(_cForeCast)
		MsgInfo("O preenchimento do campo ForeCast é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cForeCast)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBFG072D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBFG072D()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Local _nRec	:=	1
	Local _msc

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef) .and. !Empty(_cForeCast)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e anterior à data do dia" + msrhEnter
	xfMensCompl += "Data Conciliação igual branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual branco"

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
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		_msCtrlAlt := .F.
		Return .F.
	Else
		_msCtrlAlt := .T.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:lInsert := .F.
	_oGetDados:lUpdate := .F.
	_oGetDados:lDelete := .F.

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *,
		(SELECT COUNT(*)
		FROM %TABLE:ZCH% ZCH
		WHERE ZCH_FILIAL = %xFilial:ZCH%
		AND ZCH_VERSAO = %Exp:_cVersao%
		AND ZCH_REVISA = %Exp:_cRevisa%
		AND ZCH_ANOREF = %Exp:_cAnoRef%
		AND ZCH.%NotDel%
		) NUMREG
		FROM %TABLE:ZCH% ZCH
		WHERE ZCH_FILIAL = %xFilial:ZCH%
		AND ZCH_VERSAO = %Exp:_cVersao%
		AND ZCH_REVISA = %Exp:_cRevisa%
		AND ZCH_ANOREF = %Exp:_cAnoRef%
		AND ZCH.%NotDel%
		ORDER BY ZCH_VERSAO, ZCH_REVISA, ZCH_ANOREF
	EndSql

	xtrTot :=  (_cAlias)->(NUMREG)
	ProcRegua(xtrTot)

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZCH_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZCH"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZCH_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := 999

				ElseIf SUBSTR(Alltrim(_oGetDados:aHeader[_msc][2]),1,8) == "ZCH_VMES"
					If UPPER(_cForeCast) == "N"
						_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := 0
					Else
						_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := &(Alltrim(_oGetDados:aHeader[_msc][2]))

					EndIf

				Else
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := &(Alltrim(_oGetDados:aHeader[_msc][2]))

				EndIf			
			Next _msc
			_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := .F.	

			(_cAlias)->(dbSkip())
			_nRec++
		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI

	Local nPosPrd := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZCH_CODPRO"})

	Local nPosDel := Len(_oGetDados:aHeader) + 1
	Local _msc

	/*
	Local _cQry	:=	"UPDATE " + RETSQLNAME("ZCH") + ;
	" SET ZCH_DATIMP = " + VALTOSQL("") + ",  "+;
	" 		ZCH_HORIMP = " + VALTOSQL("") + ",  "+;
	" 		ZCH_USER = " + VALTOSQL("") + ",  "+;
	" 		ZCH_FILEIN = " + VALTOSQL("") + ",  "+;
	" 		ZCH_VMES01 = " + VALTOSQL(0) + ",  "+;
	" 		ZCH_VMES02 = " + VALTOSQL(0) + ",  "+;
	" 		ZCH_VMES03 = " + VALTOSQL(0) + ",  "+;
	" 		ZCH_VMES04 = " + VALTOSQL(0) + ",  "+;
	" 		ZCH_VMES05 = " + VALTOSQL(0) + ",  "+;
	" 		ZCH_VMES06 = " + VALTOSQL(0) + ",  "+;
	" 		ZCH_VMES07 = " + VALTOSQL(0) + ",  "+;
	" 		ZCH_VMES08 = " + VALTOSQL(0) + ",  "+;
	" 		ZCH_VMES09 = " + VALTOSQL(0) + ",  "+;
	" 		ZCH_VMES10 = " + VALTOSQL(0) + ",  "+;
	" 		ZCH_VMES11 = " + VALTOSQL(0) + ",  "+;
	" 		ZCH_VMES12 = " + VALTOSQL(0) + "  "+;
	" WHERE ZCH_FILIAL =  " + ValtoSql(xFilial("ZCH"))  +;
	"	AND ZCH_VERSAO = " + _cVersao + "  "+;
	"	AND ZCH_REVISA = " + _cRevisa + "  "+;
	"	AND ZCH_ANOREF = " + _cAnoRef + "  "+;
	" 	AND D_E_L_E_T_ = ''	"
	TCSQLEXEC(_cQry)
	*/

	If !fDelPeriod()
		Return
	EndIF

	dbSelectArea('ZCH')
	ZCH->(DbSetOrder(2))
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If ZCH->(DbSeek(xFilial("ZCH") + _cVersao + _cRevisa + _cAnoRef + _oGetDados:aCols[_nI,nPosPrd]))

			Reclock("ZCH",.F.)

		Else

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + _oGetDados:aCols[_nI,nPosPrd]))

			Reclock("ZCH",.T.)
			ZCH->ZCH_FILIAL := xFilial("ZCH")
			ZCH->ZCH_VERSAO	:= _cVersao 
			ZCH->ZCH_REVISA	:= _cRevisa	
			ZCH->ZCH_ANOREF	:= _cAnoRef
			ZCH->ZCH_DESPRO := SB1->B1_DESC
			ZCH->ZCH_GRPPRO := SB1->B1_GRUPO

		EndIf	

		For _msc := 1 to Len(_oGetDados:aHeader)

			If _oGetDados:aHeader[_msc][10] == "R"

				nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
				&("ZCH->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

			EndIf

		Next _msc

		ZCH->ZCH_USER   := cUserName
		ZCH->ZCH_DATIMP := Date()
		ZCH->ZCH_HORIMP := Time()
		ZCH->ZCH_FILEIN := Alltrim(cArquivo)

		ZCH->(MsUnlock())

	Next

	MsgInfo("Registro Incluído com Sucesso!")

	//_oGVersao:SetFocus()
	//_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

Return

User Function BFG72FOK()

	// Não é necessária nenhuma checagem porque não se pode efetuar nenhuma alteração

Return .T.

User Function BFG72DOK()

	Local _lRet	:=	.T.

	// Incluir neste ponto o controle de deleção para os casos em que já existir registro de orçamento associado, será necessário primeiro retirar de lá

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BFG72IEX ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BFG72IEX()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 

	If !_msCtrlAlt
		MsgInfo("A Versão orçamentária informada não está ativa para executar este processamento!!!")
		Return .F.
	EndIf

	If !Empty(_cFileIN)
		MsgInfo("Só é permitido efetuar importação de arquivo quando o campo Arquivo estiver VAZIO!!!")
		Return .F.
	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação dos dados da planilha OBZ Integration!!!"))   
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
	Local cLoad	    := 'BIAFG072' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 


	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo    ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		


	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo    := ParamLoad(cFileName,,1,cArquivo)

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
	Local cTabImp			:= 'ZCH'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0

	Local nPosRec 
	Local nPosPrd  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZCH_CODPRO"})
	Local vtRecGrd := {}
	
	Local _nRecCol	:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZCH_REC_WT"})

	Local _aDuplic	:=	{}
	Local _cMsg	:=	""
	Local vnb
	Local nY
	LOcal nx
	Local _msc

	_ImpaColsBkp  := aClone(_oGetDados:aCols)

	For vnb := 1 to Len(_ImpaColsBkp)
		AADD(vtRecGrd, _ImpaColsBkp[vnb][nPosPrd])	
	Next vnb

	If Len(vtRecGrd) == 1
		nPrimeralin := _ImpaColsBkp[Len(_ImpaColsBkp)][nPosPrd]
		If nPrimeralin == ""
			_oGetDados:aCols := {}
		EndIf
	EndIf

	_oGetDados:aCols := {}

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
		aCampos := aWorksheet[1]
		nPosPrd   := aScan(aCampos,{|x| AllTrim(x) == "ZCH_CODPRO"})

		For nx := 1 to len(aWorksheet) 

			For nY := 1 to Len(aWorkSheet)
				If aWorkSheet[nx,nPosPrd] == aWorkSheet[ny,nPosPrd] .And. nx <> ny
					If aScan(_aDuplic,{|x| x[1] ==  aWorkSheet[nx,nPosPrd]}) == 0
						aAdd(_aDuplic,{aWorkSheet[nx,nPosPrd],nx,ny})
					EndIf
				EndIf 
			Next		
		Next

		If Len(_aDuplic) == 0
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
					nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZCH_REC_WT"})
					nPosPrd   := aScan(aCampos,{|x| AllTrim(x) == "ZCH_CODPRO"})

					If nPosPrd <> 0

						nLinReg := 0//aScan(vtRecGrd,{|x| Alltrim(x) == Alltrim(aLinha[nPosPrd])})
						If nLinReg == 0 

							AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
							nLinReg := Len(_oGetDados:aCols)

						EndIf				

						For _msc := 1 to Len(aCampos)

							xkPosCampo := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == aCampos[_msc]})
							If xkPosCampo <> 0
								If _oGetDados:aHeader[xkPosCampo][8] == "N"
									_oGetDados:aCols[nLinReg, xkPosCampo] := Val(Alltrim(aLinha[_msc]))
								ELSEIf _oGetDados:aHeader[xkPosCampo][8] == "D"
									_oGetDados:aCols[nLinReg, xkPosCampo] := ctod((Alltrim(aLinha[_msc])))
								Else
									msLinTxt := FwNoAccent(UPPER(aLinha[_msc]))
									msLinTxt := StrTran( msLinTxt, "A¡", "A" )
									msLinTxt := StrTran( msLinTxt, "A£", "A" )
									msLinTxt := StrTran( msLinTxt, "Aª", "E" )
									msLinTxt := StrTran( msLinTxt, "A©", "E" )
									msLinTxt := StrTran( msLinTxt, "A‰", "E" )
									msLinTxt := StrTran( msLinTxt, "A³", "O" )
									msLinTxt := StrTran( msLinTxt, "Aµ", "O" )
									msLinTxt := StrTran( msLinTxt, "A´", "O" )
									msLinTxt := StrTran( msLinTxt, "Aº", "U" )
									msLinTxt := StrTran( msLinTxt, "A§", "C" )
									msLinTxt := StrTran( msLinTxt, "&#10;", ". " )
									_oGetDados:aCols[nLinReg, xkPosCampo] := msLinTxt
								EndIf
							EndIf

						Next _msc

						_oGetDados:aCols[nLinReg, Len(_oGetDados:aHeader)+1] := .F.	
						_oGetDados:aCols[nLinReg,_nRecCol] := 0
						nImport ++

					Else

						MsgALERT("Erro no Layout do Arquivo de Importação!!!")
						nImport := 0
						Exit

					EndIf

				EndIf

			Next nx
		Else
			_cMsg	:=	"Existem Produtos Duplicados na Planilha Excel!" + CRLF
			For nx := 1 to Len(_aDuplic)
				_cMsg	+= "Produto: " + _aDuplic[nx,1] + " Linhas: " + Alltrim(STR(_aDuplic[nx,2] )) + ',' + Alltrim(STR(_aDuplic[nx,3] )) + CRLF
			Next
			MsgInfo(_cMsg)
		EndIf
	EndIf

	If nImport > 0 

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importação dos registros")
		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf

	RestArea(aArea)

Return


Static Function fDelPeriod()

	Local _lRet	:=	.T.
	Local _cQuery	:=	" UPDATE " + RetSqlName("ZCH") + " SET D_E_L_E_T_ = '*' "
			_cQuery +=	" WHERE ZCH_FILIAL = " + ValtoSql(xFilial("ZCH")) + " "
			_cQuery +=	" 	AND ZCH_VERSAO = " + ValtoSql(_cVersao) +" "
			_cQuery +=	" 	AND ZCH_REVISA = " + ValtoSql(_cRevisa) +" "
			_cQuery +=	" 	AND ZCH_ANOREF = " + ValtoSql(_cAnoRef) +" "
			_cQuery +=	" 	AND D_E_L_E_T_ = '' "
	

	_nError := TcSqlExec(_cQuery)
	

	If _nError <> 0 .And. !Empty(TcSqlError()) 
		MsgInfo("Ocorreu um Erro ao Apagar registros do orçamento selecionado para importação!")
		_lRet	:=	.F.
	Endif 

Return _lRet