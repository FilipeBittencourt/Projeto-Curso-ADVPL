
//  CADASTROS: Inclusão manual
//  A1_COND
//	ZZ1_COD		- Código da Amarração
//	ZZ1_PRDINT	- Produto Interno (de aplicação)
//	ZZ1_PRDEXT	- Produto Externo (Cobrança de Locação)
//	A1_YDIAFEC	- Dia para fechamento da fatura de aluguél - Cadastro de Cliente
	
//  MOVIMENTAÇÕES: Será gerado por procedimento mensal e ou movimentação.
//	ZZ2_CODLOC	- Código de Locação
//	ZZ2_CLIENTE	- Código do Cliente
//	ZZ2_LOJA	- Código da Filial (Loja)
//	ZZ2_SERIE	- Série da NF de Remessa
//	ZZ2_NOTREM	- Nota Fiscal de Remessa
//	ZZ2_PRDAPL	- Código Produto Aplicado
//	ZZ2_QTDAPL 	- Quantidade Remessa
//	ZZ2_QTDDEV 	- Quantidade Devolvida
//	ZZ2_DTAAPL	- Data de Aplicação / Remessa
//	ZZ2_ULTPED	- Código do Última Pedido para cobrança do aluguel
//	ZZ1_GRPAMA	- Grupo de Amarração
//	ZZ1_METINC	- Metodo de Inclusao (M=Manual, A=Automático)
//	ZZ1_ULTATU	- Data da última atualização
//	
//	AMARRAÇÕES: As movimentações serão vinculadas pelo código de locação, para cada ocorrência
//	C6_YCODLOC	- Código da Locação - Pedido
//	E1_YCODLOC	- Código da Locação - Títulos
//	D2_YCODLOC	- Código da Locação - Nota de Remessa
//	D1_YCODLOC	- Código da Locação - Nota de Retorno

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "MSOBJECT.CH" 
#include "TOTVS.CH"     

Static oGetDupl := Nil

Class TWAmarraProdutos From LongClassName

Data oDlg						 // Dialog Principal   

Data cTitulo
Data cCampo 
Data cMacara
Data nTamanho   
Data cValidacao  
Data cF3
Data nOpc

Data oGetDados
Data aHeader
Data aCols 
Data aDicionario 
Data aButtons

Method New() Constructor 		  // Metodo construtor  
Method MapeiaCamposGetDados()     // Gerencia os campos a serem criados na MsNewGetDados
Method CarregaPropiedadeJanela()  // 
Method ValidaInclusaoProduto()	  //
Method DefinirConsultaDeProduto() //
Method PesquisaProduto()		  //
Method GetDadosVazio()
Method Show()					  // Exibe a janela 	
EndClass 

Method New() Class TWAmarraProdutos

	::oDlg 		 := Nil 
	::oGetDados	 := Nil  

	::cTitulo	 := ""
	::cCampo 	 := ""
	::cMacara    := ""
	::nTamanho   := "" 
	::cValidacao := ""
	::cF3		 := ""
	::nOpc		 := GD_INSERT+GD_UPDATE+GD_DELETE

	::aHeader	 := {}
	::aCols		 := {}
	::aDicionario:= {} 
	::aButtons	 := {""}  

	//Aadd( ::aButtons, {"HISTORIC", {|| ::PesquisaProduto() },"","Consultar Produto",{|| .T.}} ) 	 

Return      




Method Show() Class TWAmarraProdutos

	Local bOK	    := {|| iif( VldTudoOk(), ::oDlg:End(), )   }     
	Local bCancelar := {|| ::oDlg:End() }
	Local lTudoOk 	:= .F.         

	Local aButtons	:= {}   


	aAdd( aButtons, {"HISTORIC", {|| ::DefinirConsultaDeProduto()}, "","Consultar Produto",{|| .T.}} )

	DEFINE MSDIALOG ::oDlg TITLE "Produto Interno vs Produto Fornecedor" FROM 000,000 TO 320,1000 PIXEL  //STYLE FRAME 128                                             

	::aHeader    := ::MapeiaCamposGetDados()
	::oGetDados  := MSNewGetDados():New(000,000, 160, 502, ::nOpc,'AlwaysTrue()','U_VldTOK','',{"ZZ1_COD"},,9999,,,,::oDlg ,::aHeader,{},{||}) 	  	

	oGetDupl	 := ::oGetDados     

	EnchoiceBar(::oDlg, bOK, bCancelar,,@aButtons)

	ACTIVATE MSDIALOG ::oDlg


Return    


