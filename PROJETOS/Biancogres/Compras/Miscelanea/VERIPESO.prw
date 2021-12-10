#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ BVERIPESO      บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  19/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ TELA PARA CONFERENCIA DO PESO NO CARREGAMENTO                    บฑฑ
ฑฑบ          ณ																	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ AP 8                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION BVERIPESO() 
//U_LOG_USO("VERIPESO")

IF TYPE("DDATABASE") <> "D"
	RPCSETENV("05","01",,,"FAT")
END IF
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ DECLARACAO DE VARIAVEIS                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE CPLACA := SPACE(8)
PRIVATE SSDATA := DDATABASE
PRIVATE CNUMPES := 1
PRIVATE CCSERIE := SPACE(2)
//Controla a abertura do programa
//cContador ++
//If cContador > 1
//	Return
//EndIf


// Alerta implementado em 28/06/13 por Marcos Alberto Soprani.
If dtos(dDataBase) < "20130701"
	// Matem situa็ใo atual.
ElseIf dtos(dDataBase) >= "20130701" .and. dtos(dDataBase) <= "20130731"
	MsgSTOP("Esta rotina estarแ em uso apenas at้ o dia 31/07/13. Ap๓s este perํodo, somente a nova rotina de pesagem estarแ disponํvel.")
Else
	MsgSTOP("A rotina de controle de pesagem mudou. Para obter informa็๕es sobre pesagem, favor acessar a tela de controle de carga e clicar em pesagem.")
	Return
EndIf


DEFINE MSDIALOG _ODLG TITLE "CHECA PESAGEM" FROM 176,193 TO 550,500 PIXEL

DEFINE FONT OFONTMSG   NAME "ARIAL" SIZE 000,-025 BOLD
DEFINE FONT OFONTTIT   NAME "ARIAL" SIZE 000,-025 BOLD
DEFINE FONT OFONTGET   NAME "ARIAL" SIZE 000,-055 BOLD
DEFINE FONT OFONTREC   NAME "ARIAL" SIZE 000,-080 BOLD

@ 001,004 TO 180,150 LABEL "" OF _ODLG PIXEL // 1 FRAME DO TITULO 2 MAIS

@ 020,010 SAY "PLACA:" SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG FONT OFONTTIT
@ 015,060 MSGET OEDIT1 VAR CPLACA SIZE 080,025 COLOR CLR_BLACK PIXEL OF _ODLG PICTURE "@R !!!-9999" FONT OFONTTIT

@ 055,010 SAY "SEQ." SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG FONT OFONTTIT
@ 050,060 MSGET OEDIT3 VAR CNUMPES SIZE 080,025 COLOR CLR_BLACK PIXEL OF _ODLG FONT OFONTTIT

@ 090,010 SAY "DATA:" SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG FONT OFONTTIT
@ 085,060 MSGET OEDIT2 VAR SSDATA SIZE 080,025 COLOR CLR_BLACK PIXEL OF _ODLG FONT OFONTTIT
'
//@ 125,010 SAY "SERIE:" SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG FONT OFONTTIT
//@ 120,060 MSGET OEDIT4 VAR CCSERIE SIZE 080,025 COLOR CLR_BLACK PIXEL OF _ODLG FONT OFONTTIT

@ 155,008 Button "CONSULTAR" Size 037,020 PIXEL OF _ODLG Action(CONSULTA())

@ 155,047 Button "ATUALIZA PLACA" Size 060,010 PIXEL OF _ODLG Action(ATU_PLACA())
@ 165,047 Button "ATUALIZA DATA/SEQ" Size 060,010 PIXEL OF _ODLG Action(ATU_DATA())

@ 155,110 Button "CANCELAR" Size 037,020 PIXEL OF _ODLG Action(CLOSE(_ODLG))

ACTIVATE MSDIALOG _ODLG CENTERED

cContador := 0
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ CONSULTA       บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  19/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ MONTA A TELA COM PARA ATUALIZACAO DA PLACA                       บฑฑ
ฑฑบ          ณ																	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION ATU_PLACA()
PRIVATE ACPLACA := SPACE(8)
PRIVATE BCPLACA := SPACE(8)
PRIVATE ANOTA 	:= SPACE(9)
PRIVATE COSERIE	:= SPACE(3)

DEFINE MSDIALOG __ODLG TITLE "CHECA PESAGEM" FROM 176,193 TO 550,500 PIXEL

DEFINE FONT OFONTMSG   NAME "ARIAL" SIZE 000,-025 BOLD
DEFINE FONT OFONTTIT   NAME "ARIAL" SIZE 000,-025 BOLD
DEFINE FONT OFONTGET   NAME "ARIAL" SIZE 000,-055 BOLD
DEFINE FONT OFONTREC   NAME "ARIAL" SIZE 000,-080 BOLD

@ 001,004 TO 180,150 LABEL "" OF __ODLG PIXEL // 1 FRAME DO TITULO 2 MAIS

@ 020,010 SAY "NF:" SIZE 164,016 COLOR CLR_RED PIXEL OF __ODLG FONT OFONTTIT
@ 015,065 MSGET OEDIT1 VAR ANOTA VALID BUSC_PLACA("PLACA") SIZE 080,025 COLOR CLR_BLACK PIXEL OF __ODLG FONT OFONTTIT

@ 055,010 SAY "SERIE:" SIZE 164,016 COLOR CLR_RED PIXEL OF __ODLG FONT OFONTTIT
@ 050,065 MSGET OEDIT4 VAR COSERIE VALID BUSC_PLACA("PLACA") SIZE 080,025 COLOR CLR_BLACK PIXEL OF __ODLG FONT OFONTTIT

@ 090,010 SAY "PLACA A:" SIZE 164,016 COLOR CLR_RED PIXEL OF __ODLG FONT OFONTTIT
@ 085,065 MSGET OEDIT1 VAR ACPLACA SIZE 080,025 COLOR CLR_BLACK PIXEL OF __ODLG PICTURE "@R !!!-9999" FONT OFONTTIT

