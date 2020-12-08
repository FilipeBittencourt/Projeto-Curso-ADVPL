#Include "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "vkey.ch"

/*/{Protheus.doc} FPATTE03
@description Tela cadastro do ESTOQUE CLIENTE - Projeto Pedido Automatico
@author Fernando Rocha
@since 29/07/2019
@type function
/*/
User Function FPATTE03()

	Local aCores
	Private xImpDh := .F.
	Private wdProc := ""
	Private cCadastro := "ESTOQUE DO CLIENTE"
	Private aRotina
	Private lRunJob := .F.
	Private aIndScr := {}
	Private cListCli
	Private cCondicao

	aRotina   := {  {"Pesquisar"    ,'AxPesqui',0, 1},;
		{"Visualizar"   	,'AxVisual',0, 2},;
		{"Incluir"   		,'U_FPTE03MN(3)',0, 3},;
		{"Alterar"   		,'U_FPTE03MN(4)',0, 4},;
		{"Excluir Linha"   	,'U_FPTE03MN(5)',0, 5},;
		{"Excluir Estoque" 	,'U_FPAT03DE',0, 4},;
		{"Import.Excel" ,'Execblock("FPAT03EX" ,.F.,.F.,"C")',0, 3}}

	dbSelectArea("ZAI")

	If ( Type("CREPATU") <> "U" .And. !Empty(CREPATU) )
		FilterBrow()
		mBrowse(6,1,22,75, "ZAI", , , , , ,aCores, , , , , , , , , , , , cCondicao)
	ELSE
		mBrowse(6,1,22,75, "ZAI", , , , , ,aCores)
	EndIf


EndFilBrw("ZAI",aIndScr)

If ( lRunJob )
	U_EXEJBSQL("HERMES", "PEDAUT->Carga_Cliente_Ativos_Estoque", "Sincronizando Dados com BI")
EndIf

Return

Static Function FilterBrow()

	Local cCGCVend := ""
	Local cCODVend := ""

	//Quando for representante
	If Type("CREPATU") <> "U" .And. !Empty(CREPATU)

		SA3->(DbSetOrder(1))
		If SA3->(DbSeek(XFilial("SA3")+CREPATU))
			cListCli := U_FPATVCLI(CREPATU)
			cCGCVend := SA3->A3_CGC
			cCODVend := SA3->A3_COD
		EndIf

		cCondicao := "ZAI_CODCLI $ '"+cListCli+"' .and. ZAI_USER == '"+cCODVend+"'"

	Else
		cListCli := U_FPATVCLI()
		cCondicao := "ZAI_CODCLI $ '"+cListCli+"'"
	EndIf




	//bFiltraBrw := {|| FilBrowse("ZAI",@aIndScr,@cCondicao) }

	//ZAI->( Eval( bFiltraBrw ) )

Return

User Function FPTE03MN(nOpt)

	Local lRet		:= .F.

	If ( nOpt == 4)
		lRet   := AxAltera( "ZAI" , ZAI->(RecNo()), nOpt ) == 1
	ElseIf ( nOpt == 3)
		lRet   := AxInclui( "ZAI" , ZAI->(RecNo()), nOpt ) == 1
	ElseIf ( nOpt == 5)
		lRet   := AxDeleta( "ZAI" , ZAI->(RecNo()), nOpt ) == 2
	EndIf

	If (!lRunJob)
		lRunJob := lRet
	EndIf

Return

