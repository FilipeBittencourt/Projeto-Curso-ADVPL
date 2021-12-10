#Include "PROTHEUS.CH"
#Include "TopConn.ch"

/*
##############################################################################################################
# PROGRAMA...: BIA191
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 12/03/2014
# DESCRICAO..: TELA MODELO 2 PARA AMARRACAO WORKFLOW X EMAILS
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/

User Function BIA191()

	Local aArea := ZZ8->(GetArea())
	Private oBrowse
	Private cCadastro := "Amarração Workflow x Emails"
	Private lCtrlAdm  := .F.
	Private lCtrlInd  := .F.

	Private aRotina

	If PswSeek( __cUserID, .T. )

		aArray := PSWRET()
		If aScan(aArray[1][10],'000000') > 0

			lCtrlAdm := .T.

		Else

			lCtrlInd := .F.
			If U_ValOper("I01", .F.)
				lCtrlInd := .T.
			EndIf

		EndIf

	EndIf

	If lCtrlAdm

		aRotina   := { {"Pesquisar"    	,"AxPesqui"    	,0,1},;
		{               "Visualizar"  	,"U_BIA191_MNT"	,0,2},;
		{               "Incluir"	    ,"U_BIA191_I"	,0,3},;
		{               "Alterar"  	   	,"U_BIA191_MNT"	,0,4},;
		{               "Excluir"		,"U_BIA191_E"	,0,5} }

	ElseIf lCtrlInd

		aRotina   := { {"Pesquisar"    	,"AxPesqui"    	,0,1},;
		{               "Visualizar"  	,"U_BIA191_MNT"	,0,2},;
		{               "Incluir"	    ,"U_BIA191_I"	,0,3},;
		{               "Alterar"  	   	,"U_BIA191_MNT"	,0,4} }

	ElseIf (FWIsAdmin(__cUserID))
		aRotina   := { {"Pesquisar"    	,"AxPesqui"    	,0,1},;
				{               "Visualizar"  	,"U_BIA191_MNT"	,0,2},;
				{               "Incluir"	    ,"U_BIA191_I"	,0,3},;
				{               "Alterar"  	   	,"U_BIA191_MNT"	,0,4},;
				{               "Excluir"		,"U_BIA191_E"	,0,5} }
	Else

		MsgALERT("Você não tem acesso para prosseguir a partir deste ponto! Abra ticket para ter acesso à rotina BIA191 se necessitar realmente a esta rotina.", "Atenção")
		Return

	EndIf

	//Iniciamos a construção básicMARCOS_S	a de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("Z28")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	If lCtrlInd
		oBrowse:SetFilterDefault( "Z28_ROTINA = 'BIAFG101            '" )
	EndIf

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)	

Return            

/*
##############################################################################################################
# PROGRAMA...: FEXPTE06_I
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 12/02/2014
# DESCRICAO..: TELA PARA INCLUSAO DE ROTAS MODELO 2
##############################################################################################################
*/
User Function BIA191_I(cAlias, nReg, nOpc)  

	Local aArea := GetArea()
	Local oTPanel1
	Local aSizFrm := {}   
	Local oSay1

	Private oDlg            
	Private oGetDados
	Private cCodigo := Space(Len(Z28->Z28_ROTINA))
	Private cDesc := Space(Len(Z28->Z28_DESCRI)) 
	Private oComboBox
	Private cComboBox := 'Sim'
	//Private cEmail := Space(Len(Z28->Z28_EMAIL)) 

	Private aHeader := {}
	Private aCOLS := {}
	Private aREG := {}  

	If !lCtrlAdm .And. !FWIsAdmin(__cUserID)

		MsgSTOP("Somente ADMINISTRADOR pode utilizar esta opção.")
		Return

	EndIf

	//Monta Tela     
	aSizFrm := MsAdvSize() 

	dbSelectArea( cAlias )
	dbSetOrder(1)
	Mod2aHeader( cAlias )
	Mod2aCOLS( cAlias, nReg, nOpc )

	//	DEFINE MSDIALOG oDlg TITLE cCadastro From 8,0 To 28,80 OF oMainWnd
	//DEFINE MSDIALOG oDlg TITLE cCadastro From 8,0 To 48,160 OF oMainWnd  
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000, 000 TO aSizFrm[6]*80/110 ,aSizFrm[5]*80/110 COLORS 0, 15658734 PIXEL                    
	oTPanel1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,45,.T.,.F.)                    
	oTPanel1:Align := CONTROL_ALIGN_TOP

	@ 4, 006 SAY "Rotina:" SIZE 70,7 PIXEL OF oTPanel1 
	@ 4, 110 SAY "Descricao" SIZE 70,7 PIXEL OF oTPanel1  
	@ 3, 026 MSGET cCodigo PICTURE "@!" SIZE 070,7 PIXEL OF oTPanel1 VALID ValidaRotina()
	@ 3, 140 MSGET cDesc PICTURE "@!" SIZE 220,7 PIXEL OF oTPanel1

	@ 21, 006 SAY oSay1 PROMPT "Replicar para Todas Empresas?" SIZE 081, 007 OF oTPanel1 COLORS 0, 16777215 PIXEL
	@ 20, 090 MSCOMBOBOX oComboBox VAR cComboBox ITEMS {"Sim","Nao"} SIZE 045, 010 OF oTPanel1 COLORS 0, 16777215 PIXEL ON CHANGE MudaRepl(cAlias,nReg,nOpc) 

	//   	@ 21, 150 SAY oSay2 PROMPT "Incluir em Todos os Emails" SIZE 071,7 OF oTPanel1 COLORS 0, 16777215 PIXEL
	// 	@ 20, 215 MSGET cEmail SIZE 250,7 PIXEL OF oTPanel1

	oGetDados := MSGetDados():New(0,0,0,0,nOpc,"U_BIA191OK()", ".T.","+Z28_SEQ",.T.)
	oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| IIF(TudoOk(), Mod2GrvI(),(NIL) )},{|| oDlg:End() })	

	RestArea(aArea)