@ 130,010 SAY "PLACA B:" SIZE 164,016 COLOR CLR_RED PIXEL OF __ODLG FONT OFONTTIT
@ 125,065 MSGET OEDIT1 VAR BCPLACA SIZE 080,025 COLOR CLR_BLACK PIXEL OF __ODLG PICTURE "@R !!!-9999" FONT OFONTTIT

@ 155,008 Button "SALVAR" Size 037,020 PIXEL OF __ODLG Action(SALV_PLACA())
@ 155,110 Button "CANCELAR" Size 037,020 PIXEL OF __ODLG Action(CLOSE(__ODLG))

ACTIVATE MSDIALOG __ODLG CENTERED


RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ ATU_DATA       บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  19/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ ATUALA A DATA DE SAIDA                                           บฑฑ
ฑฑบ          ณ																	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION ATU_DATA()
PRIVATE AADATA 	:= CTOD("  /  /  ")
PRIVATE ANOTA 	:= SPACE(9)
PRIVATE COSERIE := SPACE(3)
PRIVATE CSEQ 	:= SPACE(2)

DEFINE MSDIALOG ___ODLG TITLE "CHECA PESAGEM" FROM 176,193 TO 550,500 PIXEL

DEFINE FONT OFONTMSG   NAME "ARIAL" SIZE 000,-025 BOLD
DEFINE FONT OFONTTIT   NAME "ARIAL" SIZE 000,-025 BOLD
DEFINE FONT OFONTGET   NAME "ARIAL" SIZE 000,-055 BOLD
DEFINE FONT OFONTREC   NAME "ARIAL" SIZE 000,-080 BOLD

@ 001,004 TO 180,150 LABEL "" OF ___ODLG PIXEL // 1 FRAME DO TITULO 2 MAIS

@ 020,010 SAY "NF:" SIZE 164,016 COLOR CLR_RED PIXEL OF ___ODLG FONT OFONTTIT
@ 015,065 MSGET OEDIT1 VAR ANOTA VALID BUSC_PLACA("DATA") SIZE 080,025 COLOR CLR_BLACK PIXEL OF ___ODLG FONT OFONTTIT

@ 055,010 SAY "SERIE:" SIZE 164,016 COLOR CLR_RED PIXEL OF ___ODLG FONT OFONTTIT
@ 050,065 MSGET OEDIT4 VAR COSERIE VALID BUSC_PLACA("DATA") SIZE 080,025 COLOR CLR_BLACK PIXEL OF ___ODLG FONT OFONTTIT

@ 090,010 SAY "DATA:" SIZE 164,016 COLOR CLR_RED PIXEL OF ___ODLG FONT OFONTTIT
@ 085,065 MSGET OEDIT1 VAR AADATA SIZE 080,025 COLOR CLR_BLACK PIXEL OF ___ODLG PICTURE "@R !!!-9999" FONT OFONTTIT


@ 130,010  SAY "SEQ:" SIZE 164,016 COLOR CLR_RED PIXEL OF ___ODLG FONT OFONTTIT
@ 125,065 MSGET OEDIT5 VAR CSEQ SIZE 080,025 COLOR CLR_BLACK PIXEL OF ___ODLG FONT OFONTTIT


@ 155,008 Button "SALVAR" Size 037,020 PIXEL OF ___ODLG Action(SALV_DATA())
@ 155,110 Button "CANCELAR" Size 037,020 PIXEL OF ___ODLG Action(CLOSE(___ODLG))

ACTIVATE MSDIALOG ___ODLG CENTERED


RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ SAL_PLACA       บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  19/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ ROTINA PARA GRAVAR A NOVA PLACA INFORMADA                        บฑฑ
ฑฑบ          ณ																	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION SALV_PLACA()
If cempant == "05"
	IF ALLTRIM(COSERIE) = "S2"
		//CSQL := "SELECT F2_YPLACA, F2_YPLACAB FROM SF2010 WHERE F2_DOC = '"+ANOTA+"' AND F2_SERIE = '"+ALLTRIM(COSERIE)+"' AND D_E_L_E_T_ = '' "
		CSQL := "UPDATE SF2010 SET F2_YPLACA = '"+ACPLACA+"', F2_YPLACAB = '"+BCPLACA+"' WHERE F2_DOC = '"+ANOTA+"' AND F2_SERIE = '"+ALLTRIM(COSERIE)+"' AND D_E_L_E_T_ = '' "
	ELSE
		CSQL := "UPDATE "+RETSQLNAME("SF2")+" SET F2_YPLACA = '"+ACPLACA+"', F2_YPLACAB = '"+BCPLACA+"' WHERE F2_DOC = '"+ANOTA+"' AND F2_SERIE = '"+ALLTRIM(COSERIE)+"' AND D_E_L_E_T_ = '' "
	END IF
ELSE
	CSQL := "UPDATE "+RETSQLNAME("SF2")+" SET F2_YPLACA = '"+ALLTRIM(ACPLACA)+"', F2_YPLACAB = '"+ALLTRIM(BCPLACA)+"' WHERE F2_DOC = '"+ANOTA+"' AND F2_SERIE = '"+ALLTRIM(COSERIE)+"' AND D_E_L_E_T_ = '' "
END IF
TCSQLEXEC(CSQL)
CLOSE(__ODLG)
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ SALV_DATA      บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  19/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ ROTINA PARA GRAVAR A NOVA PLACA INFORMADA                        บฑฑ
ฑฑบ          ณ																	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION SALV_DATA()
If cempant == "05"
	IF ALLTRIM(COSERIE) = "S2"
		//CSQL := "SELECT F2_YPLACA, F2_YPLACAB FROM SF2010 WHERE F2_DOC = '"+ANOTA+"' AND F2_SERIE = '"+ALLTRIM(COSERIE)+"' AND D_E_L_E_T_ = '' "
		CSQL := "UPDATE SF2010 SET F2_YDES = '"+DTOS(AADATA)+"', F2_YSEQB = '"+CSEQ+"' WHERE F2_DOC = '"+ANOTA+"' AND F2_SERIE = '"+ALLTRIM(COSERIE)+"' AND D_E_L_E_T_ = '' "
	ELSE
		CSQL := "UPDATE "+RETSQLNAME("SF2")+" SET F2_YDES = '"+DTOS(AADATA)+"', F2_YSEQB = '"+CSEQ+"' WHERE F2_DOC = '"+ANOTA+"' AND F2_SERIE = '"+ALLTRIM(COSERIE)+"' AND D_E_L_E_T_ = '' "
	END IF
