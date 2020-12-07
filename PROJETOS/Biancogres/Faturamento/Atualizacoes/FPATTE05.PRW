#Include "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "vkey.ch"

/*/{Protheus.doc} FPATTE05
@description Tela cadastro dos parametros de CLIENTE para pedido automatico
@author Fernando Rocha
@since 24/07/2019
@type function
/*/
User Function FPATTE05()

	Local aCores
	Private xImpDh := .F.
	Private wdProc := ""
	Private cCadastro := "PARAMETROS VENDA X CLIENTE"
	Private aRotina
	Private lRunJob := .F.

	aRotina   := {  {"Pesquisar"    ,'AxPesqui',0, 1},;
	{"Visualizar"   	,'AxVisual',0, 2},;
	{"Incluir"   		,'U_FPTE05MN(3)',0, 3},;
	{"Alterar"   		,'U_FPTE05MN(4)',0, 4},;
	{"Excluir"   		,'U_FPTE05MN(5)',0, 5},;
	{"Import.Excel" ,'Execblock("FPAT05EX" ,.F.,.F.,"C")',0, 3}}

	dbSelectArea("ZAN")
	mBrowse(6,1,22,75, "ZAN", , , , , ,aCores)

	If ( lRunJob )
		U_EXEJBSQL("HERMES", "PEDAUT->Carga_Biancogres_Param_Loja", "Sincronizando Dados com BI")
	EndIf

Return

User Function FPTE05MN(nOpt)

	Local lRet   	:= .T.
	Local aArea 	:= GetArea()
	
	If ( nOpt == 4)
		lRet   := AxAltera( "ZAN" , ZAN->(RecNo()), nOpt ) == 1
	ElseIf ( nOpt == 3)
		lRet   := AxInclui( "ZAN" , ZAN->(RecNo()), nOpt ) == 1
	ElseIf ( nOpt == 5)
		lRet   := AxDeleta( "ZAN" , ZAN->(RecNo()), nOpt ) == 2
	EndIf

	If (!lRunJob)
		lRunJob := lRet
	EndIf

	RestArea(aArea)

Return


/*/{Protheus.doc} FPAT01EX
@description Funcao para importar planilha Excel para cadastro de SellOut de Clientes
/*/
User Function FPAT05EX

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(500)

	fPergunte()

	AADD(aSays, OemToAnsi("Importação de Planilha PARAMETROS de Clientes"))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de PARAMETROS de Clientes'), aSays, aButtons ,,,500)

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
	Local cLoad	    := 'FPAT05EXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(500) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 90 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)  

		cArquivo  	:= ParamLoad(cFileName,,1,cArquivo)

	Endif

