#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} AO_METAS
@description Cadastro de Acordos de Objetivos
@author Fernando Rocha
@since 17/06/2014
@version undefined
@type function
/*/
User Function AO_METAS()

	Private cCadastro 	:= "Metas AO" 
	Private _nTotBasRea := 0
	Private _nTotBasAju := 0
	Private aTempSI		:= {}

	Private aRotina   := {  {"Pesquisar"    	,'AxPesqui'                      			,0, 1},;
	{"Visualizar"   	,'Execblock("AOMETAMNT" ,.F.,.F.,"V")'    	,0, 2},;
	{"Incluir"      	,'Execblock("AOMETAMNT" ,.F.,.F.,"I")'    	,0, 3},;
	{"Alterar Acordo"   ,'Execblock("AOMETAMNT" ,.F.,.F.,"A")'    	,0, 4},;
	{"Atualizar"      	,'Execblock("AOMETAMNT" ,.F.,.F.,"T")'    	,0, 4},;
	{"Excluir"      	,'Execblock("AOMETAMNT" ,.F.,.F.,"E")'    	,0, 5},;
	{"Aprovar"      	,'Execblock("AOMETAMNT" ,.F.,.F.,"P")'    	,0, 2},;
	{"Imprimir"     	,'U_AO_IMPWR'    							,0, 2},;
	{"Workflow"     	,'U_AO_WF()'								,0, 4},;
	{"Legenda"      	,'U_AOMETALE'    						  	,0, 4},;
	{"WF AI x Lanc"		,'U_AOWFLANC'    						  	,0, 2},;
	{"WF AO sem Bonus"	,'U_AOWFAOAI'    						  	,0, 2},;
	{"Proc. Realizado" 	,'U_AO_UPDREA'    						  	,0, 2}}

	//Legenda
	Private aCores    := {	{  'PZ5_STATUS=="N"'	, 'BR_BRANCO' 	},;
	{  'PZ5_STATUS=="A"'	, 'BR_AMARELO' 	},;
	{  'PZ5_STATUS=="S"'	, 'BR_VERDE' 	} }

	dbSelectArea("PZ5")
	dbGoTop()
	mBrowse(6,1,22,75, "PZ5",,,,,,aCores)

Return

User Function AOMETALE()
	Local aLegenda := { 	{ 'BR_BRANCO'	,	"Novo Acordo" 		},;
	{ 'BR_AMARELO'	,   "Acordo Alterado"  	},;
	{ 'BR_VERDE'	,   "Acordo Aprovado"  	} }

	BRWLEGENDA( cCadastro, "Legenda", aLegenda )
Return

User Function AOMETAMNT()

	Local i
	Private nprox := 0
	Private _aSize := MSADVSIZE()

	//Determina funcao selecionada                                             ³
	wOpcao      := paramixb
	lVisualizar := .F.
	lIncluir    := .F.
	lAlterar    := .F.
	lExcluir    := .F.

	Private lAprova := .F. 

	//variaveis para Rodape Customizado
	Private oDlg
	Private oGetTotBR 
	Private nGetTotBR := 0
	Private oGetTotBA
	Private nGetTotBA := 0

	If (wOpcao $ "A_I_E")
		If !U_VALOPER("AO2")
			Return
		EndIf
	EndIf

	If (wOpcao == "P")

		If !U_VALOPER("AO1")
			Return
		EndIf

		lAprova := .T.
		wOpcao := "V"
	EndIf

	Do Case
		Case wOpcao == "V" .Or. wOpcao == "T"; lVisualizar := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "VISUALIZAR"
		Case wOpcao == "I" ; lIncluir    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "INCLUIR"
		Case wOpcao == "A" ; lAlterar    := .T. ; nOpcE := 4 ; nOpcG := 4 ; cOpcao := "ALTERAR"
		Case wOpcao == "E" ; lExcluir    := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "EXCLUIR"
	EndCase

	//Cria variaveis
	RegToMemory("PZ5",(cOpcao=="INCLUIR"))

	//Monta aHeader
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("PZ6")
	nUsado  := 0
	aHeader := {}
	While !eof() .and. SX3->X3_ARQUIVO == "PZ6"
		If  X3USO(SX3->X3_USADO) .and. SX3->X3_NIVEL <= cNivel .And. !(Alltrim(SX3->X3_CAMPO) $ "PZ6_CODIGO")

			If lIncluir .Or.;
			!(SubStr(SX3->X3_CAMPO,1,8) $ "PZ6_PERC#PZ6_META#PZ6_PBON") .Or.;
			(	(Alltrim(SX3->X3_CAMPO) $ "PZ6_PERCF1#PZ6_METAF1#PZ6_PBONF1") .Or.;
			(Alltrim(SX3->X3_CAMPO) $ "PZ6_PERCF2#PZ6_METAF2#PZ6_PBONF2" .And. M->PZ5_NFAIXA >= '2') .Or.;
			(Alltrim(SX3->X3_CAMPO) $ "PZ6_PERCF3#PZ6_METAF3#PZ6_PBONF3" .And. M->PZ5_NFAIXA >= '3') .Or.;
			(Alltrim(SX3->X3_CAMPO) $ "PZ6_PERCF4#PZ6_METAF4#PZ6_PBONF4" .And. M->PZ5_NFAIXA >= '4') .Or.;
			(Alltrim(SX3->X3_CAMPO) $ "PZ6_PERCF5#PZ6_METAF5#PZ6_PBONF5" .And. M->PZ5_NFAIXA >= '5') )

				nUsado := nUsado + 1

				aadd(aHeader,{ trim(SX3->X3_TITULO),SX3->X3_CAMPO   , ;
				SX3->X3_PICTURE     ,SX3->X3_TAMANHO , ;
				SX3->X3_DECIMAL     ,SX3->X3_VALID , ;
				SX3->X3_USADO       ,SX3->X3_TIPO    , ;
				SX3->X3_ARQUIVO     ,SX3->X3_CONTEXT } )
			EndIf
		End
		dbSkip()
	End

	//Monta aCols
	If  lIncluir
		aCols             := {array(nUsado+1)}
		aCols[1,nUsado+1] := .F.
		For i := 1 to nUsado
			aCols[1,i] := CriaVar(aHeader[i,2])
		Next
	Else
		aCols:={}
		DbSelectArea("PZ6")
		DbSetOrder(1)
		DbSeek(xFilial("PZ6")+M->PZ5_CODIGO)
		While !eof() .and. PZ6->(PZ6_FILIAL+PZ6_CODIGO) == (xFilial("PZ6")+M->PZ5_CODIGO)

			aadd(aCols,array(nUsado+1))
			For i := 1 to nUsado
				aCols[len(aCols),i]    := FieldGet(FieldPos(aHeader[i,2]))
			Next
			aCols[len(aCols),nUsado+1] := .F.      

			//Totais no Rodape customizado
			nGetTotBR += PZ6->PZ6_BASREA
			nGetTotBA += PZ6->PZ6_BASAJU


			dbSkip()
		End
	End

	//Inicializa variaveis
	cTitulo        := "Cadastro de Metas de Acordo de Objetivos"
	cAliasEnchoice := "PZ5"
	cAliasGetD     := "PZ6"
	cLinOk         := "U_AOMETLOK()"
	cTudOk         := "U_AOMET_OK()"
	cFieldOk       := "AllwaysTrue()"
	aCpoEnchoice   := {}
	aAltEnchoice   := Nil

	//Executa funcao modelo 3

	//Parametros da funcao modelo 3
	//lRet = Retorno .T. Confirma / .F. Abandona
	//cTitulo = Titulo da Janela
	//cAlias1 = Alias da Enchoice
	//cAlias2 = Alias da GetDados
	//aMyEncho = Array com campos da Enchoice
	//cLinOk = LinOk
	//cTudOk = TudOk
	//nOpcE = nOpc da Enchoice
	//nOpcG = nOpc da GetDados
	//cFieldOk = validacao para todos os campos da GetDados
	//lVirtual = Permite visualizar campos virtuais na enchoice
	//nLinhas = Numero Maximo de linhas na getdados
	//aAltEnchoice= Array com campos da Enchoice Alteraveis
	//nFreeze = Congelamento das colunas
	//aButtons = array com botões de usuário na enchoicebar
	//aCordW = coordenadas da janela
	//nSizeHeader = altura da enchoice

	aButtons := {}

	If lIncluir .Or. lAlterar

		aAdd(aButtons , {'',{|| ProcBases() },'Atualiza Bases'} )
		aAdd(aButtons , {'',{|| ProcMetas() },'Atualiza Metas'} )
		aAdd(aButtons , {'',{|| ProcReal() 	},'Processar'} ) 

	ElseIf wOpcao == "T"

		aAdd(aButtons , {'',{|| ProcReal() 	},'Processar'} ) 

		//Fernando/Facile em 05/04/2016 - OS 1193-16 - salvar o email do cliente se houve alteracao no modo atualizacao de realizado
		nOpcE := 4
		aAltEnchoice := {"PZ5_EMAILC","PZ5_PROVER","PZ5_FREDVB","PZ5_PACOTE","PZ5_PCTVER","PZ5_PPGSUG","PZ5_PPGMAX","PZ5_CLFABR","PZ5_CLDIST"}

	EndIf

	lRet := RMod3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,3,aButtons,,250)

	If lVisualizar

		//Fernando/Facile em 05/04/2016 - OS 1193-16 - salvar o email do cliente se houve alteracao no modo atualizacao de realizado
		If lret .And. ( wOpcao == "T" )

			If lRet .And. M->PZ5_PROVER == "S" .And. ( M->PZ5_FREDVB <= 0 .Or. Empty(M->PZ5_CLFABR) .Or. Empty(M->PZ5_CLDIST) )

				MsgAlert("Para acordos com 'Provisiona = Sim', é obrigatório informar os campos 'F.Red.Ver(%)','CLVL.Fabrica' e 'CLVL.LM'.","ATENÇÃO!")
				Return

			EndIf

			RecLock("PZ5",.F.)
			PZ5->PZ5_EMAILC := M->PZ5_EMAILC
			PZ5->PZ5_PROVER := M->PZ5_PROVER
			PZ5->PZ5_FREDVB := M->PZ5_FREDVB
			PZ5->PZ5_PACOTE := M->PZ5_PACOTE
			PZ5->PZ5_PCTVER := M->PZ5_PCTVER
			PZ5->PZ5_PPGSUG := M->PZ5_PPGSUG
			PZ5->PZ5_PPGMAX := M->PZ5_PPGMAX
			PZ5->PZ5_CLFABR := M->PZ5_CLFABR
			PZ5->PZ5_CLDIST := M->PZ5_CLDIST

			PZ5->(MsUnlock())

		EndIf

		//Se está em modo aprovacao
		If lRet .And. lAprova

			AtuTotais(.F.)

			If (_nTotBasAju < _nTotBasRea)
				MsgAlert("Total de Bases Ajustadas está menor que o total de Bases Reais.","ATENÇÃO!")
			EndIf

			If MsgNoYes("Tem certeza de deseja APROVAR este acordo?","ACORDO DE OBJETIVOS")

				RecLock("PZ5",.F.)
				PZ5->PZ5_STATUS := "S"
				PZ5->(MsUnlock())

			EndIf

		EndIf

		Return

	EndIf

	If  lRet
		fProcessa()
		ConfirmSX8()
	Else
		RollBackSX8()
	End

Return               

//Valida Tudo Ok da Tela
User Function AOMET_OK
	Local lRet := .T.   

	If lRet .And. M->PZ5_PROVER == "S" .And. ( M->PZ5_FREDVB <= 0 .Or. Empty(M->PZ5_CLFABR) .Or. Empty(M->PZ5_CLDIST) )

		MsgAlert("Para acordos com 'Provisiona = Sim', é obrigatório informar os campos 'F.Red.Ver(%)','CLVL.Fabrica' e 'CLVL.LM'.","ATENÇÃO!")
		Return(.F.)

	EndIf

	AtuTotais()

	//Total das Bases Ajustadas nao pode ser menor que a Real
	If lRet                 

		If (_nTotBasAju < _nTotBasRea)  
			//MsgInfo("Total de Bases Ajustadas não pode ser menor que o total de Bases Reais.","ATENÇÃO!")
			MsgAlert("Total de Bases Ajustadas está menor que o total de Bases Reais.","ATENÇÃO!")
			lRet := .T.  //Solcitado Claudeir - OS 1103-16 - para permitir incluir assim mesmo
		EndIf

	EndIf

Return(lRet)    

User Function AOMETLOK()
	Local lRet := .T.

	AtuTotais()

Return(lRet)

Static Function AtuTotais(_lRefresh)
	Local I                   
	Default _lRefresh := .T.

	_nTotBasRea := 0
	_nTotBasAju := 0
	__nPBasRea	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BASREA" })
	__nPBasAju	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BASAJU" })

	FOR I := 1 To Len(ACOLS)

		If ACOLS[I][Len(AHEADER)+1]
			loop
		EndIf

		_nTotBasRea += ACOLS[I][__nPBasRea]
		_nTotBasAju += ACOLS[I][__nPBasAju]

	NEXT I

	If (_lRefresh)    
		nGetTotBR := _nTotBasRea
		oGetTotBR:Refresh()
		nGetTotBA := _nTotBasAju
		oGetTotBA:Refresh()  
		oDlg:Refresh() 
	EndIf

Return

//Executa processamento
Static Function fProcessa(_lReal)
	Local I,J

	Default _lReal := .F.

	If lExcluir

		PZ6->(DbSetOrder(1))
		If PZ6->(DbSeek(XFilial("PZ6")+M->PZ5_CODIGO))

			While !PZ6->(Eof()) .And. PZ6->(PZ6_FILIAL+PZ6_CODIGO) == (xFilial("PZ6")+M->PZ5_CODIGO)

				RecLock("PZ6",.F.)
				PZ6->(DbDelete())
				PZ6->(MsUnlock())

				PZ6->(DbSkip())
			EndDo

		EndIf

		PZ5->(DbSetOrder(1))
		If PZ5->(DbSeek(XFilial("PZ5")+M->PZ5_CODIGO))

			RecLock("PZ5",.F.)
			PZ5->(DbDelete())
			PZ5->(MsUnlock())

		EndIf

		Return
	EndIf


	If lIncluir

		__cPZ5Num := M->PZ5_CODIGO

		PZ5->(dbSetOrder(1))
		While PZ5->(DbSeek(xFilial("SC5")+__cPZ5Num))
			__cPZ5Num := Soma1(__cPZ5Num,Len(__cPZ5Num))		
		EndDo

		RecLock("PZ5",.T.)
		PZ5->PZ5_CODIGO := __cPZ5Num
		PZ5->PZ5_STATUS := "N"

	Else

		//Apaga tudo para incluir denovo
		PZ6->(DbSetOrder(1))
		If PZ6->(DbSeek(XFilial("PZ6")+M->PZ5_CODIGO))

			While !PZ6->(Eof()) .And. PZ6->(PZ6_FILIAL+PZ6_CODIGO) == (xFilial("PZ6")+M->PZ5_CODIGO)

				RecLock("PZ6",.F.)
				PZ6->(DbDelete())
				PZ6->(MsUnlock())

				PZ6->(DbSkip())
			EndDo

		EndIf

		RecLock("PZ5",.F.)  

		If !_lReal
			PZ5->PZ5_STATUS := "A"
		EndIf
	EndIf

	PZ5->PZ5_TIPCLI	:= M->PZ5_TIPCLI

	If M->PZ5_TIPCLI == "1"
		PZ5->PZ5_CODCLI := M->PZ5_CODCLI
		PZ5->PZ5_LOJCLI := M->PZ5_LOJCLI
		PZ5->PZ5_CODGRP := ""
		If PZ5->(FieldPos("PZ5_REDE")) > 0
			PZ5->PZ5_REDE	:= ""
		EndIf
	ElseIf M->PZ5_TIPCLI == "2"
		PZ5->PZ5_CODCLI := ""
		PZ5->PZ5_LOJCLI := ""
		PZ5->PZ5_CODGRP := M->PZ5_CODGRP
		If PZ5->(FieldPos("PZ5_REDE")) > 0
			PZ5->PZ5_REDE	:= ""
		EndIf
	Else
		PZ5->PZ5_CODCLI := ""
		PZ5->PZ5_LOJCLI := ""
		PZ5->PZ5_CODGRP := ""
		If PZ5->(FieldPos("PZ5_REDE")) > 0
			PZ5->PZ5_REDE	:= M->PZ5_REDE
		EndIf
	EndIf

	PZ5->PZ5_ANO 	:= M->PZ5_ANO
	PZ5->PZ5_SEQ 	:= M->PZ5_SEQ
	PZ5->PZ5_CODVEN := M->PZ5_CODVEN
	PZ5->PZ5_TIPACO := M->PZ5_TIPACO
	PZ5->PZ5_TIPPAG	:= M->PZ5_TIPPAG
	PZ5->PZ5_TIPCAL	:= M->PZ5_TIPCAL
	PZ5->PZ5_NFAIXA	:= M->PZ5_NFAIXA
	PZ5->PZ5_TIPFIL := M->PZ5_TIPFIL
	PZ5->PZ5_USER	:= cUserName
	PZ5->PZ5_DATA	:= dDataBase
	PZ5->PZ5_HORA	:= SubStr(Time(),1,5) 
	PZ5->PZ5_MARCA  := M->PZ5_MARCA
	PZ5->PZ5_PROVER	:= M->PZ5_PROVER
	PZ5->PZ5_FREDVB	:= M->PZ5_FREDVB
	PZ5->PZ5_PACOTE	:= M->PZ5_PACOTE
	PZ5->PZ5_EMAILC := M->PZ5_EMAILC
	PZ5->PZ5_PCTVER := M->PZ5_PCTVER
	PZ5->PZ5_PPGSUG := M->PZ5_PPGSUG
	PZ5->PZ5_PPGMAX := M->PZ5_PPGMAX
	PZ5->PZ5_CLFABR := M->PZ5_CLFABR
	PZ5->PZ5_CLDIST := M->PZ5_CLDIST

	PZ5->(MsUnlock())

	FOR I := 1 To Len(ACOLS)

		If ACOLS[I][Len(AHEADER)+1]
			loop
		EndIf

		RecLock("PZ6",.T.)
		PZ6->PZ6_CODIGO := M->PZ5_CODIGO

		FOR J := 1 To Len(AHEADER)

			&("PZ6->"+AllTrim(AHEADER[J][2])) := ACOLS[I][J]

		NEXT J

		//Base ajustada definida - e sem SI gerada - Recalcular Metas
		If !Empty(PZ6->PZ6_BASAJU) .And. Empty(PZ6->PZ6_SI)

			PZ6->PZ6_METAF1 := IIF(PZ5_NFAIXA >= '1', PZ6->PZ6_BASAJU * (1 + PZ6->PZ6_PERCF1/100), 0)
			PZ6->PZ6_METAF2 := IIF(PZ5_NFAIXA >= '2', PZ6->PZ6_BASAJU * (1 + PZ6->PZ6_PERCF2/100), 0)
			PZ6->PZ6_METAF3 := IIF(PZ5_NFAIXA >= '3', PZ6->PZ6_BASAJU * (1 + PZ6->PZ6_PERCF3/100), 0)
			PZ6->PZ6_METAF4 := IIF(PZ5_NFAIXA >= '4', PZ6->PZ6_BASAJU * (1 + PZ6->PZ6_PERCF4/100), 0)
			PZ6->PZ6_METAF5 := IIF(PZ5_NFAIXA >= '5', PZ6->PZ6_BASAJU * (1 + PZ6->PZ6_PERCF5/100), 0)

		EndIf

		PZ6->(MsUnlock())

	NEXT I

Return

//Validacoes para campos para calculo automatico de Metas
User Function AOMETAVL

	Local nPBasAju	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BASAJU" })
	Local nPSI		:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_SI" })
	Local nMetaF1	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF1" })
	Local nMetaF2	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF2" })
	Local nMetaF3	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF3" })
	Local nMetaF4	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF4" })
	Local nMetaF5	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF5" })

	//Base ajustada definida - e sem SI gerada
	If (!Empty(aCols[N][nPBasAju])) .And. (Empty(aCols[N][nPSI]))

		If (nMetaF1 > 0) .And. AllTrim(ReadVar()) == "M->PZ6_PERCF1"
			aCols[N][nMetaF1] := aCols[N][nPBasAju] * (1 + M->PZ6_PERCF1/100)
		EndIf

		If (nMetaF2 > 0) .And. AllTrim(ReadVar()) == "M->PZ6_PERCF2"
			aCols[N][nMetaF2] := aCols[N][nPBasAju] * (1 + M->PZ6_PERCF2/100)
		EndIf

		If (nMetaF3 > 0) .And. AllTrim(ReadVar()) == "M->PZ6_PERCF3"
			aCols[N][nMetaF3] := aCols[N][nPBasAju] * (1 + M->PZ6_PERCF3/100)
		EndIf

		If (nMetaF4 > 0) .And. AllTrim(ReadVar()) == "M->PZ6_PERCF4"
			aCols[N][nMetaF4] := aCols[N][nPBasAju] * (1 + M->PZ6_PERCF4/100)
		EndIf

		If (nMetaF5 > 0) .And. AllTrim(ReadVar()) == "M->PZ6_PERCF5"
			aCols[N][nMetaF5] := aCols[N][nPBasAju] * (1 + M->PZ6_PERCF5/100)
		EndIf

	EndIf


Return(.T.)

//Atualiza Metas e verificar bonus e gera SI
Static Function ProcBases()

	//VERIFICAR PERIODOS, SEM SI GERADA E ATUALIZAR A BASE REAL.
	U_BIAMsgRun("Aguarde... Atualizando Bases Ano Anterior",,{|| ProcM1() })

	GETDREFRESH()
	AtuTotais()

Return

Static Function ProcMetas()

	//ATUALIZAR METAS DE ACORDO COM AS FAIXAS
	U_BIAMsgRun("Aguarde... Atualizando Metas conforme faixas de crescimento",,{|| ProcM2() })

	GETDREFRESH()

Return

Static Function ProcReal()
	local nx := 0

	//ATUALIZAR FATURAMENTO REALIZADO
	U_BIAMsgRun("Aguarde... Atualizando Resultado Realizado",,{|| ProcM3() })
	U_BIAMsgRun("Aguarde... Processando Bônus Recebidos",,{|| ProcM4() })
	U_BIAMsgRun("Aguarde... Gerando Solicitacoes de Investimento",,{|| ProcM5() })

	//Gravando o Acordo
	fProcessa(.T.)

	GETDREFRESH()

	// enviando workflow AI x Lançamentos
	if !empty(aTempSI)
		for nx:=1 to len(aTempSI)
			if !empty(aTempSI[nx,2])
				Processa( {|| fProcWFSI(DTOS(aTempSI[nx,4]),DTOS(aTempSI[nx,4]),aTempSI[nx,1],aTempSI[nx,2],'2') },"WF AI-"+aTempSI[nx,2]+" x Lançamentos - Aguarde...","Carregando e-mail...",.F.)
			endif
		next nx
	endif

	aTempSI	:= {}

Return

//ATUALIZAR BASES DO ANO ANTERIOR
Static Function ProcM1()
	Local I
	Local nPDtIni	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERINI" })
	Local nPDtFim	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERFIM" })
	Local nPBasRea	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BASREA" })
	Local nPBasAju	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BASAJU" })
	Local nPSI		:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_SI" })
	Local cDIniAnt, cDFimAnt
	Local cTipCli, cCodCli, cLojCli
	Local cSQL

	If !MsgNoYes("Deseja atualizar os valores das BASES agora?")
		Return
	EndIf

	FOR I := 1 To Len(ACols)

		//Periodo definido - e sem SI gerada
		If (!Empty(aCols[I][nPDtFim]) .And. !Empty(aCols[I][nPDtIni])) .And. (Empty(aCols[I][nPSI]))

			//Datas equivalentes no ano anterior
			cDIniAnt := StrZero(Year(aCols[I][nPDtIni])-1,4)+ SubStr(Dtos(aCols[I][nPDtIni]),5,4)
			cDFimAnt := StrZero(Year(aCols[I][nPDtFim])-1,4)+ SubStr(Dtos(aCols[I][nPDtFim]),5,4)

			cTipCli := M->PZ5_TIPCLI

			If cTipCli == "1"
				cCodCli := M->PZ5_CODCLI
				cLojCli := M->PZ5_LOJCLI
			ElseIf cTipCli == "2"
				cCodCli := M->PZ5_CODGRP
				cLojCli := ""
			Else
				cCodCli := M->PZ5_REDE
				cLojCli := ""
			EndIf

			If Select("TRB") > 0
				TRB->(DbCloseArea())
			EndIf

			cSQL := "select dbo.FNC_AO_RECEITA('"+M->PZ5_MARCA+"','"+cTipCli+"','"+cCodCli+"','"+cLojCli+"','"+cDIniAnt+"','"+cDFimAnt+"','"+M->PZ5_TIPCAL+"','"+M->PZ5_TIPFIL+"','"+AllTrim(M->PZ5_PACOTE)+"')"
			TCQuery cSQL Alias "TRB" New

			TRB->(DbGoTop())

			If !TRB->(Eof())
				aCols[I][nPBasRea] := &(TRB->(Field(1)))
			Else
				aCols[I][nPBasRea] := 0
			EndIf

			aCols[I][nPBasAju] := aCols[I][nPBasRea]

		EndIf

	NEXT I

Return

//CALCULAR METAS
Static Function ProcM2(nLin)
	Local I
	Local nPBasAju	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BASAJU" })
	Local nPSI		:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_SI" })

	Local nPF1		:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERCF1" })
	Local nPF2		:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERCF2" })
	Local nPF3		:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERCF3" })
	Local nPF4		:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERCF4" })
	Local nPF5		:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERCF5" })

	Local nMetaF1	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF1" })
	Local nMetaF2	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF2" })
	Local nMetaF3	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF3" })
	Local nMetaF4	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF4" })
	Local nMetaF5	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF5" })

	Local cDIniAnt, cDFimAnt
	Local cTipCli, cCodCli, cLojCli
	Local cSQL

	Default nLin := 0

	FOR I := 1 To Len(ACols)

		If nLin > 0 .And. I <> nLin
			loop
		EndIf

		//Base ajustada definida - e sem SI gerada
		If (!Empty(aCols[I][nPBasAju])) .And. (Empty(aCols[I][nPSI]))

			If (nPF1 > 0) .And. !Empty(aCols[I][nPF1])
				aCols[I][nMetaF1] := aCols[I][nPBasAju] * (1 + aCols[I][nPF1]/100)
			EndIf

			If (nPF2 > 0) .And. !Empty(aCols[I][nPF2])
				aCols[I][nMetaF2] := aCols[I][nPBasAju] * (1 + aCols[I][nPF2]/100)
			EndIf

			If (nPF3 > 0) .And. !Empty(aCols[I][nPF3])
				aCols[I][nMetaF3] := aCols[I][nPBasAju] * (1 + aCols[I][nPF3]/100)
			EndIf

			If (nPF4 > 0) .And. !Empty(aCols[I][nPF4])
				aCols[I][nMetaF4] := aCols[I][nPBasAju] * (1 + aCols[I][nPF4]/100)
			EndIf

			If (nPF5 > 0) .And. !Empty(aCols[I][nPF5])
				aCols[I][nMetaF5] := aCols[I][nPBasAju] * (1 + aCols[I][nPF5]/100)
			EndIf

		EndIf

	NEXT I

Return

//ATUALIZAR REALIZADO
Static Function ProcM3()
	Local I
	Local nPDtIni	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERINI" })
	Local nPDtFim	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERFIM" })
	Local nPValRea	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_VALREA" })
	Local nPBasVer	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BASVER" })
	Local nPBVLRea	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BVLREA" })
	Local nPSI		:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_SI" })
	Local nPDTUlt	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_DTULRE" })
	Local cDIniAnt, cDFimAnt
	Local cTipCli, cCodCli, cLojCli
	Local cSQL

	If !MsgNoYes("Deseja atualizar os valores realizados agora?")
		Return
	EndIf

	FOR I := 1 To Len(ACols)

		//Periodo definido - e sem SI gerada
		If (!Empty(aCols[I][nPDtFim]) .And. !Empty(aCols[I][nPDtIni])) .And. (Empty(aCols[I][nPSI]))

			//Datas equivalentes no ano anterior
			cDIniAnt := DTOS(aCols[I][nPDtIni])
			cDFimAnt := DTOS(aCols[I][nPDtFim])

			cTipCli := M->PZ5_TIPCLI

			If cTipCli == "1"
				cCodCli := M->PZ5_CODCLI
				cLojCli := M->PZ5_LOJCLI
			ElseIf cTipCli == "2"
				cCodCli := M->PZ5_CODGRP
				cLojCli := ""
			Else
				cCodCli := M->PZ5_REDE
				cLojCli := ""
			EndIf

			If Select("TRB") > 0
				TRB->(DbCloseArea())
			EndIf

			cSQL := "select dbo.FNC_AO_RECEITA('"+M->PZ5_MARCA+"','"+cTipCli+"','"+cCodCli+"','"+cLojCli+"','"+cDIniAnt+"','"+cDFimAnt+"','"+M->PZ5_TIPCAL+"','"+M->PZ5_TIPFIL+"','"+AllTrim(M->PZ5_PACOTE)+"')"

			If Select("TRB") > 0
				TRB->(DbCloseArea())
			EndIf

			TCQuery cSQL Alias "TRB" New

			TRB->(DbGoTop())

			If !TRB->(Eof())
				aCols[I][nPValRea] := &(TRB->(Field(1)))
				aCols[I][nPDTUlt] := dDataBase
			Else
				aCols[I][nPValRea] := 0
			EndIf
			TRB->(DbCloseArea())

			//OS 1337-16 : Filtro dos pacotes para calculo da base da verba com pacotes diferenciados - solicitacao Incesa
			If PZ6->(FieldPos("PZ6_BASVER")) > 0 .And. PZ5->(FieldPos("PZ5_PCTVER")) > 0 .And. !Empty(M->PZ5_PCTVER)

				cSQL := "select dbo.FNC_AO_RECEITA('"+M->PZ5_MARCA+"','"+cTipCli+"','"+cCodCli+"','"+cLojCli+"','"+cDIniAnt+"','"+cDFimAnt+"','"+M->PZ5_TIPCAL+"','"+M->PZ5_TIPFIL+"','"+AllTrim(M->PZ5_PCTVER)+"')"

				If Select("TRB") > 0
					TRB->(DbCloseArea())
				EndIf

				TCQuery cSQL Alias "TRB" New

				TRB->(DbGoTop())

				If !TRB->(Eof())
					aCols[I][nPBasVer] := &(TRB->(Field(1)))				
				Else
					aCols[I][nPBasVer] := 0
				EndIf
				TRB->(DbCloseArea())

			EndIf

			//OS 3527-16 : armazenar valor da base real sempre em R$ para acordos do tipo Volume - para calcular o bonus que tem que ser em R$
			If PZ6->(FieldPos("PZ6_BASVER")) > 0 .And. PZ5->(FieldPos("PZ5_PCTVER")) > 0 .And. !Empty(M->PZ5_PCTVER)

				cSQL := "select dbo.FNC_AO_RECEITA('"+M->PZ5_MARCA+"','"+cTipCli+"','"+cCodCli+"','"+cLojCli+"','"+cDIniAnt+"','"+cDFimAnt+"','R','"+M->PZ5_TIPFIL+"','"+AllTrim(M->PZ5_PCTVER)+"')"

			Else

				cSQL := "select dbo.FNC_AO_RECEITA('"+M->PZ5_MARCA+"','"+cTipCli+"','"+cCodCli+"','"+cLojCli+"','"+cDIniAnt+"','"+cDFimAnt+"','R','"+M->PZ5_TIPFIL+"','"+AllTrim(M->PZ5_PACOTE)+"')"

			EndIf

			If Select("TRB") > 0
				TRB->(DbCloseArea())
			EndIf

			TCQuery cSQL Alias "TRB" New

			TRB->(DbGoTop())

			If !TRB->(Eof())
				aCols[I][nPBVLRea] := &(TRB->(Field(1)))				
			Else
				aCols[I][nPBVLRea] := 0
			EndIf
			TRB->(DbCloseArea())
			//Fim bloco OS 3527-16



		EndIf

	NEXT I

Return


//ATUALIZAR BONUS RECEBIDOS
Static Function ProcM4()
	Local I
	Local nPDtIni	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERINI" })
	Local nPDtFim	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERFIM" })
	Local nPValRea	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_VALREA" })
	Local nPBasVer	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BASVER" })
	Local nPBVLRea	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BVLREA" })
	Local nPSI		:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_SI" })

	Local nPMetaF1	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF1" })
	Local nPMetaF2	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF2" })
	Local nPMetaF3	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF3" })
	Local nPMetaF4	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF4" })
	Local nPMetaF5	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_METAF5" })

	Local nPBonF1	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PBONF1" })
	Local nPBonF2	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PBONF2" })
	Local nPBonF3	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PBONF3" })
	Local nPBonF4	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PBONF4" })
	Local nPBonF5	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PBONF5" })

	Local nPBonus	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BONUS" })

	Local cDIniAnt, cDFimAnt
	Local cTipCli, cCodCli, cLojCli
	Local cSQL

	Local _nValRea := 0
	Local _nVBasVer := 0

	Local _nMeta1 := 0
	Local _nMeta2 := 0
	Local _nMeta3 := 0
	Local _nMeta4 := 0
	Local _nMeta5 := 0

	Local _nPBonus1 := 0
	Local _nPBonus2 := 0
	Local _nPBonus3 := 0
	Local _nPBonus4 := 0
	Local _nPBonus5 := 0

	FOR I := 1 To Len(ACols)

		//Periodo definido - Encerrado - e sem SI gerada
		If (!Empty(aCols[I][nPDtFim]) .And. !Empty(aCols[I][nPDtIni])) .And. (aCols[I][nPDtFim] < dDataBase) .And. (Empty(aCols[I][nPSI]))

			_nValRea := aCols[I][nPValRea]

			//OS 1337-16 : Filtro dos pacotes para calculo da base da verba com pacotes diferenciados - solicitacao Incesa
			If PZ5->(FieldPos("PZ5_PCTVER")) > 0 .And. !Empty(M->PZ5_PCTVER)
				_nVBasVer := aCols[I][nPBasVer]		
			EndIf

			//OS 3527-16 : Se calculou a base em R$ usar ela
			If ( aCols[I][nPBVLRea] > 0 )
				_nVBasVer := aCols[I][nPBVLRea] 
			EndIf

			If nPMetaF1 > 0
				_nMeta1		:= aCols[I][nPMetaF1]
				_nPBonus1	:= aCols[I][nPBonF1]
			EndIf

			If nPMetaF2 > 0
				_nMeta2		:= aCols[I][nPMetaF2]
				_nPBonus2	:= aCols[I][nPBonF2]
			EndIf

			If nPMetaF3 > 0
				_nMeta3		:= aCols[I][nPMetaF3]
				_nPBonus3	:= aCols[I][nPBonF3]
			EndIf

			If nPMetaF4 > 0
				_nMeta4		:= aCols[I][nPMetaF4]
				_nPBonus4	:= aCols[I][nPBonF4]
			EndIf

			If nPMetaF5 > 0
				_nMeta5		:= aCols[I][nPMetaF5]
				_nPBonus5	:= aCols[I][nPBonF5]
			EndIf

			//Bonus na Faixa 1
			If (_nMeta1 > 0 .And. _nValRea >= _nMeta1 .And. (nPMetaF2 <= 0 .Or. _nValRea < _nMeta2))

				aCols[I][nPBonus] := (IIf(_nVBasVer > 0, _nVBasVer, _nValRea) * _nPBonus1) / 100

			EndIf

			//Bonus na Faixa 2
			If (_nMeta2 > 0 .And. _nValRea >= _nMeta2 .And. (nPMetaF3 <= 0 .Or. _nValRea < _nMeta3))

				aCols[I][nPBonus] := (IIf(_nVBasVer > 0, _nVBasVer, _nValRea) * _nPBonus2) / 100

			EndIf

			//Bonus na Faixa 3
			If (_nMeta3 > 0 .And. _nValRea >= _nMeta3 .And. (nPMetaF4 <= 0 .Or. _nValRea < _nMeta4))

				aCols[I][nPBonus] := (IIf(_nVBasVer > 0, _nVBasVer, _nValRea) * _nPBonus3) / 100

			EndIf

			//Bonus na Faixa 4
			If (_nMeta4 > 0 .And. _nValRea >= _nMeta4 .And. (nPMetaF5 <= 0 .Or. _nValRea < _nMeta5))

				aCols[I][nPBonus] := (IIf(_nVBasVer > 0, _nVBasVer, _nValRea) * _nPBonus4) / 100

			EndIf

			//Bonus na Faixa 5
			If (_nMeta5 > 0 .And. _nValRea >= _nMeta5)

				aCols[I][nPBonus] := (IIf(_nVBasVer > 0, _nVBasVer, _nValRea) * _nPBonus5) / 100

			EndIf

		EndIf

	NEXT I

Return

//GERAR SOLICITACA DE INVESTIMENTO
Static Function ProcM5()
	Local I
	Local nPIdPer	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_IDPER" })
	Local nPDtIni	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERINI" })
	Local nPDtFim	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_PERFIM" })
	Local nPValRea	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_VALREA" })
	Local nPSI		:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_SI" })
	Local nPBonus	:= aScan(aHeader, {|x| AllTrim(x[2]) == "PZ6_BONUS" })
	Local cDIniAnt, cDFimAnt
	Local cTipCli, cCodCli, cLojCli
	Local cSQL
	Local cNumSI

	If (PZ5->PZ5_STATUS <> "S")
		MsgAlert("Acordo NÃO está Aprovado. Não é possível Gerar as SI.","ATENÇÃO")
		Return
	EndIf

	If !MsgNoYes("Deseja gerar as Solicitações de Investimento agora?")
		Return
	EndIf

	FOR I := 1 To Len(ACols)

		//Bonus Processado e SI não gerada
		If !Empty(aCols[I][nPBonus]) .And. Empty(aCols[I][nPSI])

			cNumSI := GerarSI(aCols[I][nPBonus],aCols[I][nPDtIni],aCols[I][nPDtFim],aCols[I][nPIdPer])
			aCols[I][nPSI] := cNumSI

			if !Empty(cNumSI)
				AADD(aTempSI,{M->PZ5_CODIGO,cNumSI,aCols[I,nPDtIni],aCols[I,nPDtFim]})
			endif

		EndIf

	NEXT I

Return


Static Function GerarSI(_nValor,_dIni,_dFim,_cIdPer,_lAuto)
	Local MACODIGO
	Local cCodCli := ""
	Local cLojCli := ""

	Default _lAuto := .F.

	//BUSCANDO O MAIOR CODIGO DA TABELA
	CSQL := "SELECT ISNULL(MAX(ZO_YCOD),0) AS MAX_COD FROM "+RETSQLNAME("SZO")+" "
	If chkfile("_MAX")
		dbSelectArea("_MAX")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "_MAX" NEW
	MACODIGO := SOMA1(_MAX->MAX_COD,6)

	//Buscando codigo do cliente - se for grupo usa o maior faturamento
	IF AllTrim(PZ5->PZ5_TIPCLI) $ "2_3"

		If Select("TRB") > 0
			TRB->(DbCloseArea())
		EndIf 

		If PZ5->(FieldPos("PZ5_REDE")) > 0
			cSQL := "select dbo.FNC_AO_TOP_CLI('"+PZ5->PZ5_MARCA+"','"+IIF(PZ5->PZ5_TIPCLI=="2", PZ5->PZ5_CODGRP, PZ5->PZ5_REDE)+"','"+DTOS(_dIni)+"','"+DTOS(_dFim)+"','"+PZ5->PZ5_TIPCLI+"')"
		Else		
			cSQL := "select dbo.FNC_AO_TOP_CLI('"+PZ5->PZ5_MARCA+"','"+PZ5->PZ5_CODGRP+"','"+DTOS(_dIni)+"','"+DTOS(_dFim)+"')"
		EndIf

		PZ5->PZ5_TIPCLI

		TCQuery cSQL Alias "TRB" New

		TRB->(DbGoTop())		
		If !TRB->(Eof())
			cCodCli := SubStr(&("TRB->"+TRB->(Field(1))),1,6)
			cLojCli := SubStr(&("TRB->"+TRB->(Field(1))),7,2)
		EndIf 

		TRB->(DbCloseArea())

	ELSE 

		cCodCli := PZ5->PZ5_CODCLI
		cLojCli := PZ5->PZ5_LOJCLI

	ENDIF


	RecLock("SZO",.T.)
	SZO->ZO_FILIAL		:= XFILIAL("SZO")
	SZO->ZO_YCOD		:= MACODIGO
	SZO->ZO_SI  		:= MACODIGO
	SZO->ZO_DATA		:= DATE()
	SZO->ZO_CLIENTE		:= cCodCli
	SZO->ZO_LOJA		:= cLojCli
	SZO->ZO_REPRE		:= PZ5->PZ5_CODVEN
	SZO->ZO_VALOR		:= _nValor

	SZO->ZO_ITEMCTA 	:= "I0201"

	//OS 2788-16 - gerar as AI de acordo ja aprovadas
	SZO->ZO_STATUS		:= "Aprovado"
	SZO->ZO_DATAPRO		:= dDataBase
	SZO->ZO_HORAAPR		:= TIME()
	SZO->ZO_USUAPRO		:= cUserName

	SZO->ZO_DESCR		:= "Bonus do Acordo: "+PZ5->PZ5_CODIGO
	SZO->ZO_YOBS		:= "Gerada Automaticamente - Bônus do Acordo de Objetivos: "+PZ5->PZ5_CODIGO+" - Período: "+AllTrim(_cIdPer)

	SZO->ZO_EMP	:= PZ5->PZ5_MARCA

	DO CASE
		CASE SubString(PZ5->PZ5_MARCA,1,4) == "0101"
		SZO->ZO_EMP			:= "0101"
		SZO->ZO_SERIE   	:= 'S1'
		CASE SubString(PZ5->PZ5_MARCA,1,4) == "0199"
		SZO->ZO_EMP			:= "0199"
		SZO->ZO_SERIE   	:= 'S1'
		CASE SubString(PZ5->PZ5_MARCA,1,4) == "0501"
		SZO->ZO_EMP			:= "0501"
		SZO->ZO_SERIE   	:= 'S2'
		CASE SubString(PZ5->PZ5_MARCA,1,4) == "0599"
		SZO->ZO_EMP			:= "0599"
		SZO->ZO_SERIE   	:= 'S2'
		OTHERWISE
		SZO->ZO_EMP			:= "0101"
		SZO->ZO_SERIE   	:= 'S1'
	ENDCASE

	SZO->(MsUnLock())

	If !_lAuto
		MsgInfo("A SOLICITAÇÃO DE INVESTIMENTO DE NÚMERO: "+ALLTRIM(MACODIGO)+" FOI INCLUSA COM SUCESSO!","Solicitação de Investimento")
	EndIf

Return(MACODIGO)


/*/{Protheus.doc} AO_METAS
@description FUNCAO PARA RETORNAR O EXTRATO ATUALIZADO DO ACORDO - USAR NO RELATORIO E WORKFLOW
@author Fernando Rocha
@since 17/06/2014
@version undefined
@type function
/*/
User Function AO_EXTRATO(_cCodigo,_cAlias)
	Local _cExpRep

	//Processar e Atualizar os valores realizados do PZ6
	U_BIAMsgRun("Aguarde... Atualizando Resultado Realizado",,{|| U_AO_UPREA(_cCodigo) })

	//Representante
	If !Empty(CREPATU)
		_cExpRep := "% PZ5_CODVEN = '"+CREPATU+"' %"
	Else                                            
		_cExpRep := "% 1 = 1 %"
	EndIf

	//Relatorio - Retorno de Dados
	If PZ5->(FieldPos("PZ5_REDE")) > 0

		BeginSql Alias _cAlias
			%NOPARSER%

			SELECT
			PERIODO = PZ6_IDPER,
			STATUS = CASE WHEN PZ6_PERFIM < (convert(varchar(8),GetDate(),112)) THEN 'ENCERRADO'
			WHEN PZ6_PERINI <= (convert(varchar(8),GetDate(),112)) AND PZ6_PERFIM >= (convert(varchar(8),GetDate(),112)) THEN 'EM ANDAMENTO'
			ELSE 'NAO INICIADO'	END,
			NOME_CLI = 	CASE WHEN PZ5_TIPCLI = '1' THEN (SELECT TOP 1 A1_NOME FROM SA1010 WHERE A1_COD+A1_LOJA = PZ5_CODCLI+PZ5_LOJCLI AND D_E_L_E_T_='')
			WHEN PZ5_TIPCLI = '2' THEN (SELECT TOP 1 ACY_DESCRI FROM ACY010 WHERE ACY_GRPVEN = PZ5_CODGRP AND D_E_L_E_T_='')
			ELSE (SELECT TOP 1 Z79_DESCR FROM Z79010 WHERE Z79_REDE = PZ5_REDE AND D_E_L_E_T_='') END,
			REALIZADO = PZ6_VALREA,
			METAF1 = PZ6_METAF1,
			FALTAF1 = CASE WHEN PZ6_METAF1 <= 0 OR (PZ6_METAF1 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF1 - PZ6_VALREA) END,
			METAF2 = PZ6_METAF2,
			FALTAF2 = CASE WHEN PZ6_METAF2 <= 0 OR (PZ6_METAF2 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF2 - PZ6_VALREA) END,
			METAF3 = PZ6_METAF3,
			FALTAF3 = CASE WHEN PZ6_METAF3 <= 0 OR (PZ6_METAF3 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF3 - PZ6_VALREA) END,
			METAF4 = PZ6_METAF4,
			FALTAF4 = CASE WHEN PZ6_METAF4 <= 0 OR (PZ6_METAF4 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF4 - PZ6_VALREA) END,
			METAF5 = PZ6_METAF5,
			FALTAF5 = CASE WHEN PZ6_METAF5 <= 0 OR (PZ6_METAF5 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF5 - PZ6_VALREA) END,
			BONUS = PZ6_BONUS,     
			NUMSI = PZ6_SI

			FROM %TABLE:PZ6% PZ6 
			JOIN %TABLE:PZ5% PZ5 on PZ5_CODIGO = PZ6_CODIGO
			WHERE
			PZ6_CODIGO = %EXP:_cCodigo%
			AND %EXP:_cExpRep%
			AND PZ6.D_E_L_E_T_=''
			AND PZ5.D_E_L_E_T_=''

		EndSql

	ELSE	

		BeginSql Alias _cAlias
			%NOPARSER%

			SELECT
			PERIODO = PZ6_IDPER,
			STATUS = CASE WHEN PZ6_PERFIM < (convert(varchar(8),GetDate(),112)) THEN 'ENCERRADO'
			WHEN PZ6_PERINI <= (convert(varchar(8),GetDate(),112)) AND PZ6_PERFIM >= (convert(varchar(8),GetDate(),112)) THEN 'EM ANDAMENTO'
			ELSE 'NAO INICIADO'	END,
			NOME_CLI = CASE WHEN PZ5_TIPCLI = '1' THEN (SELECT TOP 1 A1_NOME FROM SA1010 WHERE A1_COD+A1_LOJA = PZ5_CODCLI+PZ5_LOJCLI AND D_E_L_E_T_='')
			ELSE (SELECT TOP 1 ACY_DESCRI FROM ACY010 WHERE ACY_GRPVEN = PZ5_CODGRP AND D_E_L_E_T_='') END,
			REALIZADO = PZ6_VALREA,
			METAF1 = PZ6_METAF1,
			FALTAF1 = CASE WHEN PZ6_METAF1 <= 0 OR (PZ6_METAF1 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF1 - PZ6_VALREA) END,
			METAF2 = PZ6_METAF2,
			FALTAF2 = CASE WHEN PZ6_METAF2 <= 0 OR (PZ6_METAF2 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF2 - PZ6_VALREA) END,
			METAF3 = PZ6_METAF3,
			FALTAF3 = CASE WHEN PZ6_METAF3 <= 0 OR (PZ6_METAF3 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF3 - PZ6_VALREA) END,
			METAF4 = PZ6_METAF4,
			FALTAF4 = CASE WHEN PZ6_METAF4 <= 0 OR (PZ6_METAF4 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF4 - PZ6_VALREA) END,
			METAF5 = PZ6_METAF5,
			FALTAF5 = CASE WHEN PZ6_METAF5 <= 0 OR (PZ6_METAF5 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF5 - PZ6_VALREA) END,
			BONUS = PZ6_BONUS,     
			NUMSI = PZ6_SI

			FROM %TABLE:PZ6% PZ6 
			JOIN %TABLE:PZ5% PZ5 on PZ5_CODIGO = PZ6_CODIGO
			WHERE
			PZ6_CODIGO = %EXP:_cCodigo%
			AND %EXP:_cExpRep%
			AND PZ6.D_E_L_E_T_=''
			AND PZ5.D_E_L_E_T_=''

		EndSql

	ENDIF

Return     

User Function AO_UPREA(_cCodigo)
	Local cCodCli
	Local cLojCli
	Local cSQL

	PZ6->(DbSetOrder(1))
	PZ6->(DbSeek(XFilial("PZ6")+_cCodigo))
	While !PZ6->(Eof()) .And. PZ6->(PZ6_FILIAL+PZ6_CODIGO) == (XFilial("PZ6")+_cCodigo)

		//posicionar PZ5
		PZ5->(DbSetOrder(1))
		PZ5->(DbSeek(XFilial("PZ5")+PZ6->PZ6_CODIGO))

		//Linhas que ainda nao foi gerado SI, periodo ainda nao processado e nao foi processado hoje
		If Empty(PZ6->PZ6_SI) .And. PZ6->PZ6_PERFIM >= PZ6->PZ6_DTULRE

			If Select("TRB") > 0
				TRB->(DbCloseArea())
			EndIf     

			If PZ5->PZ5_TIPCLI == "1"
				cCodCli := PZ5->PZ5_CODCLI
				cLojCli := PZ5->PZ5_LOJCLI
			ElseIf PZ5->PZ5_TIPCLI == "2"
				cCodCli := PZ5->PZ5_CODGRP
				cLojCli := ""
			Else
				cCodCli := PZ5->PZ5_REDE
				cLojCli := ""
			EndIf

			cSQL := "select dbo.FNC_AO_RECEITA('"+PZ5->PZ5_MARCA+"','"+PZ5->PZ5_TIPCLI+"','"+cCodCli+"','"+cLojCli+"','"+DTOS(PZ6->PZ6_PERINI)+"','"+DTOS(PZ6->PZ6_PERFIM)+"','"+PZ5->PZ5_TIPCAL+"','"+PZ5->PZ5_TIPFIL+"','"+AllTrim(PZ5->PZ5_PACOTE)+"')"
			TCQuery cSQL Alias "TRB" New

			TRB->(DbGoTop())

			If !TRB->(Eof())

				RecLock("PZ6",.F.)
				PZ6->PZ6_VALREA := &("TRB->"+TRB->(Field(1)))
				PZ6->PZ6_DTULRE := dDataBase
				PZ6->(MsUnlock())

			EndIf 

			TRB->(DbCloseArea())

		EndIf

		PZ6->(DbSkip())
	EndDo

Return

//FUNCAO PARA RETORNAR O EXTRATO ATUALIZADO DO ACORDO - USAR NO RELATORIO E WORKFLOW
User Function AO_EXCEL(_cCodigo)

	Local aArea := GetArea()
	Local oFWExcel := Nil
	Local oMsExcel := Nil
	Local cDir := GetSrvProfString("Startpath", "")
	Local cFile := "AO_EXCEL-" + __cUserID +"-"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
	Local cWorkSheet := ""
	Local cTable := ""
	Local cDirTmp := AllTrim(GetTempPath())
	Local cAliasTab  

	Default _cCodigo := ""

	If Empty(_cCodigo)
		Private cPerg := "AO_CODIGO"
		ValPergAco()
		If !Pergunte(cPerg)
			Return
		EndIf
		_cCodigo := MV_PAR01
	EndIf

	//posicionar PZ5
	PZ5->(DbSetOrder(1))
	If PZ5->(DbSeek(XFilial("PZ5")+_cCodigo)) .And. PZ5->PZ5_STATUS <> "S"
		MsgAlert("Acordo não está aprovado. Não é possível fazer o acompanhamento.","ACORDO DE OBJETIVOS")
		Return
	EndIf          

	//Buscando nome do cliente ou grupo
	__Nome := ""
	If PZ5->PZ5_TIPCLI == "2"     
		ACY->(DbSetOrder(1))
		ACY->(DbSeek(XFilial("ACY")+PZ5->PZ5_CODGRP))  
		__Nome := ACY->ACY_DESCRI
	Else
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(XFilial("SA1")+PZ5->PZ5_CODCLI+PZ5->PZ5_LOJCLI))
		__Nome :=  SA1->A1_NOME
	EndIf  

	If PZ5->PZ5_TIPCLI == "1"
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(XFilial("SA1")+PZ5->PZ5_CODCLI+PZ5->PZ5_LOJCLI))
		__Nome :=  SA1->A1_NOME
	ElseIf PZ5->PZ5_TIPCLI == "2"
		ACY->(DbSetOrder(1))
		ACY->(DbSeek(XFilial("ACY")+PZ5->PZ5_CODGRP))  
		__Nome := ACY->ACY_DESCRI
	Else
		ACY->(DbSetOrder(1))
		ACY->(DbSeek(XFilial("ACY")+PZ5->PZ5_CODGRP))  
		__Nome := ACY->ACY_DESCRI
	EndIf

	cWorkSheet := "Extrato Acordo de Objetivos"
	cTable := cWorkSheet + " - Acordo No: "+_cCodigo+" - Cliente: "+__Nome

	oFWExcel := FWMsExcel():New()
	oFWExcel:AddWorkSheet(cWorkSheet)
	oFWExcel:AddTable(cWorkSheet, cTable)

	oFWExcel:AddColumn(cWorkSheet, cTable, "Período", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Status", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Faturamento Realizado", 1, 3)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Meta 1a. Faixa", 1, 3)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Falta p/ 1a. Faixa", 1, 3)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Meta p/ 2a. Faixa", 1, 3)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Falta p/ 2a. Faixa", 1, 3)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Meta p/ 3a. Faixa", 1, 3)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Falta p/ 3a. Faixa", 1, 3)

	If PZ5->PZ5_NFAIXA >= '4'
		oFWExcel:AddColumn(cWorkSheet, cTable, "Meta 4a. Faixa", 1, 3)
		oFWExcel:AddColumn(cWorkSheet, cTable, "Falta p/ 4a. Faixa", 1, 3)
	EndIf

	If PZ5->PZ5_NFAIXA >= '5'
		oFWExcel:AddColumn(cWorkSheet, cTable, "Meta 5a. Faixa", 1, 3)
		oFWExcel:AddColumn(cWorkSheet, cTable, "Falta p/ 5a. Faixa", 1, 3)
	EndIf

	oFWExcel:AddColumn(cWorkSheet, cTable, "Bonus (R$)", 1, 3)   
	oFWExcel:AddColumn(cWorkSheet, cTable, "Numero SI", 1, 1)


	cAliasTab := GetNextAlias()
	U_AO_EXTRATO(_cCodigo,cAliasTab)
	(cAliasTab)->(DbGoTop())

	While (cAliasTab)->(!EOF())

		aAux := {}
		AAdd(aAux, (cAliasTab)->PERIODO)
		AAdd(aAux, (cAliasTab)->STATUS)
		AAdd(aAux, (cAliasTab)->REALIZADO)
		AAdd(aAux, (cAliasTab)->METAF1)
		AAdd(aAux, (cAliasTab)->FALTAF1)
		AAdd(aAux, (cAliasTab)->METAF2)
		AAdd(aAux, (cAliasTab)->FALTAF2)
		AAdd(aAux, (cAliasTab)->METAF3)
		AAdd(aAux, (cAliasTab)->FALTAF3)

		If PZ5->PZ5_NFAIXA >= '4'
			AAdd(aAux, (cAliasTab)->METAF4)
			AAdd(aAux, (cAliasTab)->FALTAF4)
		EndIf

		If PZ5->PZ5_NFAIXA >= '5'
			AAdd(aAux, (cAliasTab)->METAF5)
			AAdd(aAux, (cAliasTab)->FALTAF5)	
		EndIf

		AAdd(aAux, (cAliasTab)->BONUS)
		AAdd(aAux, (cAliasTab)->NUMSI)

		oFWExcel:AddRow(cWorkSheet, cTable,	aAux)

		(cAliasTab)->(DbSkip())

	EndDo

	oFWExcel:Activate()
	oFWExcel:GetXMLFile(cFile)
	oFWExcel:DeActivate()

	If CpyS2T(cDir + cFile, cDirTmp, .T.)

		fErase(cDir + cFile)

		If ApOleClient('MsExcel')

			oMSExcel := MsExcel():New()
			oMSExcel:WorkBooks:Close()
			oMSExcel:WorkBooks:Open(cDirTmp + cFile)
			oMSExcel:SetVisible(.T.)
			oMSExcel:Destroy()

		EndIf

	Else
		MsgInfo("Arquivo não copiado para a pasta temporária do usuário.")
	Endif

	(cAliasTab)->(DbCloseArea())

	RestArea(aArea)

Return() 

/*/
FUNCAO PARA RETORNAR O EXTRATO ATUALIZADO DO ACORDO - USAR NO RELATORIO E WORKFLOW
/*/
User Function AO_TREP(_cCodigo)
	Local cReport := "AO_TREP"
	Local cTitulo := "Acompanhamento de Acordo de Objetivos"
	Local cDescri := "Acompanhamento de Acordo de Objetivos"
	Local bReport := { |oReport|	oReport:SetTitle( oReport:Title()+" No.: "+_cCodigo ),	ReportPrint( oReport, _cCodigo ) }
	Local nFaixa

	Private oReport    
	Private cPerg := "AO_CODIGO"
	Private cAliasTab := GetNextAlias()
	Private oSection1 

	If Empty(_cCodigo)
		ValPergAco()
		If !Pergunte(cPerg)
			Return
		EndIf
		_cCodigo := MV_PAR01
	EndIf

	//posicionar PZ5
	PZ5->(DbSetOrder(1))
	If PZ5->(DbSeek(XFilial("PZ5")+_cCodigo)) .And. PZ5->PZ5_STATUS <> "S"
		MsgAlert("Acordo não está aprovado. Não é possível fazer o acompanhamento.","ACORDO DE OBJETIVOS")
		Return
	EndIf  

	nFaixa := Val(PZ5->PZ5_NFAIXA)        

	oReport  := TReport():New( cReport, cTitulo, cPerg , bReport, cDescri )
	oReport:SetLandScape() 

	oSection1 := TRSection():New( oReport  ,"01",cAliasTab, {} )
	TRCell():New(oSection1	,"PERIODO"	  		,,"Período"	  		   		,"@!", 20,/*lPixel*/, {|| (cAliasTab)->PERIODO } )
	TRCell():New(oSection1	,"STATUS"			,,"Status"			   		,"@!", 20,/*lPixel*/, {|| (cAliasTab)->STATUS } )
	TRCell():New(oSection1	,"REALIZADO"	  	,,"Realizado"				,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->REALIZADO  } )

	If nFaixa >= 1
		TRCell():New(oSection1	,"METAF1"	,,"Meta Faixa 1"	,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->METAF1  } )
		TRCell():New(oSection1	,"FALTAF1"	,,"Falta Faixa 1"	,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->FALTAF1  } )
	EndIf
	If nFaixa >= 2
		TRCell():New(oSection1	,"METAF2"	,,"Meta Faixa 2"	,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->METAF2  } )
		TRCell():New(oSection1	,"FALTAF2"	,,"Falta Faixa 2"	,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->FALTAF2  } )
	EndIf
	If nFaixa >= 3
		TRCell():New(oSection1	,"METAF3"	,,"Meta Faixa 3"	,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->METAF3  } )
		TRCell():New(oSection1	,"FALTAF3"	,,"Falta Faixa 3"	,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->FALTAF3  } )
	EndIf
	If nFaixa >= 4
		TRCell():New(oSection1	,"METAF4"	,,"Meta Faixa 4"	,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->METAF4  } )
		TRCell():New(oSection1	,"FALTAF4"	,,"Falta Faixa 4"	,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->FALTAF4  } )
	EndIf
	If nFaixa >= 5
		TRCell():New(oSection1	,"METAF5"	,,"Meta Faixa 5"	,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->METAF5  } )
		TRCell():New(oSection1	,"FALTAF5"	,,"Falta Faixa 5"	,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->FALTAF5  } )
	EndIf

	TRCell():New(oSection1	,"BONUS"	  		,,"Bonus (R$)"			,"@E 999,999,999.99", 15,/*lPixel*/, {|| (cAliasTab)->BONUS  } ) 
	TRCell():New(oSection1	,"NUMSI"			,,"No. SI"		   		,"@!", 10,/*lPixel*/, {|| (cAliasTab)->NUMSI } )

	oReport:lParamPage := .F.
	oReport:PrintDialog()

