#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "MSOBJECT.CH" 
#include "TOTVS.CH" 

Class TWCryoPorderTerceiro From LongClassName
	                             
	Data oDlg			// Dialog Principal
	Data aCrd 			// Array com a coordenadas de tela     
	Data aSize          // Array com a coordenadas de tela  
	Data aObj    		// 
	Data aInfo			// 
	Data aPObj	  		// 
	Data aButtons       //  
	Data aDadosCliFor   // 
	
	
	// Título
	Data cTitulo
	
	//Groups
	Data oGrpFiltro
	
	// MsNewGetDados        
	Data oObjTGetDados
	Data oGetDadosCliente    
	Data aHeader 
	Data aCols
	
	// Cliente De
	
	Data oGetIDClienteDe
	Data cIDClienteDe     
	
	// Cliente  Ate
	
	Data oGetIDClienteAte
	Data cIDClienteAte
	
	// Loja
	Data oSayLoja
	Data oGetLoja
	Data cLoja   
	
	// Nome
	Data oGetNome
	Data cNome
	
	Data oGetEndereco
	Data cEndereco   
	
	Data oDataEmissaoDe
	Data dDataEmissaoDe 
	
	Data oDataEmissaoAte  
	Data dDataEmissaoAte      
	
	Data dDataIniPoder3
	Data dDataFimPoder3   
	
	Data cTesPedidoVenda		//GetMv("COF_TESCOB")
	Data cCondPgtoPedidoVenda  
	
	Data aItemPedidoVenda
	
	Data cConsultaSQL   
	
	Data oBTNPesquisar
	     
	
	Method New() Constructor 		 // Metodo construtor  
	Method Show()					 
	Method CarregaPropiedadeJanela() 
	Method CarregaClientes()         
	Method SelecionaCliente() 
	Method CalculaPoderTerceiro()
	Method ValidaSelecao()
	Method GerarNumSeqSB6() 
	Method ObtemDadosCliFor() 
	Method GerarPedidoVenda()  
	Method ObtemProdutoPedidoVenda()
	
	
EndClass
               

Method New() Class TWCryoPorderTerceiro
        
	::cTitulo			:= "Gerar Saldos em Poder de Terceiros"    
	
	::oGrpFiltro		:= Nil   
	::oGetDadosCliente  := Nil
		
	
    ::oDlg			    := Nil
	::oGetIDClienteDe   := Nil
	::cIDClienteDe      := Space(TamSX3("A1_COD")[1])    
	
	::oGetIDClienteAte	:= Nil
	::cIDClienteAte		:= Space(TamSX3("A1_COD")[1])    
	
	::oGetLoja   	    := Nil
	::cLoja      	    := Space(TamSX3("A1_LOJA")[1])   

	::oGetNome          := Nil
	::cNome             := Space(TamSX3("A1_NOME")[1])  
		
	::oGetEndereco	    := Nil
	::cEndereco   	    := Space(TamSX3("A1_END")[1])   
	
	::cConsultaSQL	    := ""
	
	::dDataIniPoder3	:= CTOD("")
	::dDataFimPoder3    := CTOD("")
	
	::cTesPedidoVenda	   := GetMv("MV_YTESLOC")
	::cCondPgtoPedidoVenda := GetMv("MV_YCPGLOC") 
	//________________________________________________________________________________________________ 
	//                                                                                                | 
	// Variáveis que controlam a classe MsNewGetDados                                     			  |
	//________________________________________________________________________________________________|
	::oObjTGetDados		:= Nil
	::oGetDadosCliente  := Nil    
	::aHeader       	:= {}
	::aCols         	:= {}
	
	//________________________________________________________________________________________________ 
	//                                                                                                | 
	// Variáveis que controlam as coordenadas da janela principal                                     |
	//________________________________________________________________________________________________|
	
	::aSize 			:= {}                                   // 
	::aObj  			:= {}                                   // 
	::aInfo 			:= {}                                   //  
	::aButtons			:= {}                                   // 
    ::aDadosCliFor		:= {}                                   //
    ::aItemPedidoVenda	:= {}
Return   
                       

