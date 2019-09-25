#include "rwmake.ch"
//
//
//
User Function FWordR03
Local aMacros   := {"Pecas"}
Local aCampos   := {}
Local nX        := 0
Local nCopias   := 1 
Local cAux      := ""
Local cPath     := GETTEMPPATH()
Local nAt		:= 0
Local lImpress  := .F.  
Local lArquivo  := .F.
Local cArqSaida := ""
Local oWord     := NIL
Local cArqWord  := "\Proposta_Fat.dot"
Local bVarExpRW := 	bVarExpRW := {|| fPrepVar()} //bloco para preenchimento das Variaveis

	/*Verifica se o usuario escolheu um drive local (A: C: D:) caso contrario
	busca o nome do arquivo de modelo,  copia para o diretorio temporario
	no windows e ajusta o caminho completo do arquivo a ser impresso.*/
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
	
	oWord	:= OLE_CreateLink() ; OLE_NewFile( oWord , cArqWord )
	
	aCampos := Eval(bVarExpRW) 
	
	If (ValType(aCampos) == 'U')
		MsgAlert("Nao foram encontrados dados para o relatorio!")
		OLE_CloseLink( oWord )
		If Len(cAux) > 0
			fErase(carqword)
		EndIf 
		
		Return
	EndIf
	
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
			 
	//Executa as Macros
	For I := 1 to Len(aMacros) 
		OLE_ExecuteMacro(oWord,aMacros[I])
	Next I
	 
	//Atualiza as Variaveis
	OLE_UpDateFields( oWord )
	
	//Imprimindo o Documento
	IF lImpress
		For nX := 1 To nCopias
			OLE_SetProperty( oWord, '208', .F. ) ; OLE_PrintFile( oWord )
		Next nX
	ElseIF lArquivo
		OLE_SaveAsFile( oWord, cArqSaida ) 
	Else
		MsgInfo("Clique em OK para fechar o Microsoft Word.", "Proposta")	
	EndIF

	//Encerrando o Link com o Documento
	OLE_CloseLink( oWord )

	If Len(cAux) > 0
		fErase(carqword)
	EndIf	 
