#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ A_COBRANCA       ³ MADALENO           º DATA ³  29/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ PREENCHE O CAMPO CONTATO DO TELECONRANCA                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ AP 10                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION A_COBRANCA()
PRIVATE ENTER := CHR(13) + CHR(10)
PRIVATE CSQL := ""

CSQL := " SELECT LTRIM(ISNULL(MAX(U5_FONE),'')) AS TEL, ISNULL(MAX(U5_CODCONT),'') AS CODIGO  " + ENTER
CSQL += " FROM ACF010 ACF, SU5010 SU5 " + ENTER
CSQL += " WHERE	ACF_CLIENT = '"+M->ACF_CLIENT+"' AND " + ENTER
CSQL += " 		ACF_CODCON = U5_CODCONT AND " + ENTER
CSQL += " 		ACF.D_E_L_E_T_ = '' AND " + ENTER
CSQL += " 		SU5.D_E_L_E_T_ = ''  " + ENTER

IF CHKFILE("_TRAB")
	DBSELECTAREA("_TRAB")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_TRAB" NEW

IF ALLTRIM(_TRAB->TEL) <> ""
	ALERT("TELEFONE PARA CONTATO: " + _TRAB->TEL )
END IF
IF ALLTRIM(_TRAB->CODIGO) <> ""
	M->ACF_CODCONT := _TRAB->CODIGO
END IF

RETURN(_TRAB->CODIGO)