Return

Static Function ReportPrint( oReport, _cCodigo )

	oSection1:BeginQuery()
	U_AO_EXTRATO(_cCodigo,cAliasTab)
	oSection1:EndQuery()

	(cAliasTab)->(DbGoTop())

	If (cAliasTab)->(Eof())
		MsgAlert("Não existem dados ou ACORDO não pertence ao representante logado.")
		Return Nil
	EndIf

	oReport:PrintText("CLIENTE: "+(cAliasTab)->NOME_CLI, oReport:Row(), 20 )
	oReport:SkipLine()

	oSection1:Print()

Return Nil



//ValPerg - Funcao para criar o grupo de perguntas SX1 se nao existir
Static Function ValPergAco()
	Local i,j,nX
	Local aTRegs := {}
	Local aHelpPor := {}
	Local aHelpEng := {}
	Local aHelpSpa := {}

	cPerg := PADR(cPerg,10)

	//DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
	aAdd(aTRegs,{"Codigo Acordo:","C",6,0,0,"G","","","","","","","","Numero do acordo para analise."})

	//Criar aRegs na ordem do vetor Temporario
	aRegs := {}
	For I := 1 To Len(aTRegs)
		aAdd(aRegs,{cPerg,StrZero(I,2),aTRegs[I][1],aTRegs[I][1],aTRegs[I][1]	,"mv_ch"+Alltrim(Str(I)),aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],aTRegs[I][6],aTRegs[I][7],;
		"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","","",aTRegs[I][12],"","","",aTRegs[I][13],""})
	Next I

	//Grava no SX1 se ja nao existir
	dbSelectArea("SX1")
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Else
			//ATUALIZA SX1
			RecLock("SX1",.F.)
			For j:=3 to FCount()
				If j <= Len(aRegs[i])
					If SubStr(FieldName(j),1,6) <> "X1_CNT"
						FieldPut(j,aRegs[i,j])
					EndIf
				Endif
			Next
			MsUnlock()
		EndIf

		//HELP DAS PERGUNTAS
		aHelpPor := {}
		__aRet := STRTOKARR(aTRegs[I][14],"#")
		FOR nX := 1 To Len(__aRet)
			AADD(aHelpPor,__aRet[nX])
		NEXT nX
		PutSX1Help("P."+AllTrim(cPerg)+aRegs[i,2]+".",aHelpPor,aHelpEng,aHelpSpa)
	Next

	//Renumerar perguntas
	_ncont := 1
	SX1->(dbSeek(cPerg))
	While .Not. SX1->(Eof()) .And. X1_GRUPO == cPerg
		RecLock("SX1",.F.)
		SX1->X1_ORDEM := StrZero(_ncont,2)
		SX1->(MsUnlock())
		SX1->(DbSkip())
		_ncont++
	EndDo

	//Deletar Perguntas sobrando - apagadas do vetor
	While SX1->(dbSeek(cPerg+StrZero(i,2)))
		RecLock("SX1",.F.)
		SX1->(DbDelete())
		SX1->(MsUnlock())
		i++
	EndDo