ELSE
	CSQL := "UPDATE "+RETSQLNAME("SF2")+" SET F2_YDES = '"+DTOS(AADATA)+"', F2_YSEQB = '"+CSEQ+"' WHERE F2_DOC = '"+ANOTA+"' AND F2_SERIE = '"+ALLTRIM(COSERIE)+"' AND D_E_L_E_T_ = '' "
END IF
TCSQLEXEC(CSQL)
CLOSE(___ODLG)
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ BUSC_PLACA     บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  19/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ BUSCA AS PLACA QUE JA ESTAO SALVAS                               บฑฑ
ฑฑบ          ณ																	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION BUSC_PLACA(STELA)
If cempant == "05"
	IF ALLTRIM(COSERIE) = "S2"
		CSQL := "SELECT F2_YPLACA, F2_YPLACAB, F2_YDES, F2_YSEQB FROM SF2010 WHERE F2_DOC = '"+ANOTA+"' AND F2_SERIE = '"+ALLTRIM(COSERIE)+"' AND D_E_L_E_T_ = '' "
	ELSE
		CSQL := "SELECT F2_YPLACA, F2_YPLACAB, F2_YDES, F2_YSEQB FROM "+RETSQLNAME("SF2")+" WHERE F2_DOC = '"+ANOTA+"' AND F2_SERIE = '"+ALLTRIM(COSERIE)+"' AND D_E_L_E_T_ = '' "
	END IF
ELSE
	CSQL := "SELECT F2_YPLACA, F2_YPLACAB, F2_YDES, F2_YSEQB FROM "+RETSQLNAME("SF2")+" WHERE F2_DOC = '"+ANOTA+"' AND F2_SERIE = '"+ALLTRIM(COSERIE)+"' AND D_E_L_E_T_ = '' "
END IF
IF CHKFILE("__CONS")
	DBSELECTAREA("__CONS")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "__CONS" NEW

IF __CONS->(EOF())
	ALERT("NOTA FISCAL INVALIDA")
	IF STELA = "PLACA"
		ACPLACA := SPACE(6)
		BCPLACA := SPACE(6)
	ELSE
		AADATA := CTOD("  /  /  ")
		CSEQ := SPACE(2)
	END IF
ELSE
	IF STELA = "PLACA"
		ACPLACA := __CONS->F2_YPLACA
		BCPLACA := __CONS->F2_YPLACAB
		__ODLG:Refresh()
	ELSE
		AADATA := STOD(__CONS->F2_YDES)
		CSEQ := __CONS->F2_YSEQB
		___ODLG:Refresh()
	END IF
END IF

RETURN




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ CONSULTA       บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  19/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ MONTA A TELA COM AS INFORMACOES DA PESAGEM                       บฑฑ
ฑฑบ          ณ																	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION CONSULTA()

PRIVATE COBS := SPACE(255)
PRIVATE CSQL := ""
DEFINE FONT OFONTCABEC  NAME "ARIAL" SIZE 000,-030 BOLD
DEFINE FONT OFONTTIT   	NAME "ARIAL" SIZE 000,-015 BOLD
DEFINE FONT OFONTGET   	NAME "ARIAL" SIZE 000,-015 BOLD
DEFINE FONT OFONTSINAIS NAME "ARIAL" SIZE 000,-020 BOLD


//SELECIONANDO TODOS OS PRODUTOS E SUAS QUANTIDADES EM ESTOQUE
SQL_QUERY()
IF CHKFILE("C_CONS")
	DBSELECTAREA("C_CONS")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "C_CONS" NEW
C_CONS->(DBGOTOP())

IF C_CONS->(EOF())
	ALERT("PLACA INEXISTENTE")
	RETURN
ELSE
	CLOSE(_ODLG)
END IF

COBS := C_CONS->Z11_OBSER

DEFINE MSDIALOG _ODLG1 TITLE "CHECA PESAGEM" FROM 176,193 TO 500,800 PIXEL


@ 001,004 TO 030,300 LABEL "" OF _ODLG1 PIXEL
@ 006,0100 SAY "RESULTADO" SIZE 200,030 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTCABEC



@ 030,004 TO 0160,300 LABEL "" OF _ODLG1 PIXEL
// "................."
@ 040,010 SAY "PLACA:" SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTTIT
@ 040,060 SAY C_CONS->Z11_PCAVAL SIZE 080,016 COLOR CLR_BLACK PIXEL OF _ODLG1 FONT OFONTTIT

@ 055,010 SAY "DATA:" SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTTIT
@ 055,060 SAY ALLTRIM(C_CONS->Z11_DATAIN) SIZE 080,016 COLOR CLR_BLACK PIXEL OF _ODLG1 FONT OFONTTIT


@ 035,150 TO 150,290 LABEL "PESOS" OF _ODLG1 PIXEL
@ 050,160 SAY "KG. BALANCA:" SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTTIT
@ 050,240 SAY ALLTRIM(STR(C_CONS->Z11_PESLIQ)) SIZE 080,016 COLOR CLR_BLACK PIXEL OF _ODLG1 FONT OFONTTIT
@ 056,248 SAY "-" SIZE 164,025 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTSINAIS


@ 065,155 TO 120,285 LABEL  OF _ODLG1 PIXEL

