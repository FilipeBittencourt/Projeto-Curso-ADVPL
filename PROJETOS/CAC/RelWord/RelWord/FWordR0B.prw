#include "rwmake.ch"
//
//
//
User Function FWordR0B
Local aMacros   := {"Equipamentos", "Proposta"}
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
Local cArqWord  := "\Proposta_Servico_weg.dot"
Local bVarExpRW := 	bVarExpRW := {|| fPrepVar()} //bloco para preenchimento das Variaveis

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Verifica se o usuario escolheu um drive local (A: C: D:) caso contrario³
	³busca o nome do arquivo de modelo,  copia para o diretorio temporario  ³
	³do windows e ajusta o caminho completo do arquivo a ser impresso.      ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa o Ole com o MS-Word 97 ( 8.0 )						      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWord	:= OLE_CreateLink() ; OLE_NewFile( oWord , cArqWord )
	        	           
	//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//  ³ Carrega Campos Disponiveis para Edicao                       ³
	//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampos := Eval(bVarExpRW) 

	if (ValType(aCampos) == 'U')
		MsgAlert("Não foram encontrados dados para o relatório!")
		OLE_CloseLink( oWord )
		If Len(cAux) > 0
			fErase(carqword)
		Endif 
		return
	endif
	   
	//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//  ³ Ajustando as Variaveis do Documento                          ³
	//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			 
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³ Executa as Macros                                            ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For I := 1 to Len(aMacros) 
		OLE_ExecuteMacro(oWord,aMacros[I])
	Next I
	    	
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³ Atualiza as Variaveis                                        ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	OLE_UpDateFields( oWord )
	
	//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//	³Imprimindo o Documento                                                 ³
	//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lImpress
		For nX := 1 To nCopias
			OLE_SetProperty( oWord, '208', .F. ) ; OLE_PrintFile( oWord )
		Next nX
	ElseIF lArquivo
		OLE_SaveAsFile( oWord, cArqSaida ) 
	Else
		MsgInfo("Clique em OK para fechar o Microsoft Word.", "Proposta")	
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Encerrando o Link com o Documento                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	OLE_CloseLink( oWord )

	If Len(cAux) > 0
		fErase(carqword)
	EndIf	 