Return



//Modelo3 personalizado - para incluir campos no Rodape
Static Function RMod3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aButtons,aCordW,nSizeHeader)
	Local lRet, nOpca := 0,cSaveMenuh,nReg:=(cAlias1)->(Recno())
	Local oEnchoice
	Local nDlgHeight   
	Local nDlgWidth
	Local nDiffWidth := 0          
	Local nDiffHeight := 0 
	Local lMDI := .F.      
	Local lPlugin := .F.
	Local nTop := 32
	Local aSize := {}

	Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
	bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

	If IsPlugin() 
		lPlugin := .T.
	EndIf

	nOpcE := If(nOpcE==Nil,3,nOpcE)
	nOpcG := If(nOpcG==Nil,3,nOpcG)
	lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
	nLinhas:=Iif(nLinhas==Nil,99,nLinhas)

	If SetMDIChild()
		oMainWnd:ReadClientCoors()
		nDlgHeight := oMainWnd:nHeight
		nDlgWidth := oMainWnd:nWidth
		lMdi := .T.
		nDiffWidth := 2
		If lPlugin
			nDiffHeight := 25
		EndIf
	Else           
		If lPlugin
			nDlgHeight := oMainWnd:nHeight-55
			nDlgWidth	:= oMainWnd:nWidth-12
			nDiffHeight := 80
			nTop := 10
		Else		
			nDlgHeight := oMainWnd:nHeight-50
			nDlgWidth	:= oMainWnd:nWidth-27
		Endif
		nDiffWidth := 7
	EndIf

	Default aCordW := {nTop,000,nDlgHeight,nDlgWidth}
	Default nSizeHeader := 110

	Aadd(aSize,nSizeHeader)   

	DEFINE MSDIALOG oDlg TITLE cTitulo From aCordW[1],aCordW[2] to aCordW[3],aCordW[4] Pixel of oMainWnd
	If lMdi
		oDlg:lMaximized := .T.
	EndIf

	oEnchoice := Msmget():New(cAlias1,nReg,nOpcE,,,,aMyEncho,{13,1,(nSizeHeader/2)+13,If(lMdi, (oMainWnd:nWidth/2)-2,__DlgWidth(oDlg)-nDiffWidth)},aAltEnchoice,3,,,,oDlg,,lVirtual,,,,,,,,.F.)       

	_nPosRoda := (oMainWnd:nHeight/2)-nDiffHeight
	_nTamRoda := 50

	oGetDados := MsGetDados():New((nSizeHeader/2)+13+2,1,_nPosRoda-_nTamRoda,oMainWnd:nWidth/2-nDiffWidth,nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,nLinhas,cFieldOk,,,,oDlg)

	_nLRoda := 100

	@ _nPosRoda-_nTamRoda, _nLRoda+7 	SAY 	oSayTotBR PROMPT "Total Base Real:" SIZE 100, 010 OF oDlg PIXEL
	@ _nPosRoda-_nTamRoda, _nLRoda+57 	MSGET 	oGetTotBR VAR nGetTotBR SIZE 070, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL WHEN .F.
	@ _nPosRoda-_nTamRoda, _nLRoda+137 	SAY 	oSayTotBA PROMPT "Total Base Ajustada:" SIZE 100, 010 OF oDlg PIXEL
	@ _nPosRoda-_nTamRoda, _nLRoda+187 	MSGET 	oGetTotBA VAR nGetTotBA SIZE 070, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL WHEN .F.  

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons),)

	lRet:=(nOpca==1)
