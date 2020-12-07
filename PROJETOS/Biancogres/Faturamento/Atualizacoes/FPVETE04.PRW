#Include "PROTHEUS.CH"
#Include "TopConn.ch"

/*/{Protheus.doc} FPVETE04
@description Cliente X Promotores - Rateio do Sell Out - baseado do programa BIA193
@author Fernando Rocha
@since 03/02/2017
@version undefined
@type function
/*/

User Function FPVETE04()

	Local aCores := {}  
	Local cAlias := "Z85"
	PRIVATE ENTER := CHR(13)+CHR(10) 

	Private cCadastro := "Amarração Consultores de Vendas x Clientes x Empresa SELL OUT"
	Private cCodFunc := GetMv( "MV_YBIA193")	//CODIGO DE FUNCOES QUE SAO DE PROMOTORES (CADASTRADO NA TABELA SRA)
	Private cCodFuncI := GetMv( "MV_BIA193I")	//CODIGO DE FUNCOES QUE SAO DE PROMOTORES - INCESA

	Private cCLVLPVE := GetNewPar("FA_CLVLPVE", "2116/2156/2115/2215/2155/2255")
	
	cCodFuncI := cCodFunc 

	Private aRotina   := {	{"Pesquisar"    	,"AxPesqui"     	,0,1},;
	{"Visualizar"  			,"U_FPVE04_MNT"	,0,2},;
	{"Incluir"	     		,"U_FPVE04_I"	,0,3},;
	{"Alterar"  	   		,"U_FPVE04_MNT"	,0,4},;
	{"Excluir"				,"U_FPVE04_MNT"	,0,5},;
	{"Listar Cadastrados"	,"U_FPVE04_L"	,0,6}}

	(cAlias)->(DbSetOrder(1))
	(cAlias)->(DbGoTop())

	(cAlias)->(MBROWSE(6,1,22,75,cAlias,,,,,,aCores))

Return            

/*/{Protheus.doc} FPVE04_I
@description TELA PARA INCLUSAO DAS AMARRACOES MODELO 2
@author Fernando Rocha
@since 03/02/2017
@version undefined
@param cAlias, characters, descricao
@param nReg, numeric, descricao
@param nOpc, numeric, descricao
@type function
/*/
User Function FPVE04_I(cAlias, nReg, nOpc)  

	Local aArea		:= GetArea()
	Local oTPanel1
	Local aSizFrm	:= {}   
	Local oSay2
	Local aListaEmp	:= {"01=Biancogres","05=Incesa","07=LM"}

	Private oDlg            
	Private oGetDados
	Private cCodigo
	Private cMatricula := Space(Len(( cAlias )->Z85_CODFUN))
	Private cDesc := Space(Len(( cAlias )->Z85_NOMFUN))  
	Private oCheckBo1
	Private lCheckBo1 := .F.
	Private dGetDtIni := Date()
	Private dGetDtFim := Date() 
	Private lLinhaOk := .F.		//SE NA ALTERACAO CLICAR DIRETAMENTE EM OK, O SISTEMA NAO VALIDA A LINHA
	Private cCodStep	:= Space(Len(( cAlias )->Z85_CODSTE))
	Private cDescStep	:= Space(TAMSX3("Z85_DESSTE")[1])

	Private cCodEmp := Space(Len(( cAlias )->Z85_CODEMP))

	Private aHeader := {}
	Private aCOLS := {}
	Private aREG := {}  


	//Monta Tela     
	aSizFrm := MsAdvSize() 

	dbSelectArea( cAlias )
	dbSetOrder(1)
	Mod2aHeader( cAlias )
	Mod2aCOLS( cAlias, nReg, nOpc )

	///Numeracao automatica
	cCodigo := GetSxeNum("Z85","Z85_CODIGO")
	ConfirmSX8()

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000, 000 TO aSizFrm[6]*80/110 ,aSizFrm[5]*80/110 COLORS 0, 15658734 PIXEL                    
	oTPanel1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,54,.T.,.F.)                    
	oTPanel1:Align := CONTROL_ALIGN_TOP

	@ 11, 006 SAY "Empresa:" SIZE 70,7 PIXEL OF oTPanel1
	@ 010, 035 MSCOMBOBOX oComboBo1 VAR cCodEmp ITEMS aListaEmp SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 11, 112 SAY "Consultor(a):" SIZE 70,7 PIXEL OF oTPanel1 
	@ 11, 230 SAY "Nome:" SIZE 70,7 PIXEL OF oTPanel1  
	@ 10, 150 MSGET cMatricula PICTURE "@!" SIZE 050,7 PIXEL OF oTPanel1 F3 "SRABIA" VALID ValidaCadastro()
	@ 10, 250 MSGET cDesc PICTURE "@!" When .F. SIZE 200,7 PIXEL OF oTPanel1

	@ 26, 006 SAY "Código Step:" SIZE 70,7 PIXEL OF oTPanel1 
	@ 26, 112 SAY "Nome Step:" SIZE 70,7 PIXEL OF oTPanel1  
	@ 25, 045 MSGET cCodStep PICTURE "@!" SIZE 050,7 PIXEL OF oTPanel1 F3 "ZAE" VALID ValidaStep()
	@ 25, 150 MSGET cDescStep PICTURE "@!" When .F. SIZE 200,7 PIXEL OF oTPanel1

	@ 41, 006 SAY "Data Inicio:" SIZE 70,7 PIXEL OF oTPanel1 
	@ 39, 038 MSGET dGetDtIni SIZE 070, 09 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData()
	@ 41, 110 SAY "Data Final:" SIZE 70,7 PIXEL OF oTPanel1 
	@ 39, 138 MSGET dGetDtFim SIZE 070, 09 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData()

	@ 40, 210 SAY "Codigo:" SIZE 70,7 PIXEL OF oTPanel1
	@ 39, 235 MSGET cCodigo When .F. SIZE 50,7 PIXEL OF oTPanel1

	oGetDados := MSGetDados():New(0,0,0,0,nOpc,"U_FPVE04OK()", ".T.","+Z85_SEQ",.T.)
	oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| IIF(TudoOk(), Mod2GrvI(),(RollbackSx8()) )},{|| RollbackSx8(),oDlg:End() })	

	RestArea(aArea)
