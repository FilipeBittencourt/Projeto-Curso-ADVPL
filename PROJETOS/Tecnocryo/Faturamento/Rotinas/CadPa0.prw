
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
+---------------------------------------------------------------------------+
| Programa: CADPA0 | Autor: MARCELO SPILARES SECATE      | Data: 21/10/2015 |
+---------------------------------------------------------------------------+
| Descrição: Contratos NET                                                  |
+---------------------------------------------------------------------------+
| Uso: MP11 - COMPRAS                                                       |
+---------------------------------------------------------------------------+
*/

User Function CadPa0()
	Local aCores 		:= {}
	Private aRotina 	:= {}
	Private cCadastro	:= "Contratos NET"
	Private cAliasE 	:= "PA0" 							// Alias enchoice
	Private cAliasG 	:= "PA1" 							// Alias getdados  
	
	aAdd(aRotina, {"Pesquisar" 	, "AxPesqui"	, 0, 1})
	aAdd(aRotina, {"Visualizar"	, "U_PA0Mnt"	, 0, 2})
	aAdd(aRotina, {"Incluir"	, "U_PA0Mnt"	, 0, 3})    
	aAdd(aRotina, {"Alterar"	, "U_PA0Mnt"	, 0, 4})		
	aAdd(aRotina, {"Excluir"	, "U_PA0Mnt"	, 0, 5})	
	aAdd(aRotina, {"Finalizar"	, "U_PA0Mnt"	, 0, 6})	
	aAdd(aRotina, {"Legenda"	, "U_PA0Legen"	, 0, 7})	
	                                               
	aAdd(aCores, {"PA0_DTVIGI <= dDataBase .And. PA0_DTVIGF >= dDataBase", "BR_VERDE"})
	aAdd(aCores, {"PA0_DTVIGI > dDataBase  .Or.  PA0_DTVIGF < dDataBase", "BR_VERMELHO"})   

	DbSelectArea(cAliasE)                                   
	DbSetOrder(1)
	                   
	mBrowse(,,,,cAliasE,,,,,,aCores)	         
	
Return()
    

User Function PA0Legen()

	BrwLegenda( "Contratos NET"	, "Legenda"			,;
	  			{{"BR_VERDE"	, "Vigente"			},; 
			  	{"BR_VERMELHO"	, "Fora de Vigência"}})
Return
                                                                           

User Function PA0Mnt(cAlias, nReg, nOpcx) 

Local cTitulo 	:= "Contrato NET"
Local aCposE   	:= {}
Local cLinOk   	:= "U_VldLin()" 
Local cTudOk   	:= "U_VldDupPrd()"
Local nOpcE		:= 0 
Local nOpcG		:= 0	
Local cFieldOk	:= "AllwaysTrue()" 
Local cDelOK	:= "AllwaysTrue()" 
Local lRet		:= .F.
    
Private aAltGD		:= {}
Private aAltEnc		:= {}
Private aHeader		:= {}
Private aCols		:= {}
Private aAlt		:= {}  
 
	Do Case
		Case nOpcx == 2 //visualizar
			nOpcE := nOpcx
			nOpcG := nOpcx
		Case nOpcx == 3 //incluir
			nOpcE := nOpcx
			nOpcG := nOpcx
		Case nOpcx == 4 //alterar
			nOpcE := nOpcx
			nOpcG := nOpcx							
		Case nOpcx == 5//excluir
			nOpcE := nOpcx
			nOpcG := nOpcx
		OtherWise
			Return .T.
	End Case 
	
	RegToMemory(cAliasE, (nOpcx==3))  
	CreateAltE(nOpcx)

	//GetDados
	CreateHeader(nOpcx)
	CreateCols(nOpcx)
	CreateAltG(nOpcx)
	
	lRet := Modelo3(cTitulo, cAliasE, cAliasG, aCposE, cLinOk, cTudOk, nOpcE, nOpcG, cFieldOk,,,aAltEnc,,,,,cDelOK,aAltGD) 

	If lRet
		BeginTran()
		
		Do Case
			Case nOpcx == 3
		   		Processa({|| fInsert() }, cCadastro, "Incluindo Contrato NET, aguarde...")	   				
				ConfirmSx8()
			Case nOpcx == 4
	    		Processa({|| fUpdate() }, cCadastro, "Atualizando Contrato NET, aguarde...")
			Case nOpcx == 5
	    		Processa({|| fDelete() }, cCadastro, "Excluindo Contrato NET, aguarde...")	    		
	   	End Case

		EndTran()
	Else
		if (nOpcx == 3)
			RollbackSX8()
		End If
	EndIf
Return