Method CarregaPropiedadeJanela() Class TWCryoPorderTerceiro
            
	::aSize := MsAdvSize()  
	
	aAdd( ::aObj, { 030, 050, .T., .F. })
  	aAdd( ::aObj, { 000, 080, .T., .T. }) 
                                                                          
  
  	::aInfo := { ::aSize[1], ::aSize[2], ::aSize[3], ::aSize[4], 3, 3 }  
  	::aPObj := MsObjSize( ::aInfo, ::aObj )  
  	                                                           
  	//__________________________________________________
  	//                                                  | 
  	//Campos que formam o cabeçalho da MsNewGetDados    | 
  	//__________________________________________________|
    Aadd(::aHeader,{"A1_COD"	 , .F. }) 
  	Aadd(::aHeader,{"A1_LOJA"	 , .F. })
  	Aadd(::aHeader,{"A1_NOME"	 , .F. })
  	
  	::oObjTGetDados := TGetDados():New(.T., ::aHeader, .F., 0,.F.) 
  	::aHeader		:= ::oObjTGetDados:aDicionario
  	
Return  


Method Show() Class TWCryoPorderTerceiro
	
	Local bOK 		:= {|| ::ValidaSelecao()  } 
	Local bCancelar := {|| ::oDlg:End() }                                  	                                


    DEFINE MSDIALOG ::oDlg TITLE ::cTitulo FROM ::aSize[7],::aSize[1] To ::aSize[6],::aSize[5] OF oMainWnd PIXEL 
	
	::oGrpFiltro := TGroup():New( ::aPObj[1][1], ::aPObj[1][2] , ::aPObj[1][3], ::aPObj[1][4], 'Filtro', ::oDlg,,,.T.)  
  	
  	@ ::aPObj[1][1]+012,::aPObj[1][2]+005 SAY "Cliente De" SIZE 050,009  OF ::oGrpFiltro  PIXEL 
  	@ ::aPObj[1][1]+020,::aPObj[1][2]+005 MSGET ::oGetIDClienteDe VAR  ::cIDClienteDe     F3 "SA1" Picture "@!" When .T. SIZE 035,009  OF ::oGrpFiltro PIXEL HASBUTTON   
	
	::oGetIDClienteDe:bLostFocus := {|| ::cIDClienteAte := Space(TamSX3("A1_COD")[1])}
	
  	@ ::aPObj[1][1]+012,::aPObj[1][2]+055 SAY "Cliente Até" SIZE 050,009  OF ::oGrpFiltro PIXEL 
  	@ ::aPObj[1][1]+020,::aPObj[1][2]+055 MSGET ::oGetIDClienteAte VAR  ::cIDClienteAte F3 "SA1" Picture "@!" When .T. SIZE 035,009  OF ::oGrpFiltro PIXEL HASBUTTON   

    
    ::oGetDadosCliente := MSNewGetDados():New(::aPObj[2][1]+005, ::aPObj[2][2], ::aPObj[2][3], ::aPObj[2][4], 0,'AlwaysTrue()','AlwaysTrue()','',{},,9999,,,,::oDlg ,::aHeader,{},{||}) 	  
	                                                                                             
	
	//_____________________________________________________________________________________
    //                                                                                     | 
  	// Ação relacionada no momento do Clique soble uma determinada linha da MsNewGetDados  |
  	//_____________________________________________________________________________________|
  	::oGetDadosCliente:oBrowse:bLDblClick   := {|| ::SelecionaCliente() }
  	    
	@ 024,::aPObj[1][2]+105 Button ::oBTNPesquisar PROMPT 'Buscar' Size 025,010 Action ::CarregaClientes() Of ::oGrpFiltro Pixel
	                                                       	
	
	//__________________________________________________________________________________________
	//                                                                                          | 
	// Limita a quantidade de registros a serem disponibilizados na tela                        |
	//__________________________________________________________________________________________|
	
	::oObjTGetDados:GetDadosVazio(::oGetDadosCliente)
	
	::oDlg:bInit := (EnchoiceBar(::oDlg,bOK,bCancelar,,))

	ACTIVATE MSDIALOG ::oDlg
