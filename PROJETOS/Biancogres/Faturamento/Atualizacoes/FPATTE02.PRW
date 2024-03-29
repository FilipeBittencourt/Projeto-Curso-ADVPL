#Include "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "vkey.ch"

/*/{Protheus.doc} FPATTE02
@description Tela cadastro do PRODUTO X PRODUTO CLIENTE - Projeto Pedido Automatico
@author Fernando Rocha
@since 24/07/2019
@type function
/*/
User Function FPATTE02()

	Local aCores
	Local cSQL
	Private xImpDh := .F.
	Private wdProc := ""
	Private cCadastro := "TABELA DE EQUIVALENCIA"
	Private aRotina
	Private lRunJob := .F.
	Private aIndScr := {}
	Private cListCli
	Private cCondicao

	aRotina   := {  {"Pesquisar"    ,'AxPesqui',0, 1},;
		{"Visualizar"   ,'AxVisual',0, 2},;
		{"Incluir"   	,'U_FPTE02MN(3)',0, 3},;
		{"Alterar"   	,'U_FPTE02MN(4)',0, 4},;
		{"Excluir"   	,'U_FPTE02MN(5)',0, 5},;
		{"Excluir Loja" ,'U_FPTE02DE()',0, 5},;
		{"Import.Tab.Equivalencia" ,'Execblock("FPAT02EX" ,.F.,.F.,"C")',0, 3}}

	dbSelectArea("ZAG")

	If ( Type("CREPATU") <> "U" .And. !Empty(CREPATU) )
		FilterBrow()
		mBrowse(6,1,22,75, "ZAG", , , , , ,aCores, , , , , , , , , , , , cCondicao)
	Else
		mBrowse(6,1,22,75, "ZAG", , , , , ,aCores)
	EndIf



EndFilBrw("ZAG",aIndScr)

If ( lRunJob )

	cSQL := " EXEC SP_PEDAUT_SYNC_TAB_EQUIVALENCIA "
	U_BIAMsgRun("Aguarde, Atualizando Tabela de Equivalencia... ",,{|| TcSQLExec(cSQL)})

	U_EXEJBSQL("HERMES", "PEDAUT->Carga_Cliente_Ativos_Estoque", "Sincronizando Dados com BI")

EndIf

Return

Static Function FilterBrow()

	cListCli := U_FPATVCLI()

	cCondicao := "ZAG_CODCLI $ '"+cListCli+"'"

Return

User Function FPTE02MN(nOpt)

	Local lRet   	:= .T.
	Local _cCdPrAnt

	If ( nOpt == 4)

		_cCdPrAnt := ZAG->ZAG_CODPRO

		lRet   := AxAltera( "ZAG" , ZAG->(RecNo()), nOpt ) == 1

		//SE Alterou o codigo Bianco do produto - alterar todos os registros nas tabelas de SellOut e Estoque
		If (lRet .And. !Empty(_cCdPrAnt) .And. !Empty(ZAG->ZAG_CODPRO) .And. _cCdPrAnt <> ZAG->ZAG_CODPRO )

			LjMsgRun("Aguarde... atualizando Tabela de Equivalencia",,{|| AltBasePrc(ZAG->ZAG_CODCLI, ZAG->ZAG_LOJCLI, _cCdPrAnt, ZAG->ZAG_CODPRO) })

		EndIf

	ElseIf ( nOpt == 3)
		lRet   := AxInclui( "ZAG" , ZAG->(RecNo()), nOpt ) == 1
	ElseIf ( nOpt == 5)
		lRet   := AxDeleta( "ZAG" , ZAG->(RecNo()), nOpt ) == 2
	EndIf

	If (!lRunJob)
		lRunJob := lRet
	EndIf

Return


User Function FPTE02DE()

	Local _cCodLojCli		:= ZAG->ZAG_CODCLI+ZAG->ZAG_LOJCLI
	Local _nCont			:= 0

	ZAG->(DbSetOrder(1))
	If ZAG->(DbSeek(XFilial("ZAG")+_cCodLojCli))

		If MsgNoYes("EXCLUIR TODOS OS REGISTROS DO CLIENTE: "+_cCodLojCli+"?")

			While !ZAG->(Eof()) .And. ZAG->(ZAG_FILIAL+ZAG_CODCLI+ZAG_LOJCLI) == (XFilial("ZAG")+_cCodLojCli)

				RecLock("ZAG",.F.)
				ZAG->(DbDelete())
				ZAG->(MsUnlock())

				_nCont++
				ZAG->(DbSkip())
			EndDo

			MsgInfo(AllTrim(Str(_nCont))+" REGISTROS EXCLUIDOS.")

			lRunJob := .T. //rodar JOB do BI apos processamento

		EndIf

	EndIf