Static Function CreateAltE(nOpc)
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAliasE)

	While !EOF() .And. X3_ARQUIVO == cAliasE
		If X3Uso(X3_USADO) .And. (Empty(X3_WHEN) .Or. &(Trim(X3_WHEN)))			 
			AADD(aAltEnc, X3_CAMPO)
		EndIf
		
		DbSkip()
	EndDo			
Return() 

    
//===============================================================
// 
//===============================================================
User Function VldIncPrd()
    
    Local cProduto 	:=  ""
    
	Local lRet 		:= .T.                                                // Retorno da validação   
	
	//================================================================================================|
	// Determina o índice a ser utilizado															  | 
	//================================================================================================|	
	SB1->(dbSetOrder(1))
		
	If !SB1->(dbSeek( xFilial("SB1") + M->PA1_CODPRO ))
		 Aviso("Atenção","O Produto informado não existe.",{"OK"},1) 
	     lRet := .F.
	Endif  
	
Return lRet   
    

User Function VldLin()                                                                                

	Local cProduto := ""
	Local nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="PA1_CODPRO"})  // Posição do Produto na aCols
	Local nQuant   := 0 
	Local nExcl	   := 0 	
	Local nW       := 0            
	Local nK	   := 0		
	
	    
	If Len(aCols) > 1 
	
		 For nW := 1 To Len(aCols)
		       
			   //========================================================================================================================|
			   // Realiza o tratamento para produtos deletados da listagem                                                               |
			   //========================================================================================================================|
		 	   If !aCols[nW][Len(aHeader)+1]      
		 
			     	  For nK := 1 To Len(aCols)
											
			   				//========================================================================================================================|
			   				// Realiza o tratamento para produtos deletados da listagem                                                               |
			  	 		    //========================================================================================================================|
							If !aCols[nK][Len(aHeader)+1]  
							
								  If nW <> nK .And.  aCols[nW][nPos] == aCols[nK][nPos] 
									     		
									   nQuant++
									   //========================================================================================================================|
									   // Caso a quantidade de Produtos tenha seja igua a 2, o loop interno precisa ser interrompido por questões de performance |
									   //========================================================================================================================|
									   If nQuant > 0                   
										     	    
										    cProduto := aCols[nW][nPos]
										 	Exit          
									   Endif 
								  Endif						
							Endif 
					 Next nK       
					 //========================================================================================================================|
					 // Caso a quantidade de Produtos tenha seja igua a 2, o loop externo precisa ser interrompido por questões de performance |
					 //========================================================================================================================|
					 If nQuant > 0
						  Exit          
					 Endif 
				
				Endif 
		 Next nW
	Endif 	       
	
	//=============================================================================================|
	// Exibe mensagem personalizada com o produto duplicado										   |
	//=============================================================================================|
	If !Empty(cProduto)
		  nQuant := 1
		  Aviso("Atenção","O Produto "+Alltrim(cProduto)+" está duplicado no lançamento.",{"OK"},1) 
    Endif
    
Return nQuant == 0       


User Function VldDupPrd()
	
	Local cProduto := ""
	Local nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="PA1_CODPRO"})  // Posição do Produto na aCols
	Local nQuant   := 0 
	Local nExcl	   := 0 	
	Local nW       := 0            
	Local nK	   := 0		
	
	    
	If Len(aCols) > 1 
	
		 For nW := 1 To Len(aCols)
		       
			   //========================================================================================================================|
			   // Realiza o tratamento para produtos deletados da listagem                                                               |
			   //========================================================================================================================|
		 	   If !aCols[nW][Len(aHeader)+1]      
		 
			     	  For nK := 1 To Len(aCols)
											
			   				//========================================================================================================================|
			   				// Realiza o tratamento para produtos deletados da listagem                                                               |
			  	 		    //========================================================================================================================|
							If !aCols[nK][Len(aHeader)+1]  
							
								  If nW <> nK .And.  aCols[nW][nPos] == aCols[nK][nPos] 
									     		
									   nQuant++
									   //========================================================================================================================|
									   // Caso a quantidade de Produtos tenha seja igua a 2, o loop interno precisa ser interrompido por questões de performance |
									   //========================================================================================================================|
									   If nQuant > 0                   
										     	    
										    cProduto := aCols[nW][nPos]
										 	Exit          
									   Endif 
								  Endif						
							Endif 
					 Next nK       
					 //========================================================================================================================|
					 // Caso a quantidade de Produtos tenha seja igua a 2, o loop externo precisa ser interrompido por questões de performance |
					 //========================================================================================================================|
					 If nQuant > 0
						  Exit          
					 Endif 
				
				Endif 
		 Next nW
	Endif 	       
	
	//=============================================================================================|
	// Exibe mensagem personalizada com o produto duplicado										   |
	//=============================================================================================|
	If !Empty(cProduto)
		  Aviso("Atenção","O Produto "+Alltrim(cProduto)+" está duplicado no lançamento.",{"OK"},1) 
    Endif
    
    
    //=============================================================================================|
	// Verifica se todos os produtos foram deletados                                               |
	//=============================================================================================|
	aEval(aCols,{|x| iif( x[Len(aHeader)+1],nExcl++, )})
	
	If Len(aCols) == nExcl
	   	
	   	 nQuant := 1
	   	 Aviso("Atenção","O processo de lançamento deve ter, no mínimo, um item para efetivar a operação.",{"OK"},1) 	  
	Endif 
	
	
