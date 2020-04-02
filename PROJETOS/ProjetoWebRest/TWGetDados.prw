#Include "Protheus.ch"
#Include "Totvs.ch"


Class TWGetDados
    
    Data cQuery
    Data cTipoOperacao     
    Data cAlias  
    Data cCampo
	Data nTamanho
	Data cMacara   
	Data cTitulo
	Data cCampoLegenda	  
	Data cAlias 
	Data cBitMap
    
    Data aField
    Data aIndice 
    Data aRecno
    Data aInfoWorkArea
    
    Data lRetorno 
	Data lLegenda 
	Data lFlag
	Data lRecno   
	Data lPosicionaAlias 
	
	Data nIndiceCalculo            
	Data nTotalCalculado
    Data nQuantidadeRegistro
    Data nQuantidadeSelecionada
    Data nIndiceOrdenacao	
    Data lOrdemCrescente 
    Data nCampoBitMaps
    //________________________________________________________________________________________________________________
    //                                                                                                                | 
    // Autor 	 : Jesse Augusto			Data : 09/03/2019                                                         |
    //________________________________________________________________________________________________________________|
    //                                                                                                                | 
    // Descricao : Propriedades relacionadas a janela que exibe as ocorrencias do processamento                       |
    //________________________________________________________________________________________________________________|
    
    Data oDlgLog   
    Data cTitulo
    
    Data nTop
    Data nLeft
    Data nBottom
    Data nRight	
    
    Data nGrdTop
    Data nGrdLeft
    Data nGrdBottom
    Data nGrdRight	    
    
    Data oGetDados
    Data oGridLog		
    Data aHeader 
    Data aCols
    	
	Method New() Constructor       
	Method MapeiaCampos()  
	Method InputaValores()   
	Method BuscaValor(cPesquisado,oIndice, oGetDados)	
	Method PosicioneRegistro(oGetDados)     
	Method AtivaGetDados(oGetDados)     
	Method SelecionarRegistro() 
	Method CalculaValorColuna()  
	Method VisualizaLogOcorrencia()     
	Method OrdenaDados()

End Class
    
/**/                               
Method New() Class TWGetDados 
	
	::cQuery		 			:= ""  
	::cTipoOperacao  			:= ""  
	::cTitulo     	 			:= ""
	::cCampo	  	 			:= ""
	::cMacara     	 			:= ""
	::cAlias		 			:= ""	
	::cTitulo					:= "" 
	::cCampoLegenda				:= ""
	::cBitMap					:= LoadBitmap(GetResources(),'UNCHECKED')
	
	
	::aField 		 			:= {}
	::aIndice		 			:= {}
	::aRecno					:= {}
	::aInfoWorkArea				:= {}
	
	::lRetorno		 			:= .T.
	::lLegenda 		 			:= .F. 
	::lFlag			 			:= .F.
	::lRecno		 			:= .T.     
	::lOrdemCrescente			:= .T.  
	::lPosicionaAlias			:= .F.
	                              
	::nQuantidadeRegistro 	 	:= 0
    ::nQuantidadeSelecionada 	:= 0   
    ::nIndiceCalculo		 	:= 0
    ::nTotalCalculado		 	:= 0    
    ::nIndiceOrdenacao			:= 0
    
    ::oDlgLog				 	:= Nil
    ::oGetDados 			 	:= Nil 
    ::oGridLog					:= Nil
	 						
    //____________________________________________________________________________________________________
    //                                                                                                    | 
    // Descricao : Cordenadas da Janela Principal                                                         |                                            
    //____________________________________________________________________________________________________|
    
    ::nTop					 	:= 180
    ::nLeft					 	:= 180
    ::nBottom				 	:= 520
    ::nRight	 			 	:= 930  
    
    //____________________________________________________________________________________________________
    //                                                                                                    | 
    // Descricao : Cordenadas da Grid                                                         			  |                                            
    //____________________________________________________________________________________________________|
    
    ::nGrdTop					:= 0 
    ::nGrdLeft					:= 0 
    ::nGrdBottom                := 0 
    ::nGrdRight					:= 0 
    ::nCampoBitMaps				:= 1
    
Return 

/**/