Return lRet

//Forcar envio de workflow
User Function AO_WF

	If MsgYesNo("Tem certeza que deseja forçar o envio do Workflow de acompanhamento para todos os Acordos?","WORKFLOW ACOMPANHAMENTO")
		U_BIAMsgRun("Aguarde... Processando Workflow.",,{|| U_FACOWF01(.T.) })
	EndIf

Return

// Workflow de AO sem Bonus x Lançamentos
User Function AOWFAOAI()
	Processa( {|| fProcWfAoAi() },"WF AO sem Bonus x Lançamentos - Aguarde...","Carregando e-mail...",.F.)
return
static function fProcWfAoAi(cDtFimDe,cDtFimAte,lObs)
	Local aPergs 	:= {}
	Local aRet	 	:= {STOD("")}
	Local cDtFim 	:= ''
	local nContReg 	:= 0
	local nTotReg	:= 100
	default lObs	:= .T.

	ProcRegua(nTotReg)
	nContReg++
	IncProc("Carregando e-mail - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")	

	If MsgYesNo("Deseja enviar o Workflow de acompanhamento de AO com metas não alcançadas x Lançamentos de provisão?"+CRLF;
	+iif(lObs,'Obs: Antes de prosseguir, verifique se o REALIZADO FOI PROCESSADO.','');
	,"Workflow - AO sem Bonus x Lançamentos")

		if empty(cDtFimAte)
			aAdd( aPergs ,{1,"DT Final do Realizado" ,STOD(" "),"",'',"",'.T.',10,.T.})
			If !ParamBox(aPergs ,"e-Mail",aRet,,,,,,,,.F.,.F.)
				Return
			EndIf
			cDtFim  := DTOS(aRet[1])
			U_FACOWF03(cDtFim,cDtFim)
		else
			U_FACOWF03(cDtFimDe,cDtFimAte)
		endif	
	endif
