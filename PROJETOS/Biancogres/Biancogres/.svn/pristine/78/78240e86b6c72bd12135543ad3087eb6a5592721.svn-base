#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT010GRV       ºAutor  ³ BRUNO MADALENO     º Data ³  26/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PONTO DE ENTRADA RESPONSAVEL EM ATUALIZAR A TABELA (SA5 - AMARRA-º±±
±±º          ³ CAO PRODUTO x FORNECEDOR                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8 - R4                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION MT010GRV()
//Thiago Dantas - 10/02/2015
Local aArea 	:= GetArea()

Local nOperAux 	:=  PARAMIXB[1] // 1 - inclusao / 2 - alteracao / 3 - exclusai  
Local aHeadAux	:=  PARAMIXB[2] // Header da Rotina
Local aColsAux	:= 	PARAMIXB[3] // Acols da Rotina

Local nPosPreco :=  aScan( aHeadAux, { |x| AllTrim( x[2] ) == 'AIB_PRCCOM' 	} )
Local nPosProd 	:=  aScan( aHeadAux, { |x| AllTrim( x[2] ) == 'AIB_CODPRO' 	} )
Local nPosTab 	:=  aScan( aHeadAux, { |x| AllTrim( x[2] ) == 'AIB_CODTAB' 	} )

Local nIAux := 0  

Local cFornece 	:= AIA->AIA_CODFOR	
Local cLoja  	:= AIA->AIA_LOJFOR 
Local cTabela   := AIA->AIA_CODTAB
Local dDataIni  := M->AIA_DATDE
Local dDataFin  := M->AIA_DATATE
Local lVigente 	:= ((dDataBase >= dDataIni ) .And. (dDataBase <= dDataFin ))
Local cProduto  := ''
Local nPreco  	:= 0
Local lAchouProd:= .F.

dbSelectArea("SA5")
dbSetOrder(1)

If nOperAux == 1 .Or. (nOperAux == 2 .And. lVigente)
	For nIAux := 1 To Len(aColsAux)

		cProduto	:= aColsAux[nIAux, nPosProd]
		nPreco		:= aColsAux[nIAux, nPosPreco]
		
		If dbSeek(xFilial("SA5")+cFornece+cLoja+cProduto)
			 While (!SA5->(Eof()).And. (cProduto == SA5->A5_PRODUTO .And. cFornece == SA5->A5_FORNECE .And. cLoja == SA5->A5_LOJA))
				 If SA5->A5_CODTAB != cTabela .And. nPreco != SA5->A5_YPRECO
				 	//lAtualTab := .T.
				 	RECLOCK("SA5",.F.)
				 	SA5->A5_CODTAB 	:= cTabela
				 	SA5->A5_YPRECO	:= nPreco
				 	MSUNLOCK()	
				 ElseIf (SA5->A5_CODTAB == cTabela .And. nPreco != SA5->A5_YPRECO)
				 	//lAtualTab := .T.
				 	RECLOCK("SA5",.F.)
				 	SA5->A5_YPRECO	  := nPreco
				 	MSUNLOCK()
				 EndIf
				 dbSelectArea("SA5")
				 SA5->(dbSkip())
			 EndDo
		Else
			RECLOCK("SA5",.T.)
			SA5->A5_FILIAL	  	:= XFILIAL("SA5")
			SA5->A5_FORNECE	:= cFornece
			SA5->A5_LOJA	    := cLoja
			SA5->A5_NOMEFOR	:= Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_NOME")
			SA5->A5_PRODUTO	:= cProduto
			SA5->A5_NOMPROD	:= Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
			SA5->A5_CODTAB	  	:= cTabela
			SA5->A5_YPRECO	  	:= nPreco 
		 	MSUNLOCK()
		EndIf
	Next nIAux
EndIf