Return     


Static Function TudoOk()

	Local lRet 			:= .T.
	Local nRateio 		:= 0
	Local nPosRateio  	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_RATEIO" } )
	Local nPosLoja  	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_LOJCLI" } )
	Local nPosEmp		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_CLVL" } )
	Local nI


	If !lLinhaOk
		lRet := U_FPVE04OK()
	EndIf 

	If lRet
		If Empty(cMatricula) .Or. Empty(cDesc)
			MsgStop("Cabeçalho da Tela Não Preenchido Corretamente. Preencha o Campo com a Matricula do(a) Consultor(a).","FPVE04")
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If Empty(cCodStep)
			MsgStop("Cabeçalho da Tela Não Preenchido Corretamente. Preencha o Campo Step.","FPVE04")
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



User Function FPVE04OK() 

	Local lRet			:= .T.  
	Local nPosCodCli	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_CODCLI" } )
	Local nPosLojCli	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_LOJCLI" } )  
	Local nPosRateio	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_RATEIO" } )
	Local nPosEmp		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_CLVL" } )
	Local nI

	Local cSQL

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
			cSQL :=" SELECT ISNULL (SUM(ISNULL(Z85_RATEIO,0)), 0) AS TOT_RATEIO FROM "+RetSQLName("Z85")+" Z85 " +ENTER		
			cSQL += " WHERE "+ENTER 
			cSQL += "(( Z85_DTINIC BETWEEN '"+DtoS(dGetDtIni)+"' AND '"+DtoS(dGetDtFim)+"' ) " +ENTER
			cSQL += " OR (Z85_DTFIM BETWEEN '"+DtoS(dGetDtIni)+"' AND '"+DtoS(dGetDtFim)+"')) " 
			cSQL += " AND Z85_CODFUN = '"+cMatricula+"' "+ENTER
			cSQL += "AND Z85_CODIGO <> '"+cCodigo+"' AND Z85.D_E_L_E_T_ = '' "

			TCQUERY CSQL ALIAS "QRY" NEW

			If QRY->TOT_RATEIO + aCols[N][nPosRateio] > 100
				MsgStop("O Consultor(a) Ja Possui 100% de Rateio para o Periodo.","Verifique")
				lRet := .F.
			EndIf

			QRY->(DbCloseArea())		 
		EndIf
	EndIf       
return lRet      