Method MapeiaCampos() Class TWGetDados 
                      
	Local nX    := 0  
	Local nK	:= 0 
	Local aAux 	:= {}
    
    //________________________________________________________________________________________________________________
    //                                                                                                                |
	// Tratamento específico para criação de Legenda                                                                  | 
	//________________________________________________________________________________________________________________|
	
	SX3->(dbSetOrder(2)) 
	
	//________________________________________________________________________________________________________________
    //                                                                                                                |
    // Verifica se a legenda será utilizada na MsNewGetDados                                                          | 
    //                                                                                                                |   
    //________________________________________________________________________________________________________________|
      
    If ::lLegenda
    
    	 For nK := 1 To ::nCampoBitMaps	
    	 	 
    	 	 If  nK < 2 
    	 	 	 Aadd(aAux,{" ","OK","@BMP", 1, 0,"",,"C","",""})        
    	 	 Else
    	 	 	 Aadd(aAux,{" ","OK"+StrZero(nK,2,0),"@BMP", 1,0,"",,"C","",""})        		
    	 	 Endif
    	 Next nK
    Endif
    
	For nX := 1 To Len (::aField)
		   
		   //________________________________________________________________________________________________________________
		   //                                                                                                                | 
	       // Posiciona sobre o campo informado a fim de obter suas configurações                                            |
	       //________________________________________________________________________________________________________________|
	       
		   If SX3->(dbSeek(::aField[nX][1]))
			          
			          
			       aAdd(aAux,{  TRIM(x3Titulo())	,;
								   SX3->X3_CAMPO	,;	
								   SX3->X3_PICTURE	,;
								   SX3->X3_TAMANHO	,;
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
           	   
				Aadd(aAux,{ ""+::aField[nX][1]+"", ::aField[nX][2], ::aField[nX][3], ::aField[nX][4] , , , , , ,"V"})	
           	    
	       Endif
	Next nX 
	
	If ::lRecno  
    	Aadd(aAux, {"Registro", "RECNO", "", 22, 0, "ALWAYSTRUE()",, "N", "", "R",,0})
    Endif
    
Return ::aField := aClone(aAux)          


//_________________________________________________________________________________
//         
// 
//_________________________________________________________________________________

Method InputaValores(oGetDados) Class TWGetDados  
                                         
    Local nX		:= 0   
    Local cWorkArea := GetNextAlias()               
	
	Local aAux	    := {}                           
	 
    dbUseArea( .T., "TOPCONN", TcGenQry(,,::cQuery), cWorkArea, .T., .F.)
	
	Count To nTotal
	 
	::cQuery := ""                  
	
	//_______________________________________________________________________________________
	//                                                                                       |  
	// Posiciona no primeiro registro da tabela 											 |
	//_______________________________________________________________________________________|
	
	
	ProcRegua(nTotal)
	
	oGetDados:aCols := {}
    
    (cWorkArea)->(dbGoTop()) 
         
	While (cWorkArea)->(!Eof())
	      
	      IncProc(nTotal)
	      
	      aAux := {} 
	                           
		  For nX := 1 To Len(oGetDados:aHeader)
		                                       
		         nPos   := (cWorkArea)->(FieldPos(oGetDados:aHeader[nX][2]))   
		         
		         If  nPos > 0    
		                                          
		         	  If  oGetDados:aHeader[nX][8] == "D" 
		         	  	  Aadd(aAux,STOD((cWorkArea)->(FieldGet(nPos))))                      
		         	  Else
		         	  	  Aadd(aAux, (cWorkArea)->(FieldGet(nPos)))	 
		         	  Endif 
		         
		         Elseif oGetDados:aHeader[nX][3] == "@BMP"
		              
		              
		              If oGetDados:aHeader[nX][8] == "OK"
		              	
		              		Aadd(aAux, ::cBitMap)	
		              
		              ElseIf !Empty(::aInfoWorkArea)  
		                   
		                   If ::lPosicionaAlias  .And. ::lRecno  
		                     	  
		                     	nPos := aScan(::aInfoWorkArea,{|x| Alltrim(x[1])== oGetDados:aHeader[nX][2]})
		                     	
		                     	If nPos > 0
		                     		 //________________________________________________________________________________________________________________________
		                     		 //                                                                                                                        | 
		                     		 // Descricao : Posiciona sobre o registro da tabela especificada na propriedade ::cAlias                                  |
		                     		 //________________________________________________________________________________________________________________________|
		                     		 
		                     		 (::cAlias)->(dbGoto( (cWorkArea)->(RECNO)))
		                     			
		                     		 nPos := aScan(::aInfoWorkArea,{|x| Alltrim(x[1]) == (::cAlias)->(::cCampoLegenda) })   
		                     		 // Valor
		                     		 // Figura
		                     		 //    
		                     		 Aadd(aAux, ::aInfoWorkArea[nPos][2])
		                     	Endif 
		                   Endif 
		              Else
		              	  Aadd(aAux, LoadBitmap(GetResources(),'UNCHECKED')) 
		              Endif   
		         	           	
		         Endif 
		  Next nX                                                 
		  
		  //_______________________________________________________________________________________ 
		  //                                                                                       |
		  // Coluna responsável pela seleção do registro no aCols.				   				   |	
		  //_______________________________________________________________________________________|
		  		  
		  If ::lFlag
		  	   Aadd(aAux,.F.)                               
		  Endif 
		  
    	 //_______________________________________________________________________________________ 
		  //                                                                                       |
		  // Coluna adicional do aCols.				   							  				   |	
		  //_______________________________________________________________________________________|
		  
		  Aadd(aAux,.F.)                               
		   
		  Aadd(oGetDados:aCols,aClone(aAux))
		  
		  (cWorkArea)->(dbSkip())	 
	EndDo
	(cWorkArea)->(dbCloseArea())		
	
	//_______________________________________________________________________________________ 
	//                                                                                       |
	// Se a quantidade de registro for igual a zero a grid sera desabilitadda                |
	//_______________________________________________________________________________________|                                        
	
	If !Empty(oGetDados:aCols)
		oGetDados:oBrowse:Enable()	
	Else 
		oGetDados:oBrowse:Disable()
	Endif 
    
	::nQuantidadeRegistro := Len(oGetDados:aCols)
	
	oGetDados:oBrowse:Refresh()      
Return 

//_________________________________________________________________________________
//                                                                                 | 
// Responsável pela pesquisa do valor digitado                                     |
//_________________________________________________________________________________|

Method BuscaValor(cPesquisado,oIndice, oGetDados) Class TWGetDados  
                                                                      	
	Local nK      := 0   
	Local nIndice := aScan(oGetDados:aHeader,{|x| Alltrim(x[2]) == ::aIndice[oIndice:nAt][1]})
	                     
	
	If  nIndice > 0                                                                                                        
		 
		 For nK := 1 To Len(oGetDados:aCols)
			       
			    //_______________________________________________________________________________________
				//                                                                                 		 | 
				// Compara o valor digitado com o valor presente na GetDados, conforme o índice de busca | 
				//_______________________________________________________________________________________| 
					
				    
				If SubStr(Alltrim(Upper(cPesquisado)),1,Len(Alltrim(cPesquisado))) == SubStr(Alltrim(Upper(oGetDados:aCols[nK][nIndice])),1,Len(Alltrim(cPesquisado)))
		
				      oGetDados:GoTo(nK)
				End If 
		 Next nK         
	Endif 
                                                                      
Return 


Method PosicioneRegistro(oGetDados)Class TWGetDados  
	
	Local nRecno := 0
	
	If  !Empty(oGetDados:aCols)
	
		nRecno := oGetDados:aCols[oGetDados:nAt][Len(oGetDados:aHeader)+1]
		
    	(::cAlias)->(dbGoto(nRecno))
	Else
		 ::lRetorno := .F.
	Endif  
	
Return 

/**/
Method AtivaGetDados(oGetDados) Class TWGetDados  
	
	If Empty(oGetDados:aCols)
	  	    
	  	 oGetDados:Disable()
	  	 oGetDados:oBrowse:Refresh() 	
	Endif 

Return 
      
/**/
Method SelecionarRegistro(oGrid) Class TWGetDados    
	
	Local nLinha 	:= 0	        
	Local nLinAt   	:= oGrid:oBrowse:nAt   
	Local nColFlag 	:= Len(oGrid:aHeader) + 1
	Local nImgFlg  	:= aScan(oGrid:aHeader,{|x| Alltrim(x[2])=="OK"})
	Local lFlag	   	:= .F. 	   
	
	Local oOK      	:= LoadBitmap(GetResources(),'CHECKED') 
 	Local oNO 	   	:= LoadBitmap(GetResources(),'UNCHECKED') 	 			
                           

  	If oGrid:oBrowse:nColPos == nImgFlg                                        
  	 	
	     oGrid:aCols[nLinAt][nColFlag]  	:= !oGrid:aCols[nLinAt][nColFlag] 
		 lFlag 							 	:= oGrid:aCols[nLinAt][nColFlag]  
		 oGrid:aCols[nLinAt][nImgFlg]    	:= Iif( lFlag, oOK, oNo)  
		 ::nQuantidadeSelecionada 		 	:= 0 	       
		                           
		 //____________________________________________________________________________________________________
		 //                                                                                                    | 
		 //	Descrição : Verifica se a grid utiliza Recno na tabela utilizada                                   |                                                     
		 //____________________________________________________________________________________________________|
		 
		 If ::lRecno  
		  		
		  	  If lFlag
		  	  	  aAdd(::aRecno, oGrid:aCols[nLinAt][Len(oGrid:aHeader)])	
		  	  Else
		  	  	   nPos := aScan( ::aRecno, {|x| x == oGrid:aCols[nLinAt][Len(oGrid:aHeader)]})
		  	  	   
		  	  	   If nPos >  0                    
		  	  	 	 	aDel(::aRecno,nPos)
		  	  	 	 	aSize(::aRecno,Len(::aRecno)-1)	
		  	  	   Endif 
		  	  Endif                             
		 Endif 
		 
		 aEval( oGrid:aCols, {|x| iif( x[nColFlag], ::nQuantidadeSelecionada++,)})     
	Endif                                                                

	oGrid:oBrowse:Refresh() 

Return     
         
/**/

Method OrdenaDados(oGrid) Class TWGetDados                   	

	Local nImgFlg  	:= aScan(oGrid:aHeader,{|x| Alltrim(x[2])=="OK"})
	Local nColFlag 	:= Len(oGrid:aHeader) + 1                 
	
	Local oOK      	:= LoadBitmap(GetResources(),'CHECKED') 
 	Local oNO 	   	:= LoadBitmap(GetResources(),'UNCHECKED') 
	Local lFlag	   	:= .F. 	   
	
	::nIndiceOrdenacao 			:= oGrid:oBrowse:nColPos
	::lOrdemCrescente			:= !::lOrdemCrescente   
	::nQuantidadeSelecionada 	:= 0
	
  	If ::nIndiceOrdenacao == nImgFlg   
  	
  		::aRecno:= {} 
  		
  		If ::lOrdemCrescente   
  			aEval(oGrid:aCols,{|x|  (x[nImgFlg] := LoadBitmap(GetResources(),'CHECKED')	, x[nColFlag]	:= .T., aAdd(::aRecno, x[Len(oGrid:aHeader)]) )})	
  		Else 
  			aEval(oGrid:aCols,{|x|  (x[nImgFlg] := LoadBitmap(GetResources(),'UNCHECKED')	, x[nColFlag]	:= .F.)})	
  		Endif 
  		
  	Else
  		If ::lOrdemCrescente  
  		    aSort(oGrid:aCols, , , { | x,y | x[::nIndiceOrdenacao] > y[::nIndiceOrdenacao] } )
		Else
			aSort(oGrid:aCols, , , { | x,y | x[::nIndiceOrdenacao] < y[::nIndiceOrdenacao] } )
		Endif 
	Endif                  
	
	aEval( oGrid:aCols, {|x| iif( x[nColFlag], ::nQuantidadeSelecionada++,)}) 
	
	oGrid:oBrowse:Refresh()
Return                


/**/
Method VisualizaLogOcorrencia() Class TWGetDados      
	
	Local oDlgLog := Nil    
	
	DEFINE DIALOG oDlgLog TITLE ::cTitulo FROM ::nTop,::nLeft  TO ::nBottom,::nRight PIXEL
        
    ::oGridLog := MSNewGetDados():New(::nGrdTop, ::nGrdLeft, ::nGrdBottom, ::nGrdRight,0,'AlwaysTrue()','AlwaysTrue()','',{},,9999,,,,oDlgLog,::aHeader,::aCols,{||})
    
    ACTIVATE DIALOG oDlgLog ON INIT EnchoiceBar(oDlgLog, {|| oDlgLog:End()} , {|| oDlgLog:End() } ) CENTERED 
	
Return (Nil)