Return nQuant == 0
	

Static Function CreateAltG(nOpc)
	
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAliasG)

	While !EOF() .And. X3_ARQUIVO == cAliasG
		
		If X3Uso(X3_USADO) .And. (Empty(X3_WHEN) .Or. &(Trim(X3_WHEN)))	
			  //If !(cExcessao $ cExcessao)
			  AADD(aAltGD, X3_CAMPO)
		EndIf
		
		DbSkip()
	EndDo
Return()

Static Function CreateHeader(nOpc)
	
	aHeader := {}

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAliasG)

	While !EOF() .And. X3_ARQUIVO == cAliasG
		 
		 If X3Uso(X3_USADO) 
			  AADD(aHeader,{ Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT})
		 EndIf
		
		 DbSkip()
	EndDo
	         
	//================================================================================| 
	// Exclui apenas o campo que não deve ser exibido na MsNewGetDados   			  |
	//================================================================================|
	nPos := aScan(aHeader, {|x| Alltrim(x[2]) == "PA1_COD"})
	        
	If nPos > 0 
		 aDel(aHeader , nPos)  
		 aSize(aHeader, Len(aHeader)-1)
	Endif
	 
Return()

Static Function CreateCols(nOpc)
	Local nQtdCpo := 0
	Local nX		:= 0

	nQtdCpo := Len(aHeader)
	aCols := {}

	If nOpc == 3 // Incluir 
		aCols := {Array(nQtdCpo + 1)} 
		aCols[1, nQtdCpo + 1] := .F. 
		
		For nX := 1 to nQtdCpo 
			aCols[1, nX] := CriaVar(aHeader[nX, 2]) 
		Next 
	Else 
		aCols:={} 

		DbSelectArea(cAliasG) 
		DbSetOrder(1) 
		DbSeek((cAliasG)->(PA0_FILIAL + PA0_COD)) 
		
		While !Eof() .And. (cAliasG)->(PA1_FILIAL + PA1_COD) == (cAliasE)->(PA0_FILIAL + PA0_COD)
			AADD(aCols, Array(nQtdCpo + 1)) 
			
			For nX:=1 to nQtdCpo 
				aCols[Len(aCols), nX] := FieldGet(FieldPos(aHeader[nX, 2])) 
			Next 
			
			aCols[Len(aCols),nQtdCpo + 1] := .F. 
			AAdd(aAlt, Recno())			
			
			DbSkip() 
		End 
	Endif
Return()

Static Function fInsert()
	Local bCampo := {|nField| Field(nField)}
	Local i := 0
	Local y := 0
	Local nItem := 0

	ProcRegua(Len(aCols) + FCount())

	DbSelectArea(cAliasE)
	RecLock(cAliasE, .T.)
	
	For i := 1 To FCount()
 		IncProc()
    
	    If "FILIAL" $ FieldName(i)
	    	FieldPut(i, xFilial(cAliasE))
	    Else
	    	FieldPut(i, M->&(Eval(bCampo, i)))
	    EndIf
	Next
	
	MSUnlock()
	
	DbSelectArea(cAliasG)
	DbSetOrder(1)
	
	For i := 1 To Len(aCols)
		IncProc()    

	    If !GDDeleted(i)
	       	RecLock(cAliasG, .T.)
       
       		(cAliasG)->PA1_FILIAL := (cAliasE)->PA0_FILIAL
       		(cAliasG)->PA1_COD    := (cAliasE)->PA0_COD
       
			For y := 1 To Len(aHeader)
	       		FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
	       	Next

	       	MSUnlock()
		EndIf
	Next
Return()

