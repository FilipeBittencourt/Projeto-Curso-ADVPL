#Include "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "vkey.ch"

/*/{Protheus.doc} FPVETE05
@description tela Modelo 3 para cadastro do SELLOUT dos clientes - Substituicao da FPVETE03 que é MVC mas apresentou erros
@author Fernando Rocha
@since 14/06/2017
@version undefined\
@type function
/*/
User Function FPVETE05()


	Local aCores
	Private xImpDh := .F.
	Private wdProc := ""
	Private cCadastro := "SELLOUT dos clientes"
	Private aRotina

	aRotina   := {  {"Pesquisar"    ,'AxPesqui'                             ,0, 1},;
	{                "Visualizar"   ,'Execblock("FPT05MNT" ,.F.,.F.,"V")'    ,0, 2},;
	{                "Incluir"      ,'Execblock("FPT05MNT" ,.F.,.F.,"I")'    ,0, 3},;
	{                "Alterar"      ,'Execblock("FPT05MNT" ,.F.,.F.,"T")'    ,0, 4},;
	{                "Excluir"      ,'Execblock("FPT05MNT" ,.F.,.F.,"E")'    ,0, 5},;
	{                "Copiar"       ,'Execblock("FPT05MNT" ,.F.,.F.,"C")'    ,0, 6},;
	{                "Import.Excel" ,'Execblock("FPT05EXC" ,.F.,.F.,"C")'    ,0, 6}}

	dbSelectArea("Z84")
	mBrowse(6,1,22,75, "Z84", , , , , ,aCores)

Return


/*/{Protheus.doc} FPT05MNT
@description Manutenção Modelo 3
@author Fernando Rocha
@since 14/06/2017
@version undefined
@type function
/*/
User Function FPT05MNT()

	Local i, z

	Private cOpcao

	If PARAMIXB == "I"
		cOpcao := "INCLUIR"
	ElseIf PARAMIXB == "V"
		cOpcao := "VISUALIZAR"
	ElseIf PARAMIXB == "T"
		cOpcao := "ALTERAR"
	ElseIf PARAMIXB == "E"
		cOpcao := "EXCLUIR"
	ElseIf PARAMIXB == "C"
		cOpcao := "COPIAR"
	EndIf

	Do Case
		Case cOpcao == "VISUALIZAR"; nOpcE:=2 ; nOpcG:=2
		Case cOpcao == "INCLUIR"   ; nOpcE:=3 ; nOpcG:=3
		Case cOpcao == "ALTERAR"   ; nOpcE:=2 ; nOpcG:=4
		Case cOpcao == "EXCLUIR"   ; nOpcE:=2 ; nOpcG:=2
		Case cOpcao == "COPIAR"    ; nOpcE:=3 ; nOpcG:=4
	EndCase


	Private aCOLSORI  //private para armazenar o ACOLS original antes dos filtros

	//Cabecalho
	Private aCpoEnchoice   := {"Z84_ANO", "Z84_MES", "NOUSER"}


	//Campos do Grid 
	Private aHeader := {}

	Aadd(aHeader,{ "Cliente"	, "Z84_CODCLI"	, "@!", 6, 0,"U_FPT5VLCL()", "€€€€€€€€€€€€€€" , "C", "", "R" } )
	Aadd(aHeader,{ "Lj.Cli."	, "Z84_LOJCLI"	, "@!", 2, 0,"U_FPT5VLCL()", "€€€€€€€€€€€€€€" , "C", "", "R" } )
	Aadd(aHeader,{ "UF"			, "UF"			, "@!", 2, 0,"AllwaysTrue()", "€€€€€€€€€€€€€€" , "C", "", "V" } )
	Aadd(aHeader,{ "Nome Loja"	, "NOMLOJ"		, "@!", 40, 0,"AllwaysTrue()", "€€€€€€€€€€€€€€" , "C", "", "V" } )
	Aadd(aHeader,{ "Promotor(a)", "NOMFUN"		, "@!", 40, 0,"AllwaysTrue()", "€€€€€€€€€€€€€€" , "C", "", "V" } )
	Aadd(aHeader,{ "Real (m2)"	, "META_QTDE"	, "@E 999,999,999.99", 14, 2,"AllwaysTrue()", "€€€€€€€€€€€€€€" , "N", "", "R" } )
	Aadd(aHeader,{ "Real (R$)"	, "META_VALOR"	, "@E 999,999,999.99", 14, 2,"AllwaysTrue()", "€€€€€€€€€€€€€€" , "N", "", "R" } )


	RegToMemory("Z84", (cOpcao $ "INCLUIR/COPIAR") )

	aCols := {}
	If cOpcao == "INCLUIR"

		AAdd(aCols, {Space(6),Space(2),Space(2),Space(40),Space(40),0,0,.F.} )

	Else

		aCols := LoadZ84()

	Endif

	If Len(aCols) > 0

		aCOLSORI 		:= AClone(aCols) 

		cTitulo        := cCadastro
		cAliasEnchoice := "Z84"
		cAliasGetD     := "Z84"
		cLinOk         := "ExecBlock('FPT05LOK',.F.,.F.)"
		cTudOk         := "ExecBlock('FPT05TOK',.F.,.F.)"
		cFieldOk       := "AllwaysTrue()"

		xf_Buttons	:= {}

		If cOpcao $ "ALTERAR"
			AAdd(xf_Buttons, {'CLIENTE',{|| U_FPT5FILT() },'Filtrar Loja/Promotor'} )
			AAdd(xf_Buttons, {'CLIENTE',{|| U_FPT5REFI() },'Remover Filtro'} )
		EndIf

		_lRet := Modelo3(cTitulo, cAliasEnchoice, cAliasGetD, aCpoEnchoice, cLinOk, cTudOk, nOpcE, nOpcG, cFieldOk, .T., 9999, , , xf_Buttons,,100)

		If _lRet

			Gravar()

		Endif

	Endif