Static Function VldTudoOk()

	Local lTudoOK 	:= .T.
	Local nTamanho  := 0
	Local nK 		:= 0


	For nK := 1 To Len(oGetDupl:aCols)

		nTamanho := Len(oGetDupl:aCols[nK])

		If !oGetDupl:aCols[nK][nTamanho]   

			If  Empty(oGetDupl:aCols[nK][1]) .Or. Empty(oGetDupl:aCols[nK][3])

				lTudoOK	:= .F.	
			Endif 		      
		Endif 		     
	Next nK


	If  lTudoOK

		Processa({||GrvProds()}, "Associando Produtos", "Gravando os dados, aguarde...")  
	Else
		Aviso("Atenção","Preencha todos os campos para finalizar o processo" ,{"OK"},1) 	
	Endif 

Return  lTudoOK



Method CarregaPropiedadeJanela() Class TWAmarraProdutos

	//Campos que formam o cabeçalho da MsNewGetDados  
	Aadd(::aDicionario,{"ZZ1_PRDAPL"  , .T.,"Código"		 , PesqPict("ZZ1","ZZ1_COD")   , TamSx3("ZZ1_COD")[2]	, ""  				 ,"" 	}) 
	Aadd(::aDicionario,{"ZZ1_PRDAPL"  , .T.,"Prod.(Aplicado)", PesqPict("ZZ1","ZZ1_PRDAPL"), TamSx3("ZZ1_PRDAPL")[2], "ExistCpo('SB1')"  ,"SB1" }) 
	Aadd(::aDicionario,{"ZZ1_APLDES"  , .T.,"Desc." 	     , PesqPict("ZZ1","ZZ1_APLDES"), TamSx3("ZZ1_APLDES")[2], "" 	 			 ,""	}) 	
	Aadd(::aDicionario,{"ZZ1_PRDLOC"  , .T.,"Prod.(Cob.Loc.)", PesqPict("ZZ1","ZZ1_PRDLOC"), TamSx3("ZZ1_PRDLOC")[2], "ExistCpo('SB1')"  ,"SB1"	}) 
	Aadd(::aDicionario,{"ZZ1_LOCDES"  , .T.,"Desc."			 , PesqPict("ZZ1","ZZ1_LOCDES"), TamSx3("ZZ1_LOCDES")[2], ""				 ,""	}) 

Return  

Method MapeiaCamposGetDados() Class TWAmarraProdutos

	Local aAux := {}
	Local nK   := 0
	Local nX   := 0

	//______________________________________________________________________
	//                                                                      | 
	// Cria coluna(s) que representarão a legenda                           | 
	//______________________________________________________________________|

	SX3->(dbSetOrder(2))

	For nX := 1 To Len (::aDicionario)

		//______________________________________________________________________
		//                                                                      | 
		// Posiciona sobre o campo informado a fim de obter suas configurações  | 
		//                                                                      |
		//______________________________________________________________________|

		If SX3->(dbSeek(::aDicionario[nX][1]))

			//_______________________________________________________________
			//                                                               | 
			// Permite a personalização dos campos padrões                   |
			//                                                               | 
			//_______________________________________________________________|

			::cTitulo  := TRIM(X3Titulo()) 
			::nTamanho := SX3->X3_TAMANHO 

			//_______________________________________________________________
			//                                                               |
			// Tratamento específico para campos personalizados			   |                                             
			//                                                               |
			//_______________________________________________________________|

			If ::aDicionario[nX][2]

				::cTitulo    := iif( !Empty(::aDicionario[nX][3]) 	, ::aDicionario[nX][3], TRIM(x3Titulo())	)
				::nTamanho   := iif( ::aDicionario[nX][5] > 0		, ::aDicionario[nX][5], SX3->X3_TAMANHO )
				::cValidacao := iif( !Empty(::aDicionario[nX][6])   , ::aDicionario[nX][6], SX3->X3_VALID 	) 
				::cF3        := iif( !Empty(::aDicionario[nX][7])   , ::aDicionario[nX][7], SX3->X3_F3  	)
				
			Endif 

			aAdd(aAux,{  ::cTitulo		,;
			SX3->X3_CAMPO	,;	
			SX3->X3_PICTURE	,;
			::nTamanho		,;
			SX3->X3_DECIMAL	,;
			::cValidacao		,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO		,;	
			::cF3			,;
			SX3->X3_CONTEXT	,;
			SX3->X3_CBOX		,;
			SX3->X3_RELACAO	,;
			".T."			})				

		Else    
			//===============================================================================|
			// Campos personalizados a serem utilizados no cabeçalho da Classe MsNewGetDados |
			//===============================================================================|
			::cCampo  	  := ::aDicionario[nX][1]
			::cTitulo    := ::aDicionario[nX][2]
			::cMacara    := ::aDicionario[nX][3]
			::nTamanho   := ::aDicionario[nX][4]  
			::cValidacao := ::aDicionario[nX][5]  
			::cF3		  := ::aDicionario[nX][6]   


			Aadd(aAux,{ ""+::cTitulo+"", ::cCampo, ::cMacara, ::nTamanho , , ::cValidacao, , , ::cF3,"V"})				
		Endif
	Next nX 



