#Include "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "vkey.ch"

/*/{Protheus.doc} FPATTE04
@description Tela cadastro do TABELA DE EQUIVALENCIA DE LOJA DE CLIENTES - Projeto Pedido Automatico
@author Fernando Rocha
@since 24/07/2019
@type function
/*/
User Function FPATTE04()


	Local aCores
	Private xImpDh := .F.
	Private wdProc := ""
	Private cCadastro := "TABELA DE EQUIVALENCIA DE LOJAS"
	Private aRotina

	aRotina   := {  {"Pesquisar"    ,'AxPesqui',0, 1},;
	{"Visualizar"   ,'AxVisual',0, 2},;
	{"Import.Tab.Equivalencia" ,'Execblock("FPAT04EX" ,.F.,.F.,"C")',0, 3}}

	dbSelectArea("ZAK")
	mBrowse(6,1,22,75, "ZAK", , , , , ,aCores)

Return

/*/{Protheus.doc} FPAT04EX
@description Funcao para importar planilha Excel Planilha TABELA DE EQUIVALENCIA DE LOJAS
/*/
User Function FPAT04EX

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de Planilha TABELA DE EQUIVALENCIA DE LOJAS, por arquivo excel!"))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de TABELA DE EQUIVALENCIA DE LOJAS'), aSays, aButtons ,,,500)

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
	Local cLoad	    := 'FPAT02EXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 



	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importação TABELA DE EQUIVALENCIA
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
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
	Local nx

	ProcRegua(0) 

	msTmpINI := Time()
	//oArquivo := TBiaArquivo():New()
	//aArquivo := oArquivo:GetArquivo(cArquivo)

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
	_aListCols 	:= {"COD_LOJA_BIANCO","COD_LOJA_CLIENTE","NOME_LOJA_CLIENTE"}
	aArquivo 	:= _oApi:GetJsonList("/Arquivo", "tipoArquivo=0&nomeArquivo="+escape(_cNomFile),_aListCols)
	//FIM >>>> PROCESSAMENTO DE ARQUIVO EXCEL VIA API NO SERVIDOR

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If aArquivo <> Nil .And. Len(aArquivo) > 0 

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		aWorksheet 	:= aArquivo[1]	
		nTotLin		:= len(aWorksheet)

		ProcRegua(nTotLin)

		BEGIN TRANSACTION   

			For nx := 1 to len(aWorksheet) 

				IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

				If nx == 1

				Else

					aLinha    := aWorksheet[nx]

					_cCodLojCli 	:= AllTrim(aLinha[1])
					_cCodLojExt 	:= AllTrim(aLinha[2])
					_cNomLojExt		:= AllTrim(aLinha[3])

					_cCodLojCli		:= PADR(_cCodLojCli, TamSX3("A1_COD")[1]+TamSX3("A1_LOJA")[1])

					SA1->(DbSetOrder(1))
					IF Len(_cCodLojCli) <> 8 .Or. !SA1->(DbSeek(XFilial("SA1")+_cCodLojCli))

						DisarmTransaction()
						MsgAlert("ERRO - CODIGO LOJA CLIENTE NAO ENCONTRADO/INVALIDO - LINHA "+AllTrim(Str(nx))+" DA PLANILHA")
						Return

					EndIf

					ZAK->(DbSetOrder(1))
					//ZAK_FILIAL, ZAK_CODCLI, ZAK_LOJCLI, R_E_C_N_O_, D_E_L_E_T_
					If ZAK->(DbSeek(XFilial("ZAK")+_cCodLojCli))
						RecLock("ZAK",.F.)
					Else
						RecLock("ZAK",.T.)
						ZAK->ZAK_FILIAL := XFILIAL("ZAK")
						ZAK->ZAK_CODCLI	:= SubStr(_cCodLojCli,1,6)
						ZAK->ZAK_LOJCLI := SubStr(_cCodLojCli,7,2)
					EndIf

					ZAK->ZAK_CCLREP := _cCodLojExt
					ZAK->ZAK_NCLREP := _cNomLojExt
					ZAK->(MsUnlock())		

					nImport++

				EndIf

			Next nx

		END TRANSACTION

	EndIf

	MsgInfo(Alltrim(Str(nImport))+" Registros importados com sucesso.")
	RestArea(aArea)

Return