Return

Static Function LoadZ84()
	Local _aColsTmp := {}
	U_BIAMsgRun("Aguarde... Carregando registros...",, {|| _aColsTmp := LZ84Proc() })
Return(_aColsTmp)

Static Function LZ84Proc()

	Local _aColsTmp := {}

	__cAno := Z84->Z84_ANO
	__cMes := Z84->Z84_MES

	Z84->(DbSetOrder(2))
	If Z84->(DbSeek(XFilial("Z84")+__cAno+__cMes))

		While !Z84->(Eof()) .And. Z84->(Z84_FILIAL+Z84_ANO+Z84_MES) == (XFilial("Z84")+__cAno+__cMes)

			SA1->(DbSetOrder(1))
			SA1->(DbSeek(XFilial("SA1")+Z84->Z84_CODCLI+Z84->Z84_LOJCLI))

			__nPromotor := GetPromotor(Z84->Z84_CODCLI, Z84->Z84_LOJCLI)

			AAdd(_aColsTmp, {Z84->Z84_CODCLI, Z84->Z84_LOJCLI, SA1->A1_EST, SA1->A1_YNLOJA, __nPromotor, Z84->Z84_QTDE, Z84->Z84_VALOR,.F.} )

			Z84->(DbSkip())
		EndDo

	EndIf

Return(_aColsTmp)


User Function FPT05LOK()

Return(.T.)

User Function FPT05TOK()

	Local cAno := M->Z84_ANO
	Local cMes := M->Z84_MES

	If Empty(cAno) .Or. Empty(cMes)
		MsgAlert("Obrigatório informar ANO e MÊS!")
		Return(.F.)
	EndIf

	If cOpcao $ "INCLUIR/COPIAR"
		Z84->(DbSetOrder(2))
		If Z84->(DbSeek(XFilial("Z84")+cAno+cMes))

			MsgAlert("ANO e MÊS já informados, favor alterar o registro existente!")
			Return(.F.)

		EndIf
	EndIf

Return(.T.)


/*/{Protheus.doc} GetPromotor
@description Buscar o promotor atualmente associado ao cliente/empresa
@author Fernando Rocha
@since 16/01/2017
@version undefined
@param _cCodCli, , descricao
@param _cLojCli, , descricao
@type function
/*/
Static Function GetPromotor(_cCodCli, _cLojCli)

	Local cAliasTmp
	Local cRet := ""
	Local cArea := GetArea()

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp 
		%NoParser%

		select top 1 Z85_NOMFUN from %Table:Z85%
		where Z85_FILIAL = %XFilial:Z85%
		and Z85_CODCLI = %Exp:_cCodCli%
		and Z85_LOJCLI = %Exp:_cLojCli%
		and Z85_DTINIC <= %Exp:DTOS(dDataBase)%
		and Z85_DTFIM >= %Exp:DTOS(dDataBase)%
		and D_E_L_E_T_=''
		order by Z85_DTINIC desc

	EndSql

	If !(cAliasTmp)->(Eof())
		cRet := (cAliasTmp)->Z85_NOMFUN
	EndIf

	(cAliasTmp)->(DbCloseArea())
	RestArea(cArea)

