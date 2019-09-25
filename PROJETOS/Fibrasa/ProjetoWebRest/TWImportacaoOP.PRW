#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "MSOBJECT.CH" 
#include "TOTVS.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "RPTDEF.CH"  
#include "TOTVS.CH"      

#DEFINE ENTER Chr(013) + Chr(10)     

Static oGrid

Class TWImportacaoOP 

	//________________________________________________________________________________________________________________
	//                                                                                                                |   
	// Propriedades da classe                                                                                         | 
	//________________________________________________________________________________________________________________|
	
	Data oDlg 						// MsDialog
	//Data oGrid						//  	
	Data oPnlGrid	 				// 				
	Data oPnlFiltro					// 
	
	Data aCrd 						// Array com a coordenadas de tela	 
	Data oFWLayer                   // 
	Data cTitulo            		//  
	
	
	Data aSize          			// Array com a coordenadas de tela  
	Data aObj    					// 
	Data aInfo						// 
	Data aPObj	  					// 
                                     
	Data oGrpFiltro                 // 
	//__________________________________________________________________________________________________
	//                                                                                                  | 
	// Filtros da janela                                                                            	| 
	//__________________________________________________________________________________________________|
	
	Data cOrdemProducaoDe
	Data oOrdemProducaoDe
	Data oSayOrdemProducaoDe

	Data cOrdemProducaoAte
	Data oOrdemProducaoAte
	Data oSayOrdemProducaoAte

	Data cRecursoDe
	Data oRecursoDe  
	Data oSayRecursoDe	

	Data cRecursoAte
	Data oRecursoAte  
	Data oSayRecursoAte

	Data dDataInicialDe 
	Data oDataInicialDe 
	Data oSayDataInicialDe 

	Data dDataFinalAte 
	Data oDataFinalAte 
	Data oSayDataFinalAte   
	
	
	Data cTipoApontamentoDe	 
	Data oTipoApontamentoDe	   
	Data oSayTipoApontamentoDe
		   

	Data cTipoApontamentoAte 
	Data oTipoApontamentoAte	   
	Data oSayTipoApontamentoAte
	
	Data oGrpDireita	  
	Data oGrpInferior   
	Data oGrpTotalRegistro
	Data oGrpTotalSelcionado    
	
	Data oBtnFiltrar
	Data oBtnGravar
	Data oBtnLimpar      
	
	Data cBackupQuery      
	
	
	Data oSayTotalSelecionado
	Data oSayTotalRegistro   
	
	Data nTotalSelcionado    
	Data nResultadoSomaColuna     
	Data aProcessamento
	
	
	//__________________________________________________________________________________________________
	//                                                                                                  | 
	// Dados do Destinatario                                                                            | 
	//__________________________________________________________________________________________________|
	
	
	Method New() Constructor 
	Method CarregaInterface()   
	Method Filtrar()
	Method ControlaAcao()  
	Method Gravar() 
	Method GeraApontamento()   
	Method CalculaQuantidadeApontada()
	Method ValidaApontamentOP()

EndClass  


Method New() Class TWImportacaoOP 
	
	::aCrd 				:= FWGetDialogSize(oMainWnd)	
	::oDlg 				:= MsDialog():Create() 
	//::oFWLayer			:= FWLayer():New()
	::oDlg:cName 		:= "oDlg" 				  
	::oDlg:cCaption 	:= " "            
	
	//oGrid				  := Nil  
	::oPnlGrid			  := Nil 
	::oPnlFiltro		  := Nil     
	::oGrpFiltro		  := Nil    
	::oGrpDireita	  	  := Nil
	::oGrpInferior		  := Nil     
	::oGrpTotalRegistro	  := Nil
	::oGrpTotalSelcionado := Nil
	
	::oSayTotalSelecionado := Nil
	::oSayTotalRegistro    := Nil
	
	::oBtnFiltrar		:= Nil
	::oBtnGravar		:= Nil
	::oBtnLimpar     	:= Nil
		
	
	
	::oDlg:nTop 		:= ::aCrd[1]
	::oDlg:nLeft 		:= ::aCrd[2]
	::oDlg:nHeight 		:= ::aCrd[3] 
	::oDlg:nWidth 		:= ::aCrd[4] 
	                                       	
	::oDlg:lShowHint 	:= .F.
	::oDlg:lCentered 	:= .T.
	::oDlg:lEscClose 	:= .T.   
	::oDlg:lMaximized 	:= .T.
	
	//__________________________________________________________________________________________________
	//                                                                                                  | 
	// Filtros da janela                                                                            	| 
	//__________________________________________________________________________________________________|
		
	
	::cOrdemProducaoDe  	:= Space(TamSX3("Z01_OP")[1])
	::oOrdemProducaoDe  	:= Nil
	::oSayOrdemProducaoDe 	:= Nil
	
	
	::cOrdemProducaoAte		:= Space(TamSX3("Z01_OP")[1])
	::oOrdemProducaoAte     := Nil
	::oSayOrdemProducaoAte  := Nil
	
	::cRecursoDe        	:= Space(TamSX3("Z01_RECURS")[1]) 
	::oRecursoDe        	:= Nil
	::oSayRecursoDe 		:= Nil
	
	::cRecursoAte		    := Space(TamSX3("Z01_RECURS")[1])		
	::oRecursoAte  			:= Nil
	::oSayRecursoAte		:= Nil
	
	::dDataInicialDe 		:= dDataBase
	::oDataInicialDe		:= Nil
	::oSayDataInicialDe 	:= Nil
	
	::dDataFinalAte 		:= dDataBase 
	::oDataFinalAte         := Nil
	::oSayDataFinalAte 		:= Nil
	
	::cTipoApontamentoDe	:= Space(TamSX3("Z01_RECURS")[1]) 
	::oTipoApontamentoDe 	:= Nil                  
	::oSayTipoApontamentoDe	:= Nil
	
	::cTipoApontamentoAte	:= Space(TamSX3("Z01_RECURS")[1]) 
	::oTipoApontamentoAte 	:= Nil                  
	::oSayTipoApontamentoAte:= Nil
		                            
		
	//::oGetDados:cQuery		:= ""	
	
	::nTotalSelcionado		:= 0 
	::nResultadoSomaColuna	:= 0
	//________________________________________________________________________________________________ 
	//                                                                                                | 
	// Vari�veis que controlam as coordenadas da janela principal                                     |
	//________________________________________________________________________________________________|
	
	::aSize 			:= {}                                   // 
	::aObj  			:= {}                                   // 
	::aInfo 			:= {}                                   //  
	::aProcessamento	:= {}