Return     

/*
##############################################################################################################
# PROGRAMA...: TudoOk
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 13/03/2014                      
# DESCRICAO..: TUDO OK 
##############################################################################################################
*/
Static Function TudoOk()
	Local lRet := .T.

	If Empty(cCodigo) .Or. Empty(cDesc)
		MsgStop("Cabeçalho da Tela Não Preenchido Corretamente. Preencha o Campo Rotina/Descrição.","Verifique")
		lRet := .F.
	EndIf
	/*If lRet
	If !(Empty(cEmail)) .And. !("@" $ cEmail)
	MsgStop("Verifique o Campo EMAIL no Cabeçalho da Tela.","Verifique")
	lRet := .F.
	EndIf
	EndIf
	*/

Return lRet

/*
##############################################################################################################
# PROGRAMA...: FEXPLOK
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 12/02/2014                      
# DESCRICAO..: LINHA OK 
##############################################################################################################
*/
User Function BIA191OK() 

	Local lRet			:= .T.  
	Local nPosEmp  		:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z28_EMPRES" } ) 
	Local nPosEmail  	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z28_EMAIL" } ) 
	Local nPosClasse 	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "Z28_CLASSE" } )
	local nI 

	If !aCOLS[N, Len(aHeader)+1]		//LINHA DELETADA?
		//VALIDAR CAMPO EMPRESA
		If cComboBox == "Sim" 
			If (!Empty(aCols[N][nPosEmp]))
				MsgStop("Campo Empresa Não Precisa ser Informado, Pois o Cadastro Será Replicado.","Verifique")
				lRet := .F.  
			EndIf
		Else
			If (Empty(aCols[N][nPosEmp]))
				MsgStop("Campo Empresa Precisa ser Informado, Pois o Cadastro Não Será Replicado.","Verifique")
				lRet := .F.  
			EndIf
		EndIf     
		//VALIDAR CAMPO EMAIL	
		If lRet    
			If !("@" $ aCols[N][nPosEmail])
				MsgStop("Verifique o Campo Email.","Verifique")
				lRet := .F.  
			EndIf
		EndIf              
		//VALIDAR CADASTROS DUPLICADOS	
		If lRet       
			For nI := 1 To Len(aCols)
				If !(aCOLS[nI, Len(aHeader)+1]) .And. (nI != N)		//LINHA DELETADA?
					If(UPPER(Alltrim(aCols[nI][nPosEmail])) == UPPER(Alltrim(aCols[N][nPosEmail]))) //.And. (aCols[nI][nPosClasse] == aCols[N][nPosClasse])
						If (Empty(aCols[nI][nPosClasse]) .And. !Empty(aCols[N][nPosClasse])) .Or. (!Empty(aCols[nI][nPosClasse]) .And. Empty(aCols[N][nPosClasse])) .Or. ;
						(aCols[nI][nPosClasse] == aCols[N][nPosClasse]) .And. (aCols[nI][nPosEmp] == aCols[N][nPosEmp])
							MsgStop("Email Já Cadastrado","Verifique")
							lRet := .F.
							exit  					
						EndIf
					EndIf
				EndIf
			Next nI
		EndIf
	EndIf  

return lRet      