@ 070,160 SAY "KG. NOTA: " SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTTIT
@ 070,240 SAY ALLTRIM(STR(C_CONS->F2_PLIQUI)) SIZE 080,016 COLOR CLR_BLACK PIXEL OF _ODLG1 FONT OFONTTIT

//@ 080,248 SAY "+" SIZE 164,025 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTSINAIS


//@ 090,210 Button "?" Size 010,008 PIXEL OF _ODLG1 Action(INFORMA())
//@ 090,160 SAY "KG. PALLET: " SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTTIT
//IF C_CONS->Z11_PALADC = 0
//	@ 090,240 SAY ALLTRIM(STR(C_CONS->PESOPALLET)) SIZE 080,016 COLOR CLR_BLACK PIXEL OF _ODLG1 FONT OFONTTIT
//ELSE
//	@ 090,240 SAY ALLTRIM(STR(C_CONS->PESOPALLET)) SIZE 080,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTTIT
//END IF
//@ 090,260 Button "ALT." Size 020,010 PIXEL OF _ODLG1 Action(NNALTERA())


//@ 090,160 SAY "______________________" SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTTIT
//@ 105,160 SAY "TOTAL" SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTTIT
//@ 105,240 SAY ALLTRIM(STR(   ( C_CONS->F2_PLIQUI + C_CONS->PESOPALLET )  )) SIZE 080,016 COLOR CLR_BLACK PIXEL OF _ODLG1 FONT OFONTTIT

@ 125,160 SAY "DIFERENวA EM Kg" SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTTIT
@ 125,240 SAY ALLTRIM(STR(C_CONS->DIFERENCA)) SIZE 080,016 COLOR CLR_BLACK PIXEL OF _ODLG1 FONT OFONTTIT


@ 135,160 SAY "DIFERENวA EM %" SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTTIT
@ 135,240 SAY ALLTRIM(STR(C_CONS->DIFE_PERCE)) SIZE 080,016 COLOR CLR_BLACK PIXEL OF _ODLG1 FONT OFONTTIT


@ 070,010 SAY "OBSERVAวรO:" SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTTIT
@ 080,010 MSGET OEDIT2 VAR COBS SIZE 120,025 COLOR CLR_BLACK PIXEL OF _ODLG1 FONT OFONTTIT

@ 120,010 SAY C_CONS->ASTATUS SIZE 164,016 COLOR CLR_RED PIXEL OF _ODLG1 FONT OFONTSINAIS

IF ALLTRIM(C_CONS->ASTATUS) <> "LIBERADO"
	@ 140,010 Button "GRAVAR OBS" Size 037,017 PIXEL OF _ODLG1 Action(GRAVA_OBS())
END IF
@ 140,110 Button "CANCELAR" Size 037,017 PIXEL OF _ODLG1 Action(CLOSE(_ODLG1))


IF ALLTRIM(C_CONS->ASTATUS) <> "LIBERADO"
	//	_EMAIL() // DESABILITADO POR BRUNO
END IF

ACTIVATE MSDIALOG _ODLG1 CENTERED

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ _EMAIL         บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  09/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ ROTINA PARA ENVIAR EMAIL QUANDO OCORRER DIVERGENCIA NA BALANCA   บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION _EMAIL()
LOCAL  CEMAIL    	:= ""
LOCAL  C_HTML  	:= ""
LOCAL  LOK        := .F.

C_HTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
C_HTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
C_HTML += '<head> '
C_HTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
C_HTML += '<title>Untitled Document</title> '
C_HTML += '<style type="text/css"> '
C_HTML += '<!-- '
C_HTML += '.style11 {font-size: 9px; color: #FFFFFF; } '
C_HTML += '.style12 {color: #FFFFFF} '
C_HTML += '.style13 {font-size: 12px} '
C_HTML += '.style15 {font-size: 12px; color: #000000; } '
C_HTML += '.style16 {color: #000000; } '
C_HTML += '.style20 {font-size: 9px} '
C_HTML += '--> '
C_HTML += '</style></head> '
C_HTML += ' '
C_HTML += '<body> '
IF CEMPANT = "05"
	C_HTML += '    <th width="236" scope="col">INCESA CERAMICA LTDA </th> '
ELSE
	C_HTML += '    <th width="236" scope="col">BIANCOGRES CERAMICA SA </th> '