return


// Envia workflow de AI x Lançamentos Contabeis 
User Function AOWFLANC()
	Processa( {|| fProcWFSI() },"WF AI x Lançamentos - Aguarde...","Carregando e-mail...",.F.)
return
static function fProcWFSI(cDtFimDe,cDtFimAte,cContrato,cSI,cMod,lObs)
	Local aPergs 	:= {}
	Local aRet	 	:= {STOD("")}
	Local cDtFim 	:= ''
	local nContReg 	:= 0
	local nTotReg	:= 100
	default cMod	:= '1'	
	default lObs	:= .T.

	ProcRegua(nTotReg)
	nContReg++
	IncProc("Carregando e-mail - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")	

	if cMod	== '1'	
		If MsgYesNo("Deseja enviar o Workflow de acompanhamento de AI x Lançamentos de provisão?"+CRLF;
		+iif(lObs,'Obs: Antes de prosseguir, verifique se o REALIZADO FOI PROCESSADO.','');
		,"Workflow - AI x Lançamentos")
			if empty(cDtFimAte)
				aAdd( aPergs ,{1,"DT Final do Realizado" ,STOD(" "),"",'',"",'.T.',10,.T.})
				If !ParamBox(aPergs ,"e-Mail",aRet,,,,,,,,.F.,.F.)
					Return
				EndIf
				cDtFim  := DTOS(aRet[1])
				U_FACOWF02(cDtFim,cDtFim)
			else
				U_FACOWF02(cDtFimDe,cDtFimAte,cContrato,cSI)
			endif	
		endif
	else
		U_FACOWF02(cDtFimDe,cDtFimAte,cContrato,cSI)
	endif	