Return(cRet)


//-------------------------------------------------------------------
// Validar digitacao de cliente
//-------------------------------------------------------------------
User Function FPT5VLCL()

	Local lRet := .T.
	Local I, J
	Local cCliDig
	Local cLojDig
	Local nPosCli 	:= aScan(aHeader, {|x|  Alltrim(x[2]) == "Z84_CODCLI"})
	Local nPosLoj 	:= aScan(aHeader, {|x|  Alltrim(x[2]) == "Z84_LOJCLI"})
	Local nPosUF 	:= aScan(aHeader, {|x|  Alltrim(x[2]) == "UF"})
	Local nPosNLoj 	:= aScan(aHeader, {|x|  Alltrim(x[2]) == "NOMLOJ"})
	Local nPosNFun	:= aScan(aHeader, {|x|  Alltrim(x[2]) == "NOMFUN"})

	If AllTrim(ReadVar()) == "M->Z84_CODCLI"
		cCliDig := M->Z84_CODCLI
		cLojDig := IIF(!Empty(ACOLS[N][nPosLoj]), ACOLS[N][nPosLoj], "01") 
	Else
		cCliDig := ACOLS[N][nPosCli]
		cLojDig := M->Z84_LOJCLI
	EndIf

	For I := 1 To Len(ACOLS)

		If ( N <> I )	

			If ( ACOLS[I][nPosCli] == cCliDig ) .And. ( ACOLS[I][nPosLoj] == cLojDig )

				MsgAlert("Cliente já informado (LINHA: "+AllTrim(Str(I))+"), não é possível duas linhas de Sell Out para o mesmo cliente.","Sell Out de Clientes")
				lRet := .F.
				exit

			EndIf

		EndIf

	Next I

	For I := 1 To Len(aCOLSORI)

		If ( N <> I )	

			If ( aCOLSORI[I][nPosCli] == cCliDig ) .And. ( aCOLSORI[I][nPosLoj] == cLojDig )

				MsgAlert("Cliente já informado, não é possível duas linhas de Sell Out para o mesmo cliente.","Sell Out de Clientes")
				lRet := .F.
				exit

			EndIf

		EndIf

	Next I

	If lRet

		SA1->(DbSetOrder(1))
		SA1->(DbSeek(XFilial("SA1")+cCliDig+cLojDig))

		__nPromotor := GetPromotor(cCliDig, cLojDig)

		ACOLS[N][nPosUF] 	:= SA1->A1_EST
		ACOLS[N][nPosNLoj]	:= SA1->A1_YNLOJA
		ACOLS[N][nPosNFun]	:= __nPromotor

		GETDREFRESH()

	EndIf

Return(lRet)


/*/{Protheus.doc} fFiltraGrid
@description Filtrar o ACOLS
@author Fernando Rocha
@since 14/06/2017
@version undefined
@type function
/*/
User Function FPT5FILT()

	Local aPergs 	:= {}
	local cLoad	    := 'FPVET3FL' + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local cNomeLoja	:= space(100) 
	local cPromotor	:= space(100) 
	Local lContinua	:= .T.

	aAdd( aPergs ,{1,"Loja"		,cNomeLoja  ,"@!",'.T.',"",'.T.',75,.F.})
	aAdd( aPergs ,{1,"Promotor"	,cPromotor  ,"@!",'.T.',"",'.T.',75,.F.})

	If ParamBox(aPergs ,"Filtrar (Dados Alterados serão perdidos)",,,,,,,,cLoad,.T.,.T.)      
		cNomeLoja  := ParamLoad(cFileName,,1,cNomeLoja) 
		cPromotor  := ParamLoad(cFileName,,2,cPromotor) 

		if lContinua .and. Empty(cNomeLoja) .and. Empty(cPromotor)	
			lContinua := .F.
			MsgAlert("Informe pelo menos um campo para realizar o filtro!")
		endif	

		if lContinua .and. (!Empty(cNomeLoja) .or. !Empty(cPromotor))	

			if Len(Alltrim(cNomeLoja)) < 3 .and. Len(Alltrim(cPromotor)) < 3
				lContinua := .F.
			endif
			if ! lContinua 
				MsgAlert("Informe pelo menos 3 caracteres em um dos campos!")
			endif	
		endif

		if lContinua

			Processa( {|| fProcFil(cNomeLoja,cPromotor) },"Aguarde...","Filtrando registros...")

		endif
	endif	
