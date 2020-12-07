#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
²±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²
²±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±²
²±±ºPrograma  ³ VER_R1_R2º Autor ³ MADALENO           º Data ³  09/12/08   º±±²
²±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±²
²±±ºDesc.     ³ ROTINA PARA IMPORTAR TODOS OS ARQUIVOS TXT                 º±±²
²±±º          ³                                                            º±±²
²±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±²
²±±ºUso       ³ AP7                                                        º±±²
²±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±²
²±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²    
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION VER_R1_R2(NUM_PED_PAI)
PRIVATE ENTER := CHR(13) + CHR(10)
PRIVATE CSQL := ""

IF ALLTRIM(NUM_PED_PAI) = ""
	ALERT("PEDIDO PAI NÃO INFORMADO")
	RETURN(.F.)
END IF
// BUSCANDO O VALOR DO R1 FATURADO.
CSQL := "SELECT ISNULL(SUM(D2_QUANT),0) AS QUANT 											" + ENTER
CSQL += "FROM "+RETSQLNAME("SD2")+" SD2																" + ENTER
CSQL += "WHERE	SD2.D2_PEDIDO 	= '"+NUM_PED_PAI+"' AND -- PEDIDO PAI	" + ENTER
CSQL += "				SD2.D2_COD 			= '"+_SC9->C9_PRODUTO+"' AND 					" + ENTER
CSQL += "				SD2.D_E_L_E_T_	= '' 																	" + ENTER
IF CHKFILE("_R1")
	DBSELECTAREA("_R1")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_R1" NEW
IF _R1->QUANT = 0
	ALERT("O PEDIDO :" + NUM_PED_PAI + " PAI AINDA NÃO FOI FATURADO")
	RETURN(.F.)
END IF
NTOTAL_R1 := _R1->QUANT


// BUSCANDO A QUANTIDADE FATURADA DE R2 PELO PEDIDO PAI
CSQL := "SELECT ISNULL(SUM(D2_QUANT),0) AS QUANT 												" + ENTER
CSQL += "FROM "+RETSQLNAME("SD2")+" SD2, "+RETSQLNAME("SC5")+" SC5 		" + ENTER
CSQL += "WHERE	SD2.D2_PEDIDO		= SC5.C5_NUM 				AND 								" + ENTER
CSQL += "				SC5.C5_YPEDPAI 	= '"+NUM_PED_PAI+"'	AND -- PEDIDO PAI  	" + ENTER
CSQL += "				SD2.D2_COD 			= '"+_SC9->C9_PRODUTO+"'	AND						" + ENTER
CSQL += "				C5_YSUBTP 			IN ('R2','R3') 	AND " + ENTER
CSQL += "				SD2.D_E_L_E_T_	= ''						AND	" + ENTER
CSQL += "				SC5.D_E_L_E_T_ 	= '' 								" + ENTER
IF CHKFILE("_R2")
	DBSELECTAREA("_R2")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_R2" NEW
NTOTAL_R2 := _SC9->C9_QTDLIB + _R2->QUANT

IF NTOTAL_R2 > NTOTAL_R1
	ALERT("PEDIDO MAIOR QUE A QUANTIDADE DISPONÍVEL NO PEDIDO PAI: " + NUM_PED_PAI + " ")
	RETURN(.F.)
END IF

RETURN(.T.)