return

//Atualizar Realizado de Todos os Acrordos de uma so vez
User Function AO_UPDREA

	Local aPergs		:= {}
	Local aRet			:= {CTOD(" "),CTOD(" "),"Sim"}
	Local cAliasTmp  	:= ''
	Local cAliasCount	:= ''
	Local nCount		:= ''
	Local cDtFimDe		:= ''
	Local cDtFimAte		:= ''
	Private cLogSI		:= ''

	aAdd( aPergs ,{1,"Data De: ",CTOD(" "),"",'',"",'.T.',10,.T.})
	aAdd( aPergs ,{1,"Data Até: ",CTOD(" "),"",'',"",'.T.',10,.T.})
	aAdd( aPergs ,{2,"Gerar SI: ",1,{"Sim","Não"},30,'.T.',.T.})

	If !ParamBox(aPergs ,"Atualização",aRet,,,,,,,,.F.,.F.)
		Return
	EndIf
	cDtFimDe  := DTOS(aRet[1])
	cDtFimAte := DTOS(aRet[2])

	cAliasCount := GetNextAlias()
	BeginSql Alias cAliasCount  

		select CONT = count(distinct PZ5_CODIGO) from %Table:PZ5% PZ5
		join %Table:PZ6% PZ6 on PZ6_FILIAL = PZ5_FILIAL and PZ6_CODIGO = PZ5_CODIGO
		where PZ5_STATUS = 'S' 
		and PZ6_PERFIM between %Exp:cDtFimDe% and %Exp:cDtFimAte%
		and (PZ6_DTULRE <= PZ6_PERFIM OR PZ6_SI = '') 
		and PZ5.D_E_L_E_T_=''
		and PZ6.D_E_L_E_T_=''

	EndSql

	nCount := (cAliasCount)->CONT
	(cAliasCount)->(DbCloseArea())

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp  

		select distinct PZ5_CODIGO from %Table:PZ5% PZ5
		join %Table:PZ6% PZ6 on PZ6_FILIAL = PZ5_FILIAL and PZ6_CODIGO = PZ5_CODIGO
		where PZ5_STATUS = 'S' 
		and PZ6_PERFIM between %Exp:cDtFimDe% and %Exp:cDtFimAte%
		and (PZ6_DTULRE <= PZ6_PERFIM OR PZ6_SI = '')
		and PZ5.D_E_L_E_T_=''
		and PZ6.D_E_L_E_T_=''

	EndSql

	If !(cAliasTmp)->(Eof())

		processa({|| UpdReaAll(nCount, cAliasTmp) }, "Atualização de Realizado", "Processando aguarde...", .F.)

		processa({|| UpdBonAll(nCount, cAliasTmp, AllTrim(aRet[3]) == "Sim") }, "Calculo de bônus e AI", "Processando aguarde...", .F.)

	EndIf

	(cAliasTmp)->(DbCloseArea())

	If !Empty(cLogSI)
		Aviso("Atenção",'Foram geradas as seguintes SI:' +CRLF+cLogSI,{"Ok"},3)
	EndIf

	MsgInfo("Atualização realizada com sucesso!","Acordos de Objetivo")

	// WF AI x Lançamentos
	Processa( {|| fProcWFSI(cDtFimDe,cDtFimAte,,,,.F.) },"WF AI x Lançamentos - Aguarde...","Carregando e-mail...",.F.)
	// WF AO sem AI
	Processa( {|| fProcWfAoAi(cDtFimDe,cDtFimAte,.F.) },"WF AO sem Bonus x Lançamentos - Aguarde...","Carregando e-mail...",.F.)

