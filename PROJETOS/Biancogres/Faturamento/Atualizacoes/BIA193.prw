#Include "PROTHEUS.CH"
#Include "TopConn.ch"

/*/{Protheus.doc} BIA193
@description TELA MODELO 2 PARA AMARRACAO PROMOTORES DE VENDAS X CLIENTES X PERCENTUAL X EMPRESAS
@author Rubens Junior (FACILE SISTEMAS) (Revisado por: Fernando Rocha)
@since 07/05/2014
@version 1.0
@type function
/*/
User Function BIA193()

	Local aCores := {}
	Local cAlias := "Z31"

	PRIVATE ENTER := CHR(13)+CHR(10)

	Private cCadastro := "Amarração Consultores de Vendas x Clientes x Empresa"
	Private cCodFunc := GetMv( "MV_YBIA193")	//CODIGO DE FUNCOES QUE SAO DE PROMOTORES (CADASTRADO NA TABELA SRA)
	Private cCodFuncI := GetMv( "MV_BIA193I")	//CODIGO DE FUNCOES QUE SAO DE PROMOTORES - INCESA

	Private cCLVLPVE := GetNewPar("FA_CLVLPVE", "2116/2156/2115/2215/2155/2255")

	cCodFuncI := cCodFunc

	Private aRotina   := {	{"Pesquisar"    	,"AxPesqui"     	,0,1},;
		{"Visualizar"  		,"U_BIA193_MNT"	,0,2},;
		{"Incluir"	     	,"U_BIA193_I"	,0,3},;
		{"Alterar"  	   	,"U_BIA193_MNT"	,0,4},;
		{"Excluir"			,"U_BIA193_MNT"	,0,5},;
		{"Listar Cadastrados","U_BIA193_L"	,0,6}}

	(cAlias)->(DbSetOrder(1))
	(cAlias)->(DbGoTop())

	(cAlias)->(MBROWSE(6,1,22,75,cAlias,,,,,,aCores))

Return

//DESCRICAO..: TELA PARA INCLUSAO DAS AMARRACOES MODELO 2
User Function BIA193_I(cAlias, nReg, nOpc)

	Local aArea := GetArea()
	Local oTPanel1
	Local aSizFrm := {}

	Private oDlg
	Private oGetDados
	Private cCodigo := GetSxeNum("Z31","Z31_CODIGO")
	Private cMatricula := Space(Len(( cAlias )->Z31_CODFUN))
	Private cDesc := Space(Len(( cAlias )->Z31_NOMFUN))
	Private oCheckBo1
	Private lCheckBo1 := .F.
	Private dGetDtIni := Date()
	Private dGetDtFim := Date()
	Private lLinhaOk := .F.		//SE NA ALTERACAO CLICAR DIRETAMENTE EM OK, O SISTEMA NAO VALIDA A LINHA

	Private cCodEmp := Space(Len(( cAlias )->Z31_CODEMP))

	Private aHeader := {}
	Private aCOLS := {}
	Private aREG := {}

	//Monta Tela
	aSizFrm := MsAdvSize()

	dbSelectArea( cAlias )
	dbSetOrder(1)
	Mod2aHeader( cAlias )
	Mod2aCOLS( cAlias, nReg, nOpc )

	//DEFINE MSDIALOG oDlg TITLE cCadastro From 8,0 To 48,160 OF oMainWnd
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000, 000 TO aSizFrm[6]*80/110 ,aSizFrm[5]*80/110 COLORS 0, 15658734 PIXEL
	oTPanel1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,45,.T.,.F.)
	oTPanel1:Align := CONTROL_ALIGN_TOP

	@ 11, 006 SAY "Empresa:" SIZE 70,7 PIXEL OF oTPanel1
	@ 010, 035 MSCOMBOBOX oComboBo1 VAR cCodEmp ITEMS {"01=Biancogres","05=Incesa","07=LM"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 11, 112 SAY "Consultor(a):" SIZE 70,7 PIXEL OF oTPanel1
	@ 11, 230 SAY "Nome:" SIZE 70,7 PIXEL OF oTPanel1
	@ 10, 150 MSGET cMatricula PICTURE "@!" SIZE 050,7 PIXEL OF oTPanel1 F3 "SRABIA" VALID ValidaCadastro()
	@ 10, 250 MSGET cDesc PICTURE "@!" When .F. SIZE 200,7 PIXEL OF oTPanel1

	@ 29, 006 SAY "Data Inicio:" SIZE 70,7 PIXEL OF oTPanel1
	@ 28, 038 MSGET dGetDtIni SIZE 060, 010 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData()
	@ 29, 110 SAY "Data Final:" SIZE 70,7 PIXEL OF oTPanel1
	@ 28, 138 MSGET dGetDtFim SIZE 060, 010 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData()

	@ 29, 210 SAY "Codigo:" SIZE 70,7 PIXEL OF oTPanel1
	@ 29, 235 MSGET cCodigo When .F. SIZE 50,7 PIXEL OF oTPanel1
	@ 29, 320 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT "Reiniciar Cadastro" SIZE 081, 008 OF oDlg COLORS 0, 16777215 PIXEL ON CHANGE MudaRepl(cAlias,nReg,nOpc)

	oGetDados := MSGetDados():New(0,0,0,0,nOpc,"U_BIA193OK()", ".T.","+Z31_SEQ",.T.)
	oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| IIF(TudoOk(), Mod2GrvI(),(RollbackSx8()) )},{|| RollbackSx8(),oDlg:End() })

	RestArea(aArea)