/*/{Protheus.doc} Mod2GrvI
@description Gravar Dados
@author Fernando Rocha
@since 03/02/2017
@version undefined
@type function
/*/
Static Function Mod2GrvI() 

	Local aArea := GetArea()
	Local cAlias := "Z85"  

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

			(cAlias)->Z85_FILIAL 	:= xFilial(cAlias)
			(cAlias)->Z85_CODIGO 	:= cCodigo
			(cAlias)->Z85_CODFUN 	:= cMatricula
			(cAlias)->Z85_NOMFUN 	:= cDesc 
			(cAlias)->Z85_SEQ 		:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_SEQ" } ) ]
			(cAlias)->Z85_CODCLI	:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_CODCLI" } ) ]
			(cAlias)->Z85_LOJCLI 	:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_LOJCLI" } ) ]
			(cAlias)->Z85_CLVL 		:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_CLVL" } ) ]
			(cAlias)->Z85_RATEIO 	:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_RATEIO" } ) ]		
			(cAlias)->Z85_DTINIC 	:= dGetDtIni
			(cAlias)->Z85_DTFIM 	:= dGetDtFim
			(cAlias)->Z85_NOMCLI 	:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_NOMCLI" } ) ]
			(cAlias)->Z85_CODEMP 	:= cCodEmp
			(cAlias)->Z85_CODSTE 	:= cCodStep


			MsUnLock()
		EndIf  
	Next i

	MsgInfo("Cadastro Concluido com Sucesso!","Cadastro Concluido") 
	oDlg:End()

	RestArea(aArea)
Return    

