#INCLUDE "PROTHEUS.CH"
#include "TOTVS.CH"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
                         
//==================================================================================================|
// Autor 	 : Jessé Augusto |  Data: 23/05/2016 | 			                             			|
//==================================================================================================|
// Descrição :                                                                                      | 
//==================================================================================================|
Class TGetDados From LongClassName	
                                       	
		Data aDicionario
		Data cTitulo
		Data cCampo
		Data nTamanho
		Data cMacara
		Data lRecno
		Data lCores	 
		Data cWhere	
		Data cBitmap
		Data objMain
		Data nIndiceOrdenacao 
		Data nQuantCores
		Data aCores  
		Data lFormularioDEB 
		Data cChamadaOrigem   
		Data cAlias
		
		//______________________________________________________________________ 
		//                                                                      | 
		// Propriedade relacionadas ao método de exportação                     |
		//______________________________________________________________________|
		Data oExcel
		Data cPlanilha 
		Data cTitPlanilha
		Data cTituloSalvar
		Data cTipoArquivo
		Data cDiretorio
		Data cExtensao
		Data lArvore   
		Data aLinha
		
		
		Method New(lLegenda, aCabec) Constructor 
		Method MapeiaCampos() 
		Method GerenciaConsultaSQL(oGetDados,cQuery) 
		Method GetDadosVazio(oGetDados)  
		Method Selecionar(oGetDados,nCol,nColAva)    
		Method OrdenaDados()  
		Method Exportar()
		
		
EndClass   

//=======================================================================================|
// Autor 	 : Jessé Augusto |  Data: 23/05/2016 			                             |
//=======================================================================================|
// Descrição : Método construtor da classe											     | 
//=======================================================================================|
Method New(lLegenda, aCabec, lRec, nQuantCor, lFrmDEB ) Class TGetDados

	::cTitulo     	 	:= ""
	::cCampo	  	 	:= ""        	
	::cMacara     	 	:= ""
	::cWhere	  	 	:= ""	
	::cChamadaOrigem	:= ""
	::cBitmap	  	 	:= "" 
	
	
	//______________________________________________________________________ 
	//                                                                      | 
	// Propriedade relacionadas ao método de exportação                     |
	//______________________________________________________________________|
	::oExcel			:= Nil
	::cPlanilha			:= ""
	::cTitPlanilha		:= ""
	::cDiretorio		:= ""
	::cTituloSalvar	    := 'Exportar'
	::cTipoArquivo		:= '*.xls' 
	::cExtensao			:= ".xls"
	::lArvore           := .F.
	     
	::aLinha			:= {} 
    ::aCores			:= {} 
	                      
	//______________________________________________________________________
	                                                                        
	::nTamanho    	 	:= 0
	::nIndiceOrdenacao 	:= 0  
	
	::aDicionario 	    := aCabec 
	::objMain 		    := Nil  
	 
	::nQuantCores 	    := nQuantCor                        
	::lRecno      	    := lRec  
	::lFormularioDEB    := lFrmDEB 
	
	::cAlias			:= ""
	
	::MapeiaCampos(lLegenda)	
	
Return 


