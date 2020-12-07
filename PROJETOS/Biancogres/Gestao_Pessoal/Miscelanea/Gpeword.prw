#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "GPEWORD.CH"
#include "topconn.ch"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Programa    ³ GPEWORD  ³ Autor ³Marinaldo de Jesus     ³ Data ³  05/07/00  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Descri‡„o   ³ Impressao de Documentos tipo Word                            ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Sintaxe     ³ Chamada padrao para programas em RdMake.                     ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Programador ³Data      ³ FNC            ³Motivo da Alteracao               ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Raquel Hager|14/10/2013³         M12RH01³Projeto Unificacao Folha de Paga- ³
//³        	   ³          ³         RQ0317³mento - Remocao de ajustas         ³ 
//³Christiane V|17/06/2013³TPUSEP   ³Correção da impressão dos         		  ³
//³        	   ³          ³         ³dependentes.                      		  ³
//³Renan Borges³18/08/2014³TQFCTS	³Ajuste na impressao da descricao 		  ³ 
//³            ³          ³         ³da função.						 		  ³  
//³Marcia Moura³04/09/2014³TQMI75	³Alterado o nome dos valids de perguntas  ³
//³Mariana M.  ³12/06/2015³TSPCXJ	³Ajuste para que ao gerar a integração    ³
//³            ³ 		  ³      	³com o Word, o sistema mostre arquivos    ³ 
//³            ³ 		  ³      	³.DOT ou .DOTX	                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function GPEWORD()
	Local   cCampo  	:= ""
	Local	oDlg		:= Nil
	Local 	cMsgDic		:= ""	// Mensagem para validacao de dicionario de dados
	// Declaracao de arrays para dimensionar tela
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}

	Private	cPerg	:= "GPWORD"
	Private aInfo	:= {}
	Private aDepenIR:= {}
	Private aDepenSF:= {}
	Private aPerSRF := {}
	Private nDepen	:= 0
	Private lDepSf	:= Iif(SRA->(FieldPos("RA_DEPSF"))>0,.T.,.F.)

	// Tratando os espacos do novo tamanho do X1_GRUPO
	cPerg	:= cPerg + (Space( Len(SX1->X1_GRUPO)  - Len(cPerg) ) )

	Pergunte(cPerg,.F.)

	OpenProfile()

	// Avalia o conteudo ja existente no profile e o altera se necessario
	// para que o erro nao ocorra apos a atualizacao do sistema
	If ( ProfAlias->( DbSeek( SM0->M0_CODIGO + Padl( CUSERNAME, 13 ) + "GPWORD    ") ) )
		cCampo := SubStr( AllTrim( ProfAlias->P_DEFS ), 487, 75 )
		If !( ".DOT" $ UPPER( cCampo ) )
			RecLock( "ProfAlias", .F. )
			ProfAlias->P_DEFS := ""
			ProfAlias->( MsUnLock() )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³         Grupo  Ordem Pergunta Portugues     Pergunta Espanhol  Pergunta Ingles Variavel Tipo Tamanho Decimal Presel  GSC Valid                              Var01      Def01         DefSPA1   DefEng1 Cnt01             Var02  Def02    		 DefSpa2  DefEng2	Cnt02  Var03 Def03      DefSpa3    DefEng3  Cnt03  Var04  Def04     DefSpa4    DefEng4  Cnt04  Var05  Def05       DefSpa5	 DefEng5   Cnt05  XF3   GrgSxg ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Monta as Dimensoes dos Objetos
	aAdvSize		:= MsAdvSize()
	aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	// Horizontal
	aAdvSize[6]	:=  (aAdvSize[6]/100) * 40	// Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*20), (((aObjSize[1,4])/100)*59) }	// 1,3 Vertical /1,4 Horizontal

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	@ aGdCoord[1],aGdCoord[2] TO aGdCoord[3],aGdCoord[4] PIXEL
	@ aGdCoord[1]+10,aGdCoord[2]+10 SAY OemToAnsi(STR0002) PIXEL
	@ aGdCoord[1]+20,aGdCoord[2]+10 SAY OemToAnsi(STR0003) PIXEL

	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-95 BMPBUTTON TYPE 5 ACTION Eval( { || fPerg_Word() , Pergunte(cPerg,.T.) } )

	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-60 BUTTON OemToAnsi(STR0004) SIZE 55,11 ACTION Eval( { || fPerg_Word() , (ndepen:= 0,fVarW_Imp() ) }  )
	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+5 BUTTON OemToAnsi(STR0005) SIZE 55,11 ACTION Eval( { || fPerg_Word() , fWord_Imp() } )

	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+70 BMPBUTTON TYPE 2 ACTION Close(oDlg)
	ACTIVATE DIALOG oDlg CENTERED

Return( Nil)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³fWord_Imp ³ Autor ³ Marinaldo de Jesus    ³ Data ³ 05/07/00 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³Impressao do Documento Word                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fWord_Imp()
	// Definindo Variaveis Locais                                             
	Local oWord			:= NIL
	Local cExclui		:= ""
	Local cFilAnt   	:= Space(FWGETTAMFILIAL)
	Local aCampos		:= {}
	Local nX			:= 0
	Local nSvOrdem		:= 0
	Local nSvRecno		:= 0
	Local cAcessaSRA	:= &( " { || " + ChkRH( "GPEWORD" , "SRA" , "2" ) + " } " )

	// Carregando mv_par para Variaveis Locais do Programa                    
	Local cFilDe		:= mv_par01
	Local cFilAte		:= mv_par02
	Local cCcDe			:= mv_par03
	Local cCcAte		:= mv_par04
	Local cMatDe		:= mv_par05
	Local cMatAte		:= mv_par06
	Local cNomeDe		:= mv_par07
	Local cNomeAte		:= mv_par08
	Local cTnoDe		:= mv_par09
	Local cTnoAte		:= mv_par10
	Local cFunDe		:= mv_par11
	Local cFunAte		:= mv_par12
	Local cSindDe		:= mv_par13
	Local cSindAte		:= mv_par14
	Local dAdmiDe		:= mv_par15
	Local dAdmiAte		:= mv_par16
	Local cSituacao		:= mv_par17
	Local cCategoria	:= mv_par18
	Local nCopias		:= If ( Empty(mv_par23),1,mv_par23 )
	Local nOrdem		:= mv_par24
	Local cArqWord		:= mv_par25
	Local cAux			:= ""
	Local cPath 		:= GETTEMPPATH()
	Local nAt			:= 0
	Local lDepende		:= If (Mv_par26 = 1, .T., .F.)
	Local nDepende  	:= mv_par27
	Local lImpress      := ( mv_par28 == 1 )
	Local cArqSaida     := AllTrim( mv_par29 )
	nDepen				:= If ( ! lDepende, 4,nDepende )

	// Checa o SO do Remote (1=Windows, 2=Linux)
	If GetRemoteType() == 2
		MsgAlert(OemToAnsi(STR0167), OemToAnsi(STR0168))	// "Integracao Word funciona somente com Windows !!!")###"Atencao !"
		Return	
	EndIf

	// Verifica se o usuario escolheu um drive local (A: C: D:) caso contrario
	// busca o nome do arquivo de modelo,  copia para o diretorio temporario  
	// do windows e ajusta o caminho completo do arquivo a ser impresso.     
	If Substr(cArqWord,2,1) <> ":"
		cAux 	:= cArqWord
		nAT		:= 1
		For nx := 1 to len(cArqWord)
			cAux := substr(cAux,If(nx==1,nAt,nAt+1),len(cAux))
			nAt := at("\",cAux)
			If nAt == 0
				Exit
			EndIf
		Next nx
		CpyS2T(cArqWord,cPath, .T.)
		cArqWord	:= cPath+cAux
	EndIf

	// Bloco que definira a Consistencia da Parametrizacao dos Intervalos 
	// selecionados nas Perguntas De? Ate?                                      
	cExclui := cExclui + "{ || "
	cExclui := cExclui + "(RA_FILIAL  < cFilDe     .or. RA_FILIAL  > cFilAte    ).or."
	cExclui := cExclui + "(RA_MAT     < cMatDe     .or. RA_MAT     > cMatAte    ).or." 
	cExclui := cExclui + "(RA_CC      < cCcDe      .or. RA_CC      > cCCAte     ).or." 
	cExclui := cExclui + "(RA_NOME    < cNomeDe    .or. RA_NOME    > cNomeAte   ).or." 
	cExclui := cExclui + "(RA_TNOTRAB < cTnoDe     .or. RA_TNOTRAB > cTnoAte    ).or." 
	cExclui := cExclui + "(RA_CODFUNC < cFunDe     .or. RA_CODFUNC > cFunAte    ).or." 
	cExclui := cExclui + "(RA_SINDICA < cSindDe    .or. RA_SINDICA > cSindAte   ).or." 
	cExclui := cExclui + "(RA_ADMISSA < dAdmiDe    .or. RA_ADMISSA > dAdmiAte   ).or." 
	cExclui := cExclui + "!(RA_SITFOLH$cSituacao).or.!(RA_CATFUNC$cCategoria)"
	cExclui := cExclui + " } "

	// Inicializa o Ole com o MS-Word 97 ( 8.0 )						      
	oWord	:= OLE_CreateLink() ; OLE_NewFile( oWord , cArqWord )

	dbSelectArea("SRB")
	nSBOrdem := IndexOrd() ; nSBRecno := Recno()
	dbGotop()

	dbSelectArea("SRA")
	nSvOrdem := IndexOrd() ; nSvRecno := Recno()
	dbGotop()


	// Posicionando no Primeiro Registro do Parametro               
	If nOrdem == 1	 	//Matricula
		dbSetOrder(nOrdem)
		dbSeek( cFilDe + cMatDe , .T. )
		cInicio := '{ || RA_FILIAL + RA_MAT }'
		cFim    := cFilAte + cMatAte
	ElseIf nOrdem == 2		//Centro de Custo
		dbSetOrder(nOrdem)
		dbSeek( cFilDe + cCcDe + cMatDe , .T. )
		cInicio  := '{ || RA_FILIAL + RA_CC + RA_MAT }'
		cFim     := cFilAte + cCcAte + cMatAte
	ElseIf nOrdem == 3							//Nome
		dbSetOrder(nOrdem)
		dbSeek( cFilDe + cNomeDe + cMatDe , .T. )
		cInicio := '{ || RA_FILIAL + RA_NOME + RA_MAT }'
		cFim    := cFilAte + cNomeAte + cMatAte
	ElseIf nOrdem == 4							//Turno
		dbSetOrder(nOrdem)
		dbSeek( cFilDe + cTnoDe ,.T. )
		cInicio  := '{ || RA_FILIAL + RA_TNOTRAB } '
		cFim     := cFilAte + cCcAte + cNomeAte
	ElseIf nOrdem == 5							//Admissao
		cIndCond:= "RA_FILIAL + DTOS (RA_ADMISSA)"
		cArqNtx  := CriaTrab(Nil,.F.)
		IndRegua("SRA",cArqNtx,cIndCond,,,STR0162)		//"Selecionando Registros..."
		dbSeek( cFilDe + DTOS(dAdmiDe) ,.T. )
		cInicio  :='{ || RA_FILIAL + DTOS(RA_ADMISSA)}' 
		cFim     := cFilAte + DTOS(dAdmiAte)
	EndIf

	cFilialAnt := Space(FWGETTAMFILIAL)

	// Ira Executar Enquanto Estiver dentro do Escopo dos Parametros
	While SRA->( !Eof() .and. Eval( &(cInicio) ) <= cFim )

		// Consiste Parametrizacao do Intervalo de Impressao           
		If SRA->( Eval ( &(cExclui) ) )
			dbSelectArea("SRA")
			dbSkip()
			Loop
		EndIf


		// Consiste Filiais e Acessos                                             
		If !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
			dbSelectArea("SRA")
			dbSkip()
			Loop
		EndIf


		// Consiste os dependentes  de Salario Familia                            
		If lDepende
			If nDepende == 1 //Salario Familia
				// Consiste os dependentes  de Salario Familia                            
				If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))
					fDepSF( )
//				Else
//					SRA->(dbSkip())
//					Loop
				EndIf
			ElseIf nDepende == 2 //Imposto de Renda
				//	Consiste os dependentes  de Imposto de Renda                           
				If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))
					fDepIR( )
//				Else
//					SRA->(dbSkip())
//					Loop
				EndIf
			ElseIf nDepende == 3 // Todos os Tipos de Dependente (Salario Familia e Imposto de Renda
				//	Consiste todos os tipos de Dependentes                            
				If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))
					fDepIR( )
//				Else
//					SRA->(dbSkip())
//					Loop
				Endif
				If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))
					fDepSF( )
//				Else                                                                         
//					SRA->(dbSkip())
//					Loop
				Endif
			EndIf

/*			If (nDepende == 1)
			If  Empty(aDepenSF[1,1])
					SRA->(dbSkip())
					Loop
			Endif
		ElseIf	(nDepende == 2)
			If  Empty(aDepenIR[1,1])
					SRA->(dbSkip())
					Loop
			EndIf
		ElseIf	(nDepende == 3)
			If  !Empty(aDepenIR[1,1])  .And. !Empty(aDepenSF[1,1])
					SRA->(dbSkip())
					Loop
			EndIf
		EndIf */
	EndIf

	If cPaisLoc == "COL"
			fPesqSRF( ) //Busca Periodo Aquisitivo para Colombia
	EndIf

		// Carregando Informacoes da Empresa                           
	If SRA->RA_FILIAL # cFilialAnt
		If !fInfo(@aInfo,SRA->RA_FILIAL)
				// Encerra o Loop se Nao Carregar Informacoes da Empresa        
				Exit
		EndIf
			// Atualiza a Variavel cFilialAnt                               
			dbSelectArea("SRA")
			cFilialAnt := SRA->RA_FILIAL
	EndIf

		// Carrega Campos Disponiveis para Edicao                       
		aCampos := fCpos_Word()   

		// Ajustando as Variaveis do Documento                          
		Aeval(	aCampos																								,; 
		{ |x| OLE_SetDocumentVar( oWord, x[1]  																,;
	IF( Subst( AllTrim( x[3] ) , 4 , 2 )  == "->"          					,;
		Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 )		,;
		Subst( AllTrim( x[3] )  				,;
		- ( Len( AllTrim( x[3] ) ) - 5 )	 ;	
		)	  	 							 ; 
		)                                          ;
		)															,; 
		Transform( x[2] , x[3] )                                     		 ;
		) 														 	 		 ; 
		)																			 ;
		}     																 							 	 ;
		)


		// Atualiza as Variaveis                                        
		OLE_UpDateFields( oWord )

		// Imprimindo o Documento                                                 
			If lImpress
			For nX := 1 To nCopias
				OLE_SetProperty( oWord, '208', .F. ) ; OLE_PrintFile( oWord )
			Next nX
		Else
		 
			OLE_SaveAsFile( oWord, StrTran( cArqSaida, ".doc", "_" +ALLTRIM(SRA->RA_Nome)+ "_"+SRA->RA_Mat+".doc" ) )
		EndIf

		dbSelectArea("SRA")                                               
		dbSkip() 

		//Iniciliaza array 
		aDepenIR:= {}
		aDepenSF:= {}
		aPerSRF := {}

	Enddo


	// Encerrando o Link com o Documento                                      
	OLE_CloseLink( oWord )
	If Len(cAux) > 0
		fErase(carqword)
	EndIf

	// Restaurando dados de Entrada                                           
	dbSelectArea('SRA')
	dbSetOrder( nSvOrdem )
	dbGoTo( nSvRecno )

Return( Nil )

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao    ³ fOpen_Word ³ Autor ³ Marinaldo de Jesus  ³ Data ³ 06/05/00 ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descricao ³ Selecionaro os Arquivos do Word.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function fOpWord()
	Local cSvAlias		:= Alias()
	Local lAchou		:= .F.
	Local cTipo			:= STR0006														
	Local cNewPathArq	:= cGetFile( cTipo , STR0007, , , , nOR(GETF_MULTISELECT, GETF_NETWORKDRIVE, GETF_LOCALHARD) )									

	If !Empty( cNewPathArq )
		If Len( cNewPathArq ) > 75
			MsgAlert( STR0187 ) // "O endereco completo do local onde está o arquivo do Word excedeu o limite de 75 caracteres!"
			Return			
		Else
			If  Upper( Subst( AllTrim( cNewPathArq ), - 3 ) ) == Upper( AllTrim( STR0008 ) )
				Aviso( STR0009 , cNewPathArq , { STR0010 } )								
			ElseIf	Upper( Subst( AllTrim( cNewPathArq ), - 4 ) ) == Upper( AllTrim( STR0294 ) )
				Aviso( STR0009 , cNewPathArq , { STR0010 } )								
			Else
				MsgAlert( STR0011 )															
				Return
			EndIf
		EndIf
	Else
		Aviso(STR0012 ,STR0007,{ STR0010 } )//Aviso(STR0012 ,{ STR0010 } )													
		Return
	EndIf

	// Limpa o parametro para a Carga do Novo Arquivo                         
	dbSelectArea("SX1")  
	If lAchou := ( SX1->( dbSeek( cPerg + "25" , .T. ) ) )
		RecLock("SX1",.F.,.T.)
		SX1->X1_CNT01 := Space( Len( SX1->X1_CNT01 ) )
		mv_par25 := cNewPathArq
		MsUnLock()
	EndIf

	dbSelectArea( cSvAlias )

Return(.T.)


//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao    ³ fVarW_Imp ³ Autor ³ Marinaldo de Jesus   ³ Data ³ 07/05/00 ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descricao ³ Impressao das Variaveis disponiveis para uso.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fVarW_Imp()
	Local cString	:= 'SRA'                                	     
	Local aOrd		:= {STR0142,STR0143}
	Local cDesc1	:= STR0144
	Local cDesc2	:= STR0145                     
	Local cDesc3	:= STR0146                                
	Local Tamanho	:= "P"

	Private aReturn		:= {STR0147, 1,STR0148, 2, 2, 1, '',1 }  
	Private aLinha		:= {}                     
	Private nomeprog	:= 'GPEWORD' 
	Private cBtxt		:= ""
	Private AT_PRG		:= nomeProg
	Private wCabec0		:= 1
	Private wCabec1		:= STR0149
	Private wCabec2		:= ""
	Private wCabec3		:= ""
	Private nTamanho	:= "P"
	Private lEnd		:= .F.
	Private Titulo		:= cDesc1
	Private Li			:= 0
	Private ContFl		:= 1 
	Private nLastKey	:= 0


	// Envia controle para a funcao SetPrint                      
	WnRel := "WORD_VAR" 
	WnRel := SetPrint(cString,Wnrel,"",Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.F.)

	If nLastKey == 27
		Return( Nil )
	EndIf

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return( Nil )
	EndIf

	// Chamada do Relatorio.                                        
	RptStatus( { |lEnd| fImpVar() } , Titulo )

Return( Nil)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fImpVar  ³ Autor ³ Marinaldo de Jesus    ³ Data ³ 07/05/00 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³ Impressao das Variaveis disponiveis para uso.              ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fImpVar()
	Local nOrdem	:= aReturn[8]
	Local aCampos	:= {}
	Local nX		:= 0
	Local cDetalhe	:= ""
	Local cDescr	:= ""

	// Carregando Informacoes da Empresa                            
	If !fInfo(@aInfo,xFilial("SRA"))
		Return( Nil )
	EndIf

	// Carregando Variaveis                                         
	aCampos := fCpos_Word()

	// Ordena aCampos de Acordo com a Ordem Selecionada                   
	If nOrdem = 1
		aSort( aCampos , , , { |x,y| x[1] < y[1] } )
	Else
		aSort( aCampos , , , { |x,y| x[4] < y[4] } )
	EndIf

	// Carrega Regua de Processamento                                      
	SetRegua( Len( aCampos ) )


	// Impressao do Relatorio                                             
	For nX := 1 To Len( aCampos )

		// Movimenta Regua Processamento                                      
		IncRegua()  

		// Cancela Impressao                                             
		If lEnd
			@ Prow()+1,0 PSAY cCancel
			Exit
		EndIf

		// Mascara do Relatorio                                         
		//        10        20        30        40        50        60        70        80
		//12345678901234567890123456789012345678901234567890123456789012345678901234567890
		//Variaveis                      Descricao
		//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

		// Carregando Variavel de Impressao                             
		cDescr := AllTrim( aCampos[nX,4] )

		// Imprimindo Relatorio                                         
		Impr( Padr(aCampos[nX,1],31) + Left(cDescr,50) )

		If Len(cDescr) > 50
			Impr( Space(31) + SubStr(cDescr,51,50) )
		EndIf

		If Len(cDescr) > 100
			Impr( Space(31) + SubStr(cDescr,101,50) )
		EndIf

	Next nX

	If aReturn[5] == 1
		Set Printer To
		dbCommit()
		OurSpool(WnRel)
	EndIf

	// Apaga indices temporarios
	If nOrdem == 5
		fErase( cArqNtx + OrdBagExt() )
	EndIf

	MS_FLUSH()

Return( Nil )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fPerg_Word ³ Autor ³ Marinaldo de Jesus    ³ Data ³ 05/07/00 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³ Grava as Perguntas utilizadas no Programa no SX1.            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fPerg_Word()
	Local aArea		:= Getarea()

	// Ajusta o tamanho da pergunta 25 - Arquivo do Word            
	dbselectarea("SX1")
	If dbseek(cPerg+"25") .And. SX1->X1_TAMANHO <> 75
		Reclock("SX1",.F.)
		SX1->X1_TAMANHO		:= 75
		MsUnlock()
	EndIf

	// Retorna para a area corrente.                                
	Restarea(aArea)