/*
##############################################################################################################
# PROGRAMA...: Mod2GrvI
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 16/10/2013                      
# DESCRICAO..: Efetivar Gravacao
##############################################################################################################
*/
Static Function Mod2GrvI() 

	Local aArea := GetArea()
	Local cAlias := "Z28"  

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

			(cAlias)->Z28_FILIAL 	:= xFilial(cAlias)
			(cAlias)->Z28_ROTINA 	:= cCodigo
			(cAlias)->Z28_DESCRI 	:= cDesc 
			(cAlias)->Z28_SEQ 		:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z28_SEQ" } ) ]
			//If Empty(cEmail)
			(cAlias)->Z28_EMAIL		:= Alltrim(aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z28_EMAIL" } ) ])
			//ELse
			//	(cAlias)->Z28_EMAIL		:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z28_EMAIL" } ) ] + ";" + Alltrim(cEmail)
			//EndIf
			(cAlias)->Z28_EMPRES 	:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z28_EMPRES" } ) ]
			(cAlias)->Z28_CLASSE 	:= aCols[i][aScan( aHeader, { |x| AllTrim( x[2] ) == "Z28_CLASSE" } ) ]
			If(cComboBox == 'Sim')
				(cAlias)->Z28_REPLIC 	:= 'S'
			Else
				(cAlias)->Z28_REPLIC 	:= 'N'
			EndIf     

			MsUnLock()
		EndIf  
	Next i

	MsgInfo("Informe a Equipe de TI que foi feito um Novo Cadastro no Sistema!","Cadastro Concluido Com Sucesso") 
	oDlg:End()

	RestArea(aArea)

Return    

/*
##############################################################################################################
# PROGRAMA...: Mod2GrvA
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 19/02/2014                      
# DESCRICAO..: Efetivar Alteração
##############################################################################################################
*/
Static Function Mod2GrvA()

	Local aArea := GetArea()
	Local cAlias := "Z28"
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
			(cAlias)->Z28_FILIAL := xFilial(cAlias)
			(cAlias)->Z28_ROTINA := cCodigo
			(cAlias)->Z28_DESCRI := cDesc 
			If(cComboBox == 'Sim')
				(cAlias)->Z28_REPLIC 	:= 'S'
			Else
				(cAlias)->Z28_REPLIC 	:= 'N'
			EndIf    

			For nX := 1 To Len( aHeader )
				FieldPut( FieldPos( aHeader[nX, 2] ),aCOLS[nI, nX] )
			Next nX
		Endif
		MsUnLock()
	Next nI

	RestArea( aArea )

Return              

/*
##############################################################################################################
# PROGRAMA...: Mod2aHeader
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 12/02/2014                      
# DESCRICAO..: Montagem do aHeader para tela Modelo 2
##############################################################################################################
*/
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

/*
##############################################################################################################
# PROGRAMA...: Mod2aCOLS
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 12/02/2014                      
# DESCRICAO..: Montagem do aCols para tela Modelo 2
##############################################################################################################
*/
Static Function Mod2aCOLS( cAlias, nReg, nOpc )

	Local aArea := GetArea()
	Local cChave := Z28->Z28_ROTINA
	Local nI := 0          

	If nOpc <> 3
		dbSelectArea( cAlias )
		dbSetOrder(1)
		dbSeek( xFilial( cAlias ) + cChave )
		While !EOF() .And. (cAlias)->( Z28_FILIAL + Z28_ROTINA ) == xFilial( cAlias ) + cChave
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
		aCOLS[1, GdFieldPos("Z28_SEQ")] := "001"
		aCOLS[1, Len( aHeader )+1 ] := .F.
	Endif                   

	Restarea( aArea )

Return

/*
##############################################################################################################
# PROGRAMA...: BIA191_MNT
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/03/2014                      
# DESCRICAO..: Manutencao de dados na tabela Z28
##############################################################################################################
*/
User Function BIA191_MNT( cAlias, nReg, nOpc )   

	Local oTPanel1
	Local aSizFrm := {}   
	Local aArea := GetArea()

	Private oDlg            
	Private oGetDados

	Private cCodigo 
	Private cDesc 
	Private oComboBox
	Private cComboBox := IIF((cAlias)->Z28_REPLIC =="S",'Sim',"Nao")
	//Private cEmail := Space(Len(Z28->Z28_EMAIL)) 

	Private aHeader := {}
	Private aCOLS := {}
	Private aREG := {}  

	//Monta Tela     
	aSizFrm := MsAdvSize() 

	dbSelectArea( cAlias )
	dbGoTo( nReg )               

	cCodigo := (cAlias)->Z28_ROTINA
	cDesc := (cAlias)->Z28_DESCRI

	Mod2aHeader( cAlias )
	Mod2aCOLS( cAlias, nReg, nOpc )

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000, 000 TO aSizFrm[6]*80/110 ,aSizFrm[5]*80/110 COLORS 0, 15658734 PIXEL   
	oTPanel1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,45,.T.,.F.)                    
	oTPanel1:Align := CONTROL_ALIGN_TOP

	@ 4, 006 SAY "Rotina:" SIZE 70,7 PIXEL OF oTPanel1
	@ 4, 110 SAY "Descricao" SIZE 70,7 PIXEL OF oTPanel1  
	@ 3, 026 MSGET cCodigo When .F. SIZE 030,7 PIXEL OF oTPanel1

	If nOpc == 2	//CAMPO BLOQUEADO PARA VISUALIZACAO
		@ 3, 090 MSGET cDesc When .F. PICTURE "@!" SIZE 220,7 PIXEL OF oTPanel1
	Else
		@ 3, 090 MSGET cDesc PICTURE "@!" SIZE 220,7 PIXEL OF oTPanel1
	EndIf

	@ 21, 006 SAY oSay1 PROMPT "Replicar para Todas Empresas?" SIZE 081, 007 OF oTPanel1 COLORS 0, 16777215 PIXEL
	@ 20, 090 MSCOMBOBOX oComboBox VAR cComboBox ITEMS {"Sim","Nao"} SIZE 045, 010 OF oTPanel1 COLORS 0, 16777215 PIXEL ON CHANGE MudaRepl(cAlias,nReg,nOpc) 


	If nOpc == 4   //ATERACAO
		oGetDados := MSGetDados():New(0,0,0,0,nOpc,"U_BIA191OK()", ".T.","+Z28_SEQ",.T.)
	Else
		oGetDados := MSGetDados():New(0,0,0,0,nOpc)
	Endif
	oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| ( IIF( nOpc==4 .And. TudoOk(), Mod2GrvA(), IIF( nOpc==5, Mod2GrvE(), oDlg:End() ) ), oDlg:End() ) },{|| oDlg:End() })

	RestArea( aArea )