Method MapeiaCampos(lLegenda) Class TGetDados 

	Local aAux := {}
	Local nK   := 0
	Local nX   := 0
    
    //======================================================================
	// Tratamento específico para criação de Legenda
	//======================================================================
    If lLegenda
    	 Aadd(aAux,{" ","OK","@BMP", 1, 0,"",,"C","",""})    
    Endif  
    
    //______________________________________________________________________
    //                                                                      | 
    // Cria coluna(s) que representarão a legenda                           | 
    //______________________________________________________________________|
    
    If ::nQuantCores > 0  .And. ::lFormularioDEB
              
    	 For nK := 1 To ::nQuantCores
    	 
    	 	    Aadd(aAux,{" ","COL"+StrZero(nK,2),"@BMP", 1, 0,"",,"C","",""})    
    	 Next nK
    Endif   
  
    
    SX3->(dbSetOrder(2))
    
	For nX := 1 To Len (::aDicionario)
		   
			   //======================================================================
	    	   // Posiciona sobre o campo informado a fim de obter suas configurações
	    	   //======================================================================
			   If SX3->(dbSeek(::aDicionario[nX][1]))
			                                       
			          //===============================================================|
			          // Permite a personalização dos campos padrões                   |                                             
			          //===============================================================|
			          ::cTitulo  := TRIM(x3Titulo()) 
					  ::nTamanho := SX3->X3_TAMANHO 
			                
			          //===============================================================|
			          // Tratamento específico para campos personalizados				|                                             
			          //================================================================|
			          If ::aDicionario[nX][2]
			          		
			          	    ::cTitulo  := iif( !Empty(::aDicionario[nX][3]) , ::aDicionario[nX][3], TRIM(x3Titulo()))
			          		::nTamanho := iif( ::aDicionario[nX][4] > 0		, ::aDicionario[nX][4], SX3->X3_TAMANHO)
			          Endif 
					  
					  aAdd(aAux,{  ::cTitulo		,;
								   SX3->X3_CAMPO	,;	
								   SX3->X3_PICTURE	,;
								   ::nTamanho		,;
								   SX3->X3_DECIMAL	,;
								   SX3->X3_VALID	,;
								   SX3->X3_USADO	,;
								   SX3->X3_TIPO		,;	
								   SX3->X3_F3		,;
								   SX3->X3_CONTEXT	,;
								   SX3->X3_CBOX		,;
								   SX3->X3_RELACAO	,;
								   ".T."			})				
	            
	           Else    
	                 //===============================================================================|
	                 // Campos personalizados a serem utilizados no cabeçalho da Classe MsNewGetDados |
	                 //===============================================================================|
	                 ::cTitulo  := ::aDicionario[nX][2]
					 ::cCampo	:= ::aDicionario[nX][1]
					 ::nTamanho := ::aDicionario[nX][4]
					 ::cMacara  := ::aDicionario[nX][3]
					
	           	     Aadd(aAux,{ ""+::cTitulo+"", ::cCampo, ::cMacara, ::nTamanho , , , , , ,"V"})				
	           Endif
	Next nX 
    
    If ::lRecno  
    	//Aadd(aAux, {"Registro", SX3->X3_ARQUIVO+"REC", "", 22, 0, "ALWAYSTRUE()",, "N", "", "R",,0})
    	Aadd(aAux, {"Registro", "SE1REC", "", 22, 0, "ALWAYSTRUE()",, "N", "", "R",,0})
    Endif                         
    
    ::aDicionario := aClone(aAux) 
    
Return 

//=======================================================================================|
// Autor 	 : Jessé Augusto |  Data: 05/07/2016 			                             |
//=======================================================================================|
// Descrição : 					     												     |	 
//=======================================================================================|

Method GerenciaConsultaSQL(oGetDados,cQuery) Class TGetDados    
    
    Local cWorkArea := GetNextAlias()               
	//==============================================
	                     
	Local nTam      := 0
	Local nX     	:= 0                            
	
	//============================================== 
	Local aAux	    := {}  
	Local aColsDEB  := {}
	                   
	//==============================================                           
	cQuery   := cQuery + ::cWhere 
    ::cWhere := ""
     
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cWorkArea, .T., .F.)
	
	Count To nTotal 
	                  
	//==========================================|
	// Posiciona no primeiro registro da tabela |
	//==========================================|
	(cWorkArea)->(dbGotop())
	
	ProcRegua(nTotal)
	
	oGetDados:aCols := {}
    
    (cWorkArea)->(dbGoTop()) 
         
	While (cWorkArea)->(!Eof())
	      
	      IncProc(nTotal)
	      
	      aAux := {}                                   
	      
	      //_________________________________________________________________________________________
	      //                                                                                         |  
	      // Posiciona sobre o Álias corrente                                                        | 
	      //_________________________________________________________________________________________| 
	      
	      If ::lRecno
	           
	           SE1->(dbGoto((cWorkArea)->(SE1REC)))
	      Endif                       
	      
		  For nX := 1 To Len(oGetDados:aHeader)
		                                       
		          cCampo := oGetDados:aHeader[nX][2] 
		          nPos   := (cWorkArea)->(FieldPos(oGetDados:aHeader[nX][2]))   
		         
		          If  nPos > 0    
		                                          
		         	  If  oGetDados:aHeader[nX][8] == "D" 
		         	  	  Aadd(aAux,STOD((cWorkArea)->(FieldGet(nPos))))                      
		         	  Else
		         	  	  Aadd(aAux, (cWorkArea)->(FieldGet(nPos)))	 
		         	  Endif 
		         	  
		          Else
		          	   If oGetDados:aHeader[nX][2] == "OK"
		         	    	 
		         	    	Aadd(aAux,::cBitmap)
		         	   
		         	   Elseif oGetDados:aHeader[nX][2]  == "COL01" .And.  ::lFormularioDEB
		         	   		
		         	   		If SE1->E1_PREFIXO == "DEB"
		         	   			Aadd(aAux,LoadBitmap(GetResources(),'BR_VERMELHO')) 
		         	   		Else
		         	   			Aadd(aAux,LoadBitmap(GetResources(),'BR_VERDE'))  
		         	   		Endif 
		         	   Endif 	
		          Endif                          
		         
		  Next nX                                                 
		  
		  //===========================================|
		  // Valor responsável pela seleção do registro| 	
		  //===========================================|
		  Aadd(aAux,.F.) 	
		  
		  //===========================================|
		  // Coluna adicional do aCols.				   | 	
		  //===========================================|
		  Aadd(aAux,.F.) 
		   
		  Aadd(oGetDados:aCols,aClone(aAux))
		  
		  If ::cChamadaOrigem == "TECFAT02"  
		  
		  		If SE1->E1_PREFIXO == "DEB"  .And. ::lFormularioDEB  
		    
	  		   		Aadd(oGetDados:aCols,aClone(aAux))
		       
		       		oGetDados:aCols[Len(oGetDados:aCols)][aScan(oGetDados:aHeader,{|x| x[2] == "COL01" })] := LoadBitmap(GetResources(),'BR_LARANJA')
		       
		  		Endif 
		  Endif
		   
		  (cWorkArea)->(dbSkip())	 
	EndDo
	                   
	(cWorkArea)->(dbCloseArea())
	
	oGetDados:oBrowse:Refresh()      
	
	//________________________________________________
	// aCols Vazio                                    | 
	//________________________________________________|
	If Empty(oGetDados:aCols)      
	
		  ::GetDadosVazio(oGetDados)
	Endif
	
	::objMain := oGetDados
	