Return( Nil )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fDepIR   ³ Autor ³R.H.                   ³ Data ³ 02/04/01 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³ Carrega Dependentes de Imp. de Renda.                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/                                                                                                                                                  
Static Function fDepIR( )
	Local Nx,nVezes
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste os dependentes  de I.R.                                       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aDepenIR:= {}
	Do  while SRB->RB_FILIAL+SRB->RB_MAT == SRA->RA_FILIAL+SRA->RA_MAT
		If  (SRB->RB_TipIr == '1') .Or.;
		(SRB->RB_TipIr == '2' .And. Year(dDataBase)-Year(SRB->RB_DtNasc) <= 21) .Or. ;
		(SRB->RB_TipIr == '3' .And. Year(dDataBase)-Year(SRB->RB_DtNasc) <= 24)
			//	Nome do Depend., Dta Nascimento,Grau de parentesco
			aAdd(aDepenIR,{left(SRB->RB_Nome,30),;
				SRB->RB_DtNasc,;
				If(SRB->RB_GrauPar=='C','Conjuge   ',If(SRB->RB_GrauPar=='F','Filho     ','Outros    ')),;
				SRB->RB_CIC,'S',;
				SRB->RB_TPDEP   })
		/*ELSE
		//	aAdd(aDepenIR,{left(SRB->RB_Nome,30),;
		//		SRB->RB_DtNasc,;
		//		If(SRB->RB_GrauPar=='C','Conjuge   ',If(SRB->RB_GrauPar=='F','Filho     ','Outros    ')),;
		//		SRB->RB_CIC,'',;
		 		SRB->RB_TPDEP   })*/
				EndIf
		SRB->(dbSkip())
		EndDo
		If  Len(aDepenIR) < 10
		nVezes := (10 - Len(aDepenIR))
			For Nx := 1 to nVezes
			aAdd(aDepenIR,{Space(30),Space(10),Space(10),Space(11),Space(1),Space(2) } )
			Next Nx
		EndIf
Return(aDepenIR)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fDepSF   ³ Autor ³ Equipe RH             ³ Data ³ 02/04/01 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³ Carrega Dependentes de Salario Familia.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function  fDepSF()
	Local Nx,nVezes
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste os dependentes  de Salario Familia                                       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aDepenSF:= {}
	Do While SRB->RB_FILIAL+SRB->RB_MAT == SRA->RA_FILIAL+SRA->RA_MAT
		If (SRB->RB_TipSf == '1') .Or. (SRB->RB_TipSf == '2' .And. ;
		Year(dDAtABase) - Year(SRB->RB_DtNasc) <= 14)
			//Nome do Depend., Dta Nascimento,Grau Parent.,Local Nascimento,Cartorio,Numero Regr.,Numero do Livro, Numero da Folha, Data Entrega,Data baixa. //
			aAdd(aDepenSF,{left(SRB->RB_Nome,30),;
				SRB->RB_DtNasc,;
				If(SRB->RB_GrauPar=='C','Conjuge   ',If(SRB->RB_GrauPar=='F','Filho     ','Outros    ')),;
				SRB->RB_LOCNASC,;
				SRB->RB_CARTORI,;
				SRB->RB_NREGCAR,;
				SRB->RB_NUMLIVR,;
				SRB->RB_NUMFOLH,;
				SRB->RB_DTENTRA,;
				SRB->RB_DTBAIXA,;
				SRB->RB_CIC,'S',;
				SRB->RB_TPDEP})
	/*	ELSE
		aAdd(aDepenSF,{left(SRB->RB_Nome,30),;
		SRB->RB_DtNasc,;
					If(SRB->RB_GrauPar=='C','Conjuge   ',If(SRB->RB_GrauPar=='F','Filho     ','Outros    ')),;
			SRB->RB_LOCNASC,;
			SRB->RB_CARTORI,;
			SRB->RB_NREGCAR,;
			SRB->RB_NUMLIVR,;
			SRB->RB_NUMFOLH,;
			SRB->RB_DTENTRA,;
			SRB->RB_DTBAIXA,;
			SRB->RB_CIC,'',;
			SRB->RB_TPDEP})*/
					EndIf
		SRB->(dbSkip())
			Enddo
			If  Len(aDepenSF) < 10
		nVezes := (10 - Len(aDepenSF))
				For Nx := 1 to nVezes
			aAdd(aDepenSF,{Space(30),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10),Space(11),Space(1),Space(2) } )
				Next Nx
			EndIf

Return(aDepenSF)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fPesqSRF ³ Autor ³ Equipe RH             ³ Data ³ 05/01/09 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³ Carrega Periodo Aquisitivo SRF.                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function  fPesqSRF()
	Local cAliasSRF := "SRF"        

	// Rotina de Busca Periodo Aquisitivo SRF 
	aPerSRF := {}	
	dbSelectArea(cAliasSRF)	
	dbSetOrder(RETORDER(cAliasSRF,"RF_FILIAL+RF_MAT+DTOS(RF_DATABAS") )	
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
		While !Eof() .And. SRF->RF_MAT == SRA->RA_MAT
			If SRF->RF_STATUS == "1" // 1= Ativo
				//Verifica se o Periodo Aberto não esta Expirado (3 Anos)
				nAnoExp := DDATABASE - SRF->RF_DATAFIM					
				If (nAnoExp < 1080 )
					//Data Inicial Periodo de Ferias, Data Final Periodo de Ferias
					aAdd(aPerSRF,{SRF->RF_DATABAS,SRF->RF_DATAFIM } )
				Else
					( cAliasSRF )->( dbSkip(1) )
					Loop
				EndIf
				Exit
			EndIf
			( cAliasSRF )->( dbSkip(1) )
		EndDo
	EndIf

Return(aPerSRF)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fTarProf ³ Autor ³ Jonatas A. T. Alves   ³ Data ³ 18/02/11   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³ Carrega Informacoes dos lancamentos de tarefas p/ professor. ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function  fTarProf(dDtRef)
	Local nI		:= 0
	Local nP		:= 0
	Local nCont		:= 0
	Local nQtTar	:= 2	
	Local aArea		:= GetArea()
	Local aCpos		:= Array(nQtTar,0)
	Local aRet		:= Array(nQtTar,0)
	Local bTar		:= { || .T. }

	DEFAULT dDtRef := SRA->RA_ADMISSA

	For nI := 1 To nQtTar
		aAdd( aCpos[nI], { "RO_DESTAR",	} )
		aAdd( aCpos[nI], { "RO_QTDSEM",	} )
		aAdd( aCpos[nI], { "RO_QUANT",	} )
		aAdd( aCpos[nI], { "RO_VALOR",	} )
		aAdd( aCpos[nI], { "RO_VALTOT",	} )
	Next

	// Professores mensalistas so considerar tarefas fixas
	If SRA->RA_CATFUNC == "I"
		bTar := { || SRO->RO_TIPO == "1" }
	EndIf

	dbSelectArea("SRO")
	If dbSeek( SRA->( RA_FILIAL + RA_MAT ) )
		While !Eof() .And. SRA->( RA_FILIAL + RA_MAT ) == SRO->( RO_FILIAL + RO_MAT ) .And. nCont < nQtTar
			If MesAno(SRO->RO_DATA) == MesAno(dDtRef) .And. Eval(bTar) // Filtra data de referencia e tarefas fixas
				If SRO->RO_TPALT == "001" .And. SRO->RO_QUANT > 0 		// Considera apenas salario Inicial e despreza se for h.e./falta
					nCont++
					For nP := 1 To Len( aCpos[1] )
						If aCpos[nCont][nP][1] == "RO_DESTAR"
							aCpos[nCont][nP][2] := fDescTarefa(SRO->RO_CODTAR)
						Else
							aCpos[nCont][nP][2] := SRO->( &( aCpos[nCont][nP][1] ) )
						EndIf
					Next
				EndIf
			EndIf
			dbSkip()
		EndDo
	EndIf

	For nI := 1 To nQtTar
		aEval( aCpos[nI], { |x| aAdd( aRet[nI], x[2] ) } )
	Next

	RestArea( aArea )

Return( aRet )