Return


Static Function UpdReaAll(nCount, cAliasTmp)

	procregua(nCount)

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		incproc("Processando acordo: "+(cAliasTmp)->PZ5_CODIGO)

		UpdReaAco((cAliasTmp)->PZ5_CODIGO)

		(cAliasTmp)->(DbSkip())
	EndDo

Return


Static Function UpdReaAco(cCodAC)
	Local I
	Local cDIni, cDFim
	Local cTipCli, cCodCli, cLojCli
	Local cSQL

	PZ5->(DbSetOrder(1))
	If !PZ5->(DbSeek(XFilial("PZ5")+cCodAC))
		Return
	EndIf

	PZ6->(DbSetOrder(1))
	If !PZ6->(DbSeek(XFilial("PZ6")+cCodAC))
		Return
	EndIf

	While !PZ6->(Eof()) .And. PZ6->(PZ6_FILIAL+PZ6_CODIGO) == (XFilial("PZ6")+cCodAC) 

		//Periodo definido - e sem SI gerada
		If (!Empty(PZ6->PZ6_PERFIM) .And. !Empty(PZ6->PZ6_PERINI)) .And. (Empty(PZ6->PZ6_SI))

			If (PZ6->PZ6_DTULRE > PZ6->PZ6_PERFIM)
				PZ6->(DbSkip())
				loop
			EndIf

			cDIni := DTOS(PZ6->PZ6_PERINI)
			cDFim := DTOS(PZ6->PZ6_PERFIM)

			cTipCli := PZ5->PZ5_TIPCLI

			If cTipCli == "1"
				cCodCli := PZ5->PZ5_CODCLI
				cLojCli := PZ5->PZ5_LOJCLI
			ElseIf cTipCli == "2"
				cCodCli := PZ5->PZ5_CODGRP
				cLojCli := ""
			Else
				cCodCli := PZ5->PZ5_REDE
				cLojCli := ""
			EndIf

			If Select("TRB") > 0
				TRB->(DbCloseArea())
			EndIf

			cSQL := "select VALOR = dbo.FNC_AO_RECEITA('"+PZ5->PZ5_MARCA+"','"+cTipCli+"','"+cCodCli+"','"+cLojCli+"','"+cDIni+"','"+cDFim+"','"+PZ5->PZ5_TIPCAL+"','"+PZ5->PZ5_TIPFIL+"','"+AllTrim(PZ5->PZ5_PACOTE)+"')"

			If Select("TRB") > 0
				TRB->(DbCloseArea())
			EndIf

			TCQuery cSQL Alias "TRB" New

			TRB->(DbGoTop())

			RecLock("PZ6",.F.)

			If !TRB->(Eof())
				PZ6->PZ6_VALREA := TRB->VALOR
				PZ6->PZ6_DTULRE := dDataBase
			Else
				PZ6->PZ6_VALREA := 0
			EndIf

			PZ6->(MsUnlock())

			TRB->(DbCloseArea())

			//OS 1337-16 : Filtro dos pacotes para calculo da base da verba com pacotes diferenciados - solicitacao Incesa
			If PZ6->(FieldPos("PZ6_BASVER")) > 0 .And. PZ5->(FieldPos("PZ5_PCTVER")) > 0 .And. !Empty(PZ5->PZ5_PCTVER)

				cSQL := "select VALOR = dbo.FNC_AO_RECEITA('"+PZ5->PZ5_MARCA+"','"+cTipCli+"','"+cCodCli+"','"+cLojCli+"','"+cDIni+"','"+cDFim+"','"+PZ5->PZ5_TIPCAL+"','"+PZ5->PZ5_TIPFIL+"','"+AllTrim(PZ5->PZ5_PCTVER)+"')"

				If Select("TRB") > 0
					TRB->(DbCloseArea())
				EndIf

				TCQuery cSQL Alias "TRB" New

				TRB->(DbGoTop())

				RecLock("PZ6",.F.)

				If !TRB->(Eof())
					PZ6->PZ6_BASVER := TRB->VALOR				
				Else
					PZ6->PZ6_BASVER := 0
				EndIf

				PZ6->(MsUnlock())

				TRB->(DbCloseArea())

			EndIf

		EndIf

		PZ6->(DbSkip())	
	EndDo

