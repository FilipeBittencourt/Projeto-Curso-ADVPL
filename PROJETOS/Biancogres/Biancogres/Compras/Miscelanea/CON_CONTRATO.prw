#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CON_CONTRATO     ºAutor  ³ MADALENO   º Data ³  07/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ROTINA PAR EXIBIR NA TELA O RESUMO DO CONTRATO NO COMPRAS. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION CON_CONTRATO()
PRIVATE SQL := ""
PRIVATE ENTER := CHR(13) + CHR(10)

SetPrvt("oDlg1","oGrp1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oGrp2","oSay9")
SetPrvt("oSay13","oSay14","oGrp3","oSay11","oSay15")

CC_PEDIDO := ALLTRIM(SCR->CR_NUM)
DbSelectArea("SC7")
DbSetOrder(1)
DbSeek(xFilial("SC7")+CC_PEDIDO)

IF SUBSTRING(SC7->C7_CLVL,1,1) == '8' .OR. ALLTRIM(SC7->C7_CLVL) == '2130' .OR. ALLTRIM(SC7->C7_CLVL) == '1045' .OR. ALLTRIM(SC7->C7_CLVL) == '3145' .OR. ALLTRIM(SC7->C7_CLVL) == '3184' .OR. ALLTRIM(SC7->C7_CLVL) == '3185' .OR. ALLTRIM(SC7->C7_CLVL) == '4011'	// BUSCANDO O CODIGO DO CONTRATO
	CSQL := "SELECT C7_YCONTR FROM "+RETSQLNAME("SC7")+" WHERE C7_NUM = '"+CC_PEDIDO+"' AND D_E_L_E_T_ = '' AND C7_CLVL = '"+SC7->C7_CLVL+"' "
	IF CHKFILE("_PEDI")
		DBSELECTAREA("_PEDI")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_PEDI" NEW
	IF _PEDI->(EOF())
		MSGBOX("Classe de Valor do pedido não é de investimento")
		RETURN
	END IF
	IF ALLTRIM(_PEDI->C7_YCONTR) = ""
		MSGBOX("CONTRATO NÃO PREENCHIDO")
		RETURN
	END IF

	//Tratamento dos contratos Genéricos	
	IF SUBSTR(_PEDI->C7_YCONTR,3,1) = '9'
		CC_CONTRATO := _PEDI->C7_YCONTR
	ELSE
		CC_CONTRATO := SUBSTR(_PEDI->C7_YCONTR,1,5)
	ENDIF
	
	// BUSCANDO O VALOR DO CONTRATO -- COLOCAR O CODIGO DO CONTRATO COMO PARAMETRO
	IF SUBSTR(_PEDI->C7_YCONTR,3,1) = '9'
		CSQL := "SELECT ISNULL(SUM(C3_TOTAL),0) AS CONTRATO FROM "+RETSQLNAME("SC3")+" WHERE C3_NUM = '"+CC_CONTRATO+"' AND "
	ELSE
		CSQL := "SELECT ISNULL(SUM(C3_TOTAL),0) AS CONTRATO FROM "+RETSQLNAME("SC3")+" WHERE SUBSTRING(C3_NUM,1,5) = '"+CC_CONTRATO+"' AND "
	ENDIF
	CSQL += "C3_YCLVL = '"+SC7->C7_CLVL+"' AND D_E_L_E_T_ = '' "
	IF CHKFILE("_CONTRATO")
		DBSELECTAREA("_CONTRATO")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_CONTRATO" NEW
	IF _CONTRATO->CONTRATO = 0
		RETURN
	ENDIF
	
	DbSelectArea("SC3")
	DbSetOrder(1)
	DbSeek(xFilial("SC3")+CC_CONTRATO)
	IF cEmpAnt <> '06'
		cDescr := ALLTRIM(SC3->C3_YOBS)
	ELSE
		cDescr := ALLTRIM(SC3->C3_OBS)
	ENDIF
	
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial("SA2")+SC3->C3_FORNECE+SC3->C3_LOJA)
	cNome := SA2->A2_COD+'-'+SA2->A2_LOJA+'-'+ALLTRIM(SA2->A2_NOME)
	
	// BUSCANDO O VALOR NA TABELA DE LIBERACAO PARA O TOTAL EM ABERTO -- COLOCAR O CODIGO DO PEDIDO COMO PARAMETRO
	CSQL := "SELECT ISNULL(SUM((C7_QUANT - C7_QUJE)*C7_PRECO),0) AS PEDIDOS_ABERTO  "
	CSQL += "FROM "+RETSQLNAME("SCR")+" SCR, "+RETSQLNAME("SC7")+" SC7, "+RETSQLNAME("SC3")+" SC3 "
	CSQL += "WHERE	CR_NUM <> '"+CC_PEDIDO+"' AND 		 "
	CSQL += "		C7_NUM = CR_NUM           AND "
	CSQL += "	  C3_NUM = C7_YCONTR        AND "
	CSQL += "	  C3_YCLVL  = C7_CLVL       AND "
	IF SUBSTR(_PEDI->C7_YCONTR,3,1) = '9'
		CSQL += "		C7_YCONTR = '"+CC_CONTRATO+"' AND "
	ELSE
		CSQL += "		SUBSTRING(C7_YCONTR,1,5) = '"+CC_CONTRATO+"' AND "
	ENDIF
	CSQL += "		CR_DATALIB <> ''          AND 		 "
	CSQL += "		C7_QUANT   <> C7_QUJE     AND 		 "
	CSQL += "		C7_RESIDUO <> 'S'         AND 		 "
	CSQL += "   C7_CONAPRO = 'L'          AND      "
	CSQL += "   C7_ENCER  <> 'E'          AND      "
	CSQL += "		SCR.D_E_L_E_T_ = ''       AND      "
	CSQL += "		SC3.D_E_L_E_T_ = ''       AND      "
	CSQL += "		SC7.D_E_L_E_T_ = ''            "
	IF CHKFILE("_ABERTO")
		DBSELECTAREA("_ABERTO")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_ABERTO" NEW
	_ABERTO->PEDIDOS_ABERTO
	
	// BUSCANDO OS TITULOS A PAGAR -- PARAMETRO CONTRATO
	IF SUBSTR(_PEDI->C7_YCONTR,3,1) = '9'
		CSQL := "SELECT ISNULL(SUM(E2_SALDO),0) AS PAGAR FROM "+RETSQLNAME("SE2")+" WHERE E2_YCONTR = '"+CC_CONTRATO+"' AND E2_SALDO > 0 AND E2_TIPO <> 'PA' AND "
	ELSE
		CSQL := "SELECT ISNULL(SUM(E2_SALDO),0) AS PAGAR FROM "+RETSQLNAME("SE2")+" WHERE SUBSTRING(E2_YCONTR,1,5) = '"+CC_CONTRATO+"' AND E2_SALDO > 0 AND E2_TIPO <> 'PA' AND "
	ENDIF
	CSQL += "E2_CLVLDB = '"+SC7->C7_CLVL+"' AND D_E_L_E_T_ = '' "
	IF CHKFILE("_PAGAR")
		DBSELECTAREA("_PAGAR")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_PAGAR" NEW
	
	// BUSCANDO OS TITULOS A PAGOS -- PARAMETRO CONTRATO
	CSQL := "SELECT ISNULL(SUM(E5_VALOR),0) AS PAGOS "
	CSQL += "FROM "+RETSQLNAME("SE5")+" "
	IF SUBSTR(_PEDI->C7_YCONTR,3,1) = '9'
		CSQL += "WHERE E5_YCONTR = '"+CC_CONTRATO+"' "
	ELSE
		CSQL += "WHERE SUBSTRING(E5_YCONTR,1,5) = '"+CC_CONTRATO+"' "
	ENDIF
	CSQL += "AND E5_TIPODOC IN ('BA','CP','VL') "
	CSQL += "AND E5_MOTBX NOT IN ('FAT','DES') "
	CSQL += "AND E5_SITUACA = 'C' "
	CSQL += "AND E5_CLVLDB = '"+SC7->C7_CLVL+"' "
	CSQL += "AND E5_RECPAG = 'P' "
	CSQL += "AND E5_TIPO <> 'PA' "
	CSQL += "AND D_E_L_E_T_ = '' "
	
	IF CHKFILE("_PAGOS")
		DBSELECTAREA("_PAGOS")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_PAGOS" NEW
	
	// BUSCANDO O PEDIDO ATUAL -- PARAMETRO CONTRATO
	CSQL := "SELECT ISNULL(SUM((C7_QUANT-C7_QUJE)*C7_PRECO),0) AS PC_ATUAL FROM "+RETSQLNAME("SC7")+" WHERE C7_NUM = '"+CC_PEDIDO+"' AND D_E_L_E_T_ = '' "
	IF CHKFILE("_PC_ATUAL")
		DBSELECTAREA("_PC_ATUAL")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_PC_ATUAL" NEW
	
	// BUSCANDO OS TITULOS
	IF SUBSTR(_PEDI->C7_YCONTR,3,1) = '9'
		CSQL := "SELECT ISNULL(SUM(E2_VALOR),0) AS PA FROM "+RETSQLNAME("SE2")+" WHERE E2_YCONTR = '"+CC_CONTRATO+"' AND E2_SALDO > 0 AND E2_TIPO = 'PA' AND "
	ELSE
		CSQL := "SELECT ISNULL(SUM(E2_VALOR),0) AS PA FROM "+RETSQLNAME("SE2")+" WHERE SUBSTRING(E2_YCONTR,1,5) = '"+CC_CONTRATO+"' AND E2_SALDO > 0 AND E2_TIPO = 'PA' AND "
	ENDIF
	CSQL += "E2_CLVLDB = '"+SC7->C7_CLVL+"' AND D_E_L_E_T_ = '' "
	IF CHKFILE("_PA")
		DBSELECTAREA("_PA")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_PA" NEW
	
	SALDO_LIBERAR := _CONTRATO->CONTRATO - _ABERTO->PEDIDOS_ABERTO - _PAGAR->PAGAR - _PAGOS->PAGOS
	
	oDlg1      := MSDialog():New( 095,232,450,805,"INFORMAÇÕES DO CONTRATO",,,.F.,,,,,,.T.,,,.T. )
	
	oGrp1      := TGroup():New( 008,008,050,276,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1      := TSay():New( 016,012,{||" Número do Contrato: "+CC_CONTRATO},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay2      := TSay():New( 028,012,{||" Descrição: "+CDESCR},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,210,008)
	oSay3      := TSay():New( 040,012,{||" Fornecedor: "+CNOME},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
	
	oGrp2      := TGroup():New( 050,008,100,276,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay4      := TSay():New( 056,012,{||" Valor do Contrato:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay5      := TSay():New( 068,012,{||" Pedidos em Aberto:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay6      := TSay():New( 080,012,{||" Titulos a Pagar:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay7      := TSay():New( 092,012,{||" Titulos Pagos:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	
	oSay8      := TSay():New( 056,096,{||  Transform( _CONTRATO->CONTRATO ,"@E 999,999,999.99")  },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay9      := TSay():New( 068,096,{||  Transform( _ABERTO->PEDIDOS_ABERTO ,"@E 999,999,999.99")  },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay10     := TSay():New( 080,096,{||  Transform( _PAGAR->PAGAR ,"@E 999,999,999.99")  },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay11     := TSay():New( 092,096,{||  Transform( _PAGOS->PAGOS ,"@E 999,999,999.99")  },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	
	oGrp3      := TGroup():New( 100,008,140,276,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay12     := TSay():New( 110,012,{||" Sal.do a Liberar:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay13     := TSay():New( 122,012,{||" Valor do PC Atual:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	
	oSay16     := TSay():New( 110,096,{||  Transform( SALDO_LIBERAR ,"@E 999,999,999.99")  },oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay17     := TSay():New( 122,096,{||  Transform( _PC_ATUAL->PC_ATUAL ,"@E 999,999,999.99")  },oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	
	oGrp4      := TGroup():New( 140,008,160,276,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay14     := TSay():New( 146,012,{||" PAs  não Compensados:"},oGrp4,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	oSay18     := TSay():New( 146,096,{|| Transform( _PA->PA ,"@E 999,999,999.99")  },oGrp4,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
	
	oDlg1:Activate(,,,.T.)
ENDIF

Return