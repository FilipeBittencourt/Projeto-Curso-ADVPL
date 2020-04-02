#INCLUDE "RWMAKE.CH" 
#INCLUDE "MSOLE.CH"
#INCLUDE "RELWORD.CH"

User Function RelWord(fcPerg,faMacros,fcTitulo)
Local	oDlg	:= NIL

Private	cPerg	:= fcPerg   
Private aMacros := faMacros

Private aInfo	:= {}
Private aDepenIR:= {}
Private aDepenSF:= {}
Private nDepen	:= 0

	Pergunte(cPerg,.F.)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё         Grupo  Ordem Pergunta Portugues     Pergunta Espanhol  Pergunta Ingles Variavel Tipo Tamanho Decimal Presel  GSC Valid                              Var01      Def01         DefSPA1   DefEng1 Cnt01             Var02  Def02    		 DefSpa2  DefEng2	Cnt02  Var03 Def03      DefSpa3    DefEng3  Cnt03  Var04  Def04     DefSpa4    DefEng4  Cnt04  Var05  Def05       DefSpa5	 DefEng5   Cnt05  XF3   GrgSxg Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	@ 096,042 TO 323,505 DIALOG oDlg TITLE OemToAnsi(fcTitulo)
	@ 008,010 TO 084,222
	@ 018,020 SAY OemToAnsi(STR0002)						 												
	@ 030,020 SAY OemToAnsi(STR0003)																		
	@ 095,042 BMPBUTTON TYPE 5 					    ACTION Eval( { || fPerg_Word(cPerg) , Pergunte(cPerg,.T.) } )	
	@ 095,072 BUTTON OemToAnsi(STR0004) SIZE 55,13 ACTION Eval( { || fPerg_Word(cPerg) , (ndepen:= 0,fVarW_Imp() ) }  )      
	@ 095,130 BUTTON OemToAnsi(STR0005) SIZE 55,13 ACTION Eval( { || fPerg_Word(cPerg) , fWord_Imp() } )
	@ 095,187 BMPBUTTON TYPE 2 ACTION Close(oDlg)

	ACTIVATE DIALOG oDlg CENTERED
