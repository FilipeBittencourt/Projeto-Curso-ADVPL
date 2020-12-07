#Include "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "vkey.ch"

/*/{Protheus.doc} FPATTE01
@description Tela cadastro do SELLOUT dos clientes x produtos - Projeto Pedido Automatico
@author Fernando Rocha
@since 24/07/2019
@type function
/*/
User Function FPATTE01()

	Local aCores
	Private xImpDh := .F.
	Private wdProc := ""
	Private cCadastro := "SELLOUT CLIENTE X PRODUTO"
	Private aRotina
	Private lRunJob := .F.

	aRotina   := {  {"Pesquisar"    ,'AxPesqui',0, 1},;
	{"Visualizar"   	,'AxVisual',0, 2},;
	{"Incluir"   		,'U_FPTE01MN(3)',0, 3},;
	{"Alterar"   		,'U_FPTE01MN(4)',0, 4},;
	{"Excluir Linha"   	,'U_FPTE01MN(5)',0, 5},;
	{"Excluir SellOut" 	,'U_FPAT01DE',0, 4},;
	{"Import.Excel" ,'Execblock("FPAT01EX" ,.F.,.F.,"C")',0, 3}}

	dbSelectArea("ZAH")
	mBrowse(6,1,22,75, "ZAH", , , , , ,aCores)

	If ( lRunJob )
		U_EXEJBSQL("HERMES", "PEDAUT->Carga_Cliente_SellOut", "Sincronizando Dados com BI")
	EndIf

Return

User Function FPTE01MN(nOpt)

	Local lRet   	:= .T.
	Local aArea 	:= GetArea()
	Local nOpcao 	:= 4	
	Local lRet		:= .F.	

	If ( nOpt == 4)
		lRet   := AxAltera( "ZAH" , ZAH->(RecNo()), nOpt ) == 1
	ElseIf ( nOpt == 3)
		lRet   := AxInclui( "ZAH" , ZAH->(RecNo()), nOpt ) == 1
	ElseIf ( nOpt == 5)
		lRet   := AxDeleta( "ZAH" , ZAH->(RecNo()), nOpt ) == 2
	EndIf

	If (!lRunJob)
		lRunJob := lRet
	EndIf

Return


/*/{Protheus.doc} FPAT01EX
@description Funcao para importar planilha Excel para cadastro de SellOut de Clientes
/*/
User Function FPAT01EX

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(500)
	Private cPCliente	:= space(6)
	Private cPLoja		:= space(2)

	fPergunte()

	AADD(aSays, OemToAnsi("Importação de Planilha SELL OUT de Clientes"))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Sell Out de Clientes X Produtos'), aSays, aButtons ,,,500)

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
	cArquivo		:= space(500) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 90 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		
	aAdd( aPergs ,{1, "CLIENTE", space(6), , ".T.", "SA1" ,".T.", 4, .F.})
	aAdd( aPergs ,{1, "LOJA", space(2), , ".T.", ,".T.", 4, .F.})

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)  

		cArquivo  	:= ParamLoad(cFileName,,1,cArquivo) 
		cPCliente	:= ParamLoad(cFileName,,2,cPCliente)
		cPLoja		:= ParamLoad(cFileName,,3,cPLoja)

	Endif