/*/{Protheus.doc} Mod2GrvA
@description Alteracao
@author Fernando Rocha
@since 03/02/2017
@version undefined
@type function
/*/
Static Function Mod2GrvA()

	Local aArea := GetArea()
	Local cAlias := "Z85"
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

			(cAlias)->Z85_FILIAL 	:= xFilial(cAlias)
			(cAlias)->Z85_CODIGO 	:= cCodigo
			(cAlias)->Z85_CODFUN 	:= cMatricula
			(cAlias)->Z85_NOMFUN 	:= cDesc 
			(cAlias)->Z85_SEQ 		:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_SEQ" } ) ]
			(cAlias)->Z85_CODCLI	:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_CODCLI" } ) ]
			(cAlias)->Z85_LOJCLI 	:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_LOJCLI" } ) ]
			(cAlias)->Z85_CLVL 		:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_CLVL" } ) ]
			(cAlias)->Z85_RATEIO 	:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_RATEIO" } ) ]
			(cAlias)->Z85_DTINIC 	:= dGetDtIni
			(cAlias)->Z85_DTFIM 	:= dGetDtFim
			(cAlias)->Z85_NOMCLI 	:= aCols[nI][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z85_NOMCLI" } ) ]
			(cAlias)->Z85_CODEMP 	:= cCodEmp
			(cAlias)->Z85_CODSTE 	:= cCodStep

			For nX := 1 To Len( aHeader )
				FieldPut( FieldPos( aHeader[nX, 2] ),aCOLS[nI, nX] )
			Next nX
		Endif
		MsUnLock()
	Next nI

	oDlg:End()
	RestArea( aArea )
Return    


/*/{Protheus.doc} Mod2GrvE
@description Exclusao
@author Fernando Rocha
@since 03/02/2017
@version undefined

@type function
/*/
Static Function Mod2GrvE()

	Local aArea := GetArea()
	Local cChave := Z85->Z85_CODIGO
	Local cAlias := "Z85"

	dbSelectArea( cAlias )
	dbSetOrder(2)

	If dbSeek(cChave)

		If MsgYesNo("Confirma Excluisão do(a) Consultor(a) " +Alltrim(Z85->Z85_CODFUN)+"-"+Alltrim(cDesc)+"?","Confirma Exclusão?")

			While !EOF() .And. (cAlias)->Z85_CODIGO == cChave
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
	Local cChave := Z85->Z85_CODIGO
	Local nI := 0          

	If nOpc <> 3
		dbSelectArea( cAlias )
		dbSetOrder(2)
		dbSeek(cChave )

		While !EOF() .And. (cAlias)->( Z85_CODIGO ) == cChave
			AADD( aREG, (cAlias)->( RecNo() ) )
			AADD( aCOLS, Array( Len( aHeader ) + 1 ) )
			For nI := 1 To Len( aHeader )

				If AllTrim(aHeader[nI,2]) == "Z85_NOMCLI"

					SA1->(DbSetOrder(1))
					IF SA1->(DbSeek(XFilial("SA1")+(cAlias)->(Z85_CODCLI+Z85_LOJCLI)))
						aCOLS[Len(aCOLS),nI] := SA1->A1_YNLOJA
					ENDIF			

				ElseIf aHeader[nI,10] == "V"
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
		aCOLS[1, GdFieldPos("Z85_SEQ")] := "001"
		aCOLS[1, Len( aHeader )+1 ] := .F.
	Endif                   

	Restarea( aArea )
Return


User Function FPVE04_MNT( cAlias, nReg, nOpc )   

	Local aArea := GetArea()
	Local oTPanel1
	Local aSizFrm := {}   
	Local oSay2
	Local aListaEmp	:= {"01=Biancogres","05=Incesa","07=LM"}


	Private oDlg            
	Private oGetDados
	Private cCodigo := (cAlias)->Z85_CODIGO
	Private cMatricula := ( cAlias )->Z85_CODFUN
	Private cDesc := ( cAlias )->Z85_NOMFUN 
	Private oCheckBo1
	Private lCheckBo1 := .F.
	Private dGetDtIni := ( cAlias )->Z85_DTINIC
	Private dGetDtFim := ( cAlias )->Z85_DTFIM 
	Private lLinhaOk := .F.		//SE NA ALTERACAO CLICAR DIRETAMENTE EM OK, O SISTEMA NAO VALIDA A LINHA    
	Private cCodStep	:= (cAlias)->Z85_CODSTE
	Private cDescStep	:= FDESC('ZAE',cCodStep,'ZAE_DESC',TAMSX3('ZAE_DESC'), XFILIAL("ZAE")) //(cAlias)->Z85_DESSTE

	Private cCodEmp := ( cAlias )->Z85_CODEMP

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
	oTPanel1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,52,.T.,.F.)                    
	oTPanel1:Align := CONTROL_ALIGN_TOP

	@ 11, 006 SAY "Empresa:" SIZE 70,7 PIXEL OF oTPanel1
	@ 010, 035 MSCOMBOBOX oComboBo1 VAR cCodEmp ITEMS aListaEmp SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 11, 112 SAY "Consultor(a):" SIZE 70,7 PIXEL OF oTPanel1 
	@ 11, 230 SAY "Nome:" SIZE 70,7 PIXEL OF oTPanel1  
	@ 10, 150 MSGET cMatricula When .F. PICTURE "@!" SIZE 050,7 PIXEL OF oTPanel1 F3 "SRABIA" VALID ValidaCadastro()
	@ 10, 250 MSGET cDesc PICTURE "@!" When .F. SIZE 200,7 PIXEL OF oTPanel1

	@ 26, 006 SAY "Código Step:" SIZE 70,7 PIXEL OF oTPanel1 
	@ 26, 112 SAY "Nome Step:" SIZE 70,7 PIXEL OF oTPanel1  
	If nOpc == 4	 
		@ 25, 045 MSGET cCodStep PICTURE "@!" SIZE 050,7 PIXEL OF oTPanel1 F3 "ZAE" VALID ValidaStep()
	Else
		@ 25, 045 MSGET cCodStep When .F. PICTURE "@!" SIZE 050,7 PIXEL OF oTPanel1 F3 "ZAE" VALID ValidaStep()
	EndIf
	@ 25, 150 MSGET cDescStep PICTURE "@!" When .F. SIZE 200,7 PIXEL OF oTPanel1


	@ 41, 006 SAY "Data Inicio:" SIZE 70,7 PIXEL OF oTPanel1 
	@ 39, 110 SAY "Data Final:" SIZE 70,7 PIXEL OF oTPanel1
	If nOpc == 4	 
		@ 41, 038 MSGET dGetDtIni SIZE 060, 09 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData() 
		@ 39, 138 MSGET dGetDtFim SIZE 060, 09 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData()
	Else
		@ 41, 038 MSGET dGetDtIni When .F. SIZE 060, 09 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData() 
		@ 39, 138 MSGET dGetDtFim When .F. SIZE 060, 09 OF oTPanel1 COLORS 0, 16777215 PIXEL VALID ValidaData()
	EndIf

	@ 41, 210 SAY "Codigo:" SIZE 70,7 PIXEL OF oTPanel1
	@ 39, 235 MSGET cCodigo When .F. SIZE 50,7 PIXEL OF oTPanel1

	If nOpc == 4   //ATERACAO
		oGetDados := MSGetDados():New(0,0,0,0,nOpc,"U_FPVE04OK()", ".T.","+Z85_SEQ",.T.)
	Else
		oGetDados := MSGetDados():New(0,0,0,0,nOpc)
	Endif
	oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	Do Case
		Case nOpc==4	//ATERACAO
		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| ( IIF(TudoOk(), Mod2GrvA(),(NIL) ))},{|| oDlg:End() })
		Case nOpc==5	//EXCLUSAO
		//ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(k,{|| ( IIF(TudoOk(), Mod2GrvE(),(NIL) ))},{|| oDlg:End() })
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
	/*
	If lRet
	If(dGetDtIni < dDatabase)
	MsgStop("Data Inicial Informada Menor que a Database do Sistema.","Verifique")
	lRet := .F.
	EndIf
	EndIf
	If lRet
	If(dGetDtFim < dDatabase)
	MsgStop("Data Final Informada Menor que a Database do Sistema.","Verifique")
	lRet := .F.
	EndIf
	EndIf
	*/
	If lRet
		If(dGetDtFim < dGetDtIni)
			MsgStop("Data Final Informada Menor que a Data Incial.","Verifique")
			lRet := .F.
		EndIf
	EndIf

