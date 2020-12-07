#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"  


/*/{Protheus.doc} FPVERE03
@description Impressao da planilha de Metas de Promotor em Word
@author Fernando Rocha
@since 10/02/2017
@version undefined
@type function
/*/
User Function FPVERE03

	Local aPergs		:= {}
	Local cRefPer	  	:= 'FPVER03' + cEmpAnt
	Local cFileName    	:= __cUserID +"_"+ cRefPer

	Private cAno		:= Space(4)
	Private cMatricula	:= Space(6)
	Private nEmpresa	:= 0
	Private cDirDest	:= Space(170)
	Private cCodEmp		:= "01"
	Private cArqSaida	:= ""

	aAdd( aPergs ,{2,"Empresa:"  		,1  ,{"Biancogres","Incesa", "LM"},50, '.T.',.T.})
	aAdd( aPergs ,{1,"Ano:"	   			,cAno  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Matricula:"		,cMatricula  ,"",,"SRA",'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino: " 	,cDirDest  ,"","","", 75 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE} )

	If !ParamBox(aPergs ,"Formulário Metas Promotor",,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf

	nEmpresa		:= ParamLoad(cFileName,,1 , nEmpresa)
	cCodEmp			:= IIf(nEmpresa==1,"01","05")
	cAno   			:= ParamLoad(cFileName,,2 , cAno)
	cMatricula   	:= ParamLoad(cFileName,,3 , cMatricula)
	cDirDest		:= ParamLoad(cFileName,,4 , cDirDest)

	cArqSaida	:= AllTrim(cDirDest) + "Form_Metas_Bianco_"+cMatricula+"_"+cAno+".doc"

	U_BIAMsgRun("Aguarde... Gerando documento WORD... ",,{|| fGeraWord() })

	shellExecute("Open", cArqSaida, "", "C:\", 1 )

Return

Static Function fGeraWord()

	Local cAux      := ""
	Local aMacros	:= {}
	Local aCampos   := {}
	Local nX        := 0
	Local nCopias   := 1 
	Local cPath     := GETTEMPPATH()
	Local nAt		:= 0
	Local lImpress  := .F.  
	Local lArquivo  := .T.
	Local oWord     := NIL
	Local cArqWord  := "\P10\PROMOTOR\Form_Metas_Bianco.dot"
	Local bVarExpRW := 	bVarExpRW := {|| fPrepVar()} //bloco para preenchimento das Variaveis
	local I


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
		MsgInfo("Clique em OK para fechar o Microsoft Word.", "Formulário de Metas Promotor")	
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
	Local nItens    := 0
	Local nTotProp  := 0
	Local cOrdem    := ""
	Local cAliasTmp
	Local cMes
	Local I
	Local cCodFunc	:= ""
	Local nPRat		:= 100
	Local nMesAtu   := Month(dDataBase)
	Local cFNCName

	aAdd(aExp, {"ANO"	, cAno	, "@!"	, "ANO"})

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NoParser%

		select TOP 2 Z81_ANO, Z81_DATCAD, Z81_REVISA from %Table:Z81% where Z81_ANO = %Exp:cAno% order by Z81_DATCAD, Z81_HORCAD desc

	EndSql

	(cAliasTmp)->(DbGoTop())

	If !(cAliasTmp)->(Eof())

		aAdd(aExp, {"DATA_REV_ATU"	, DTOC(STOD((cAliasTmp)->Z81_DATCAD))	, "@!"	, "Data Revisao Atual"})
		aAdd(aExp, {"NUM_REV"	, (cAliasTmp)->Z81_REVISA	, "@!"	, "Numero Revisao Atual"})

	EndIf

	(cAliasTmp)->(DbSkip())
	If !(cAliasTmp)->(Eof())
		aAdd(aExp, {"DATA_REV_ANT"	, DTOC(STOD((cAliasTmp)->Z81_DATCAD))	, "@!"	, "Data Revisao Anterior"})	
	Else
		aAdd(aExp, {"DATA_REV_ANT"	, ""	, "@!"	, "Data Revisao Anterior"})
	Endif

	(cAliasTmp)->(DbCloseArea())

	cFNCName := "% FNC_PVE_RELAT02_"+AllTrim(CEMPANT)+" %"

	cMes := ""
	For I := 1 To 12

		cMes := StrZero(I,2)

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			%NoParser%

			select * from %Exp:cFNCName%(%Exp:cCodEmp%,%Exp:cAno%,%Exp:cMes%,0) where P_MAT = %Exp:cMatricula%

		EndSql

		(cAliasTmp)->(DbGoTop())

		If !(cAliasTmp)->(Eof())

			__nPCab := aScan(aExp, {|x| AllTrim(x[1]) == "REPRESENTANTE"  })

			If !(__nPCab > 0)

				cCodFunc := (cAliasTmp)->P_CODFUNC
				nPRat	 := (cAliasTmp)->P_RATEIO

				aAdd(aExp, {"REPRESENTANTE"	, (cAliasTmp)->REPRESENTANTE	, "@!"	, "REPRESENTANTE"})
				aAdd(aExp, {"PROMOTOR"		, (cAliasTmp)->P_NOME			, "@!"	, "PROMOTOR"})
				aAdd(aExp, {"LOJAS"			, (cAliasTmp)->C_NOME			, "@!"	, "LOJAS"})

			Else

				cCodFunc := (cAliasTmp)->P_CODFUNC
				nPRat	 := (cAliasTmp)->P_RATEIO

				aExp[__nPCab][2] := (cAliasTmp)->REPRESENTANTE
				aExp[__nPCab+1][2] := (cAliasTmp)->P_NOME
				aExp[__nPCab+2][2] := (cAliasTmp)->C_NOME 

			EndIf

			aAdd(aExp, {"META_"+cMes	, (cAliasTmp)->V_META			, "@E 9,999,999.99"	, "META_01"})
			aAdd(aExp, {"REAL_"+cMes	, (cAliasTmp)->V_REAL			, "@E 9,999,999.99"	, "REAL_01"})
			aAdd(aExp, {"PERFOR_"+cMes	, (cAliasTmp)->V_PERFORMANCE*100, "@E 999.99"		, "PERFOR_01"})

		Else

			aAdd(aExp, {"META_"+cMes	, 0			, "@E 9,999,999.99"	, "META_01"})
			aAdd(aExp, {"REAL_"+cMes	, 0			, "@E 9,999,999.99"	, "REAL_01"})
			aAdd(aExp, {"PERFOR_"+cMes	, 0			, "@E 999.99"		, "PERFOR_01"})

		EndIf

		(cAliasTmp)->(DbCloseArea())

	Next I


	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NoParser%

		select * from %Table:Z80% where Z80_CODFUN = %Exp:cCodFunc% and Z80_VIGFIM >= %Exp:DTOS(dDataBase)% and D_E_L_E_T_='' order by Z80_PERC

	EndSql

	(cAliasTmp)->(DbGoTop())
	_nCont := 1
	While !(cAliasTmp)->(Eof())

		aAdd(aExp, {"PREMIO_"+StrZero(_nCont,2)	, ((cAliasTmp)->Z80_PREMIO * nPRat)/100	, "@E 9,999.99"	, "PREMIO_"+StrZero(_nCont,2)})
		_nCont++

		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())

Return(aExp)