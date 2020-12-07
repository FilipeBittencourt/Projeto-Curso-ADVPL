#include "TOTVS.ch"


/*/{Protheus.doc} AO_IMPWR
@description Impressao em Word do Acordo de Objetivos
@author Fernando Rocha
@since 23/05/2017 (revisado)
@version undefined
@type function
/*/
User Function AO_IMPWR
	Local aMacros   := {"itens"}
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
	Local cArqWord  := "\P10\ACORDO_OBJ\Modelo_Acordo_"+AllTrim(IIF(PZ5->PZ5_NFAIXA<="3","3",PZ5->PZ5_NFAIXA))+"Faixas_"+PZ5->PZ5_MARCA+".dot"
	Local bVarExpRW := 	bVarExpRW := {|| fPrepVar()} //bloco para preenchimento das Variaveis
	Local I

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
		MsgInfo("Clique em OK para fechar o Microsoft Word.", "Acordo de Objetivo")	
	EndIF

	//Encerrando o Link com o Documento
	OLE_CloseLink( oWord )

	If Len(cAux) > 0
		fErase(carqword)
	EndIf	 
Return


Static Function fPrepVar()    
	Local aExp      := {}
	Local cMVal     := "@E 999,999,999.99"
	Local nItens    := 0
	Local nTotProp  := 0
	Local cOrdem    := ""

	aAdd(aExp, {"PZ5_CODIGO"	, PZ5->PZ5_CODIGO	, "PZ5->PZ5_CODIGO"	, "Acordo"}) 
	aAdd(aExp, {"PZ5_DATA"		, PZ5->PZ5_DATA		, "PZ5->PZ5_DATA"	, "Data"})
	aAdd(aExp, {"PZ5_SEQ"		, PZ5->PZ5_SEQ		, "PZ5->PZ5_SEQ"	, "Sequencial"})
	aAdd(aExp, {"PZ5_ANO"		, PZ5->PZ5_ANO		, "PZ5->PZ5_ANO"	, "Ano"})
	aAdd(aExp, {"PZ5_TIPACO"	, PZ5->PZ5_TIPACO	, "PZ5->PZ5_TIPACO"	, "Tipo Acordo"})
	aAdd(aExp, {"PZ5_TIPPAG"	, PZ5->PZ5_TIPPAG	, "PZ5->PZ5_TIPPAG"	, "Tipo Pgto"})  

	IF PZ5->PZ5_TIPCLI == "2"

		ACY->(DbSetOrder(1))
		ACY->(DbSeek(XFilial("ACY")+PZ5->PZ5_CODGRP))  

		aAdd(aExp, {"A1_NOME"		, ACY->ACY_DESCRI		, "ACY->ACY_DESCRI"		, "Nome Cli"}) 
		aAdd(aExp, {"A1_CONTATO"	, ""	  				, ""					, "Contato Cli"})
		aAdd(aExp, {"A1_EMAIL"		, ""	   				, ""	  				, "Email Cli"})

	ELSEIF PZ5->PZ5_TIPCLI == "3"

		Z79->(DbSetOrder(1))
		Z79->(DbSeek(XFilial("Z79")+PZ5->PZ5_REDE))  

		aAdd(aExp, {"A1_NOME"		, Z79->Z79_DESCR		, "Z79->Z79_DESCR"		, "Nome Cli"}) 
		aAdd(aExp, {"A1_CONTATO"	, ""	  				, ""					, "Contato Cli"})
		aAdd(aExp, {"A1_EMAIL"		, ""	   				, ""	  				, "Email Cli"})

	ELSE

		SA1->(DbSetOrder(1))
		SA1->(DbSeek(XFilial("SA1")+PZ5->PZ5_CODCLI+PZ5->PZ5_LOJCLI))

		aAdd(aExp, {"A1_NOME"		, SA1->A1_NOME		, "SA1->A1_NOME"   		, "Nome Cli"})
		aAdd(aExp, {"A1_CONTATO"	, SA1->A1_CONTATO	, "SA1->A1_CONTATO"		, "Contato Cli"})
		aAdd(aExp, {"A1_EMAIL"		, SA1->A1_EMAIL		, "SA1->A1_EMAIL"  		, "Email Cli"})

	ENDIF 

	SA3->(DbSetOrder(1))
	If SA3->(DbSeek(xFilial("SA3") + PZ5->PZ5_CODVEN))

		aAdd(aExp, {"A3_NOME"		, SA3->A3_NOME		, "SA3->A3_NOME"	, "Nome vend"})	

	else

		aAdd(aExp, {"A3_NOME"		, ""		, "SA3->A3_NOME"	, "Nome vend"})

	EndIf	

	//Selcionando itens 
	nItens := 0     
	__cDtDe := ""
	__cDtAte := ""
	PZ6->(DbSetOrder(1))
	If PZ6->(DbSeek(XFilial("PZ6")+PZ5->PZ5_CODIGO))

		While !PZ6->(Eof()) .And. PZ6->(PZ6_FILIAL+PZ6_CODIGO) == (xFilial("PZ6")+PZ5->PZ5_CODIGO)

			nItens++
			cOrdem   := AllTrim(cValToChar(nItens))

			If nItens == 1
				__cDtDe := DTOC(PZ6->PZ6_PERINI)

				aAdd(aExp, {"PZ6_PBONF1", PZ6->PZ6_PBONF1 , "PZ6->PZ6_PBONF1", "Bonus F1"})
				aAdd(aExp, {"PZ6_PBONF2", PZ6->PZ6_PBONF2 , "PZ6->PZ6_PBONF2", "Bonus F2"})
				aAdd(aExp, {"PZ6_PBONF3", PZ6->PZ6_PBONF3 , "PZ6->PZ6_PBONF3", "Bonus F3"})
				aAdd(aExp, {"PZ6_PBONF4", PZ6->PZ6_PBONF4 , "PZ6->PZ6_PBONF4", "Bonus F4"})
				aAdd(aExp, {"PZ6_PBONF5", PZ6->PZ6_PBONF5 , "PZ6->PZ6_PBONF5", "Bonus F5"})

				aAdd(aExp, {"PZ6_PERCF1", PZ6->PZ6_PERCF1 , "PZ6->PZ6_PERCF1", "Perc F1"})
				aAdd(aExp, {"PZ6_PERCF2", PZ6->PZ6_PERCF2 , "PZ6->PZ6_PERCF2", "Perc F2"})
				aAdd(aExp, {"PZ6_PERCF3", PZ6->PZ6_PERCF3 , "PZ6->PZ6_PERCF3", "Perc F3"})
				aAdd(aExp, {"PZ6_PERCF4", PZ6->PZ6_PERCF4 , "PZ6->PZ6_PERCF4", "Perc F4"})
				aAdd(aExp, {"PZ6_PERCF5", PZ6->PZ6_PERCF5 , "PZ6->PZ6_PERCF5", "Perc F5"})

			EndIf

			aAdd(aExp, {"PZ6_IDPER" + cOrdem , PZ6->PZ6_IDPER , "PZ6->PZ6_IDPER", "Id periodo"})
			aAdd(aExp, {"PZ6_BASAJU" + cOrdem , PZ6->PZ6_BASAJU , "PZ6->PZ6_BASAJU", "Base Aju"})

			aAdd(aExp, {"PZ6_METAF1" + cOrdem , PZ6->PZ6_METAF1 , "PZ6->PZ6_METAF1", "Meta F1"})
			aAdd(aExp, {"PZ6_METAF2" + cOrdem , PZ6->PZ6_METAF2 , "PZ6->PZ6_METAF2", "Meta F2"})
			aAdd(aExp, {"PZ6_METAF3" + cOrdem , PZ6->PZ6_METAF3 , "PZ6->PZ6_METAF3", "Meta F3"})
			aAdd(aExp, {"PZ6_METAF4" + cOrdem , PZ6->PZ6_METAF4 , "PZ6->PZ6_METAF4", "Meta F4"})
			aAdd(aExp, {"PZ6_METAF5" + cOrdem , PZ6->PZ6_METAF5 , "PZ6->PZ6_METAF5", "Meta F5"})

			PZ6->(DbSkip())
		EndDo              

		PZ6->(DbSkip(-1))
		__cDtAte := DTOC(PZ6->PZ6_PERFIM)

	EndIf 

	aAdd(aExp, {"DATA_DE"	, __cDtDe	, ""	, "Data De"})
	aAdd(aExp, {"DATA_ATE"	, __cDtAte	, ""	, "Data Ate"})

	aAdd(aExp, {"N_ITENS", nItens, "", "Qtd Itens"})		

Return(aExp)