#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOPCONN.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUN‡…O    ³ GRUP_SEG	  ³ AUTOR ³ BRUNO MADALENO        ³ DATA ³ 03/06/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRI‡„O ³ GATILHO NO CLIENTE PARA GRAVACAO DO GRUPO NO ORCAMENTO       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ FATURAMENTO                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION GRUP_SEG()

CSQL := "SELECT ZZG_GRUPO, A1_SATIV1 "
CSQL += "FROM "+RETSQLNAME("SA1")+" SA1, "+RETSQLNAME("ZZG")+" ZZG "
CSQL += "WHERE	ZZG_SEG =  A1_SATIV1 AND "
CSQL += "		A1_COD = '"+M->CJ_CLIENTE+"' AND "
CSQL += "		A1_LOJA = '"+M->CJ_LOJA+"' AND "
CSQL += "		SA1.D_E_L_E_T_ = '' AND "
CSQL += "		ZZG.D_E_L_E_T_ = ''  "
IF CHKFILE("_TRAB")
	DBSELECTAREA("_TRAB")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_TRAB" NEW
IF _TRAB->(EOF())
	GRUP_SEG := "" 
ELSE
	GRUP_SEG := _TRAB->ZZG_GRUPO
END IF


RETURN(	GRUP_SEG )