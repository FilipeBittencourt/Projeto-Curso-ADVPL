#INCLUDE "Protheus.ch"

#DEFINE ENTER chr(13)+chr(10)

/*
Funcao      : CargaXLS
Objetivos   : Fun��o chamada para realizar a convers�o de XLS para um array
Par�metros  : cArqE    - Nome do arquivo XLS a ser carregado
cOrigemE - Local onde est� o arquivo XLS
nLinTitE - Quantas linhas de cabe�alho que n�o ser�o integradas possui o arquivo
Autor       : Kana�m L. R. Rodrigues 
Data/Hora   : 24/05/2012
*/

User Function CargaXLS(cArqE,cOrigemE,nLinTitE,lTela)   

	Local bOk        := {||lOk:=.T.,oDlg:End()}
	Local bCancel    := {||lOk:=.F.,oDlg:End()}
	Local lOk        := .F.
	Local nLin       := 20
	Local nCol1      := 15
	Local nCol2      := nCol1+30
	Local cMsg       := ""
	Local oDlg
	Local oArq
	Local oOrigem
	Local oMacro  

	Default lTela := .T.

	Private cArq       := If(ValType(cArqE)=="C",cArqE,"")
	Private cArqMacro  := "XLS2DBF.XLA"
	Private cTemp      := GetTempPath() //pega caminho do temp do client
	Private cSystem    := Upper(GetSrvProfString("STARTPATH",""))//Pega o caminho do sistema
	Private cOrigem    := If(ValType(cOrigemE)=="C",cOrigemE,"")
	Private nLinTit    := If(ValType(nLinTitE)=="N",nLinTitE,0)
	Private aArquivos  := {}
	Private aRet       := {}


	cArq       += Space(20-(Len(cArq)))
	cOrigem    += Space(99-(Len(cOrigem)))
	

	If lTela .Or. Empty(AllTrim(cArq)) .Or. Empty(AllTrim(cOrigem)) 

		Define MsDialog oDlg Title 'Integra��o de Excel' From 7,10 To 20,50 OF oMainWnd         


		@ nLin,nCol1  Say      'Arquivo :'                                Of oDlg Pixel  
		@ nLin,nCol2  MsGet    oArq   Var cArq                 Size 60,09 Of oDlg Pixel  

		nLin += 15

		@ nLin,nCol1  Say      'Caminho do arquivo :'                     Of oDlg Pixel  
		nLin += 10
		@ nLin,nCol1  MsGet    oOrigem Var cOrigem            Size 130,09 Of oDlg Pixel  

		nLin += 15

		@ nLin,nCol1  Say      'Nome da Macro :'                          Of oDlg Pixel  
		nLin += 10
		@ nLin,nCol1  MsGet    oMacro  Var cArqMacro When .F. Size 130,09 Of oDlg Pixel  

		Activate MsDialog oDlg On Init Enchoicebar(oDlg,bOk,bCancel) Centered
	Else
		lOk := .T.
	EndIf

	If lOk 
		cMsg := validaCpos()
		If Empty(cMsg) 
			aAdd(aArquivos, cArq)
			IntegraArq()
		Else
			MsgStop(cMSg)
			Return
		EndIf
	EndIf
	//
Return aRet


/*
Funcao      : IntegraArq
Objetivos   : Faz a chamada das rotinas referentes a integra��o
Autor       : Kana�m L. R. Rodrigues 
Data/Hora   : 24/05/2012
*/

Static Function IntegraArq()

	Local lConv      := .F.
	//converte arquivos xls para csv copiando para a pasta temp
	MsAguarde( {|| ConOut("Come�ou convers�o do arquivo "+cArq+ " - "+Time()),;
	lConv := convArqs(aArquivos) }, "Convertendo arquivos", "Convertendo arquivos" )
	If lConv
		//carrega do xls no array
		ConOut("Terminou convers�o do arquivo "+cArq+ " - "+Time())   
		ConOut("Come�ou carregamento do arquivo "+cArq+ " - "+Time())
		Processa( {|| aRet:= CargaArray(AllTrim(cArq)) } ,;
		"Aguarde, carregando planilha..."+ENTER+"Pode demorar") 
		ConOut("Terminou carregamento do arquivo "+cArq+ " - "+Time())
		//
	EndIf
	//
