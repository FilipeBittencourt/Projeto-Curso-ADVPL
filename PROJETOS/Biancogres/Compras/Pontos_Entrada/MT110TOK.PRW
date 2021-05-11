#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ MT110LOK ³ Autor ³ Wanisay William       ³ Data ³ 19.04.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Validar C.Custo Na Solicitacao Compra                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDMAKE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MT110TOK()
	Local lret     := .T.
	Local CSQL     := ""
	Local sPOS     := ""
	Local wContrat := ""
	Local wItemCta := ""
	Local	wProd		 := ""
	Local wLocal	 := ""
	Local lConta	 := .F.
	Local ni

	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()
	wAlias  := Alias()

	For  ni := 1 to Len(aCols)

		If !GdDeleted(ni)

			wProd    	:= Gdfieldget("C1_PRODUTO",ni)
			wLocal	 	:= Gdfieldget("C1_LOCAL",ni)
			wCLVL    	:= Gdfieldget("C1_CLVL",ni)
			wConta   	:= Gdfieldget("C1_CONTA",ni)
			wItemCta	:= Gdfieldget("C1_ITEMCTA",ni)
			wSI     	:= Gdfieldget("C1_YSI",ni)
			wContrat 	:= Gdfieldget("C1_YCONTR",ni)
			cSubitem 	:= Gdfieldget("C1_YSUBITE",ni)

			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+wProd,.F.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa validacao referente Almoxarifado Comum ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Executa funcao de validacao com retorno imediato
			If !U_fValProdComum(wProd,wLocal,"MT110TOK","C") //Paramentros da Funcao Produto/Almoxarifado/NomeProgroma/TipoMovimento(C=Compra/T=Transferencia)
				lRet := .F.
				Return(lRet)
			EndIF

			If !Empty(wConta) .And. Substr(wConta,1,1) == '6' .And. !Empty(wCLVL)
				CTH->(DbSetOrder(1))
				If CTH->(DbSeek(xFilial("CTH")+wCLVL)) .And. CTH->CTH_YATRIB == 'C' .And. Gdfieldget("C1_YAPLIC",ni) $ " _0"
					MsgAlert("O campo Aplicação devera ser preenchido para essa Conta e Classe de Valor! ", "ATENCAO")
					AutoGrLog("O campo Aplicação devera ser preenchido para essa Conta e Classe de Valor! ")
					DbSelectArea(cArq)
					DbSetOrder(cInd)
					DbGoTo(cReg)
					Return .F.
				EndIf

			EndIf

			If !Empty(wConta) .And. !Empty(wCLVL)
				If U_BFG81VCL(wCLVL) .And. U_BFG81VCO(wCONTA)
					If Empty(GdFieldGet("C1_YDRIVER",ni))
						MsgStop("A conta e a classe de valor selecionadas exigem que o driver seja informado!")
						AutoGrLog("A conta e a classe de valor selecionadas exigem que o driver seja informado!")
						Return .F.
						DbSelectArea(cArq)
						DbSetOrder(cInd)
						DbGoTo(cReg)
					EndIF
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa validacao do Item Contabil de Marketing ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lConta := .F.
			If Substr(wConta,1,5) == "31401" .OR. Substr(wConta,1,5) == "31406"
				IF ALLTRIM(wConta) <> '31401017' 
					lConta := .T.                    
				ENDIF
			/*
			Else
				//Verifica se o produto possui conta de Investimento (31401)
				If (Substr(SB1->B1_CONTA,1,5) == "31401" .Or. ;
				Substr(SB1->B1_CONTA,1,5) == "31406" .Or. ;
				Substr(SB1->B1_YCTARES,1,5) == "31401" .Or. ;
				Substr(SB1->B1_YCTARES,1,5) == "31406" .Or. ;
				Substr(SB1->B1_YCTRIND,1,5) == "31401" .Or. ;
				Substr(SB1->B1_YCTRIND,1,5) == "31406" .Or. ;
				Substr(SB1->B1_YCTRADM,1,5) == "31401" .Or. ;
				Substr(SB1->B1_YCTRADM,1,5) == "31406") .And. !lConta
					IF ALLTRIM(SB1->B1_CONTA) <> '31401017' .AND. ALLTRIM(SB1->B1_YCTARES) <> '31401017' .AND. ALLTRIM(SB1->B1_YCTRIND) <> '31401017' .AND. ALLTRIM(SB1->B1_YCTRADM) <> '31401017'						
						lConta := .T.
					ENDIF
				EndIf
			*/
			EndIf
			//Funcao para Validar o Item Contabil
			lRet := U_fValItemCta("XX", lConta, wCLVL, wItemCta, cSubitem)
			IF lRet == .F.
				Return(lRet)
			ENDIF
			IF SUBSTR(ALLTRIM(wItemCta),1,1) == 'I' .AND. EMPTY(wSI)
				MsgBox("Favor informar o cliente para este Item Contábil","Atencao","ALERT")
				AutoGrLog("Favor informar o cliente para este Item Contábil")
				lRet := .F.
				Return(lret)
			ENDIF

			IF (SUBSTR(wCLVL,1,1) == '8' .OR. ALLTRIM(wCLVL) == '2130' .OR. ALLTRIM(wCLVL) == '1045' .OR. ALLTRIM(wCLVL) == '3145' .OR. ALLTRIM(wCLVL) == '3184' .OR. ALLTRIM(wCLVL) == '3185') .AND. EMPTY(wContrat)
				//MsgAlert("O campo Contrato devera ser preenchido quando a Classe de Valor iniciar com 8.")
				MsgAlert("O campo Contrato devera ser preenchido quando a Classe de Valor for '" + Alltrim(wCLVL) + "'.", "ATENCAO")
				AutoGrLog("O campo Contrato devera ser preenchido quando a Classe de Valor for '" + Alltrim(wCLVL) + "'.")
				lRet := .F.
			ENDIF

			// Valida Subitem de projeto
			If !U_BIAF160(wCLVL, wItemCta, cSubitem)
	
				MsgBox("A classe de valor e o item de selecionados, exige o preenchimento do Subitem de Projeto!", "MT110TOK", "STOP")
				
				AutoGrLog("MT110TOK ==> A classe de valor e o item de selecionados, exige o preenchimento do Subitem de Projeto!")
				
				lRet := .F.
							
			EndIf
			

			If !lRet
				Return(lRet)
			EndIf

			IF !EMPTY(wContrat)
				DbSelectArea("SC3")
				DbSetOrder(1)
				DbSeek(xFilial("SC3")+wContrat)
				lPassei := .F.

				WHILE !EOF() .AND. SC3->C3_NUM == wContrat
					IF ALLTRIM(wCLVL) == ALLTRIM(SC3->C3_YCLVL)
						lPassei := .T.
						IF SC3->C3_MSBLQL == '1' .and. cCtrBloq <> 2 							
							cCtrBloq := 1
				        ELSE
				           cCtrBloq := 2
						ENDIF
					ENDIF

					DbSelectArea("SC3")
					DbSkip()
				END
				
				IF cCtrBloq == 1
				   MsgAlert("[MT110TOK] Este contrato está bloqueado.", "ATENCAO")
				   AutoGrLog("[MT110TOK]Este contrato está bloqueado.")
				   cCtrBloq := 0
				   Return .F.
				ENDIF

				IF !lPassei
					MsgAlert("A Classe de Valor desta SC deverá ser igual a Classe de Valor do Contrato informado.", "ATENCAO")
					AutoGrLog("A Classe de Valor desta SC deverá ser igual a Classe de Valor do Contrato informado.")
					Return .F.
				ENDIF
			EndIf
		EndIf
	Next

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

Return(lret)