Return( NIL )

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfWord_Imp Ё Autor ЁMarinaldo de Jesus     Ё Data Ё05/07/2000Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁImpressao do Documento Word                                 Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fWord_Imp()
/*
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁDefinindo Variaveis Locais                                             Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Local aCampos		:= {}
Local nX			:= 0

/*
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁCarregando mv_par padroes para Variaveis Locais do Programa            Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Local nCopias		:= If ( Empty(mv_par01),1,mv_par01 ) 
Local cAux			:= ""
Local cPath 		:= GETTEMPPATH()
Local nAt			:= 0
Local lImpress      := ( mv_par02 == 1 )  
Local lArquivo      := ( mv_par02 == 2 )
Local cArqSaida     := AllTrim( mv_par04 )

//objeto do Word
Local oWord			:= NIL

Private cArqWord		:= mv_par03

	/*
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁVerifica se o usuario escolheu um drive local (A: C: D:) caso contrarioЁ
	Ёbusca o nome do arquivo de modelo,  copia para o diretorio temporario  Ё
	Ёdo windows e ajusta o caminho completo do arquivo a ser impresso.      Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	If substr(cArqWord,2,1) <> ":"
		cAux 	:= cArqWord
		nAT		:= 1
		for nx := 1 to len(cArqWord)
			cAux := substr(cAux,If(nx==1,nAt,nAt+1),len(cAux))
			nAt := at("\",cAux)
			If nAt == 0
				Exit
			Endif
		next nx
		CpyS2T(cArqWord,cPath, .T.)
		cArqWord	:= cPath+cAux
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁInicializa o Ole com o MS-Word 97 ( 8.0 )						      Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oWord	:= OLE_CreateLink() ; OLE_NewFile( oWord , cArqWord )
	        	           
	//	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//  Ё Carrega Campos Disponiveis para Edicao                       Ё
	//	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aCampos := fCpos_Word()
	if (ValType(aCampos) == 'U')
		MsgAlert("NЦo foram encontrados dados para o relatСrio!")
		OLE_CloseLink( oWord )
		If Len(cAux) > 0
			fErase(carqword)
		Endif 
		return
	endif
	   
	//	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//  Ё Ajustando as Variaveis do Documento                          Ё
	//	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aeval(	aCampos																								    ,; 
				{ |x| OLE_SetDocumentVar( oWord, x[1]  																,;
											IF( Subst( AllTrim( x[3] ) , 4 , 2 )  == "->"          				,; 
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
			 
	// здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	// Ё Executa as Macros                                            Ё
	// юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For I := 1 to Len(aMacros) 
		OLE_ExecuteMacro(oWord,aMacros[I])
	Next I
	    	
	// здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	// Ё Atualiza as Variaveis                                        Ё
	// юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	OLE_UpDateFields( oWord )
	
	//	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//	ЁImprimindo o Documento                                                 Ё
	//	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	IF lImpress
		For nX := 1 To nCopias
			OLE_SetProperty( oWord, '208', .F. ) ; OLE_PrintFile( oWord )
		Next nX
	ElseIF lArquivo
		OLE_SaveAsFile( oWord, cArqSaida )  
	Else
		MsgAlert("Encerrar o link com o Microsoft Word?")
	EndIF
	                                         
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁEncerrando o Link com o Documento                                      Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	OLE_CloseLink( oWord )
	If Len(cAux) > 0
		fErase(carqword)
	Endif
Return( NIL )

//зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
//ЁFun┤фo    ЁfOpen_WordЁ Autor Ё Marinaldo de Jesus    Ё Data Ё06/05/2000Ё
//цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
//ЁDescri┤фo ЁSelecionaro os Arquivos do Word.                            Ё
//юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
User Function fOpenArqRW()
Local cSvAlias		:= Alias()
Local lAchou		:= .F.
Local cTipo			:= STR0006														
Local cNewPathArq	:= cGetFile( cTipo , STR0007 )									

	IF !Empty( cNewPathArq )
		IF Upper( Subst( AllTrim( cNewPathArq), - 3 ) ) == Upper( AllTrim( STR0008 ) )	
			Aviso( STR0009 , cNewPathArq , { STR0010 } )								
	    Else
	    	MsgAlert( STR0011 )															
	    	Return
	    EndIF
	Else
	    Aviso(STR0012 ,{ STR0010 } )													
	    Return
	EndIF
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁLimpa o parametro para a Carga do Novo Arquivo                         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SX1")  
	IF lAchou := ( SX1->( dbSeek( PADL(cPerg,10) + "03" , .T. ) ) )
		RecLock("SX1",.F.,.T.)
		SX1->X1_CNT01 := Space( Len( SX1->X1_CNT01 ) )
		MV_PAR03 := cNewPathArq
		MsUnLock()
	EndIF	
	dbSelectArea( cSvAlias )
Return( .T. )


//зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
//ЁFun┤фo    ЁfVarW_Imp Ё Autor Ё Marinaldo de Jesus    Ё Data Ё07/05/2000Ё
//цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
//ЁDescri┤фo ЁImpressao das Variaveis disponiveis para uso                Ё
//юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function fVarW_Imp()
/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Define Variaveis Locais                                      Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Local cString	:= 'SRA'                                	     
Local aOrd		:= {STR0142,STR0143}
Local cDesc1	:= STR0144
Local cDesc2	:= STR0145                     
Local cDesc3	:= STR0146                                
Local Tamanho	:= "P"

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Define Variaveis Privates Basicas                            Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Private nomeprog	:= 'GPEWORD'
Private AT_PRG		:= nomeProg
Private aReturn		:= {STR0147, 1,STR0148, 2, 2, 1, '',1 }
Private wCabec0		:= 1
Private wCabec1		:= STR0149
Private wCabec2		:= ""
Private wCabec3		:= ""
Private nTamanho	:= "P"
Private lEnd		:= .F.
Private Titulo		:= cDesc1
Private Li			:= 0
Private ContFl		:= 1
Private cBtxt		:= ""
Private aLinha		:= {}
Private nLastKey	:= 0
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Envia controle para a funcao SETPRINT                        Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	WnRel := "WORD_VAR" 
	WnRel := SetPrint(cString,Wnrel,"",Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.F.)
	
	IF nLastKey == 27
		Return( NIL )
	EndIF
	
	SetDefault(aReturn,cString)
	
	IF nLastKey == 27
		Return( NIL )
	EndIF
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Chamada do Relatorio.                                        Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	RptStatus( { |lEnd| fImpVar() } , Titulo )
Return( NIL )

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤фo    ЁfImpVar   Ё Autor Ё Marinaldo de Jesus    Ё Data Ё07/05/2000Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤фo ЁImpressao das Variaveis disponiveis para uso                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fImpVar()
Local nOrdem	:= aReturn[8]
Local aCampos	:= {}
Local nX		:= 0
Local cDetalhe	:= ""

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carregando Informacoes da Empresa                            Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/ 
	IF !fInfo(@aInfo,xFilial("SRA"))
		Return( NIL )
	EndIF			
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carregando Variaveis                                         Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/ 
	aCampos := fCpos_Word()
	if (ValType(aCampos) == 'U')
		MsgAlert("NЦo foram encontrados dados para o relatСrio!")
		return
	endif
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Ordena aCampos de Acordo com a Ordem Selecionada             Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/        
	IF nOrdem = 1
		aSort( aCampos , , , { |x,y| x[1] < y[1] } )
	Else
		aSort( aCampos , , , { |x,y| x[4] < y[4] } )
	EndIF
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carrega Regua de Processamento                               Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/        
	SetRegua( Len( aCampos ) )
	
	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Impressao do Relatorio                                       Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/        
	For nX := 1 To Len( aCampos )
	
	        /*
	        здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	        Ё Movimenta Regua Processamento                                Ё
	        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/        
	        IncRegua()  
	
	        /*
	        здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	        Ё Cancela Impresфo                                             Ё
	        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	        IF lEnd
	           @ Prow()+1,0 PSAY cCancel
	           Exit
	        EndIF            
	
			/*
	        здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	        Ё Mascara do Relatorio                                         Ё
	        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	        //        10        20        30        40        50        60        70        80
	        //12345678901234567890123456789012345678901234567890123456789012345678901234567890
			//Variaveis                      Descricao
			//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
			/*
	        здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	        Ё Carregando Variavel de Impressao                             Ё
	        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
			cDetalhe := IF( Len( AllTrim( aCampos[nX,1] ) ) < 30 , AllTrim( aCampos[nX,1] ) + ( Space( 30 - Len( AllTrim ( aCampos[nX,1] ) ) ) ) , aCampos[nX,1] )
			cDetalhe := cDetalhe + AllTrim( aCampos[nX,4] )
	      	
	      	/*
	        здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	        Ё Imprimindo Relatorio                                         Ё
	        юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	        Impr( cDetalhe )
	        
	Next nX
	
	IF aReturn[5] == 1
	   Set Printer To
	   dbCommit()
	   OurSpool(WnRel)
	EndIF
	//--APAGA OS INDICES TEMPORARIOS--//
	If nOrdem == 5
		fErase( cArqNtx + OrdBagExt() )
	Endif                      
	
	MS_FLUSH()
Return( NIL )

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfPerg_WordЁ Autor ЁMarinaldo de Jesus     Ё Data Ё05/07/2000Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁGrava as Perguntas utilizadas no Programa no SX1            Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fPerg_Word(cPerg)
Local aArea		:= getarea()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Ajusta o tamanho da pergunta 25 - Arquivo do Word            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbselectarea("SX1")
	If dbseek(cPerg+"03")
		Reclock("SX1",.f.)
		SX1->X1_TAMANHO		:= 60
		MsUnlock()
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Retorna para a area corrente.                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	restarea(aArea)
Return( Nil )

//зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
//ЁFun┤└o    ЁfCpos_WordЁ Autor ЁMarinaldo de Jesus     Ё Data Ё06/07/2000Ё
//цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
//ЁDescri┤└o ЁRetorna Array com as Variaveis Disponiveis para Impressao   Ё
//цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
//Ё          ЁaExp[x,1] - Variavel Para utilizacao no Word (Tam Max. 30)  Ё
//Ё          ЁaExp[x,2] - Conteudo do Campo                (Tam Max. 49)  Ё
//Ё          ЁaExp[x,3] - Campo para Pesquisa da Picture no X3 ou Picture Ё
//Ё          ЁaExp[x,4] - Descricao da Variaval                           Ё
//юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
STATIC Function fCpos_Word()
Local aExp	:= {}

	aExp := Eval(bVarExpRW) 
Return( aExp )