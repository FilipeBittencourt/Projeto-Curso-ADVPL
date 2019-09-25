#include "rwmake.ch"
//
//
//
User Function FWordR0D
Local aMacros   := {"Equipamentos", "Pecas"}
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
Local cArqWord  := "\Proposta_Pecas_weg.dot"
Local bVarExpRW := 	bVarExpRW := {|| fPrepVar()} //bloco para preenchimento das Variaveis

	/*
	旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	쿣erifica se o usuario escolheu um drive local (A: C: D:) caso contrario�
	쿫usca o nome do arquivo de modelo,  copia para o diretorio temporario  �
	쿭o windows e ajusta o caminho completo do arquivo a ser impresso.      �
	읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
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
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿔nicializa o Ole com o MS-Word 97 ( 8.0 )						      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	oWord	:= OLE_CreateLink() ; OLE_NewFile( oWord , cArqWord )
	        	           
	//	旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//  � Carrega Campos Disponiveis para Edicao                       �
	//	읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	aCampos := Eval(bVarExpRW) 

	if (ValType(aCampos) == 'U')
		MsgAlert("N�o foram encontrados dados para o relat�rio!")
		OLE_CloseLink( oWord )
		If Len(cAux) > 0
			fErase(carqword)
		Endif 
		return
	endif
	   
	//	旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//  � Ajustando as Variaveis do Documento                          �
	//	읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
			 
	// 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	// � Executa as Macros                                            �
	// 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	For I := 1 to Len(aMacros) 
		OLE_ExecuteMacro(oWord,aMacros[I])
	Next I
	    	
	// 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	// � Atualiza as Variaveis                                        �
	// 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	OLE_UpDateFields( oWord )
	
	//	旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//	쿔mprimindo o Documento                                                 �
	//	읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	IF lImpress
		For nX := 1 To nCopias
			OLE_SetProperty( oWord, '208', .F. ) ; OLE_PrintFile( oWord )
		Next nX
	ElseIF lArquivo
		OLE_SaveAsFile( oWord, cArqSaida ) 
	Else
		MsgInfo("Clique em OK para fechar o Microsoft Word.", "Proposta")	
	EndIF

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿐ncerrando o Link com o Documento                                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
Local nPecas   := 0
Local nTotProp := 0
Local cOrdem   := ""
Local aUsu     := {}

	PswSeek(__cUserId, .T.)
    aUsu := PswRet()

	SA1->(DbSetOrder(1))                                                                
	SA1->(DbSeek(XFilial("SA1")+AB3->AB3_CODCLI+AB3->AB3_LOJA))
    
    aAdd(aExp, {"EMISSAO",       AB3->AB3_EMISSAO,                                "AB3->AB3_EMISSAO", "Emissao"})
	aAdd(aExp, {"RAZAO_SOCIAL",  AllTrim(SA1->A1_NOME),                           "SA1->A1_NOME",     "Nome"})
	aAdd(aExp, {"CIDADE",        AllTrim(SA1->A1_MUN),                            "SA1->A1_MUN",      "Cidade"})
	aAdd(aExp, {"UF",            AllTrim(SA1->A1_EST),                            "SA1->A1_EST",      "Estado"})
	aAdd(aExp, {"CONTATO",       AllTrim(SA1->A1_CONTATO),                        "SA1->A1_CONTATO",  "Contato"})
	aAdd(aExp, {"TELEFONE",      SA1->("("+AllTrim(A1_DDD)+") "+AllTrim(A1_TEL)), "@!"           ,    "Telefone"})
	aAdd(aExp, {"EMAIL_CONTATO", AllTrim(SA1->A1_EMAIL),                          "SA1->A1_EMAIL",    "Email Contato"})
	aAdd(aExp, {"AB3_NUMORC",    AB3->AB3_NUMORC,                                 "AB3->AB3_NUMORC",  "Num. Or�amento"})
	aAdd(aExp, {"NOME_USUARIO",  AllTrim(aUsu[1, 04]),                            "@!",               "Nome Usuario"})
	aAdd(aExp, {"CARGO_USUARIO", AllTrim(aUsu[1, 13]),                            "@!",               "Cargo"})
	aAdd(aExp, {"TEL_USUARIO",   AllTrim(aUsu[1, 20]),                            "@!",               "Tel Usu"})
	aAdd(aExp, {"EMAIL_USUARIO", AllTrim(aUsu[1, 14]),                            "@!",               "Email Usu"})	

	//Condicao de Pagamento
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(XFilial("SE4")+AB3->AB3_CONPAG))  
	aAdd(aExp, {"CONDICAO_PAGTO", SE4->E4_DESCRI, "SE4->E4_DESCRI", "Cond PG"})

	//equipamentos do orcamento
	SB1->(DbSetOrder(1))	
	AB4->(DbSetOrder(1))
	If AB4->(DbSeek(xFilial("AB4")+AB3->AB3_NUMORC))  
        While !AB4->(Eof()) .And. xFilial("AB4")+AB4->AB4_NUMORC == xFilial("AB3")+AB3->AB3_NUMORC
			SB1->(DbSeek(xFilial("SB1")+AB4->AB4_CODPRO))

			nEqp++
		
			cServ += AllTrim(MSMM(AB4->AB4_MEMO)) + Chr(10) + Chr(13)

			aAdd(aExp, {"EQUIPAMENTO" + cValToChar(nEqp), ;
			            AllTrim(SB1->B1_DESC)+AllTrim(SB1->B1_YMODELO)+" s�rie: "+ AllTrim(AB4->AB4_NUMSER) + ";", ;
			            "@!", "Equipamento"})

			AB4->(DbSkip())
		EndDo
	EndIf       
	
	aAdd(aExp, {"N_EQUIP", nEqp, "", "Num Equip"})	
	
	//servi�os
	aAdd(aExp, {"SERVICOS", cServ, "AB4->AB4_MEMO", "Servi�os"})	
     
	// ====================================================
	// ALFONSO 2018ABR04 PEGANDO DADOS DO CHAMADO TECNICO  
	// =====================================================
	// AB3 Or�amento Tecnico, j� utilizado no programa atual.
	// SQL SELECT  AB3_CODCLI, AB3_LOJA, AB3_EMISSA, * FROM AB3010 WHERE D_E_L_E_T_='' AND
    // AB3_NUMORC='003801' 
    // link entre as duas s� XXX_FILIAL, XXX_CODCLI, XXX_LOJA, XXX_EMISSA  
    // AB1 Chamado Tenico, n�o esta sendo utilizado no programa, mas, nele tem alguns dos dados para o word
    // SELECT AB1_CODCLI, AB1_LOJA, AB1_EMISSA, AB1_CONTAT, AB1_TEL, AB1_ATEND,AB1_YEMAIL,
    // * FROM AB1010 WHERE D_E_L_E_T_='' AND AB1_CODCLI='000742' 
 
	AB1->(DbSetOrder(3)) // tem que cria indice com os campos abaixo ?  
    IF AB1->(DbSeek(XFilial("AB1")+AB3->AB3_CODCLI+AB3->AB3_LOJA+DTOS(AB3_EMISSA))) 
	 
    	aAdd(aExp, {"AB1_CONTAT",       AB1->AB1_CONTAT,                               "AB1->AB1_CONTAT", "Contato"})
    	aAdd(aExp, {"AB1_TEL",          AB1->AB1_TEL,                                  "AB1->AB1_TEL", "Telcontato"})
    	aAdd(aExp, {"AB1_YEMAIL",       AB1->AB1_YEMAIL,                               "AB1->AB1_YEMAIL", "Emailcto"})
    ELSE
    	aAdd(aExp, {"AB1_CONTAT",       '-------',                               "AB1->AB1_CONTAT", "Contato"})
    	aAdd(aExp, {"AB1_TEL",          '-------',                                  "AB1->AB1_TEL", "Telcontato"})
    	aAdd(aExp, {"AB1_YEMAIL",       '-------',                               "AB1->AB1_YEMAIL", "Emailcto"})
    ENDIF
	// FIM ALFONSO
	// =====================================================

	//Selcionando Apontamentos, SERVI�OS E PE�AS
	AB5->(DbSetOrder(1))
	If AB5->(DbSeek(xFilial("AB5")+AB3->AB3_NUMORC))
		While !AB5->(Eof()) .And. AB5->(AB5_FILIAL+AB5_NUMORC) == xFilial("AB3")+AB3->AB3_NUMORC
			SB1->(DbSeek(xFilial("SB1")+AB5->AB5_CODPRO))

			nPecas++
			cOrdem   := cValToChar(nPecas)
			nTotProp += AB5->AB5_TOTAL
		
			aAdd(aExp, {"ITEM" + cOrdem,       AB5->AB5_SUBITE,          "AB5->AB5_SUBITE", "ITEM"})
			aAdd(aExp, {"QTD" + cOrdem,        AllTrim(Transform(AB5->AB5_QUANT, "@E 999,999")), "", "QUANTIDADE"})
			aAdd(aExp, {"UND" + cOrdem,        AllTrim(SB1->B1_UM),      "SB1->B1_UM",      "UN MEDIDA"})			
			aAdd(aExp, {"REFERENCIA" + cOrdem, AllTrim(SB1->B1_YREF),    "SB1->B1_YREF",    "REFERENCIA"})
			aAdd(aExp, {"DESCRICAO" + cOrdem,  AllTrim(AB5->AB5_DESPRO), "AB5->AB5_DESPRO", "DESCRICAO"})
			aAdd(aExp, {"NCM" + cOrdem,        AllTrim(SB1->B1_POSIPI),  "SB1->B1_POSIPI",  "NCM"})
			aAdd(aExp, {"VALOR_UNIT" + cOrdem, AllTrim(Transform(AB5->AB5_VUNIT, "@E 999,999,999.99")), "", "VALOR UNITARIO"})
			aAdd(aExp, {"VALOR_TOT" + cOrdem,  AllTrim(Transform(AB5->AB5_TOTAL, "@E 999,999,999.99")), "",  "VALOR TOTAL"})
			aAdd(aExp, {"ICMS" + cOrdem,       SB1->B1_PICM,             "SB1->B1_PICM",    "ICMS"})						
			aAdd(aExp, {"PRAZO" + cOrdem,      AB5->AB5_YPZENT,          "AB5->AB5_YPZENT", "PRAZO ENTREGA"})									

			AB5->(DbSkip())
		EndDo
	EndIf

	aAdd(aExp, {"N_PECAS", nPecas, "", "Qtd Pe�as"})		
	aAdd(aExp, {"TOTAL_PROPOSTA", AllTrim(Transform(nTotProp, "@E 999,999,999.99")), "", "TOTAL_PROPOSTA"})
Return(aExp)