Return 
           

//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : GetDadosVazio                                               							|                        
//                                                                      							| 
//__________________________________________________________________________________________________| 
//                                                                                                 	| 
// Descrição : Tratamento específico quando o aCols é vazio após uma determinada operação			| 
//__________________________________________________________________________________________________|

Method GetDadosVazio(oGetDados) Class TGetDados

	Local cCampo := ""
	Local nX 	 := 0   
	
	//==========================================================================================|
	// Zera o aCols  																			|
	//==========================================================================================| 
	oGetDados:aCols := {}
    //==========================================================================================|
	// Cria uma nova linha para o aCols															|
	//==========================================================================================| 
    Aadd(oGetDados:aCols,Array(Len(oGetDados:aHeader)+1))     
    
    For nX := 1 To Len(oGetDados:aHeader)
    
      	   cCampo := oGetDados:aHeader[nX][2]  
           
      	   If cCampo == "OK" .Or.   cCampo == "COL01"   
      	       oGetDados:aCols[1][nX] := 'BR_AMARELO'
      	   Else    
      	       If oGetDados:aHeader[1][8] =="N"
	      	       oGetDados:aCols[1][nX] := 0
	      	   Elseif oGetDados:aHeader[nX][8] =="D"
			   	   oGetDados:aCols[1][nX] := CTOD("")      	  
	      	   Elseif oGetDados:aHeader[nX][8] =="C"
	      	 	   oGetDados:aCols[1][nX] := Space(TamSx3(cCampo)[1])
	      	   Endif 
	      Endif    
	Next nX

  	oGetDados:aCols[1][Len(oGetDados:aHeader)+1] := .F.
	
	//==========================================================================================|
	// Atualiza o objeto                                                                        | 
	//==========================================================================================|   	
  	oGetDados:oBrowse:Refresh()

Return (Nil) 


//______________________________________________________________________
//                                                                      |
// Prgrama   : Selecionar                                               |                        
//                                                                      | 
//______________________________________________________________________| 
//                                                                      |
// Descrição : 															| 
//______________________________________________________________________|
Method Selecionar(oGetDados,nCol,nColAva) Class TGetDados
	

Return 


//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : OrdenaDados                                              							|                        
//                                                                      							| 
//__________________________________________________________________________________________________| 
//                                                                      							|
// Descrição :Permite ordenar os registro conforme a coluna selecionada 							| 
//__________________________________________________________________________________________________|
  
Method OrdenaDados() Class TGetDados                   	
       
	
	ASORT(::objMain:aCols, , , { | x,y | x[::nIndiceOrdenacao] < y[::nIndiceOrdenacao] } )
	
Return 

  
  
//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : Exportar                                              								|                        
//                                                                                                  |
// Autor     : Jessé Augusto                                                                        |
//                                                                                                  | 
// Data 	 : 09/09/2016 	                                                                     	| 
//__________________________________________________________________________________________________| 
//                                                                      							|
// Descrição :																						| 
//__________________________________________________________________________________________________|
                    