Static Function fUpdate()
	Local i := 0
	Local y := 0
	Local nItem := 0
	Local lLogUpd := .F.

	ProcRegua(Len(aCols) + FCount())

	DbSelectArea(cAliasE)
	RecLock(cAliasE, .F.)

	For i := 1 To FCount()
 		IncProc()
    
	    If "FILIAL" $ FieldName(i)
	    	FieldPut(i, xFilial(cAliasE))
	    Else
	    	FieldPut(i, M->&(Fieldname(i)))
	    EndIf
	Next

	MSUnlock()		

	DbSelectArea(cAliasG)
	DbSetOrder(1)

	nItem := Len(aAlt) + 1

	For i := 1 To Len(aCols)
		If i <= Len(aAlt)
			DbGoTo(aAlt[i])			
			RecLock(cAliasG, .F.)

			If GDDeleted(i)
	   			DbDelete()
			Else      	      	      	
		      	For y := 1 To Len(aHeader)
		       		FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
		       	Next
			EndIf
			
			MSUnlock()
		Else
			If !GDDeleted(i)
	   			RecLock(cAliasG, .T.)
	      	
		      	For y := 1 To Len(aHeader)
		       		FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
		       	Next

	       		(cAliasG)->PA1_FILIAL := (cAliasE)->PA0_FILIAL
	       		(cAliasG)->PA1_COD    := (cAliasE)->PA0_COD
	        
	        	MSUnlock()
   			EndIf
		EndIf
	Next
Return()

// Deleta registros
Static Function fDelete()
	DbSelectArea(cAliasG)
	DbSetOrder(1)

	If DbSeek(xFilial(cAliasG) + (cAliasE)->(PA0_COD))
		ProcRegua((cAliasG)->(RecCount()))

		While !EOF() .And. (cAliasG)->(PA1_FILIAL + PA1_COD) == (cAliasE)->(PA0_FILIAL + PA0_COD)
	 		IncProc()
	 			 		
		   	RecLock(cAliasG, .F.)
	   		DbDelete()
	   		MSUnlock()
	   	
	   		DbSkip()
		End
	EndIf

	DbSelectArea(cAliasE)
	DbSetOrder(1)		
		
	RecLock(cAliasE, .F.)
	DbDelete()
	MSUnlock()	
Return()

Static Function Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aButtons,aCordW,nSizeHeader,cDelOK, aAltGetDados)
	Local lRet
	Local nOpca := 0
	Local cSaveMenuh
	Local nReg := (cAlias1)->(Recno())
	Local oDlg
	Local nDlgHeight   
	Local nDlgWidth
	Local nDiffWidth := 0 
	Local lMDI := .F.
	//Private Altera := nOpcE == 4
	//Private Inclui := nOpcE == 3
	Private lRefresh := .T.
	Private aTELA := Array(0,0)
	Private aGets := Array(0)
	Private bCampo := {|nCPO|Field(nCPO)}
	Private nPosAnt := 9999
	Private nColAnt := 9999
	Private cSavScrVT
	Private cSavScrVP
	Private cSavScrHT
	Private cSavScrHP
	Private CurLen 
	Private nPosAtu := 0

	nOpcE    := If (nOpcE == Nil, 3, nOpcE)
	nOpcG    := If (nOpcG == Nil, 3, nOpcG)
	lVirtual := If (lVirtual == Nil, .F., lVirtual)
	nLinhas  := If (nLinhas == Nil, 99, nLinhas)
	
	If SetMDIChild()
		oMainWnd:ReadClientCoors()
		nDlgHeight 	:= oMainWnd:nHeight
		nDlgWidth	:= oMainWnd:nWidth
		lMdi 		:= .T.
		nDiffWidth 	:= 0
	Else           
		nDlgHeight 	:= 420
		nDlgWidth	:= 632
		nDiffWidth 	:= 1
	EndIf
	
	Default aCordW := {135, 000, nDlgHeight, nDlgWidth}
	Default nSizeHeader := 110

	Define MsDialog oDlg Title cTitulo From aCordW[1], aCordW[2] To aCordW[3], aCordW[4] Pixel Of oMainWnd
		
	If lMdi
		oDlg:lMaximized := .T.
	EndIf

	oEnch := MsmGet():New(cAlias1,nReg,nOpcE,,,,aMyEncho,{13,1,(nSizeHeader/2)+13,If(lMdi, (oMainWnd:nWidth/2)-2,__DlgWidth(oDlg)-nDiffWidth)},aAltEnchoice,3,,,,oDlg,,lVirtual,,,,,,,,.T.)
	
	oGetD := MsGetDados():New((nSizeHeader/2)+13+2,1,If(lMdi, (oMainWnd:nHeight/2)-25,__DlgHeight(oDlg)),If(lMdi, (oMainWnd:nWidth/2)-2,__DlgWidth(oDlg)-nDiffWidth),nOpcG,cLinOk,cTudoOk,"",.T.,aAltGetDados,nFreeze,,nLinhas,cFieldOk,,,,oDlg)
	oGetD:cDelOk := cDelOK
	
	Activate MsDialog oDlg On Init (EnchoiceBar(oDlg,{||nOpca:=1,If(oGetD:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons))

	lRet := nOpca == 1
Return(lRet)