Return lRet

Static Function ValidaStep()
	Local aArea := GetArea()
	Local lRet := .T.  

	cDescStep := FDESC('ZAE',cCodStep,'ZAE_DESC',TAMSX3('ZAE_DESC'), XFILIAL("ZAE"))

	RestArea(aArea)

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
		cSQL += " FROM VW_SENIOR_SRA SRA			"
		cSQL += "  WHERE CODEMP = '"+cCodEmp+"' AND RA_MAT  = '"+cMatricula+"' AND SRA.D_E_L_E_T_='' "
		cSQL += " ORDER BY RA_MAT"     

		TcQuery cSQL New Alias "QRY"

		If cCodEmp == '01'
			If !(Alltrim(QRY->RA_CODFUNC) $ cCodFunc) 
				MsgStop("Matricula Informada não é de Consultor de Vendas. Somente Matriculas Vinculadas as Funções "+cCodFunc+" Serão Permitido.","Verifique")
				lRet := .F.
			EndIf
		EndIf             
		If cCodEmp == '05'
			If !(Alltrim(QRY->RA_CODFUNC) $ cCodFuncI) 
				MsgStop("Matricula Informada não é de Consultor de Vendas. Somente Matriculas Vinculadas as Funções "+cCodFuncI+" Serão Permitido.","Verifique")
				lRet := .F.
			EndIf
		EndIf
		If cCodEmp == '07'
			If !(Alltrim(QRY->RA_CODFUNC) $ cCodFuncI) 
				MsgStop("Matricula Informada não é de Consultor de Vendas. Somente Matriculas Vinculadas as Funções "+cCodFuncI+" Serão Permitido.","Verifique")
				lRet := .F.
			EndIf
		EndIf

		cDesc := QRY->RA_NOME

		QRY->(dbCloseArea())

	EndIf	

	If !lRet
		cMatricula 	:= Space(Len(Z85->Z85_CODFUN))
		cDesc 		:= Space(Len(Z85->Z85_NOMFUN))  
	EndIf

	RestArea(aArea)

Return lRet         


User Function FPVE04_L()

	Local oButton2
	Local oListBox1
	Local nListBox1 := 1
	Local oSay1
	Local aItens := {}
	Local cSQL
	Static oDlg2

	cSQL :=" SELECT Z85_CODIGO FROM "+RetSQLName("Z85")+" Z85 " +ENTER		
	cSQL += " WHERE "+ENTER 
	cSQL += "Z85_CODFUN = '"+Z85->Z85_CODFUN+"' " +ENTER
	cSQL += " AND Z85.D_E_L_E_T_ = '' " +ENTER
	cSQL += " GROUP BY Z85_CODIGO" +ENTER
	cSQL += " ORDER BY Z85_CODIGO" +ENTER

	TCQUERY CSQL ALIAS "QRY2" NEW

	While !QRY2->(EOF())
		aadd(aItens,QRY2->Z85_CODIGO)
		QRY2->(DbSkip())	
	EndDo	
	QRY2->(DbCloseArea())

	DEFINE MSDIALOG oDlg2 TITLE "Filtrar Cadastros" FROM 000, 000  TO 250, 300 COLORS 0, 16777215 PIXEL

	@ 040, 049 LISTBOX oListBox1 VAR nListBox1 ITEMS aItens SIZE 060, 048 OF oDlg2 COLORS 0, 16777215 PIXEL
	@ 021, 005 SAY oSay1 PROMPT "Consultor(a): "+Z85->Z85_CODFUN+" - "+Alltrim(Z85->Z85_NOMFUN)+" " SIZE 139, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
	@ 104, 061 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg2 ACTION oDlg2:End() PIXEL

	ACTIVATE MSDIALOG oDlg2 CENTERED

Return