Return            
         


Method CarregaClientes() Class TWCryoPorderTerceiro 

	Local oSay := Nil 
	
	//____________________________________________________________
  	//                                                            | 
  	// Consulta SQL                                               |
  	//____________________________________________________________|  
  	
  	::cConsultaSQL :=" SELECT 		  		 "
	::cConsultaSQL +=" A1_COD				,"
	::cConsultaSQL +=" A1_LOJA				,"
	::cConsultaSQL +=" A1_NOME				 "
	::cConsultaSQL +=" FROM " + RetSqlName("SA1") +" AS SA1 "
	::cConsultaSQL +=" WHERE SA1.D_E_L_E_T_ ='' 			" 
	::cConsultaSQL +=" AND   SA1.A1_FILIAL  =" +xFilial("SA1")+"    "
	
	
	
	If !Empty(::cIDClienteAte)
	
	 	 ::oObjTGetDados:cWhere += " AND A1_COD BETWEEN  '"+ ::cIDClienteDe +"' AND '" + ::cIDClienteAte + "' "
	Endif 

	//____________________________________________________________________________________________________________
	//                                                                                                            |
	// Define a figura a ser utilizada na coluna lateral do aCols                                                 | 
	//____________________________________________________________________________________________________________|
	::oObjTGetDados:cBitmap := LoadBitmap(GetResources(),'UNCHECKED')
   
	::oObjTGetDados:GerenciaConsultaSQL( ::oGetDadosCliente, ::cConsultaSQL)
	
Return 


Method SelecionaCliente() Class TWCryoPorderTerceiro                                	

	Local nLinha    := ::oGetDadosCliente:oBrowse:nAt                 
	Local nPosFlag  := Len(::oGetDadosCliente:aHeader) + 1  		
	Local nPosMck   := aScan(::oGetDadosCliente:aHeader,{|x| Alltrim(x[2])=="OK"}) 
	Local nPosId	:= aScan(::oGetDadosCliente:aHeader,{|x| Alltrim(x[2])=="A1_COD"})  
    Local lMarc	    := .F.	
    Local aArea		:= GetArea()
    
	//_________________________________________________________________________
	//                                                                         |
	// A marcação apenas é realizada quando a coluna posicionada é a primeira. | 
	//_________________________________________________________________________|
	
	If !Empty(::oGetDadosCliente:aCols[nLinha][nPosId])
	
		 If ::oGetDadosCliente:oBrowse:nColPos == nPosMck 
	         
	         ::oGetDadosCliente:aCols[nLinha][nPosFlag] :=  !::oGetDadosCliente:aCols[nLinha][nPosFlag] 
		 	 lMarc 							 			:=  ::oGetDadosCliente:aCols[nLinha][nPosFlag]  
		 	 ::oGetDadosCliente:aCols[nLinha][nPosMck]  :=  Iif( lMarc, LoadBitmap(GetResources(),'CHECKED'),LoadBitmap(GetResources(),'UNCHECKED'))   
			 ::oGetDadosCliente:oBrowse:Refresh()
		 Endif 
	Else 
		Aviso("Operação inválida","Impossível realizar esta operação" ,{"OK"},1)
	Endif	
	
	::oGetDadosCliente:oBrowse:Refresh()  
	
	RestArea(aArea)