//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao    ³ fCpos_Word ³ Autor ³ Marinaldo de Jesus    ³ Data ³ 06/07/00 ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descricao ³ Retorna Array com as Variaveis Disponiveis para Impressao.   ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³          ³ aExp[x,1] - Variavel Para utilizacao no Word (Tam Max. 30)   ³
//³          ³ aExp[x,2] - Conteudo do Campo                (Tam Max. 49)   ³
//³          ³ aExp[x,3] - Campo para Pesquisa da Picture no X3 ou Picture  ³
//³          ³ aExp[x,4] - Descricao da Variaval                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
STATIC Function fCpos_Word()
	Local aExp			:= {}
	Local aRet			:= {}
	Local cTexto_01		:= AllTrim( mv_par19 )
	Local cTexto_02		:= AllTrim( mv_par20 )
	Local cTexto_03		:= AllTrim( mv_par21 )
	Local cTexto_04		:= AllTrim( mv_par22 ) 
	Local cApoderado	:= ""
	Local cRamoAtiv		:= ""   
	Local cEstCiv		:= "" //Estado Civil para DCN/DMN - PIS
	Local cTipCertd		:= "" //Tipo de Certidao Civil para DCN/DMN - PIS
	Local cGrauInstr	:= "" //Grau de Instrucao conforme DCN/DMN - PIS
	Local cTipNIS		:= ""

	Local cDESMTSS		:=""
	Local cDESCCSS		:=""
	Local cDESINS		:=""
	Local cDESCAN		:=""
	Local cDESCIC		:=""
	Local cDESJOR		:=""
	Local cDESFON		:=""

	Local cCodMunLP		:= ""
	Local cCodReqFun	:= ""

	Local aDescTurno	:= {}
	Local nPosTurno		:= 0

	If cPaisLoc == "BRA"
		cTipNIS := MV_PAR30  //Pergunte exclusivo do Brasil // Tipo PIS - DCN/DMN
	EndIf

	If cPaisLoc == "ARG"
		If fPHist82(xFilial(),"99","01")
			cApoderado := SubStr(SRX->RX_TXT,1,30)
		EndIf
		If fPHist82(xFilial(),"99","02")
			cRamoAtiv := SubStr(SRX->RX_TXT,1,50) 
		EndIf
	EndIf

	aAdd( aExp, {'GPE_FILIAL'			   		,	SRA->RA_FILIAL 										  	, "SRA->RA_FILIAL"			,STR0013	} ) 
	aAdd( aExp, {'GPE_MATRICULA'		   		,	SRA->RA_MAT												, "SRA->RA_MAT"				,STR0014	} ) 
	aAdd( aExp, {'GPE_CENTRO_CUSTO'		   		,	SRA->RA_CC												, "SRA->RA_CC"				,STR0015	} ) 
	aAdd( aExp, {'GPE_DESC_CCUSTO'		   		,	fDesc("SI3",SRA->RA_CC,"I3_DESC")		 				, "@!"						,STR0016	} ) 
	aAdd( aExp, {'GPE_NOME'		   		   		,	SRA->RA_NOME											, "SRA->RA_NOME"			,STR0017	} ) 
	aAdd( aExp, {'GPE_NOMECMP'           		,   SRA->RA_NOMECMP											, "@!"           			,STR0017 	} )
	aAdd( aExp, {'GPE_CPF'		   				,	SRA->RA_CIC												, "SRA->RA_CIC"				,STR0018	} ) 
	aAdd( aExp, {'GPE_PIS'		   				,	SRA->RA_PIS												, "SRA->RA_PIS"				,STR0019	} ) 
	aAdd( aExp, {'GPE_RG'		   		   		,	SRA->RA_RG												, "SRA->RA_RG"				,STR0020	} ) 
	aAdd( aExp, {'GPE_RG_ORG'	   		   		,	SRA->RA_RGORG											, "@!"						,STR0152	} ) 
	aAdd( aExp, {'GPE_RG_ORGUF'	   		   		,	SRA->RA_RGUF											, "@!"						,STR0241	} ) 
	aAdd( aExp, {'GPE_CTPS'				   		,	SRA->RA_NUMCP							 				, "SRA->RA_NUMCP"			,STR0021	} ) 
	aAdd( aExp, {'GPE_SERIE_CTPS'				,	SRA->RA_SERCP							 				, "SRA->RA_SERCP"			,STR0022	} ) 
	aAdd( aExp, {'GPE_UF_CTPS'			   		,	SRA->RA_UFCP							 				, "SRA->RA_UFCP"			,STR0023	} ) 
	aAdd( aExp, {'GPE_CNH'   	  		   		,	SRA->RA_HABILIT							 				, "SRA->RA_HABILIT"			,STR0024	} ) 
	aAdd( aExp, {'GPE_RESERVISTA'		   		,	SRA->RA_RESERVI							 				, "SRA->RA_RESERVI"			,STR0025	} ) 
	aAdd( aExp, {'GPE_TIT_ELEITOR' 		   		,	SRA->RA_TITULOE							 				, "SRA->RA_TITULOE"			,STR0026	} ) 
	aAdd( aExp, {'GPE_ZONA_SECAO'  		   		,	SRA->RA_ZONASEC							 				, "SRA->RA_ZONASEC"			,STR0027	} ) 
	aAdd( aExp, {'GPE_ENDERECO'			   		,	SRA->RA_ENDEREC							 				, "SRA->RA_ENDEREC"			,STR0028	} ) 
	aAdd( aExp, {'GPE_COMP_ENDER'		   		,	SRA->RA_COMPLEM							 				, "SRA->RA_COMPLEM"			,STR0029	} )	

	If cPaisLoc == "PER"
		aAdd( aExp, {'GPE_BAIRRO'				,	RetContUbigeo("SRA->RA_CEP", "RA_BAIRRO") 				, "@!"						,STR0030	} ) 
		aAdd( aExp, {'GPE_MUNICIPIO'			,	RetContUbigeo("SRA->RA_CEP", "RA_MUNICIP") 				, "@!"						,STR0031	} )
		aAdd( aExp, {'GPE_DESC_ESTADO'			,	RetContUbigeo("SRA->RA_CEP", "RA_DEPARTA")				, "@!"						,STR0033	} )	
	Else
		aAdd( aExp, {'GPE_BAIRRO'				,	SRA->RA_BAIRRO							 				, "SRA->RA_BAIRRO"			,STR0030	} ) 
		aAdd( aExp, {'GPE_MUNICIPIO'			,	SRA->RA_MUNICIP							 				, "SRA->RA_MUNICIP"			,STR0031	} )	
	EndIf

	If cPaisLoc <> "PER"
		aAdd( aExp, {'GPE_ESTADO'				,	SRA->RA_ESTADO											, "SRA->RA_ESTADO"			,STR0032	} )	
		aAdd( aExp, {'GPE_DESC_ESTADO'			,	fDesc("SX5","12"+SRA->RA_ESTADO,"X5_DESCRI")			, "@!"						,STR0033	} ) 
	EndIf

	aAdd( aExp, {'GPE_CEP'		   				,	SRA->RA_CEP												, "SRA->RA_CEP"				,STR0034	} ) 
	aAdd( aExp, {'GPE_TELEFONE'	   				,	SRA->RA_TELEFON										   	, "SRA->RA_TELEFON"			,STR0035	} ) 
	aAdd( aExp, {'GPE_NOME_PAI'	   		   		,	SRA->RA_PAI												, "SRA->RA_PAI"				,STR0036	} ) 
	aAdd( aExp, {'GPE_NOME_MAE'	   		   		,	SRA->RA_MAE											   	, "SRA->RA_MAE"				,STR0037	} ) 
	aAdd( aExp, {'GPE_COD_SEXO'	   				,	SRA->RA_SEXO											, "SRA->RA_SEXO"			,STR0038	} ) 
	//	aAdd( aExp, {'GPE_DESC_SEXO'   		   		,	SRA->(IF(RA_SEXO ="M","Masculino","Feminino"))			, "@!"						,STR0039	} ) 

	If cPaisLoc <> "ARG"
		aAdd( aExp, {'GPE_EST_CIVIL'  			,	SRA->RA_ESTCIVI											, "SRA->RA_ESTCIVI"			,STR0040	} ) 
	Else
		aAdd( aExp, {'GPE_EST_CIVIL'  			,	fDesc("SX5","33"+SRA->RA_ESTCIVI,"X5DESCRI()")	   		, "SRA->RA_ESTCIVI"			,STR0040	} ) 
	EndIf

	aAdd( aExp, {'GPE_COD_NATURALIDADE'	   		,	If(SRA->RA_NATURAL # " ",SRA->RA_NATURAL," ")	    	, "SRA->RA_NATURAL"			,STR0041	} ) 
	aAdd( aExp, {'GPE_DESC_NATURALIDADE'		,	fDesc("SX5","12"+SRA->RA_NATURAL,"X5_DESCRI")			, "@!"						,STR0042	} ) 
	aAdd( aExp, {'GPE_COD_NACIONALIDADE'		,	SRA->RA_NACIONA											, "SRA->RA_NACIONA"			,STR0043	} ) 
	aAdd( aExp, {'GPE_DESC_NACIONALIDADE'  		,	fDesc("SX5","34"+SRA->RA_NACIONA,"X5_DESCRI")			, "@!"						,STR0044	} ) 

	If cPaisLoc <> "EQU"
		aAdd( aExp, {'GPE_ANO_CHEGADA' 			,	SRA->RA_ANOCHEG											, "SRA->RA_ANOCHEG"			,STR0045	} )
	EndIf

	aAdd( aExp, {'GPE_DEP_IR'   				,	SRA->RA_DEPIR										 	, "SRA->RA_DEPIR"			,STR0046	} )	

	If lDepSf
		aAdd( aExp, {'GPE_DEP_SAL_FAM'			,	SRA->RA_DEPSF											, "SRA->RA_DEPSF"			,STR0047 	} )
	EndIf

	aAdd( aExp, {'GPE_DATA_NASC'  		   		,	SRA->RA_NASC											, "SRA->RA_NASC"			,STR0048	} )
	aAdd( aExp, {'GPE_DATA_ADMISSAO'			,	SRA->RA_ADMISSA											, "SRA->RA_ADMISSA"			,STR0049	} )
	aAdd( aExp, {'GPE_DIA_ADMISSAO' 	   		,	StrZero( Day( SRA->RA_ADMISSA ) , 2 )					, "@!"						,STR0050	} )
	aAdd( aExp, {'GPE_MES_ADMISSAO'		   		,	StrZero( Month( SRA->RA_ADMISSA ) , 2 )					, "@!"						,STR0051 	} )
	aAdd( aExp, {'GPE_ANO_ADMISSAO'				,	StrZero( Year( SRA->RA_ADMISSA ) , 4 )					, "@!"						,STR0052	} )
	aAdd( aExp, {'GPE_DT_OP_FGTS'  				,	SRA->RA_OPCAO											, "SRA->RA_OPCAO"			,STR0053	} )
	aAdd( aExp, {'GPE_DATA_DEMISSAO'	   		,	SRA->RA_DEMISSA											, "SRA->RA_DEMISSA"			,STR0054	} ) 

	If cPaisLoc <> "EQU"
		aAdd( aExp, {'GPE_DATA_EXPERIENCIA'		,	SRA->RA_VCTOEXP											, "SRA->RA_VCTOEXP"			,STR0055	} )
		aAdd( aExp, {'GPE_DIA_EXPERIENCIA' 		,	StrZero( Day( SRA->RA_VCTOEXP ) , 2 )					, "@!"						,STR0056	} )
		aAdd( aExp, {'GPE_MES_EXPERIENCIA'		,	StrZero( Month( SRA->RA_VCTOEXP ) , 2 )					, "@!"						,STR0057	} )
		aAdd( aExp, {'GPE_ANO_EXPERIENCIA'		,	StrZero( Year( SRA->RA_VCTOEXP ) , 4 ) 					, "@!"						,STR0058	} )
		aAdd( aExp, {'GPE_DIAS_EXPERIENCIA'		,	StrZero(SRA->(RA_VCTOEXP-RA_ADMISSA)+1,03)				, "@!"						,STR0059	} )
		aAdd( aExp, {'GPE_DATA_EXPERIENCIA2'	,	SRA->RA_VCTEXP2											, "SRA->RA_VCTEXP2"			,STR0245	} )
		aAdd( aExp, {'GPE_DIA_EXPERIENCIA2' 	,	StrZero( Day( SRA->RA_VCTEXP2 ) , 2 )					, "@!"						,STR0246	} )
		aAdd( aExp, {'GPE_MES_EXPERIENCIA2'		,	StrZero( Month( SRA->RA_VCTEXP2 ) , 2 )					, "@!"						,STR0247	} )
		aAdd( aExp, {'GPE_ANO_EXPERIENCIA2'		,	StrZero( Year( SRA->RA_VCTEXP2 ) , 4 ) 					, "@!"						,STR0248	} )
		aAdd( aExp, {'GPE_DIAS_EXPERIENCIA2'	,	StrZero(SRA->(RA_VCTEXP2-RA_ADMISSA)+1,03)				, "@!"						,STR0249	} )
		aAdd( aExp, {'GPE_DATA_EX_MEDIC'		,	SRA->RA_EXAMEDI											, "SRA->RA_EXAMEDI"			,STR0060	} )
	EndIf

	aAdd( aExp, {'GPE_BCO_AG_DEP_SAL'	   		, 	SRA->RA_BCDEPSA											, "SRA->RA_BCDEPSA"			,STR0061	} )
	aAdd( aExp, {'GPE_DESC_BCO_SAL'		   		, 	fDesc("SA6",SRA->RA_BCDEPSA,"A6_NOME")					, "@!"						,STR0062	} )
	aAdd( aExp, {'GPE_DESC_AGE_SAL'		   		, 	fDesc("SA6",SRA->RA_BCDEPSA,"A6_NOMEAGE")				, "@!"						,STR0063	} )
	aAdd( aExp, {'GPE_CTA_DEP_SAL'		   		,	SRA->RA_CTDEPSA											, "SRA->RA_CTDEPSA"			,STR0064	} )
	aAdd( aExp, {'GPE_BCO_AG_FGTS'				,	SRA->RA_BCDPFGT											, "SRA->RA_BCDPFGT"			,STR0065	} )
	aAdd( aExp, {'GPE_DESC_BCO_FGTS'	   		, 	fDesc("SA6",SRA->RA_BCDPFGT,"A6_NOME")					, "@!"						,STR0066	} )
	aAdd( aExp, {'GPE_DESC_AGE_FGTS'	   		, 	fDesc("SA6",SRA->RA_BCDPFGT,"A6_NOMEAGE")				, "@!"						,STR0067	} )
	aAdd( aExp, {'GPE_CTA_Dep_FGTS'		   		,	SRA->RA_CTDPFGT											, "SRA->RA_CTDPFGT"			,STR0068	} )
	aAdd( aExp, {'GPE_SIT_FOLHA'	  	   		,	SRA->RA_SITFOLH											, "SRA->RA_SITFOLH"			,STR0069	} )
	aAdd( aExp, {'GPE_DESC_SIT_FOLHA'  			,	fDesc("SX5","30"+SRA->RA_SITFOLH,"X5_DESCRI")			, "@!"						,STR0070	} )
	aAdd( aExp, {'GPE_HRS_MENSAIS'		   		,	SRA->RA_HRSMES											, "SRA->RA_HRSMES"			,STR0071	} )
	aAdd( aExp, {'GPE_HRS_SEMANAIS'				,	SRA->RA_HRSEMAN											, "SRA->RA_HRSEMAN"			,STR0072	} )
	aAdd( aExp, {'GPE_CHAPA'		  	   		,	SRA->RA_CHAPA											, "SRA->RA_CHAPA"			,STR0073	} )
	aAdd( aExp, {'GPE_TURNO_TRAB'	 	   		,	SRA->RA_TNOTRAB											, "SRA->RA_TNOTRAB"			,STR0074	} )
	aAdd( aExp, {'GPE_DESC_TURNO'	  			,	fDesc('SR6',SRA->RA_TNOTRAB,'R6_DESC',,SRA->RA_FILIAL)	, "@!"						,STR0075	} )
	aAdd( aExp, {'GPE_COD_FUNCAO'	 			,	SRA->RA_CODFUNC											, "SRA->RA_CODFUNC"			,STR0076 	} )
	aAdd( aExp, {'GPE_DESC_FUNCAO'				,	fDesc('SRJ',SRA->RA_CODfUNC,'RJ_DESC',,SRA->RA_FILIAL)	, "@!"						,STR0077	} )
	aAdd( aExp, {'GPE_CBO'			   	   		,	fCodCBO(SRA->RA_FILIAL,SRA->RA_CODFUNC,dDataBase)		, "@!"				        ,STR0078	} )
	aAdd( aExp, {'GPE_CONT_SINDIC'		   		,	SRA->RA_PGCTSIN											, "SRA->RA_PGCTSIN"			,STR0079	} )
	aAdd( aExp, {'GPE_COD_SINDICATO'			,	SRA->RA_SINDICA											, "SRA->RA_SINDICA"			,STR0080	} )
	aAdd( aExp, {'GPE_DESC_SINDICATPO'	   		,	AllTrim( fDesc("RCE",SRA->RA_SINDICA,"RCE_DESCRI",40) ), "@!"						,STR0081	} )
	aAdd( aExp, {'GPE_COD_ASS_MEDICA'			,	SRA->RA_ASMEDIC											, "SRA->RA_ASMEDIC"			,STR0082	} )
	aAdd( aExp, {'GPE_DEP_ASS_MEDICA'			,	SRA->RA_DPASSME											, "SRA->RA_DPASSME"			,STR0083	} )
	aAdd( aExp, {'GPE_ADIC_TEMP_SERVIC'			,	SRA->RA_ADTPOSE											, "SRA->RA_ADTPOSE"			,STR0084	} )
	aAdd( aExp, {'GPE_COD_CESTA_BASICA'			,	SRA->RA_CESTAB											, "SRA->RA_CESTAB"			,STR0085	} )
	aAdd( aExp, {'GPE_COD_VALE_REF' 			,	SRA->RA_VALEREF											, "SRA->RA_VALEREF"			,STR0086	} )

	//|Facile Pontin - Criado variavel para aditivo de contrato de turno |
	aAdd(aDescTurno,{"E1","05h50 às 14h10", "13h50 às 22h10", "21h50 às 6h10"})
	aAdd(aDescTurno,{"E2","13h50 às 22h10", "05h50 às 14h10", "21h50 às 6h10"})
	aAdd(aDescTurno,{"E3","21h50 às 6h10", "05h50 às 14h10", "13h50 às 22h10"})

	nPosTurno	:= aScan(aDescTurno,{ |x| x[1] == Substr(AllTrim(SRA->RA_TNOTRAB), 1, 2) })

	If nPosTurno > 0
		aAdd( aExp, {'GPE_DESC_TURNO1'	  			,	aDescTurno[nPosTurno,2]	, "@!"						,STR0075	} )
		aAdd( aExp, {'GPE_DESC_TURNO2'	  			,	aDescTurno[nPosTurno,3]	, "@!"						,STR0075	} )
		aAdd( aExp, {'GPE_DESC_TURNO3'	  			,	aDescTurno[nPosTurno,4]	, "@!"						,STR0075	} )
	else
		aAdd( aExp, {'GPE_DESC_TURNO1'	  			,	""	, "@!"						,STR0075	} )
		aAdd( aExp, {'GPE_DESC_TURNO2'	  			,	""	, "@!"						,STR0075	} )
		aAdd( aExp, {'GPE_DESC_TURNO3'	  			,	""	, "@!"						,STR0075	} )
	EndIf


	If cPaisLoc $ ("ANG/ARG/BOL/BRA/CHI/COL/EQU/MEX/PER")
		aAdd( aExp, {'GPE_COD_SEG_VIDA' 		,	SRA->RA_SEGUROV											, "SRA->RA_SEGUROV"			,STR0087	} )
	EndIf

	aAdd( aExp, {'GPE_%ADIANTAM'	 			,	SRA->RA_PERCADT											, "SRA->RA_PERCADT"			,STR0089	} )
	aAdd( aExp, {'GPE_CATEG_FUNC'	  	   		,	SRA->RA_CATFUNC											, "SRA->RA_CATFUNC"			,STR0090	} )
	aAdd( aExp, {'GPE_DESC_CATEG_FUNC'			,	fDesc("SX5","28"+SRA->RA_CATFUNC,"X5_DESCRI")			, "@!"						,STR0091	} )
	aAdd( aExp, {'GPE_POR_MES_HORA'		   		,	SRA->(IF(RA_CATFUNC$"H","P/Hora",IF(RA_CATFUNC$"J","P/Aula","P/Mes"))) 			, "@!"						,STR0092	} )
	aAdd( aExp, {'GPE_TIPO_PAGTO'  				,	SRA->RA_TIPOPGT								 			, "SRA->RA_TIPOPGT"			,STR0093	} )
	aAdd( aExp, {'GPE_DESC_TIPO_PAGTO'  		,	fDesc("SX5","40"+SRA->RA_TIPOPGT,"X5_DESCRI")			, "@!"						,STR0094	} )
	aAdd( aExp, {'GPE_SALARIO'		   	   		,	SRA->RA_SALARIO											, "SRA->RA_SALARIO"			,STR0095	} )

	If cPaisLoc <> "EQU"
		aAdd( aExp, {'GPE_SAL_BAS_DISS'			,	SRA->RA_ANTEAUM											, "SRA->RA_ANTEAUM"			,STR0096	} )
	EndIf

	aAdd( aExp, {'GPE_HRS_PERICULO'  			,	SRA->RA_PERICUL											, "SRA->RA_PERICUL"			,STR0099	} )
	aAdd( aExp, {'GPE_HRS_INS_MINIMA'			,	SRA->RA_INSMIN											, "SRA->RA_INSMIN"			,STR0100	} )
	aAdd( aExp, {'GPE_HRS_INS_MEDIA'			,	SRA->RA_INSMED											, "@!"						,STR0101	} )
	aAdd( aExp, {'GPE_HRS_INS_MAXIMA'			,	SRA->RA_INSMAX											, "SRA->RA_INSMAX"			,STR0102	} )
	aAdd( aExp, {'GPE_TIPO_ADMISSAO'			,	SRA->RA_TIPOADM											, "SRA->RA_TIPOADM"			,STR0103	} )
	aAdd( aExp, {'GPE_DESC_TP_ADMISSAO'			,	fDesc("SX5","38"+SRA->RA_TIPOADM,"X5_DESCRI")			, "@!"						,STR0104	} )
	aAdd( aExp, {'GPE_COD_AFA_FGTS'		   		,	SRA->RA_AFASFGT											, "SRA->RA_AFASFGT"			,STR0105	} )
	aAdd( aExp, {'GPE_DESC_AFA_FGTS'	   		,	fDesc("SX5","30"+SRA->RA_AFASFGT,"X5_DESCRI")			, "@!"						,STR0106	} )

	If cPaisLoc <> "PER"
		aAdd( aExp, {'GPE_VIN_EMP_RAIS'			,	SRA->RA_VIEMRAI											, "SRA->RA_VIEMRAI"			,STR0107	} )
		aAdd( aExp, {'GPE_DESC_VIN_EMP_RAIS'	,	fDesc("SX5","25"+SRA->RA_VIEMRAI,"X5_DESCRI")			, "@!"						,STR0108	} )
	EndIf

	aAdd( aExp, {'GPE_COD_INST_RAIS'			,	SRA->RA_GRINRAI											, "SRA->RA_GRINRAI"			,STR0109	} )
	aAdd( aExp, {'GPE_DESC_GRAU_INST'			,	fDesc("SX5","26"+SRA->RA_GRINRAI,"X5_DESCRI")			, "@!"						,STR0110	} )
	aAdd( aExp, {'GPE_COD_RESC_RAIS'	   		,	SRA->RA_RESCRAI											, "SRA->RA_RESCRAI"			,STR0111	} )
	aAdd( aExp, {'GPE_CRACHA'		  	   		,	SRA->RA_CRACHA											, "SRA->RA_CRACHA"			,STR0112	} )
	aAdd( aExp, {'GPE_REGRA_APONTA'		   		,	SRA->RA_REGRA											, "SRA->RA_REGRA"			,STR0113	} )
	aAdd( aExp, {'GPE_NO_REGISTRO'	 	   		,	SRA->RA_REGISTR											, "SRA->RA_REGISTR"			,STR0115	} )
	aAdd( aExp, {'GPE_NO_FICHA'	    	   		,	SRA->RA_FICHA											, "SRA->RA_FICHA"			,STR0116	} )
	aAdd( aExp, {'GPE_TP_CONT_TRAB'		   		,	SRA->RA_TPCONTR											, "SRA->RA_TPCONTR"			,STR0117	} )
	aAdd( aExp, {'GPE_DESC_TP_CONT_TRAB'		,	SRA->(IF(RA_TPCONTR="1","Indeterminado","Determinado")), "@!"						,STR0118	} )
	aAdd( aExp, {'GPE_APELIDO'		   			,	SRA->RA_APELIDO											, "SRA->RA_APELIDO"			,STR0119	} )
	aAdd( aExp, {'GPE_E-MAIL'		 			,	SRA->RA_EMAIL											, "SRA->RA_EMAIL"			,STR0120	} )
	aAdd( aExp, {'GPE_TEXTO_01'			   		,	cTexto_01								   				, "@!"						,STR0121	} ) 
	aAdd( aExp, {'GPE_TEXTO_02'					,	cTexto_02												, "@!"						,STR0122	} )
	aAdd( aExp, {'GPE_TEXTO_03'					,	cTexto_03												, "@!"						,STR0123	} )
	aAdd( aExp, {'GPE_TEXTO_04'					,	cTexto_04												, "@!"						,STR0124	} )
	aAdd( aExp, {'GPE_EXTENSO_SAL'		   		,	Extenso( SRA->RA_SALARIO , .F. , 1 )					, "@!"						,STR0125 	} )
	aAdd( aExp, {'GPE_DDATABASE'				,	dDataBase                    	        				, "" 						,STR0126	} )
	aAdd( aExp, {'GPE_DIA_DDATABASE'			,	StrZero( Day( dDataBase ) , 2 )            				, "@!"						,STR0127	} )
	aAdd( aExp, {'GPE_MES_DDATABASE'			,	MesExtenso( dDataBase ) 								, "@!"						,STR0128	} )
	aAdd( aExp, {'GPE_ANO_DDATABASE'			,	StrZero( Year( dDataBase ) , 4 )            			, "@!"						,STR0129	} )
	aAdd( aExp, {'GPE_NOME_EMPRESA' 			,	aInfo[03]                              					, "@!"						,STR0130	} )
	aAdd( aExp, {'GPE_END_EMPRESA'				,	aInfo[04]                              					, "@!"						,STR0131	} )
	aAdd( aExp, {'GPE_CID_EMPRESA'		   		,	aInfo[05]                              					, "@!"						,STR0132	} )
	aAdd( aExp, {'GPE_CEP_EMPRESA'         		,   aInfo[07]                                              	, "!@R #####-###"          	,STR0034 	} )
	aAdd( aExp, {'GPE_EST_EMPRESA'         		,   aInfo[06]												, "@!"						,STR0032 	} )
	aAdd( aExp, {'GPE_CGC_EMPRESA' 		   		,	aInfo[08]             									, "@R ##.###.###/####-##"	,STR0134	} )
	aAdd( aExp, {'GPE_INSC_EMPRESA' 	   		,	aInfo[09]                              					, "@!" 						,STR0135	} )
	aAdd( aExp, {'GPE_TEL_EMPRESA'	 			,	aInfo[10]                              					, "@!" 						,STR0136	} )
	aAdd( aExp, {'GPE_FAX_EMPRESA'         		,   If(aInfo[11]#nil ,aInfo[11], "        ")              	, "@!"                     	,STR0136 	} )
	aAdd( aExp, {'GPE_BAI_EMPRESA'				,	aInfo[13]                              					, "@!" 						,STR0137	} )
	aAdd( aExp, {'GPE_DESC_RESC_RAIS'			,	fDesc("SX5","31"+SRA->RA_RESCRAI,"X5_DESCRI")			, "@!" 						,STR0138	} )
	aAdd( aExp, {'GPE_DIA_DEMISSAO'		   		,	StrZero( Day( SRA->RA_DEMISSA ) , 2 )					, "@!" 						,STR0139	} )
	aAdd( aExp, {'GPE_MES_DEMISSAO'				,	StrZero( Month( SRA->RA_DEMISSA ) , 2 )					, "@!" 						,STR0140 	} )
	aAdd( aExp, {'GPE_ANO_DEMISSAO'				,	StrZero( Year( SRA->RA_DEMISSA ) , 4 )					, "@!" 						,STR0141 	} )

	If cPaisLoc == "BRA"
		aAdd( aExp, {'GPE_RG_EMISSAO'			,	SRA->RA_DTRGEXP											, "SRA->RA_DTRGEXP"       	,STR0242	} )
		aAdd( aExp, {'GPE_CTPS_EMISSAO'			,	SRA->RA_DTCPEXP											, "SRA->RA_DTCPEXP"       	,STR0243	} )
		aAdd( aExp, {'GPE_FECREI'				, 	SRA->RA_FECREI											, "SRA->RA_FECREI" 			,STR0178	} ) 	
		aAdd( aExp, {'GPE_HRDIA'				,	SRA->RA_HRSDIA											, "SRA->RA_HRSDIA"			,STR0218	} )													
	EndIf

	aAdd( aExp, {'GPE_FUNC_COR'					,	If( SRA->RA_RACACOR == "1" , "Indígena" , ( If( SRA->RA_RACACOR == "2" , "Branca" , ( If( SRA->RA_RACACOR == "4" , "Negra" , ( If( SRA->RA_RACACOR == "6" , "Amarela" , ( If( SRA->RA_RACACOR == "8" , "Parda" , "Não informado" ) ) ) ) ) ) ) ) ) 											, "@!"       	,STR0244	} )

	//Periodo Aquisitivo de Ferias
	If cPaisLoc == "COL"
		aAdd( aExp, {'GPE_DIA_INIFERIAS'           ,   If(Len(aPerSRF) > 0,StrZero( Day( aPerSRF[1,1] ) , 2 ),Space(02))	, "@!"		,STR0188 	} )
		aAdd( aExp, {'GPE_MES_INIFERIAS'           ,   If(Len(aPerSRF) > 0,MesExtenso(aPerSRF[1,1] ),Space(12))			, "@!"    	,STR0189 	} )
		aAdd( aExp, {'GPE_ANO_INIFERIAS'           ,   If(Len(aPerSRF) > 0,StrZero( Year( aPerSRF[1,1] ) , 4 ),Space(04))	, "@!"		,STR0190 	} )	   
		aAdd( aExp, {'GPE_DIA_FIMFERIAS'           ,   If(Len(aPerSRF) > 0,StrZero( Day( aPerSRF[1,2] ) , 2 ),Space(02))	, "@!"		,STR0191 	} )
		aAdd( aExp, {'GPE_MES_FIMFERIAS'           ,   If(Len(aPerSRF) > 0,MesExtenso(aPerSRF[1,2] ),Space(12))			, "@!"		,STR0192 	} )
		aAdd( aExp, {'GPE_ANO_FIMFERIAS'           ,   If(Len(aPerSRF) > 0,StrZero( Year( aPerSRF[1,2] ) , 4 ),Space(04))	, "@!"		,STR0193 	} )
	EndIf
	
	// Em 17/11/16 Por Marcos Alberto
	aAdd( aExp, {'GPE_CLASSE_VALOR'			,	SRA->RA_CLVL													, "SRA->RA_CLVL"			,STR0015	} ) 
	aAdd( aExp, {'GPE_DESC_CLASSE_VALOR'	,	Posicione("CTH", 1, xFilial("CTH")+SRA->RA_CLVL, "CTH_DESC01")	, "@!"						,STR0016	} ) 

	dfrTipoAdc := ""
	If SRA->RA_PERICUL > 0
		dfrTipoAdc := "Periculosidade"
	ElseIf SRA->RA_INSMIN > 0
		dfrTipoAdc := "Insalubridade Minina"
	ElseIf SRA->RA_INSMED > 0
		dfrTipoAdc := "Insalubridade MÃ©dia"
	ElseIf SRA->RA_INSMAX > 0
		dfrTipoAdc := "Insalubridade MÃ¡xima"
	EndIf
	aAdd( aExp, {'GPE_ADICIONAIS_SALARIO'	,	dfrTipoAdc 							    						, "@!"	          		,STR0015	} ) 

	IF (nDepen==1 .Or. nDepen==3) .AND. Type("aDepenSF[1,1]") == "U"

		nDepen := 4

	Endif
	
	// Salario Familia
	aAdd( aExp, {'GPE_CFILHO01'            		,   If((nDepen==1 .Or. nDepen==3),aDepenSF[1,1],Space(30))	, "@!"						,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL01'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[1,2],Space(08))	, ""						,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO02'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[2,1],Space(30))	, "@!"						,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL02'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[2,2],Space(08))	, ""						,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO03'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[3,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL03'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[3,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO04'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[4,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL04'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[4,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO05'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[5,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL05'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[5,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO06'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[6,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL06'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[6,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO07'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[7,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL07'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[7,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO08'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[8,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL08'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[8,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO09'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[9,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL09'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[9,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO10'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[10,1],Space(30))	, "@!"                    	,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL10'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[10,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_DESC_ESTEMP'         		,   Alltrim(fDesc("SX5","12"+aInfo[06],"X5_DESCRI"))      	, "@!"                     	,STR0134 	} ) 
	aAdd( aExp, {'GPE_cGrau01'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau02'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau03'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau04'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau05'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau06'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,3],Space(10))	, "@!"						,STR0153 	} )
	aAdd( aExp, {'GPE_cGrau07'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,3],Space(10))	, "@!"						,STR0153 	} )
	aAdd( aExp, {'GPE_cGrau08'					,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,3],Space(10))	, "@!"						,STR0153 	} )
	aAdd( aExp, {'GPE_cGrau09'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau10'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_LOCAL01'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO01'		  		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO01'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO01'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA01'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA01'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA01'		   		,	if(nDepen==1 .Or. nDepen==3,aDepenSF[1,10],Space(10))	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL02'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO02'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO02'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO02'					,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA02'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA02'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA02'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,10],Space(10))	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL03'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO03'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO03'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO03'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA03'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA03'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA03'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,10],Space(10)) 	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL04'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,4],Space(10)) 	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO04'				,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,5],Space(10)) 	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO04'				,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,06],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO04'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA04'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA04'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA04'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,10],Space(10)) 	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL05'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO05'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,5],Space(10))	, "@!"						,STR0156 	} )
	aAdd( aExp, {'GPE_NREGISTRO05'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO05'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA05'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA05'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA05'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,10],Space(10))	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL06'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO06'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO06'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO06'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA06'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA06'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA06'		  		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,10],Space(10))	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL07'			  		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO07'		  		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO07'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO07'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA07'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA07'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA07'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,10],Space(10)) 	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL08'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO08'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO08'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO08'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA08'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA08'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA08'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,10],Space(10)) 	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL09'					,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO09'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO09'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO09'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA09'					,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA09'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA09'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,10],Space(10))	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL10'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO10'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO10'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO10'					,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA10'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA10'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA10'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,10],Space(10))	, "@!"						,STR0161 	} ) 
	// Imposto de Renda
	aAdd( aExp, {'GPE_CDEPE01'             		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[1,1],Space(30))	, "@!"						,STR0154   	} )
	aAdd( aExp, {'GPE_cGrDp01'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[1,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR01'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[1,2],Space(08)) 	, ""						,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE02'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[2,1],Space(30))	, "@!" 						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp02'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[2,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR02'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[2,2],Space(08))	, ""						,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE03'					,	If(nDepen==2 .Or. nDepen==3,aDepenIR[3,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp03'					,	If(nDepen==2 .Or. nDepen==3,aDepenIR[3,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR03'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[3,2],Space(08)) 	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE04'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[4,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp04'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[4,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR04'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[4,2],Space(08)) 	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE05'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[5,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp05'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[5,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR05'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[5,2],Space(08))	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE06'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[6,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp06'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[6,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR06'			   		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[6,2],Space(08)) 	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE07'					,	If(nDepen==2 .Or. nDepen==3,aDepenIR[7,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp07'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[7,3],Space(10))	, "@!"						,STR0153	} ) 
	aAdd( aExp, {'GPE_DTFLIR07'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[7,2],Space(08))	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE08'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[8,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp08'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[8,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR08'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[8,2],Space(08)) 	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE09'					,	If(nDepen==2 .Or. nDepen==3,aDepenIR[9,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp09'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[9,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR09'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[9,2],Space(08)) 	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE10'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[10,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp10'					,	If(nDepen==2 .Or. nDepen==3,aDepenIR[10,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR10'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[10,2],Space(08))	, ""                        ,STR0163 	} )

	aAdd( aExp, {'GPE_MES_ADEXT'		        ,	MesExtenso( Month( SRA->RA_ADMISSA ) )					 , "@!"						,STR0155	} )
	
	aAdd( aExp, {'GPE_DATA_1AVALIACAO'      ,   SRA->RA_VCTOEXP					                            , "SRA->RA_VCTOEXP"			,        	} )
	aAdd( aExp, {'GPE_DATA_2AVALIACAO'	    ,	SRA->RA_VCTEXP2                                             , "SRA->RA_VCTEXP2"			,       	} )
	
	
	If cPaisLoc == "ARG"
		aAdd( aExp, {'GPE_MES_ADEXT'		    ,	MesExtenso( Month( SRA->RA_ADMISSA ) )					 , "@!"						,STR0155	} )
		aAdd( aExp, {'GPE_APODERADO'		    ,	cApoderado												 , "@!"						,STR0156	} )
		aAdd( aExp, {'GPE_ATIVIDADE'		    ,	cRamoAtiv												 , "@!"						,STR0157	} )
	EndIf

	aAdd( aExp, {'GPE_MUNICNASC'           		,   If(SRA->(FieldPos("RA_MUNNASC")) # 0  ,SRA->RA_MUNNASC,space(20)), "@!"           ,STR0166 	} )
	aAdd( aExp, {'GPE_PROCES'	,	SRA->RA_PROCES	,	"SRA->RA_PROCES"	,STR0173 	} )	//Codigo do Processo                                                                     
	aAdd( aExp, {'GPE_DEPTO'	,	SRA->RA_DEPTO	,	"SRA->RA_DEPTO"		,STR0181 	} )	//Codigo do Departamento
    cDescDepto  := POSICIONE("SQB",1,"  "+SRA->RA_DEPTO,"QB_DESCRIC") 
    aAdd( aExp, {'GPE_DESC_DEPTO'	,	cDescDepto	,	"SQB->QB_DESCRIC"		,"Descrição do Departamento" 	} )	//Descrição do Departamento
    cCodMemAtv  := POSICIONE("SQ3",1,"  "+SRA->RA_CARGO+"  ","Q3_DESCDET") 
    cMemoAtividade := ""
   
	If !Empty(cCodMemAtv)
       dbSelectArea("SQ3")
	   dbSetOrder(1)
	   dbSeek(xFilial("SQ3", SRA->RA_FILIAL) +SRA->RA_CARGO+"  ")
       cMemoAtividade := MSMM(SQ3->Q3_DESCDET,,,,3)
	EndIf
    
    aAdd( aExp, {'GPE_DESC_ATIV'	,	cMemoAtividade	,	"SQ3->Q3_DESCDET"		, "Descrição da Atividade" 	} )	//Descrição da Atividade
    
    cInsalub := fGetInsalub(SRA->RA_ADCINS)
    aAdd( aExp, {'GPE_INSALUBRIDADE'	,	cInsalub	,	"SQ3->Q3_DESCDET"		, "Percentual de Insalubridade" 	} )	//Insalubridade
    
    cPericulosidade := ""
	If SRA->RA_ADCPERI == "2"
    	cPericulosidade := "+ adicional de 30% de periculosidade "
	endIf
    aAdd( aExp, {'GPE_PERICULOSIDADE'	,	cPericulosidade	,	"SQ3->Q3_DESCDET"		, "Percentual de Periculosidade" 	} )	//Insalubridade
    
    cMemoEPI := fGetEpiCarg(SRA->RA_CARGO, SRA->RA_DEPTO, SRA->RA_MAT)
    //cMemoEPI := fGetEpiCarg('8082')
    
    aAdd( aExp, {'GPE_EPI'	,	cMemoEPI	,	"SQ3->Q3_DESCDET"		, "Detalhamento EPI" 	} )	//Detalhamento de EPI
    //cMemoRISCOS := fGetRiscoCarg('8082')
    cMemoRISCOS := fGetRiscoCarg(SRA->RA_CARGO, SRA->RA_DEPTO, SRA->RA_MAT)
    
    aAdd( aExp, {'GPE_RISCOS'	,	cMemoRISCOS	,	"SQ3->Q3_DESCDET"		, "Detalhamento de Riscos" 	} )	//Detalhamento de EPI
    
    
    // Marcelo Facile - Ajustes para conter, em caso de transferencia, os dados de origem e destino
    cCodMat  := ALLTRIM(SRA->RA_MAT)
    cTranOri := fGetTrans('E',cCodMat,'1')
    cTranDES := fGetTrans('E',cCodMat,'2')
    cDepo    := fGetTrans('D',cCodMat,'1')
    cDepd    := fGetTrans('D',cCodMat,'2')
    cCaro    := fGetTrans('C',cCodMat,'1')
    cDesc    := fGetTrans('CD',cCodMat,'2')
    cClvlo   := fGetTrans('V',cCodMat,'1')
    cClvld   := fGetTrans('V',cCodMat,'2')
    cAdic    := fGetTrans('A',cCodMat,'1')
        
    aAdd(aExp, {'GPE_TRANORI'   ,   cTranOri    ,   "SQ3->Q3_DESCDET"       , "Empresa de Origem"       } )
    aAdd(aExp, {'GPE_TRANDES'   ,   cTranDES    ,   "SQ3->Q3_DESCDET"       , "Empresa de Destino"      } )
    aAdd(aExp, {'GPE_DEPORI'    ,   cDepo    ,   "SQ3->Q3_DESCDET"       , "Departamento de Origem"       } )
    aAdd(aExp, {'GPE_DEPDES'    ,   cDepd    ,   "SQ3->Q3_DESCDET"       , "Departamento de Destino"      } )
    aAdd(aExp, {'GPE_CARCOD'    ,   cCaro    ,   "SQ3->Q3_DESCDET"       , "Cargo"       } )
    aAdd(aExp, {'GPE_CARDES'    ,   cDesc    ,   "SQ3->Q3_DESCDET"       , "Cargo Descrição"      } )
    aAdd(aExp, {'GPE_CLVLO'      ,   cClvlo   ,   "SQ3->Q3_DESCDET"       , "Classe de valor origem"      } )
    aAdd(aExp, {'GPE_CLVLD'      ,   cClvld   ,   "SQ3->Q3_DESCDET"       , "Classe de valor destino"      } )
	aAdd(aExp, {'GPE_GEST'	    , SRA->RA_YSEMAIL , "SRA->RA_YSEMAIL"	,"Supervisor"	} ) 	//Supervisor
	aAdd(aExp, {'GPE_ADIC'	    , cAdic , "SRA->RA_YSUPEML"	,"Supervisor"	} ) 	//Adicionais
     
	If SRA->(FieldPos("RA_POSTO"  )) # 0
		aAdd( aExp, {'GPE_POSTO'	,	SRA->RA_POSTO  ,	"SRA->RA_POSTO"		,STR0182 	} )	//Codigo do Posto
	EndIf

	If cPaisLoc == "MEX"

		cCodMunLP  := POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_MUNIC")
		cCodReqFun := POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_DESCREQ")


		aAdd( aExp, {'GPE_PRINOME'				, SRA->RA_PRINOME  											, "SRA->RA_PRINOME"			,STR0169	} ) 	//Primeiro Nome 
		aAdd( aExp, {'GPE_SECNOME'				, SRA->RA_SECNOME  											, "SRA->RA_SECNOME"			,STR0170	} ) 	//Segundo Nome
		aAdd( aExp, {'GPE_PRISOBR'				, SRA->RA_PRISOBR											, "SRA->RA_PRISOBR"			,STR0171	} ) 	//Primeiro Sobrenome
		aAdd( aExp, {'GPE_SECSOBR' 				, SRA->RA_SECSOBR  											, "SRA->RA_SECSOBR"			,STR0172	} ) 	//Segundo Sobrenome
		aAdd( aExp, {'GPE_KEYLOC'				, SRA->RA_KEYLOC   											, "SRA->RA_KEYLOC"			,STR0174	} ) 	//Codigo Local de Pagamento
		aAdd( aExp, {'GPE_TSIMSS'				, SRA->RA_TSIMSS   											, "SRA->RA_TSIMSS" 			,STR0175	} ) 	//Tipo de Salario IMSS
		aAdd( aExp, {'GPE_TEIMSS'				, SRA->RA_TEIMSS											, "SRA->RA_TEIMSS"			,STR0176	} ) 	//Tipo de Empregado IMSS
		aAdd( aExp, {'GPE_TJRNDA'				, SRA->RA_TJRNDA   											, "SRA->RA_TJRNDA"			,STR0177	} ) 	//Tipo de Jornada IMSS
		aAdd( aExp, {'GPE_FECREI'				, SRA->RA_FECREI   											, "SRA->RA_FECREI"			,STR0178	} ) 	//Data de Readmissao
		aAdd( aExp, {'GPE_DTBIMSS'				, SRA->RA_DTBIMSS  											, "SRA->RA_DTBIMSS"			,STR0179	} ) 	//Data de Baixa IMSS
		aAdd( aExp, {'GPE_CODRPAT'				, SRA->RA_CODRPAT											, "SRA->RA_CODRPAT"			,STR0180	} ) 	//Codigo do Registro Patronal
		aAdd( aExp, {'GPE_CURP'	   		   		, SRA->RA_CURP 	   											, "SRA->RA_CURP"			,STR0183	} ) 	//CURP
		aAdd( aExp, {'GPE_TIPINF'		   		, SRA->RA_TIPINF											, "SRA->RA_TIPINF"			,STR0184	} ) 	//Tipo de Infonavit
		aAdd( aExp, {'GPE_VALINF'		   		, SRA->RA_VALINF   											, "SRA->RA_VALINF" 			,STR0185	} ) 	//Valor do Infonavit
		aAdd( aExp, {'GPE_NUMINF'				, SRA->RA_NUMINF											, "SRA->RA_NUMINF"			,STR0186	} ) 	//Nro. de Credito Infonavit
		aAdd( aExp, {'GPE_IDADE'				, cValToChar(Year(DDATABASE)-Year(SRA->RA_NASC))			, "!@"			   			,STR0335	} ) 	//Idade
		aAdd( aExp, {'GPE_REQFUNC'				, MSMM(cCodReqFun,80)										,"!@"						,STR0334	} )		//Requisitos da Funcao
		aAdd( aExp, {'GPE_DESCMUNIC'			, POSICIONE("VAM",1,XFILIAL("VAM")+SRA->RA_MUNICIP,"VAM_DESCID"),	"!@"				,STR0031	} ) 	//Descricao do Municipio

		//Campos da Localidade de Pagamento
		aAdd( aExp, {'GPE_DESCLP',		POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_DESLOC")		, "RGC->RGC_DESLOC"			,STR0216	} )		//Descricao do Local de Pagamento
		aAdd( aExp, {'GPE_ENDERECOLP',	POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_ENDER")		, "RGC->RGC_ENDER" 			,STR0328	} )		//Endereco da Localidade de Pagamento
		aAdd( aExp, {'GPE_BAIRROLP',	POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_BAIRRO")		, "RGC->RGC_BAIRRO"			,STR0329	} )		//Bairro da Localidade de Pagamento
		aAdd( aExp, {'GPE_CIDADELP',	POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_CIDADE")		, "RGC->RGC_CIDADE"			,STR0330	} )		//Cidade da Localidade de Pagamento
		aAdd( aExp, {'GPE_ESTADOLP',	POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_ESTADO")		, "RGC->RGC_ESTADO"			,STR0331	} )		//Estado da Localidade de Pagamento
		aAdd( aExp, {'GPE_CEPLP',		POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_CODPOS")		, "RGC->RGC_CODPOS"			,STR0333	} )		//CEP da Localidade de Pagamento
		aAdd( aExp, {'GPE_DESCMUNICLP',	POSICIONE("VAM",1,XFILIAL("VAM")+cCodMunLP,"VAM_DESCID")			, "!@"						,STR0332	} )		//Municipio da Localidade de Pagamento

	EndIf

	If  cPaisLoc $ "COS/DOM"
		aAdd( aExp, {'GPE_DISTEMP'	,	POSICIONE("CC2",1,XFILIAL("CC2")+SRA->RA_ESTADO+SRA->RA_MUNICIP,"CC2_MUN")			,	"CC2->CC2_MUN"		,STR0220	} )//"Descripción del distrito"
	EndIf

	If cPaisLoc == "COS"

		cDESMTSS:=getQuery(	" SELECT SUBSTRING(RCC_CONTEU,5,40) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S006' AND SUBSTRING(RCC_CONTEU,1,4)= '"+POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODMTSS")+"'")
		cDESCCSS:=getQuery(	" SELECT SUBSTRING(RCC_CONTEU,5,80) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S007' AND SUBSTRING(RCC_CONTEU,1,4)= '"+POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODCCSS")+"'")
		cDESINS:=getQuery ( " SELECT SUBSTRING(RCC_CONTEU,6,80) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S008' AND SUBSTRING(RCC_CONTEU,1,5)= '"+POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODINS")+"'")
		cDESCAN:=getQuery ( " SELECT SUBSTRING(RCC_CONTEU,6,40) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S013' AND SUBSTRING(RCC_CONTEU,1,5)= '"+SRA->RA_MUNICIP+"'")
		cDESCIC:=getQuery ( " SELECT SUBSTRING(RCC_CONTEU,5,40) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S014' AND SUBSTRING(RCC_CONTEU,1,4)= '"+SRA->RA_TPCIC+"'")
		cDESJOR:=getQuery ( " SELECT SUBSTRING(RCC_CONTEU,5,100) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S021' AND SUBSTRING(RCC_CONTEU,1,2)= '"+SRA->RA_TJRNDA+"'")
		cDESFON:=getQuery ( " SELECT SUBSTRING(RCC_CONTEU,5,40)  CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S004' AND SUBSTRING(RCC_CONTEU,1,4)= '"+SRA->RA_FONSOL+"'")

		aAdd( aExp, {'GPE_CODRPAT'	,	SRA->RA_CODRPAT														,	"SRA->RA_CODRPAT"  		,STR0180	} )//Codigo do Registro Patronal
		aAdd( aExp, {'GPE_NRPAT'	,	POSICIONE("RCO",1,XFILIAL("RCO")+SRA->RA_CODRPAT,"RCO_NREPAT")		,	"RCO->RCO_NREPAT"  		,STR0207	} )//Codigo do Registro Patronal
		aAdd( aExp, {'GPE_POLRT'	,	POSICIONE("RCO",1,XFILIAL("RCO")+SRA->RA_CODRPAT,"RCO_POLRT")		,	"RCO->RCO_POLRT"   		,STR0208	} )//"Número de Póliza para MTSS"
		aAdd( aExp, {'GPE_SUCCSS'	,	POSICIONE("RCO",1,XFILIAL("RCO")+SRA->RA_CODRPAT,"RCO_SUCCSS")		,	"RCO->RCO_SUCCSS"		,STR0209	} )//"Número de Sucursal del CCSS"
		aAdd( aExp, {'GPE_CODMTSS'	,	POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODMTSS")		,	"SRJ->RJ_CODMTSS"	,STR0210	} )//"Código Ocupación MTSS"
		aAdd( aExp, {'GPE_CODCCSS'	,	POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODCCSS")		,	"SRJ->RJ_CODCCSS"  		,STR0211	} )//"Código Ocupación CCSS"
		aAdd( aExp, {'GPE_CODCINS'	,	POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODINS")		,	"SRJ->RJ_CODINS"   		,STR0212	} )//"Código Ocupación INS"
		aAdd( aExp, {'GPE_DESMTSS'	,	cDESMTSS															,	"!@             "		,STR0213	} )//"Descripción de código Ocupación MTSS"
		aAdd( aExp, {'GPE_DESCCSS'	,	cDESCCSS															,	"!@            "		,STR0214	} )//"Descripción de código Ocupación CCSS"
		aAdd( aExp, {'GPE_DESINS'	,	cDESINS																,	"!@            "   		,STR0215	} )//"Descripción de código Ocupación INS" 	
		aAdd( aExp, {'GPE_KEYLOC'	,	SRA->RA_KEYLOC														,	"SRA->RA_KEYLOC"		,STR0174	} )//Codigo Local de Pagamento
		aAdd( aExp, {'GPE_DESLOC'	,	POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_DESLOC")		,	"RGC->RGC_DESLOC"		,STR0216	} )//"Descripcion Localidad de Pago"
		aAdd( aExp, {'GPE_TNOTRAB'	,	SRA->RA_TNOTRAB														,	"SRA->RA_TNOTRAB"  		,STR0217	} )//"Turno Trabajado"
		aAdd( aExp, {'GPE_HRDIA'	,	POSICIONE("SR6",1,XFILIAL("SR6")+SRA->RA_TNOTRAB,"R6_HRDIA")		,	"SR6->R6_HRDIA"	   		,STR0218	} )//"Horas por Dia"
		aAdd( aExp, {'GPE_BAIRROEMP',	SRA->RA_BAIRRO														,	"SRA->RA_BAIRRO"   		,STR0219	} )//"Distrito donde vive el trabajador"
		aAdd( aExp, {'GPE_PRINOME'	,	SRA->RA_PRINOME														,	"SRA->RA_PRINOME"		,STR0169	} )//Primeiro Nome 
		aAdd( aExp, {'GPE_SECNOME'	,	SRA->RA_SECNOME														,	"SRA->RA_SECNOME"  		,STR0170	} )//Segundo Nome
		aAdd( aExp, {'GPE_PRISOBR'	,	SRA->RA_PRISOBR														,	"SRA->RA_PRISOBR"  		,STR0171	} )//Primeiro Sobrenome
		aAdd( aExp, {'GPE_SECSOBR'	,	SRA->RA_SECSOBR														,	"SRA->RA_SECSOBR"		,STR0172	} )//Segundo Sobrenome
		aAdd( aExp, {'GPE_CANTEMP'	,	SRA->RA_MUNICIP														,	"SRA->RA_MUNICIP"  		,STR0221	} )//"Cantón donde vive el Trabajador"
		aAdd( aExp, {'GPE_DESCCANEMP'	,cDESCAN															,	"!@             "  		,STR0222	} )//"Descripción del cantón donde vive el Trabjador"
		aAdd( aExp, {'GPE_PROVEMP'	,	SRA->RA_ESTADO														,	"SRA->RA_ESTADO"		,STR0223	} )//"Provincia donde vive el Trabjador"
		aAdd( aExp, {'GPE_TIPOFIN'	,	SRA->RA_TIPOFIN														,	"SRA->RA_TIPOFIN"  		,STR0225	} )//"Tipo de Baja de Acuerdo a la Empresa"
		aAdd( aExp, {'GPE_IDENEMP'	,	cDESCIC																,	"SRA->RA_CIC"  	   		,STR0226	} )//"Tipo número de identificación"
		aAdd( aExp, {'GPE_SEGSOC'	,	SRA->RA_RG															,	"SRA->RA_RG"   			,STR0227	} )//"Número de Seguridad Social"
		aAdd( aExp, {'GPE_DESTIPJOR',	cDESJOR																,	"!@            "   		,STR0228	} )//"Descripción Jornada"
		aAdd( aExp, {'GPE_FECAUM'	,	SRA->RA_FECAUM														,	"SRA->RA_FECAUM"   		,STR0229	} )//"Fecha de Modificación de Salario"
		aAdd( aExp, {'GPE_DOMICIL'	,	SRA->RA_DOMICIL														,	"SRA->RA_DOMICIL"		,STR0230	} )//"Extranjero viviendo en el Pais(1=Si; 2=No"
		aAdd( aExp, {'GPE_MOEDAPG'	,	SRA->RA_MOEDAPG														,	"SRA->RA_MOEDAPG"  		,STR0231	} )//Tipo de Moneda para el salario en contrato (1=Local, 2=Dólares)
		aAdd( aExp, {'GPE_FONSOL'	,	SRA->RA_FONSOL 														,	"SRA->RA_FONSOL"		,STR0232	} )//"Asociación Solidarista"

		aAdd( aExp, {'GPE_DESFONSOL',	cDESFON																,	"!@            "   		,STR0233	} )//"Descripción Asociación Solidarista"
		aAdd( aExp, {'GPE_TPCCSS'	,	SRA->RA_TPCCSS														,	"SRA->RA_TPCCSS"   		,STR0234	} )//"Clase Seguro"
		aAdd( aExp, {'GPE_NSEGURO'	,	SRA->RA_NSEGURO														,	"SRA->RA_NSEGURO"  		,STR0235	} )//"Número Asegurado"	
		aAdd( aExp, {'GPE_GROSSUP'	,	SRA->RA_GROSSUP														,	"SRA->RA_GROSSUP"		,STR0236	} )//"Tipo de Gross Up de Salario"
		aAdd( aExp, {'GPE_ANTEAUM'	,	SRA->RA_ANTEAUM														,	"SRA->RA_ANTEAUM"  		,STR0237	} )//"Salario Anterior"	

	EndIf

	If cPaisLoc == "ANG"
		aAdd( aExp, {'GPE_BIDENT'	     ,	SRA->RA_BIDENT                                					, "SRA->RA_BIDENT"			,STR0195	} ) // Nr. Bilhete Identidade
		aAdd( aExp, {'GPE_BIEMISS'	     ,	SRA->RA_BIEMISS                             					, "SRA->RA_BIEMISS"			,STR0196	} )	// Data de Emissao do Bilhete Identidade
		aAdd( aExp, {'GPE_ESTADO'		 ,  Alltrim(fDescRCC("S001",SRA->RA_ESTADO,1,2,3,30))  			, "SRA->RA_ESTADO" 			,STR0032	} ) // Descricao do Distrito
	EndIf

	aAdd( aExp, {'GPE_DESC_EST_CIV'  ,	fDesc("SX5","33"+SRA->RA_ESTCIVI,"X5DESCRI()")	, "SRA->RA_ESTCIVI"	,STR0194	} ) //Descricao do Estado Civil

	If SRA->RA_CATFUNC $ "I*J"

		aRet := fTarProf()

		//Inclusao de variaveis contendo as tarefas fixas e aditamentos fixos dos professores
		aAdd( aExp, {'GPE_DESC_TAR_01'      	,   aRet[1,1], "@!"				, STR0197 	} ) // "Descricao da primeira tarefa"
		aAdd( aExp, {'GPE_AULS_TAR_01'         	,   aRet[1,2], "SRO->RO_QTDSEM"	, STR0198 	} ) // "Aulas por semana da primeira tarefa"
		aAdd( aExp, {'GPE_QTD_TAR_01'         	,   aRet[1,3], "SRO->RO_QUANT"	, STR0199 	} ) // "Quantidade da primeira tarefa"
		aAdd( aExp, {'GPE_VUNI_TAR_01'         	,   aRet[1,4], "SRO->RO_VALOR"	, STR0200 	} ) // "Valor unitario da primeira tarefa"
		aAdd( aExp, {'GPE_VTOT_TAR_01'         	,   aRet[1,5], "SRO->RO_VALTOT"	, STR0201	} ) // "Valor total da primeira tarefa"

		aAdd( aExp, {'GPE_DESC_TAR_02'         	,   aRet[2,1], "@!"          	, STR0202 	} ) // "Descricao da segunda tarefa"
		aAdd( aExp, {'GPE_AULS_TAR_02'         	,   aRet[2,2], "SRO->RO_QTDSEM"	, STR0203 	} ) // "Aulas por semana da segunda tarefa"
		aAdd( aExp, {'GPE_QTD_TAR_02'         	,   aRet[2,3], "SRO->RO_QUANT"	, STR0204 	} ) // "Quantidade da segunda tarefa"
		aAdd( aExp, {'GPE_VUNI_TAR_02'         	,   aRet[2,4], "SRO->RO_VALOR"	, STR0205 	} ) // "Valor unitário da segunda tarefa"
		aAdd( aExp, {'GPE_VTOT_TAR_02'         	,   aRet[2,5], "SRO->RO_VALTOT"	, STR0206 	} ) // "Valor total da segunda tarefa" 

	EndIf

	If cPaisLoc == "BRA"
		//Variaveis criadas para utilizacao no DCN/DMN Documento de Cadastro/Manutencao do NIS - PIS   

		cEstCiv :=SRA->RA_ESTCIVI  					//Adequacao do estado civil conforme o leiaute do DCN/DMN - PIS
		Do Case
		Case cEstCiv$"C|M"
			cEstCiv :="CASADO(A)
		Case cEstCiv$"D"
			cEstCiv :="DIVORCIADO(A)
		Case cEstCiv$"Q"
			cEstCiv :="SEPARADO(A)
		Case cEstCiv$"S"
			cEstCiv :="SOLTEIRO(A)
		Case cEstCiv$"V"
			cEstCiv :="VIUVO(A)
		EndCase

		cTipCertd := SRA->RA_TIPCERT 				//Adequacao da descricao do certificado civil conforme o leiaute do DCN/DMN - PIS
		Do Case
		Case cTipCertd == "1"
			cTipCertd :=OemToAnsi(STR0317)
		Case cTipCertd == "2"
			cTipCertd :=OemToAnsi(STR0318)
		Case cTipCertd == "3"
			cTipCertd :=OemToAnsi(STR0317)
		Case cTipCertd == "4"
			cTipCertd :=OemToAnsi(STR0320)
		EndCase


		cGrauInstr :=SRA->RA_GRINRAI
		Do Case										//Adequacao da descricao do grau de instrucao conforme o leiaute do DCN/DMN - PIS
		Case cGrauInstr == "10"
			cGrauInstr := OemToAnsi(STR0295)
		Case cGrauInstr == "20"
			cGrauInstr := OemToAnsi(STR0296)
		Case cGrauInstr == "25"
			cGrauInstr := OemToAnsi(STR0297)
		Case cGrauInstr == "30"
			cGrauInstr := OemToAnsi(STR0298)
		Case cGrauInstr == "35"
			cGrauInstr := OemToAnsi(STR0299)
		Case cGrauInstr == "40"
			cGrauInstr := OemToAnsi(STR0300)
		Case cGrauInstr == "45"
			cGrauInstr := OemToAnsi(STR0301)
		Case cGrauInstr == "50"
			cGrauInstr := OemToAnsi(STR0302)
		Case cGrauInstr == "55"
			cGrauInstr := OemToAnsi(STR0303)
		Case cGrauInstr == "65"
			cGrauInstr := OemToAnsi(STR0304)
		Case cGrauInstr == "75"
			cGrauInstr := OemToAnsi(STR0305)
		Case cGrauInstr == "85"
			cGrauInstr := OemToAnsi(STR0306)
		Case cGrauInstr == "95"
			cGrauInstr := OemToAnsi(STR0307)																											
		EndCase

		aAdd( aExp, {'GPE_NACION_BRASILEIRA'	,SRA->(IF(RA_BRNASEX$"1","",(IF(RA_NACIONA$"10","x",""))))						 	 		,"SRA->RA_BRNASEX"	, STR0250   } ) // "Marca 'x' se Nacionalidade Brasileira"
		aAdd( aExp, {'GPE_NACION_ESTRANGEIRA'	,SRA->(IF(RA_BRNASEX$"1","",(IF(RA_NACIONA$"10","",(IF(RA_NACIONA$"20","","x"))))))			,"SRA->RA_BRNASEX"	, STR0251   } ) // "Marca 'x' se Nacionalidade Extrangeira"
		aAdd( aExp, {'GPE_NACION_BRA_NATURA'	,SRA->(IF(RA_BRNASEX$"1","",(IF(RA_NACIONA$"10","",(IF(RA_NACIONA$"20","x",""))))))			,"SRA->RA_BRNASEX"	, STR0252   } ) // "Marca 'x' se Nacionalidade Brasileira Naturalizada"
		aAdd( aExp, {'GPE_NACION_BRA_NASC_EXTE'	,SRA->(IF(RA_BRNASEX$"1","x",""))			 													,"SRA->RA_BRNASEX"	, STR0253   } ) // "Marca 'x' se Nacionalidade Brasileiro Nascido no Exterior"
		aAdd( aExp, {'GPE_EST_CIVIL_DCN'  		,cEstCiv																						,"SRA->RA_ESTCIVI"	, STR0254	} ) // "Estado civil de acordo com o NIS/PIS"
		aAdd( aExp, {'GPE_NOME_PAI_DCN'	   		,SRA->(IF(Empty (SRA->RA_PAI),"IGNORADO",SRA->RA_PAI))											,"SRA->RA_PAI"		, STR0255	} ) // "Nome do Pai, informa IGNORADO caso esteja em branco"
		aAdd( aExp, {'GPE_NOME_MAE_DCN'	   		,SRA->(IF(Empty (SRA->RA_MAE),"IGNORADA",SRA->RA_MAE))											,"SRA->RA_MAE"		, STR0256	} ) // "Nome da Mae, informa IGNORADO caso esteja em branco"
		aAdd( aExp, {'GPE_COMPLEM_RG'			,SRA->RA_COMPLRG																				,"SRA->RA_COMPLRG"	, STR0257   } ) // "Complemento do RG"
		aAdd( aExp, {'GPE_TIP_CERTID'			,cTipCertd																						,"SRA->RA_TIPCERT"	, STR0258   } ) // "Tipo de Certidao Civil"
		aAdd( aExp, {'GPE_EMIS_CERTID'			,SRA->RA_EMICERT																				,"SRA->RA_EMICERT"	, STR0259   } ) // "Data de Emissao da Certidao Civil"
		aAdd( aExp, {'GPE_MAT_CERTID'			,SRA->RA_MATCERT																				,"SRA->RA_MATCERT"	, STR0260   } ) // "Termo/Matricula da Certidao Civil"
		aAdd( aExp, {'GPE_LIVRO_CERT'			,SRA->RA_LIVCERT																				,"SRA->RA_LIVCERT"	, STR0261   } ) // "Livro da Certidao Civil"
		aAdd( aExp, {'GPE_FOLHA_CERT'			,SRA->RA_FOLCERT																				,"SRA->RA_FOLCERT"	, STR0262   } ) // "Folha da Certidao Civil"
		aAdd( aExp, {'GPE_CART_CERTID'			,SRA->RA_CARCERT																				,"SRA->RA_CARCERT"	, STR0263   } ) // "Cartorio da Certidao Civil"
		aAdd( aExp, {'GPE_UF_CERTIDAO'			,SRA->RA_UFCERT			 																		,"SRA->RA_UFCERT"	, STR0264   } ) // "UF da Certidao Civil"
		aAdd( aExp, {'GPE_MUN_CERTIDAO'			,fDesc("CC2",SRA->RA_UFCERT+SRA->RA_CDMUCER,"CC2_MUN")											,"SRA->RA_MUNCERT"	, STR0265   } ) // "Municipio da Certidao Civil"
		aAdd( aExp, {'GPE_NUM_PASSAPOR'			,SRA->RA_NUMEPAS																				,"SRA->RA_NUMEPAS"	, STR0266   } ) // "Numero do Passaporte"
		aAdd( aExp, {'GPE_EMIS_PASSAPOR'		,SRA->RA_EMISPAS																				,"SRA->RA_EMISPAS"	, STR0267   } ) // "Orgao Emissor do Passaporte"
		aAdd( aExp, {'GPE_UF_PASSAPORTE'		,SRA->RA_UFPAS  																				,"SRA->RA_UFPAS"	, STR0268   } ) // "UF do Passaporte"
		aAdd( aExp, {'GPE_DT_EMIS_PAS'			,SRA->RA_DEMIPAS																				,"SRA->RA_DEMIPAS"	, STR0269   } ) // "Data Emissao Passaporte"
		aAdd( aExp, {'GPE_DT_VALID_PAS'			,SRA->RA_DVALPAS																				,"SRA->RA_DVALPAS"	, STR0270   } ) // "Data Validade Passaporte"
		aAdd( aExp, {'GPE_PAIS_PASSAPOR'		,fDesc("CCH",SRA->RA_CODPAIS,"CCH_PAIS")														,"SRA->RA_PAISPAS"	, STR0271   } ) // "Pais de Emissao Passaporte"
		aAdd( aExp, {'GPE_NUM_NATURALIZ'		,SRA->RA_NUMNATU																				,"SRA->RA_NUMNATU"	, STR0272   } ) // "Numero de Naturalizacao"
		aAdd( aExp, {'GPE_DATA_NATURALIZ'		,SRA->RA_DATNATU																				,"SRA->RA_DATNATU"	, STR0273   } ) // "Data de Naturalizacao"
		aAdd( aExp, {'GPE_NUMERO_RIC'			,SRA->RA_NUMRIC 																				,"SRA->RA_NUMRIC" 	, STR0274   } ) // "Numero do RIC"
		aAdd( aExp, {'GPE_EMISSAO_RIC'			,SRA->RA_EMISRIC																				,"SRA->RA_EMISRIC"	, STR0275   } ) // "Orgao Emissor do RIC"
		aAdd( aExp, {'GPE_UF_RIC'				,SRA->RA_UFRIC  																				,"SRA->RA_UFRIC"  	, STR0276   } ) // "UF do RIC"
		aAdd( aExp, {'GPE_MUNICIPIO_RIC'		,fDesc("CC2",SRA->RA_UFRIC+SRA->RA_CDMURIC,"CC2_MUN")											,"SRA->RA_MUNIRIC"	, STR0277   } ) // "Municipio do RIC"
		aAdd( aExp, {'GPE_DATA_EXP_RIC'			,SRA->RA_DEXPRIC																				,"SRA->RA_DEXPRIC"	, STR0278   } ) // "Data de Expedicao do RIC"
		aAdd( aExp, {'GPE_TIPO_ENDERECO_COM'	,SRA->(IF(RA_TIPENDE$"1","x" ,""))																,"SRA->RA_TIPENDE"	, STR0279   } ) // "Marca 'x' se Endereco for Comercial"
		aAdd( aExp, {'GPE_TIPO_ENDERECO_RES'	,SRA->(IF(RA_TIPENDE$"2","x" ,""))																,"SRA->RA_TIPENDE"	, STR0280   } ) // "Marca 'x' se Endereco for Residencial"	
		aAdd( aExp, {'GPE_NUM_ENDERECO'			,SRA->RA_NUMENDE																				,"SRA->RA_NUMENDE"	, STR0281   } ) // "Numero do Endereco"
		aAdd( aExp, {'GPE_CAIXA_POSTAL'			,SRA->RA_CPOSTAL																				,"SRA->RA_CPOSTAL"	, STR0282  	} ) // "Caixa Postal"
		aAdd( aExp, {'GPE_CEP_CAIXA_POSTAL'		,SRA->RA_CEPCXPO																				,"SRA->RA_CEPCXPO"	, STR0283	} ) // "CEP da Caixa Postal" 
		aAdd( aExp, {'GPE_DDD_TELEFONE'			,SRA->RA_DDDFONE																				,"SRA->RA_DDDFONE"	, STR0284   } ) // "DDD do Telefone"
		aAdd( aExp, {'GPE_DDD_CELULAR'			,SRA->RA_DDDCELU																				,"SRA->RA_DDDCELU"	, STR0285   } ) // "DDD do Celular"
		aAdd( aExp, {'GPE_NUM_CELULAR'			,SRA->RA_NUMCELU																				,"SRA->RA_NUMCELU"	, STR0286   } ) // "Numero do Celular"
		aAdd( aExp, {'GPE_EMPRESA_TIPO_CNPJ'	,IF(aInfo[15]==2,"x","")																		,"@!"				, STR0287	} ) // "Marca 'x' se Empresa por CNPJ"
		aAdd( aExp, {'GPE_EMPRESA_TIPO_CEI'		,IF(aInfo[15]==1,"x","")																		,"@!"				, STR0288	} ) // "Marca 'x' se Empresa por CEI"
		aAdd( aExp, {'GPE_DATA_CHEGADA'			,SRA->RA_DATCHEG																				,"SRA->RA_DATCHEG"	, STR0289   } ) // "Data de Expedicao do RIC"   	
		aAdd( aExp, {'GPE_SECAO'				,SRA->RA_SECAO												  									,"SRA->RA_SECAO"	, STR0290  	} ) // "Secao Eleitoral"
		aAdd( aExp, {'GPE_INST_DCN'				,cGrauInstr																						,"@!"				, STR0291	} ) // "Grau de Instrucao conforme NIS/PIS"
		aAdd( aExp, {'GPE_PAIS_ORIGEM_PIS'		,SRA->(IF(RA_NACIONA<>"10" .OR. RA_BRNASEX=="1",fDesc("CCH",SRA->RA_CPAISOR,"CCH_PAIS"),""))	,"SRA->RA_PAISORI"	, STR0292   } ) // "Pais de Origem para o DCN/DMN"    
		aAdd( aExp, {'GPE_COD_UF_NASCTO_PIS'	,SRA->(IF(RA_NACIONA=="10" .AND. RA_BRNASEX<>"1",SRA->RA_NATURAL,""))	    					,"SRA->RA_NATURAL"	, STR0308   } ) // "Estado de Nascimento NIS/PIS"     
		aAdd( aExp, {'GPE_MUNICIPIO_NASCTO_PIS'	,SRA->(IF(RA_NACIONA=="10" .AND. RA_BRNASEX<>"1",SRA->RA_MUNNASC,""))							,"SRA->RA_MUNNASC"	, STR0309	} ) // "Municipio de Nascimento NIS/PIS"	
		aAdd( aExp, {'GPE_TIPO_MANUT_NIS_ALTER'	,IF(cTipNIS=="1","x","")																		,"@!"				, STR0310	} )	// "Marca 'x' para tipo de DMN - Alteracao"	
		aAdd( aExp, {'GPE_TIPO_MANUT_NIS_CADAS'	,IF(cTipNIS=="2","x","")																		,"@!"				, STR0311	} )	// "Marca 'x' para tipo de DMN - Cadastro Retroativo"	
		aAdd( aExp, {'GPE_TIPO_MANUT_NIS_CANCE'	,IF(cTipNIS=="3","x","")																		,"@!"				, STR0312	} )	// "Marca 'x' para tipo de DMN - Cancelamento"	
		aAdd( aExp, {'GPE_TIPO_MANUT_NIS_REATI'	,IF(cTipNIS=="4","x","")																		,"@!"				, STR0313	} )	// "Marca 'x' para tipo de DMN - Reativacao"
		aAdd( aExp, {'GPE_TIPO_MANUT_NIS_RETRO'	,IF(cTipNIS=="5","x","")																		,"@!"				, STR0314	} )	// "Marca 'x' para tipo de DMN - Retroacao Cadastral"	
		aAdd( aExp, {'GPE_COD_SEXO_MASCULINO'	,SRA->(IF(RA_SEXO=="M","x",""))																, "SRA->RA_SEXO"	, STR0315	} )	// "Marca 'x' se sexo for Masculino" 
		aAdd( aExp, {'GPE_COD_SEXO_FEMININO'	,SRA->(IF(RA_SEXO=="F","x",""))																, "SRA->RA_SEXO"	, STR0316	} )	// "Marca 'x' se sexo for Feminino" 
		aAdd( aExp, {'GPE_COD_SERVENTIA'		,SRA->RA_SERVENT 																				, "SRA->RA_SERVENT"	, STR0336	} )	// Codigo da Serventia
		aAdd( aExp, {'GPE_COD_ACERVO'			,SRA->RA_CODACER 																				, "SRA->RA_CODACER"	, STR0337	} )	// Codigo do Acervo
		aAdd( aExp, {'GPE_REG_CIVIL'			,SRA->RA_REGCIVI 																				, "SRA->RA_REGCIVI"	, STR0338	} )	// Registro Civil
		aAdd( aExp, {'GPE_TIPO_LIVRO'			,SRA->RA_TPLIVRO																				, "SRA->RA_TPLIVRO"	, STR0339	} )	// Tipo do Livro Reg.


		// Variaveis Personalizadas
	#DEFINE STRz001 "Data de Experiencia 2"  
	#DEFINE STRz002 "Dia da Data de Experiencia 2" 
	#DEFINE STRz003 "Mes da Data de Experiencia 2"
	#DEFINE STRz004 "Ano da Data de Experiencia 2"
	#DEFINE STRz005 "Dias de Experiencia 2"  
	#DEFINE STRz006 "Mes Extenso da Data de Experiencia"
	#DEFINE STRz007 "Mes Extenso da Data de Experiencia 2"
	#DEFINE STRz008 "Data de Experiencia (Exclusivo p/ Relatório)"
	#DEFINE STRz009 "Data de Experiencia 2 (Exclusivo p/ Relatório)"
	#DEFINE STRz010 "Insalubridade (o cadastro do funcionario deve estar 999,99)"  
	#DEFINE STRz011 "Periculosidade (o cadastro do funcionario deve estar 999,99)"  
	#DEFINE STRz012 "Término do Aviso Prévio Trabalhado (Data Base + 30 dias)"  
	#DEFINE STRz013 "CNAE Empresa"  
	#DEFINE STRz014 "Titulo Eleitoral - Zona"  
	#DEFINE STRz015 "Titulo Eleitoral - Secao"  
	#DEFINE STRz016 "Regra de Apontamento"  
	#DEFINE STRz017 "Mes Extenso da Data de Admissao"
	#DEFINE STRz018 "Salario da Data de Admissao"  
	#DEFINE STRz019 "Função da Data de Admissao"
	#DEFINE STRz020 "Extenso Salario da Data de Admissao"  
	#DEFINE STRz021 "Endereço de Entrega da Empresa"  
	#DEFINE STRz022 "Cidade do Endereço de Entrega da Empresa"  
	#DEFINE STRz023 "CEP do Endereço de Entrega da Empresa"  
	#DEFINE STRz024 "Estado do Endereço de Entrega da Empresa"  
	#DEFINE STRz025 "Bairro do do Endereço de Entrega da Empresa"  
	#DEFINE STRz026 "CNH - Orgao Emissor"  
	#DEFINE STRz027 "CNH - Data de Emissao"  
	#DEFINE STRz028 "CNH - Data de Vencimento" 
	#DEFINE STRz029 "Categoria" 
	#DEFINE STRz030 "CPF Dependente 01" 
	#DEFINE STRz031 "Dependente de Imposto de Renda? - Dep01" 
	#DEFINE STRz032 "CPF Dependente 02" 
	#DEFINE STRz033 "Dependente de Imposto de Renda? - Dep02" 
	#DEFINE STRz034 "CPF Dependente 03" 
	#DEFINE STRz035 "Dependente de Imposto de Renda? - Dep03" 
	#DEFINE STRz036 "CPF Dependente 04" 
	#DEFINE STRz037 "Dependente de Imposto de Renda? - Dep04" 
	#DEFINE STRz038 "CPF Dependente 05" 
	#DEFINE STRz039 "Dependente de Imposto de Renda? - Dep05" 
	#DEFINE STRz040 "CPF Dependente 06" 
	#DEFINE STRz041 "Dependente de Imposto de Renda? - Dep06" 
	#DEFINE STRz042 "CPF Dependente 07" 
	#DEFINE STRz043 "Dependente de Imposto de Renda? - Dep07" 
	#DEFINE STRz044 "CPF Dependente 08" 
	#DEFINE STRz045 "Dependente de Imposto de Renda? - Dep08" 
	#DEFINE STRz046 "CPF Dependente 09" 
	#DEFINE STRz047 "Dependente de Imposto de Renda? - Dep09" 
	#DEFINE STRz048 "CPF Dependente 10" 
	#DEFINE STRz049 "Dependente de Imposto de Renda? - Dep10" 
	#DEFINE STRz050 "CPF Dependente SF 01" 
	#DEFINE STRz051 "Dependente de Salario Familia? - Dep01" 
	#DEFINE STRz052 "CPF Dependente SF 02" 
	#DEFINE STRz053 "Dependente de Salario Familia? - Dep02" 
	#DEFINE STRz054 "CPF Dependente SF 03" 
	#DEFINE STRz055 "Dependente de Salario Familia? - Dep03" 
	#DEFINE STRz056 "CPF Dependente SF 04" 
	#DEFINE STRz057 "Dependente de Salario Familia? - Dep04" 
	#DEFINE STRz058 "CPF Dependente SF 05" 
	#DEFINE STRz059 "Dependente de Salario Familia? - Dep05" 
	#DEFINE STRz060 "CPF Dependente SF 06" 
	#DEFINE STRz061 "Dependente de Salario Familia? - Dep06" 
	#DEFINE STRz062 "CPF Dependente SF 07" 
	#DEFINE STRz063 "Dependente de Salario Familia? - Dep07" 
	#DEFINE STRz064 "CPF Dependente SF 08" 
	#DEFINE STRz065 "Dependente de Salario Familia? - Dep08" 
	#DEFINE STRz066 "CPF Dependente SF 09" 
	#DEFINE STRz067 "Dependente de Salario Familia? - Dep09" 
	#DEFINE STRz068 "CPF Dependente SF 10" 
	#DEFINE STRz069 "Dependente de Salario Familia? - Dep10" 
	#DEFINE STRz070 "Data fim do contrato de trabalho determinado" 
	#DEFINE STRz071 "Endereço de email do supervisor"
	#DEFINE STRz072 "Tipo Dependente eSocial"
		
		//Categoria do Funcionario
		cCatFunc :=SRA->RA_CATFUNC  					
		Do Case
		Case cCatFunc$"A"
				cCatFunc :="AUTONOMO" 
		Case cCatFunc$"C"
				cCatFunc :="COMISSIONADO"
		Case cCatFunc$"D"
				cCatFunc :="DIARISTA"
		Case cCatFunc$"E|G"
				cCatFunc :="ESTAGIARIO"
		Case cCatFunc$"H"
				cCatFunc :="HORISTA"
		Case cCatFunc$"I|J"
				cCatFunc :="PROFESSOR"
		Case cCatFunc$"M"
				cCatFunc :="MENSALISTA"
		Case cCatFunc$"P"
				cCatFunc :="PRO-LABORE"
		Case cCatFunc$"S"
				cCatFunc :="SEMANALISTA"
		Case cEstCiv$"T"
				cCatFunc :="TAREFEIRO"
		EndCase

		// Gera as  variaveis para o 2o. Vencimento de Experiencia
		aAdd( aExp, {'GPE_DATA_EXPERIENCIA2'	,	SRA->RA_VCTEXP2								, "SRA->RA_VCTEXP2"			,STRz001	} )
		aAdd( aExp, {'GPE_DIA_EXPERIENCIA2' 	,	StrZero( Day( SRA->RA_VCTEXP2 ) , 2 )		, "@!"						,STRz002	} )
		aAdd( aExp, {'GPE_MES_EXPERIENCIA2'		,	StrZero( Month( SRA->RA_VCTEXP2 ) , 2 )		, "@!"						,STRz003	} )
		aAdd( aExp, {'GPE_ANO_EXPERIENCIA2'		,	StrZero( Year( SRA->RA_VCTEXP2 ) , 4 ) 		, "@!"						,STRz004	} )
		aAdd( aExp, {'GPE_DIAS_EXPERIENCIA2'	,	StrZero(SRA->(RA_VCTEXP2-RA_ADMISSA)+1,03)	, "@!"						,STRz005	} )
		aAdd( aExp, {'GPE_MES_EXPERIENCIAEXT'	,	MesExtenso( Month( SRA->RA_VCTOEXP ) )		, "@!"						,STRz006	} )
		aAdd( aExp, {'GPE_MES_EXPERIENCIA2EXT'	,	MesExtenso( Month( SRA->RA_VCTEXP2 ) )		, "@!"						,STRz007	} )
		aAdd( aExp, {'GPE_EXPERIENCIA'		,	SRA->RA_VCTOEXP											, "SRA->RA_VCTOEXP"			,STRz008	} )
		aAdd( aExp, {'GPE_EXPERIENCIA2'		,	SRA->RA_VCTEXP2											, "SRA->RA_VCTEXP2"			,STRz009	} )
		aAdd( aExp, {'GPE_MES_ADMISSAOEXT'	,	MesExtenso( Month( SRA->RA_ADMISSA ) )		, "@!"						,STRz017	} )
		aAdd( aExp, {'GPE_TIT_ZONA'  			,	SubStr(SRA->RA_ZONASEC,1,3)							 				, "SRA->RA_ZONASEC"			,STRz014	} ) 
		aAdd( aExp, {'GPE_TIT_SECAO'  			,	SubStr(SRA->RA_ZONASEC,5,5)							 				, "SRA->RA_ZONASEC"			,STRz015	} ) 
		aAdd( aExp, {'GPE_CNH_EMISSOR'   	  			,	SRA->RA_CNHORG							 				, "SRA->RA_CNHORG"			,STRz026	} ) 
		aAdd( aExp, {'GPE_CNH_EMISSAO'   	  			,	SRA->RA_DTEMCNH							 				, "SRA->RA_DTEMCNH"			,STRz027	} ) 
		aAdd( aExp, {'GPE_CNH_VENCIMENTO'   	  			,	SRA->RA_DTVCCNH							 				, "SRA->RA_DTVCCNH"			,STRz028	} ) 
		aAdd( aExp, {'GPE_CATEG_FUNCIONARIO', cCatFunc													,"SRA->RA_CATFUNC"	        ,STRz029	} ) // "Estado civil de acordo com o NIS/PIS"
	
		// Marcelo - Facile Sistemas - 1402 - os 12436 - ADICIONADO CAMPO TIPO DEPENDENTE ESOCIAL
		aAdd( aExp, {'GPE_TPDEP01'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[1,6],IF(nDepen==1,aDepenSF[1,13],space(2)))	, "@!"						,STRz072   } )
	    aAdd( aExp, {'GPE_TPDEP02'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[2,6],IF(nDepen==1,aDepenSF[2,13],space(2)))	, "@!"						,STRz072   } )
	    aAdd( aExp, {'GPE_TPDEP03'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[3,6],IF(nDepen==1,aDepenSF[3,13],space(2)))	, "@!"						,STRz072   } ) 
	    aAdd( aExp, {'GPE_TPDEP04'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[4,6],IF(nDepen==1,aDepenSF[4,13],space(2)))	, "@!"						,STRz072   } )
	    aAdd( aExp, {'GPE_TPDEP05'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[5,6],IF(nDepen==1,aDepenSF[5,13],space(2)))	, "@!"						,STRz072   } )
	    aAdd( aExp, {'GPE_TPDEP06'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[6,6],IF(nDepen==1,aDepenSF[6,13],space(2)))	, "@!"						,STRz072   } )
	    aAdd( aExp, {'GPE_TPDEP07'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[7,6],IF(nDepen==1,aDepenSF[7,13],space(2)))	, "@!"						,STRz072   } )
	    aAdd( aExp, {'GPE_TPDEP08'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[8,6],IF(nDepen==1,aDepenSF[8,13],space(2)))	, "@!"						,STRz072   } )
    	aAdd( aExp, {'GPE_TPDEP09'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[9,6],IF(nDepen==1,aDepenSF[9,13],space(2)))	, "@!"						,STRz072   } )
    	aAdd( aExp, {'GPE_TPDEP10'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[10,6],IF(nDepen==1,aDepenSF[10,13],space(2)))	, "@!"						,STRz072   } )

		//Gera Variaveis de Dependentes de IR (CPF e Tipo)
		aAdd( aExp, {'GPE_CPFDEP01'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[1,4],space(11))	, "@!"						,STRz030   } )
		aAdd( aExp, {'GPE_TpDp01'			,	if(nDepen==2 .or. nDepen==3,aDepenIR[1,5],space(1))		, "@!"						,STRz031 	} ) 
		aAdd( aExp, {'GPE_CPFDEP02'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[2,4],space(11))	, "@!"						,STRz032   } )
		aAdd( aExp, {'GPE_TpDp02'			,	if(nDepen==2 .or. nDepen==3,aDepenIR[2,5],space(1))		, "@!"						,STRz033 	} ) 
		aAdd( aExp, {'GPE_CPFDEP03'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[3,4],space(11))	, "@!"						,STRz034   } )
		aAdd( aExp, {'GPE_TpDp03'			,	if(nDepen==2 .or. nDepen==3,aDepenIR[3,5],space(1))		, "@!"						,STRz035 	} ) 
		aAdd( aExp, {'GPE_CPFDEP04'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[4,4],space(11))	, "@!"						,STRz036   } )
		aAdd( aExp, {'GPE_TpDp04'			,	if(nDepen==2 .or. nDepen==3,aDepenIR[4,5],space(1))		, "@!"						,STRz037 	} ) 
		aAdd( aExp, {'GPE_CPFDEP05'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[5,4],space(11))	, "@!"						,STRz038   } )
		aAdd( aExp, {'GPE_TpDp05'			,	if(nDepen==2 .or. nDepen==3,aDepenIR[5,5],space(1))		, "@!"						,STRz039 	} ) 
		aAdd( aExp, {'GPE_CPFDEP06'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[6,4],space(11))	, "@!"						,STRz040   } )
		aAdd( aExp, {'GPE_TpDp06'			,	if(nDepen==2 .or. nDepen==3,aDepenIR[6,5],space(1))		, "@!"						,STRz041 	} ) 
		aAdd( aExp, {'GPE_CPFDEP07'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[7,4],space(11))	, "@!"						,STRz042   } )
		aAdd( aExp, {'GPE_TpDp07'			,	if(nDepen==2 .or. nDepen==3,aDepenIR[7,5],space(1))		, "@!"						,STRz043 	} ) 
		aAdd( aExp, {'GPE_CPFDEP08'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[8,4],space(11))	, "@!"						,STRz044   } )
		aAdd( aExp, {'GPE_TpDp08'			,	if(nDepen==2 .or. nDepen==3,aDepenIR[8,5],space(1))		, "@!"						,STRz045 	} ) 
		aAdd( aExp, {'GPE_CPFDEP09'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[9,4],space(11))	, "@!"						,STRz046   } )
		aAdd( aExp, {'GPE_TpDp09'			,	if(nDepen==2 .or. nDepen==3,aDepenIR[9,5],space(1))		, "@!"						,STRz047 	} ) 
		aAdd( aExp, {'GPE_CPFDEP10'         ,   if(nDepen==2 .or. nDepen==3,aDepenIR[10,4],space(11))	, "@!"						,STRz048   } )
		aAdd( aExp, {'GPE_TpDp10'			,	if(nDepen==2 .or. nDepen==3,aDepenIR[10,5],space(1))	, "@!"						,STRz049 	} ) 
	
		//Gera Variaveis de Dependentes de SF (CPF e Tipo)
		aAdd( aExp, {'GPE_CPFDEPSF01'       ,   if(nDepen==1 .or. nDepen==3,aDepenSF[1,11],space(11))	, "@!"						,STRz050 	} )
		aAdd( aExp, {'GPE_TpDpSF01'         ,   if(nDepen==1 .or. nDepen==3,aDepenSF[1,12],space(1))	, ""						,STRz051 	} )
		aAdd( aExp, {'GPE_CPFDEPSF02'       ,   if(nDepen==1 .or. nDepen==3,aDepenSF[2,11],space(11))	, "@!"						,STRz052 	} )
		aAdd( aExp, {'GPE_TpDpSF02'         ,   if(nDepen==1 .or. nDepen==3,aDepenSF[2,12],space(1))	, ""						,STRz053 	} )
		aAdd( aExp, {'GPE_CPFDEPSF03'       ,   if(nDepen==1 .or. nDepen==3,aDepenSF[3,11],space(11))	, "@!"						,STRz054 	} )
		aAdd( aExp, {'GPE_TpDpSF03'         ,   if(nDepen==1 .or. nDepen==3,aDepenSF[3,12],space(1))	, ""						,STRz055 	} )
		aAdd( aExp, {'GPE_CPFDEPSF04'       ,   if(nDepen==1 .or. nDepen==3,aDepenSF[4,11],space(11))	, "@!"						,STRz056 	} )
		aAdd( aExp, {'GPE_TpDpSF04'         ,   if(nDepen==1 .or. nDepen==3,aDepenSF[4,12],space(1))	, ""						,STRz057 	} )
		aAdd( aExp, {'GPE_CPFDEPSF05'       ,   if(nDepen==1 .or. nDepen==3,aDepenSF[5,11],space(11))	, "@!"						,STRz058 	} )
		aAdd( aExp, {'GPE_TpDpSF05'         ,   if(nDepen==1 .or. nDepen==3,aDepenSF[5,12],space(1))	, ""						,STRz059 	} )
		aAdd( aExp, {'GPE_CPFDEPSF06'       ,   if(nDepen==1 .or. nDepen==3,aDepenSF[6,11],space(11))	, "@!"						,STRz060 	} )
		aAdd( aExp, {'GPE_TpDpSF06'         ,   if(nDepen==1 .or. nDepen==3,aDepenSF[6,12],space(1))	, ""						,STRz061 	} )
		aAdd( aExp, {'GPE_CPFDEPSF07'       ,   if(nDepen==1 .or. nDepen==3,aDepenSF[7,11],space(11))	, "@!"						,STRz062 	} )
		aAdd( aExp, {'GPE_TpDpSF07'         ,   if(nDepen==1 .or. nDepen==3,aDepenSF[7,12],space(1))	, ""						,STRz063 	} )
		aAdd( aExp, {'GPE_CPFDEPSF08'       ,   if(nDepen==1 .or. nDepen==3,aDepenSF[8,11],space(11))	, "@!"						,STRz064 	} )
		aAdd( aExp, {'GPE_TpDpSF08'         ,   if(nDepen==1 .or. nDepen==3,aDepenSF[8,12],space(1))	, ""						,STRz065 	} )
		aAdd( aExp, {'GPE_CPFDEPSF09'       ,   if(nDepen==1 .or. nDepen==3,aDepenSF[9,11],space(11))	, "@!"						,STRz066 	} )
		aAdd( aExp, {'GPE_TpDpSF09'         ,   if(nDepen==1 .or. nDepen==3,aDepenSF[9,12],space(1))	, ""						,STRz067 	} )
		aAdd( aExp, {'GPE_CPFDEPSF10'       ,   if(nDepen==1 .or. nDepen==3,aDepenSF[10,11],space(11))	, "@!"						,STRz068 	} )
		aAdd( aExp, {'GPE_TpDpSF10'         ,   if(nDepen==1 .or. nDepen==3,aDepenSF[10,12],space(1))	, ""						,STRz069 	} )
		aAdd( aExp, {'GPE_DTFIMCT'          ,   SRA->RA_DTFIMCT	                                        , ""						,STRz070 	} )
		aAdd( aExp, {'GPE_YSEMAIL'          ,   SRA->RA_YSEMAIL	                                        , ""						,STRz071 	} )
	
		aAdd( aExp, {'GPE_CPFDEPSF01'       ,   if(nDepen==1 .or. nDepen==3,aDepenSF[1,11],space(11))	, "@!"						,STRz050 	} )
	
		//
		// Endereco Empresa
		//* Busca descricao empresa*/
		cEndEntrega := ""
		cCidEntrega := ""
		cCepEntrega := ""
		cEstEntrega := ""
		cBaiEntrega := ""
	
		//dbSelectArea( "SM0" )
		//nReg := Recno()
		//if dbSeek( SRA->RA_FILIAL )
		cEndEntrega := SM0->M0_ENDENT
		cCidEntrega := SM0->M0_CIDENT
		cCepEntrega := SM0->M0_CEPENT
		cEstEntrega := SM0->M0_ESTENT
		cBaiEntrega := SM0->M0_BAIRENT
		//Endif
		//DBGotop( nReg )
		/* Fim da pesquisa */	
		aAdd( aExp, {'GPE_END_EMPRESA_ENT'		,	cEndEntrega                       , "@!"						,STRz021	} )
		aAdd( aExp, {'GPE_CID_EMPRESA_ENT'		,	cCidEntrega                       , "@!"						,STRz022	} )
		aAdd( aExp, {'GPE_CEP_EMPRESA_ENT'    , cCepEntrega                       , "!@R #####-###" ,STRz023 	} )
		aAdd( aExp, {'GPE_EST_EMPRESA_ENT'    , cEstEntrega												, "@!"						,STRz024 	} )
		aAdd( aExp, {'GPE_BAI_EMPRESA_ENT'		,	cBaiEntrega                       , "@!" 						,STRz025	} )
	
		//
		// Verifica se o funcionario possui Insalubridade ou Periculosidade
		If (SRA->RA_PERICUL <> 0.00)
			cIndPericul = '+ 30% de Adicional de Periculosidade'
		Else
			cIndPericul = ' '
		EndIf
	
		If (SRA->RA_INSMIN <> 0.00)
			cIndInsalub = '+ 10% de Adicional de Insalubridade'
		ElseIf (SRA->RA_INSMED <> 0.00)
			cIndInsalub = '+ 20% de Adicional de Insalubridade'
		ElseIf (SRA->RA_INSMAX <> 0.00)
			cIndInsalub = '+ 40% de Adicional de Insalubridade'
		Else
			cIndInsalub = ' '
		EndIf
		//Variaveis que retornam o Adicional de Insalubridade ou Periculosidade
		cIndInsalub := fGetInsalub(SRA->RA_ADCINS)
		aAdd( aExp, {'GPE_INSALUBRIDADE'		    ,	cIndInsalub												    , "@!"						,STRz010	} )
		aAdd( aExp, {'GPE_PERICULOSIDADE'		    ,	cIndPericul												    , "@!"						,STRz011	} )
		aAdd( aExp, {'GPE_FIMAVISO'			,	dDataBase+30                    	        				, "" 						,STRz012	} )
	
		//Variaveis para Folha de Ponto
		aAdd( aExp, {'GPE_CNAE_EMPRESA' 			,	aInfo[16]             									, "@R ##.##-#-##"	,STRz013	} )
		aAdd( aExp, {'GPE_REGRA_APONTA'	 		,	SRA->RA_REGRA											, "SRA->RA_REGRA"			,STRz016	} )
	
		//|Alteracoes para buscar salario e cargo de admissao |
		aAreaSR3 := SR3->(GetArea())
		aAreaSR7 := SR7->(GetArea())
	
		nSalario := 0
		dbSelectArea("SR3")
		SR3->(dbSetOrder(1))
		If !SR3->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + DTOS(SRA->RA_ADMISSA)))
			nSalario := SRA->RA_SALARIO
		Else
			nSalario := SR3->R3_VALOR
		EndIf
	
		cFuncOrig := 0
		dbSelectArea("SR7")
		SR7->(dbSetOrder(1))
		If !SR7->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + DTOS(SRA->RA_ADMISSA)))
			cFuncOrig := fDesc('SRJ',SRA->RA_CODFUNC,'RJ_DESC')
		Else
			cFuncOrig := SR7->R7_DESCFUN
		EndIf
	
		aAdd( aExp, {'GPE_SAL_ADMISSA' 			,	nSalario           									      , "@E 999,999,999.99"		,STRz018	} )
		aAdd( aExp, {'GPE_FUNC_ADMISSA'	 		,	cFuncOrig											            , "@!"						      ,STRz019	} )
		aAdd( aExp, {'GPE_EXT_SAL_ADMISSA'	,	Extenso( nSalario , .F. , 1 )					    , "@!"						      ,STRz020 	} )
	
		RestArea(aAreaSR3)
		RestArea(aAreaSR7)
	
		// Busca Valores para o plano de saude. Implementado por Marcos Alberto em 07/03/12
		xfPart := -1
		xfVlrTotP := 0
		AK001 := " SELECT RHK_MAT MATRIC,
		AK001 += "        '00' DEPEND,
		AK001 += "        (SELECT RCC_CONTEU
		AK001 += "           FROM "+RetSqlName("RCC")+" RCC
		AK001 += "          WHERE RCC_FILIAL = '"+xFilial("RCC")+"'
		AK001 += "            AND RCC_CODIGO = 'S008'
		AK001 += "            AND SUBSTRING(RCC_CONTEU, 1, 2) = RHK_PLANO
		AK001 += "            AND RCC_CHAVE IN(SELECT MAX(RCC_CHAVE)
		AK001 += "                               FROM "+RetSqlName("RCC")+" XRCC
		AK001 += "                              WHERE RCC_FILIAL = '"+xFilial("RCC")+"'
		AK001 += "                                AND RCC_CODIGO = 'S008'
		AK001 += "                                AND SUBSTRING(RCC_CONTEU, 1, 2) = RHK_PLANO
		AK001 += "                                AND XRCC.D_E_L_E_T_ = ' ')
		AK001 += "            AND SUBSTRING(RCC_CONTEU, 25, 10) IN (SELECT MAX(SUBSTRING(RCC_CONTEU, 25, 10))
		AK001 += "                                                    FROM "+RetSqlName("RCC")+" XRCC
		AK001 += "                                                   WHERE RCC_FILIAL = '"+xFilial("RCC")+"'
		AK001 += "                                                     AND RCC_CODIGO = 'S008'
		AK001 += "                                                     AND SUBSTRING(RCC_CONTEU, 1, 2) = RHK_PLANO
		AK001 += "                                                     AND RCC_CHAVE IN(SELECT MAX(RCC_CHAVE)
		AK001 += "                                                                        FROM "+RetSqlName("RCC")+" XRCC
		AK001 += "                                                                       WHERE RCC_FILIAL = '"+xFilial("RCC")+"'
		AK001 += "                                                                         AND RCC_CODIGO = 'S008'
		AK001 += "                                                                         AND SUBSTRING(RCC_CONTEU, 1, 2) = RHK_PLANO
		AK001 += "                                                                         AND XRCC.D_E_L_E_T_ = ' ')
		AK001 += "                                                     AND CONVERT(NUMERIC, SUBSTRING(RCC_CONTEU, 25, 10)) <= RA_SALARIO
		AK001 += "                                                     AND XRCC.D_E_L_E_T_ = ' ')
		AK001 += "            AND RCC.D_E_L_E_T_ = ' ') CONTEUDP
		AK001 += "   FROM "+RetSqlName("RHK")+" RHK
		AK001 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
		AK001 += "                       AND RA_MAT = RHK_MAT
		AK001 += "                       AND SRA.D_E_L_E_T_ = ' '
		AK001 += "  WHERE RHK_FILIAL = '"+xFilial("RHK")+"'
		AK001 += "    AND RHK_MAT = '000042'
		AK001 += "    AND RHK_PLANO IN( 'E4', 'E5' )
		AK001 += "    AND RHK.D_E_L_E_T_ = ' '
		AK001 += " UNION ALL
		AK001 += " SELECT RHL_MAT MATRIC,
		AK001 += "        RHL_CODIGO DEPEND,
		AK001 += "        ' ' CONTEUDP
		AK001 += "   FROM "+RetSqlName("RHL")
		AK001 += "  WHERE RHL_FILIAL = '"+xFilial("RHL")+"'
		AK001 += "    AND RHL_MAT = '"+SRA->RA_MAT+"'
		AK001 += "    AND RHL_PLANO IN('E4','E5')
		AK001 += "    AND D_E_L_E_T_ = ' '
		TcQuery AK001 New Alias "AK01"
		dbSelectArea("AK01")
		dbGoTop()
		bs_AsVlMTt := Val(Alltrim(Substr(AK01->CONTEUDP, 36, 11)) )
		bs_AsPrMTt := (Val(Alltrim(Substr(AK01->CONTEUDP, 36, 11)))) * (Val(Alltrim(Substr(AK01->CONTEUDP, 71, 07)))) / 100
		bs_AsVlMDp := Val(Alltrim(Substr(AK01->CONTEUDP, 48, 11)) )
		bs_AsPrMDp := (Val(Alltrim(Substr(AK01->CONTEUDP, 48, 11)))) * (Val(Alltrim(Substr(AK01->CONTEUDP, 78, 07)))) / 100
		While !Eof() .or. xfPart <= 10
	
			sl_AsVlMTt := Transform( bs_AsVlMTt, "@E 999,999.99")
			sl_AsPrMTt := Transform( bs_AsPrMTt, "@E 999,999.99")
			sl_AsVlMDp := Transform( bs_AsVlMDp, "@E 999,999.99")
			sl_AsPrMDp := Transform( bs_AsPrMDp, "@E 999,999.99")
			xfPart ++
			xfDepn := StrZero(xfPart,2)
			If AK01->DEPEND <> StrZero(xfPart,2) .and. xfPart <= 10
				sl_AsVlMTt := ""
				sl_AsPrMTt := ""
				sl_AsVlMDp := ""
				sl_AsPrMDp := ""
				dbSkip(-1)
			Else
				If AK01->DEPEND == "00"
					xfVlrTotP += bs_AsPrMTt
				Else
					xfVlrTotP += bs_AsPrMDp
				EndIf
			EndIf
	
			If xfDepn == "00"
				aAdd( aExp, {'GPE_ASVLM00'          , sl_AsVlMTt          , ""                  , STR0001  } )
				aAdd( aExp, {'GPE_ASPRM00'          , sl_AsPrMTt          , ""                  , STR0001  } )
			EndIf
			If xfDepn == "01"
				aAdd( aExp, {'GPE_ASVLM01'          , sl_AsVlMDp          , ""                  , STR0001  } )
				aAdd( aExp, {'GPE_ASPRM01'          , sl_AsPrMDp          , ""                  , STR0001  } )
			EndIf
			If xfDepn == "02"
				aAdd( aExp, {'GPE_ASVLM02'          , sl_AsVlMDp          , ""                  , STR0001  } )
				aAdd( aExp, {'GPE_ASPRM02'          , sl_AsPrMDp          , ""                  , STR0001  } )
			EndIf
			If xfDepn == "03"
				aAdd( aExp, {'GPE_ASVLM03'          , sl_AsVlMDp          , ""                  , STR0001  } )
				aAdd( aExp, {'GPE_ASPRM03'          , sl_AsPrMDp          , ""                  , STR0001  } )
			EndIf
			If xfDepn == "04"
				aAdd( aExp, {'GPE_ASVLM04'          , sl_AsVlMDp          , ""                  , STR0001  } )
				aAdd( aExp, {'GPE_ASPRM04'          , sl_AsPrMDp          , ""                  , STR0001  } )
			EndIf
			If xfDepn == "05"
				aAdd( aExp, {'GPE_ASVLM05'          , sl_AsVlMDp          , ""                  , STR0001  } )
				aAdd( aExp, {'GPE_ASPRM05'          , sl_AsPrMDp          , ""                  , STR0001  } )
			EndIf
			If xfDepn == "06"
				aAdd( aExp, {'GPE_ASVLM06'          , sl_AsVlMDp          , ""                  , STR0001  } )
				aAdd( aExp, {'GPE_ASPRM06'          , sl_AsPrMDp          , ""                  , STR0001  } )
			EndIf
			If xfDepn == "07"
				aAdd( aExp, {'GPE_ASVLM07'          , sl_AsVlMDp          , ""                  , STR0001  } )
				aAdd( aExp, {'GPE_ASPRM07'          , sl_AsPrMDp          , ""                  , STR0001  } )
			EndIf
			If xfDepn == "08"
				aAdd( aExp, {'GPE_ASVLM08'          , sl_AsVlMDp          , ""                  , STR0001  } )
				aAdd( aExp, {'GPE_ASPRM08'          , sl_AsPrMDp          , ""                  , STR0001  } )
			EndIf
			If xfDepn == "09"
				aAdd( aExp, {'GPE_ASVLM09'          , sl_AsVlMDp          , ""                  , STR0001  } )
				aAdd( aExp, {'GPE_ASPRM09'          , sl_AsPrMDp          , ""                  , STR0001  } )
			EndIf
			If xfDepn == "10"
				aAdd( aExp, {'GPE_ASVLM10'          , sl_AsVlMDp          , ""                  , STR0001  } )
				aAdd( aExp, {'GPE_ASPRM10'          , sl_AsPrMDp          , ""                  , STR0001  } )
			EndIf
	
			dbSelectArea("AK01")
			dbSkip()
		End
		AK01->(dbCloseArea())
		aAdd( aExp, {'GPE_ASTOTPL'          , Round(xfVlrTotP,2)                       , "@E 999,999.99"     , STR0001  } )
		aAdd( aExp, {'GPE_ASTOTEX'          , Extenso( xfVlrTotP , .F. , 1 )           , ""                  , STR0001  } )
	
		// Busca Valores para o plano de saude. Implementado por Marcos Alberto em 07/03/12
	
		AK002 := "SELECT TOP 1 RB7.RB7_DATALT "
		AK002 += "    , (SELECT SX5.X5_DESCRI FROM " + RetSqlName("SX5") + " SX5 WHERE SX5.X5_TABELA = '41' AND SX5.X5_CHAVE = RB7.RB7_TPALT AND SX5.D_E_L_E_T_ = '') AS TPALT "
		AK002 += "    , SRJ.RJ_DESC "
		AK002 += "    , RB7.RB7_SALARI "
		AK002 += "    , RB7.RB7_PERCEN "
		AK002 += "    , RB7.RB7_YCCDES "
		AK002 += "    , RB7.RB7_YCLVLD "
		AK002 += "    , RB7.RB7_YDEPTO "
		AK002 += "    , RB7.RB7_YADICI "
		AK002 += "    , RB7.RB7_YEMPDE "
		AK002 += "FROM " + RetSqlName("RB7") + " RB7 "
		AK002 += "    LEFT JOIN " + RetSqlName("SRJ") + " SRJ ON RB7.RB7_FUNCAO = SRJ.RJ_FUNCAO "
		AK002 += "	   AND SRJ.D_E_L_E_T_ = '' "
		AK002 += "WHERE RB7.RB7_FILIAL= '" + xFilial("RB7") + "' "
		AK002 += "    AND RB7.RB7_MAT = '" + SRA->RA_MAT + "' "
		AK002 += "    AND RB7.RB7_DTPROC = '        ' "
		AK002 += "    AND RB7.D_E_L_E_T_ = '' "
		AK002 += "ORDER BY RB7.RB7_DATALT DESC "
		TcQuery AK002 New Alias "AK02"
		dbSelectArea("AK02")
		dbGoTop()
	
		If !Eof()
			aAdd(aExp, {'GPE_DATA_ALT', stod(AK02->RB7_DATALT), "", STR0001})
			aAdd(aExp, {'GPE_MOTIVO_ALT', AK02->TPALT, "@!", STR0001})
			aAdd(aExp, {'GPE_DESC_NOVA_FUNCAO', AK02->RJ_DESC, "@!", STR0001})
			aAdd(aExp, {'GPE_NOVO_SALARIO', AK02->RB7_SALARI, "@E 999,999,999.99", STR0001})
			aAdd(aExp, {'GPE_PERCENT_AUMENT', AK02->RB7_PERCEN, "@E 999,999.99", STR0001})
			aAdd(aExp, {'GPE_VALOR_AUMENT', AK02->RB7_SALARI - SRA->RA_SALARIO, "@E 999,999,999.99", STR0001})
	
			dfrEmprDet := ""
			If AK02->RB7_YEMPDE == "01"
				dfrEmprDet := "Biancogres"
			ElseIf AK02->RB7_YEMPDE == "05"
				dfrEmprDet := "Incesa Revest."
			ElseIf AK02->RB7_YEMPDE == "06"
				dfrEmprDet := "JK"
			ElseIf AK02->RB7_YEMPDE == "13"
				dfrEmprDet := "Mundi"
			ElseIf AK02->RB7_YEMPDE == "14"
				dfrEmprDet := "Vitcer"
			ElseIf AK02->RB7_YEMPDE == "15"
				dfrEmprDet := "Fazenda"
			EndIf
			aAdd(aExp, {'GPE_EMPRESA_DESTINO', dfrEmprDet, "@!", STR0001})
			aAdd(aExp, {'GPE_DESC_DEPTO_DESTINO', Posicione("SQB", 1, xFilial("SQB")+AK02->RB7_YDEPTO, "QB_DESCRIC"), "", STR0001})
			aAdd(aExp, {'GPE_DESC_CCUSTO_DESTINO', Posicione("CTT", 1, xFilial("CTT")+AK02->RB7_YCCDES, "CTT_DESC01"), "", STR0001})
			dfrTipoAdc := ""
			If AK02->RB7_YADICI == "2"
				dfrTipoAdc := "Periculosidade"
			ElseIf AK02->RB7_YADICI == "3"
				dfrTipoAdc := "Insalubridade mínima"
			ElseIf AK02->RB7_YADICI == "4"
				dfrTipoAdc := "Insalubridade Média"
			ElseIf AK02->RB7_YADICI == "5"
				dfrTipoAdc := "Insalubridade máxima"
			EndIf
			aAdd(aExp, {'GPE_ADICIONAIS_DESTINO', dfrTipoAdc, "@!", STR0001})
			aAdd(aExp, {'GPE_CLASSE_VALOR_DESTINO', AK02->RB7_YCLVLD, "", STR0001})
			aAdd(aExp, {'GPE_DESC_CLASSE_VALOR_DESTINO', Posicione("CTH", 1, xFilial("CTH")+AK02->RB7_YCLVLD, "CTH_DESC01"), "", STR0001})
	
		End
		AK02->(dbCloseArea())
	
		cDifDatas = DATEDIFFYMD(SRA->RA_ADMISSA,dDatabase)
		aAdd(aExp, {'GPE_TEMPO_CASA', Alltrim(Str(cDifDatas[01])) + " ano(s), " + Alltrim(Str(cDifDatas[02])) + " mes(es), " + Alltrim(Str(cDifDatas[03])) + " dia(s)", "", STR0001})
		aAdd(aExp, {'GPE_EMPRESA', SM0->M0_NOME, "", STR0001})
	
		aAdd(aExp, {'GPE_DESC_DEPTO', Posicione("SQB", 1, xFilial("SQB")+SRA->RA_DEPTO, "QB_DESCRIC"), "", "Descr. Departamento"})

	EndIf

	//|Customização para buscar o período das férias |
	//|Regra enviada pela Sadila |
	aFerias	:= fBuscaFerias(SRA->RA_MAT)
	// Estrutura do aFerias
	// 1 - Inicio período aquisitivo
	// 2 - Final período aquisitivo
	// 3 - Inicio da primeira férias
	// 4 - Final da primeira férias
	// 5 - Inicio da segunda férias
	// 6 - Final da segunda férias

	//|Período aquisitivo |
	cFerAquisitivo 	:= DtoC( aFerias[1] ) + " a " + DtoC( aFerias[2] )
	aAdd(aExp, {'GPE_FERIAS_AQUISITIVO', cFerAquisitivo, "", "Periodo Aquisitivo"})

	//|Periodo de gozo |
	cFerGozo 				:= DtoC( aFerias[3] ) + " a " + DtoC( aFerias[4] ) 
	cFerRetorno			:= DtoC( DaySum( aFerias[4] , 1 ) )

	If !Empty( aFerias[5] )
		cFerGozo 			+= " e de " + DtoC( aFerias[5] ) + " a " + DtoC( aFerias[6] )
		cFerRetorno		:= DtoC( DaySum( aFerias[6] , 1 ) ) 
	EndIf

	aAdd(aExp, {'GPE_FERIAS_GOZO', cFerGozo, "", "Periodo de Gozo"})

	//|Data de retorno |
	aAdd(aExp, {'GPE_FERIAS_RETORNO', cFerRetorno, "", "Retorno de Ferias"})
		

Return( aExp )


//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao    ³ GetQuery ³ Autor ³ Flor - HUB Mexico     ³ Data ³ 15/09/11 ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descricao ³ Retorna Informacoes da Definicao de Tabelas                ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³          ³ aExp[x,1] - Variavel Para utilizacao no Word (Tam Max. 30) ³
//³          ³ aExp[x,2] - Conteudo do Campo                (Tam Max. 49) ³
//³          ³ aExp[x,3] - Campo para Pesquisa da Picture no X3 ou Picture³
//³          ³ aExp[x,4] - Descricao da Variaval                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GetQuery(cQuery)
	Local cDes		:= ""
	Local cAliasTmp	:= CriaTrab(Nil,.F.)

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.) 
	(cAliasTmp)->(dbgotop())
	IF(cAliasTmp)->(!EOF())
		cDes:=(cAliasTmp)->CONTEU
	EndIf

	(cAliasTmp)->( dbCloseArea())  

Return( cDes )


//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao    ³ fOpTpPIS ³ Autor ³ Claudinei Soares     ³ Data ³ 15/09/11 ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descricao ³ Retorna Informacoes da Definicao de Tabelas                ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Uso       ³ GPEWORD													  ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function fOpTpPis()
	Local cTitulo	:= "" 
	Local MvParDef	:= ""
	Local MvPar
	Local lRet	    := .T.

	Private aInc	:={}

	If Alltrim(ReadVar() )= "MV_PAR30"

		MvPar		:=	&(Alltrim(ReadVar()))	 		    // Carrega Nome da Variavel do Get em Questao
		mvRet		:=	Alltrim(ReadVar())			 	    // Iguala Nome da Variavel ao Nome variavel de Retorno
		aInc		:=	{STR0322,STR0323,STR0324,STR0325,STR0326,STR0327}// "Nenhum";"Alteracao";"Cadastro Retroativo";"Cancelamento";
		//"Reativacao";"Retroacao Cadastral"
		MvParDef	:=	"012345"
		cTitulo		:=	STR0321							  	// "Informe o Tipo de Alteracao do NIS-PIS"

		f_Opcoes(@MvPar,cTitulo,aInc,MvParDef,12,49,.T.)  	// Chama funcao f_Opcoes

		&MvRet := mvpar										// Devolve Resultado

	EndIf

Return( .T. )

Static Function fGetInsalub(cCodInsalub)
Local cInsa := ""

	Do Case
	Case cCodInsalub$"1"
				cInsa := ""
	Case cCodInsalub$"2"
				cInsa := ""
	Case cCodInsalub$"3"
				cInsa := "+ adicional de 20% de insalubridade"
	Case cCodInsalub$"4"
				cInsa := "+ adicional de 40% de insalubridade "
			
	EndCase

Return cInsa

Static Function fGetEpiCarg(cCodCarg, cCodDepto, cCodMat)
Local cEpiFunC := ""
dbSelectArea("SRJ")
dbSetOrder(4)
DbGoTop()
	If dbSeek(xFilial("SRJ")+cCodCarg)
	//While(xFilial("SRJ") == SRJ->RJ_FILIAL .And. cCodCarg == SRJ->RJ_CARGO .And. !Eof())
		cEpiFunC += fGetEpiFun(SRJ->RJ_FUNCAO, cCodDepto, cCodMat)
	//	dbSkip()
	//End
	EndIf

Return cEpiFunC

Static Function fGetEpiFun(cCodFun, cCodDepto, cCodMat)
Local cEpiFun := ""

	//Busca EPI para aquela funcao dentro daquele departamento		
	cSQL := " SELECT SB1.B1_DESC "
	cSQL += " FROM " + RetSQLName("TN0") + " TN0 " 
	cSQL += " INNER JOIN " + RetSQLName("TMA") + " TMA ON (TN0.TN0_AGENTE = TMA_AGENTE) "
	cSQL += " INNER JOIN " + RetSQLName("TNX") + " TNX ON (TMA_AGENTE = TNX_AGENTE and TN0_NUMRIS = TNX_NUMRIS) "
	cSQL += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON (TNX_EPI = B1_COD) "
	cSQL += " AND TN0.TN0_CODFUN = '" + ALLTRIM(cCodFun) + "' " 
	cSQL += " AND TN0.TN0_DEPTO = '" + ALLTRIM(cCodDepto) + "' " 
	cSQL += " AND TN0.D_E_L_E_T_ = '' " 
	cSQL += " AND TMA.D_E_L_E_T_ = '' " 
	cSQL += " AND TNX.D_E_L_E_T_ = '' " 
	cSQL += " AND SB1.D_E_L_E_T_ = '' " 
	cSQL += " group by SB1.B1_DESC " 
	
	cSQL += " UNION " 
	
	//Busca EPI para aquela funcao independente do departamento	
	cSQL += " SELECT SB1.B1_DESC "
	cSQL += " FROM " + RetSQLName("TN0") + " TN0 " 
	cSQL += " INNER JOIN " + RetSQLName("TMA") + " TMA ON (TN0.TN0_AGENTE = TMA_AGENTE) "
	cSQL += " INNER JOIN " + RetSQLName("TNX") + " TNX ON (TMA_AGENTE = TNX_AGENTE and TN0_NUMRIS = TNX_NUMRIS) "
	cSQL += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON (TNX_EPI = B1_COD) "
	cSQL += " AND TN0.TN0_CODFUN = '" + ALLTRIM(cCodFun) + "' " 
	cSQL += " AND TN0.TN0_DEPTO = '*' " 
	cSQL += " AND TN0.TN0_CODTAR = '*' "
	cSQL += " AND TN0.D_E_L_E_T_ = '' " 
	cSQL += " AND TMA.D_E_L_E_T_ = '' " 
	cSQL += " AND TNX.D_E_L_E_T_ = '' " 
	cSQL += " AND SB1.D_E_L_E_T_ = '' " 
	cSQL += " group by SB1.B1_DESC " 
	
	cSQL += " UNION " 
	
	 //Busca EPI para aquele departamento independente da funcao		
	cSQL += " SELECT SB1.B1_DESC "
	cSQL += " FROM " + RetSQLName("TN0") + " TN0 " 
	cSQL += " INNER JOIN " + RetSQLName("TMA") + " TMA ON (TN0.TN0_AGENTE = TMA_AGENTE) "
	cSQL += " INNER JOIN " + RetSQLName("TNX") + " TNX ON (TMA_AGENTE = TNX_AGENTE and TN0_NUMRIS = TNX_NUMRIS) "
	cSQL += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON (TNX_EPI = B1_COD) "
	cSQL += " AND TN0.TN0_CODFUN = '*' " 
	cSQL += " AND TN0.TN0_DEPTO = '" + ALLTRIM(cCodDepto) + "' " 
	cSQL += " AND TN0.TN0_CODTAR = '*' "
	cSQL += " AND TN0.D_E_L_E_T_ = '' " 
	cSQL += " AND TMA.D_E_L_E_T_ = '' " 
	cSQL += " AND TNX.D_E_L_E_T_ = '' " 
	cSQL += " AND SB1.D_E_L_E_T_ = '' " 
	cSQL += " group by SB1.B1_DESC " 
	
	cSQL += " UNION " 
	
	//Busca EPI para todos departamentos e todas as funcoes		
	cSQL += " SELECT SB1.B1_DESC "
	cSQL += " FROM " + RetSQLName("TN0") + " TN0 " 
	cSQL += " INNER JOIN " + RetSQLName("TMA") + " TMA ON (TN0.TN0_AGENTE = TMA_AGENTE) "
	cSQL += " INNER JOIN " + RetSQLName("TNX") + " TNX ON (TMA_AGENTE = TNX_AGENTE and TN0_NUMRIS = TNX_NUMRIS) "
	cSQL += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON (TNX_EPI = B1_COD) "
	cSQL += " AND TN0.TN0_CODFUN = '*' " 
	cSQL += " AND TN0.TN0_DEPTO = '*' " 
	cSQL += " AND TN0.TN0_CODTAR = '*' "
	cSQL += " AND TN0.D_E_L_E_T_ = '' " 
	cSQL += " AND TMA.D_E_L_E_T_ = '' " 
	cSQL += " AND TNX.D_E_L_E_T_ = '' " 
	cSQL += " AND SB1.D_E_L_E_T_ = '' " 
	cSQL += " group by SB1.B1_DESC " 
	
	cSQL += " UNION " 
	
	//Busca EPI para determinadas tarefas	relacionadas aquela matricula
	cSQL += " SELECT SB1.B1_DESC "
	cSQL += " FROM " + RetSQLName("TN0") + " TN0 " 
	cSQL += " INNER JOIN " + RetSQLName("TMA") + " TMA ON (TN0.TN0_AGENTE = TMA_AGENTE) "
	cSQL += " INNER JOIN " + RetSQLName("TNX") + " TNX ON (TMA_AGENTE = TNX_AGENTE and TN0_NUMRIS = TNX_NUMRIS) "
	cSQL += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON (TNX_EPI = B1_COD) "
	cSQL += " AND TN0.TN0_CODFUN = '*' " 
	cSQL += " AND TN0.TN0_DEPTO = '*' " 
	cSQL += " AND EXISTS ( SELECT 1 from " + RetSQLName("TN6") + " TN6 WHERE TN6.D_E_L_E_T_ = '' and TN0.TN0_CODTAR = TN6.TN6_CODTAR AND TN6_MAT =  '" + ALLTRIM(cCodMat) + "' ) " 
	cSQL += " AND TN0.D_E_L_E_T_ = '' " 
	cSQL += " AND TMA.D_E_L_E_T_ = '' " 
	cSQL += " AND TNX.D_E_L_E_T_ = '' " 
	cSQL += " AND SB1.D_E_L_E_T_ = '' " 
	cSQL += " group by SB1.B1_DESC " 
	
	If chkfile("EPI_PRODUTO")
		dbSelectArea("EPI_PRODUTO")
		dbCloseArea()
	EndIf
	
	TcQuery cSql New Alias "EPI_PRODUTO"

	While !EPI_PRODUTO->(Eof())
		cEpiFun += EPI_PRODUTO->B1_DESC
		cEpiFun += Chr(13)+Chr(10)
		EPI_PRODUTO->(DbSkip())
	EndDo
  EPI_PRODUTO->(DbCloseArea())
  
Return cEpiFun

Static Function fGetRiscoCarg(cCodCarg, cCodDepto, cCodMat)
Local cRiscoFunC := ""
Local cRiscoFisico := ""
Local cRiscoQuimico := ""
Local cRiscoBiologico := ""
Local cRiscoErgonomico := ""
Local cRiscoAcidente := ""

cCodMat := ALLTRIM(SRA->RA_MAT)

dbSelectArea("SRJ")
dbSetOrder(4)
DbGoTop()
	If dbSeek(xFilial("SRJ")+cCodCarg)
	//While(xFilial("SRJ") == SRJ->RJ_FILIAL .And. cCodCarg == SRJ->RJ_CARGO)
	//Fisico
		cRiscoFisico := fGetRiscoFun(SRJ->RJ_FUNCAO, cCodDepto, cCodMat, '1')
		if Empty(cRiscoFisico)
			cRiscoFisico := "Inexistentes"
		endif
		
		cRiscoFunC += "Riscos Físicos: "+cRiscoFisico
		cRiscoFunC += Chr(13)+Chr(10)
		
		//Quimico
		cRiscoQuimico := fGetRiscoFun(SRJ->RJ_FUNCAO, cCodDepto, cCodMat, '2')
		if Empty(cRiscoQuimico)
			cRiscoQuimico := "Inexistentes"
		endif
		
		cRiscoFunC += "Riscos Químicos: "+cRiscoQuimico
		cRiscoFunC += Chr(13)+Chr(10)
		
		//Biologico
		cRiscoBiologico := fGetRiscoFun(SRJ->RJ_FUNCAO, cCodDepto, cCodMat, '3')
		if Empty(cRiscoBiologico)
			cRiscoBiologico := "Inexistentes"
		endif
		
		cRiscoFunC += "Riscos Biológicos: "+cRiscoBiologico
		cRiscoFunC += Chr(13)+Chr(10)
		
		//Ergonomico
		cRiscoErgonomico := fGetRiscoFun(SRJ->RJ_FUNCAO, cCodDepto, cCodMat, '4')
		if Empty(cRiscoErgonomico)
			cRiscoErgonomico := "Inexistentes"
		endif
		
		cRiscoFunC += "Riscos Ergonômicos: "+cRiscoErgonomico
		cRiscoFunC += Chr(13)+Chr(10)
		
		//Ergonomico
		cRiscoAcidente := fGetRiscoFun(SRJ->RJ_FUNCAO, cCodDepto, cCodMat, '5')
		if Empty(cRiscoAcidente)
			cRiscoAcidente := "Inexistentes"
		endif
		cRiscoFunC += "Riscos Mecânicos: "+cRiscoAcidente
		cRiscoFunC += Chr(13)+Chr(10)
		
		
		
	//	dbSkip()
	//End
	EndIf

SRJ->(DbCloseArea())

Return cRiscoFunC

Static Function fGetRiscoFun(cCodFun, cCodDepto, cCodMat, cGrpRisco)
Local cRiscoFun := ""
	
	cSQL := " SELECT TMA.TMA_NOMAGE "
	cSQL += " FROM " + RetSQLName("TN0") + " TN0 " 
	cSQL += " INNER JOIN " + RetSQLName("TMA") + " TMA ON (TN0.TN0_AGENTE = TMA_AGENTE) "
	//cSQL += " AND TN0.TN0_DEPTO = '*' " 
	cSQL += " WHERE TN0.TN0_CODFUN = '" + ALLTRIM(cCodFun) + "' "
	cSQL += " AND TMA.TMA_GRISCO = '" + ALLTRIM(cGrpRisco) + "' " 
	cSQL += " AND TN0.TN0_CODTAR = '*' "
	cSQL += " AND TN0.D_E_L_E_T_ = '' " 
	cSQL += " AND TMA.D_E_L_E_T_ = '' " 
	cSQL += " group by TMA.TMA_NOMAGE " 
	
	cSQL += " UNION " 
	
	cSQL += " SELECT TMA.TMA_NOMAGE "
	cSQL += " FROM " + RetSQLName("TN0") + " TN0 " 
	cSQL += " INNER JOIN " + RetSQLName("TMA") + " TMA ON (TN0.TN0_AGENTE = TMA_AGENTE) "
	cSQL += " WHERE TN0.TN0_DEPTO = '" + ALLTRIM(cCodDepto) + "' " 
	cSQL += " AND TMA.TMA_GRISCO = '" + ALLTRIM(cGrpRisco) + "' " 
	cSQL += " AND TN0.TN0_CODFUN = '*' "
	cSQL += " AND TN0.TN0_CODTAR = '*' "
	cSQL += " AND TN0.D_E_L_E_T_ = '' " 
	cSQL += " AND TMA.D_E_L_E_T_ = '' " 
	cSQL += " group by TMA.TMA_NOMAGE " 
	
	cSQL += " UNION " 
	
	cSQL += " SELECT TMA.TMA_NOMAGE "
	cSQL += " FROM " + RetSQLName("TN0") + " TN0 " 
	cSQL += " INNER JOIN " + RetSQLName("TMA") + " TMA ON (TN0.TN0_AGENTE = TMA_AGENTE) "
	cSQL += " WHERE TN0.TN0_DEPTO = '*' " 
	cSQL += " AND TMA.TMA_GRISCO = '" + ALLTRIM(cGrpRisco) + "' " 
	cSQL += " AND TN0.TN0_CODFUN = '*' "
	cSQL += " AND TN0.TN0_CODTAR = '*' "
	cSQL += " AND TN0.D_E_L_E_T_ = '' " 
	cSQL += " AND TMA.D_E_L_E_T_ = '' " 
	cSQL += " group by TMA.TMA_NOMAGE " 
	
	cSQL += " UNION " 
	
	cSQL += " SELECT TMA.TMA_NOMAGE "
	cSQL += " FROM " + RetSQLName("TN0") + " TN0 " 
	cSQL += " INNER JOIN " + RetSQLName("TMA") + " TMA ON (TN0.TN0_AGENTE = TMA_AGENTE) "
	cSQL += " WHERE TN0.TN0_DEPTO = '*' " 
	cSQL += " AND TMA.TMA_GRISCO = '" + ALLTRIM(cGrpRisco) + "' " 
	cSQL += " AND TN0.TN0_CODFUN = '*' "
	cSQL += " AND EXISTS ( SELECT 1 from " + RetSQLName("TN6") + " TN6 WHERE TN6.D_E_L_E_T_ = '' and  TN0.TN0_CODTAR = TN6.TN6_CODTAR AND TN6_MAT =  '" + ALLTRIM(cCodMat) + "' )"
	cSQL += " AND TN0.D_E_L_E_T_ = '' " 
	cSQL += " AND TMA.D_E_L_E_T_ = '' " 
	cSQL += " group by TMA.TMA_NOMAGE " 
	
	If chkfile("RISCO_FUN")
		dbSelectArea("RISCO_FUN")
		dbCloseArea()
	EndIf
	
	TcQuery cSql New Alias "RISCO_FUN"

	While !RISCO_FUN->(Eof())
		cRiscoFun += ALLTRIM(RISCO_FUN->TMA_NOMAGE)
		cRiscoFun += "; "//Chr(13)+Chr(10)
		RISCO_FUN->(DbSkip())
	EndDo
  RISCO_FUN->(DbCloseArea())
Return cRiscoFun


Static Function fGetTrans(cPed,cCodMat,cTipo)

	Local cEmpd
	Local cEmpo
	Local cDepto
	Local cCar
	Local cV
	Local cIns := ""
	Local cPer := ""
	Local cAdic := ""
	

	If Select("cTra") > 0
		cTra->(dbCloseArea())
	EndIf

	cCodMat := ALLTRIM(SRA->RA_MAT) 

	cTran := " SELECT RE_EMPD,RE_EMPP,RE_DEPTOD,RE_DEPTOP,RE_CLVLD,RE_CLVLP FROM " +RetSqlName("SRE")
	cTran += " WHERE D_E_L_E_T_ = '' "
	cTran += " AND RE_MATP = " +ALLTRIM(cCodMat)
	cTran += " AND RE_DATA IN ( "
	cTran += " SELECT MAX(RE_DATA) FROM " +RetSqlName("SRE")
	cTran += " WHERE D_E_L_E_T_ = '' "
	cTran += " AND RE_MATP = " +ALLTRIM(cCodMat)+  " ) "

	TcQuery cTran New Alias cTra


	IF cPed == 'E'

		IF cTipo == '1' //oRIGEM
		
		cEmpo := cTra->RE_EMPD
		cEmp := Capital(FWEmpName(cEmpo))
	
		Elseif cTipo == '2' //Destino

		cEmpd := cTra->RE_EMPP
		cEmp := Capital(FWEmpName(cEmpd))

		Endif

//	cTra->(DBCLOSEAREA())

	Return cEmp
		
	ELSEIF cPed == 'D'
	
		IF cTipo == '1' //oRIGEM

		Dep := " SELECT QB_DEPTO,QB_DESCRIC FROM " +RetSqlName("SQB")
		Dep += " WHERE D_E_L_E_T_ = '' "
	    Dep += " AND QB_DEPTO = '" +cTra->RE_DEPTOD+ "' "
	
	    TcQuery Dep New Alias cSqlDep
		
		cDepto := cSqlDep->QB_DESCRIC
		
		cSqlDep->(DBCLOSEAREA())
			
		Elseif cTipo == '2' //Destino

		Dep := " SELECT QB_DEPTO,QB_DESCRIC FROM " +RetSqlName("SQB")
		Dep += " WHERE D_E_L_E_T_ = '' "
	    Dep += " AND QB_DEPTO = '" +cTra->RE_DEPTOP+ "' "
	
	    TcQuery Dep New Alias cSqlDep
		
		cDepto := cSqlDep->QB_DESCRIC
		
		cSqlDep->(DBCLOSEAREA())

		Endif

//	cTra->(DBCLOSEAREA())

	Return cDepto
	
	ELSEIF cPed == 'CD' .OR. cPed == 'C'
	
	Car := " SELECT Q3_CARGO,Q3_DESCSUM FROM " +RetSqlName("SQ3")+ " SQ3 "
	Car += " INNER JOIN " +RetSqlName("SRA")+ " ON RA_CARGO = Q3_CARGO AND RA_MAT = " +ALLTRIM(cCodMat)
	Car += " WHERE SQ3.D_E_L_E_T_ = '' "
	
	TcQuery Car New Alias cRes
	
		IF cPed == 'C'
	
		cCar := cRes->Q3_CARGO
	
		ELSEIF cPed == 'CD'
	
		cCar := cRes->Q3_DESCSUM
	
		ENDIF
	
	cRes->(DBCLOSEAREA())
	
	Return cCar

	ELSEIF cPed == 'V'

		IF cTipo == '1' //oRIGEM
		
		cV := cTra->RE_CLVLD
			
		Elseif cTipo == '2' //Destino

		cV := cTra->RE_CLVLP

		Endif
	
	Return cV
	
	ELSEIF cPed == 'A'
	
		If Select("cAlias2") > 0
		cAlias2->(dbCloseArea())
		EndIf
	
	Adc := " SELECT RA_ADCPERI,RA_ADCINS FROM " +RetSqlName("SRA")
	Adc += " WHERE D_E_L_E_T_ = '' "
	Adc += " AND RA_MAT = " +ALLTRIM(cCodMat)

	TcQuery Adc New Alias cAlias2
	
		IF cAlias2->RA_ADCPERI <> '1' .OR. cAlias2->RA_ADCINS <> '1'
	
			IF cAlias2->RA_ADCPERI == '2'

	 		cPer := "Periculosidade"

			ENDIF
	 	
			IF cAlias2->RA_ADCINS == '2'

	 		cIns := "Insalubridade Mínima"

			ELSEIF cAlias2->RA_ADCINS == '3'
	 	
	 		cIns := "Insalubridade Média"
	 	
			ELSEIF cAlias2->RA_ADCINS == '4'
	 	
	 		cIns := "Insalubridade Máxima"
	 		
			ENDIF
	 	
			IF !EMPTY(cPer)
	 	
	 		cAdic := cPer 

			ENDIF
	 	
			IF !EMPTY(cIns)
	 	
	 	    cAdic += " e "	 	
	 		cAdic := cAdic + cIns 
	 	    	 	    
			ENDIF

		ENDIF
	
	Return cAdic
	ENDIF

cTra->(DBCLOSEAREA())

Return


/*/{Protheus.doc} fBuscaFerias
Função foi criada para uso especial do adiantamento de férias devido ao COVID-19
Não é recomendando utilizar essa função para outros fins
@type function
@version 1.0
@author Pontin - Facile
@since 15/04/2020
@param cMatricula, character, matricula do funcionário
@return array, resultado
/*/
Static Function fBuscaFerias(cMatricula)

	Local aDados		:= {}
	Local cQuery		:= ""

	aAdd(aDados, CtoD(''))	// 1 - Inicio período aquisitivo
	aAdd(aDados, CtoD(''))	// 2 - Final período aquisitivo
	aAdd(aDados, CtoD(''))	// 3 - Inicio da primeira férias
	aAdd(aDados, CtoD(''))	// 4 - Final da primeira férias
	aAdd(aDados, CtoD(''))	// 5 - Inicio da segunda férias
	aAdd(aDados, CtoD(''))	// 6 - Final da segunda férias

	cQuery += " SELECT TOP 1 * "
	cQuery += " FROM " + RetSqlName("SRF") + " SRF "
	cQuery += " WHERE SRF.RF_FILIAL = " + ValToSql( xFilial("SRA") )
	cQuery += " 			AND SRF.RF_MAT = " + ValToSql( cMatricula )
	cQuery += " 			AND SRF.RF_STATUS = '1' "
	cQuery += " 			AND SRF.RF_DATAINI <> '' "
	cQuery += " 			AND SRF.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY SRF.RF_DATABAS DESC "

	If Select("__SRF") > 0
		__SRF->(dbCloseArea())
	EndIf

	TcQuery cQuery New Alias "__SRF"

	__SRF->(dbGoTop())

	If !__SRF-> ( EoF() )

		aDados[1]		:= StoD( __SRF->RF_DATABAS )
		aDados[2]		:= StoD( __SRF->RF_DATAFIM )
		aDados[3]		:= StoD( __SRF->RF_DATAINI )
		aDados[4]		:= DaySum( StoD( __SRF->RF_DATAINI ) , (__SRF->RF_DFEPRO1 - 1) )
		aDados[5]		:= StoD( __SRF->RF_DATINI2 )
		aDados[6]		:= DaySum( StoD( __SRF->RF_DATINI2 ) , (__SRF->RF_DFEPRO2 - 1) )

	EndIf

Return aDados