Return ::aDicionario := aClone(aAux) 



Method DefinirConsultaDeProduto() Class TWAmarraProdutos

	Local cSQL	   := ""
	Local aPergs   := {}
	Local aRet     := {} 
	Local aProcPrd := {"01=Prod.(Aplicado)","02=Prod.(Cob.Loc.)", "03=Ambos"}
	Local lRet     := .F. 

	aAdd(aPergs,{2,"Origem do Produto", 						   , aProcPrd,70 , "", .F.})
	aAdd(aPergs,{1,"Produto De" 	  , Space(TamSX3("B1_COD")[1]) ,"", "", "SB1", "", 0,.F.})      
	aAdd(aPergs,{1,"Produto Até"	  , Space(TamSX3("B1_COD")[1]) ,"", "", "SB1", "", 0,.F.}) 


	If ParamBox(aPergs ,"",aRet)      

		cSQL += " SELECT								   "
		cSQL += " ZZ1.ZZ1_PRDINT CAMPO01		  		 , "
		cSQL += " ZZ1.ZZ1_PRDEXT CAMPO03		  		 , "
		cSQL += " ZZ1.R_E_C_N_O_ ZZ1REC   			   "  
		cSQL += " FROM " + RetSqlName("ZZ1") +" AS ZZ1   "
		cSQL += "  WHERE ZZ1.D_E_L_E_T_ ='' 			   " 

		If MV_PAR01 == "01"

			If !Empty(MV_PAR03,2)

				cSQL += " AND (ZZ1_PRDINT BETWEEN  '"+MV_PAR02+"' AND '"+MV_PAR03+"' ) " 
			Endif

			cSQL += " ORDER BY ZZ1_PRDINT "


		Elseif MV_PAR01 == "02" 

			If !Empty(MV_PAR03,2)

				cSQL += " AND (ZZ1_PRDEXT BETWEEN  '"+MV_PAR02+"' AND '"+MV_PAR03+"' ) " 
			Endif

			cSQL += " ORDER BY ZZ1_PRDEXT"
		Else 

			If !Empty(MV_PAR02,2) .And.  !Empty(MV_PAR03,2)

				cSQL += " AND (ZZ1_PRDINT BETWEEN  '"+MV_PAR02+"' AND '"+MV_PAR03+"'  OR  ZZ1_PRDEXT BETWEEN  '"+MV_PAR02+"' AND '"+MV_PAR03+"'   )"
			Endif                                          

			cSQL += " ORDER BY ZZ1_PRDINT "	
		Endif 

		::PesquisaProduto(cSQL)
	EndIf

Return 



Method PesquisaProduto(cQuery) Class TWAmarraProdutos

	Local cWorkArea := GetNextAlias()               
	//==============================================

	Local nTam      := 0
	Local nX     	:= 0                            

	//============================================== 
	Local aAux	    := {}  

	//==============================================                           

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cWorkArea, .T., .F.)

	Count To nTotal 

	//==========================================|
	// Posiciona no primeiro registro da tabela |
	//==========================================|
	(cWorkArea)->(dbGotop())

	ProcRegua(nTotal)

	::oGetDados:aCols := {}

	(cWorkArea)->(dbGoTop()) 

	While (cWorkArea)->(!Eof())

		IncProc(nTotal)

		aAux := {}                                   

		//_________________________________________________________________________________________
		//                                                                                         |  
		// Posiciona sobre o Álias corrente                                                        | 
		//_________________________________________________________________________________________| 

		Aadd(aAux, (cWorkArea)->(CAMPO01)) 
		Aadd(aAux, Posicione("SB1", 1, xFilial("SB1") + PADR((cWorkArea)->CAMPO01,TAMSX3("B1_COD")[1]),"B1_DESC")) 
		Aadd(aAux, (cWorkArea)->(CAMPO03))
		Aadd(aAux, Posicione("SB1", 1, xFilial("SB1") + PADR((cWorkArea)->CAMPO03,TAMSX3("B1_COD")[1]),"B1_DESC")) 

		//===========================================|
		// Valor responsável pela seleção do registro| 	
		//===========================================|
		Aadd(aAux, (cWorkArea)->(ZZ1REC)) 	

		//===========================================|
		// Coluna adicional do aCols.				   | 	
		//===========================================|
		Aadd(aAux,.F.) 

		Aadd(::oGetDados:aCols,aClone(aAux))

		(cWorkArea)->(dbSkip())	 
	EndDo

	(cWorkArea)->(dbCloseArea())

	::oGetDados:oBrowse:Refresh() 

	oGetDupl := ::oGetDados     

	//================================================|
	// aCols Vazio                                    | 
	//================================================|
	If Empty(::oGetDados:aCols)      

		::GetDadosVazio(::oGetDados)
	Endif


