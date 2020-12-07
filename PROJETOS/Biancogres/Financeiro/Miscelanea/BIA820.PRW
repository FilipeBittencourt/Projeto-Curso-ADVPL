#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ BIA820		      ºAUTOR  ³ RANISSES A. CORONA º DATA ³  02/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ ACERTA O CAMPO VENCIMENTO REAL - E2_VENCREA.						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ FINANCEIRO                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION BIA820()

@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Refaz Vencimento Real "
@ 8,10 TO 84,222

@ 16,12 SAY "Esta rotina tem por finalidade: "
@ 24,12 SAY "Refazer a campo Vencimento Real - E2_VENCREA. "

@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)

ACTIVATE DIALOG oDlg5 CENTERED

RETURN()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama rotina que acerta o empenho       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function OkProc()
	Processa( {|| RunProc() } )
	Close(oDlg5)
Return()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina que realiza o acerto do Empenho  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RunProc()
PRIVATE CSQL	:= ""
PRIVATE ENTER	:= CHR(13)
PRIVATE lRet	:= .F.

lRet := MsgBox("Esta rotina irá refazer o campo Vencimento Real. Deseja continuar? ","Atencao","YesNo")

If lRet

	CSQL := " SELECT * FROM SE2070 WHERE E2_VENCREA = '20091231' ORDER BY R_E_C_N_O_	" + ENTER 
	//CSQL := " SELECT DATEDIFF(D,E2_VENCTO,E2_VENCREA) DIAS , E2_PREFIXO, E2_NUM, E2_PARCELA, E2_CLIENTE, E2_VENCTO, E2_VENCREA, E2_VALOR, R_E_C_N_O_ 	" + ENTER		
	//CSQL += " FROM "+RETSQLNAME("SE2")+" 																						" + ENTER	
	//CSQL += " WHERE E2_SALDO > 0 AND D_E_L_E_T_ = '' AND DATEDIFF(D,E2_VENCTO,E2_VENCREA) NOT IN (0,1,2,3)						" + ENTER
	IF CHKFILE("_EMP")
		DBSELECTAREA("_EMP")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_EMP" NEW

	CSQL := " SELECT COUNT(*) AS QUANT		" + ENTER
	CSQL += " FROM SE2070 WHERE E2_VENCREA = '20091231'			" + ENTER 	
	//CSQL += " FROM "+RETSQLNAME("SE2")+"	" + ENTER
	//CSQL += " WHERE E2_SALDO > 0 AND D_E_L_E_T_ = '' AND DATEDIFF(D,E2_VENCTO,E2_VENCREA) NOT IN (0,1,2,3)	" + ENTER
	IF CHKFILE("_EMP2")
		DBSELECTAREA("_EMP2")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_EMP2" NEW
	ProcRegua(_EMP2->QUANT)
	
	DBSELECTAREA("_EMP")	
	DBGoTop()

	DO WHILE ! _EMP->(EOF())
	
		//IncProc("Corrigindo Vencimento Real - SE2..."+ALLTRIM(_EMP->E2_PREFIXO)+"-"+ALLTRIM(_EMP->E2_NUM)+"-"+ALLTRIM(_EMP->E2_PARCELA)) 
    IncProc(ALLTRIM(STR(_EMP->R_E_C_N_O_)))		
		
		nData	:= DATAVALIDA(STOD(_EMP->E2_VENCTO))
		nData	:= DTOS(nData)

    //IF _EMP->R_E_C_N_O_ = 4036
    //   lOK := .T.
    //ENDIF

	    //Atualiza SE2
		//CSQL := "UPDATE "+RETSQLNAME("SE2")+" SET E2_VENCREA = '"+nData+"'		" + ENTER 
		CSQL := "UPDATE SE2070 SET E2_VENCREA = '"+nData+"'		" + ENTER		
		CSQL += "WHERE	R_E_C_N_O_ = '"+ALLTRIM(STR(_EMP->R_E_C_N_O_))+"' 	" + ENTER
		//CSQL += "		D_E_L_E_T_ = '' 										" + ENTER
		TCSQLEXEC(CSQL)
	                      
	  DBSELECTAREA("_EMP")		
		_EMP->(DBSKIP())

	END DO

	IF CHKFILE("_EMP")
		DBSELECTAREA("_EMP")
		DBCLOSEAREA()
	ENDIF
	
	MsgAlert("Atualizacao realizada com sucesso!")

EndIf

Return()