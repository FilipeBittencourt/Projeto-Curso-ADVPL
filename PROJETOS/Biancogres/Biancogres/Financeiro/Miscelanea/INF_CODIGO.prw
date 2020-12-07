#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"   
#INCLUDE "PROTHEUS.CH" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ INF_CODIGO       ºAutor  ³ MADALENO   º Data ³  28/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ROTINA PARA INFORMAR O CODIGO DE BARRAS OU A LINHA DIGITA. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION INF_CODIGO()
PRIVATE ENTER := CHR(13)+CHR(10)
PRIVATE CSQL := ""
SetPrvt("oDlg99","oGrp1","oSay1","oSay2","oGet1","oGet2","oSBtn2","oSBtn1")

DbSelectArea("SE2")
cArqSA1 := Alias()
cIndSA1 := IndexOrd()
cRegSA1 := Recno()
aAreaAnt := GetArea()

CSQL = "SELECT E2_YLINDIG, E2_CODBAR  FROM "+RETSQLNAME("SE2")+" " + ENTER
CSQL += "WHERE	E2_FILIAL	= '"+SE2->E2_FILIAL+"' AND " + ENTER
CSQL += "		E2_PREFIXO	= '"+SE2->E2_PREFIXO+"' AND  " + ENTER
CSQL += "		E2_NUM		= '"+SE2->E2_NUM+"' AND  " + ENTER
CSQL += "		E2_PARCELA	= '"+SE2->E2_PARCELA+"' AND  " + ENTER
CSQL += "		E2_TIPO		= '"+SE2->E2_TIPO+"' AND  " + ENTER
CSQL += "		E2_FORNECE	= '"+SE2->E2_FORNECE+"' AND  " + ENTER
CSQL += "		E2_LOJA		= '"+SE2->E2_LOJA+"' AND  " + ENTER
CSQL += "		D_E_L_E_T_	= ''
IF CHKFILE("__TRAB")
	DBSELECTAREA("__TRAB")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "__TRAB" NEW
IF __TRAB->(EOF())
	Private cCcodigo   := Space(60)
	Private cLinha     := Space(60)
ELSE
	Private cCcodigo   := __TRAB->E2_CODBAR
	Private cLinha     := __TRAB->E2_YLINDIG
END IF

oDlg99      := MSDialog():New( 095,232,305,671,"ALTERAÇÃO",,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 004,004,096,212,"Alteração do Titulo",oDlg99,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1      := TSay():New( 020,008,{||"Código de Barras"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,108,008)
oSay2      := TSay():New( 048,008,{||"Linha Digitável"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)
oGet1      := TGet():New( 028,008,{|u| If(PCount()>0,cCcodigo:=u,cCcodigo)},oGrp1,196,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cCcodigo",,)
oGet2      := TGet():New( 056,008,{|u| If(PCount()>0,cLinha:=u,cLinha)},oGrp1,196,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cLinha",,)
oSBtn1     := SButton():New( 080,008,1,{|| SSF_GRAVA() },oGrp1,,"", )
oSBtn2     := SButton():New( 080,180,2,{|| oDlg99:End() },oGrp1,,"", )
oDlg99:Activate(,,,.T.)

RestArea(aAreaAnt)

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ INF_CODIGO       ºAutor  ³ MADALENO   º Data ³  28/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ROTINA PARA INFORMAR O CODIGO DE BARRAS OU A LINHA DIGITA. º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION SSF_GRAVA()
PRIVATE ENTER := CHR(13)+CHR(10)
PRIVATE CSQL := ""

oDlg99:End()

//CSQL = "SELECT E2_YLINDIG, E2_CODBAR  FROM "+RETSQLNAME("SE2")+" " + ENTER
CSQL := "UPDATE "+RETSQLNAME("SE2")+" SET E2_YLINDIG = '"+cLinha+"' , E2_CODBAR  = '"+cCcodigo+"' " +ENTER
CSQL += "WHERE	E2_FILIAL	= '"+SE2->E2_FILIAL+"' AND " + ENTER
CSQL += "		E2_PREFIXO	= '"+SE2->E2_PREFIXO+"' AND  " + ENTER
CSQL += "		E2_NUM		= '"+SE2->E2_NUM+"' AND  " + ENTER
CSQL += "		E2_PARCELA	= '"+SE2->E2_PARCELA+"' AND  " + ENTER
CSQL += "		E2_TIPO		= '"+SE2->E2_TIPO+"' AND  " + ENTER
CSQL += "		E2_FORNECE	= '"+SE2->E2_FORNECE+"' AND  " + ENTER
CSQL += "		E2_LOJA		= '"+SE2->E2_LOJA+"' AND  " + ENTER
CSQL += "		D_E_L_E_T_	= ''
CSQL += ""
TCSQLExec(CSQL)

RETURN