Return


Static Function TudoOk()

	Local lRet 			:= .T.
	Local nRateio 		:= 0
	Local nPosRateio  	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_RATEIO" } )
	Local nPosLoja  	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_LOJCLI" } )
	Local nPosEmp		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_CLVL" } )
	Local nI


	If !lLinhaOk
		lRet := U_BIA193OK()
	EndIf


	If lRet
		If Empty(cMatricula) .Or. Empty(cDesc)
			MsgStop("Cabeçalho da Tela Não Preenchido Corretamente. Preencha o Campo com a Matricula do(a) Consultor(a).","BIA193")
			lRet := .F.
		EndIf
	EndIf

	//########### CLASSE VALOR LM ###########
	If lRet
		For nI := 1 To Len(aCols)
			If !(aCOLS[nI, Len(aHeader)+1])

				If (AllTrim(cCodEmp) <> '07' .And. AllTrim(aCols[nI][nPosEmp]) $ '2155_2255')
					MsgStop("Classe de Valor (2155, 2255) Permitida Apenas para Empresa LM.","Verifique")
					lRet := .F.
					exit
				EndIf

			EndIf
		Next nI
	EndIf


	//###########VALIDAR SE O RATEIO ESTA DANDO 100%###########
	if(lRet)
		For nI := 1 to Len(aCols)
			If !aCOLS[nI, Len(aHeader)+1]		//LINHA DELETADA?
				nRateio := nRateio + aCols[nI][nPosRateio]
			EndIf
		Next nI
		If (nRateio != 100)
			MsgStop("Valor da Soma do Rateio Deve ser 100%.","Verifique")
			lRet := .F.
		EndIf
	EndIf
	//###########VALIDAR SE LOJA ESTA PREENCHIDA###########
	if(lRet)
		For nI := 1 to Len(aCols)
			If !aCOLS[nI, Len(aHeader)+1]		//LINHA DELETADA?
				If Trim(aCols[nI][nPosLoja])== ""
					MsgStop("Existe cliente sem loja.","Verifique")
					lRet := .F.
				EndIf
			EndIf
		Next nI
	EndIf

Return lRet


