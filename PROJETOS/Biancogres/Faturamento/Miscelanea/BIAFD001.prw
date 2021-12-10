#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFD001
@author Diego Souza Barbosa
@since 06/10/2021
@version 1.0
@description Tela para cadastro de Comissão  
@type function
/*/

User Function BIAFD001()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZOM") + SPACE(TAMSX3("ZOM_VERSAO")[1]) + SPACE(TAMSX3("ZOM_REVISA")[1]) + SPACE(TAMSX3("ZOM_ANOREF")[1])
	Local bWhile	    := {|| ZOM_FILIAL + ZOM_VERSAO + ZOM_REVISA + ZOM_ANOREF + ZOM_MARCA }   

	Local aNoFields     := {"ZOM_VERSAO", "ZOM_REVISA", "ZOM_ANOREF", "ZOM_MARCA"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZOM_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZOM_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZOM_ANOREF")[1])
	Private _oGAnoRef
	Private _cCodMarc	:= SPACE(TAMSX3("ZOM_MARCA")[1])
	Private _oGCodMarca
	Private _mNomeMarc   := SPACE(50)

	aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A")}, "Exporta p/Excel"   ,"Exporta p/Excel"})
	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_BFD001IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZOM",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Cadastro de comissão" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIAFD001A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIAFD001B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIAFD001C()

	@ 050,310 SAY "MARCA:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oGCodMarca VAR _cCodMarc F3("Z37") SIZE 50, 11 OF _oDlg PIXEL VALID fBIAFD001D()
	@ 050,410 SAY _mNomeMarc SIZE 250, 11 OF _oDlg PIXEL FONT oFont

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, "U_BFD001TOK", /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_BFD001FOK()", /*[ cSuperDel]*/,"U_BFD001DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIAFD001A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIAFD001D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIAFD001B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIAFD001D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIAFD001C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIAFD001D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIAFD001D()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Local _msc
	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef) .or. Empty(_cCodMarc)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	_mNomeMarc := Posicione("Z37", 1, xFilial("Z37") + _cCodMarc, "Z37_DESCR")

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RECEITA" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e menor ou igual a DataBase" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RECEITA'
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
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	// Verifica se todos os itens de chave necessárias existem na tabela correlata e se não existir, cria.

	RG003 := " SELECT ZBH.ZBH_VEND, ZBH.ZBH_PCTGMR, ZBH.ZBH_CATEG "
	RG003 += "   FROM " + RetSqlName("ZBH") + " ZBH "
	RG003 += "  WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
	RG003 += "    AND ZBH.ZBH_VERSAO = '" + _cVersao + "' "
	RG003 += "    AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
	RG003 += "    AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
	RG003 += "    AND ZBH.ZBH_MARCA = '" + _cCodMarc + "' "
	RG003 += "    AND ZBH.ZBH_PERIOD = '00' "
	RG003 += "    AND ZBH.ZBH_ORIGF = '1' "
	RG003 += "    AND ZBH.ZBH_VEND + ZBH.ZBH_PCTGMR + ZBH.ZBH_CATEG NOT IN(SELECT XZOM.ZOM_VEND + XZOM.ZOM_PCTGMR + XZOM.ZOM_CATEGO "
	RG003 += "                                                 FROM " + RetSqlName("ZOM") + " XZOM "
	RG003 += "                                                WHERE XZOM.ZOM_FILIAL = ZBH.ZBH_FILIAL "
	RG003 += "                                                  AND XZOM.ZOM_VERSAO = ZBH.ZBH_VERSAO "
	RG003 += "                                                  AND XZOM.ZOM_REVISA = ZBH.ZBH_REVISA "
	RG003 += "                                                  AND XZOM.ZOM_ANOREF = ZBH.ZBH_ANOREF "
	RG003 += "                                                  AND XZOM.ZOM_MARCA  = ZBH.ZBH_MARCA "
	RG003 += "                                                  AND XZOM.ZOM_VEND   = ZBH.ZBH_VEND "
	RG003 += "                                                  AND XZOM.ZOM_PCTGMR = ZBH.ZBH_PCTGMR "
	RG003 += "                                                  AND XZOM.ZOM_CATEGO  = ZBH.ZBH_CATEG "
	RG003 += "                                                  AND XZOM.D_E_L_E_T_ = ' ' ) "
	RG003 += "    AND ZBH.D_E_L_E_T_ = ' ' "
	RG003 += "  GROUP BY ZBH.ZBH_VEND, ZBH.ZBH_PCTGMR, ZBH.ZBH_CATEG "
	RG003 += "  ORDER BY ZBH.ZBH_VEND, ZBH.ZBH_PCTGMR, ZBH.ZBH_CATEG "
	RGIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RG003),'RG03',.T.,.T.)
	dbSelectArea("RG03")
	RG03->(dbGoTop())

	If RG03->(!Eof())

		While RG03->(!Eof())

			Reclock("ZOM",.T.)
			ZOM->ZOM_FILIAL  := xFilial("ZBH")
			ZOM->ZOM_VERSAO  := _cVersao
			ZOM->ZOM_REVISA  := _cRevisa
			ZOM->ZOM_ANOREF  := _cAnoRef
			ZOM->ZOM_MARCA   := _cCodMarc
			ZOM->ZOM_VEND  	 := RG03->ZBH_VEND
			ZOM->ZOM_PCTGMR  := RG03->ZBH_PCTGMR
			ZOM->ZOM_CATEGO  := RG03->ZBH_CATEG
			ZOM->(MsUnlock())

			RG03->(dbSkip())

		End

	EndIf

	RG03->(dbCloseArea())
	Ferase(RGIndex+GetDBExtension())
	Ferase(RGIndex+OrdBagExt())

	BeginSql Alias _cAlias

		SELECT *, ZOM_PCM01 + ZOM_PCM02 + ZOM_PCM03, + ZOM_PCM04 + ZOM_PCM05 + ZOM_PCM06 + ZOM_PCM07 + ZOM_PCM08 + ZOM_PCM09 + ZOM_PCM10 + ZOM_PCM11 + ZOM_PCM12 
		FROM %TABLE:ZOM% ZOM
		WHERE ZOM_FILIAL = %xFilial:ZOM%
		AND ZOM_VERSAO = %Exp:_cVersao%
		AND ZOM_REVISA = %Exp:_cRevisa%
		AND ZOM_ANOREF = %Exp:_cAnoRef%
		AND ZOM_MARCA = %Exp:_cCodMarc%
		AND ZOM.%NotDel%
		ORDER BY ZOM_VEND, ZOM_PCTGMR, ZOM_CATEGO
	EndSql

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)

				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOM_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZOM"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOM_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOM_DPCTGM"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SX5", 1, xFilial("SX5") + "ZH" + (_cAlias)->ZOM_PCTGMR, "X5_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOM_NOMEVE"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SA3", 1, xFilial("SA3") + (_cAlias)->ZOM_VEND, "A3_NOME")

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

	Local _nI, _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOM_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	dbSelectArea('ZOM')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZOM->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZOM",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZOM->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

			Else

				ZOM->(DbDelete())

			EndIf

			ZOM->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZOM",.T.)

				ZOM->ZOM_FILIAL  := xFilial("ZOM")
				ZOM->ZOM_VERSAO  := _cVersao
				ZOM->ZOM_REVISA  := _cRevisa
				ZOM->ZOM_ANOREF  := _cAnoRef
				ZOM->ZOM_MARCA   := _cCodMarc
				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZOM->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

				ZOM->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao        := SPACE(TAMSX3("ZOM_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZOM_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZOM_ANOREF")[1])
	_cCodMarc       := SPACE(TAMSX3("ZOM_MARCA")[1])
	_mNomeMarc      := SPACE(50)
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function BFD001DOK()

	Local _lRet	:=	.T.

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BFD001IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Comissãos REC.I ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BFD001IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

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
	Local cLoad	    := 'BFD001IEXC' + cEmpAnt
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
	Local cTabImp			:= 'ZOM'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb, ny, _msc, nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOM_REC_WT"})
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZOM_REC_WT"})

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
¦¦¦  TudoOk                                                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BFD001TOK()

	Local _lRet	:=	.T.
	Local _nI

	nPosVEND  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOM_VEND"})
	nPosPCTGMR  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOM_PCTGMR"})
	nPosCATEG   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOM_CATEGO"})


	For _nI	:=	1 to Len(_oGetDados:aCols)

		If !GDdeleted(_nI)

			nVENDLin  := _oGetDados:aCols[_nI][nPosVEND]
			nPCTGMRLin  := _oGetDados:aCols[_nI][nPosPCTGMR]
			nCATEGLin   := _oGetDados:aCols[_nI][nPosCATEG]


			xkPosRec := aScan(_oGetDados:aCols,{|x| Alltrim(x[nPosVEND]) == Alltrim(nVENDLin) .and. Alltrim(x[nPosPCTGMR]) == Alltrim(nPCTGMRLin) .and. Alltrim(x[nPosCATEG]) == Alltrim(nCATEGLin)  })

			If xkPosRec <> _nI

				MsgInfo("A chave composta de Vendedor / Pacote GMR / Categoria só pode existir uma única vez. Na linha: " + Alltrim(Str(xkPosRec)) + " já existe esta chave informada!!!")
				Return .F.

			EndIf

		EndIf

	Next _nI