Return
//
//
//                   
Static Function fPrepVar()    
Local aExp      := {}
Local cMVal     := "@E 999,999,999.99"
Local cServ     := ""
Local nEqp      := 0
Local nPecas    := 0
Local nTotProp  := 0
Local cOrdem    := ""
Local aUsu      := {}
Local lAchouSA3 := .F.

	aAdd(aExp, {"OBSERVACAO", If(Empty(SCJ->CJ_YOBS), "", AllTrim(SCJ->CJ_YOBS)), "", "Observacao"})	

	SA1->(DbSetOrder(1))                                                                
	SU5->(DbSetOrder(1))

	SA1->(DbSeek(XFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA))
    
	aAdd(aExp, {"RAZAO_SOCIAL" , AllTrim(SA1->A1_NOME)                          , "SA1->A1_NOME"   , "Nome"})
	aAdd(aExp, {"CIDADE"       , AllTrim(SA1->A1_MUN)                           , "SA1->A1_MUN"    , "Cidade"})
	aAdd(aExp, {"UF"           , AllTrim(SA1->A1_EST)                           , "SA1->A1_EST"    , "Estado"})

	If Empty(SCJ->CJ_YCODCON)
		aAdd(aExp, {"CONTATO"      , AllTrim(SA1->A1_CONTATO)                       , "", "Contato"})
		aAdd(aExp, {"TELEFONE"     , SA1->("("+AllTrim(A1_DDD)+") "+AllTrim(A1_TEL)), ""             , "Telefone"})
		aAdd(aExp, {"EMAIL_CONTATO", AllTrim(SA1->A1_EMAIL)                         , ""  , "Email Contato"})
	Else
		If SU5->(DbSeek(xFilial("SU5") + SCJ->CJ_YCODCON))
			aAdd(aExp, {"CONTATO"      , AllTrim(SU5->U5_CONTAT)                       , "", "Contato"})
			aAdd(aExp, {"TELEFONE"     , SU5->("("+AllTrim(U5_DDD)+") "+AllTrim(If(Empty(U5_FONE), U5_FCOM1, U5_FONE))), "", "Telefone"})
			aAdd(aExp, {"EMAIL_CONTATO", AllTrim(SU5->U5_EMAIL)                         , ""  , "Email Contato"})
		End If
	End If

	SA3->(DbSetOrder(1))
	
	If !Empty(SCJ->CJ_YVEND1)
		lAchouSA3 := SA3->(DbSeek(xFilial("SA3") + SCJ->CJ_YVEND1))
	EndIf
	
	If lAchouSA3
		aAdd(aExp, {"NOME_USUARIO" , AllTrim(SA3->A3_NOME)                                   , "@!", "Nome Usuario"})
		aAdd(aExp, {"TEL_USUARIO"  , SA3->("(" + AllTrim(A3_DDDTEL) + ") " + AllTrim(A3_TEL)), "@!", "Tel Usu"})
		aAdd(aExp, {"EMAIL_USUARIO", AllTrim(SA3->A3_EMAIL)                                  , "@!", "Email Usu"})		
	Else
		aAdd(aExp, {"NOME_USUARIO" , "", "@!", "Nome Usuario"})
		aAdd(aExp, {"TEL_USUARIO"  , "", "@!", "Tel Usu"})
		aAdd(aExp, {"EMAIL_USUARIO", "", "@!", "Email Usu"})		
	EndIf

	aAdd(aExp, {"CARGO_USUARIO", "Consultor Tecnico", "@!", "Cargo"})	
	
	//Condicao de Pagamento
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(xFilial("SE4") + SCJ->CJ_CONDPAG))  
	
	aAdd(aExp, {"CONDICAO_PAGTO", AllTrim(SE4->E4_DESCRI), "SE4->E4_DESCRI", "Cond PG"})

	//Selcionando itens
	SCK->(DbSetOrder(1))
	
	If SCK->(DbSeek(xFilial("SCK") + SCJ->CJ_NUM))
		If Empty(SCK->CK_NUMPV)
			aAdd(aExp, {"CJ_NUM", SCJ->CJ_NUM, "SCJ->CJ_NUM", "Num. Orcamento"})
		Else
			aAdd(aExp, {"CJ_NUM", AllTrim(SCJ->CJ_NUM) + " / PV " + AllTrim(SCK->CK_NUMPV) , "", "Num. Orcamento"})
		End If	
	
		While !SCK->(Eof()) .And. SCK->(CK_FILIAL + CK_NUM) == SCJ->(CJ_FILIAL + CJ_NUM)
			SB1->(DbSeek(xFilial("SB1") + SCK->CK_PRODUTO))

			nPecas++
			cOrdem   := cValToChar(nPecas)
			nTotProp += SCK->(CK_VALOR+CK_YVALIPI)
		
			aAdd(aExp, {"ITEM" + cOrdem      , SCK->CK_ITEM                                                    , "AB5->AB5_SUBITE", "ITEM"})
			aAdd(aExp, {"QTD" + cOrdem       , AllTrim(Transform(SCK->CK_QTDVEN, "@E 999,999"))                , ""               , "QUANTIDADE"})
			aAdd(aExp, {"UND" + cOrdem       , AllTrim(SB1->B1_UM)                                             , "SB1->B1_UM"     , "UN MEDIDA"})			
			aAdd(aExp, {"REFERENCIA" + cOrdem, AllTrim(SB1->B1_YREF)                                           , "SB1->B1_YREF"   , "REFERENCIA"})
			aAdd(aExp, {"DESCRICAO" + cOrdem , AllTrim(SCK->CK_DESCRI)                                         , "AB5->AB5_DESPRO", "DESCRICAO"})
			aAdd(aExp, {"VALOR_UNIT" + cOrdem, AllTrim(Transform(SCK->CK_PRCVEN, "@E 999,999,999.99"))         , ""               , "VALOR UNITARIO"})
			aAdd(aExp, {"B1_IPI" + cOrdem    , AllTrim(Transform(SCK->CK_YPERIPI, "@E 999.99"))                    , ""    , "B1_IPI"})
			aAdd(aExp, {"VALOR_IPI" + cOrdem , AllTrim(Transform(SCK->CK_YVALIPI, "@E 999,999,999.99")), ""  , "VALOR_IPI"})			
			aAdd(aExp, {"VALOR_TOT" + cOrdem , AllTrim(Transform( SCK->(CK_VALOR+CK_YVALIPI)  , "@E 999,999,999.99")), "", "VALOR TOTAL"})
			aAdd(aExp, {"ICMS" + cOrdem      , AllTrim(Transform(SCK->CK_YPEICMS, "@E 999.99")), "", "ICMS"})						
			aAdd(aExp, {"PRAZO" + cOrdem     , SCK->CK_ENTREG                                                  , "SCK->CK_ENTREG", "PRAZO ENTREGA"})									

			SCK->(DbSkip())
		EndDo
	EndIf

	aAdd(aExp, {"N_PECAS", nPecas, "", "Qtd Pecas"})		
	aAdd(aExp, {"TOTAL_PROPOSTA", AllTrim(Transform(nTotProp, "@E 999,999,999.99")), "", "TOTAL_PROPOSTA"})
Return(aExp)