Return

//ATUALIZAR BONUS RECEBIDOS
Static Function UpdBonAll(nCount, cAliasTmp, lGeraSI)

	procregua(nCount)

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		incproc("Processando acordo: "+(cAliasTmp)->PZ5_CODIGO)

		UpdBonusAI((cAliasTmp)->PZ5_CODIGO, lGeraSI)

		(cAliasTmp)->(DbSkip())
	EndDo

Return

Static Function UpdBonusAI(cCodAC, lGeraSI)
	Local _nValRea := 0
	Local _nVBasVer := 0

	Local _nMeta1 := 0
	Local _nMeta2 := 0
	Local _nMeta3 := 0
	Local _nMeta4 := 0
	Local _nMeta5 := 0
	Local _nPBonus1 := 0
	Local _nPBonus2 := 0
	Local _nPBonus3 := 0
	Local _nPBonus4 := 0
	Local _nPBonus5 := 0

	PZ5->(DbSetOrder(1))
	If !PZ5->(DbSeek(XFilial("PZ5")+cCodAC))
		Return
	EndIf

	PZ6->(DbSetOrder(1))
	If !PZ6->(DbSeek(XFilial("PZ6")+cCodAC))
		Return
	EndIf

	While !PZ6->(Eof()) .And. PZ6->(PZ6_FILIAL+PZ6_CODIGO) == (XFilial("PZ6")+cCodAC) 

		//Periodo definido - e sem SI gerada
		If (!Empty(PZ6->PZ6_PERFIM) .And. !Empty(PZ6->PZ6_PERINI)) .And. (Empty(PZ6->PZ6_SI)) .And. (PZ6->PZ6_PERFIM < dDataBase)

			_nValRea := PZ6->PZ6_VALREA

			//OS 1337-16 : Filtro dos pacotes para calculo da base da verba com pacotes diferenciados - solicitacao Incesa
			If PZ5->(FieldPos("PZ5_PCTVER")) > 0 .And. !Empty(PZ5->PZ5_PCTVER)
				_nVBasVer := PZ6->PZ6_BASVER		
			EndIf

			_nMeta1		:= PZ6->PZ6_METAF1
			_nPBonus1	:= PZ6->PZ6_PBONF1
			_nMeta2		:= PZ6->PZ6_METAF2
			_nPBonus2	:= PZ6->PZ6_PBONF2
			_nMeta3		:= PZ6->PZ6_METAF3
			_nPBonus3	:= PZ6->PZ6_PBONF3
			_nMeta4		:= PZ6->PZ6_METAF4
			_nPBonus4	:= PZ6->PZ6_PBONF4
			_nMeta5		:= PZ6->PZ6_METAF5
			_nPBonus5	:= PZ6->PZ6_PBONF5

			//Bonus na Faixa 1
			If (_nMeta1 > 0 .And. _nValRea >= _nMeta1 .And. (_nMeta2 <= 0 .Or. _nValRea < _nMeta2))

				RecLock("PZ6",.F.)
				PZ6->PZ6_BONUS := (IIf(_nVBasVer > 0, _nVBasVer, _nValRea) * _nPBonus1) / 100
				PZ6->(MsUnlock())

			EndIf

			//Bonus na Faixa 2
			If (_nMeta2 > 0 .And. _nValRea >= _nMeta2 .And. (_nMeta3 <= 0 .Or. _nValRea < _nMeta3))

				RecLock("PZ6",.F.)
				PZ6->PZ6_BONUS := (IIf(_nVBasVer > 0, _nVBasVer, _nValRea) * _nPBonus2) / 100
				PZ6->(MsUnlock())

			EndIf

			//Bonus na Faixa 3
			If (_nMeta3 > 0 .And. _nValRea >= _nMeta3 .And. (_nMeta4 <= 0 .Or. _nValRea < _nMeta4))

				RecLock("PZ6",.F.)
				PZ6->PZ6_BONUS := (IIf(_nVBasVer > 0, _nVBasVer, _nValRea) * _nPBonus3) / 100
				PZ6->(MsUnlock())

			EndIf

			//Bonus na Faixa 4
			If (_nMeta4 > 0 .And. _nValRea >= _nMeta4 .And. (_nMeta5 <= 0 .Or. _nValRea < _nMeta5))

				RecLock("PZ6",.F.)
				PZ6->PZ6_BONUS := (IIf(_nVBasVer > 0, _nVBasVer, _nValRea) * _nPBonus4) / 100
				PZ6->(MsUnlock())

			EndIf

			//Bonus na Faixa 5
			If (_nMeta5 > 0 .And. _nValRea >= _nMeta5)

				RecLock("PZ6",.F.)
				PZ6->PZ6_BONUS := (IIf(_nVBasVer > 0, _nVBasVer, _nValRea) * _nPBonus5) / 100
				PZ6->(MsUnlock())

			EndIf

			//Geracao da SI
			If (lGeraSI .And. PZ6->PZ6_BONUS > 0)

				cNumSI := GerarSI(PZ6->PZ6_BONUS,PZ6->PZ6_PERINI,PZ6->PZ6_PERFIM,PZ6->PZ6_IDPER, .T.)
				RecLock("PZ6",.F.)
				PZ6->PZ6_SI := cNumSI 
				PZ6->(MsUnlock())

				cLogSI += cNumSI + CRLF 

			EndIf	

		EndIf

		PZ6->(DbSkip())
	EndDo

Return