Return   


/*
##############################################################################################################
# PROGRAMA...: BIA191_E
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/03/2014
# DESCRICAO..: TELA PARA EXCLUSAO DO REGISTRO
##############################################################################################################
*/
User Function BIA191_E()

	Local aArea := GetArea()
	Local cChave := Z28->Z28_ROTINA
	Local cAlias := "Z28"

	dbSelectArea( cAlias )
	dbSetOrder(1)
	If dbSeek( xFilial( cAlias ) + cChave )
		//If dbSeek(cChave)

		If MsgYesNo("Confirma Exclusão da Rotina " +Alltrim(Z28->Z28_ROTINA)+"? Isso Poderá acarrer na Falha do Recebimentos dos Emails","Confirma Exclusão?")

			While !EOF() .And. (cAlias)->( Z28_FILIAL + Z28_ROTINA ) == xFilial( cAlias ) + cChave
				RecLock(cAlias,.F.)  

				( cAlias )->(DbDelete())
				( cAlias )->(MsUnlock())

				DbSkip()
			EndDo
		EndIf
	EndIf	
	RestArea(aArea) 

Return

/*
##############################################################################################################
# PROGRAMA...: ValidaRotina
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/03/2014
# DESCRICAO..: VALIDACAO DE REGISTRO DUPLICADO
##############################################################################################################
*/
Static Function ValidaRotina()

	Local aArea := GetArea()
	Local lRet := .T.             

	DbSelectArea("Z28")
	DbSetOrder(1)
	If DbSeek(xFilial("Z28")+cCodigo) 
		//If DbSeek(cCodigo)
		MsgStop("Rotina Já Cadastrada Anteriormente.","Verifique")
		lRet := .F.
	EndIf          

	//DbCloseArea("Z28")     
	RestArea(aArea)

Return lRet


/*
##############################################################################################################
# PROGRAMA...: MudaRepl
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/03/2014
# DESCRICAO..: REINICIAR TELA DE CADASTRO - ACOLS
##############################################################################################################
*/
Static Function MudaRepl(cAlias, nReg, nOpc)

	If(Len(aCols) > 1 .Or. !Empty(aCols[1][2]) )
		If MsgYesNo("Já existe registros inseridos. Deseja Reiniciar Cadastro?","Confirmar?")
			aCOLS := {} 
			Mod2aCOLS( cAlias, nReg, nOpc )
			oGetDados:Refresh()			
		EndIf
	EndIf

Return