Return 

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local aArquivo 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local nErros			:= 0
	Local nTotLin			:= 0
	Local cLogErro			:= ""
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
	_aListCols 	:= {"COD_LOJA_BIANCO","COBERTURA_LOJA","TRANSIT_TIME","EMPENHO","SATURACAO_MAX","SATURACAO_MIN","SUGESTAO_EMISSAO","REPOSICOES_POR_MES","ENTRE_REPOSICOES","MEDIA_MESES","INF_SELL_EST"}
	aArquivo 	:= _oApi:GetJsonList("/Arquivo", "tipoArquivo=0&nomeArquivo="+escape(_cNomFile),_aListCols)
	//FIM >>>> PROCESSAMENTO DE ARQUIVO EXCEL VIA API NO SERVIDOR

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If aArquivo <> Nil .And. Len(aArquivo) > 0 

		lRunJob 	:= .T.

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		nTotLin		:= len(aArquivo)

		ProcRegua(nTotLin)


		For nx := 1 to len(aArquivo) 		

			nLinPlan++

			IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

			aLinha    := aArquivo[nx]

			_cCodLojCli			:= AllTrim(aLinha[1])

			nCOB_LOJA			:= aLinha[2]	
			nTRA_TIME			:= aLinha[3]	
			nEMPENHO			:= aLinha[4]	
			nSAT_MAX			:= aLinha[5]		
			nSAT_MIN			:= aLinha[6]
			nSUG_EMISSAO		:= aLinha[7]		
			nREP_POR_MES		:= aLinha[8]		
			nENT_REPOSICOES		:= aLinha[9]
			nMED_MESES			:= aLinha[10]	
			cINF_EST			:= AllTrim(aLinha[11])

			If Empty(_cCodLojCli)
				loop					
			EndIf

			_cCodLojCli		:= PADR(_cCodLojCli, TamSX3("A1_COD")[1]+TamSX3("A1_LOJA")[1])

			SA1->(DbSetOrder(1))
			IF Len(_cCodLojCli) <> 8 .Or. !SA1->(DbSeek(XFilial("SA1")+_cCodLojCli))

				DisarmTransaction()
				MsgAlert("ERRO - CODIGO LOJA CLIENTE NAO ENCONTRADO/INVALIDO - VERIFICAR PARAMETROS.")
				Return

			EndIf			


			If  (ValType(nCOB_LOJA) <> "N" .Or. ValType(nTRA_TIME) <> "N" .Or. ValType(nEMPENHO) <> "N" .Or. ValType(nSAT_MAX) <> "N" .Or. ValType(nSAT_MIN) <> "N" .Or. ValType(nSUG_EMISSAO) <> "N" .Or. ValType(nREP_POR_MES) <> "N" .Or. ValType(nENT_REPOSICOES) <> "N" .Or.ValType(nMED_MESES) <> "N")

				cLogErro += "ERRO - VALOR INVALIDO - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
				nErros++
				loop

			EndIf


			If  !(AllTrim(Upper(cINF_EST)) == "S" .Or. AllTrim(Upper(cINF_EST)) == "N")

				cLogErro += "ERRO - CAMPO INF_SELL_EST INVALIDO (tem que ser S ou N) - LINHA "+AllTrim(Str(nLinPlan))+" DA PLANILHA"+CRLF
				nErros++
				loop

			EndIf


			ZAN->(DbSetOrder(1))
			IF ZAN->(DbSeek(XFilial("ZAN")+_cCodLojCli))

				RecLock("ZAN",.F.)

			Else

				RecLock("ZAN",.T.)
				ZAN->ZAN_FILIAL := XFILIAL("ZAN")
				ZAN->ZAN_CODCLI := SubStr(_cCodLojCli,1,6)
				ZAN->ZAN_LOJCLI := SubStr(_cCodLojCli,7,2)				

			EndIf

			ZAN->ZAN_COBERT	:= nCOB_LOJA
			ZAN->ZAN_TRTIME	:= nTRA_TIME
			ZAN->ZAN_EMPENH	:= nEMPENHO
			ZAN->ZAN_SATMAX	:= nSAT_MAX
			ZAN->ZAN_SATMIN	:= nSAT_MIN
			ZAN->ZAN_SUGEMI	:= nSUG_EMISSAO
			ZAN->ZAN_REPMES	:= nREP_POR_MES
			ZAN->ZAN_ENTREP	:= nENT_REPOSICOES
			ZAN->ZAN_MEDMES	:= nMED_MESES
			ZAN->ZAN_INFEST	:= cINF_EST

			ZAN->ZAN_USER	:= CUSERNAME
			ZAN->ZAN_DTIMP	:= Date()
			ZAN->ZAN_HRIMP	:= Time()
			ZAN->ZAN_FILE	:= cArquivo
			ZAN->ZAN_LINHA	:= nx

			ZAN->(MsUnlock())		

			nImport++

		Next nx

	EndIf

	IF !Empty(cLogErro)

		U_FROPMSG("[FPATTE01] PARAMETROS CLIENTE",cLogErro,,,"Log de Avisos e Inconsistencias")

	ENDIF	

	MsgInfo(Alltrim(Str(nImport))+" Registros importados. "+Alltrim(Str(nErros))+" com ERROS. ")
	RestArea(aArea)

Return
