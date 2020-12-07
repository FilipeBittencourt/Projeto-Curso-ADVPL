#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ OBS_SOLI         ³ MADALENO           º DATA ³  29/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ GRAVA A OBSERVACAO NA SOLICITACAO DE COMPRA                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ AP 10                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION OBS_SOLI()

PRIVATE AAREA		:= GETAREA()


PRIVATE ASTRUCT := {}
PRIVATE LREFRESH := .T.
PRIVATE AHEADER := {}
PRIVATE ACOLS := {}

CSQL := " SELECT * FROM "+RETSQLNAME("SC1")+" WHERE C1_NUM = '"+SC1->C1_NUM+"' AND D_E_L_E_T_ = ''
IF CHKFILE("__TRAB")
	DBSELECTAREA("__TRAB")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "__TRAB" NEW
IF __TRAB->(EOF())
	RETURN
END IF

						
DEFINE DIALOG ODLG TITLE "PREENCHIMENTO OBSERVACAO" FROM 100,300 TO 500,1100 PIXEL


	AADD(AHEADER,{"R_E_C_N_O_"	,"R_E_C_N_O_"	,""	,6	,0,"","","C","","" })
	AADD(AHEADER,{"ITEM"				,"ITEM"				,""	,4	,0,"","","C","","" })
	AADD(AHEADER,{"PRODUTO"			,"PRODUTO"		,""	,10	,0,"","","C","","" })
	AADD(AHEADER,{"DESCRICAO"		,"DESCRICAO"	,""	,30	,0,"","","C","","" })
	AADD(AHEADER,{"OBS"					,"OBS"				,""	,100,0,"","","C","","" })



				
	AADD(ASTRUCT,{"R_E_C_N_O_"	,"C",6	,0})
	AADD(ASTRUCT,{"ITEM"				,"C",4	,0})
	AADD(ASTRUCT,{"PRODUTO"			,"C",10	,0})
	AADD(ASTRUCT,{"DESCRICAO"		,"C",30	,0})
	AADD(ASTRUCT,{"OBS"					,"C",100,0})


	IF CHKFILE("_TRB")
		DBSELECTAREA("_TRB")
		DBCLOSEAREA()
	ENDIF
	CCRIATRAB := CRIATRAB(ASTRUCT)
	DBUSEAREA (.T., __LOCALDRIVER, CCRIATRAB, "_TRB") 


	PREENCHE_ARQUIVO()
	OGETDB := MSGETDB():NEW(05,05,180,400,3,,,,.F.,{"R_E_C_N_O_","ITEM","PRODUTO","DESCRICAO","OBS"},1,.F.,,"_TRB",,,.F.,ODLG, .T., ,,)


	oTHButton := THButton():New(180,05,"CONFIRMA ALTERAÇÃO"	,ODLG,{|| __GRAVA() },55,10,,"CONFIRMA A ALTERAÇÃO DOS CAMPO")
	oTHButton := THButton():New(180,350,"CANCELA ALTERAÇÃO"	,ODLG,{|| ODLG:End() },55,10,,"CANCELA ALTERAÇÃO")
		
ACTIVATE DIALOG ODLG CENTERED 

RESTAREA(AAREA)
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³PREENCHE_ARQUIVO  ³ MADALENO           º DATA ³  22/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ FUNCAO PARA MONTAR O ARQUIVO COM OS HORARIOS               º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION PREENCHE_ARQUIVO()
PRIVATE CSQL := ""
PRIVATE ENTER := CHR(13) + CHR(10)


CSQL := " SELECT * FROM "+RETSQLNAME("SC1")+" WHERE C1_NUM = '"+SC1->C1_NUM+"' AND D_E_L_E_T_ = ''
IF CHKFILE("__TRAB")
	DBSELECTAREA("__TRAB")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "__TRAB" NEW

IF __TRAB->(EOF())
	RETURN
END IF

	
DO WHILE ! __TRAB->(EOF())
    RECLOCK("_TRB",.T.)
    
		_TRB->R_E_C_N_O_	= ALLTRIM(STR(__TRAB->R_E_C_N_O_))
    _TRB->ITEM				= __TRAB->C1_ITEM
    _TRB->PRODUTO 		= ALLTRIM(__TRAB->C1_PRODUTO)
    _TRB->DESCRICAO		= ALLTRIM(__TRAB->C1_DESCRI)
    _TRB->OBS					= ALLTRIM(__TRAB->C1_YOBS2)
        
	_TRB->(MSUNLOCK())	
	
	__TRAB->(DBSKIP())
END IF	

	
RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³__GRAVA   ³ Autor ³ J. Ricardo            ³ Data ³23/02/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ GRAVA AS ALTERAÇÕES REALIZADAS                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ _AJU_SP8                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC Function __GRAVA()

ODLG:End()

_TRB->(DbGoTop())
DO WHILE 	! _TRB->(EOF())
	CSQL := " UPDATE "+RETSQLNAME("SC1")+" SET C1_YOBS2 = '"+_TRB->OBS+"' "
	CSQL += " WHERE R_E_C_N_O_ = '"+_TRB->R_E_C_N_O_+"' "
	TCSQLEXEC(CSQL)
	_TRB->(DBSKIP())
END DO


RETURN