/*/{Protheus.doc} FPAT03EX
@description Funcao para importar planilha Excel para cadastro de Estoque de Clientes
/*/
User Function FPAT03EX

	Local aSays	   		:= {}
	Local aButtons 		:= {}
	Local lConfirm 		:= .F.
	Private cArquivo	:= space(500)
	Private cPCliente	:= space(6)
	Private cPLoja		:= space(2)
	Private cVendCGC	:= ""
	Private cVendCod	:= ""
	Private dDatEst		:= CTOD(" ")

	If Select("SX6") <= 0
		RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
	EndIf

	fPergunte()

	if Empty(dDatEst) .Or. Empty(cPCliente) .Or. Len(cPLoja) <> 2
		MsgStop('Informe CLIENTE, e DATA do ESTOQUE validos para importação!')
		Return
	endif

	AADD(aSays, OemToAnsi("Rotina para importação de Planilha ESTOQUE DE CLIENTES, por arquivo excel!"))
	AADD(aSays, OemToAnsi("Deseja Continuar?"))

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de ESTOQUE DE CLIENTES'), aSays, aButtons ,,,500)

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
	Local cLoad	    := 'FPAT01EXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	Local cRepre    := ".T."
	Local aRet      := {}
	Local cVenCod   := SPACE(TamSX3("A3_COD")[01])
	Local cVenCNPJ  := SPACE(TamSX3("A3_CGC")[01])

	cArquivo		:= space(500)

	if Type("CREPATU") <> "U" .And. !Empty(CREPATU)

		cRepre := ".F."  // se .T. é representante, então desabilito o campo para edição

		SA3->(DbSetOrder(1))//A3_FILIAL, A3_COD, R_E_C_N_O_, D_E_L_E_T_
		If SA3->(DbSeek(XFilial("SA3")+CREPATU))
			cVenCod  := SA3->A3_COD
			cVenCNPJ := SA3->A3_CGC
		EndIf

	EndIf

	aAdd( aPergs ,{6, "Arquivo para Importação: " 	,cArquivo  ,"","","", 90 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )
	aAdd( aPergs ,{1, "CLIENTE", SPACE(TamSX3("A1_COD")[01]), , ".T.", "SA1" ,".T.", 4, .T.})
	aAdd( aPergs ,{1, "LOJA", SPACE(TamSX3("A1_LOJA")[01]),"","","","",0,.T.}) // Tipo caractere
	aAdd( aPergs ,{1, "VENDEDOR", cVenCod,"", "U_VENDGET()", "SA3BIA" ,cRepre, 4, .F.})
	aAdd( aPergs ,{1, "CPNJ VENDEDOR",cVenCNPJ,"","","",".F.",0,.T.}) // Tipo caractere
	aAdd( aPergs ,{1, "DATA ESTOQUE", ctod("  /  /  "), , ".T.", ,".T.", 8, .T.})

	If ParamBox(aPergs ,"Importar Arquivo",@aRet,,,,,,,cLoad,.T.,.T.)

		cArquivo  := ParamLoad(cFileName,,1,cArquivo)
		cPCliente	:= ParamLoad(cFileName,,2,cPCliente)
		cPLoja		:= ParamLoad(cFileName,,3,cPLoja)
		cVendCGC	:= AllTrim(aRet[5])
		dDatEst		:= ParamLoad(cFileName,,6,dDatEst)

	Endif

Return


User Function VENDGET()

	Local lRet    := .T.

	SA3->(DbSetOrder(1))//A3_FILIAL, A3_COD, R_E_C_N_O_, D_E_L_E_T_
	If SA3->(DbSeek(XFilial("SA3")+MV_PAR04))
		&("MV_PAR05") := SA3->A3_CGC
	else
		&("MV_PAR05") := ""
	EndIf

RETURN lRet

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local aArquivo 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local nErros			:= 0
	Local nTotLin			:= 0
	Local cLogErro			:= ""
	Local _cCodLojCli		:= cPCliente+cPLoja
	Local nLinPlan			:= 1
	Local __cListCli 		:= U_FPATVCLI()
	Local nx

	ZAI->(DbSetOrder(3)) // ZAI_FILIAL+ZAI_CODCLI+ZAI_LOJCLI+ZAI_DATA+ZAI_CGCVEN
	If ZAI->(DbSeek(XFilial("ZAI")+_cCodLojCli+DTOS(dDatEst)+cVendCGC))
		MsgAlert("ESTOQUE CLIENTE NESTA DATA JA EXISTE - EXCLUIR OS REGISTROS PRIMEIRO ANTES DE IMPORTAR NOVAMENTE.")
		Return
	EndIf


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
	_aListCols 	:= {"COD_PRODUTO_CLIENTE","DESC_PRODUTO_CLIENTE","PRECO_SELL_OUT","QTDE_ESTOQUE_CLIENTE_M2"}
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

			_cProdCli		:= AllTrim(cValToChar(aLinha[1]))

			_nPrcSell		:= IIF(aLinha[3] <> Nil, aLinha[3], 0) //GetCsvNum(aLinha[3])  //Processamento via API ja traz valores numericos
			_nQtde			:= IIF(aLinha[4] <> Nil, aLinha[4], 0) //GetCsvNum(aLinha[4])

			If Empty(_cProdCli) .And. Empty(_nPrcSell) .And. Empty(_nQtde)
				loop
			EndIf

			_cCodLojCli		:= PADR(_cCodLojCli, TamSX3("A1_COD")[1]+TamSX3("A1_LOJA")[1])
			_cProdCli		  := PADR(_cProdCli, TamSX3("ZAI_CODPCL")[1])
			_cProdBianco	:= ""

			SA1->(DbSetOrder(1))
			IF Len(_cCodLojCli) <> 8 .Or. !SA1->(DbSeek(XFilial("SA1")+_cCodLojCli))

				DisarmTransaction()
				MsgAlert("ERRO - CODIGO LOJA CLIENTE NAO ENCONTRADO/INVALIDO - VERIFICAR PARAMETROS.")
				Return

			EndIf

			//VALIDAR NAO PERMITIR REPRESENTANTE IMPORTAR PLANILHA COM CLIENTES QUE NAO SEJAM DELE
			If ( Type("CREPATU") <> "U" .And. !Empty(CREPATU) ) .And. !( SubStr(_cCodLojCli,1,6) $ __cListCli )

				cLogErro += "ERRO - CODIGO LOJA CLIENTE NAO PERMITIDO PARA ESTE REPRESENTANTE - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
				nErros++
				loop

			Else //Não é representante

				cCodSA3 := ""
				If (!Empty(cVendCGC))

					SA3->(DbSetOrder(3))
					If SA3->(DbSeek(XFilial("SA3")+cVendCGC))

						cCodSA3 		:= SA3->A3_COD
						__cListCli 		:= U_FPATVCLI(cCodSA3)

						If (!( SubStr(_cCodLojCli,1,6) $ __cListCli ))

							MsgAlert("ERRO - CODIGO LOJA CLIENTE NAO PERMITIDO PARA ESTE REPRESENTANTE - <B>LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA</B>"+CRLF)
							return

						EndIf

					EndIf

				EndIf

			EndIf




			ZAG->(DbSetOrder(2))
			IF !ZAG->(DbSeek(XFilial("ZAG")+_cCodLojCli+_cProdCli))

				_cProdBianco := ""
				cLogErro += "ERRO - CODIGO PRODUTO CLIENTE NAO ENCONTRADO/NAO INFORMADO NA EQUIVALENCIA - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
				nErros++
				//loop

			Else

				_cProdBianco := ZAG->ZAG_CODPRO

			EndIf

			SB1->(DbSetOrder(1))
			IF !Empty(_cProdBianco) .And. !SB1->(DbSeek(XFilial("SB1")+_cProdBianco))

				cLogErro += "ERRO - CODIGO PRODUTO BIANCO NAO ENCONTRADO/NAO PREENCHIDO NA EQUIVALENCIA - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
				nErros++
				//loop

			EndIf

			RecLock("ZAI",.T.)
			ZAI->ZAI_FILIAL := XFILIAL("ZAI")
			ZAI->ZAI_DATA	:= dDatEst
			ZAI->ZAI_CODCLI	:= SubStr(_cCodLojCli,1,6)
			ZAI->ZAI_LOJCLI := SubStr(_cCodLojCli,7,2)
			ZAI->ZAI_CODPRO := _cProdBianco

			ZAI->ZAI_CODPCL	:= _cProdCli
			ZAI->ZAI_PRECO	:= _nPrcSell
			ZAI->ZAI_QTDE 	:= _nQtde

			ZAI->ZAI_USER	  := CUSERNAME
			ZAI->ZAI_DTIMP	:= Date()
			ZAI->ZAI_HRIMP	:= Time()
			ZAI->ZAI_FILE	  := cArquivo
			ZAI->ZAI_LINHA	:= nx
			ZAI->ZAI_CGCVEN	:= cVendCGC

			ZAI->(MsUnlock())

			nImport++

		Next nx

	EndIf

	IF !Empty(cLogErro)

		U_FROPMSG("[FPATTE03] ESTOQUE CLIENTE",cLogErro,,,"Log de Avisos e Inconsistencias")

	ENDIF

	MsgInfo(Alltrim(Str(nImport))+" Registros importados. "+Alltrim(Str(nErros))+" com ERROS. ")
	RestArea(aArea)

Return


User Function FPAT03DE()

	Local _cCodLojCli		:= ZAI->ZAI_CODCLI+ZAI->ZAI_LOJCLI
	Local _dDATA		  	:= ZAI->ZAI_DATA
	Local _cVendCGC			:= ZAI->ZAI_CGCVEN
	Local _nCont			:= 0
	Local cChaveI    	:= XFilial("ZAI")+_cCodLojCli+DTOS(_dDATA)


	//Quando for representante
	If Type("CREPATU") <> "U" .And. !Empty(CREPATU)

		SA3->(DbSetOrder(1))
		If SA3->(DbSeek(XFilial("SA3")+CREPATU))
			_cVendCGC :=SA3->A3_CGC
		EndIf

	EndIf

	If EMPTY(_cVendCGC)
		_cVendCGC := "" //Apenas para tratamento da variavel  caso ocorra algum conflito na hora do DBSeek com Nil
	EndIf

	ZAI->(DbSetOrder(3)) // ZAI_FILIAL+ZAI_CODCLI+ZAI_LOJCLI+ZAI_DATA+ZAI_CGCVEN
	If ZAI->(DbSeek(cChaveI+_cVendCGC))

		If MsgNoYes("EXCLUIR TODOS OS REGISTROS DO CLIENTE: "+_cCodLojCli+", NA DATA: "+DTOC(_dDATA)+"?")

			While !ZAI->(Eof()) .and. ZAI->ZAI_FILIAL+ZAI->ZAI_CODCLI+ZAI->ZAI_LOJCLI+DTOS(ZAI->ZAI_DATA) == cChaveI

				If !Empty(_cVendCGC) .and. ZAI->ZAI_CGCVEN  != _cVendCGC
					ZAI->(DbSkip())
					loop
				EndIF

				RecLock("ZAI",.F.)
				ZAI->(DbDelete())
				ZAI->(MsUnlock())
				_nCont++
				ZAI->(DbSkip())

			EndDo

			MsgInfo(AllTrim(Str(_nCont))+" REGISTROS EXCLUIDOS.")

			lRunJob := .T. //rodar JOB do BI apos processamento

		EndIf

	ELSE

		MsgInfo("REGISTROS NÃO ENCONTRADOS PARA O CNPJ <B>"+_cVendCGC+ "</B> OU NÃO FOI IMPORTADO COM CNPJ.")


	EndIf


Return


Static Function GetCsvNum(cContent)

	cContent := Replace(cContent,"R$","")
	cContent := Replace(cContent,"$","")
	cContent := AllTrim(cContent)

	If At('.',cContent) > 0 .And. At(',',cContent) > 0
		cContent := Replace(cContent,".","")
		cContent := Replace(cContent,",",".")
	ElseIf At(',',cContent) > 0
		cContent := Replace(cContent,",",".")
	EndIf

	nVal := Val(cContent)

Return(nVal)