Return 
        
        
Method ValidaSelecao() Class TWCryoPorderTerceiro 
	                   
	//________________________________________________________________
	
	Local nPosFlag := Len(::oGetDadosCliente:aHeader) + 1 	 
	Local nTotMark := 0                                  
	
	//________________________________________________________________
	
	Local bABuscar := {|x| iif( x[nPosFlag], nTotMark++, ) }
	
	//________________________________________________________________
	
	Local aPerg := {}
	Local aRet  := {}
	Local aArea := {} 
	Local lRet  := .F. 
	
	aEval(::oGetDadosCliente:aCols, bABuscar)  
	
	If nTotMark > 0             
	
		//_______________________________________________________________
   		//                                                               | 
		// Janela contendo a Data Incial e Final da operação             |
		//_______________________________________________________________|
	
		aAdd(aPerg,{1,"Data De"  , dDataBase ,"", "", , "", 50,.F.})      
		aAdd(aPerg,{1,"Data Até" , dDataBase ,"", "", , "", 50,.F.}) 
		
		If ParamBox(aPerg ,"",aRet)  
			 
			 //________________________________________________________________________________
	    	 //                                                                                | 
	    	 // Data-limite a ser considerada no processo de geração de Poder de Terceiros     |
	    	 //________________________________________________________________________________|
	    
	    	 ::dDataIniPoder3	:= MV_PAR01
			 ::dDataFimPoder3   := MV_PAR02 	    
		       
			 Processa({|| ::CalculaPoderTerceiro()}, "Gerando de Pedido de Venda", "Aguarde...")
		     
		     aEval(::oGetDadosCliente:aCols,{|x| (x[1]:= LoadBitmap(GetResources(),'UNCHECKED'), x[Len(::oGetDadosCliente:aHeader)+1]:= .F.) } )
	
			 ::oGetDadosCliente:oBrowse:Refresh()
		Endif
	Else 
		Aviso("Operação inválida","Selecione, no mínimo, um registro para realizar esta operação " ,{"OK"},1)	
	Endif 	
Return 

Method CalculaPoderTerceiro() Class TWCryoPorderTerceiro 
     
	//___________________________________________________________________________________
	
	Local nPosID 	:= aScan(::oGetDadosCliente:aHeader,{|x| Alltrim(x[2])=="A1_COD"})
	Local nPosLoja 	:= aScan(::oGetDadosCliente:aHeader,{|x| Alltrim(x[2])=="A1_LOJA"})
	Local nK		:= 0 
	Local nW		:= 0                                                                  
	
	//___________________________________________________________________________________
	
	Local aProduto    := {}
	Local aPoderTerc  := {}	
	Local aDetlCliFor := {}  
	Local aLinha	  := {}	 
      
	
	aProduto   			:= ::ObtemProdutoPedidoVenda() 
	
	SA1->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	    
	ProcRegua(Len(::oGetDadosCliente:aCols))
	     
	For nK := 1 To Len(::oGetDadosCliente:aCols)
		        
		 		IncProc()
		 		
		 	 	If ::oGetDadosCliente:aCols[nK][Len(::oGetDadosCliente:aHeader)+1] 
		 	 	          
		 	 	      If SA1->(dbSeek(xFilial("SA1") + Alltrim(::oGetDadosCliente:aCols[nK][nPosID]) + Alltrim(::oGetDadosCliente:aCols[nK][nPosLoja]) ))
		 	 		 		    
		 	 		 		 
		 	 		 		 
		 	 		 		 For nW := 1 To Len(aProduto)
		 	 		 			 	
						 	 		If SB1->(dbSeek(xFilial("SB1") + aProduto[nW][1])) 
							 	 		 
								 	 	   aArea := GetArea()
								 	 				
								 	 	   aDetlCliFor := ::ObtemDadosCliFor()
								 	 	   
								 	 	   If Len(aDetlCliFor) > 0 
								 	 	   
										 	 	   aPoderTerc := CalcTerc(   			 ;
												  				aDetlCliFor[1][1]		,;  // Codigo do Produto
													 	 		SA1->A1_COD	   			,;  // Codigo do Cliente/Fornecedor
													 	 		SA1->A1_LOJA	   		,;  // Codigo da Loja 
													 	 		aDetlCliFor[1][3]		,;  // Codigo do identIficador do SB6
													 	 		aDetlCliFor[1][2]		,;  // Codigo da Tes
													 	 		aDetlCliFor[1][4]		,;  // Tipo da Nota 
													 	 		::dDataIniPoder3 		,;  // Dt Inicial a ser Considerada na Composi‡Æo do Saldo  
													 	 		::dDataFimPoder3  )  		// Dt Final a ser Considedara na Composi‡Æo do Saldo 
								        
								           Endif 
								           
								           RestArea(aArea)
							              
							               //_____________________________________________________________________________________________________
							               //                                                                                                     | 
							               //                                                                                                     |
							               // Uma vez que os dados do Produto foram coletados, convém, a partir de agora, gerar o Pedido de Venda |
							               //_____________________________________________________________________________________________________|
							               
							               aAdd( aLinha , {"C6_FILIAL",  xFilial("SC6")				  , Nil})	
										   aAdd( aLinha , {"C6_ITEM"   , StrZero(nW,2)        		  , Nil})	
										   aAdd( aLinha , {"C6_PRODUTO", Alltrim(SB1->B1_COD) 		  , Nil})	
										   aAdd( aLinha , {"C6_QTDVEN" , aPoderTerc[6]        		  , Nil})	
										   aAdd( aLinha , {"C6_PRCVEN" , aProduto[nW][2]	 		  , Nil})	
										   aAdd( aLinha , {"C6_VALOR"  , aProduto[nW][2]*aPoderTerc[6], Nil})	
										   aAdd( aLinha , {"C6_UM"     , SB1->B1_UM  		 		  , Nil})	
										   aAdd( aLinha , {"C6_TES"    , ::cTesPedidoVenda       	  , Nil})
										   
										   aAdd(::aItemPedidoVenda,aLinha) 
			    
							 			   aLinha := {}	
							        Endif 		
			        	 		
							 Next nW				        	 		
							                    
							 If Len(::aItemPedidoVenda) > 0 
							 	  
							 	  ::GerarPedidoVenda()           
							 Endif 
							                                	
							 aLinha 			:= {}	
							 ::aItemPedidoVenda := {}
							 
					  Endif 
		        Endif 
	Next nK
	
    