Return

/*
Funcao      : convArqs
Objetivos   : converte os arquivos .xls para .csv
Autor       : Kana�m L. R. Rodrigues 
Data/Hora   : 24/05/2012
*/

Static Function convArqs(aArqs)

	Local oExcelApp
	Local cNomeXLS  := ""
	Local cFile     := ""
	Local cExtensao := ""
	Local i         := 1
	Local j         := 1
	Local aExtensao := {}

	cOrigem := AllTrim(cOrigem)

	//Verifica se o caminho termina com "\"
	If !Right(cOrigem,1) $ "\"
		cOrigem := AllTrim(cOrigem)+"\"
	EndIf


	//loop em todos arquivos que ser�o convertidos
	For i := 1 To Len(aArqs)      

		If !"." $ AllTrim(aArqs[i])
			//passa por aqui para verifica se a extens�o do arquivo � .xls ou .xlsx
			aExtensao := Directory(cOrigem+AllTrim(aArqs[i])+".*")
			For j := 1 To Len(aExtensao)
				If "XLS" $ Upper(aExtensao[j][1])
					cExtensao := SubStr(aExtensao[j][1],Rat(".",aExtensao[j][1]),Len(aExtensao[j][1])+1-Rat(".",aExtensao[j][1]))
					Exit
				EndIf
			Next j
		EndIf
		//recebe o nome do arquivo corrente
		cNomeXLS := AllTrim(aArqs[i])
		cFile    := cOrigem+cNomeXLS+cExtensao

		If !File(cFile)
			MsgInfo("O arquivo "+cFile+" n�o foi encontrado!" ,"Arquivo")      
			Return .F.
		EndIf

		//verifica se existe o arquivo na pasta temporaria e apaga
		If File(cTemp+cNomeXLS+cExtensao)
			fErase(cTemp+cNomeXLS+cExtensao)
		EndIf                 

		//Copia o arquivo XLS para o Temporario para ser executado
		//If !AvCpyFile(cFile,cTemp+cNomeXLS+cExtensao,.F.)
		If !(__CopyFile(cFile, cTemp+cNomeXLS+cExtensao)) 
			MsgInfo("Problemas na copia do arquivo "+cFile+" para "+cTemp+cNomeXLS+cExtensao ,"__CopyFile()")
			Return .F.
		EndIf                                       

		//apaga macro da pasta tempor�ria se existir
		//If File(cTemp+cArqMacro)
		//	fErase(cTemp+cArqMacro)
		//EndIf

		//Copia o arquivo XLA para o Temporario para ser executado
		//If !AvCpyFile(cSystem+cArqMacro,cTemp+cArqMacro,.F.)
		/*If !(CpyS2T(cSystem+cArqMacro, cTemp)) 
			MsgInfo("Problemas na copia do arquivo "+cSystem+cArqMacro+"para"+cTemp ,"CpyS2T()")
			Return .F.
		EndIf*/

		//Exclui o arquivo antigo (se existir)
		If File(cTemp+cNomeXLS+".csv")
			fErase(cTemp+cNomeXLS+".csv")
		EndIf

		//Inicializa o objeto para executar a macro
		oExcelApp := MsExcel():New()             
		//define qual o caminho da macro a ser executada

		_cCliPath := PathSCli()

		If !File(_cCliPath+cArqMacro)
			MsgInfo("O arquivo "+_cCliPath+cArqMacro+" n�o foi encontrado!" ,"Arquivo Macro Excel")      
			Return .F.
		EndIf

		oExcelApp:WorkBooks:Open(_cCliPath+cArqMacro)       
		//executa a macro passando como parametro da macro o caminho e o nome do excel corrente
		oExcelApp:Run(cArqMacro+'!XLS2DBF',cTemp,cNomeXLS)
		//fecha a macro sem salvar
		oExcelApp:WorkBooks:Close('savechanges:=False')
		//sai do arquivo e destr�i o objeto
		oExcelApp:Quit()
		oExcelApp:Destroy()

		//Exclui o Arquivo excel da temp
		fErase(cTemp+cNomeXLS+cExtensao)
		//fErase(cTemp+cArqMacro) //Exclui a Macro no diretorio temporario
		//
	Next i
	//