Method Exportar() Class TGetDados 

    Local nFormato := 0
	Local nK 	   := 0   
	Local nW	   := 0 
	Local nPesq    := 0 
		
	Local aAux	   := {} 
	
	Local oExcel   := Nil	
		
	::cDiretorio := cGetFile( ::cTipoArquivo, ::cTituloSalvar, 1,, .F., nOR( GETF_LOCALHARD,GETF_RETDIRECTORY ), ::lArvore, .T. )
	
	If !Empty(::cDiretorio)
		      
		      //________________________________________________________________________________________________ 
			  //                                                                                                | 
			  // Percorre toda a String a fim de verificar se a mesma possui um caractér específico             |
			  //________________________________________________________________________________________________|
		      
		      For nK := 1 To Len(::cDiretorio)
		      		  
		      		  nPesq := iif( SubStr(::cDiretorio,nK,1) == "\", nK  , 0) 
		      Next nK 
		      
		      
		      //________________________________________________________________________________________________ 
			  //                                                                                                | 
			  // Verifica se o nome do arquivo foi digitado                                                     | 
			  //________________________________________________________________________________________________|
		      If Len(::cDiretorio) >  nPesq  
		          
				  	  ::oExcel:= FWMSEXCEL():New() 
				  	  ::oExcel:AddworkSheet(::cPlanilha)   
			          ::oExcel:AddTable (::cPlanilha,::cTitPlanilha ) 
				      
				      //________________________________________________________________________________________________ 
					  //                                                                                                | 
					  // Determina os cabeçalho da Planilha gerada                                                      | 
					  //________________________________________________________________________________________________|
					  	
					  For nK := 1 To Len(::objMain:aHeader)
										  		 
								If ::objMain:aHeader[nK][2] <> "OK"
										  		 	   
									     Do Case
											   Case ::objMain:aHeader[nK][8] == "C"; nFormato:= 1 
											   Case ::objMain:aHeader[nK][8] == "N"; nFormato:= iif(::objMain:aHeader[nK][5] =="", 2, 3)  	               
											   Case ::objMain:aHeader[nK][8] == "D"; nFormato:= 4
										 EndCase 
											  		 	   
										 ::oExcel:AddColumn(	::cPlanilha				,;  // Nome da Planilha
																::cTitPlanilha			,;  // Título da Planilha
											  		 	   		::objMain:aHeader[nK][1],;  // Nome do Campo
											  		 	   		1						,;  // Alinhamento
											  		 	   		nFormato				,;  // Formato
											  		 	   		.F.)                   		// Totalizador
										  		 	   
			                    Endif 
					  Next nK                               
					   					  
					  
					  //________________________________________________________________________________________________ 
					  //                                                                                                | 
					  // Determina os Valores associados a cada coluna                                                  | 
					  //________________________________________________________________________________________________|
					  
				      For nK := 1 To Len(::objMain:aCols)
				  		           
				  			 For nW := 1 To Len(::objMain:aHeader)
				  			          
				  			          //________________________________________________________________________________________________ 
					  				  //                                                                                                | 
					  				  // O campo de legenda não é considerado                                                          |
					  				  //________________________________________________________________________________________________| 
				  			          If ::objMain:aHeader[nW][2] <> "OK"
				  			          
						  			          If ::objMain:aHeader[nW][8] == "D"  
						  			          	  
						  			          	  aAdd(::aLinha, DTOC(::objMain:aCols[nK][GDFieldPos(::objMain:aHeader[nW][2])]))
						  			          Else
						  			          	  aAdd(::aLinha, ::objMain:aCols[nK][GDFieldPos(::objMain:aHeader[nW][2])])
						  			          Endif
									  Endif 				  			           
				  			 Next nW
				  		 	
				  		 	 ::oExcel:AddRow(	::cPlanilha , ::cTitPlanilha , ::aLinha)
									  
							 ::aLinha := {}
				  	  Next nK   
		      
		              //___________________________________________________________________| 
                      //                                                                   | 
    		  		  // Analisa se existe alguma planilha já definida no processo         | 
    		          //___________________________________________________________________|
    
	          		  If !Empty(::oExcel:aWorkSheet)
     
		 				  ::oExcel:Activate()   
		 				  ::oExcel:GetXMLFile(::cDiretorio + ::cExtensao)  
		 
	     				  oExcel := MsExcel():New()             
	     				  oExcel:WorkBooks:Open(::cDiretorio + ::cExtensao) 
	     				  oExcel:SetVisible(.T.) 
    				  Endif 
		      
		      Else 
		      	   Aviso("Atenção","Informe o nome do arquivo a ser gerado" ,{"OK"},1)    
		      Endif
	Endif	  

Return