Return 


Method ObtemDadosCliFor() Class TWCryoPorderTerceiro 
	
	Local cSQL	 		:= "" 
	Local cWorkArea 	:= GetNextAlias()   
	
	//_______________________________________________________________
	
	Local aDadosCliFor := {}
	                                
	cSQL := " SELECT 							   "
	cSQL += " TOP 1								   "	
	cSQL += " SB6.B6_PRODUTO,					   "
	cSQL += " SB6.B6_TES, 						   "
	cSQL += " SB6.B6_IDENT,						   "
	cSQL += " SD2.D2_TIPO                          " 
	cSQL += " FROM  SB6010 SB6 					   "   
			
	
	cSQL += " INNER JOIN SD2010 SD2 ON			   "	
	cSQL += " SB6.D_E_L_E_T_	  =''			   "
	cSQL += " AND SD2.D2_FILIAL   = SB6.B6_FILIAL  "
	cSQL += " AND SD2.D2_CLIENTE  = SB6.B6_CLIFOR  "
	cSQL += " AND SD2.D2_LOJA     = SB6.B6_LOJA    "
	cSQL += " AND SD2.D2_COD      = SB6.B6_PRODUTO "
	cSQL += " AND SD2.D2_DOC	  = SB6.B6_DOC     " 
	cSQL += " AND SD2.D2_SERIE    = SB6.B6_SERIE   "
	cSQL += " AND SD2.D2_TES      = SB6.B6_TES     " 
	 
	
	cSQL += " WHERE SB6.D_E_L_E_T_=''"                
	
	cSQL += " AND SB6.B6_CLIFOR	  ='" + SA1->A1_COD  +"' "                  
	cSQL += " AND SB6.B6_PRODUTO  ='" + SB1->B1_COD  +"' "  
	
	cSQL += " AND SB6.B6_DTDIGIT BETWEEN '"+DTOS(::dDataIniPoder3)+"' AND '"+DTOS(::dDataFimPoder3)+"'"  
	cSQL += " AND SB6.B6_TES ='"+::cTesPedidoVenda+"' "				
	cSQL += " ORDER BY SB6.R_E_C_N_O_ DESC"				
	  				
  	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cWorkArea, .T., .F. )
  	
 	While (cWorkArea)->(!Eof())
 		  
 		  aAdd(aDadosCliFor, { (cWorkArea)->(B6_PRODUTO)	,;
 		  						 (cWorkArea)->(B6_TES)		,;
 		  						 (cWorkArea)->(B6_IDENT)	,;
 		  					  	 (cWorkArea)->(D2_TIPO)		})
 		  
 	    (cWorkArea)->(dbSkip()) 	  	
 	EndDo
	
	(cWorkArea)->(dbCloseArea())
	