User Function BIA193OK()

	Local lRet			:= .T.
	Local nPosCodCli	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_CODCLI" } )
	Local nPosLojCli	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_LOJCLI" } )
	Local nPosEmp		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_CLVL" } )
	Local nPosRateio	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_RATEIO" } )
	Local cSQL
	Local nI

	lLinhaOk := .T.

	If !aCOLS[N, Len(aHeader)+1]

		//########### VALIDAR CLIENTES DUPLICADOS ###########
		If lRet
			For nI := 1 To Len(aCols)
				If !(aCOLS[nI, Len(aHeader)+1]) .And. (nI != N)		//LINHA DELETADA?
					If((Alltrim(aCols[nI][nPosCodCli]) == Alltrim(aCols[N][nPosCodCli])) .And. ;
							(Alltrim(aCols[nI][nPosLojCli]) == Alltrim(aCols[N][nPosLojCli])) .And. (aCols[nI][nPosEmp]) == aCols[N][nPosEmp])
						MsgStop("Cliente Já Cadastrado para Essa Empresa","Verifique")
						lRet := .F.
						exit
					EndIf
				EndIf
			Next nI
		EndIf

		//########### VALIDAR SE JA EXISTE CADASTRO PARA O CLIENTE NO PERIODO INFORMADO ###########
		If lRet
			cSQL :=" SELECT ISNULL (SUM(ISNULL(Z31_RATEIO,0)), 0) AS TOT_RATEIO FROM "+RetSQLName("Z31")+" Z31 " +ENTER
			cSQL += " WHERE "+ENTER
			cSQL += "(( Z31_DTINIC BETWEEN '"+DtoS(dGetDtIni)+"' AND '"+DtoS(dGetDtFim)+"' ) " +ENTER
			cSQL += " OR (Z31_DTFIM BETWEEN '"+DtoS(dGetDtIni)+"' AND '"+DtoS(dGetDtFim)+"')) "
			cSQL += " AND Z31_CODFUN = '"+cMatricula+"' "+ENTER
			cSQL += "AND Z31_CODIGO <> '"+cCodigo+"' AND Z31.D_E_L_E_T_ = '' "

			TCQUERY CSQL ALIAS "QRY" NEW

			If QRY->TOT_RATEIO + aCols[N][nPosRateio] > 100
				MsgStop("O Consultor(a) Ja Possui 100% de Rateio para o Periodo.","Verifique")
				lRet := .F.
			EndIf

			QRY->(DbCloseArea())
		EndIf
	EndIf
return lRet

Static Function Mod2GrvI()

	Local aArea := GetArea()
	Local cAlias := "Z31"

	Local i := 0
	Local y := 0

	dbSelectArea(cAlias)
	dbSetOrder(1)

	For i := 1 To Len( aCOLS )
		If !aCOLS[i, Len(aHeader)+1]

			RecLock(cAlias, .T.)

			For y := 1 To Len(aHeader)
				FieldPut(FieldPos(Trim(aHeader[y,2])), aCOLS[i,y])
			Next y

			(cAlias)->Z31_FILIAL 	:= xFilial(cAlias)
			(cAlias)->Z31_CODIGO 	:= cCodigo
			(cAlias)->Z31_CODFUN 	:= cMatricula
			(cAlias)->Z31_NOMFUN 	:= cDesc
			(cAlias)->Z31_SEQ 		:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_SEQ" } ) ]
			(cAlias)->Z31_CODCLI	:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_CODCLI" } ) ]
			(cAlias)->Z31_LOJCLI 	:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_LOJCLI" } ) ]
			(cAlias)->Z31_CLVL 		:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_CLVL" } ) ]
			(cAlias)->Z31_RATEIO 	:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_RATEIO" } ) ]
			(cAlias)->Z31_DTINIC 	:= dGetDtIni
			(cAlias)->Z31_DTFIM 	:= dGetDtFim
			(cAlias)->Z31_NOMCLI 	:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_NOMCLI" } ) ]
			(cAlias)->Z31_CODEMP 	:= cCodEmp

			MsUnLock()
		EndIf
	Next i

	ConfirmSX8()

	MsgInfo("Cadastro Concluido com Sucesso!","Cadastro Concluido")
	oDlg:End()

	RestArea(aArea)
Return


Static Function Mod2GrvA()

	Local aArea := GetArea()
	Local cAlias := "Z31"
	Local nI := 0
	Local nX := 0

	dbSelectArea(cAlias)

	For nI := 1 To Len( aCOLS )
		If nI <= Len( aREG )
			dbGoTo( aREG[nI] )
			RecLock(cAlias,.F.)
			If aCOLS[nI, Len(aHeader)+1]
				dbDelete()
			Endif
		Else
			RecLock(cAlias,.T.)
		Endif
		If !aCOLS[nI, Len(aHeader)+1]

			(cAlias)->Z31_FILIAL 	:= xFilial(cAlias)
			(cAlias)->Z31_CODIGO 	:= cCodigo
			(cAlias)->Z31_CODFUN 	:= cMatricula
			(cAlias)->Z31_NOMFUN 	:= cDesc
			(cAlias)->Z31_SEQ 		:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_SEQ" } ) ]
			(cAlias)->Z31_CODCLI	:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_CODCLI" } ) ]
			(cAlias)->Z31_LOJCLI 	:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_LOJCLI" } ) ]
			(cAlias)->Z31_CLVL 		:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_CLVL" } ) ]
			(cAlias)->Z31_RATEIO 	:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_RATEIO" } ) ]
			(cAlias)->Z31_DTINIC 	:= dGetDtIni
			(cAlias)->Z31_DTFIM 	:= dGetDtFim
			(cAlias)->Z31_NOMCLI 	:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_NOMCLI" } ) ]
			(cAlias)->Z31_CODEMP 	:= cCodEmp

			For nX := 1 To Len( aHeader )
				FieldPut( FieldPos( aHeader[nX, 2] ),aCOLS[nI, nX] )
			Next nX
		Endif
		MsUnLock()
	Next nI

	oDlg:End()
	RestArea( aArea )
