#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIA767
@author Marcos Alberto Soprani
@since 05/10/21
@version 1.1
@description Cadastro DE-PARA de Classe de Valor por Matricula  
@type function
/*/                                                                                               
User Function BIA767()

	Local oLayer
	Local _oPanel
	Local _cTexto1
	Local _cTexto2
	Local oFont

	Private _oDlgGer

	Define FONT oFont  NAME "Arial" SIZE 0,14 BOLD

	Define MsDialog _oDlgGer Title "De-Para CLVL" From 0,0 To 230,500 Of oMainWnd Pixel

	oLayer := FWLayer():New()
	oLayer:Init(_oDlgGer, .F., .T.)

	// Adiciona linha ao Layer
	oLayer:AddLine("LIN1", 20, .F.)
	oLayer:AddLine("LIN2", 20, .F.)
	// Adiciona coluna ao Layer
	oLayer:AddCollumn("COL1", 30, .T., "LIN1")
	oLayer:AddCollumn("COL2", 70, .T., "LIN1")

	oLayer:AddCollumn("COL1", 30, .T., "LIN2")
	oLayer:AddCollumn("COL2", 70, .T., "LIN2")

	//Importação / Manutenção
	_oPanel	:=	oLayer:getColPanel( "COL1", "LIN1" )
	oBtVisual := TButton():New( 10, 10, "Import / Manut", _oPanel,{|| U_BIA767IP() }, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	_cTexto1	:=	"Importação / Manutenção CLVL"
	_oPanel	:=	oLayer:getColPanel( "COL2", "LIN1" )
	_oSay1	:=	tSay():New(010,010,{|| _cTexto1  },_oPanel,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,10)

	//Processamento
	_oPanel	:=	oLayer:getColPanel( "COL1", "LIN2" )  
	oBtManut := TButton():New( 10, 10, "Processamento", _oPanel,{|| Processa({ || cMsg := U_BIA767PR() }, "Aguarde...", "Processando...",.F.) }, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	_cTexto2	:=	"Processamento CLVL - De-Para"
	_oPanel	:=	oLayer:getColPanel( "COL2", "LIN2" )
	_oSay2	:=	tSay():New(010,010,{|| _cTexto2  },_oPanel,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,10)	

	ACTIVATE DIALOG _oDlgGer CENTERED

Return

User Function BIA767IP() 

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZOL") + SPACE(TAMSX3("ZOL_VERSAO")[1]) + SPACE(TAMSX3("ZOL_REVISA")[1]) + SPACE(TAMSX3("ZOL_ANOREF")[1])
	Local bWhile	    := {|| ZOL_FILIAL + ZOL_VERSAO + ZOL_REVISA + ZOL_ANOREF }

	Local aNoFields     := {"ZOL_VERSAO", "ZOL_REVISA", "ZOL_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZOL_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZOL_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZOL_ANOREF")[1])
	Private _oGAnoRef
	Private _msCtrlAlt := .T.  

	_aSize := MsAdvSize(.T.)      

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração"      , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_BIA767EX() }, "Importa Arquivo"        , "Importa Arquivo"})

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZOL",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "De-Para de Classe de Valor" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA767A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA767B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA767C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE + GD_DELETE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999 /*[ nMax]*/, "U_BI767FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_BI767DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA767A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA767C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA767B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA767C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA767C()

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
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RH'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:Date()%
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
		_oGetDados:lDelete := .T.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZOL% ZOL
		INNER JOIN %TABLE:ZO0% ZO0 ON ZO0_FILIAL = %xFilial:ZO0%
		AND ZO0_VERSAO = ZOL_VERSAO
		AND ZO0_REVISA = ZOL_REVISA
		AND ZO0_ANOREF = ZOL_ANOREF
		AND ZO0_MAT = ZOL_MATR
		AND ZO0.%NotDel%
		WHERE ZOL_FILIAL = %xFilial:ZOL%
		AND ZOL_VERSAO = %Exp:_cVersao%
		AND ZOL_REVISA = %Exp:_cRevisa%
		AND ZOL_ANOREF = %Exp:_cAnoRef%
		AND ZOL.%NotDel%
		ORDER BY ZOL.ZOL_VERSAO, ZOL.ZOL_REVISA, ZOL.ZOL_ANOREF, ZOL_MATR

	EndSql

	ProcRegua(0)

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno() ))))

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZOL_MATR,;
			ZO0_NOME,;
			ZOL_CLVLDE,;
			ZOL_CLVLPA,;
			"ZOL",;
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
	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1
	Local _cChave	:=	xFilial("ZOL") + _cVersao + _cRevisa + _cAnoRef
	Local _nPosMat	:=	aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOL_MATR"})

	If _msCtrlAlt

		dbSelectArea('ZOL')
		ZOL->(DbSetOrder(1))		

		For _nI	:=	1 to Len(_oGetDados:aCols)

			If !Empty(_oGetDados:aCols[_nI,_nPosMat]) 

				If ZOL->(DbSeek(_cChave+_oGetDados:aCols[_nI,_nPosMat]))

					Reclock("ZOL",.F.)
					If !_oGetDados:aCols[_nI,nPosDel]

						For _msc := 1 to Len(_oGetDados:aHeader)

							If _oGetDados:aHeader[_msc][10] == "R"

								nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
								&("ZOL->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

							EndIf

						Next _msc

					Else

						ZOL->(DbDelete())

					EndIf

					ZOL->(MsUnlock())

				Else

					If !_oGetDados:aCols[_nI,nPosDel]

						Reclock("ZOL",.T.)

						ZOL->ZOL_FILIAL  := xFilial("ZOL")
						ZOL->ZOL_VERSAO  := _cVersao
						ZOL->ZOL_REVISA  := _cRevisa
						ZOL->ZOL_ANOREF  := _cAnoRef
						For _msc := 1 to Len(_oGetDados:aHeader)

							If _oGetDados:aHeader[_msc][10] == "R"

								nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
								&("ZOL->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

							EndIf

						Next _msc

						ZOL->(MsUnlock())

					EndIf

				EndIf

			EndIf

		Next

	EndIf

	_cVersao		:=	SPACE(TAMSX3("ZOL_VERSAO")[1])
	_cRevisa		:=	SPACE(TAMSX3("ZOL_REVISA")[1])
	_cAnoRef		:=	SPACE(TAMSX3("ZOL_ANOREF")[1])
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

User Function BI767FOK()

Return .T.

User Function BI767DOK()

	Local _lRet	:=	.T.

Return _lRet

User Function BIA767EX()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fxPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de De-Para de Classe de Valor"))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fxPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fPrcImpExc() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

//Parametros
Static Function fxPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIA767EX' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importação
Static Function fPrcImpExc()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZOL'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb, ny, _msc, nx, lp

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOL_REC_WT"})
	Local nPosMat  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOL_MATR"})

	Local vtMatGrd := {}

	_ImpaColsBkp  := aClone(_oGetDados:aCols)

	For vnb := 1 to Len(_ImpaColsBkp)
		AADD(vtMatGrd, _ImpaColsBkp[vnb][nPosMat])	
	Next vnb

	If Len(vtMatGrd) == 1
		nPrimeralin := _ImpaColsBkp[Len(_ImpaColsBkp)][nPosMat]
		If nPrimeralin == "      "
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZOL_REC_WT"})
				nPosMat	  := aScan(aCampos,{|x| AllTrim(x) == "ZOL_MATR"})
				nPCLVLDE  := aScan(aCampos,{|x| AllTrim(x) == "ZOL_CLVLDE"})
				nPCLVLPA  := aScan(aCampos,{|x| AllTrim(x) == "ZOL_CLVLPA"})

				If nPosMat <> 0

					xxContinua := .T.
					xxMatNew := Alltrim(aLinha[nPosMat])
					For lp := 1 to len(xxMatNew)

						If Substr(xxMatNew,lp,1) > "9"
							MsgINFO("A matrícula " + xxMatNew + " não é suportada para conversão e será desprezada.", "Matrícula: com letras!!!")
							xxContinua := .F.
							Exit
						EndIf

					Next lp

					If xxContinua

						ZO0->(dbSetOrder(1))
						If !ZO0->(dbSeek(xFilial("ZO0") + _cVersao + _cRevisa + _cAnoRef + StrZero(Val(aLinha[nPosMat]),6)))

							MsgINFO("A matrícula " + StrZero(Val(aLinha[nPosMat]),6) + " não está na lista de matrículas ativas para o processo orçamentário corrente e será desprezada.", "Matricula: não consta!!!")

						Else

							CTH->(dbSetOrder(1))
							If !CTH->(dbSeek(xFilial("CTH") + Alltrim(aLinha[nPCLVLDE]) ))

								MsgINFO("A CLVL De: " + Alltrim(aLinha[nPCLVLDE]) +  " da matrícula " + StrZero(Val(aLinha[nPosMat]),6) + " não é válida e será desprezada.", "CLVL De: inexistente!!!")

							Else

								CTH->(dbSetOrder(1))
								If !CTH->(dbSeek(xFilial("CTH") + Alltrim(aLinha[nPCLVLPA]) ))

									MsgINFO("A CLVL Para: " + Alltrim(aLinha[nPCLVLPA]) +  " da matrícula " + StrZero(Val(aLinha[nPosMat]),6) + " não é válida e será desprezada.", "CLVL Para: inexistente!!!")

								Else

									nLinReg := aScan(vtMatGrd,{|x| x == StrZero(Val(aLinha[nPosMat]),6) })
									If nLinReg == 0

										AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
										nLinReg := Len(_oGetDados:aCols)

									EndIf				

									For _msc := 1 to Len(aCampos)

										If aCampos[_msc] <> "ZOL_REC_WT"

											xkPosCampo := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == aCampos[_msc]})
											If xkPosCampo <> 0
												If Alltrim(aCampos[_msc]) == "ZOL_MATR"
													If _oGetDados:aHeader[xkPosCampo][8] == "N"
														_oGetDados:aCols[nLinReg, xkPosCampo] := StrZero(aLinha[_msc],6)
													Else
														_oGetDados:aCols[nLinReg, xkPosCampo] := StrZero(Val(Alltrim(aLinha[_msc])),6)
													EndIf
												ElseIf Alltrim(aCampos[_msc]) == "ZOL_NOME"
													_oGetDados:aCols[nLinReg, xkPosCampo] := ZO0->ZO0_NOME
												ElseIf _oGetDados:aHeader[xkPosCampo][8] == "N"
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

								EndIf

							EndIf

						EndIf

					EndIf

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