Return  aDadosCliFor


Method GerarPedidoVenda() Class TWCryoPorderTerceiro 
	
	Local aCabec    	:= {}
	Local aItens    	:= {}
	Local aLinha    	:= {}  
	Local aProdutos 	:= {}
	
	//________________________________________________
	
	Local nK			:= 0 
		
	//________________________________________________
	
	Private lMsErroAuto := .F. 
	Private lMsHelpAuto := .F.                        
	
		
	aAdd(aCabec, {"C5_FILIAL"  , xFilial("SC5")			, Nil} )
	aAdd(aCabec, {"C5_TIPO"    , "N"         			, Nil} )	 
	aAdd(aCabec, {"C5_CLIENTE" , SA1->A1_COD 			, Nil} )	 
	aAdd(aCabec, {"C5_LOJACLI" , SA1->A1_LOJA			, Nil} )	 
	aAdd(aCabec, {"C5_TIPOCLI" , SA1->A1_TIPO			, Nil} )	 
	aAdd(aCabec, {"C5_CONDPAG" , ::cCondPgtoPedidoVenda , Nil} )	 
	aAdd(aCabec, {"C5_EMISSAO" , dDatabase   			, Nil} )	 
	aAdd(aCabec, {"C5_MOEDA"   , 1           			, Nil} )	  
	 	
    //_________________________________________________________________________________________________
    //                                                                                                 | 
    // Busca os dados vinculados aos Produtos especificados na ZZ1 (Tabela de Amarração de Produtos)   |
    //_________________________________________________________________________________________________|
    
	BeginTran()
		 
	MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,::aItemPedidoVenda,3)
	    
	If lMsErroAuto  
		RollBackSX8()
		DisarmTransaction()
	Else
		ConfirmSX8()
		EndTran() 
	Endif  
	             
Return    


Method ObtemProdutoPedidoVenda() Class TWCryoPorderTerceiro 	

	Local cSQL	 	:= "" 
	Local cWorkArea := GetNextAlias()   
	
	//___________________________________________________
	
	Local bAdiciona := {||}
	Local bCondicao := {||} 
	
	//___________________________________________________
		
	Local aDetlProd	:= {}
	
	
	cSQL +=" SELECT 								 "  
	cSQL +=" DA1.DA1_CODPRO,						 "
	cSQL +=" DA1.DA1_PRCVEN							 "
	cSQL +=" FROM "+RetSqlName("ZZ1")+" ZZ1 		 "
	cSQL +=" INNER JOIN "+RetSqlName("DA1")+" DA1 ON "  
	cSQL +=" DA1.D_E_L_E_T_=''						 "
	cSQL +=" AND ZZ1.ZZ1_FILIAL = DA1.DA1_FILIAL	 " 
	cSQL +=" AND ZZ1.ZZ1_PRDEXT = DA1.DA1_CODPRO	 "
	cSQL +=" WHERE ZZ1.D_E_L_E_T_=''				 "
	cSQL +=" ORDER BY DA1.DA1_PRCVEN DESC			 "
	
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cWorkArea, .T., .F. )
	
	
	While (cWorkArea)->(!Eof())  
	
		 nPos := aScan(aDetlProd,{|x| Alltrim(x[1]) == Alltrim((cWorkArea)->DA1_CODPRO) } )	
		       
		 If nPos == 0 
		 
		 	 aAdd(aDetlProd, { (cWorkArea)->DA1_CODPRO, (cWorkArea)->DA1_PRCVEN })  
		 
		 Elseif aDetlProd[nPos][2] < (cWorkArea)->DA1_PRCVEN                                                                                            
				 
			  aDetlProd[nPosVlr][2] := (cWorkArea)->DA1_PRCVEN
 		 Endif                                            
		 
		 (cWorkArea)->(dbSkip())
	EndDo
	
	(cWorkArea)->(dbCloseArea())
	
Return aDetlProd