Return
//________________________________________________________________________________________________              



Method GetDadosVazio(oGetDados) Class TWAmarraProdutos

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



User Function  VldProd()

	Local cWorkArea := GetNextAlias()
	Local cQuery    := ""
	Local cProduto  := "" 

	Local nLin 	   := oGetDupl:oBrowse:nAt  
	Local nCol     := oGetDupl:oBrowse:nColPos	       
	Local nTamanho := 0
	Local nK	   := 0

	Local lRet 	   := .T.

	If ExistCpo("SB1", M->B1_COD) 

		If Len(oGetDupl:aCols) > 1 

			For nK := 1 To Len(oGetDupl:aCols)

				nTamanho := Len(oGetDupl:aCols[nK])

				If !oGetDupl:aCols[nK][nTamanho]

					If  Alltrim(oGetDupl:aCols[nK][1])== Alltrim(M->B1_COD) .Or. Alltrim(oGetDupl:aCols[nK][3])== Alltrim(M->B1_COD) 

						Aviso("Atenção","O Produto "+Alltrim(M->B1_COD)+" já está vinculado a outro Produto" ,{"OK"},1) 
						lRet := .F.
					Endif 
				Endif 
			Next nK



		Else 

			If  !oGetDupl:aCols[1][Len(oGetDupl:aCols[1])]

				If !Empty(M->B1_COD) 

					oGetDupl:aCols[nLin][nCol] := M->B1_COD

					If Alltrim(oGetDupl:aCols[nLin][1]) == Alltrim(oGetDupl:aCols[nLin][3]) .And. !oGetDupl:aCols[nLin][Len(oGetDupl:aCols[1])]

						Aviso("Atenção","O Produto "+Alltrim(M->B1_COD)+" já está vinculado a outro Produto na " ,{"OK"},1) 
						lRet := .F.
					Endif

				Endif 
			Endif 
		Endif 


		//__________________________________________________________________________________________
		//                                                                                          | 
		// A descrição dos campos será atualizada apenas em caso da validação estar correta.        |
		//__________________________________________________________________________________________|

		If lRet

			//__________________________________________________________________________________________
			//                                                                                          | 
			// Impede o lançamento de um produto que já esteja associado com outro                      |
			//__________________________________________________________________________________________|

			cQuery  += " SELECT ZZ1.R_E_C_N_O_ ZZ1REC FROM "+ RetSqlName("ZZ1") +" AS ZZ1 	" 
			cQuery  += " WHERE ZZ1.D_E_L_E_T_ = '' 											"
			cQuery  += " AND ZZ1.ZZ1_FILIAL   = '"+xFilial("ZZ1")+"' 						"  
			cQuery  += " AND ( ZZ1.ZZ1_PRDINT = '"+M->B1_COD+"' 							"  
			cQuery  += " OR    ZZ1.ZZ1_PRDEXT = '"+M->B1_COD+"') 							" 

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cWorkArea, .T., .F. )

			If  (cWorkArea)->(!Eof())

				MsgAlert("Este produto já está cadastrado !","Atenção") 
				lRet := .F.   

				//________________________________________________________________________________________________
				//                                                                                                | 
				// Fecha a área de trabalho ativa                                                                 |
				//________________________________________________________________________________________________|

				(cWorkArea)->(dbCloseArea()) 

			Else 

				//__________________________________________________________________________________________
				//                                                                                          | 
				// Identifica a coluna que cujo valor foi informado                                         | 
				//__________________________________________________________________________________________|
				If oGetDupl:oBrowse:nColPos == 1

					oGetDupl:aCols[nLin][GDFieldPos('B1_DESC')] := SB1->B1_DESC
				Else
					oGetDupl:aCols[nLin][GDFieldPos('PRDEXT')]  := SB1->B1_DESC
				Endif
			Endif

		Endif
	Else
		lRet := .F.
	Endif 


Return lRet  