return

Static Function fProcFil(cNomeLoja,cPromotor)

	Local I
	Local nPosLoj 	:= aScan(aHeader, {|x|  Alltrim(x[2]) == "NOMLOJ"})
	Local nPosPro 	:= aScan(aHeader, {|x|  Alltrim(x[2]) == "NOMFUN"})
	Local NewACols := {}

	Gravar()
	aCOLSORI := AClone(LoadZ84())

	For I := 1 To Len(aCOLSORI)

		__LLOJAOK := Empty(cNomeLoja) .Or. Alltrim(cNomeLoja) $ AllTrim(aCOLSORI[I][nPosLoj])
		__LPROMOOK := Empty(cPromotor) .Or. Alltrim(cPromotor) $ AllTrim(aCOLSORI[I][nPosPro])

		If (__LLOJAOK .And. __LPROMOOK)

			AAdd(NewACols, aCOLSORI[I])

		EndIf

	Next I

	If Len(NewACols) == 0

		MsgAlert("Não localizado resultados com este filtro!")
		Return

	Else

		ACOLS := AClone(NewACols)
		GETDREFRESH()

	EndIf

Return

User Function FPT5REFI()

	Gravar()
	ACOLS := AClone(LoadZ84())
	GETDREFRESH()

Return


/*/{Protheus.doc} Gravar
@description Gravacao dos Dados da Tela
@author Fernando Rocha
@since 14/06/2017
@version undefined

@type function
/*/
Static Function Gravar()
	U_BIAMsgRun("Aguarde... Gravando registros...",, {|| GrvProc() })
Return

Static Function GrvProc()

	Local I
	Local cAno := M->Z84_ANO
	Local cMes := M->Z84_MES
	Local nPosCCli 	:= aScan(aHeader, {|x|  Alltrim(x[2]) == "Z84_CODCLI"})
	Local nPosLCli 	:= aScan(aHeader, {|x|  Alltrim(x[2]) == "Z84_LOJCLI"})
	Local nPosQtd 	:= aScan(aHeader, {|x|  Alltrim(x[2]) == "META_QTDE"})
	Local nPosVal 	:= aScan(aHeader, {|x|  Alltrim(x[2]) == "META_VALOR"})

	If cOpcao $ "EXCLUIR"

		If !MsgNoYes("TEM CERTEZA que deseja excluir todos os registros do ANO/MÊS: "+cAno+"/"+cMes)
			Return
		EndIf

		Z84->(DbSetOrder(2))
		If Z84->(DbSeek(XFilial("Z84")+cAno+cMes))

			While !Z84->(Eof()) .And. Z84->(Z84_FILIAL+Z84_ANO+Z84_MES) == (XFilial("Z84")+cAno+cMes) 

				RecLock("Z84",.F.)
				Z84->(DbDelete())
				Z84->(MsUnlock())

				Z84->(DbSkip())
			EndDo

		EndIf

	EndIf

	If cOpcao $ "INCLUIR/COPIAR"

		FOR I := 1 To Len(ACOLS)

			If ACOLS[I][Len(AHEADER)+1]
				loop
			EndIf

			RecLock("Z84",.T.)
			Z84->Z84_FILIAL := XFILIAL("Z84")
			Z84->Z84_ANO	:= cAno
			Z84->Z84_MES	:= cMes			
			Z84->Z84_CODCLI	:= ACOLS[I][nPosCCli]
			Z84->Z84_LOJCLI	:= ACOLS[I][nPosCCli]
			Z84->Z84_QTDE	:= ACOLS[I][nPosQtd]
			Z84->Z84_VALOR	:= ACOLS[I][nPosVal]
			Z84->(MsUnlock())

		NEXT I

	EndIf

	If cOpcao $ "ALTERAR"

		FOR I := 1 To Len(ACOLS)

			If ACOLS[I][Len(AHEADER)+1]

				Z84->(DbSetOrder(2))
				If Z84->(DbSeek(XFilial("Z84")+cAno+cMes+ACOLS[I][nPosCCli]+ACOLS[I][nPosLCli]))

					RecLock("Z84",.F.)
					Z84->(DbDelete())
					Z84->(MsUnlock())

				EndIf

				loop
			EndIf

			Z84->(DbSetOrder(2))
			If Z84->(DbSeek(XFilial("Z84")+cAno+cMes+ACOLS[I][nPosCCli]+ACOLS[I][nPosLCli]))

				RecLock("Z84",.F.)

			Else

				RecLock("Z84",.T.)
				Z84->Z84_FILIAL := XFILIAL("Z84")
				Z84->Z84_ANO	:= cAno
				Z84->Z84_MES	:= cMes
				Z84->Z84_CODCLI	:= ACOLS[I][nPosCCli]
				Z84->Z84_LOJCLI	:= ACOLS[I][nPosLCli]	

			EndIf

			Z84->Z84_QTDE	:= ACOLS[I][nPosQtd]
			Z84->Z84_VALOR	:= ACOLS[I][nPosVal]
			Z84->(MsUnlock())

		NEXT I

	EndIf