END IF
C_HTML += '<p>&nbsp;</p> '
C_HTML += '<table width="486" height="89" border="1" bordercolor="#FFFFFF"> '
C_HTML += '  <tr bordercolor="#999999" bgcolor="#0066FF"> '
C_HTML += '    <th colspan="2" scope="col"><span class="style12"> DIVERGสNCIA NA PESAGEM </span></th> '
C_HTML += '  </tr> '
C_HTML += '  <tr bordercolor="#999999"> '
C_HTML += '    <th colspan="2" scope="col"><div align="left" class="style13"> PLACA: '+ CPLACA +' ::::: DATA: '+ DTOC(SSDATA) +' </div></th> '
C_HTML += '  </tr> '
C_HTML += '  <tr bgcolor="#0066FF"> '
C_HTML += '    <th bgcolor="#FFFFFF" scope="col"><span class="style16"></span></th> '
C_HTML += '    <th bgcolor="#FFFFFF" scope="col"><span class="style16"></span></th> '
C_HTML += '  </tr> '
C_HTML += '   '
C_HTML += '  <tr bordercolor="#999999" bgcolor="#0066FF"> '
C_HTML += '    <th width="308" scope="col"><div align="left" class="style12"><span class="style20"> KG. NA BALANวA </span></div></th> '
C_HTML += '    <th width="162" bgcolor="#FFFFFF" scope="col"><span class="style15"> '+ TRANSFORM(C_CONS->Z11_PESLIQ	,"@E 999,999,999.99") +' </span></th> '
C_HTML += '  </tr> '
C_HTML += '   '
C_HTML += '   <tr bgcolor="#0066FF"> '
C_HTML += '    <th width="162" bordercolor="#FFFFFF" bgcolor="#FFFFFF" scope="col"><span class="style15">  </span></th> '
C_HTML += '    <th width="162" bordercolor="#FFFFFF" bgcolor="#FFFFFF" scope="col"><span class="style15"> - </span></th> '
C_HTML += '  </tr> '
C_HTML += '   '
C_HTML += '  <tr bordercolor="#999999" bgcolor="#0066FF"> '
C_HTML += '    <th width="308" scope="col"><div align="left" class="style12"><span class="style20"> KG. NA NOTA </span></div></th> '
C_HTML += '    <th width="162" bgcolor="#FFFFFF" scope="col"><span class="style15"> '+ TRANSFORM(C_CONS->F2_PLIQUI	,"@E 999,999,999.99") +' </span></th> '
C_HTML += '  </tr> '
C_HTML += '   '
C_HTML += '   <tr bgcolor="#0066FF"> '
C_HTML += '    <th width="162" bordercolor="#FFFFFF" bgcolor="#FFFFFF" scope="col"><span class="style15">  </span></th> '
C_HTML += '    <th width="162" bordercolor="#FFFFFF" bgcolor="#FFFFFF" scope="col"><span class="style15"> + </span></th> '
C_HTML += '  </tr> '
C_HTML += '    '
C_HTML += '  <tr bordercolor="#999999" bgcolor="#0066FF"> '
C_HTML += '    <th width="308" scope="col"><div align="left" class="style12"><span class="style20"> KG PALLET </span></div></th> '
C_HTML += '    <th width="162" bgcolor="#FFFFFF" scope="col"><span class="style15"> '+ TRANSFORM(C_CONS->PESOPALLET	,"@E 999,999,999.99") +' </span></th> '
C_HTML += '   '
C_HTML += '  </tr> '
C_HTML += '    '
C_HTML += '  <tr bgcolor="#0066FF"> '
C_HTML += '    <th width="162" bordercolor="#FFFFFF" bgcolor="#FFFFFF" scope="col"><span class="style15">  </span></th> '
C_HTML += '    <th width="162" bordercolor="#FFFFFF" bgcolor="#FFFFFF" scope="col"><span class="style15"> -------------------------- </span></th> '
C_HTML += '  </tr> '
C_HTML += ' '
C_HTML += '   <tr bordercolor="#999999" bgcolor="#0066FF"> '
C_HTML += '    <th width="308" scope="col"><div align="left" class="style12"><span class="style20"> TOTAL </span></div></th> '
C_HTML += '    <th width="162" bgcolor="#FFFFFF" scope="col"><span class="style15"> '+ TRANSFORM(  (C_CONS->F2_PLIQUI + C_CONS->PESOPALLET)  ,"@E 999,999,999.99") +' </span></th> '
C_HTML += '  </tr> '
C_HTML += '    '
C_HTML += '   <tr bgcolor="#0066FF"> '
C_HTML += '    <th width="162" bordercolor="#FFFFFF" bgcolor="#FFFFFF" scope="col"><span class="style15">  </span></th> '
C_HTML += '    <th width="162" bordercolor="#FFFFFF" bgcolor="#FFFFFF" scope="col"><span class="style15">  </span></th> '
C_HTML += '  </tr> '
C_HTML += '   '
C_HTML += '  <tr bordercolor="#999999" bgcolor="#0066FF"> '
C_HTML += '    <th width="308" scope="col"><div align="left" class="style12"><span class="style20"> DIFERENวA EM KG. </span></div></th> '
C_HTML += '    <th width="162" bgcolor="#FFFFFF" scope="col"><span class="style15"> '+ TRANSFORM(C_CONS->DIFERENCA	,"@E 999,999,999.99") +' </span></th> '
C_HTML += '  </tr> '
C_HTML += '   '
C_HTML += '  <tr bordercolor="#999999" bgcolor="#0066FF"> '
C_HTML += '    <th width="308" scope="col"><div align="left" class="style12"><span class="style20"> DIFERENวA EM % </span></div></th> '
C_HTML += '    <th width="162" bgcolor="#FFFFFF" scope="col"><span class="style15"> '+ TRANSFORM(C_CONS->DIFE_PERCE	,"@E 999,999.999999") +' </span></th> '
C_HTML += '  </tr> '
C_HTML += ' '
C_HTML += '  <tr class="style15"> '
C_HTML += '    <td colspan="2" bordercolor="#FFFFFF"><strong>  OBS: ' + ALLTRIM(COBS) +' </strong></td> '
C_HTML += '  </tr> '
C_HTML += '</table> '
C_HTML += '<p>&nbsp;</p> '
C_HTML += '</body> '
C_HTML += ' '
C_HTML += '</html> '


cRecebe     := "sistemas.ti@biancogres.com.br"  // ;"+cEmail	// Email do(s) receptor(es)
cRecebeCC	:= "" 	// Com Copia
cRecebeCO	:= ""												// Copia Oculta
cAssunto	:= "DIVERGENCIA NA BALANวA - PLACA: " + CPLACA + "NA DATA " + DTOC(SSDATA)

lOk := U_BIAEnvMail(,cRecebe,cAssunto,C_HTML)

IF !lOK
	MSGBOX("ERRO AO ENVIAR EMAIL ")
ENDIF

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ NNALTERA       บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  19/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ ALTERA A QUANTIDADE DE PALLET                                    บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION NNALTERA()
LOCAL CCvalor := SPACE(2)

CLOSE(_ODLG1)
DEFINE MSDIALOG _OD11 TITLE "ALTERA PALLET" FROM 176,193 TO 320,500 PIXEL

@ 001,004 TO 70,150 LABEL "" OF _OD11 PIXEL // 1 FRAME DO TITULO 2 MAIS
@ 020,010 SAY "PALLET." SIZE 164,016 COLOR CLR_RED PIXEL OF _OD11 FONT OFONTTIT
@ 015,060 MSGET OEDIT5 VAR CCvalor SIZE 080,025 COLOR CLR_BLACK PIXEL OF _OD11 FONT OFONTCABEC