Return



Static Function AltBasePrc(_cCliente, _cLoja, _cCdPrAnt, _cCdPrNew)

	U_GravaPZ2(ZAG->(RecNo()),"ZAG",_cCdPrAnt,_cCdPrNew,AllTrim(FunName()),"ZAG",CUSERNAME)

	_cSql := "UPDATE "+RetSqlName("ZAH")+" SET ZAH_CODPRO = '"+_cCdPrNew+"' WHERE ZAH_CODCLI = '"+_cCliente+"' AND ZAH_LOJCLI = '"+_cLoja+"' AND ZAH_CODPRO = '"+_cCdPrAnt+"' AND D_E_L_E_T_=' '"
	TCSQLExec(_cSql)

	_cSql := "UPDATE "+RetSqlName("ZAI")+" SET ZAI_CODPRO = '"+_cCdPrNew+"' WHERE ZAI_CODCLI = '"+_cCliente+"' AND ZAI_LOJCLI = '"+_cLoja+"' AND ZAI_CODPRO = '"+_cCdPrAnt+"' AND D_E_L_E_T_=' '"
	TCSQLExec(_cSql)

Return

/*/{Protheus.doc} FPAT01EX
@description Funcao para importar planilha Excel Planilha TABELA DE EQUIVALENCIA
/*/
User Function FPAT02EX

	Local aSays	   		:= {}
	Local aButtons 		:= {}
	Local lConfirm 		:= .F.
	Private cArquivo	:= space(500)

	fPergunte()

	AADD(aSays, OemToAnsi("�mporta��o de Planilha TABELA DE EQUIVALENCIA."))
	AADD(aSays, OemToAnsi("Deseja Continuar?"))

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importa��o de TABELA DE EQUIVALENCIA (Produto Biancogres X Produto Cliente)'), aSays, aButtons ,,,500)

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
	Local cLoad	    := 'FPAT02EXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(500)



	aAdd( aPergs ,{6,"Arquivo para Importa��o: " 	,cArquivo  ,"","","", 90 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)
		cArquivo  := ParamLoad(cFileName,,1,cArquivo)
	Endif

Return

//Processa importa��o TABELA DE EQUIVALENCIA
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local aArquivo 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local nTotLin			:= 0
	Local cLogErro			:= ""
	Local nLinPlan			:= 1
	Local nAlterados		:= 0
	Local nInseridos		:= 0
	Local __cListCli 		:= U_FPATVCLI()
	Local nx

	ProcRegua(0)

	msTmpINI := Time()

	_cPath := SubStr(cArquivo,1,RAT('\',cArquivo))
	_cNomFile := SubStr(cArquivo,RAT('\',cArquivo)+1)

	//aArquivo := U_CargaXLS(_cNomFile,_cPath,1,.F.)

	//PROCESSAMENTO DE ARQUIVO EXCEL VIA API NO SERVIDOR
	_cDefPath			:= GetNewPar("FA_PATSPTH","\P10\AUTOMACAO\PEDIDO_AUTOMATICO\")

	If ( File(_cDefPath+_cNomFile) )
		FErase(_cDefPath+_cNomFile)
	EndIf

	lRet := CpyT2S(cArquivo, _cDefPath)

	If (!lRet)
		MsgAlert("ERRO AO ENVIAR ARQUIVO: "+cArquivo+" >>> PARA O SERVIDOR.")
	EndIf

	_oApi 		:= TPATApiNet():New()
	_aListCols 	:= {"COD_PRODUTO_BIANCO","COD_PRODUTO_CLIENTE","DESC_PRODUTO_CLIENTE","COD_CLIENTE", "PRODUTO_ATIVO"}
	aArquivo 	:= _oApi:GetJsonList("/Arquivo", "tipoArquivo=0&nomeArquivo="+escape(_cNomFile),_aListCols)
	//FIM >>>> PROCESSAMENTO DE ARQUIVO EXCEL VIA API NO SERVIDOR

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If aArquivo <> Nil .And. Len(aArquivo) > 0

		lRunJob := .T. //Arquivo Ok - rodar JOB do BI apos processamento

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		nTotLin		:= len(aArquivo)

		ProcRegua(nTotLin)

		For nx := 1 to len(aArquivo)

			nLinPlan++

			IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )

			aLinha    := aArquivo[nx]

			_cProdBianco 	:= AllTrim(aLinha[1])
			_cProdCli		:= AllTrim(cValToChar(aLinha[2]))
			_cDscPrCli		:= AllTrim(aLinha[3])
			_cCodLojCli 	:= AllTrim(aLinha[4])
			_cProdAtiv		:= Upper(AllTrim(aLinha[5]))

			_cProdBianco := RemoveEsp(_cProdBianco)

			If Empty(_cProdBianco) .And. Empty(_cProdCli) .And. Empty(_cCodLojCli)
				cLogErro += "ERRO - COLUNAS OBRIGATORIA EM BRANCO - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
				loop
			EndIf

			If Len(AllTrim(_cProdBianco)) <> 8
				cLogErro += "ERRO - PRODUTO BIANCO COM TAMANHO DIFERENTE DE 8 - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
				loop
			EndIf

			If (len(_cCodLojCli)) <= 6
				_cCodLojCli += "01"
			EndIf

			_cCodLojCli		:= PADR(_cCodLojCli, TamSX3("A1_COD")[1]+TamSX3("A1_LOJA")[1])
			_cProdBianco	:= PADR(_cProdBianco, TamSX3("B1_COD")[1])


			SA1->(DbSetOrder(1))
			IF Len(_cCodLojCli) <> 8 .Or. !SA1->(DbSeek(XFilial("SA1")+_cCodLojCli))

				//DisarmTransaction()
				//MsgAlert("ERRO - CODIGO LOJA CLIENTE NAO ENCONTRADO/INVALIDO - LINHA "+AllTrim(Str(nx))+" DA PLANILHA")
				//Return

				cLogErro += "ERRO - CODIGO LOJA CLIENTE NAO ENCONTRADO/INVALIDO - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
				loop

			EndIf

			//VALIDAR NAO PERMITIR REPRESENTANTE IMPORTAR PLANILHA COM CLIENTES QUE NAO SEJAM DELE
			If ( Type("CREPATU") <> "U" .And. !Empty(CREPATU) ) .And. !( SubStr(_cCodLojCli,1,6) $ __cListCli )

				cLogErro += "ERRO - CODIGO LOJA CLIENTE NAO PERMITIDO PARA ESTE REPRESENTANTE - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
				loop

			EndIf

			SB1->(DbSetOrder(1))
			IF !SB1->(DbSeek(XFilial("SB1")+_cProdBianco))

				_cProdBianco := "" //Se nao informado ou errado o codigo Biancogres tera que ser informado depois
				cLogErro += "AVISO - CODIGO BIANCOGRES DO PRODUTO "+AllTrim(_cProdBianco)+" NAO INFORMADO/INVALIDO - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF

				//DisarmTransaction()
				//MsgAlert("ERRO - CODIGO PRODUTO BIANCO NAO ENCONTRADO - LINHA "+AllTrim(Str(nx))+" DA PLANILHA")
				//Return

			EndIf

			If Empty(_cProdCli)
				cLogErro += "AVISO - CODIGO INTERNO CLIENTE DO PRODUTO NAO INFORMADO - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
			EndIf

			If !Empty(_cProdBianco)

				ZAG->(DbSetOrder(1))
				//ZAG_FILIAL, ZAG_CODCLI, ZAG_LOJCLI, ZAG_CODPRO, R_E_C_N_O_, D_E_L_E_T_
				//S� alterar se for o mesmo codigo Bianco e codigo Cliente

				If ZAG->(DbSeek(XFilial("ZAG")+_cCodLojCli+_cProdBianco)) .And. ( AllTrim(ZAG->ZAG_CODPCL) == AllTrim(_cProdCli) )

					cLogErro += "LINHA EXISTENTE COD.BIANCO E COD.CLIENTE - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
					nAlterados++

					RecLock("ZAG",.F.)

				Else

					ZAG->(DbSetOrder(2))
					//ZAG_FILIAL, ZAG_CODCLI, ZAG_LOJCLI, ZAG_CODPCL, R_E_C_N_O_, D_E_L_E_T_
					If !Empty(_cProdCli) .And. ZAG->(DbSeek(XFilial("ZAG")+_cCodLojCli+_cProdCli))

						cLogErro += "LINHA EXISTENTE COD.CLIENTE - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
						nAlterados++

						RecLock("ZAG",.F.)
						ZAG->ZAG_CODPRO := _cProdBianco

					Else

						nInseridos++

						RecLock("ZAG",.T.)
						ZAG->ZAG_FILIAL := XFILIAL("ZAG")
						ZAG->ZAG_CODCLI	:= SubStr(_cCodLojCli,1,6)
						ZAG->ZAG_LOJCLI := SubStr(_cCodLojCli,7,2)
						ZAG->ZAG_CODPRO := _cProdBianco

					EndIf

				EndIf

				ZAG->ZAG_CODPCL := _cProdCli
				ZAG->ZAG_DSCPCL := _cDscPrCli
				ZAG->ZAG_ATIVO := IIF(( _cProdAtiv == "SIM" ),"S","N")

				ZAG->ZAG_USER	:= CUSERNAME
				ZAG->ZAG_DTIMP	:= Date()
				ZAG->ZAG_HRIMP	:= Time()
				ZAG->ZAG_FILE	:= cArquivo
				ZAG->ZAG_LINHA	:= nx

				ZAG->(MsUnlock())

			Else

				ZAG->(DbSetOrder(2))
				//ZAG_FILIAL, ZAG_CODCLI, ZAG_LOJCLI, ZAG_CODPCL, R_E_C_N_O_, D_E_L_E_T_
				If ZAG->(DbSeek(XFilial("ZAG")+_cCodLojCli+_cProdCli))

					cLogErro += "LINHA EXISTENTE COD.CLIENTE - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
					nAlterados++

					RecLock("ZAG",.F.)
					ZAG->ZAG_CODPRO := _cProdBianco
					ZAG->ZAG_ATIVO := IIF(( _cProdAtiv == "SIM" ),"S","N")
					ZAG->ZAG_DSCPCL := _cDscPrCli

					ZAG->ZAG_USER	:= CUSERNAME
					ZAG->ZAG_DTIMP	:= Date()
					ZAG->ZAG_HRIMP	:= Time()
					ZAG->ZAG_FILE	:= cArquivo
					ZAG->ZAG_LINHA	:= nx

					ZAG->(MsUnlock())

					//Se nao achou inclui linha com Codigo Biancogres em Branco para posterior alteracao
				ElseIf !Empty(_cProdCli)

					nInseridos++

					RecLock("ZAG",.T.)
					ZAG->ZAG_FILIAL := XFILIAL("ZAG")
					ZAG->ZAG_CODCLI	:= SubStr(_cCodLojCli,1,6)
					ZAG->ZAG_LOJCLI := SubStr(_cCodLojCli,7,2)
					ZAG->ZAG_ATIVO  := IIF(( _cProdAtiv == "SIM" ),"S","N")
					ZAG->ZAG_CODPCL := _cProdCli
					ZAG->ZAG_DSCPCL := _cDscPrCli

					ZAG->ZAG_USER	:= CUSERNAME
					ZAG->ZAG_DTIMP	:= Date()
					ZAG->ZAG_HRIMP	:= Time()
					ZAG->ZAG_FILE	:= cArquivo
					ZAG->ZAG_LINHA	:= nx

					ZAG->(MsUnlock())

				EndIf

			EndIf

			nImport++

		Next nx

	EndIf

	MsgInfo(Alltrim(Str(nImport))+" Registros processados.")

	U_FROPMSG("[FPATTE02] TABELA DE EQUIVALENCIA",;
		Alltrim(Str(nImport))+" Registros processados."+CRLF+Alltrim(Str(nInseridos))+" Registros inseridos."+CRLF+Alltrim(Str(nAlterados))+" Registros alterados.")

	IF !Empty(cLogErro)

		U_FROPMSG("[FPATTE02] TABELA DE EQUIVALENCIA",cLogErro,,,"Log de Avisos e Inconsistencias")

	ENDIF

	RestArea(aArea)

Return

Static Function RemoveEsp(_cTxt)

	Local nX
	Local cRes := ""

	For nX := 1 To Len(_cTxt)

		_cChar := Upper(SubStr(_cTxt,nX,1))

		If ( _cChar $ "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"  )

			cRes += _cChar

		EndIf

	Next

Return(cRes)


/*/{Protheus.doc} FPATVCLI
@description Lista de Clientes que o Representante tem Acesso
@author Fernando Rocha
@since 11/11/2019
@version 1.0
/*/
User Function FPATVCLI(cCodSA3)

	Local cSQL 				:= ""
	Local cAliasTmp 	:= GetNextAlias()
	Local cAliasRep		:= Nil
	Local cListCli 		:= ""
	Local cREPIn 			:= ""
	Local cBKPCREP		:= ""
	Default cCodSA3 	:= ""


	cBKPCREP := CREPATU // GUARDANDO O VALOR ANTIGO DA VARIAVEL CASO MUDE
	If ( Type("CREPATU") <> "U" .And. !Empty(CREPATU) ) .Or. !Empty(cCodSA3)

		If !Empty(cCodSA3)
			CREPATU := cCodSA3
		EndIf


		cREPIn := U_MontaSQLIN(CREPATU,'#',6)

		If SA3->(FieldPos("A3_YEMAPBI")) > 0

			SA3->(DbSetOrder(1))
			If SA3->(DbSeek(XFilial("SA3")+CREPATU)) .And. !Empty(SA3->A3_YEMAPBI)

				_cCodReps := ""
				cAliasRep := GetNextAlias()
				BeginSql Alias cAliasRep
					%NoParser%

					SELECT DISTINCT A3_COD FROM SA3010 WHERE RTRIM(A3_YEMAPBI) = %Exp:AllTrim(SA3->A3_YEMAPBI)% AND %NotDel%

				EndSql

				While !(cAliasRep)->(Eof())

					If !Empty(_cCodReps)

						_cCodReps += "#"

					EndIf

					_cCodReps += (cAliasRep)->A3_COD

					(cAliasRep)->(DbSkip())
				EndDo
				(cAliasRep)->(DbCloseArea())

				cREPIn := U_MontaSQLIN(_cCodReps,'#',6)

			Endif

		EndIf

		cSQL += " select distinct A1_COD "+CRLF
		cSQL += " from SA1010 "+CRLF
		cSQL += " where "+CRLF
		cSQL += " exists (select 1 from ZAG010 ZAG where ZAG_CODCLI = A1_COD and ZAG_LOJCLI = A1_LOJA and ZAG.D_E_L_E_T_='') "+CRLF

		cSQL += " and ((A1_VEND IN (" + cREPIn + ")) or "+CRLF
		cSQL += " (A1_YVENDB2 IN (" + cREPIn + ")) or "+CRLF
		cSQL += " (A1_YVENDB3 IN (" + cREPIn + ")) or "+CRLF
		cSQL += " (A1_YVENDI  IN (" + cREPIn + ")) or "+CRLF
		cSQL += " (A1_YVENDI2 IN (" + cREPIn + ")) or "+CRLF
		cSQL += " (A1_YVENDI3 IN (" + cREPIn + ")) or "+CRLF
		cSQL += " (A1_YVENBE1 IN (" + cREPIn + ")) or "+CRLF
		cSQL += " (A1_YVENBE2 IN (" + cREPIn + ")) or "+CRLF
		cSQL += " (A1_YVENBE3 IN (" + cREPIn + ")) or "+CRLF
		cSQL += " (A1_YVENPEG IN (" + cREPIn + ")) or "+CRLF
		cSQL += " (A1_YVENVI1 IN (" + cREPIn + "))) "+CRLF

		cSQL += " and D_E_L_E_T_='' "

		TcQuery cSQL New Alias (cAliasTmp)

		While !(cAliasTmp)->(Eof())

			If !Empty(cListCli)

				cListCli += "#"

			EndIf

			cListCli += (cAliasTmp)->A1_COD

			(cAliasTmp)->(DbSkip())
		EndDo
		(cAliasTmp)->(DbCloseArea())

	EndIf

	CREPATU := cBKPCREP // RESTAURANDO O VALOR ANTIGO DA VARIAVEL CASO MUDE

Return(cListCli)