Return .T. 

/*
Funcao      : CargaDados
Objetivos   : carrega dados do csv no array pra retorno
Par�metros  : cArq - nome do arquivo que ser� usado      
Autor       : Kana�m L. R. Rodrigues 
Data/Hora   : 24/05/2012
*/

Static Function CargaArray(cArq)

	Local cLinha  := ""
	Local nLin    := 1 
	Local nTotLin := 0
	Local aDados  := {}
	Local cFile   := ""
	Local nHandle := 0
	
	//remover extensao
	cArq := Upper(cArq)
	cArq := Replace(cArq,'.XLSX','')
	cArq := Replace(cArq,'.XLS','')
	
	cFile   := cTemp + cArq + ".csv"

	//abre o arquivo csv gerado na temp
	nHandle := Ft_Fuse(cFile)
	If nHandle == -1
		Return aDados
	EndIf
	Ft_FGoTop()                                                         
	nLinTot := FT_FLastRec()-1
	ProcRegua(nLinTot)
	//Pula as linhas de cabe�alho
	While nLinTit > 0 .AND. !Ft_FEof()
		Ft_FSkip()
		nLinTit--
	EndDo

	//percorre todas linhas do arquivo csv
	Do While !Ft_FEof()
		//exibe a linha a ser lida
		IncProc("Carregando Linha "+AllTrim(Str(nLin))+" de "+AllTrim(Str(nLinTot)))
		nLin++
		//le a linha
		cLinha := Ft_FReadLn()
		//verifica se a linha est� em branco, se estiver pula
		If Empty(AllTrim(StrTran(cLinha,';','')))
			Ft_FSkip()
			Loop
		EndIf
		//transforma as aspas duplas em aspas simples
		cLinha := StrTran(cLinha,'"',"'")
		cLinha := '{"'+cLinha+'"}' 
		//adiciona o cLinha no array trocando o delimitador ; por , para ser reconhecido como elementos de um array 
		cLinha := StrTran(cLinha,';','","')
		aAdd(aDados, &cLinha)

		//passa para a pr�xima linha
		FT_FSkip()
		//
	EndDo

	//libera o arquivo CSV
	FT_FUse()             

	//Exclui o arquivo csv
	If File(cFile)
		FErase(cFile)
	EndIf

Return aDados


/*
Funcao      : validaCpos
Objetivos   : faz a valida��o dos campos da tela de filtro
Autor       : Kana�m L. R. Rodrigues 
Data/Hora   : 24/05/2012
*/

Static Function validaCpos()

	Local cMsg := ""

	If Empty(cArq)
		cMsg += "Campo Arquivo deve ser preenchido!"+ENTER
	EndIf                            

	If Empty(cOrigem)
		cMsg += "Campo Caminho do arquivo deve ser preenchido!"+ENTER
	EndIf

	If Empty(cArqMacro)
		cMsg += "Campo Nome da Macro deve ser preenchido!"
	EndIf

Return cMsg


Static function PathSCli()

  Local cIniName := GetRemoteIniName() // Resultado: "C:\totvs\bin\SmartClient\smartclient.ini"
  Local lUnix := IsSrvUnix()
  Local nPos := Rat( IIf( lUnix, "/", "\" ), cIniName )
  Local cPathRmt
   
  if !( nPos == 0 )
    cPathRmt := SubStr( cIniName, 1, nPos - 1 )
  else
    cPathRmt := ""
  endif
   
Return(cPathRmt + "\")