@ 045,010 Button "OK" Size 037,020 PIXEL OF _OD11 Action(CLOSE(_OD11) )
ACTIVATE MSDIALOG _OD11 CENTERED


IF ALLTRIM(CCvalor) <> ""
	CSQL := "UPDATE "+RETSQLNAME("Z11")+" SET Z11_PALADC = '"+ALLTRIM(CCvalor)+"' WHERE R_E_C_N_O_ = '"+ALLTRIM(STR(C_CONS->R_E_C_N_O_))+"' "
	TCSQLExec(CSQL)
	ALERT("GRAVAวรO REALIZADO COM SUCESSO")
END IF

CONSULTA()
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ INFORMA        บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  19/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ GERA UMA MENSAGEM NA TELA COM INFORMACOES DO PESO ALTERADO DO    บฑฑ
ฑฑบ          ณ PALLET                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION INFORMA()
LOCAL SSENSAGEM := ""

IF C_CONS->Z11_PALADC = 0
	SSENSAGEM := "A QUANTIDADE DE PALLET NรO FOI ALTERADO"
	ALERT(SSENSAGEM)
ELSE
	SSENSAGEM := "A QUANTIDADE DE PALLET FOI A.LTERADO" + CHR(13)
	SSENSAGEM += "QUANTIDADE DE PALEET = " + ALLTRIM(STR(C_CONS->F2_YPALLET)) + " PC" + CHR(13)
	SSENSAGEM += "QUANTIDADE INFORMADA = " + ALLTRIM(STR(C_CONS->Z11_PALADC)) + " PC"
	ALERT(SSENSAGEM)
END IF
dlgRefresh(_ODLG1)
ObjectMethod(_ODLG1,"Refresh()")

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ GRAVA_OBS      บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  19/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ GRAVA A OBSERVACAO QUANDO A PESAGEM ESTA COM DIFERENCA > 2       บฑฑ
ฑฑบ          ณ																	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION GRAVA_OBS()

CSQL := "UPDATE "+RETSQLNAME("Z11")+" SET Z11_OBSER = '"+ALLTRIM(COBS)+"' WHERE R_E_C_N_O_ = '"+ALLTRIM(STR(C_CONS->R_E_C_N_O_))+"' "
TCSQLExec(CSQL)
ALERT("GRAVAวรO REALIZADO COM SUCESSO")
RETURN




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ SQL_QUERY      บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  19/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ MONTA A CONSULTA PARA EXIBICAO NA TELA DE PESAGEM                บฑฑ
ฑฑบ          ณ																	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION SQL_QUERY()
Private Enter := CHR(13)+CHR(10)

CQUERY := "SELECT SUM(QUANT) AS QUANT FROM  " + ENTER
CQUERY += "(SELECT ISNULL(COUNT(F2_YPLACAB),0) AS QUANT " + ENTER
CQUERY += "FROM SF2050 " + ENTER
CQUERY += "WHERE	F2_EMISSAO = '"+DTOS(SSDATA)+"' AND  " + ENTER
CQUERY += "			F2_YPLACAB = '"+CPLACA+"' AND  " + ENTER
CQUERY += "			D_E_L_E_T_ = '' " + ENTER
CQUERY += " UNION " + ENTER
CQUERY += "SELECT ISNULL(COUNT(F2_YPLACAB),0) AS QUANT " + ENTER
CQUERY += "FROM SF2010 " + ENTER
CQUERY += "WHERE	F2_EMISSAO = '"+DTOS(SSDATA)+"' AND  " + ENTER
CQUERY += "			F2_YPLACAB = '"+CPLACA+"' AND  " + ENTER
CQUERY += "			D_E_L_E_T_ = '' AND F2_SERIE = 'S2' ) AS T " + ENTER
IF CHKFILE("C_RTESTE")
	DBSELECTAREA("C_RTESTE")
	DBCLOSEAREA()
ENDIF
//TCQUERY CQUERY ALIAS "C_RTESTE" NEW


CSQL := "SELECT	Z11_OBSER, Z11_SEQB, Z11_PALADC, Z11.R_E_C_N_O_, CONVERT(VARCHAR,CONVERT(DATETIME,Z11.Z11_DATASA),103) AS Z11_DATAIN, Z11.Z11_PCAVAL, SUM(Z11.Z11_PESLIQ) AS Z11_PESLIQ, ISNULL(F2_YPALLET,0) AS F2_YPALLET,   (ISNULL(F2_YPALLET + Z11_PALADC,0) * "+ALLTRIM(STR(GETMV("MV_YPESOPL")))+") AS PESOPALLET,  " + ENTER
CSQL += "		ISNULL(F2_PBRUTO,0) AS F2_PLIQUI,  " + ENTER
cSQL += "		(SUM(Z11.Z11_PESLIQ) - (ISNULL(F2_PBRUTO,0))) DIFERENCA,   " + Enter

//CSQL += "		((   (SUM(Z11.Z11_PESLIQ) - (ISNULL(F2_PBRUTO,0) + (ISNULL(F2_YPALLET + Z11_PALADC,0) * "+ALLTRIM(STR(GETMV("MV_YPESOPL")))+")) )   /  SUM(SF2.F2_PBRUTO) )    * 100 ) DIFE_PERCE   " + Enter
//CSQL += "		,ASTATUS = CASE WHEN ((   (SUM(Z11.Z11_PESLIQ) - (ISNULL(F2_PBRUTO,0) + (ISNULL(F2_YPALLET + Z11_PALADC,0) * "+ALLTRIM(STR(GETMV("MV_YPESOPL")))+")) )   /  SUM(SF2.F2_PBRUTO) )    * 100 )  <= "+ALLTRIM(STR(GETMV("MV_YTOLER2")))+" AND ((   (SUM(Z11.Z11_PESLIQ) - (ISNULL(F2_PBRUTO,0) + (ISNULL(F2_YPALLET + Z11_PALADC,0) * "+ALLTRIM(STR(GETMV("MV_YPESOPL")))+")) )   /  SUM(SF2.F2_PBRUTO) )    * 100 ) >= -"+ALLTRIM(STR(GETMV("MV_YTOLER2")))+" THEN 'LIBERADO'  " + ENTER