Return


Static Function Mod2GrvE()

	Local aArea := GetArea()
	Local cChave := Z31->Z31_CODIGO
	Local cAlias := "Z31"

	dbSelectArea( cAlias )
	dbSetOrder(2)
	If dbSeek(cChave)

		If MsgYesNo("Confirma Excluisão do(a) Consultor(a) " +Alltrim(Z31->Z31_CODFUN)+"-"+Alltrim(cDesc)+"?","Confirma Exclusão?")

			While !EOF() .And. (cAlias)->Z31_CODIGO == cChave
				RecLock(cAlias,.F.)

				( cAlias )->(DbDelete())
				( cAlias )->(MsUnlock())

				DbSkip()
			EndDo
		EndIf
	EndIf

	oDlg:End()
	RestArea(aArea)

Return

Static Function Mod2aHeader( cAlias )

	Local aArea := GetArea()

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek( cAlias )

	While !EOF() .And. X3_ARQUIVO == cAlias

		If X3Uso(X3_USADO) .And. cNivel >= X3_NIVEL
			AADD( aHeader, { Trim( X3Titulo() ),;
				X3_CAMPO,;
				X3_PICTURE,;
				X3_TAMANHO,;
				X3_DECIMAL,;
				X3_VALID,;
				X3_USADO,;
				X3_TIPO,;
				X3_ARQUIVO,;
				X3_CONTEXT})
		Endif

		dbSkip()
	End

	RestArea(aArea)
Return