Return    

/**/  

/**/
Method CarregaInterface() Class TWImportacaoOP    
     
	    //______________________________________________________________________________________________________
	  	//                                                                                                      | 
	  	//  Vari�veis respons�veis pelas cordenadas da Grid                                                     |
	  	//______________________________________________________________________________________________________|
	  	  
	  	Local nTop 	  	:= 0
		Local nLeft   	:= 0
		Local nHeight 	:= 0
		Local nWidth  	:= 0    
		Local oGetDados := TWGetDados():New()  
		
		
	    //______________________________________________________________________________________________________
	  	//                                                                                                      | 
	  	//  Campo editave� da Grid                                                     							|
	  	//______________________________________________________________________________________________________|
	  	
		Local bCancelar 	:= {|| ::oDlg:End() }  
		Local bCarrega  	:= {|| }
		Local bLimpar		:= {|| }      
		
		Local aAux			:= {}         
		Local aEdicao		:= {"Z01_QTDE","Z01_VOLUME"}
		
		Local bFiltrar		:= {|| ::Filtrar(oGetDados) }         
		Local bGravar		:= {|| ::Gravar(oGetDados)}  
		Local bOrdenar  	:= {|| FWMsgRun(, {|oSay| oGetDados:OrdenaDados(oGrid), ::ControlaAcao(oGetDados) },,'Aguarde...Ordenando os registros') }    
		Local bSelecionar 	:= {|| FWMsgRun(, {|oSay| oGetDados:SelecionarRegistro(oGrid) , ::ControlaAcao(oGetDados) },,'Aguarde...Selecinando o registro...') }  
	                      
		Local oFont 		:= TFont():New('Courier new',,-14,.T.)         
		Local oFont18 		:= TFont():New('Arial',,-18,.T.,.T.)  
		
		Local lHasButton 	:= .T. 
		
		//__________________________________________________
		//                                                  | 
		// Campos a serem utilizados na Grid 		        |
		//__________________________________________________|  
    
		aAdd(oGetDados:aField,{"Z01_OP"})
		aAdd(oGetDados:aField,{"Z01_RECURS"})
		aAdd(oGetDados:aField,{"Z01_DTINIC"})
		aAdd(oGetDados:aField,{"Z01_DTFINA"})
		aAdd(oGetDados:aField,{"Z01_QTDE"})    
		
		aAdd(oGetDados:aField,{"B1_QE"})
		aAdd(oGetDados:aField,{"Z01_VOLUME"})
		aAdd(oGetDados:aField,{"C2_PRODUTO"})   
		aAdd(oGetDados:aField,{"B1_DESC"})
		   
		aAdd(oGetDados:aField,{"Z01_SUBLOT"})
		aAdd(oGetDados:aField,{"Z01_OPERAD"})
		aAdd(oGetDados:aField,{"Z01_REFUGO"})         
		aAdd(oGetDados:aField,{"Z01_TIPO"})

		oGetDados:cQuery := " SELECT 				  						" 
		oGetDados:cQuery += "  Z01_OP                 						"
		oGetDados:cQuery += " ,Z01_RECURS             						"
		oGetDados:cQuery += " ,Z01_DTINIC             						"
		oGetDados:cQuery += " ,Z01_DTFINA             						"      
		oGetDados:cQuery += " ,Z01_QTDE               						"
		oGetDados:cQuery += " ,ISNULL(T.C2_PRODUTO, '') AS 'C2_PRODUTO' 	" 
		oGetDados:cQuery += " ,ISNULL(T.B1_DESC, '') 	AS 'B1_DESC' 		" 
		oGetDados:cQuery += " ,ISNULL(T.B1_QE, 0) 		AS 'B1_QE'			"	
		oGetDados:cQuery += " ,ISNULL(Z01_QTDE/ B1_QE,0) 'Z01_VOLUME' 		"  
		
		oGetDados:cQuery += " ,Z01_SUBLOT             						"
		oGetDados:cQuery += " ,Z01_OPERAD             						"
		oGetDados:cQuery += " ,Z01_REFUGO             						"
		oGetDados:cQuery += " ,Z01_TIPO               						"
		oGetDados:cQuery += " ,Z01.R_E_C_N_O_ AS RECNO               		"
		oGetDados:cQuery += " FROM "+ RetSqlName("Z01") +" AS Z01 		   	" 
		
		oGetDados:cQuery += " LEFT JOIN ( 									  "	
		oGetDados:cQuery += " 	SELECT 										  "    
		oGetDados:cQuery += " 	SC2.C2_FILIAL 'FILIAL',	                      "
		oGetDados:cQuery += " 	SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN 'OP',"
		oGetDados:cQuery += " 	SC2.C2_PRODUTO,                               " 
		oGetDados:cQuery += " 	SB1.B1_DESC,	                              "  
		oGetDados:cQuery += " 	SB1.B1_QE                                     "
		oGetDados:cQuery += " 	FROM SC2150  SC2                              "
		oGetDados:cQuery += " 	INNER JOIN SB1150 SB1 ON                      "
		oGetDados:cQuery += " 	SB1.D_E_L_E_T_ = ''                           "
		oGetDados:cQuery += " 	AND SB1.B1_FILIAL	= SC2.C2_FILIAL           "
		oGetDados:cQuery += " 	AND SB1.B1_COD		= SC2.C2_PRODUTO          "
		oGetDados:cQuery += " 	WHERE SC2.D_E_L_E_T_ = ''                     "
		oGetDados:cQuery += " ) T ON                                          "
		oGetDados:cQuery += "                                                 "
		oGetDados:cQuery += " T.FILIAL  = Z01.Z01_FILIAL                      " 
		oGetDados:cQuery += " AND T.OP  = Z01.Z01_OP                          "
		oGetDados:cQuery += " AND Z01_QTDE > 0 								  "		
		
		oGetDados:cQuery += " WHERE Z01.D_E_L_E_T_ = '' 				   	  "
		oGetDados:cQuery += " AND   Z01.Z01_FILIAL = '"+xFilial("Z01")+"' 	  "    
		oGetDados:cQuery += " AND Z01.Z01_SITUAC = '0'   					  "
		
		::cBackupQuery 	 := oGetDados:cQuery                                                        
		
		oGetDados:lLegenda 			:= .T.	
		oGetDados:lRecno   			:= .T. 
		oGetDados:lFlag	   			:= .T.  
		oGetDados:nCampoBitMaps		:=  2 
			              
	    
 		aAux := oGetDados:MapeiaCampos()  
 		
 		//_________________________________________________________________________________________________________________________________________________________
 		//                                                                                                                                                         | 
 		// Descricao : Inclusao de Validacao na MsNewGetDados. Mais especificamente no campo Z01_QTDE                                                              |
 		//_________________________________________________________________________________________________________________________________________________________|
 		
 		nPos := aScan(aAux,{|x| Alltrim(x[2]) == "Z01_QTDE"})
 		 
 		If nPos> 0  
		     //aAux[nPos][6] := "U_VLDAPTO()" 
		Endif                                  
		
		DEFINE MSDIALOG ::oDlg TITLE "Ordem de Producao" FROM 000,000 TO 600,980 PIXEL 
		
	    oGrid := MsNewGetDados():New(003,003,245,350,GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue","AllwaysTrue","",{"Z01_VOLUME"},,9999,,,,::oDlg, aAux ,{})      
	    
	    //__________________________________________________________________________________________________________________
	  	//                                                                                                      			| 
	  	//  Descricao : Metodo que aciona a marcacao do registro atualmente posicionado na linha e coluna corrente          |
	  	//__________________________________________________________________________________________________________________|
	  	
	    oGrid:oBrowse:bLDblClick := bSelecionar   
	    
	    //__________________________________________________________________________________________________________________
	  	//                                                                                                      			| 
	  	//  Descricao : Metodo que aciona a marcacao do registro                                                    		|
	  	//__________________________________________________________________________________________________________________|
	  	
	    oGrid:oBrowse:bHeaderClick := bOrdenar 
	    
	    
	    ::oGrpDireita 		  := TGroup():New( 003,355, 245,488,'Filtro'			  	, ::oDlg,,,.T.)      

		::oGrpTotalSelcionado := TGroup():New( 250,003, 295,176,'Total Selecionado' 	, ::oDlg,,,.T.)      
		::oGrpTotalRegistro   := TGroup():New( 250,181, 295,350,'Total Registro'	  	, ::oDlg,,,.T.)     
		::oGrpInferior		  := TGroup():New( 250,355, 295,488,'Acao'				  	, ::oDlg,,,.T.)    
		
		
		::oSayOrdemProducaoDe 	:= TSay():New(013,358,{|| "OP De"},::oGrpDireita,,oFont,,,,.T. , CLR_RED,CLR_WHITE,200,20)  
		::oOrdemProducaoDe		:= TGet():New(024,358, { | u | If( PCount() == 0, ::cOrdemProducaoDe, ::cOrdemProducaoDe := u ) },::oDlg, 060, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"::cOrdemProducaoDe",,,,lHasButton)
		
		::oSayOrdemProducaoAte  := TSay():New(013,423,{|| "OP Ate"},::oGrpDireita,,oFont,,,,.T. , CLR_RED,CLR_WHITE,200,20)  
        ::oOrdemProducaoAte  	:= TGet():New( 024,423, { | u | If( PCount() == 0, ::cOrdemProducaoAte, ::cOrdemProducaoAte := u ) },::oDlg, 060, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"::cOrdemProducaoAte",,,,lHasButton)
             
		::oSayRecursoDe  		:= TSay():New(042,358,{|| "Recurso De"},::oGrpDireita,,oFont,,,,.T. , CLR_RED,CLR_WHITE,200,20)  
		::oRecursoDe 			:= TGet():New( 051,358, { | u | If( PCount() == 0, ::cRecursoDe, ::cRecursoDe := u ) },::oDlg, 060, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"::cRecursoDe",,,,lHasButton)
		
		::oSayRecursoAte  		:= TSay():New(042,423,{|| "Recurso Ate"},::oGrpDireita,,oFont,,,,.T. , CLR_RED,CLR_WHITE,200,20)  
		::oRecursoAte			:= TGet():New( 051,423, { | u | If( PCount() == 0, ::cRecursoAte, ::cRecursoAte := u ) },::oDlg, 060, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"::cRecursoAte",,,,lHasButton)
		
		::oSayDataInicialDe		:= TSay():New(071,358,{|| "Data Inicial"},::oGrpDireita,,oFont,,,,.T. , CLR_RED,CLR_WHITE,200,20)  
		
		@ 080,358 MSGET ::oDataInicialDe VAR ::dDataInicialDe  Picture "@!" When .T. SIZE 060,010 OF ::oDlg PIXEL HASBUTTON 
									
		
		::oSayDataFinalAte		:= TSay():New(071,423,{|| "Data Final"},::oGrpDireita,,oFont,,,,.T. , CLR_RED,CLR_WHITE,200,20)  
		@ 080,423 MSGET ::oDataFinalAte VAR ::dDataFinalAte  Picture "@!" When .T. SIZE 060,010 OF ::oDlg PIXEL HASBUTTON							

		//_______________________________________________________________________________________________________________________________________________________________
	  	//                                                                                                      			                                             | 
	  	//  Descricao : Filtro que determina a carga inicial dos dados na grid. O objetivo do mesmo e tornar a rotina mais performatica                                  |  
	  	//_______________________________________________________________________________________________________________________________________________________________|
	  	
		oGetDados:cQuery += " AND Z01_DTINIC >= '"+ DTOS(::dDataInicialDe) +"'  AND Z01_DTFINA <= '"+ DTOS(::dDataFinalAte) +"'  "    
		
		                     
		oGrid:oBrowse:Refresh()  
		
		::oSayTotalSelecionado := TSay():New(272,086,{|| cValToChar(::nTotalSelcionado)}, ::oGrpTotalSelcionado	,,oFont18,,,,.T.,CLR_RED,CLR_WHITE,200,20)  	
		::oSayTotalRegistro    := TSay():New(272,266,{|| cValToChar(::nResultadoSomaColuna)}, ::oGrpTotalRegistro,,oFont18,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		
		::oBtnFiltrar			:= TButton():New( 268, 358, "Filtrar"	,::oGrpInferior, bFiltrar , 060,020,,,.F.,.T.,.F.,,.F.,,,.F.)  
		::oBtnGravar		 	:= TButton():New( 268, 423, "Gravar"	,::oGrpInferior, bGravar  , 055,020,,,.F.,.T.,.F.,,.F.,,,.F.)  
		::oBtnGravar:lActive 	:= .F. 
		
		FWMsgRun(, {|oSay| ::Filtrar(oGetDados)/*, oGetDados:InputaValores(oGrid)*/},,'Aguarde...Selecionando os daodos') 
		                                                                                                                         
		ACTIVATE MSDIALOG ::oDlg CENTERED 
Return 


/**/            
Method Filtrar(oGetDados) Class TWImportacaoOP  
	
	Local lFiltro 	:= .F.    
	
	Local nPosRecno := aScan(oGrid:aHeader,{|x| Alltrim(x[2])=="RECNO"}) 	
	Local nX	  	:=  0
	
	oGetDados:cQuery := ::cBackupQuery	
	
	If !Empty(::cOrdemProducaoAte) 
		 oGetDados:cQuery += " AND Z01_OP BETWEEN '" + ::cOrdemProducaoDe + "' AND '"+ ::cOrdemProducaoAte +"'" ; lFiltro := .T.
	Endif 
	
	If !Empty(::cRecursoAte)
		oGetDados:cQuery += " AND Z01_RECURS BETWEEN '" + ::cRecursoDe 	 + "' AND '"+ ::cRecursoAte +"'" ; lFiltro := .T. 
  	Endif                  
  	    
  	If !Empty(::dDataFinalAte)
  		 oGetDados:cQuery += " AND Z01_DTINIC >= '"+ DTOS(::dDataInicialDe) +"' AND Z01_DTFINA <= '"+ DTOS(::dDataFinalAte) +"' " ; lFiltro := .T. 
	Endif 
	
	oGetDados:cQuery += " AND Z01_QTDE > 0"  
	                  
	If lFiltro
		FWMsgRun(, {|oSay| oGetDados:InputaValores(oGrid)},,'Aguarde...Selecionando os dados') 
		oGrid:oBrowse:Refresh()
	Else 
		MsgStop("Favor preencher corretamente os campos de filtro de dados", "Atencao")
	Endif 	
	
	
	//________________________________________________________________________________________________________________________________________________________________
	//                                                                                                                                                                | 
	// Descri��o : Atualiza o                                                                                                                                         |
	//________________________________________________________________________________________________________________________________________________________________|
	
	oGetDados:aRecno		:= {}
	
	::nTotalSelcionado 	  	:= Len(oGetDados:aRecno)
	
	
	::oSayTotalRegistro:SetText(cValToChar(0))

	::oBtnGravar:lActive 	:= .F.      
	                            
	
	If !Empty(oGrid:aCols) 
		 
		 For nX := 1 To Len(oGrid:aCols)
		 		 
		 		 Z01->(dbGoto(oGrid:aCols[nX][nPosRecno]))
		 		 
		 		 FWMsgRun(, {|oSay| },,"Aguarde...Atualizando a marcacao "+cValToChar(nX)+" ") 
		 		 
		 		 If Z01->(Z01_STATUS) == "0"   
				 	 
				 	 If Z01->Z01_TIPO == "1"
				 	 	 oGrid:aCols[nX][2] := LoadBitmap(GetResources(),'BR_AMARELO')  
				 	 Else
				 	 	 oGrid:aCols[nX][2] := LoadBitmap(GetResources(),'BR_VERDE')   
				 	 Endif 
				 Else
				     oGrid:aCols[nX][2] := LoadBitmap(GetResources(),'BR_VERMELHO')    	 		 
		 		 Endif 
		 Next nX                                                          
		 
	Endif 

Return                                                                        

Method ControlaAcao(oGetDados) Class TWImportacaoOP  

	Local nPosQt			:= aScan(oGrid:aHeader,{|x| Alltrim(x[2])=="Z01_QTDE"})    
	Local nPosRecno			:= aScan(oGrid:aHeader,{|x| Alltrim(x[2])=="RECNO"})
	Local nImgFlg  			:= aScan(oGrid:aHeader,{|x| Alltrim(x[2])=="OK"})        
	Local nLinAt   			:= oGrid:oBrowse:nAt   
	
	Local nX				:= 0
	
	::oBtnGravar:lActive 	:= oGetDados:nQuantidadeSelecionada > 0   
	::nTotalSelcionado 	  	:= Len(oGetDados:aRecno)
	
	::oSayTotalSelecionado:SetText(cValToChar(::nTotalSelcionado))       
	                                                 
	::CalculaQuantidadeApontada(oGetDados)
    	 
	::oBtnGravar:Refresh()
Return 

       
/**/
Method Gravar(oGetDados) Class TWImportacaoOP        


    Local cSQL		:= ""    
    Local cMsg		:= ""
    Local cTitulo	:= "Status de Processamento"
    
    Local cWorkArea := GetNextAlias()          
                     
    Local aDADOS	:= {}
    Local nX	  	:= 0    
    
    
    For nX := 1 To Len(oGetDados:aRecno) 
    	    
    		cSQL := " SELECT				  "
			cSQL += " Z01_FILIAL	FILIAL	, "
			cSQL += " Z01_SITUAC	SITUAC	, "
			cSQL += " Z01_ARQUIV	ARQUIV	, "
			cSQL += " Z01_OP		OPNUME	, "
			cSQL += " Z01_RECURS	RECURS	, "
			cSQL += " Z01_DTINIC	DTINIC	, "
			cSQL += " Z01_HRINIC	HRINIC	, "
			cSQL += " Z01_DTFINA	DTFINA	, "
			cSQL += " Z01_HRFINA	HRFINA 	, "
			cSQL += " Z01_QTDE		OPQTDE	, "
			cSQL += " Z01_VOLUME	VOLUME	, "
			cSQL += " Z01_SUBLOT	SUBLOT	, "
			cSQL += " Z01_QTPERD	QTPERD	, "
			cSQL += " Z01_OPERAD	OPERAD	, "
			cSQL += " Z01_REFUGO	REFUGO	, "
			cSQL += " Z01_STATUS	OPSTAT  , "
			cSQL += " Z01_TIPO		OPTIPO  , "
			cSQL += " R_E_C_N_O_	RECNO_    "
			cSQL += " FROM "+ RetSqlName("Z01")+"  Z01 								"
			cSQL += " WHERE Z01.D_E_L_E_T_ =''   									"
    		cSQL += " AND Z01.Z01_SITUAC = '0'   									"
    		cSQL += " AND Z01.R_E_C_N_O_ = "+ cValToChar(oGetDados:aRecno[nX]) +" 	"  	  
    		
	
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cWorkArea, .T., .F. )
			
			aDADOS := {} 
    	    
    	    While (cWorkArea)->(!EoF()) 
	    	
				aAdd(aDADOS,{          							 ;
								AllTrim((cWorkArea)->OPNUME)	,;
								AllTrim((cWorkArea)->RECURS)	,;
								(cWorkArea)->DTINIC				,;
								AllTrim((cWorkArea)->HRINIC)	,;
								(cWorkArea)->DTFINA				,;
								AllTrim((cWorkArea)->HRFINA)	,;
								Str((cWorkArea)->OPQTDE)		,;
								Str((cWorkArea)->QTPERD)		,;
								AllTrim((cWorkArea)->OPERAD)	,;
								AllTrim((cWorkArea)->REFUGO)	,;
								(cWorkArea)->OPTIPO				,; 	
								AllTrim((cWorkArea)->OPSTAT)	,;	
								(cWorkArea)->RECNO_          	 ; 	
							})                                       	
				  (cWorkArea)->(dbSkip())
			EndDo
    	   	
    	   	(cWorkArea)->(dbCloseArea())
    	   	
    		::oBtnGravar:lActive := .F.
    		
    		FWMsgRun(, {|oSay|  ::GeraApontamento(aDados) },,'Aguarde...Gerando Apontamento de Producao...') 
    Next 
	
	::Filtrar(oGetDados)
		 
    If !Empty(::aProcessamento)
    	 	 
		 oGetDados:aField 		 := {}      

    	 aAdd(oGetDados:aField,{"Z01_OP"})        
    	 aAdd(oGetDados:aField,{"CR_OBS"}) //Utilizado o CR somente como refer�ncia de campo MEMO         
    	 
         
    	 oGetDados:nCampoBitMaps := 1 
    			 
    	 oGetDados:nGrdTop 		:= 035
    	 oGetDados:nGrdLeft 	:= 003
    	 oGetDados:nGrdBottom	:= (oGetDados:nBottom/2) - 090
    	 oGetDados:nGrdRight 	:= (oGetDados:nRight/2)  - 090
    	 
    	 oGetDados:lLegenda 	:= .T.	
		 oGetDados:lRecno   	:= .T. 
		 oGetDados:lFlag		:= .T.   
			              
    	 oGetDados:aHeader 		:= oGetDados:MapeiaCampos()   
    	 oGetDados:aCols		:= aClone(::aProcessamento)         
    			
    	 oGetDados:VisualizaLogOcorrencia()
    Endif 
 	
 	::aProcessamento := {}
	
Return

/**/
Method CalculaQuantidadeApontada(oGetDados) Class TWImportacaoOP      
	
	Local nPosQt			:= aScan(oGrid:aHeader,{|x| Alltrim(x[2])=="Z01_QTDE"})    
	Local nPosVL			:= aScan(oGrid:aHeader,{|x| Alltrim(x[2])=="Z01_VOLUME"})    
	Local nPosRecno			:= aScan(oGrid:aHeader,{|x| Alltrim(x[2])=="RECNO"})
	Local nImgFlg  			:= aScan(oGrid:aHeader,{|x| Alltrim(x[2])=="OK"})        
	Local nLinAt   			:= oGrid:oBrowse:nAt   
	Local nX				:= 0	
	
	
	If oGetDados:nQuantidadeSelecionada > 0
		
		If  oGrid:oBrowse:nColPos == nImgFlg  
		 	 
		 	 ::nResultadoSomaColuna := 0 
		 	 
		 	 For nX := 1 To Len(oGetDados:aRecno)     
		 	 
			 	    nPos := aScan(oGrid:aCols,{|x| (x[nPosRecno]) == oGetDados:aRecno[nX]}) 
			 	    
			 	    If nPos >  0
			 	    	 ::nResultadoSomaColuna +=  oGrid:aCols[nPos][nPosQt] 
			 	    Endif 
			 Next nX                      
		Endif                                 
		
	ElseIf oGrid:oBrowse:nColPos == nImgFlg  
		 
		 ::nResultadoSomaColuna := 0  	
	Endif 


	For nX := 1 To Len(oGrid:aCols)     
        //QTD PRODUTO         //QTD EMBALAGEM        //VOLUME
		 oGrid:aCols[nX][7] := oGrid:aCols[nX][8]  *  oGrid:aCols[nX][9] 

		 	dbSelectArea("Z01")
			Z01->(dbSetOrder(1)) 
			Z01->(dbGoTo(oGrid:aCols[nX][16])) // recno 	
	 
			RecLock("Z01",.F.)
				Z01->Z01_QTDE	:= oGrid:aCols[nX][7]
				Z01->Z01_VOLUME	:= oGrid:aCols[nX][9]				
			Z01->(MsUnLock())
	 
	
	Next nX         
	oGrid:oBrowse:Refresh()  
	::oSayTotalRegistro:SetText(cValToChar(::nResultadoSomaColuna))
	oGrid:oBrowse:Refresh()  

Return 
          

/**/
Method ValidaApontamentOP() Class TWImportacaoOP        
	    
    Local cSQL	:= ""	  
	Local lRet 	:= .F.      
	
	
	cSQL := " SELECT				  "
	cSQL += " Z01_FILIAL	FILIAL	, "
	cSQL += " Z01_SITUAC	SITUAC	, "
	cSQL += " Z01_ARQUIV	ARQUIV	, "
	cSQL += " Z01_OP		OPNUME	, "
	cSQL += " Z01_RECURS	RECURS	, "
	cSQL += " Z01_DTINIC	DTINIC	, "
	cSQL += " Z01_HRINIC	HRINIC	, "
	cSQL += " Z01_DTFINA	DTFINA	, "
	cSQL += " Z01_HRFINA	HRFINA 	, "
	cSQL += " Z01_QTDE		OPQTDE	, "
	cSQL += " Z01_VOLUME	VOLUME	, "
	cSQL += " Z01_SUBLOT	SUBLOT	, "
	cSQL += " Z01_QTPERD	QTPERD	, "
	cSQL += " Z01_OPERAD	OPERAD	, "
	cSQL += " Z01_REFUGO	REFUGO	, "
	cSQL += " Z01_STATUS	OPSTAT  , "
	cSQL += " Z01_TIPO		OPTIPO  , "
	cSQL += " R_E_C_N_O_	RECNO_    "
	cSQL += " FROM "+ RetSqlName("Z01")+"  Z01 								"
	cSQL += " WHERE Z01.D_E_L_E_T_ =''   									"
 	cSQL += " AND Z01.Z01_SITUAC = '0'   									"
    cSQL += " AND Z01.R_E_C_N_O_ = "+ cValToChar(oGetDados:aRecno[nX]) +" 	"  	  
    		
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cWorkArea, .T., .F. )                   
	
	
			