Static Function GrvProds()

	//________________________________________________

	Local cWorkArea := GetNextAlias()
	Local cQuery    := ""
	Local cProdInt  := "" 
	Local cProdExt  := ""                            

	//________________________________________________
	Local nTamanho  := 0 
	Local nK 		:= 0 


	ZZ1->(dbSetOrder(1))

	For nK := 1 To Len(oGetDupl:aCols)

		nTamanho := Len(oGetDupl:aCols[nK])

		If nTamanho == Len(oGetDupl:aHeader) + 1

			If !oGetDupl:aCols[nK][nTamanho]  

				ZZ1->(RecLock("ZZ1", .T.))	  

				ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
				ZZ1->ZZ1_PRDINT := oGetDupl:aCols[nK][1]
				ZZ1->ZZ1_PRDEXT := oGetDupl:aCols[nK][3] 	   		 

				ZZ1->(MSUnlock())
			Endif 
		Else  

			//________________________________________________________________________________________________
			//                                                                                                | 
			// Deleta/Altera,respectivamente, o registro atualmente posicionado                               | 
			//________________________________________________________________________________________________|

			ZZ1->(dbGoto(oGetDupl:aCols[nK][nTamanho-1]))

			ZZ1->(RecLock("ZZ1", .F.))

			If oGetDupl:aCols[nK][nTamanho]  

				ZZ1->(dbDelete())         
			Else                  
				ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
				ZZ1->ZZ1_PRDINT := oGetDupl:aCols[nK][1]
				ZZ1->ZZ1_PRDEXT := oGetDupl:aCols[nK][3] 	   		 
			Endif 

			ZZ1->(MSUnLock())	
		Endif 	
	Next nK

Return



// Alinhamento do método addInLayout
#define LAYOUT_ALIGN_LEFT     1
#define LAYOUT_ALIGN_RIGHT    2
#define LAYOUT_ALIGN_HCENTER  4
#define LAYOUT_ALIGN_TOP      32
#define LAYOUT_ALIGN_BOTTOM   64
#define LAYOUT_ALIGN_VCENTER  128

// Alinhamento para preenchimento dos componentes no TLinearLayout
#define LAYOUT_LINEAR_L2R 0 // LEFT TO RIGHT
#define LAYOUT_LINEAR_R2L 1 // RIGHT TO LEFT
#define LAYOUT_LINEAR_T2B 2 // TOP TO BOTTOM
#define LAYOUT_LINEAR_B2T 3 // BOTTOM TO TOP