Static Function Mod2aCOLS( cAlias, nReg, nOpc )

	Local aArea := GetArea()
	Local cChave := Z31->Z31_CODIGO
	Local nI := 0

	If nOpc <> 3
		dbSelectArea( cAlias )
		dbSetOrder(2)
		dbSeek(cChave )
		While !EOF() .And. (cAlias)->( Z31_CODIGO ) == cChave
			AADD( aREG, (cAlias)->( RecNo() ) )
			AADD( aCOLS, Array( Len( aHeader ) + 1 ) )
			For nI := 1 To Len( aHeader )
				If aHeader[nI,10] == "V"
					aCOLS[Len(aCOLS),nI] := CriaVar(aHeader[nI,2],.T.)
				Else
					aCOLS[Len(aCOLS),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Endif
			Next nI
			aCOLS[Len(aCOLS),Len(aHeader)+1] := .F.
			dbSkip()
		End
	Else
		AADD( aCOLS, Array( Len( aHeader ) + 1 ) )
		For nI := 1 To Len( aHeader )
			aCOLS[1, nI] := CriaVar( aHeader[nI, 2], .T. )
		Next nI
		aCOLS[1, GdFieldPos("Z31_SEQ")] := "001"
		aCOLS[1, Len( aHeader )+1 ] := .F.
	Endif

	Restarea( aArea )
Return

User Function BIA193_MNT( cAlias, nReg, nOpc )

	Local oTPanel1
	Local aSizFrm := {}

	Private oDlg
	Private oGetDados
	Private cCodigo := (cAlias)->Z31_CODIGO
	Private cMatricula := ( cAlias )->Z31_CODFUN
	Private cDesc := ( cAlias )->Z31_NOMFUN
	Private oCheckBo1
	Private lCheckBo1 := .F.
	Private dGetDtIni := ( cAlias )->Z31_DTINIC
	Private dGetDtFim := ( cAlias )->Z31_DTFIM
	Private lLinhaOk := .F.		//SE NA ALTERACAO CLICAR DIRETAMENTE EM OK, O SISTEMA NAO VALIDA A LINHA

	Private cCodEmp := ( cAlias )->Z31_CODEMP

	Private aHeader := {}
	Private aCOLS := {}
	Private aREG := {}

	//Monta Tela
	aSizFrm := MsAdvSize()

	dbSelectArea( cAlias )
	dbGoTo( nReg )

	Mod2aHeader( cAlias )
	Mod2aCOLS( cAlias, nReg, nOpc )

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000, 000 TO aSizFrm[6]*80/110 ,aSizFrm[5]*80/110 COLORS 0, 15658734 PIXEL
	oTPanel1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,45,.T.,.F.)
	oTPanel1:Align := CONTROL_ALIGN_TOP

	@ 11, 006 SAY "Empresa:" SIZE 70,7 PIXEL OF oTPanel1
	@ 010, 035 MSCOMBOBOX oComboBo1 VAR cCodEmp ITEMS {"01=Biancogres","05=Incesa","07=LM"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 11, 112 SAY "Consultor(a):" SIZE 70,7 PIXEL OF oTPanel1
	@ 11, 230 SAY "Nome:" SIZE 70,7 PIXEL OF oTPanel1
	@ 10, 150 MSGET cMatricula When .F. PICTURE "@!" SIZE 050,7 PIXEL OF oTPanel1 F3 "SRABIA" VALID ValidaCadastro()
	@ 10, 250 MSGET cDesc PICTURE "@!" When .F. SIZE 200,7 PIXEL OF oTPanel1


	@ 29, 006 SAY "Data Inicio:" SIZE 70,7 PIXEL OF oTPanel1
	@ 29, 110 SAY "Data Final:" SIZE 70,7 PIXEL OF oTPanel1
	If nOpc == 4
		@ 28, 038 MSGET dGetDtIni SIZE 060, 010 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData()
		@ 28, 138 MSGET dGetDtFim SIZE 060, 010 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData()
	Else
		@ 28, 038 MSGET dGetDtIni When .F. SIZE 060, 010 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData()
		@ 28, 138 MSGET dGetDtFim When .F. SIZE 060, 010 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData()
	EndIf
	@ 29, 210 SAY "Codigo:" SIZE 70,7 PIXEL OF oTPanel1
	@ 29, 235 MSGET cCodigo When .F. SIZE 50,7 PIXEL OF oTPanel1
	@ 29, 320 CHECKBOX oCheckBo1 VAR lCheckBo1 When .F. PROMPT "Reiniciar Cadastro" SIZE 081, 008 OF oDlg COLORS 0, 16777215 PIXEL ON CHANGE MudaRepl(cAlias,nReg,nOpc)

	If nOpc == 4   //ATERACAO
		oGetDados := MSGetDados():New(0,0,0,0,nOpc,"U_BIA193OK()", ".T.","+Z31_SEQ",.T.)
	Else
		oGetDados := MSGetDados():New(0,0,0,0,nOpc)
	Endif
	oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	Do Case
	Case nOpc==4	//ATERACAO
		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| ( IIF(TudoOk(), Mod2GrvA(),(NIL) ))},{|| oDlg:End() })
	Case nOpc==5	//EXCLUSAO
		//ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| ( IIF(TudoOk(), Mod2GrvE(),(NIL) ))},{|| oDlg:End() })
		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg, {||Mod2GrvE()},{|| oDlg:End() })
	Otherwise
		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||  oDlg:End() },{|| oDlg:End() })
	End Case

Return

Static Function ValidaData()
	Local lRet := .T.
	If Empty(dGetDtIni) .Or. Empty(dGetDtFim)
		MsgStop("Preencha o Campo Data Inicio e Data Fim.","Verifique")
		lRet := .F.
	EndIf

	If lRet
		If(dGetDtFim < dGetDtIni)
			MsgStop("Data Final Informada Menor que a Data Incial.","Verifique")
			lRet := .F.
		EndIf
	EndIf

Return lRet

