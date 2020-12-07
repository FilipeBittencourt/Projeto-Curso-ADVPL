#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT094LOK  ºAutor  ³Microsiga           º Data ³  07/30/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compras                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT094LOK()
Local lRetorno := .T. 
Local nLinha := 0 
Local nSoma := 0
Local aAreaSCR	:= SCR->(GetArea())
Local aAreaSC7	:= SC7->(GetArea())
Local aAreaSC3	:= SC3->(GetArea())
Local cArq		:= ""
Local cInd		:= 0
Local cReg		:= 0
Local oContrato := Nil

//Armazena area de Trabalho
cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

PRIVATE SQL := ""
PRIVATE ENTER := CHR(13) + CHR(10)

SetPrvt("oDlg1","oGrp1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oGrp2","oSay9")
SetPrvt("oSay13","oSay14","oGrp3","oSay11","oSay15")

CC_PEDIDO := ALLTRIM(SCR->CR_NUM)
DbSelectArea("SC7")
DbSetOrder(1)
DbSeek(xFilial("SC7")+CC_PEDIDO)
IF SUBSTRING(SC7->C7_CLVL,1,1) == '8' .OR. ALLTRIM(SC7->C7_CLVL) == '2130' .OR. ALLTRIM(SC7->C7_CLVL) == '1045' .OR. ALLTRIM(SC7->C7_CLVL) == '3145' .OR. ALLTRIM(SC7->C7_CLVL) == '3184' .OR. ALLTRIM(SC7->C7_CLVL) == '3185' .OR. ALLTRIM(SC7->C7_CLVL) == '4011'
	CC_PEDIDO := ALLTRIM(SCR->CR_NUM)
	//CSQL := "SELECT C7_YCONTR FROM "+RETSQLNAME("SC7")+" WHERE C7_NUM = '"+CC_PEDIDO+"' AND D_E_L_E_T_ = '' AND SUBSTRING(C7_CLVL,1,1) = '8' "
	CSQL := "SELECT C7_YCONTR FROM "+RETSQLNAME("SC7")+" WHERE C7_NUM = '"+CC_PEDIDO+"' AND D_E_L_E_T_ = '' AND C7_CLVL = '"+SC7->C7_CLVL+"' "
	IF CHKFILE("_PEDI")
		DBSELECTAREA("_PEDI")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_PEDI" NEW
	
	IF _PEDI->(EOF())
		MSGBOX("Classe de Valor do pedido não é de investimento", "MT094LOK","STOP")
		RETURN
	END IF
	
	IF ALLTRIM(_PEDI->C7_YCONTR) = ""
		MSGBOX("CONTRATO NÃO PREENCHIDO","MT094LOK","STOP")
		RETURN
	END IF
	
	//Tratamento dos contratos Genéricos
	IF SUBSTR(_PEDI->C7_YCONTR,3,1) = '9'
		CC_CONTRATO := _PEDI->C7_YCONTR
	ELSE
		CC_CONTRATO := SUBSTR(_PEDI->C7_YCONTR,1,5)
	ENDIF
	
	If !Empty(CC_CONTRATO)
		
		oContrato := TContratoParceria():New()
		
		oContrato:cNumero := _PEDI->C7_YCONTR
		
		If oContrato:Validate(CC_CONTRATO)
		
			DbSelectArea("SC3")
			DbSetOrder(1)
			If DbSeek(xFilial("SC3") + CC_CONTRATO)
			
				If cEmpAnt <> '06'
					
					cDescr := ALLTRIM(SC3->C3_YOBS)
					
				Else
					
					cDescr := ALLTRIM(SC3->C3_OBS)
					
				EndIf
				
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2") + SC3->C3_FORNECE + SC3->C3_LOJA)
				cNome := SA2->A2_COD + '-' + SA2->A2_LOJA +'-' + ALLTRIM(SA2->A2_NOME)				
				
				oContrato:Get()
				
				If oContrato:nValor == 0
					
					lRetorno := .F.
					
				Else
				
					SALDO_LIBERAR := oContrato:nSaldo
					PC_ATUAL := SCR->CR_TOTAL
							
					oDlg1      := MSDialog():New( 095,232,450,805,"INFORMAÇÕES DO CONTRATO",,,.F.,,,,,,.T.,,,.T. )   
					
					oGrp1      := TGroup():New( 008,008,050,276,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
					nLinha := 16
					nSoma := 12
					oSay1      := TSay():New( nLinha,012,{||" Número do Contrato: "+CC_CONTRATO},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay2      := TSay():New( nLinha + nSoma,012,{||" Descrição: "+CDESCR},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,210,008)
					oSay3      := TSay():New( nLinha + nSoma*2,012,{||" Fornecedor: "+CNOME},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
					
					oGrp2      := TGroup():New( 050,008,110,276,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
					oSay4      := TSay():New( nLinha + nSoma*3,012,{||" Valor do Contrato:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay5      := TSay():New( nLinha + nSoma*4,012,{||" Pedidos em Aberto:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay6      := TSay():New( nLinha + nSoma*5,012,{||" Titulos a Pagar:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay7      := TSay():New( nLinha + nSoma*6,012,{||" Titulos Pagos:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay8      := TSay():New( nLinha + nSoma*7,012,{||" NDF:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)		
					
					oSay9      := TSay():New( nLinha + nSoma*3,096,{||  Transform( oContrato:nValor ,"@E 999,999,999.99")  },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay10     := TSay():New( nLinha + nSoma*4,096,{||  Transform( oContrato:nPedAbe,"@E 999,999,999.99")  },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay11     := TSay():New( nLinha + nSoma*5,096,{||  Transform( oContrato:nTitAbe ,"@E 999,999,999.99")  },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay12     := TSay():New( nLinha + nSoma*6,096,{||  Transform( oContrato:nTitPag ,"@E 999,999,999.99")  },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay13     := TSay():New( nLinha + nSoma*7,096,{||  Transform( oContrato:nTitDev,"@E 999,999,999.99")  },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)		
					
					oGrp3      := TGroup():New( 110,008,140,276,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
					oSay15     := TSay():New( nLinha + nSoma*8,012,{||" Sal.do a Liberar:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay16     := TSay():New( nLinha + nSoma*9,012,{||" Valor do PC Atual:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					
					oSay19     := TSay():New( nLinha + nSoma*8,096,{||  Transform( SALDO_LIBERAR ,"@E 999,999,999.99")  },oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay20     := TSay():New( nLinha + nSoma*9,096,{||  Transform( PC_ATUAL ,"@E 999,999,999.99")  },oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					
					oGrp4      := TGroup():New( 140,008,160,276,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
					oSay17     := TSay():New( nLinha + nSoma*11,012,{||" PAs  não Compensados:"},oGrp4,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
					oSay21     := TSay():New( nLinha + nSoma*11,096,{|| Transform( oContrato:nTitAnt ,"@E 999,999,999.99")  },oGrp4,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)		
					
					oDlg1:Activate(,,,.T.)
					
					If (SALDO_LIBERAR - PC_ATUAL) < -1
						
						lRetorno := .F.
						
						MSGBOX("Este pedido não poderá ser liberado pois o valor limite do contrato será ultrapassado!","MT094LOK","STOP")
						
					EndIf				
					
				EndIf

			EndIf
		
		Else
		
			lRetorno := .F.
			
		EndIf
		
	EndIf
		
EndIf

RestArea(aAreaSC7)
RestArea(aAreaSCR)
RestArea(aAreaSC3)

//Volta area de Trabalho
DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(lRetorno)