CSQL += "		((   (SUM(Z11.Z11_PESLIQ) - (ISNULL(F2_PBRUTO,0) ) )   /  SUM(SF2.F2_PBRUTO) )    * 100 ) DIFE_PERCE    " + Enter
CSQL += "		,ASTATUS = CASE WHEN ((   (SUM(Z11.Z11_PESLIQ) - (ISNULL(F2_PBRUTO,0) ) )   /  SUM(SF2.F2_PBRUTO) )    * 100 )  <= "+ALLTRIM(STR(GETMV("MV_YTOLER2")))+" AND ((   (SUM(Z11.Z11_PESLIQ) - (ISNULL(F2_PBRUTO,0) ) )   /  SUM(SF2.F2_PBRUTO) )    * 100 ) >= -"+ALLTRIM(STR(GETMV("MV_YTOLER2")))+" THEN 'LIBERADO'   " + Enter

CSQL += "						ELSE 'CONFERIR CAMINHรO' END  " + ENTER
//CSQL += "FROM "+RETSQLNAME("Z11")+" Z11 ," + ENTER
CSQL += "FROM "+RETSQLNAME("Z11")+" Z11 LEFT JOIN" + ENTER //22/01/2016 - pode precisar ser trocado por inner join, pois o select original estava com erro, referenciando inner e left join - Luana Marin Ribeiro

// VERIFICANDO SE A PLACA 2 ESTA PREENCHIDA POIS SE ESTIVER BUSCA AS INFORMAวีES DA MESMA
//IF C_RTESTE->QUANT = 0
If cempant == "05"
	CSQL += "		(SELECT F2_YSEQB, F2_YPLACA, F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET FROM " + ENTER
	CSQL += "				(SELECT F2_YSEQB, F2_YPLACA, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET   " + ENTER
	CSQL += "				FROM SF2050 SF2  " + ENTER
	CSQL += "				WHERE	--F2_EMISSAO = '20080915' AND   " + ENTER
	CSQL += "						--F2_YPLACA <> '' AND   " + ENTER
	CSQL += "						SF2.D_E_L_E_T_ = '' AND  " + ENTER
	CSQL += "						SF2.F2_DOC+SF2.F2_SERIE+SF2.F2_CLIENTE+SF2.F2_LOJA IN  " + ENTER
	CSQL += "						(SELECT D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA " + ENTER
	CSQL += "						FROM SD2050 SD2, SF4050 SF4 " + ENTER
	CSQL += "						WHERE F4_CODIGO = D2_TES AND SF4.F4_ESTOQUE = 'S' AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' " + ENTER
	CSQL += "						GROUP BY D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA)   " + ENTER
	CSQL += "				GROUP BY F2_YSEQB, F2_YPLACA, F2_YDES   " + ENTER
	CSQL += "				UNION 					 " + ENTER
	CSQL += "				SELECT F2_YSEQB, F2_YPLACA, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET   " + ENTER
	CSQL += "				FROM SF2010 SF2  " + ENTER
	CSQL += "				WHERE	--F2_EMISSAO = '20080915' AND   " + ENTER
	CSQL += "						--F2_YPLACA <> '' AND   " + ENTER
	CSQL += "						SF2.D_E_L_E_T_ = ''  AND F2_SERIE = 'S2' AND " + ENTER
	CSQL += "						SF2.F2_DOC+SF2.F2_SERIE+SF2.F2_CLIENTE+SF2.F2_LOJA IN  " + ENTER
	CSQL += "						(SELECT D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA " + ENTER
	CSQL += "						FROM SD2010 SD2, SF4010 SF4 " + ENTER
	CSQL += "						WHERE F4_CODIGO = D2_TES AND SF4.F4_ESTOQUE = 'S' AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' " + ENTER
	CSQL += "						GROUP BY D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA)   " + ENTER
	CSQL += "				GROUP BY F2_YSEQB, F2_YPLACA, F2_YDES " + ENTER
	CSQL += "				UNION " + ENTER
	CSQL += "				SELECT F2_YSEQB, F2_YPLACAB AS F2_YPLACA, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET   " + ENTER
	CSQL += "				FROM SF2050 SF2  " + ENTER
	CSQL += "				WHERE	--F2_EMISSAO = '20080915' AND   " + ENTER
	CSQL += "						--F2_YPLACA <> '' AND   " + ENTER
	CSQL += "						SF2.D_E_L_E_T_ = ''  AND " + ENTER
	CSQL += "						SF2.F2_DOC+SF2.F2_SERIE+SF2.F2_CLIENTE+SF2.F2_LOJA IN  " + ENTER
	CSQL += "						(SELECT D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA " + ENTER
	CSQL += "						FROM SD2050 SD2, SF4050 SF4 " + ENTER
	CSQL += "						WHERE F4_CODIGO = D2_TES AND SF4.F4_ESTOQUE = 'S' AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' " + ENTER
	CSQL += "						GROUP BY D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA)   " + ENTER
	CSQL += "				GROUP BY F2_YSEQB, F2_YPLACAB, F2_YDES   " + ENTER
	CSQL += "				UNION 					 " + ENTER
	CSQL += "				SELECT F2_YSEQB, F2_YPLACAB AS F2_YPLACA, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET   " + ENTER
	CSQL += "				FROM SF2010 SF2  " + ENTER	  "
	CSQL += "				WHERE	--F2_EMISSAO = '20080915' AND   " + ENTER
	CSQL += "						--F2_YPLACA <> '' AND   " + ENTER
	CSQL += "						SF2.D_E_L_E_T_ = ''  AND F2_SERIE = 'S2' AND " + ENTER
	CSQL += "						SF2.F2_DOC+SF2.F2_SERIE+SF2.F2_CLIENTE+SF2.F2_LOJA IN  " + ENTER
	CSQL += "						(SELECT D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA " + ENTER
	CSQL += "						FROM SD2010 SD2, SF4010 SF4 " + ENTER
	CSQL += "						WHERE F4_CODIGO = D2_TES AND SF4.F4_ESTOQUE = 'S' AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' " + ENTER
	CSQL += "						GROUP BY D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA)   " + ENTER
	CSQL += "				GROUP BY F2_YSEQB, F2_YPLACAB, F2_YDES) AS SF2 " + ENTER
	CSQL += "		GROUP BY F2_YSEQB, F2_YPLACA, F2_EMISSAO) AS SF2" + ENTER