Static Function ValidaCadastro()
	Local aArea := GetArea()
	Local lRet := .T.

	IF TYPE ("hk_Retur1") != "U"
		If !Empty(hk_Retur1)
			cMatricula := hk_Retur1
			hk_Retur1 := ""
		EndIf
	endif
	IF TYPE ("hk_Retur2") != "U"
		If !Empty(hk_Retur2)
			cDesc := hk_Retur2
			hk_Retur2 := ""
		EndIf
	endif

	If lRet .And. !Empty(cMatricula)

		cSQL := " SELECT RA_MAT,RA_CLVL,RA_NOME,RA_CODFUNC "
		cSQL += " FROM VW_SENIOR_SRA SRA "
		cSQL += " WHERE SRA.CODEMP = '"+cCodEmp+"' AND SRA.RA_MAT  = '"+cMatricula+"' "
		cSQL += " ORDER BY RA_MAT "

		TcQuery cSQL New Alias "QRY"

		If !(Alltrim(QRY->RA_CLVL) $ cCLVLPVE)
			MsgStop("Matricula Informada não é de Consultor/Especificador de Vendas. Somente Matriculas Vinculadas as Classes de Valor: "+cCLVLPVE+" serão permitidas.","Verifique")
			lRet := .F.
		EndIf

		QRY->(dbCloseArea())

	EndIf

	If !lRet
		cMatricula 	:= Space(Len(Z31->Z31_CODFUN))
		cDesc 		:= Space(Len(Z31->Z31_NOMFUN))
	EndIf

	RestArea(aArea)

Return lRet

Static Function MudaRepl(cAlias, nReg, nOpc)


	If(Len(aCols) > 1 .Or. !Empty(aCols[1][2]) )
		If MsgYesNo("Já existe registros inseridos. Deseja Reiniciar Cadastro?","Confirmar?")
			aCOLS := {}
			Mod2aCOLS( cAlias, nReg, nOpc )
			lCheckBo1 := .F.
			oCheckBo1:Refresh()
			oGetDados:Refresh()
		EndIf
	Else
		lCheckBo1 := .F.
		oCheckBo1:Refresh()
	EndIf
Return


//DESCRICAO..: GATILHO PARA PREENCHER NOME DO CLIENTE NO ACOLS
USer Function Gati_Cliente()

	Local nPosNome 		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z31_NOMCLI" } )

	aCols[N][nPosNome] := Posicione("SA1",1,xFilial("SA1")+ SA1->A1_COD+SA1->A1_LOJA,"A1_NOME")
	oGetDados:Refresh()

Return .T.

//DESCRICAO..: LISTAR TODOS OS PROMOTORES CADASTRADOS
User Function BIA193_L()

	Local oButton2
	Local oListBox1
	Local nListBox1 := 1
	Local oSay1
	Local aItens := {}
	Local cSQL
	Static oDlg2

	cSQL :=" SELECT Z31_CODIGO FROM "+RetSQLName("Z31")+" Z31 " +ENTER
	cSQL += " WHERE "+ENTER
	cSQL += "Z31_CODFUN = '"+Z31->Z31_CODFUN+"' " +ENTER
	cSQL += " AND Z31.D_E_L_E_T_ = '' " +ENTER
	cSQL += " GROUP BY Z31_CODIGO" +ENTER
	cSQL += " ORDER BY Z31_CODIGO" +ENTER

	TCQUERY CSQL ALIAS "QRY2" NEW

	While !QRY2->(EOF())
		aadd(aItens,QRY2->Z31_CODIGO)
		QRY2->(DbSkip())
	EndDo
	QRY2->(DbCloseArea())

	DEFINE MSDIALOG oDlg2 TITLE "Filtrar Cadastros" FROM 000, 000  TO 250, 300 COLORS 0, 16777215 PIXEL

	@ 040, 049 LISTBOX oListBox1 VAR nListBox1 ITEMS aItens SIZE 060, 048 OF oDlg2 COLORS 0, 16777215 PIXEL
	@ 021, 005 SAY oSay1 PROMPT "Consultor(a): "+Z31->Z31_CODFUN+" - "+Alltrim(Z31->Z31_NOMFUN)+" " SIZE 139, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
	@ 104, 061 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg2 ACTION oDlg2:End() PIXEL

	ACTIVATE MSDIALOG oDlg2 CENTERED

Return