Return lRet 


/**/
Method GeraApontamento(aDados) Class TWImportacaoOP     
                      
//LOCAL aDADOS := {}
Local nX
Local nOP_T    := 0
Local nOP_P    := 0									//Contador de OP apontada Total ou Parcial
Local lRet     := .T.
Local cPath    := GetSrvProfString("Startpath","")
Local aCabec   := {}
Local aItens   := {}
Local aLinha   := {}
Local cProdRef := ""   


If Len(aDADOS) == 0
	ConOut("N�o h� OPs para serem processadas. Favor verificar.")
	Return
EndIf

aVetor := {}
nOP_T := nOP_P := 0

For nX := 1 To Len(aDADOS)     

	aVetor := {}
	
	/*
	01 - OP - N�mero da OP
	02 - Recurso - Recurso	C�digo do recurso / m�quina utilizado na opera��o.
	03 - Data Inicial - Data de Entrada do Operador
	04 - Hora Inicial - Hora de Entrada do Operador
	05 - Data Final - Data de Sa�da do Operador
	06 - Hora Final - Hora de Sa�da do Operador
	07 - Qtde Produzida - Quantidade Real Produzida
	08 - Qtde Perda - Quantidade real de PA Refugado
	09 - Operador - Nome do Operador
	10 - Motivo - Motivo do Refugo
	11 - Tipo Dado - Envia 0 se for para informar produ��o ou envia 1 se for para informar refugo.
	12 - Status da OP - Envia 0 se a mesma ainda permanece aberta para apontamentos complementares ou 1 se ser� considerada finalizada.
	*/
	
	dbSelectArea("SC2")
	
	// Variaveis a serem utilizadas nas rotinas automaticas
	nRegZ01	:= aDADOS[nX,13]
	aOP := GetAdvFVal("SC2",{"C2_PRODUTO","C2_LOCAL","C2_RECURSO","C2_QUANT"},xFilial("SC2")+AllTrim(aDADOS[nX,01]),1,"")
	
	cOp := aDADOS[nX,01]//+"01001"
	
	nQtdOp := Posicione("SC2",1,xFilial("SC2")+cOP,"C2_QUANT")
	
	cProduto	:= aOP[01]
	dDataIni	:= STOD(StrTran(aDADOS[nX,03],"-",""))
	cHoraIni	:= Left(aDADOS[nX,04],5)
	dDataFin	:= STOD(StrTran(aDADOS[nX,05],"-",""))
	cHoraFin	:= Left(aDADOS[nX,06],5)
	
	//Tratativa do erro:
	//A680HORA
	//Hora final deve ser posterior a inicial quando as datas forem iguais
	If (dDataIni = dDataFin) .And. (cHoraIni = cHoraFin)
	    
	    //Acrescenta 01 minuto quando as datas e horas forem iguais
		cHoraFin := StrTran(cValToChar(SomaHoras(cHoraFin,"00:01")),".",":")
		
		//Para garantir o formato 00:00, acrescenta um zero a esquerda quando ocorrer situacoes 3:09
		If Len(cHoraFin) = 4
			cHoraFin := "0"+cHoraFin
		EndIf
		
	EndIf
	
	cRecurso	:= Upper(aDADOS[nX,02])
	cFerrame 	:= Posicione("SH8",1,xFilial("SH8")+cOp,"H8_FERRAM")
	If Empty(cFerrame)
		cFerrame 	:= Posicione("SG2",3,xFilial("SG2")+cProduto+"01","G2_FERRAM")
	EndIf
	nQtdProd	:= Val(aDADOS[nX,07])
	nQtPerda	:= Val(aDADOS[nX,08])
	If aDADOS[nX,12] == "1"
		cParcTot := "T"
	Else
		cParcTot := "P"
	EndIf
	dDataPon 	:= dDataBase
	cOperado	:= Upper(AllTrim(aDADOS[nX,09]))
	cLocalAr	:= aOP[02]
	nRateio 	:= (nQtdProd / nQtdOp) * 100
	cStatusOP	:= aDADOS[nX,11]
	
	SC2->(dbSeek(xFilial("SC2")+cOP))
	
	If 	aDADOS[nX,11] == "0"	// Quando a linha do arquivo referir-se a Apontamento de Producao
		
		If aDADOS[nX,12] == "0" //Tratamento para Apontamento da OP
			aAdd(aVetor,{"H6_FILIAL"	,xFilial("SH6") ,NIL})
			aAdd(aVetor,{"H6_OP"		,cOp 	  ,NIL})
			aAdd(aVetor,{"H6_PRODUTO"	,cProduto ,NIL})
			aAdd(aVetor,{"H6_OPERAC"  	,"01" 	  ,NIL})
			aAdd(aVetor,{"H6_RECURSO" 	,cRecurso ,NIL})
			aAdd(aVetor,{"H6_FERRAM" 	,cFerrame ,NIL})
			aAdd(aVetor,{"H6_DATAINI" 	,dDataIni ,NIL})
			aAdd(aVetor,{"H6_HORAINI" 	,cHoraIni ,NIL})
			aAdd(aVetor,{"H6_DATAFIN" 	,dDataFin ,NIL})
			aAdd(aVetor,{"H6_HORAFIN" 	,cHoraFin ,NIL})
			aAdd(aVetor,{"H6_QTDPROD" 	,nQtdProd ,NIL})
			conout("H6_PT="+cParcTot)
			nSldOp := ASC2SLD("SC2")
			If  (nSldOp - nQtdProd) < 0
				nQtdMaior := ABS(nSldOp - nQtdProd)
				aAdd(aVetor, {"H6_QTMAIOR",	nQtdMaior,NIL})
			EndIf
			aAdd(aVetor,{"H6_PT" 		,cParcTot ,NIL})
			aAdd(aVetor,{"H6_DTAPONT" 	,dDataPon ,NIL})
			aAdd(aVetor,{"H6_OPERADO" 	,cOperado ,NIL})
			aAdd(aVetor,{"H6_LOCAL"   	,cLocalAr ,NIL})
			aAdd(aVetor,{"H6_RATEIO"  	,nRateio  ,NIL})
			
			lMsErroAuto := .F.
			
			MSExecAuto({|x,y| mata681(x,y)},aVetor,3)	// PCP Mod 2
			
			lRet := .T.
			
			If lMsErroAuto
				
				//cNomArqErro := NomeAutoLog()
				MostraErro(cPath, "SEND_ERR.log")
				cMsgMemo := MemoRead(cPath + "SEND_ERR.log") //Carrega o log gravado
				cMsgLog  := ""
				//cMsgMemo := ""
				
				FT_FUSE("SEND_ERR.log")
				FT_FGOTOP()
				
				While !FT_FEOF()
					cMsgLog  += FT_FREADLN()+"<br>"
					FT_FSKIP()
				EndDo
				FT_FUSE()
				
				U_FIB0715("Erro de Apontamento de Producao - OP: "+AllTrim(cOp),cMsgLog,"apontamento.producao.sd@fibrasa.com.br","","")
				If File("SEND_ERR.log")
					FErase("SEND_ERR.log")
				EndIf
				
				DisarmTransaction()
				lRet := .F.
			EndIf
			
			If !lRet
				
				ConOut("OP "+aDADOS[nX,01]+" apresentou problema no Apontamento de Producao do produto "+cProduto)  
				
				//____________________________________________________________________________________________________
				//                                                                                                    | 
				// Autor : Jesse Augusto	Data : 18/02/2019                                                         | 
				//____________________________________________________________________________________________________|
				//                                                                                                    | 
				// Data : Obtem o Stsus de Processamento do Apontamento                                               |
				//____________________________________________________________________________________________________|
				
				aAdd(::aProcessamento,{LoadBitmap(GetResources(),'BR_VERMELHO'),cOp, cMsgMemo, STRZero(Len(::aProcessamento)+1,3),.F.})
				
			Else
				conout(".... Tipo = Producao | OP = "+cOp+" | QT = "+cVALTOCHAR(nQtdProd)+" | Incluido com sucesso")
				If aDADOS[nX,12] == "1"
					nOP_T++
				Else
					nOP_P++
				EndIf
				
				Z01->(DbGoTo(nRegZ01))
				RecLock("Z01",.F.)
				Z01->Z01_SITUAC	:= "1"
				Z01->(MsUnLock())   
				
				//____________________________________________________________________________________________________
				//                                                                                                    | 
				// Autor : Jesse Augusto	Data : 18/02/2019                                                         | 
				//____________________________________________________________________________________________________|
				//                                                                                                    | 
				// Data : Obtem o Stsus dde Processamento do Apontamento                                              |
				//____________________________________________________________________________________________________|
				
				aAdd(::aProcessamento,{LoadBitmap(GetResources(),'BR_VERDE'), cOp, "Processamento concluido com sucesso!", STRZero(Len(::aProcessamento)+1,3), .F.})
				                                                                          
			EndIf
		Else //Tratamento para Encerramento da OP
			
			dbSelectArea("SH6")
			SH6->(dbSetOrder(1))
			SH6->(dbGoTop())
			
			If SH6->(dbSeek(xFilial("SH6")+cOp,.F.))
				aVetor	:= {}
				aAdd(aVetor,{"H6_OP"		,cOp 		,NIL})
				aAdd(aVetor,{"H6_PRODUTO"	,cProduto 	,NIL})
				
				lMSErroAuto:= .F.
				lMsHelpAuto:= .F.
				
				MsExecAuto({|x, y| mata680(x, y)},aVetor,7 )
				
				lRet := .T.
				
				If lMsErroAuto
					//cNomArqErro := NomeAutoLog()
					MostraErro(cPath, "SEND_ERR.log")
					//cMsgLog := MemoRead(cPath + "SEND_ERR.log") //Carrega o log gravado
					cMsgLog := ""
					
					FT_FUSE("SEND_ERR.log")
					FT_FGOTOP()
					
					While !FT_FEOF()
						cMsgLog += FT_FREADLN()+"<br>"
						FT_FSKIP()
					EndDo
					FT_FUSE()
					
					U_FIB0715("Erro no Encerramento de OP: "+AllTrim(cOp),cMsgLog,"apontamento.producao.sd@fibrasa.com.br","","")
					
					If File("SEND_ERR.log")
						FErase("SEND_ERR.log")
					EndIf
					
					DisarmTransaction()
					lRet := .F.  
					

				EndIf
				
				If !lRet
					ConOut("OP "+cOp+" apresentou problema no Encerramento!")     
					
					//____________________________________________________________________________________________________
					//                                                                                                    | 
					// Autor : Jesse Augusto	Data : 18/02/2019                                                         | 
					//____________________________________________________________________________________________________|
					//                                                                                                    | 
					// Data : Obtem o Stsus dde Processamento do Apontamento                                              |
					//____________________________________________________________________________________________________|
					
					  
					aAdd(::aProcessamento,{LoadBitmap(GetResources(),'BR_VERMELHO'),cOp,STRZero(Len(::aProcessamento)+1,3),.F.})
				Else
					ConOut("OP "+cOp+" Encerrada com Sucesso!")
					
					Z01->(DbGoTo(nRegZ01))
					RecLock("Z01",.F.)
					Z01->Z01_SITUAC	:= "1"
					Z01->(MsUnLock())     
					                                   
					//____________________________________________________________________________________________________
					//                                                                                                    | 
					// Autor : Jesse Augusto	Data : 18/02/2019                                                         | 
					//____________________________________________________________________________________________________|
					//                                                                                                    | 
					// Data : Obtem o Stsus dde Processamento do Apontamento                                              |
					//____________________________________________________________________________________________________|
					
					aAdd(::aProcessamento,{cOp,"OK",.T.})
					
				EndIf
				
			EndIf
		EndIf
	ElseIf aDADOS[nX,11] == "1"	// Quando a linha do arquivo referir-se a Apontamento de Refugo
		
		cArqSG1 := GetNextAlias()
		
		BeginSql Alias cArqSG1
			
			SELECT TOP 1 G1_COMP CODREF
			FROM %Table:SG1% G1
			WHERE G1.%NotDel%
			AND G1_FILIAL = %xFilial:SG1%
			AND G1_COD = %Exp:cProduto%
			AND LEN(G1_COMP) = 8
			AND SUBSTRING(G1_COMP,1,1) = '6'
			ORDER BY G1_REVFIM
			
		EndSql
		
		cProdRef := (cArqSG1)->CODREF //Atribui o codigo do refugo/sobra
		
		If Empty(cProdRef)
			//Caso n�o exista item de sobra
			cMsgLog := ""
			cMsgLog += "Nao foi possivel apontar a perda de producao, verifique os poss�veis motivos:<br><br>"
			cMsgLog += "-Exist�ncia do item SOBRA na estrutura do produto;<br>"
			cMsgLog += "-Exist�ncia do item SOBRA no armazem de processos: 10;<br>"
			//U_FIB0715("Erro de Apontamento de Perda - OP: "+AllTrim(cOp),cMsgLog,"renato@fibrasa.com.br; danilo.gonzaga@fibrasa.com.br; felippe.paul@fibrasa.com.br","","")
			U_FIB0715("Erro de Apontamento de Perda - OP: "+AllTrim(cOp),cMsgLog,"apontamento.producao.sd@fibrasa.com.br","","")
		Else
			
			//
			/*
			01 - GRELHA - OP DE LISO
			02 - ACERTO - OP DE QUALQUER
			03 - APARA LISA - OP DE LISO
			04 - APARA IMPRESSA - OP DE IMPRESSO
			REFILE - OP DE CHAPA
			
			15 caracteres
			come�a com 60
			3 �ltimos diferente de 000
			
			*/
			
			If (aDADOS[nX,10] $ "03" .and. (Len(cProduto)==15 .and. Left(cProduto,2)=="60" .and. Right(cProduto,2)<>"00")); 	// Impresso
				.or. aDADOS[nX,10] $ "01"	// Grelha
				
				lErro03_Impresso	:= .F.	// Indica se houve erro
				
				aRetEstrux	:= U_ESTRUX(cProduto)
				
				If aRetEstrux[2] == 0
					cMsgLog := "OP "+aDADOS[nX,01]+" apresentou problema no mov. valorizado de Sobra, com custo zero para o produto "+cProduto+". Favor verificar."
					lErro03_Impresso	:= .T.
				EndIf
				
				If .not. lErro03_Impresso
					If !fPerdaD3(aRetEstrux[1], aRetEstrux[2], nQtPerda)
						cMsgLog := "OP "+aDADOS[nX,01]+" apresentou problema no mov. valorizado de Sobra para o produto "+cProduto+". Favor verificar."
					EndIf
				EndIf
				
				If lErro03_Impresso
					//cNomArqErro := NomeAutoLog()
					MostraErro(cPath, "SEND_ERR.log")
					//cMsgLog := MemoRead(cPath + "SEND_ERR.log") //Carrega o log gravado
					cMsgLog := ""
					
					FT_FUSE("SEND_ERR.log")
					FT_FGOTOP()
					
					While !FT_FEOF()
						cMsgLog += FT_FREADLN()+"<br>"
						FT_FSKIP()
					EndDo
					FT_FUSE()
					
					//U_FIB0715("Erro de Apontamento de Perda (MP) - OP: "+AllTrim(cOp),cMsgLog,"renato@fibrasa.com.br; danilo.gonzaga@fibrasa.com.br; felippe.paul@fibrasa.com.br","","")
					If File("SEND_ERR.log")
						FErase("SEND_ERR.log")
					EndIf
					
					DisarmTransaction()
					lRet := .F.
				EndIf
				
			Else		// Apontamento de Perda para OP
				
				// Montar Rotina Automatica para Perda
				aCabec := 	{{"BC_FILIAL"   ,xFilial("SBC")      ,NIL},;
							{"BC_OP"        ,aDADOS[nX,01]       ,NIL},;
							{"BC_OPERAC"    ,"01"                ,NIL}}
				
				aItens := 	{{"BC_QUANT"    ,nQtPerda            ,NIL},;
							{"BC_PRODUTO"   ,cProduto            ,NIL},;
							{"BC_LOCORIG"	,aOP[02]             ,NIL},;
							{"BC_CODDEST"	,cProdRef            ,NIL},;
							{"BC_LOCAL"	    ,GetMv("MV_LOCPROC") ,NIL},;
							{"BC_TIPO" 		,"R"                 ,NIL},;
							{"BC_DTVALID" 	,dDatabase 	         ,NIL},;
							{"BC_MOTIVO"    ,aDADOS[nX,10]       ,NIL}}
							
				AAdd(aLinha ,aItens)
				
				lMsErroAuto := .F.
				
				MsExecAuto ( {|x,y,z| MATA685(x,y,z) }, aCabec, aLinha, 3)
				
				If lMsErroAuto
					
					//cNomArqErro := NomeAutoLog()
					MostraErro(cPath, "SEND_ERR.log")
					//cMsgLog := MemoRead(cPath + "SEND_ERR.log") //Carrega o log gravado
					cMsgLog := ""
					
					FT_FUSE("SEND_ERR.log")
					FT_FGOTOP()
					
					While !FT_FEOF()
						cMsgLog += FT_FREADLN()+"<br>"
						FT_FSKIP()
					EndDo
					FT_FUSE()
					
					U_FIB0715("Erro de Apontamento de Perda - OP: "+AllTrim(cOp),cMsgLog,"apontamento.producao.sd@fibrasa.com.br","","")
					If File("SEND_ERR.log")
						FErase("SEND_ERR.log")
					EndIf
					
					DisarmTransaction()
					lRet := .F.
					
					ConOut("OP "+aDADOS[nX,01]+" apresentou problema no Apontamento de Perda/Refugo do produto "+cProduto)
					
				Else
					conout(".... Tipo = Refugo/Perda | OP = "+cOp+" | QT = "+cVALTOCHAR(nQtPerda)+" | Incluido com sucesso")
					
					Z01->(DbGoTo(nRegZ01))
					//Grava o status de finalizado
					RecLock("Z01",.F.)
					Z01->Z01_SITUAC	:= "1"
					Z01->(MsUnLock())
				EndIf
			EndIf
		EndIf
	EndIf
	
Next nX

If nOP_T+nOP_P > 0
	Conout("OP(s) TOTAL(s): "+cVALTOCHAR(nOP_T)+ " | OP(s) PARCIAL(s): "+cVALTOCHAR(nOP_P))
EndIf

Return


/**/
User Function VLDAPTO()
    
	Local nLinAt 	:= oGrid:oBrowse:nAt
    Local nColFlag 	:= Len(oGrid:aHeader) + 1      
    Local nTotal	:= 0
            

	aEval( oGrid:aCols, {|x| iif( x[nColFlag],nTotal++,)}) 
	
Return .T.