Return
//
//
//                   
Static Function fPrepVar()    
Local aExp     := {}
Local cMVal    := "@E 999,999,999.99"
Local cServ    := ""
Local nEqp     := 0
Local nProp    := 0
Local nPosUser := 0
Local aUser    := {}
Local aUsers   := AllUsers(.F., .T.)
    
	nPosUser := aScan(aUsers, {|x| Upper(AllTrim(x[01, 04])) == Upper(AllTrim(AB3->AB3_ATEND)) })

	If nPosUser > 0
		aUser := aUsers[nPosUser]
	Else
		PswOrder(1)
		PswSeek(__cUserId, .T.)
	    aUser := PswRet()			
	EndIf

	SA1->(DbSetOrder(1))                                                                
	SA1->(DbSeek(XFilial("SA1")+AB3->AB3_CODCLI+AB3->AB3_LOJA))
    
	aAdd(aExp, {"RAZAO_SOCIAL",  AllTrim(SA1->A1_NOME),                           "SA1->A1_NOME",    "Nome"})
	aAdd(aExp, {"CIDADE",        AllTrim(SA1->A1_MUN),                            "SA1->A1_MUN",     "Cidade"})
	aAdd(aExp, {"UF",            AllTrim(SA1->A1_EST),                            "SA1->A1_EST",     "Estado"})
	//aAdd(aExp, {"TELEFONE",      SA1->("("+AllTrim(A1_DDD)+") "+AllTrim(A1_TEL)), "@!",              "Telefone"})
	aAdd(aExp, {"AB3_NUMORC",    AB3->AB3_NUMORC,                                 "AB3->AB3_NUMORC", "Num. Orçamento"})
	aAdd(aExp, {"NOME_USUARIO",  AllTrim(aUser[1, 04]),                            "",              "Nome Usuario"})
	aAdd(aExp, {"DEPARTAMENTO",  AllTrim(aUser[1, 12]),                            "",              "Departamento"})
	aAdd(aExp, {"TEL_USUARIO",   AllTrim(aUser[1, 20]),                            "",              "Tel Usu"})
	aAdd(aExp, {"EMAIL_USUARIO", AllTrim(aUser[1, 14]),                            "",              "Email Usu"})	

	//Condicao de Pagamento
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(XFilial("SE4")+AB3->AB3_CONPAG))  
	aAdd(aExp, {"CONDICAO_PAGTO", SE4->E4_DESCRI, "SE4->E4_DESCRI", "Cond PG"})

	//equipamentos do orcamento
	SB1->(DbSetOrder(1))
	AB1->(DbSetOrder(1))
	AB1->(DbGoTop())	
	AB4->(DbSetOrder(1))
	If AB4->(DbSeek(xFilial("AB4")+AB3->AB3_NUMORC))  
        While !AB4->(Eof()) .And. xFilial("AB4")+AB4->AB4_NUMORC == xFilial("AB3")+AB3->AB3_NUMORC
			SB1->(DbSeek(xFilial("SB1")+AB4->AB4_CODPRO))

			nEqp++
		
			cServ += MSMM(AB4->AB4_MEMO) + Chr(10) + Chr(13)

			aAdd(aExp, {"EQUIPAMENTO"+cValToChar(nEqp), AllTrim(SB1->B1_DESC) + " série: "+AB4->AB4_NUMSER+";", ;
			            "@!", "Equipamento"})
			            
            If !Empty(AB4->AB4_NRCHAM) .And. aScan(aExp, { |x| x[1] == "CONTATO" }) == 0
            	If AB1->(DbSeek( xFilial("AB1") + SubStr(AB4->AB4_NRCHAM, 1, TamSX3("AB1_NRCHAM")[1])))
					aAdd(aExp, {"CONTATO",       AllTrim(AB1->AB1_CONTAT), "AB1->AB1_CONTAT", "Contato"})
					aAdd(aExp, {"EMAIL_CONTATO", AllTrim(AB1->AB1_YEMAIL), "AB1->AB1_YEMAIL", "Email Contato"})
					aAdd(aExp, {"TELEFONE",      AllTrim(AB1->AB1_TEL)   , ""             , "Telefone"})
            	EndIf
            EndIf

			AB4->(DbSkip())
		EndDo
	EndIf       
	
	If aScan(aExp, { |x| x[1] == "CONTATO" }) == 0
		aAdd(aExp, {"CONTATO",       "", "AB1->AB1_CONTAT", "Contato"})
		aAdd(aExp, {"EMAIL_CONTATO", "", "AB1->AB1_YEMAIL", "Email Contato"})
		aAdd(aExp, {"TELEFONE",      "", ""             , "Telefone"})			
	EndIf
	
	aAdd(aExp, {"N_EQUIP", nEqp, "", "Num Equip"})	
	
	//serviços
	// Comentado a pedido do Renato - Será sempre em branco pois ele coloca o serviço manualmente.
	//aAdd(aExp, {"SERVICOS", cServ, "AB4->AB4_MEMO", "Serviços"}) 

	//Selcionando Apontamentos
	AB5->(DbSetOrder(1))
	If AB5->(DbSeek(xFilial("AB5")+AB3->AB3_NUMORC))
		While !AB5->(Eof()) .And. AB5->(AB5_FILIAL+AB5_NUMORC) == xFilial("AB3")+AB3->AB3_NUMORC
			SB1->(DbSeek(xFilial("SB1")+AB5->AB5_CODPRO))

			nProp++
		
			aAdd(aExp, {"PROPOSTA"+cValToChar(nProp), AllTrim(AB5->AB5_DESPRO), "@!",  "PROPOSTA"})
			aAdd(aExp, {"PROPVAL"+cValToChar(nProp),  AllTrim(Transform(AB5->AB5_VUNIT, cMVal)), "@!", "VALOR"})
			aAdd(aExp, {"PROPUN"+cValToChar(nProp),   AllTrim(SB1->B1_UM),      "@!",  "UN MEDIDA"})			

			AB5->(DbSkip())
		EndDo
	EndIf

	aAdd(aExp, {"N_PROP", nProp, "", "Qtd Propostas"})		
Return(aExp)