Return


/*/{Protheus.doc} FPT05EXC
@description Funcao para importar planilha Excel para cadastro de SellOut de Clientes
@author Fernando Rocha
@since 11/07/2017
@version undefined
@type function
/*/
User Function FPT05EXC

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de Planilha Sell Out de Clientes, por arquivo excel!"))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Sell Out de Clientes'), aSays, aButtons ,,,500)

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
	Local cLoad	    := 'FPT05EXC' + cEmpAnt
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
	Local cTabImp			:= 'Z84'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	local nRepeat			:= 0
	Local nErros			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local ny, nx

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

		BEGIN TRANSACTION   

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

					SX3->(DbSetOrder(2))

					For ny := 1 to Len(aLinha)

						If Len(aCampos) >= ny 

							cConteudo := aLinha[ny]

							If SX3->(DbSeek(Padr(aCampos[ny],10),.T.))

								Do Case

									case SX3->X3_TIPO == "D"
									cConteudo := SubStr(cConteudo,1,10)
									cConteudo := stod(StrTran(cConteudo, "-", ""))

									case SX3->X3_TIPO == "N"
									cConteudo := Val(cConteudo)

									case SX3->X3_TIPO == "C"
									cConteudo := Padr(cConteudo,TamSX3(aCampos[ny])[1])

								EndCase

								AADD(aItem,{ aCampos[ny] , cConteudo , nil })

							EndIf

						EndIf

					Next ny	

					If len(aItem) > 0

						__cAno := aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z84_ANO"})][2]
						__cMes := aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z84_MES"})][2]
						__cCli := aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z84_CODCLI"})][2]+aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z84_LOJCLI"})][2]

						Z84->(DbSetOrder(2))
						If Z84->(DbSeek(XFilial("Z84")+__cAno+__cMes+__cCli))

							nRepeat++

						Else
							nImport++

							RecLock("Z84",.T.)
							Z84_FILIAL	:= XFilial("Z84")
							Z84_ANO		:= __cAno
							Z84_MES		:= __cMes
							Z84_CODCLI	:= SubStr(__cCli,1,6)
							Z84_LOJCLI	:= SubStr(__cCli,7,2)
							Z84_QTDE	:= aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z84_QTDE"})][2]
							Z84_VALOR	:= aItem[aScan(aItem,{|x| AllTrim(x[1]) == "Z84_VALOR"})][2]
							Z84->(MsUnlock())

						EndIf

					Else
						nErros++				
					EndIf

				EndIf

			Next nx

		END TRANSACTION

	EndIf

	MsgInfo(Alltrim(Str(nImport))+" Registros importados com sucesso."+CRLF+;
	Alltrim(Str(nRepeat))+" Registros já existentes na base de dados."+;
	IIF(nErros>0,CRLF+Alltrim(Str(nErros))+" Registros com ERROS.",""))

	RestArea(aArea)

Return