Return 

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZAH'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	local nRepeat			:= 0
	Local nErros			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local cLogErro			:= ""
	Local _cCodLojCli		:= cPCliente+cPLoja
	Local aMesesX			:= {}
	Local nLinPlan			:= 1
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
	_aListCols 	:= {"ANO","MES","COD_PRODUTO_CLIENTE","DESC_PRODUTO_CLIENTE","VENDA_REAIS","VENDA_QTDE_M2"}
	aArquivo 	:= _oApi:GetJsonList("/Arquivo", "tipoArquivo=0&nomeArquivo="+escape(_cNomFile),_aListCols)
	//FIM >>>> PROCESSAMENTO DE ARQUIVO EXCEL VIA API NO SERVIDOR

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If aArquivo <> Nil .And. Len(aArquivo) > 0 

		lRunJob 	:= .T.

		nTotLin		:= len(aArquivo)

		ProcRegua(nTotLin)

		For nx := 1 to len(aArquivo) 

			IncProc("Tmp Leit:(" + msTmpRead + ") Validando: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

			aLinha    := aArquivo[nx]

			cAno			:= AllTrim(aLinha[1])
			cMes			:= AllTrim(aLinha[2])

			cAno	:= PADL(cAno,4,'0')
			cMes	:= PADL(cMes,2,'0')

			ZAH->(DbSetOrder(1))
			//ZAH_FILIAL, ZAH_ANO, ZAH_MES, ZAH_CODCLI, ZAH_LOJCLI, ZAH_CODPRO, R_E_C_N_O_, D_E_L_E_T_
			If ZAH->(DbSeek(XFilial("ZAH")+cAno+cMes+_cCodLojCli)) .And. aScan(aMesesX,{|x| x == cAno+cMes}) <= 0

				AAdd(aMesesX,cAno+cMes)

			EndIf

		Next nx

		For nx := 1 To len(aMesesX)

			cLogErro += "MES/ANO: "+aMesesX[nx]+" - JA POSSUI DADOS - EXCLUIR TUDO ANTES DE IMPORTAR NOVAMENTE."+CRLF

		Next nx



		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		nTotLin		:= len(aArquivo)

		ProcRegua(nTotLin)


		For nx := 1 to len(aArquivo) 		

			nLinPlan++

			IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

			aLinha    := aArquivo[nx]

			cAno			:= AllTrim(aLinha[1])
			cMes			:= AllTrim(aLinha[2])
			_cProdCli		:= AllTrim(cValTochar(aLinha[3]))
			_nValor			:= IIF(aLinha[5] <> Nil, aLinha[5], 0)  //GetCsvNum(aLinha[5])
			_nQtde			:= IIF(aLinha[6] <> Nil, aLinha[6], 0)  //GetCsvNum(aLinha[6])			

			cAno	:= PADL(cAno,4,'0')
			cMes	:= PADL(cMes,2,'0')			

			If Empty(_cProdCli) .And. Empty(_nQtde) .And. Empty(_nValor)
				loop					
			EndIf

			If aScan(aMesesX,{|x| x == cAno+cMes}) > 0
				loop					
			EndIf

			_cCodLojCli		:= PADR(_cCodLojCli, TamSX3("A1_COD")[1]+TamSX3("A1_LOJA")[1])
			_cProdCli		:= PADR(_cProdCli, TamSX3("ZAH_CODPCL")[1])

			_cProdBianco	:= ""

			SA1->(DbSetOrder(1))
			IF Len(_cCodLojCli) <> 8 .Or. !SA1->(DbSeek(XFilial("SA1")+_cCodLojCli))

				DisarmTransaction()
				MsgAlert("ERRO - CODIGO LOJA CLIENTE NAO ENCONTRADO/INVALIDO - VERIFICAR PARAMETROS.")
				Return

			EndIf

			ZAG->(DbSetOrder(2))
			IF !ZAG->(DbSeek(XFilial("ZAG")+_cCodLojCli+_cProdCli))

				cLogErro += "ERRO - CODIGO PRODUTO CLIENTE NAO ENCONTRADO - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF+"VERIFICAR IMPORTACAO DO ARQUIVO LISTA DE ATIVOS"+CRLF
				nErros++
				//loop

			Else

				_cProdBianco := ZAG->ZAG_CODPRO

			EndIf

			SB1->(DbSetOrder(1))
			IF !SB1->(DbSeek(XFilial("SB1")+_cProdBianco))

				cLogErro += "ERRO - CODIGO PRODUTO BIANCO NAO ENCONTRADO/NAO INFORMADO NA EQUIVALENCIA - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
				nErros++
				//loop

			EndIf

			If (ValType(_nQtde) <> "N" .Or. ValType(_nValor) <> "N")

				cLogErro += "ERRO - QTDE OU VALOR INVALIDO - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
				nErros++
				loop

			EndIf

			ZAH->(DbSetOrder(1))
			//ZAH_FILIAL, ZAH_ANO, ZAH_MES, ZAH_CODCLI, ZAH_LOJCLI, ZAH_CODPRO, R_E_C_N_O_, D_E_L_E_T_

			RecLock("ZAH",.T.)
			ZAH->ZAH_FILIAL := XFILIAL("ZAH")
			ZAH->ZAH_ANO	:= cAno
			ZAH->ZAH_MES	:= cMes
			ZAH->ZAH_CODCLI	:= SubStr(_cCodLojCli,1,6)
			ZAH->ZAH_LOJCLI := SubStr(_cCodLojCli,7,2)
			ZAH->ZAH_CODPRO := _cProdBianco
			ZAH->ZAH_CODPCL	:= _cProdCli
			ZAH->ZAH_QTDE	:= _nQtde 
			ZAH->ZAH_VALOR	:= _nValor

			ZAH->ZAH_USER	:= CUSERNAME
			ZAH->ZAH_DTIMP	:= Date()
			ZAH->ZAH_HRIMP	:= Time()
			ZAH->ZAH_FILE	:= cArquivo
			ZAH->ZAH_LINHA	:= nx

			ZAH->(MsUnlock())		

			nImport++


		Next nx

	EndIf

	IF !Empty(cLogErro)

		U_FROPMSG("[FPATTE01] SELL OUT CLIENTE",cLogErro,,,"Log de Avisos e Inconsistencias")

	ENDIF	

	MsgInfo(Alltrim(Str(nImport))+" Registros importados. "+Alltrim(Str(nErros))+" com ERROS. ")
	RestArea(aArea)

Return


User Function FPAT01DE()

	LjMsgRun("Aguarde... processando exclusao do SellOut",,{|| DelProc() })

Return

Static Function DelProc()

	Local _cCodLojCli		:= ZAH->ZAH_CODCLI+ZAH->ZAH_LOJCLI
	Local _cAno				:= ZAH->ZAH_ANO
	Local _cMes				:= ZAH->ZAH_MES
	Local _nCont			:= 0

	ZAH->(DbSetOrder(1))
	If ZAH->(DbSeek(XFilial("ZAH")+_cAno+_cMes+_cCodLojCli))

		If MsgNoYes("EXCLUIR TODOS OS REGISTROS DO CLIENTE: "+_cCodLojCli+", NO PERIODO: "+_cMes+"/"+_cAno+"?")

			While !ZAH->(Eof()) .And. ZAH->(ZAH_FILIAL+ZAH->ZAH_ANO+ZAH->ZAH_MES+ZAH->ZAH_CODCLI+ZAH->ZAH_LOJCLI) == (XFilial("ZAH")+_cAno+_cMes+_cCodLojCli)

				RecLock("ZAH",.F.)
				ZAH->(DbDelete())
				ZAH->(MsUnlock())

				_nCont++
				ZAH->(DbSkip())
			EndDo

			MsgInfo(AllTrim(Str(_nCont))+" REGISTROS EXCLUIDOS.")

			lRunJob := .T.

		EndIf

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