SA5->(dbCloseArea())

  
/*
  
//
LOCAL A
LOCAL aArea := SA5->(GetArea())
PRIVATE ENTER	:= CHR(13)+CHR(10)
PRIVATE CSQL := ""
A        := "S"
cDataVig := DTOS(DDATABASE)
   
IF INCLUI .OR. ALTERA   // INCLUSAO, ALTERACAO OU COPIA

		// SELECIONANDO A TABELA DE PRECO QUE ESTA SENDO INCLUIDA / ALTERADA PARA ATUALIZAR A TABELA (SA5 - AMARRACAO PRODUTO x FORNECEDOR
		CSQL := "SELECT AIA_FILIAL, AIB_PRCCOM, AIA_CODFOR, AIA_LOJFOR, A2_NOME, AIB.AIB_CODPRO, SB1.B1_DESC, AIA.AIA_CODTAB " + ENTER
		CSQL += "FROM "+RETSQLNAME("AIA")+" AIA, "+RETSQLNAME("AIB")+" AIB, "+RETSQLNAME("SA2")+" SA2, "+RETSQLNAME("SB1")+" SB1 " + ENTER
		CSQL += "WHERE	AIA.AIA_FILIAL	=  AIB.AIB_FILIAL AND " + ENTER
		CSQL += "		AIA.AIA_CODFOR	=  AIB.AIB_CODFOR AND " + ENTER
		CSQL += "		AIA.AIA_LOJFOR	=  AIB.AIB_LOJFOR AND " + ENTER
		CSQL += "		AIA.AIA_CODTAB	=  AIB.AIB_CODTAB AND " + ENTER
		CSQL += "		SA2.A2_COD		  = AIA.AIA_CODFOR AND " + ENTER
		CSQL += "		SA2.A2_LOJA		  = AIA.AIA_LOJFOR AND " + ENTER
		CSQL += "		SB1.B1_COD	  	= AIB.AIB_CODPRO AND " + ENTER
		CSQL += "		AIB.AIB_DATVIG >= '"+cDataVig+"' AND " + ENTER
		CSQL += "		AIA.D_E_L_E_T_ = '' AND " + ENTER
		CSQL += "		AIB.D_E_L_E_T_ = '' AND " + ENTER
		CSQL += "		SA2.D_E_L_E_T_ = '' AND " + ENTER
		CSQL += "		SB1.D_E_L_E_T_ = '' " + ENTER
		CSQL += "		AND AIA_CODFOR = '"+M->AIA_CODFOR+"' " + ENTER
		CSQL += "		AND AIA_LOJFOR = '"+M->AIA_LOJFOR+"' " + ENTER
		CSQL += "		AND AIA_CODTAB = '"+M->AIA_CODTAB+"' " + ENTER
		CSQL += "ORDER BY AIA_CODFOR, AIA_LOJFOR, AIB.AIB_CODPRO, AIA.AIA_CODTAB " + ENTER
		IF CHKFILE("_TRAB")
			DBSELECTAREA("_TRAB")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_TRAB" NEW
		
		DBSELECTAREA("SA5")
		DO WHILE ! _TRAB->(EOF())
		
            */
			// BUSCANDO O PREÇO ANTIGO NA TABELA VELHA DE AMARRACAO ESSA ROTINA DEVERA SER DESATIVADA QUANDO LTERADOS NA TABELA DE PRECO
			// FOR IMPLANTADO A TABELA DE PRECO DO COMPRAS		
			/*CSQL := "SELECT * " + ENTER
			CSQL += "FROM "+RETSQLNAME("SA5")+" " + ENTER
			CSQL += "WHERE	A5_FORNECE	= '"+_TRAB->AIA_CODFOR+"' AND  " + ENTER
			CSQL += "		A5_LOJA		= '"+_TRAB->AIA_LOJFOR+"' AND " + ENTER
			CSQL += "		A5_PRODUTO	= '"+_TRAB->AIB_CODPRO+"' AND " + ENTER
			CSQL += "		D_E_L_E_T_ = ''	 " + ENTER		
			IF CHKFILE("_PRECO")
				DBSELECTAREA("_PRECO")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_PRECO" NEW		
		    IF ! _PRECO->(EOF())
		    	NNPRECO := _PRECO->A5_YPRECO
		    ELSE
				NNPRECO := 0
			END IF*/
			/*
			// DELETANDO A TABELA (SA5 AMARRACAO PRODUTO X FORNECEDOR) PARA INCLUIR OS REGISTROS INCLUIDOS / ALTERADOS NA TABELA DE PRECO
			CSQL := "UPDATE "+RETSQLNAME("SA5")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " + ENTER
			CSQL += "WHERE	A5_FORNECE	= '"+_TRAB->AIA_CODFOR+"' AND		" + ENTER
			CSQL += "		    A5_LOJA			= '"+_TRAB->AIA_LOJFOR+"' AND		" + ENTER
			CSQL += "		    A5_PRODUTO	= '"+_TRAB->AIB_CODPRO+"' AND		" + ENTER
			CSQL += "		    D_E_L_E_T_	= ''	 													" + ENTER
			TCSQLEXEC(CSQL)
			    
			DbSelectArea("SA5")
			DbSeek(xFilial("SA5")+_TRAB->AIA_CODFOR+_TRAB->AIA_LOJFOR+_TRAB->AIB_CODPRO)
			IF !Found()
				 RECLOCK("SA5",.T.)
				 SA5->A5_FILIAL	  := XFILIAL("SA5")
				 SA5->A5_FORNECE	:= _TRAB->AIA_CODFOR
				 SA5->A5_LOJA	    := _TRAB->AIA_LOJFOR
				 SA5->A5_NOMEFOR	:= _TRAB->A2_NOME
				 SA5->A5_PRODUTO	:= _TRAB->AIB_CODPRO
				 SA5->A5_NOMPROD	:= _TRAB->B1_DESC
				 SA5->A5_CODTAB	  := _TRAB->AIA_CODTAB
				 SA5->A5_YPRECO	  := _TRAB->AIB_PRCCOM // IIF(NNPRECO=0,_TRAB->AIB_PRCCOM,NNPRECO)
				 MSUNLOCK()
			ENDIF
			
			// INCLUI REGISTROS DA TABELA DE PRECO NA TABELA (A1C - DE TOLERANCIA DE RECEBIMENTO) QUANDO NAO EXISTIR NA MESMA
			DBSELECTAREA("AIC")
			DBSETORDER(2) // VERIFICANDO SE EXISTE O REGISTRO REFENTENTE A TABELA DE PRECO NA TABELA AIC
			IF ! DBSEEK( XFILIAL("AIC") + M->AIA_CODFOR + M->AIA_LOJFOR + _TRAB->AIB_CODPRO ,.F.) 
				RECLOCK("AIC",.T.)
				AIC->AIC_FILIAL 	:= XFILIAL("AIC")
			
	
				CqUERY := "SELECT ISNULL(MAX(AIC_CODIGO),'0') AS NCODIGO FROM "+RETSQLNAME("AIC")+" WHERE D_E_L_E_T_ = '' "
				If chkfile("_AUX_TOLE")
					dbSelectArea("_AUX_TOLE")
					dbCloseArea()
				EndIf
				TCQUERY CqUERY ALIAS "_AUX_TOLE" NEW
				AIC->AIC_CODIGO := IIF(ALLTRIM(_AUX_TOLE->NCODIGO)="","000001",        STRZERO(VAL(SOMA1(_AUX_TOLE->NCODIGO)),6)    )
	
				//AIC->AIC_CODIGO 	:= GETSX8NUM("AIC")
				AIC->AIC_FORNEC 	:= M->AIA_CODFOR
				AIC->AIC_LOJA		:= M->AIA_LOJFOR
				AIC->AIC_PRODUT 	:= _TRAB->AIB_CODPRO
				AIC->AIC_PPRECO 	:= 0
				MSUNLOCK()
			END IF
			
			_TRAB->(DBSKIP())
	END DO
ELSE // EXCLUSAO

	// DELETANDO A TABELA (SA5 AMARRACAO PRODUTO X FORNECEDOR) PARA INCLUIR OS REGISTROS INCLUIDOS / ALTERADOS NA TABELA DE PRECO
	CSQL := "UPDATE "+RETSQLNAME("SA5")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " + ENTER
	CSQL += "FROM "+RETSQLNAME("SA5")+" " + ENTER
	CSQL += "WHERE	A5_FORNECE	= '"+M->AIA_CODFOR+"' AND  " + ENTER
	CSQL += "		A5_LOJA		= '"+M->AIA_LOJFOR+"' AND " + ENTER
	CSQL += "		A5_CODTAB	= '"+M->AIA_CODTAB+"' AND " + ENTER
	CSQL += "		D_E_L_E_T_ = ''	 " + ENTER
	//TCSQLEXEC(CSQL)

END IF
       */
RestArea(aArea)

   
RETURN()