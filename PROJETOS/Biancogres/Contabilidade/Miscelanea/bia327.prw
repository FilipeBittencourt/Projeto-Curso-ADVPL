#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA327
@author Marcos Alberto Soprani
@since 16/09/20
@version 1.0
@description Importação de arquivos para ECF 
@type function
/*/

User Function BIA327()

	Private msrhEnter   := CHR(13) + CHR(10)

	Private joDlg
	Private joButton1
	Private joButton2
	Private joComboBox1
	Private joGet1
	Private joSay1
	Private joSay2
	Private jnComboBox1 := 0
	Private jcGet1      := ctod("  /  /  ")
	Private jItmBoxm    := {"CGM - Bloco Y600","CFQ - Bloco Y520","CG5 - Bloco X450"}
	Private msFecha     := .F.

	DEFINE MSDIALOG joDlg TITLE "Parâmetros" FROM 000, 000  TO 125, 500 COLORS 0, 16777215 PIXEL

	@ 014, 076 MSCOMBOBOX joComboBox1 VAR jnComboBox1 ITEMS jItmBoxm SIZE 071, 010 OF joDlg COLORS 0, 16777215 PIXEL
	@ 014, 015 SAY joSay1 PROMPT "Selecione a Tabela:" SIZE 055, 007 OF joDlg COLORS 0, 16777215 PIXEL
	@ 032, 015 SAY joSay2 PROMPT "Informe o Período: " SIZE 055, 007 OF joDlg COLORS 0, 16777215 PIXEL
	@ 032, 076 MSGET joGet1 VAR jcGet1 SIZE 060, 010 OF joDlg COLORS 0, 16777215 PIXEL
	@ 030, 180 BUTTON joButton2 PROMPT "Confirmar" SIZE 037, 012 OF joDlg ACTION fProcRot() PIXEL
	@ 010, 180 BUTTON joButton1 PROMPT "Cancelar" SIZE 037, 012 OF joDlg ACTION fAborta() PIXEL

	ACTIVATE MSDIALOG joDlg CENTERED VALID msFecha

Return

Static Function fAborta()

	msFecha := .T.
	Close( joDlg )

Return

Static Function fProcRot()

	If ValType(jnComboBox) == "N"
		MsgStop("Favor selecionar uma tabela", "Atenção")
		Return
	EndIf

	If Empty(jcGet1)
		MsgStop("Favor Informar uma data", "Atenção")
		Return
	EndIf

	U_BIA327A( Substr(jnComboBox1,1,3) )

	msFecha := .T.
	Close( joDlg )

Return

User Function BIA327A( xyTabl )

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}
	Local msAlias       := xyTabl
	Local msChavAl      := xyTabl + "_"
	Local msDescFr      := ""

	Local cSeek	        := xFilial(msAlias) + SPACE(TAMSX3(msChavAl+"PERIOD")[1])
	Local bWhile	    := {|| &(msChavAl + "FILIAL") + &(msChavAl + "PERIOD") }   

	Local aNoFields     := {msChavAl + "ID", msChavAl + "PERIOD"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private ksAliasG    := xyTabl
	Private ksChvAlG    := xyTabl + "_"
	Private ksChAlCa    := ksAliasG + "->" + ksChvAlG

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cPeriodo	:= jcGet1
	Private _oGPeriodo

	SX2->(dbSetOrder(1))
	If SX2->(dbSeek(msAlias))
		msDescFr := Upper(Alltrim(SX2->X2_NOME))
	EndIf

	SX3->(dbSetOrder(1))
	If SX3->(dbSeek(msAlias))
		While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == msAlias
			If SX3->X3_CONTEXT <> "R"
				aAdd(aNoFields, Alltrim(SX3->X3_CAMPO))
			EndIf
			SX3->(dbSkip())
		End
	EndIf

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B327IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,msAlias,1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title msDescFr From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Período:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGPeriodo VAR _cPeriodo Picture "@!" SIZE 50, 11 OF _oDlg WHEN .F. PIXEL

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], , /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, /*"U_B327FOK()" | cFieldOK*/, /*[ cSuperDel]*/,/*"U_B327DOK()" [ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B327IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B327IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para Importação Arquivos ECF"))   
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
	Local cLoad	    := 'B327IEXC' + cEmpAnt
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
	Local cTabImp			:= ksAliasG
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb
	Local ny
	Local _msc
	Local nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == ksChvAlG + "REC_WT"})
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == ksChvAlG + "REC_WT"})

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
							ElseIf _oGetDados:aHeader[xkPosCampo][8] == "D"
								_oGetDados:aCols[nLinReg, xkPosCampo] := ctod(Alltrim(aLinha[_msc]))
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

Static Function fGrvDados()

	Local msStaExcQy    := 0
	Local lOk           := .T.

	Local _nI
	Local _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == ksChvAlG + "REC_WT"})
	Local nPosDel :=	Len(_oGetDados:aHeader) + 1	

	Private xkContinua  := .T.

	M0007 := " SELECT COUNT(*) CONTAD "
	M0007 += "   FROM " + RetSqlName(ksAliasG) + " A "
	M0007 += "  WHERE " + ksAliasG + "_FILIAL = '" + xFilial(ksAliasG) + "' "
	M0007 += "    AND " + ksAliasG + "_PERIOD = '" + dtos(_cPeriodo) + "' "
	M0007 += "    AND D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existe base de dados para o período informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

	EndIf

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	If !xkContinua

		MsgAlert("Processo abortado...", "Atenção")
		Return

	EndIf

	Begin Transaction

		msDelTb := " DELETE A "
		msDelTb += "   FROM " + RetSqlName(ksAliasG) + " A "
		msDelTb += "  WHERE " + ksAliasG + "_FILIAL = '" + xFilial(ksAliasG) + "' "
		msDelTb += "    AND " + ksAliasG + "_PERIOD = '" + dtos(_cPeriodo) + "' "
		msDelTb += "    AND D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Apagando registros " + ksAliasG + "... ",,{|| msStaExcQy := TcSQLExec(msDelTb) })
		If msStaExcQy < 0
			lOk := .F.
		EndIf

		If lOk

			dbSelectArea(ksAliasG)
			For _nI	:=	1 to Len(_oGetDados:aCols)

				If _oGetDados:aCols[_nI,nPosRec] > 0

					ksAliasG->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
					Reclock(ksAliasG,.F.)
					If !_oGetDados:aCols[_nI,nPosDel]

						For _msc := 1 to Len(_oGetDados:aHeader)

							If _oGetDados:aHeader[_msc][10] == "R"

								nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
								&(ksAliasG + "->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

							EndIf

						Next _msc

					Else

						DbDelete()

					EndIf

					MsUnlock()

				Else

					If !_oGetDados:aCols[_nI,nPosDel]

						Reclock(ksAliasG,.T.)

						&(ksChAlCa + "FILIAL")  := xFilial(ksAliasG)
						&(ksChAlCa + "ID")      := TAFGeraID("TAF")
						&(ksChAlCa + "PERIOD")  := _cPeriodo
						For _msc := 1 to Len(_oGetDados:aHeader)

							If _oGetDados:aHeader[_msc][10] == "R"

								nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
								&(ksAliasG + "->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

							EndIf

						Next _msc

						MsUnlock()

					EndIf

				EndIf

			Next

			_cPeriodo           := ctod("  /  /  ")
			_oGetDados:aCols	:=	aClone(_aColsBkp)
			_oGPeriodo:SetFocus()
			_oGPeriodo:Refresh()
			_oGetDados:Refresh()
			_oDlg:Refresh()

		Else 

			msGravaErr := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction 	

	If lOk

		MsgINFO("Processamento realizado com sucesso.", "")
		_oDlg:End()

	Else

		DisarmTransaction()
		Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )

	EndIf

Return
