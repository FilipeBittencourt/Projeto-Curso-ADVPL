#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ CON_SALDO        ³ MADALENO           º DATA ³  29/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ CONSULTA SALDO DO PRODUTO NAS EMPRESAS                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ AP 10                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION CON_SALDO()
Private cProduto   := Space(15)
SetPrvt("oFont1","oFont2","oDlg1","oSay1","oSay2","oGet1","oBtn1","oGrp1","oSay3")

oFont1     := TFont():New( "MS Sans Serif",0,-16,,.T.,0,,700,.F.,.F.,,,,,, )
oFont2     := TFont():New( "MS Sans Serif",0,-19,,.T.,0,,700,.F.,.F.,,,,,, )
oDlg1      := MSDialog():New( 095,232,341,658,"Consulta Saldo",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 012,044,{||"Consulta saldo nas empresas"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,124,012)
oSay2      := TSay():New( 036,068,{||"Cod. Produto"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
oGet1      := TGet():New( 044,068,{|u| If(PCount()>0,cProduto:=u,cProduto)},oDlg1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SB1","cProduto",,)

oBtn1      := TButton():New( 044,132,"CONSULTA",oDlg1,{|| CONSULT() },040,008,,,,.T.,,"",,,,.F. )

oGrp1      := TGroup():New( 072,012,104,104,"BIANCOGRES",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay3      := TSay():New( 084,020,{||"R$ 5.2541,25"},oGrp1,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,076,012)
oGrp2      := TGroup():New( 072,108,104,200,"INCESA",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay4      := TSay():New( 084,116,{||"R$ 5.2541,25"},oGrp2,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,076,012)

oGrp1:LVISIBLECONTROL := .F.
oSay3:LVISIBLECONTROL := .F.
oGrp2:LVISIBLECONTROL := .F.
oSay4:LVISIBLECONTROL := .F.

oDlg1:Activate(,,,.T.)
RETURN 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ CONSULT          ³ MADALENO           º DATA ³  29/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ ROTINA PARA EXIBIR O SALDO EM TELA.                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION CONSULT()
PRIVATE CSQL := ""
PRIVATE ENTER := CHR(13) + CHR(10)

CSQL := "SELECT SUM(BIANCO) AS BIANCO, SUM(INCESA) AS INCESA " + ENTER
CSQL += "FROM  " + ENTER
CSQL += "		(SELECT ISNULL(SUM(B2_QATU),0) AS BIANCO, 0 AS INCESA  FROM SB2010 " + ENTER
CSQL += "		WHERE B2_COD = '"+cProduto+"' " + ENTER
CSQL += "		UNION ALL " + ENTER
CSQL += "		SELECT 0 AS BIANCO, ISNULL(SUM(B2_QATU),0) AS INCESA  FROM SB2050 " + ENTER
CSQL += "		WHERE B2_COD = '"+cProduto+"') AS SR " + ENTER
IF CHKFILE("_TRAB")
	DBSELECTAREA("_TRAB")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_TRAB" NEW

oGrp1:LVISIBLECONTROL := .T.
oSay3:LVISIBLECONTROL := .T.
oGrp2:LVISIBLECONTROL := .T.
oSay4:LVISIBLECONTROL := .T.
oSay3:CCAPTION := TRANSFORM(_TRAB->BIANCO	,"@E 999,999,999.99")				
oSay4:CCAPTION := TRANSFORM(_TRAB->INCESA	,"@E 999,999,999.99")						

RETURN