//DESCRICAO..: CONSULTA PADRAO CUSTOMIZADA
User Function F3_SRA_UNI()

	Local aArea   := GetArea()

	Private oDlgTab
	Private oGet1
	Private cGet1 := Space(45)
	Private oRadMenu1
	Private nRadMenu1 := 1
	Private Pesquisar
	Private Retornar
	Private nX
	Private aHeaderEx := {}
	Private aColsEx := {}
	Private aFieldFill := {}
	Private aFields := {"RA_MAT","RA_NOME","RA_CLVL","RA_CODFUNC","RJ_DESC"}
	Private oMSNewGetDados1
	Public hk_Retur1 := ""
	Public hk_Retur2 := ""

	DEFINE MSDIALOG oDlgTab TITLE "Cadastro de Funcionarios" FROM 000, 000  TO 540, 600 COLORS 0, 16777215 PIXEL

	fMSNewGetDados1()
	@ 216, 005 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Matricula","Nome" SIZE 071, 026 OF oDlgTab COLOR 0, 16777215 ON CHANGE wMudOrd() PIXEL
	@ 248, 005 MSGET oGet1 VAR cGet1 SIZE 197, 015 OF oDlgTab COLORS 0, 16777215 PIXEL
	@ 231, 208 BUTTON Pesquisar PROMPT "Pesquisar" SIZE 037, 032 OF oDlgTab ACTION( wRetCodCl() ) PIXEL
	@ 231, 255 BUTTON Retornar PROMPT "Retornar" SIZE 037, 032 OF oDlgTab ACTION( wRtCodSel() ) PIXEL
	ACTIVATE MSDIALOG oDlgTab

	n := 1
	RestArea( aArea )

Return .T.

Static Function fMSNewGetDados1()

	Local nX

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	A0001 := " SELECT RA_DEMISSA,RA_MAT,RA_CLVL,RA_NOME,RA_CODFUNC,RJ_DESC "
	A0001 += " FROM VW_SENIOR_SRA SRA "
	A0001 += " WHERE SRA.CODEMP = '"+cCodEmp+"' "

	If !(AllTrim(FunName()) $ "BIA193_FPVETE04")
		A0001 += " AND SRA.RA_DEMISSA = ''  "
	EndIf

	A0001 += "  AND RA_CLVL IN ('" + StrTran(cCLVLPVE,"/","','") + "') "
	A0001 += " ORDER BY RA_MAT"

	TcQuery A0001 New Alias "A001"

	dbSelectArea("A001")
	dbGoTop()

	ProcRegua(RecCount())
	While !Eof()
		Aadd(aFieldFill, {A001->RA_MAT, A001->RA_NOME , A001->RA_CLVL, A001->RA_CODFUNC, A001->RJ_DESC, .F. })
		dbSelectArea("A001")
		dbSkip()
	End
	A001->(dbCloseArea())

	If Len(aFieldFill) == 0
		SX3->(dbSetOrder(2))
		For nX := 1 to Len(aFields)
			If SX3->(dbSeek(aFields[nX]))
				Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	Else
		aColsEx := aFieldFill
	EndIf

	oMSNewGetDados1 := MsNewGetDados():New( 005, 005, 213, 294, , , , , , , 999, , , , oDlgTab, aHeaderEx, aColsEx)

	oMsNewGetDados1:oBrowse:bLDblClick := {||wRtCodSel() }

Return

Static Function wRetCodCl()

	jk_Tam := Len(Alltrim(cGet1))
	nPos   := 0
	If Len(aColsEx) > 1
		If nRadMenu1 == 1
			nPos := aScan(aColsEx,{|x| Substr(x[1], 1, jk_Tam) == Substr(cGet1, 1, jk_Tam) })
		ElseIf nRadMenu1 == 2
			nPos := aScan(aColsEx,{|x| Substr(x[2], 1, jk_Tam) == Substr(cGet1, 1, jk_Tam) })
		EndIf
		If nPos <> 0
			n:=nPos
			oMSNewGetDados1:oBrowse:nAt:=nPos
			oMSNewGetDados1:oBrowse:Refresh()
			oMSNewGetDados1:oBrowse:SetFocus()
		EndIf
	EndIf

Return

Static Function wMudOrd()

	If Len(aColsEx) > 1
		If nRadMenu1 == 1
			aColsEx := aSort(aColsEx,,,{|x,y| x[1] < y[1] })
		ElseIf nRadMenu1 == 2
			aColsEx := aSort(aColsEx,,,{|x,y| x[2] < y[2] })
		EndIf
		oMSNewGetDados1:ACOLS := aColsEx
		oMSNewGetDados1:oBrowse:Refresh()
		oMSNewGetDados1:oBrowse:SetFocus()
	EndIf

Return

Static Function wRtCodSel()

	hk_Retur1 := oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][1]
	hk_Retur2 := oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][2]
	oDlgTab:End()

Return