User Function BIA767PR()

	Local M002
	Local _ms        
	Private msrhEnter := CHR(13) + CHR(10)
	Private _cVersao  := space(010)
	Private _cRevisa  := space(003) 
	Private _cAnoRef  := space(004) 

	fPerg767()

	M002 := GetNextAlias()

	// ,'Z96'
	// ,'ZOY' eu criei a tabela na familia errada e com o nome do campo _VERSAO errado.
	//             Tabelas Avulsas                           Família de Tabelas usadas desde 2017                                                                                                                                                                                    Família de tabelas passas a serem usada a partir do orçamento 2021
	_cVetTabl  := {'ZCH','Z42','Z45','Z46','Z47','Z50','Z98','ZB0','ZB1','ZB2','ZB3','ZB4','ZB5','ZB6','ZB7','ZB8','ZB9','ZBA','ZBB','ZBC','ZBD','ZBE','ZBF','ZBG','ZBH','ZBI','ZBJ','ZBK','ZBL','ZBM','ZBN','ZBO','ZBP','ZBQ','ZBR','ZBS','ZBT','ZBU','ZBV','ZBW','ZBX','ZBY','ZBZ','ZO0','ZO1','ZO2','ZO3','ZO4','ZO5','ZO6','ZO7','ZO8','ZO9','ZOA','ZOB','ZOC','ZOD','ZOE','ZOF','ZOG','ZOH','ZOI','ZOJ','ZOK','ZOL','ZOM','ZON','ZOO','ZOP','ZOQ','ZOR','ZOS','ZOT','ZOU','ZOV','ZOW','ZOX','ZOZ'}
	_cTlbAfetad := ""

	ProcRegua(0)

	For _ms := 1 to Len(_cVetTabl)

		dbSelectArea("SX2")
		dbSetOrder(1)
		dbSeek(_cVetTabl[_ms])

		xxTabProc := SX2->X2_CHAVE
		msProsseg := .F.

		IncProc("Processando tabela:  " + xxTabProc )

		BeginSql Alias M002
			%noParser%
			Exec SP_BIA944 %Exp:RetSqlName(xxTabProc)%
		EndSql
		If (M002)->(EXISTE) = "S"
			msProsseg := .T.
		EndIf
		(M002)->(DbCloseArea())

		If msProsseg

			xxCmpMatr := ""
			xxCmpCLVL := "" 

			If xxTabProc <> "ZOL"

				dbSelectArea("SX3")
				dbSetOrder(2)
				If dbSeek(xxTabProc + "_VERSAO")

					dbSelectArea("SX3")
					dbSetOrder(2)
					If dbSeek(xxTabProc + "_MAT")

						xxCmpMatr := Alltrim(SX3->X3_CAMPO)	

						dbSelectArea("SX3")
						dbSetOrder(2)
						If dbSeek(xxTabProc + "_CL")

							xxCmpCLVL := Alltrim(SX3->X3_CAMPO)

							XK001 := " UPDATE " + xxTabProc + " SET " + xxCmpCLVL + " = ZOL_CLVLPA "
							XK001 += "   FROM " + RetSqlName(xxTabProc) + " " + xxTabProc + " "
							XK001 += " INNER JOIN " + RetSqlName("ZOL") + " ZOL(NOLOCK) ON ZOL_FILIAL = '" + xFilial("ZOL") + "' "
							XK001 += "                              AND ZOL.ZOL_VERSAO = " + xxTabProc + "_VERSAO "
							XK001 += "                              AND ZOL.ZOL_REVISA = " + xxTabProc + "_REVISA "
							XK001 += "                              AND ZOL.ZOL_ANOREF = " + xxTabProc + "_ANOREF "
							XK001 += "                              AND ZOL.ZOL_MATR = " + xxCmpMatr + " "
							XK001 += "                              AND ZOL.D_E_L_E_T_ = ' ' "
							XK001 += "  WHERE " + xxTabProc + "_FILIAL = '" + xFilial(xxTabProc) + "' "
							XK001 += "    AND " + xxTabProc + "_VERSAO = '" + _cVersao + "' "
							XK001 += "    AND " + xxTabProc + "_REVISA = '" + _cRevisa + "' "
							XK001 += "    AND " + xxTabProc + "_ANOREF = '" + _cAnoRef + "' "
							XK001 += "    AND " + xxTabProc + ".D_E_L_E_T_ = ' ' "
							TcSQLExec(XK001)

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	Next _ms

	MsgINFO("Fim do Processamento!!!", "De-Para CLVL")

	_oDlgGer:End()

Return

Static Function fPerg767()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIA767' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	_cVersao        := space(010)
	_cRevisa        := space(003) 
	_cAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,_cVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,_cRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,_cAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Seleção de Tempo Orçamentário",,,,,,,,cLoad,.T.,.T.)      
		_cVersao    := ParamLoad(cFileName,,1,_cVersao) 
		_cRevisa    := ParamLoad(cFileName,,2,_cRevisa) 
		_cAnoRef    := ParamLoad(cFileName,,3,_cAnoRef) 
	Endif

Return
