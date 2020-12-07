#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA632
@author Marcos Alberto Soprani
@since 250918
@version 1.0
@description Tela para Importação dos dados do formulário OBZ 
@type function
/*/

User Function BIA632()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("Z98") + SPACE(TAMSX3("Z98_VERSAO")[1]) + SPACE(TAMSX3("Z98_REVISA")[1]) + SPACE(TAMSX3("Z98_ANOREF")[1])
	Local bWhile	    := {|| Z98_FILIAL + Z98_VERSAO + Z98_REVISA + Z98_ANOREF }   

	Local aNoFields     := {"Z98_VERSAO", "Z98_REVISA", "Z98_ANOREF", "Z98_ANO", "Z98_FILEIN", "Z98_IDDRV", "Z98_DIDDRV"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("Z98_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("Z98_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("Z98_ANOREF")[1])
	Private _oGAnoRef
	Private _cFileIN    := SPACE(TAMSX3("Z98_FILEIN")[1])
	Private _oGFileIN

	Private _msCtrlAlt := .F.
	Private cArquivo   := space(100)
	Private xdUserDigt := space(006)
	Private msrhEnter  := CHR(13) + CHR(10)

	MsgINFO("Rotina retirada de uso em 12/10/20. Favor solicitar acesso à rotina BIAFG100", "Atenção!!!")
	Return



	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B632IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"Z98",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "OBZ Integration" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA632A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA632B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA632C()

	@ 050,310 SAY "Arquivo:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oGFileIN VAR _cFileIN  SIZE 150, 11 OF _oDlg PIXEL VALID fBIA632I()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_B632FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B632DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA632A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA632D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA632B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA632D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA632C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA632D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA632I()

	Local cMaskDir := "Arquivos Excel (*.xlsx) |*.xlsx|"
	Local cTitTela := "Arquivo para a integracao"
	Local lInfoOpen := .T.
	Local lDirServidor := .T.

	_cFileIN := cGetFile(cMaskDir,cTitTela,,cArquivo,lInfoOpen, (GETF_LOCALHARD+GETF_NETWORKDRIVE) ,lDirServidor)

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA632D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA632D()

	Local _msc
	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual OBZ" + msrhEnter
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
		AND RTRIM(ZB5.ZB5_TPORCT) = 'OBZ'
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
		ISNULL(CONVERT( VARCHAR(8000), CONVERT(VARBINARY(8000), Z98_JSTMEM)), '') AS JSTMEM, 
		(SELECT COUNT(*)
		FROM %TABLE:Z98% Z98
		WHERE Z98_FILIAL = %xFilial:Z98%
		AND Z98_VERSAO = %Exp:_cVersao%
		AND Z98_REVISA = %Exp:_cRevisa%
		AND Z98_ANOREF = %Exp:_cAnoRef%
		AND Z98_FILEIN = %Exp:_cFileIN%
		AND Z98.%NotDel%
		) NUMREG
		FROM %TABLE:Z98% Z98
		WHERE Z98_FILIAL = %xFilial:Z98%
		AND Z98_VERSAO = %Exp:_cVersao%
		AND Z98_REVISA = %Exp:_cRevisa%
		AND Z98_ANOREF = %Exp:_cAnoRef%
		AND Z98_FILEIN = %Exp:_cFileIN%
		AND Z98.%NotDel%
		ORDER BY Z98_VERSAO, Z98_REVISA, Z98_ANOREF
	EndSql

	xtrTot :=  (_cAlias)->(NUMREG)
	ProcRegua(xtrTot)

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "Z98"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_DCLVL"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CTH", 1, xFilial("CTH") + (_cAlias)->Z98_CLVL, "CTH_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_ENTID"
					msCodEnt := Posicione("CTH", 1, xFilial("CTH") + (_cAlias)->Z98_CLVL, "CTH_YENTID")
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ZCA", 1, xFilial("ZCA") + msCodEnt, "ZCA_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_DCONTA"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CT1", 1, xFilial("CT1") + (_cAlias)->Z98_CONTA, "CT1_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_PACOTE"
					msCodPac := Posicione("CT1", 1, xFilial("CT1") + (_cAlias)->Z98_CONTA, "CT1_YPCT20")
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ZC8", 1, xFilial("ZC8") + msCodPac, "ZC8_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_JSTMEM"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := (_cAlias)->JSTMEM

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_INIDPR"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := ctod((_cAlias)->Z98_INIDPR)

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
	Local _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z98_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1

	dbSelectArea('Z98')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		nPosCONTA := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z98_CONTA" })

		If _oGetDados:aCols[_nI,nPosRec] > 0

			Z98->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("Z98",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("Z98->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

			Else

				Z98->(DbDelete())

			EndIf

			Z98->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("Z98",.T.)

				Z98->Z98_FILIAL  := xFilial("Z98")
				Z98->Z98_VERSAO  := _cVersao
				Z98->Z98_REVISA  := _cRevisa
				Z98->Z98_ANOREF  := _cAnoRef
				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("Z98->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc
				Z98->Z98_USER   := cUserName
				Z98->Z98_DTPROC := Date()
				Z98->Z98_HRPROC := Time()
				Z98->Z98_FILEIN := Alltrim(cArquivo)
				Z98->Z98_LINHAA := _nI
				Z98->Z98_USRRSP := xdUserDigt
				Z98->Z98_USRRS2 := xdUserDigt

				Z98->(MsUnlock())

			EndIf

		EndIf

	Next

	//_cVersao        := SPACE(TAMSX3("Z98_VERSAO")[1])
	//_cRevisa        := SPACE(TAMSX3("Z98_REVISA")[1])
	//_cAnoRef        := SPACE(TAMSX3("Z98_ANOREF")[1])
	//_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B632FOK()

	// Não é necessária nenhuma checagem porque não se pode efetuar nenhuma alteração

Return .T.

User Function B632DOK()

	Local _lRet	:=	.T.

	// Incluir neste ponto o controle de deleção para os casos em que já existir registro de orçamento associado, será necessário primeiro retirar de lá

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B632IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B632IEXC()

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
	Local cLoad	    := 'B632IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 
	xdUserDigt      := space(006)  

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo    ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		
	aAdd( aPergs ,{1,"Usuário Responsável:"         ,xdUserDigt  ,"@!","NAOVAZIO()",'USR','.T.', 06,.F.})	

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo    := ParamLoad(cFileName,,1,cArquivo)
		xdUserDigt  := ParamLoad(cFileName,,2,xdUserDigt) 		 
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
	Local cTabImp			:= 'Z98'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z98_REC_WT"})
	Local vtRecGrd := {}

	Local vnb
	Local ny
	Local _msc
	Local nx

	M0007 := " SELECT COUNT(*) CONTAD "
	M0007 += "   FROM " + RetSqlName("Z98") + " Z98 "
	M0007 += "  WHERE Z98.Z98_FILIAL = '" + xFilial("Z98") + "' "
	M0007 += "    AND Z98.Z98_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND Z98.Z98_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND Z98.Z98_ANOREF = '" + _cAnoRef + "' "
	M0007 += "    AND UPPER(Z98.Z98_FILEIN) LIKE UPPER('" + Alltrim(cArquivo) + "') "
	M0007 += "    AND Z98.D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existem registros OBZ associados ao arquivo informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados existentes." + msrhEnter + msrhEnter+ " Deseja prosseguir com o importação?")

		If xkContinua

			KS001 := " DELETE " + RetSqlName("Z98") + " "
			KS001 += "   FROM " + RetSqlName("Z98") + " Z98 "
			KS001 += "  WHERE Z98.Z98_FILIAL = '" + xFilial("Z98") + "' "
			KS001 += "    AND Z98.Z98_VERSAO = '" + _cVersao + "' "
			KS001 += "    AND Z98.Z98_REVISA = '" + _cRevisa + "' "
			KS001 += "    AND Z98.Z98_ANOREF = '" + _cAnoRef + "' "
			KS001 += "    AND UPPER(Z98.Z98_FILEIN) LIKE UPPER('" + Alltrim(cArquivo) + "') "
			KS001 += "    AND Z98.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros Z98... ",,{|| TcSQLExec(KS001) })

		Else

			M007->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			Return .F.

		EndIf

	EndIf

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "Z98_REC_WT"})

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
								msLinTxt := StrTran( msLinTxt, "A‡Aƒ", "CA" )
								msLinTxt := StrTran( msLinTxt, "A­", "I" )
								msLinTxt := StrTran( msLinTxt, "A‡", "C" )
								msLinTxt := StrTran( msLinTxt, "Aƒ", "A" )
								msLinTxt := StrTran( msLinTxt, "A“", "O" )
								msLinTxt := StrTran( msLinTxt, "A€", "A" )
								msLinTxt := StrTran( msLinTxt, "A¢", "A" )
								_oGetDados:aCols[nLinReg, xkPosCampo] := msLinTxt
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