Return _lRet

User Function BFD001FOK()

	Local cMenVar   := ReadVar()
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _zpVEND := ""
	Local _zpPCTGMR := ""
	Local _zpCATEG  := ""


	Do Case

		Case Alltrim(cMenVar) == "M->ZOM_VEND"
		_zpVEND   := M->ZOM_VEND
		_zpPCTGMR   := GdFieldGet("ZOM_PCTGMR",_nAt)
		GdFieldPut("ZOM_NOMEVE"   , Posicione("SA3", 1, xFilial("SA3") + _zpVEND, "A3_NOME") , _nAt)

		Case Alltrim(cMenVar) == "M->ZOM_PCTGMR"
		_zpVEND   := GdFieldGet("ZOM_VEND",_nAt)
		_zpPCTGMR   := M->ZOM_PCTGMR
		GdFieldPut("ZOM_DPCTGM"   , Posicione("SX5", 1, xFilial("SX5") + "ZH" + _zpPCTGMR, "X5_DESCRI") , _nAt)
		Case Alltrim(cMenVar) == "M->ZOM_CATEGO"
		_zpVEND   := GdFieldGet("ZOM_VEND",_nAt)
		_zpPCTGMR := GdFieldGet("ZOM_PCTGMR",_nAt)
		_zpCATEG  := M->ZOM_CATEGO



	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_zpVEND) .and. _zpVEND == GdFieldGet("ZOM_VEND",_nI)

				If !Empty(_zpPCTGMR) .and. _zpPCTGMR == GdFieldGet("ZOM_PCTGMR",_nI)

					If !Empty(_zpCATEG) .and. _zpCATEG == GdFieldGet("ZOM_CATEGO",_nI)

						MsgInfo("A chave composta de Vendedor / Pacote GMR / Categoria só pode existir uma única vez. Na linha: " + Alltrim(Str(_nI)) + " já existe esta chave informada!!!")
						Return .F.
					
					EndIf
				EndIf

			EndIf

		EndIf

	Next

Return .T.