ELSE
	//CSQL += "(SELECT F2_YSEQB, F2_YPLACA, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET   " + ENTER
	//CSQL += "FROM SF2010 SF2  " + ENTER	  "
	//CSQL += "WHERE	--F2_EMISSAO = '20080915' AND   " + ENTER
	//CSQL += "		F2_YPLACA <> '' AND   " + ENTER
	//CSQL += "		SF2.D_E_L_E_T_ = '' AND  " + ENTER
	//
	//CSQL += "						SF2.F2_DOC+SF2.F2_SERIE+SF2.F2_CLIENTE+SF2.F2_LOJA IN  " + ENTER
	//CSQL += "						(SELECT D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA " + ENTER
	//CSQL += "						FROM SD2010 SD2, SF4010 SF4 " + ENTER
	//CSQL += "						WHERE F4_CODIGO = D2_TES AND SF4.F4_ESTOQUE = 'S' AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' " + ENTER
	//CSQL += "						GROUP BY D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA)   " + ENTER
	//
	//CSQL += "GROUP BY F2_YSEQB, F2_YPLACA, F2_YDES) AS SF2 " + ENTER
	
	//Substituido por Wanisay em 20/10/09 para considerar notas da LM somadas a empresa Biancogres
	CSQL += "		(SELECT F2_YSEQB, F2_YPLACA, F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET FROM	 " + ENTER
	CSQL += "				(SELECT F2_YSEQB, F2_YPLACA, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET  " + ENTER
	CSQL += "				FROM SF2010 SF2  " + ENTER
	CSQL += "				WHERE	SF2.D_E_L_E_T_ = '' AND   " + ENTER
	CSQL += "						SF2.F2_DOC+SF2.F2_SERIE+SF2.F2_CLIENTE+SF2.F2_LOJA IN   " + ENTER
	CSQL += "						(SELECT D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA  " + ENTER
	CSQL += "						FROM SD2010 SD2, SF4010 SF4  " + ENTER
	CSQL += "						WHERE F4_CODIGO = D2_TES AND SF4.F4_ESTOQUE = 'S' AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = ''  " + ENTER
	CSQL += "						GROUP BY D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA) " + ENTER
	CSQL += "				GROUP BY F2_YSEQB, F2_YPLACA, F2_YDES " + ENTER
	CSQL += "				UNION " + ENTER
	CSQL += "				SELECT F2_YSEQB, F2_YPLACA, F2_YDES AS F2_EMISSAO, SUM(F2_PBRUTO) AS F2_PBRUTO, SUM(F2_YPALLET) AS F2_YPALLET  " + ENTER
	CSQL += "				FROM SF2070 SF2  " + ENTER
	CSQL += "				WHERE	SF2.D_E_L_E_T_ = '' AND   " + ENTER
	CSQL += "						SF2.F2_DOC+SF2.F2_SERIE+SF2.F2_CLIENTE+SF2.F2_LOJA IN   " + ENTER
	CSQL += "						(SELECT D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA  " + ENTER
	CSQL += "						FROM SD2070 SD2, SF4070 SF4  " + ENTER
	CSQL += "						WHERE F4_CODIGO = D2_TES AND SF4.F4_ESTOQUE = 'S' AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = ''  " + ENTER
	CSQL += "						GROUP BY D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA) " + ENTER
	CSQL += "				GROUP BY F2_YSEQB, F2_YPLACA, F2_YDES) AS SF2 " + ENTER
	CSQL += "		GROUP BY F2_YSEQB, F2_YPLACA, F2_EMISSAO) AS SF2  " + ENTER
END IF
//22/01/2016 - as tr๊s linhas abaixo foram colocadas para implementar os joins dos selects - Luana Marin Ribeiro
CSQL += "		ON Z11.Z11_PCAVAL=SF2.F2_YPLACA AND " + ENTER
CSQL += "			Z11.Z11_DATASA=SF2.F2_EMISSAO AND " + ENTER
CSQL += "			Z11.Z11_SEQB=F2_YSEQB " + ENTER
CSQL += "WHERE	Z11.Z11_PESLIQ <> '' AND  " + ENTER
//CSQL += "		SF2.F2_YPLACA =* Z11.Z11_PCAVAL AND  " + ENTER
//CSQL += "		SF2.F2_EMISSAO =* Z11.Z11_DATASA AND  " + ENTER
CSQL += "		Z11.D_E_L_E_T_ = ''   " + ENTER
CSQL += "		AND Z11.Z11_DATASA = '"+DTOS(SSDATA)+"' " + ENTER
CSQL += "		AND Z11.Z11_PCAVAL = '"+CPLACA+"' " + ENTER
CSQL += "		AND Z11.Z11_SEQB = '"+ALLTRIM(STR(CNUMPES))+"' " + ENTER
//CSQL += "		AND F2_YSEQB = Z11.Z11_SEQB " + ENTER
CSQL += "		AND Z11_MERCAD = '2' " + ENTER
CSQL += "GROUP BY Z11_OBSER, Z11_SEQB, Z11_PALADC, Z11.R_E_C_N_O_, Z11.Z11_DATASA, Z11.Z11_PCAVAL,  F2_PBRUTO, F2_YPALLET  " + ENTER

RETURN