//-------------------
// TGRIDLAYOUT
//-------------------
function u_LayGrid()

	oWnd:= TWindow():New(0, 0, 200, 200, "TGridLayout", NIL, NIL, NIL, NIL, NIL, NIL, NIL, CLR_BLACK, CLR_WHITE, NIL, NIL, NIL, NIL, NIL, NIL, .T. )
	oWnd:setCss("QPushButton{borderDummy: 1px solid black;}")
	
	oLayout1:= TGridLayout():New(oWnd,CONTROL_ALIGN_ALLCLIENT,0,0)

	oTButton1 := TButton():New( 0, 0, "Botão 01", oLayout1,{||alert("Botão 01")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 := TButton():New( 0, 0, "Botão 02", oLayout1,{||alert("Botão 02")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton3 := TButton():New( 0, 0, "Botão 03", oLayout1,{||alert("Botão 03")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oLayout1:addInLayout(oTButton1, 1, 1, , ,LAYOUT_ALIGN_TOP)
	oLayout1:addInLayout(oTButton2, 1, 2, , ,LAYOUT_ALIGN_VCENTER)
	oLayout1:addInLayout(oTButton3, 1, 3, , ,LAYOUT_ALIGN_BOTTOM)

	oTButton1:cToolTip := "Linha: 01; Coluna: 01; SpanLinha: 00; SpanColuna: 00; Alinhado: Topo"
	oTButton2:cToolTip := "Linha: 01; Coluna: 02; SpanLinha: 00; SpanColuna: 00; Alinhado: Centro+Vertical"
	oTButton3:cToolTip := "Linha: 01; Coluna: 03; SpanLinha: 00; SpanColuna: 00; Alinhado: Rodapé"

	oTButton4 := TButton():New( 0, 0, "Botão 04", oLayout1,{||alert("Botão 04")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oLayout1:addInLayout(oTButton4, 2, 1, , 3)
	oTButton4:cToolTip := "Linha: 02; Coluna: 01; SpanLinha: 00; SpanColuna: 03; Alinhado: NULL"
	
	oTButton5 := TButton():New( 0, 0, "Botão 05", oLayout1,{||alert("Botão 05")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton6 := TButton():New( 0, 0, "Botão 06", oLayout1,{||alert("Botão 06")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oLayout1:addInLayout(oTButton5, 3, 1, ,2)
	oLayout1:addInLayout(oTButton6, 3, 3)
	oTButton5:cToolTip := "Linha: 03; Coluna: 01; SpanLinha: 00; SpanColuna: 02; Alinhado: NULL"
	oTButton6:cToolTip := "Linha: 03; Coluna: 03; SpanLinha: 00; SpanColuna: 00; Alinhado: NULL"

	oTButton7 := TButton():New( 0, 0, "Botão 07", oLayout1,{||alert("Botão 07")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton8 := TButton():New( 0, 0, "Botão 08", oLayout1,{||alert("Botão 08")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton9 := TButton():New( 0, 0, "Botão 09", oLayout1,{||alert("Botão 09")}, 80,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oLayout1:addInLayout(oTButton7, 4, 1, , , LAYOUT_ALIGN_RIGHT)
	oLayout1:addInLayout(oTButton8, 4, 2, 2)
	oLayout1:addInLayout(oTButton9, 4, 3, , , LAYOUT_ALIGN_LEFT)
	oTButton7:cToolTip := "Linha: 04; Coluna: 01; SpanLinha: 00; SpanColuna: 00; Alinhado: Direita; <b><font color=red>[Tamanho Fixo]</b></font>"
	oTButton8:cToolTip := "Linha: 04; Coluna: 02; SpanLinha: 02; SpanColuna: 00; Alinhado: NULL"
	oTButton9:cToolTip := "Linha: 04; Coluna: 03; SpanLinha: 00; SpanColuna: 00; Alinhado: Esquerda; <b><font color=red>[Tamanho Fixo]</b></font>""
	oTButton10 := TButton():New( 0, 0, "Botão 10", oLayout1,{||alert("Botão 10")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton11 := TButton():New( 0, 0, "Botão 11", oLayout1,{||alert("Botão 11")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oLayout1:addInLayout(oTButton10, 5, 1)
	oLayout1:addInLayout(oTButton11, 5, 3)
	oTButton10:cToolTip := "Linha: 05; Coluna: 01; SpanLinha: 00; SpanColuna: 00; Alinhado: NULL"
	oTButton11:cToolTip := "Linha: 05; Coluna: 03; SpanLinha: 00; SpanColuna: 00; Alinhado: NULL"
	oWnd:Activate()
return
//--------------------------------------
// MULTIPLOS LAYOUTS
//--------------------------------------
function u_LayGrid2()
	oWnd:= TWindow():New(100, 100, 200, 200, "Multiplos Layouts",,,,,,,,CLR_BLACK, CLR_WHITE)
	//oWnd = MsDialog():New( 000, 000, 160, 600, "Multiplos Layouts",,,.F.,, 0, 16777215,,,.T.,, ,.F. )
	oWnd:setCss("QWidget{padding: 5px;}")
	//----------------------------------------------------------------------------
	// Layout principal
	//----------------------------------------------------------------------------
	oLayGrid:= TGridLayout():New(oWnd,CONTROL_ALIGN_ALLCLIENT)
	//----------------------------------------------------------------------------
	// Segundo layout vai organizar campos de preenchimento
	//----------------------------------------------------------------------------
	oLayGrid2 := TGridLayout():New(oWnd, LAYOUT_LINEAR_L2R)
	oLayGrid2:setCss("QWidget{padding: 0px; margin-top: 4px;}") 
	oSay1 := TSay():New(01,01,{||"Lorem"},oLayGrid,,,,,,.T.,,,20,10)
	oSay2 := TSay():New(01,01,{||"ipsum"},oLayGrid,,,,,,.T.,,,20,10)
	oSay3 := TSay():New(01,01,{||"dolor"},oLayGrid,,,,,,.T.,,,20,10)
	oSay4 := TSay():New(01,01,{||"Sit"  },oLayGrid,,,,,,.T.,,,20,10)
	oLayGrid2:addInLayout(oSay1, 1, 1,,,LAYOUT_ALIGN_VCENTER)
	oLayGrid2:addInLayout(oSay2, 2, 1,,,LAYOUT_ALIGN_VCENTER)
	oLayGrid2:addInLayout(oSay3, 3, 1,,,LAYOUT_ALIGN_VCENTER)
	oLayGrid2:addInLayout(oSay4, 4, 1,,,LAYOUT_ALIGN_VCENTER)
	oGet1 := TGet():New(0,0,{|u| space(100) },oLayGrid,100,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"",,,, )
	oGet2 := TGet():New(0,0,{|u| space(100) },oLayGrid,100,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"",,,, )
	oGet3 := TGet():New(0,0,{|u| space(100) },oLayGrid,100,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"",,,, )
	oGet4 := TGet():New(0,0,{|u| space(100) },oLayGrid,100,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"",,,, )
	oLayGrid2:addInLayout(oGet1, 1, 2,,,)
	oLayGrid2:addInLayout(oGet2, 2, 2,,,)
	oLayGrid2:addInLayout(oGet3, 3, 2,,,)
	oLayGrid2:addInLayout(oGet4, 4, 2,,,)
	
	//----------------------------------------------------------------------------
	// Terceiro layout vai conter um TGet e um TButtom alinhado a direita
	//----------------------------------------------------------------------------
	oLayGrid3 := TGridLayout():New(oWnd, LAYOUT_LINEAR_L2R, CONTROL_ALIGN_BOTTOM, 0, 10)
	oLayGrid3:setCss("QWidget{padding: 0px;}") 
	
	oGetCentral := TGet():New(0,0,{|u|space(100)},oLayGrid3,100,10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"",,,, )
	oBtnCentral := TButton():New( 0, 0, "...", oLayGrid3,{||},10,13,,,.F.,.T.,.F.,,.F.,,,.F. )
	oLayGrid3:addInLayout(oGetCentral, 1, 1,,,)
	oLayGrid3:addInLayout(oBtnCentral, 1, 2,,,LAYOUT_ALIGN_RIGHT)
	//----------------------------------------------------------------------------
	// Neste ponto insiro os layouts secundarios dentro do principal
	//----------------------------------------------------------------------------
	oLayGrid:addInLayout(oLayGrid2, 1, 1,, 4, LAYOUT_ALIGN_TOP)	
	oLayGrid:addInLayout(oLayGrid3, 2, 1, , 4, )	
	oTButton1 := TButton():New( 0, 0, "Cancelar", oLayGrid,{||}, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 := TButton():New( 0, 0, "Ok", oLayGrid,{||}, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oLayGrid:addInLayout(oTButton1, 3, 3, , ,)
	oLayGrid:addInLayout(oTButton2, 3, 4, , ,)
	oWnd:Activate()
return
//-------------------
// TFLOWLAYOUT
//-------------------
function u_LayFlow()
	oWnd:= TWindow():New(0, 0, 550, 700, "TFlowLayout", NIL, NIL, NIL, NIL, NIL, NIL, NIL, CLR_BLACK, CLR_WHITE, NIL, NIL, NIL, NIL, NIL, NIL, .T. )
	oWnd:setCss("QPushButton{borderDummy: 1px solid black;}")
	oLayout1:= tFlowLayout():New(oWnd,CONTROL_ALIGN_ALLCLIENT,0,0)
	oTButton1 := TButton():New( 0, 0, "Botão 01", oLayout1,{||alert("Botão 01")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 := TButton():New( 0, 0, "Botão 02", oLayout1,{||alert("Botão 02")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton3 := TButton():New( 0, 0, "Botão 03", oLayout1,{||alert("Botão 03")}, 80,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton4 := TButton():New( 0, 0, "Botão 04", oLayout1,{||alert("Botão 04")}, 80,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton5 := TButton():New( 0, 0, "Botão 05", oLayout1,{||alert("Botão 05")}, 40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton6 := TButton():New( 0, 0, "Botão 06", oLayout1,{||alert("Botão 06")}, 40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oLayout1:AddInLayout(oTButton1)
	oLayout1:AddInLayout(oTButton2)
	oLayout1:AddInLayout(oTButton3)
	oLayout1:AddInLayout(oTButton4)
	oLayout1:AddInLayout(oTButton5)
	oLayout1:AddInLayout(oTButton6)
	oPanel1 := tPanel():New(01,01,"oPanel1",oLayout1,,.T.,,,CLR_HGRAY,050,050)
	oPanel2 := tPanel():New(01,01,"oPanel2",oLayout1,,.T.,,,CLR_HGRAY,050,100)
	oPanel3 := tPanel():New(01,01,"oPanel3",oLayout1,,.T.,,,CLR_HGRAY,100,050)
	oLayout1:AddInLayout(oPanel1)
	oLayout1:AddInLayout(oPanel2)
	oLayout1:AddInLayout(oPanel3)
	oWnd:Activate()
return
//-------------------
// TLINEARLAYOUT
//-------------------
function u_LayLinear()
	oWnd:= TWindow():New(0, 0, 500, 400, "TLinearLayout", NIL, NIL, NIL, NIL, NIL, NIL, NIL, CLR_BLACK, CLR_WHITE, NIL, NIL, NIL, NIL, NIL, NIL, .T. )
	//-------------------
	// Frame superior
	//-------------------
	oHeaderLyt := tLinearLayout():New(oWnd, LAYOUT_LINEAR_L2R, CONTROL_ALIGN_TOP, 0, 60)
	oHeaderLyt:SetCSS("QFrame{ background-color: #C6E0B4; margin: 5px; }")
	oSayHeader := TSay():New(0,0,{||"<H1><font color=#424242>Título</H1>"},oHeaderLyt,,,,,,.T.,,,0,0,,,,,,.T.)
	oHeaderLyt:addInLayout(oSayHeader, LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_VCENTER) // Centraliza horizontal+vertical
	//-------------------
	// Frame central
	//-------------------
	oBodyLyt := tLinearLayout():New(oWnd, LAYOUT_LINEAR_L2R, CONTROL_ALIGN_ALLCLIENT, 0, 0)
	// Divide Frame central com 3 Paineis
	oPanelL := tPanel():New(0,0,,oBodyLyt,,.T.,,,,0,0)
	oPanelC := tPanel():New(0,0,,oBodyLyt,,.T.,,,,0,0)
	oPanelR := tPanel():New(0,0,,oBodyLyt,,.T.,,,,0,0)
	oBodyLyt:addInLayout(oPanelL,,25)
	oBodyLyt:addInLayout(oPanelC,,50)
	oBodyLyt:addInLayout(oPanelR,,25)
	// Itens do painel Esquerdo
	oMenuLyt := tLinearLayout():New(oPanelL, LAYOUT_LINEAR_T2B, CONTROL_ALIGN_ALLCLIENT, 0, 0)
	oMenuLyt:SetCSS("QFrame{ margin: 5px; } TButton{ background-color: #B4C6E7; color: #424242; text-align: left; margin-bottom: 3px; font-size: 18px; }" )
	oButton1 := TButton():New( 0, 0, "Botão 01", oMenuLyt,{||alert("Botão 01")}, 40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton2 := TButton():New( 0, 0, "Botão 02", oMenuLyt,{||alert("Botão 02")}, 40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton3 := TButton():New( 0, 0, "Botão 03", oMenuLyt,{||alert("Botão 03")}, 40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton4 := TButton():New( 0, 0, "Botão 04", oMenuLyt,{||alert("Botão 04")}, 40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oMenuLyt:addInLayout(oButton1)
	oMenuLyt:addInLayout(oButton2)
	oMenuLyt:addInLayout(oButton3)
	oMenuLyt:AddSpacer(5) // Adiciona um espaçador para alinhar o "Botao 04" ao rodape 
	oMenuLyt:addInLayout(oButton4)
	// Itens do painel Central
	oCenterLyt := tLinearLayout():New(oPanelC, LAYOUT_LINEAR_T2B, CONTROL_ALIGN_ALLCLIENT, 0, 0)
	oCenterLyt:SetCSS("QFrame{ margin: 5px; } TSay{ color: #424242; }")
	cCenterTxt := "<h1>Conteúdo</h1><br>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus pharetra turpis a tempor tempus. Vivamus sit amet eleifend ante, quis suscipit nulla. Morbi sollicitudin eleifend dapibus. Integer congue sapien quis augue dignissim sodales. Sed a sapien justo. Ut sodales nulla sed lacus sollicitudin, a dignissim magna convallis. Maecenas facilisis purus id aliquam tempus. Quisque tempus magna quis nunc ultrices, sit amet luctus ante facilisis."
	oSayCenter := TSay():New(0,0,{||cCenterTxt},oCenterLyt,,,,,,.T.,,,0,0,,,,,,.T.)
	oCenterLyt:addInLayout(oSayCenter)
	// Itens do painel Direito
	oItemLyt := tLinearLayout():New(oPanelR, LAYOUT_LINEAR_T2B, CONTROL_ALIGN_ALLCLIENT, 0, 0)
	oItemLyt:SetCss("QFrame{ margin: 2px; }")
	cItems := "<h1>Item 1</h1><br>Lorem ipsum dolor sit amet, consectetur adipiscing elit.<br><h1>Item 2</h1><br>Vivamus pharetra turpis a tempor tempus.<br><h1>Item 3</h1><br>Quisque tempus magna quis nunc ultrices, sit amet luctus ante facilisis."
	oSayItem := TSay():New(0,0,{||cItems},oItemLyt,,,,,,.T.,,,0,0,,,,,,.T.)
	oSayItem:SetCss("TSay{ qproperty-alignment: AlignCenter; background-color: #F8CBAD; color: #424242; }")
	oItemLyt:addInLayout(oSayItem)
	//-------------------
	// Frame inferior
	//-------------------
	oBottomLyt := tLinearLayout():New(oWnd, LAYOUT_LINEAR_L2R, CONTROL_ALIGN_BOTTOM, 0, 40)
	oBottomLyt:SetCSS("QFrame{ background-color: #FFE699; color: #424242; margin: 5px; }")
	oSayBottom:= TSay():New(0,0,{||"Redimensione a janela para testar a responsividade."},oBottomLyt,,,,,,.T.,,,0,0,,,,,,.T.)
	oSayBottom:SetCss("TSay{ qproperty-alignment: AlignCenter; font-size: 18px;}")
	oBottomLyt:addInLayout(oSayBottom)
	oWnd:Activate()
return
