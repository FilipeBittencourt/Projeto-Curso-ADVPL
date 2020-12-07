#INCLUDE 'TOTVS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥COM_SALDO         ≥ MADALENO           ∫ Data ≥  23/12/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ CONTROLO PARA COMPOSICAO DE SALDO BANCARIO                 ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP 8 - R4                                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function COMP_SALDO() 
PRIVATE CBANCO := SPACE(03)
PRIVATE CAGENCIA := SPACE(10)
PRIVATE CCONTA := SPACE(10)
PRIVATE CMES := SPACE(07)

// MONTANDO A TELA DOS PARAMETROS.

DEFINE DIALOG oDlg11 TITLE "COMPOSI«√O DE SALDO" FROM 180,180 TO 500,555 PIXEL

	oFont1     	:= TFont():New( "MS Sans Serif",0,-24,,.T.,0,,700,.F.,.F.,,,,,, )
	oPanel1:= TSCROLLBOX():NEW(oDlg11,004,004,155,180,.T.,.T.,.T.)
	oSay1      	:= TSay():New( 004,010,{||"COMPOSI«√O DE SALDO"},oPanel1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,160,016)
	
	// CAMPO MES E ANO
	oSay2      := TSay():New( 050,010,{||"MÍs e Ano"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
	//oTGet2 := TGet():Create( oPanel1,{||CMES},048,050,050,009,"@! 99/9999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,CMES,,,, )
	oTGet2 := TGet():New( 048,050,{|u| If(PCount()>0,CMES:=u,CMES)},oPanel1,050,009,"@! 99/9999",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"CMES",,)
	
	
	// CAMPO BANCO
	oSay2      := TSay():New( 070,010,{||"Banco"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
	oTGet2 := TGet():New( 068,050,{|u| If(PCount()>0,CBANCO:=u,CBANCO)},oPanel1,050,009,,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA6","CBANCO",,)

	// CAMPO AGENCIA
	oSay2      := TSay():New( 90,010,{||"Agencia"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
	oTGet3 := TGet():New( 088,050,{|u| If(PCount()>0,CAGENCIA:=u,CAGENCIA)},oPanel1,050,009,,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,,"CAGENCIA",,)

	// CAMPO CONTA
	oSay2      := TSay():New( 110,010,{||"Conta"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
	oTGet4 := TGet():New( 108,050,{|u| If(PCount()>0,CCONTA:=u,CCONTA)},oPanel1,050,009,,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,,"CCONTA",,)

 	oTHButton := THButton():New(140,10,"CONSULTA SALDO",oDlg11,{|| fExecute() },70,10,,"CONSULTA O SALDO DOS BANCOS ACIMA CONFIGURADO")


ACTIVATE DIALOG oDlg11 CENTERED 

RETURN


Static Function fExecute()
	U_BIAMsgRun("Consultando saldo do banco...", "Aguarde!", {|| CONS_SALDO() })
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CONS_SALDO        ≥ MADALENO           ∫ Data ≥  23/12/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FUNCAO UTILIZADA PARA MONTAR O SALDO                       ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC FUNCTION CONS_SALDO()
PRIVATE oOK 	:= LoadBitmap(GetResources(),'br_verde')
PRIVATE oNO 	:= LoadBitmap(GetResources(),'br_vermelho')
PRIVATE CNOME 	:= ""
PRIVATE aBrowse := {} 
PRIVATE CSQL 	:= ""
PRIVATE ENTER	:= CHR(13)+CHR(10)
PRIVATE SALDO 	:= 0
PRIVATE SAL_INI := 0
PRIVATE FINAL_SALDO := 0
oDlg11:End()


// BUSCANDO O SALDO DO PERIODO INFORMADO
CSQL 	:= "SELECT * " + ENTER
CSQL 	+= "FROM "+RETSQLNAME("ZZM")+" " + ENTER
CSQL 	+= "WHERE	ZZM_BANCO = '"+ALLTRIM(CBANCO)+"' AND " + ENTER
CSQL 	+= "		ZZM_AGENCI = '"+ALLTRIM(CAGENCIA)+"' AND  " + ENTER
CSQL 	+= "		ZZM_CONTA = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL 	+= "		ZZM_DATA = '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"01' AND " + ENTER
CSQL 	+= "		D_E_L_E_T_ = '' " + ENTER
IF CHKFILE("_SAL_TRAB")
	DBSELECTAREA("_SAL_TRAB")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_SAL_TRAB" NEW
IF ! _SAL_TRAB->(EOF())
	SALDO 	:= _SAL_TRAB->ZZM_SALDO
	SAL_INI := _SAL_TRAB->ZZM_SALDO
END IF
//_SAL_TRAB->(DBCLOSEAREA())



DEFINE DIALOG oDlg TITLE "COMPOSI«√O DE SALDO" FROM 180,180 TO 800	,1000 PIXEL

	oFont1  := TFont():New( "MS Sans Serif",0,-24,,.T.,0,,700,.F.,.F.,,,,,, )	
	oFont2  := TFont():New( "MS Sans Serif",0,-16,,.T.,0,,700,.F.,.F.,,,,,, )	
	oPanel1	:= TSCROLLBOX():NEW(oDlg,004,004,35,403,.T.,.T.,.T.)
	oSay1	:= TSay():New( 004,120,{||"COMPOSI«√O DE SALDO"},oPanel1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,160,016)

	DbSelectArea("SA6")
	DbSetOrder(1)
	If DbSeek(xFilial("SA6")+CBANCO+ALLTRIM(CAGENCIA)+ALLTRIM(CCONTA),.F.)
	   CNOME := ALLTRIM(SA6->A6_NOME)
	Endif	
	cCbanco := "MÍs: "+ SubStr(cMes,1,2) +"/"+ SubStr(cMes,4,4) +"   -  Banco: "+ALLTRIM(CBANCO)+" - "+CNOME+" Agencia: "+ALLTRIM(CAGENCIA)+" Conta "+ALLTRIM(CCONTA)+" "
	Say1	:= TSay():New( 022,004,{||cCbanco},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,250,007)
	Say1	:= TSay():New( 018,274,{||"Saldo Inicial: "+ALLTRIM(Transform(  SAL_INI ,"@E 999,999,999.99"))+" "},oPanel1,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,010)	



	oPane22	:= TSCROLLBOX():NEW(oDlg,040,004,270,403,.T.,.T.,.T.)
	oBrowse := TWBrowse():New( 005 , 005, 390,240,,{'','Data','MovimentaÁ„o','Valor','Saldo'},{20,50,150,0,80},oPane22,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	COMPOEM_SALDO() // ROTINA PARA MONTAR O BROWSE
	oBrowse:SetArray(aBrowse)
	oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02],;
	                      aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05] } }

	oBrowse:bLDblClick := {|| INC_MOV() }
	
	oTHButton := THButton():New(255,350,"EXCLUS√O",oPane22,{|| S_EXCLUI() },30,10,,"CONSULTA O SALDO DOS BANCOS ACIMA CONFIGURADO")     
 	oTHButton := THButton():New(255,10,"GERA SALDO BANCARIO",oPane22,{|| GER_SALDO() },90,10,,"GERA SALDO BANCARIO")
  ACTIVATE DIALOG oDlg CENTERED     

	
RETURN



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GER_SALDO         ≥ MADALENO           ∫ Data ≥  23/12/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ ROTINA PARA GERAR SALDO BANCARIO.                          ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC FUNCTION GER_SALDO()
PRIVATE SS
PRIVATE MES_GRAV

SS := SOMA1(SUBSTR(CMES,1,2))
IF SS = "13"
	MES_GRAV := SOMA1(SUBSTR(CMES,4,4)) + '0101'	
ELSE
	MES_GRAV := SUBSTR(CMES,4,4) + SOMA1(SUBSTR(CMES,1,2)) + '01'	
END IF

// BUSCANDO O SALDO DO PERIODO INFORMADO
CSQL 	:= "SELECT * " + ENTER
CSQL 	+= "FROM "+RETSQLNAME("ZZM")+" " + ENTER
CSQL 	+= "WHERE	ZZM_BANCO = '"+ALLTRIM(CBANCO)+"' AND " + ENTER
CSQL 	+= "		ZZM_AGENCI = '"+ALLTRIM(CAGENCIA)+"' AND  " + ENTER
CSQL 	+= "		ZZM_CONTA = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL 	+= "		ZZM_DATA = '"+MES_GRAV+"' AND " + ENTER
CSQL 	+= "		D_E_L_E_T_ = '' " + ENTER
IF CHKFILE("__AUX")
	DBSELECTAREA("__AUX")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "__AUX" NEW
IF ! __AUX->(EOF())
	ALERT("SALDO JA CADASTRADO")
	RETURN
END IF


DBSELECTAREA("ZZM")
RECLOCK('ZZM',.T.)
ZZM->ZZM_FILIAL := XFILIAL("ZZM")
ZZM->ZZM_BANCO	:= ALLTRIM(CBANCO)
ZZM->ZZM_AGENCI	:= ALLTRIM(CAGENCIA)
ZZM->ZZM_CONTA	:= ALLTRIM(CCONTA)
ZZM->ZZM_DATA	:= STOD(MES_GRAV)
ZZM->ZZM_SALDO	:= FINAL_SALDO
MsUnLock()


RETURN



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥S_EXCLUI          ≥ MADALENO           ∫ Data ≥  14/01/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ EXCLUSAO DOS REGISTROS LAN«ADOS MANUAIS                    ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC FUNCTION S_EXCLUI()
PRIVATE N_VALOR
PRIVATE S_HISTORICO
PRIVATE C_VALOR
PRIVATE CSQL := ""

C_VALOR := STRTRAN(   ALLTRIM(SUBSTR(aBrowse[oBrowse:nAt,04],3,30))  , ".","")
C_VALOR := STRTRAN(   C_VALOR  , ",",".")
S_HISTORICO := ALLTRIM(aBrowse[oBrowse:nAt,03])

IF cempant = "01"
	CSQL := "DELETE TBL_COMP_SALDO_01 WHERE VALOR = "+C_VALOR+" AND HISTORICO = '"+S_HISTORICO+"' "
ELSEIF  cempant = "05"
	CSQL := "DELETE TBL_COMP_SALDO_05 WHERE VALOR = "+C_VALOR+" AND HISTORICO = '"+S_HISTORICO+"' "
ELSE
	CSQL := "DELETE TBL_COMP_SALDO_07 WHERE VALOR = "+C_VALOR+" AND HISTORICO = '"+S_HISTORICO+"' "
END IF
TcSQLExec(CSQL)

SALDO 	:= _SAL_TRAB->ZZM_SALDO
SAL_INI := _SAL_TRAB->ZZM_SALDO

aBrowse   := {}
COMPOEM_SALDO()
oBrowse:SetArray(aBrowse)
	oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02],;
	                      aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05] } }
OBROWSE:DRAWSELECT()

RETURN


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥INC_MOV           ≥ MADALENO           ∫ Data ≥  14/01/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ INCLUSAO DE MOVIMENTO NUMA TABELA TEMPORARIA NO SQL        ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC FUNCTION INC_MOV()
PRIVATE CC_DATA 	:= CTOD("  /  /  ")
PRIVATE CC_HISTO 	:= SPACE(100)
PRIVATE CC_VALOR 	:= 0.00
PRIVATE aItems:= {'Credito','Debito'}



DEFINE DIALOG oDlg3 TITLE "Inserir MovimentaÁ„o" FROM 180,180 TO 470,550 PIXEL

	oFont1     	:= TFont():New( "MS Sans Serif",0,-24,,.T.,0,,700,.F.,.F.,,,,,, )
	oPanel1:= TSCROLLBOX():NEW(oDlg3,004,004,130,180,.T.,.T.,.T.)
	oSay1      	:= TSay():New( 001,002,{||"INCLUS√O DE MOVIMENTO"},oPanel1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,170,016)

	// CAMPO DATA
	oSay2      := TSay():New( 030,010,{||"MÍs e Ano"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
	oTGet2 := TGet():New( 028,050,{|u| If(PCount()>0,CC_DATA:=u,CC_DATA)},oPanel1,050,009,,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"CC_DATA",,)


	// CAMPO HISTO
	oSay2      := TSay():New( 050,010,{||"Historico"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
	oTGet2 := TGet():New( 048,050,{|u| If(PCount()>0,CC_HISTO:=u,CC_HISTO)},oPanel1,050,009,,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","CC_HISTO",,)	
	
	// CAMPO VALOR
	oSay2      := TSay():New( 070,010,{||"Valor"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
	oTGet2 := TGet():New( 068,050,{|u| If(PCount()>0,CC_VALOR:=u,CC_VALOR)},oPanel1,050,009,"@R 999,999,999.99",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","CC_VALOR",,)

	              
    // TIPO 
	oSay2      := TSay():New( 090,010,{||"Tipo"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
    cCombo1:= aItems[1]
    oCombo1 := TComboBox():New(090,050,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},;
                         aItems,50,20,oPanel1,,;
                         ,,,,.T.,,,,,,,,,'cCombo1')
                         
                         
	oTHButton := THButton():New(120,10,"CONFIRMA",oDlg3,{|| S_SALVA_MOV("CONFIRMA") },30,10,,"CONSULTA O SALDO DOS BANCOS ACIMA CONFIGURADO")                         
    oTHButton := THButton():New(120,140,"CANCELA",oDlg3,{|| S_SALVA_MOV("CANCELA") },30,10,,"CONSULTA O SALDO DOS BANCOS ACIMA CONFIGURADO")                     
 
ACTIVATE DIALOG oDlg3 CENTERED 


RETURN



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥S_SALVA_MOV       ≥ MADALENO           ∫ Data ≥  23/12/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ SALVA A INCLUSAO DO MOVIMENTO                              ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC FUNCTION  S_SALVA_MOV(SSSS)
PRIVATE CSQL := ""
PRIVATE CCC_VAL  

CCC_VAL := STRTRAN(ALLTRIM(STR(CC_VALOR)) , "X" , "X")
IF SSSS = "CONFIRMA"
	IF cempant = "01"
		CSQL := "INSERT INTO TBL_COMP_SALDO_01 "
	ELSEIF  cempant = "05"
		CSQL := "INSERT INTO TBL_COMP_SALDO_05 "
	ELSE
		CSQL := "INSERT INTO TBL_COMP_SALDO_07 "
	END IF
	
	CSQL += "			VALUES ('"+DTOS(CC_DATA)+"','"+ '***** ' +ALLTRIM(CC_HISTO)+"','"+CCC_VAL+"','"+ALLTRIM(cCombo1)+"','"+ALLTRIM(CBANCO)+"','"+ALLTRIM(CAGENCIA)+"','"+ALLTRIM(CCONTA)+"' ) "
	TcSQLExec(CSQL)
END IF

oDlg3:End()

SALDO 	:= _SAL_TRAB->ZZM_SALDO
SAL_INI := _SAL_TRAB->ZZM_SALDO
	
aBrowse   := {}
COMPOEM_SALDO()
oBrowse:SetArray(aBrowse)
	oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02],;
	                        aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05] } }
OBROWSE:DRAWSELECT()

RETURN




/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥COMPOEM_SALDO     ≥ MADALENO           ∫ Data ≥  23/12/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FUNCAO PARA MONTAR O SALDO                                 ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC FUNCTION COMPOEM_SALDO()
PRIVATE CSQL 	:= ""
PRIVATE ENTER	:= CHR(13)+CHR(10)

CSQL := " "
//CSQL += " -- BORDERO  " + ENTER
CSQL += "SELECT EA_NUMBOR, EA_DATABOR, SUM(VALOR) AS VALOR, MAX(TIPO) AS TIPO FROM " + ENTER 
CSQL += "		(SELECT 'Bordero: ' + EA_NUMBOR AS EA_NUMBOR, EA_DATABOR,  " + ENTER 
CSQL += "		VALOR = CASE WHEN E2_VALLIQ = 0 OR E2_TIPO = 'PA' THEN (EA_YVALOR) ELSE EA_YVALOR END,    " + ENTER 
CSQL += " 		'DEBITO' AS TIPO " + ENTER 
CSQL += "FROM "+RETSQLNAME("SEA")+" SEA, "+RETSQLNAME("SE2")+" SE2 " + ENTER 
CSQL += "WHERE	SUBSTRING(EA_DATABOR,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
CSQL += " 		EA_PORTADO = '"+ALLTRIM(CBANCO)+"' AND  " + ENTER
CSQL += " 		EA_AGEDEP = '"+ALLTRIM(CAGENCIA)+"' AND " + ENTER
CSQL += " 		EA_NUMCON = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL += " 		EA_CART = 'P' AND " + ENTER 
//CSQL += " 		E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA = EA_PREFIXO+EA_NUM+EA_PARCELA+EA_FORNECE+EA_LOJA AND  " + ENTER 
CSQL += " 		RTRIM(E2_PREFIXO)+RTRIM(E2_NUM)+RTRIM(E2_PARCELA)+RTRIM(E2_FORNECE)+RTRIM(E2_LOJA)+RTRIM(E2_TIPO) = RTRIM(EA_PREFIXO)+RTRIM(EA_NUM)+RTRIM(EA_PARCELA)+RTRIM(EA_FORNECE)+RTRIM(EA_LOJA)+RTRIM(EA_TIPO) AND  " + ENTER 
CSQL += " 		E2_FATURA IN ('      ','NOTFAT') AND " + ENTER 
CSQL += " 		SEA.D_E_L_E_T_ = '' AND " + ENTER 
CSQL += " 		SE2.D_E_L_E_T_ = '') AS ASS " + ENTER 
CSQL += "GROUP BY EA_NUMBOR, EA_DATABOR " + ENTER 

CSQL += "UNION ALL " + ENTER 

CSQL += "-- COBRANCA " + ENTER
CSQL += "SELECT 'COBRAN«A', E5_DTDISPO , SUM(E5_VALOR) AS VALOR, 'CREDITO' AS TIPO  " + ENTER
CSQL += "FROM "+RETSQLNAME("SE5")+" " + ENTER
CSQL += "WHERE	SUBSTRING(E5_DTDISPO,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
CSQL += "		E5_BANCO = '"+ALLTRIM(CBANCO)+"' AND  " + ENTER
CSQL += "		E5_AGENCIA = '"+ALLTRIM(CAGENCIA)+"' AND " + ENTER
CSQL += "		E5_CONTA = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL += "		E5_TIPODOC = '' AND " + ENTER
CSQL += "		E5_SITUACA <> 'C' AND " + ENTER
CSQL += "		E5_LOTE <> '' AND " + ENTER
CSQL += "		E5_RECPAG = 'R' AND " + ENTER
CSQL += "		D_E_L_E_T_ = '' " + ENTER
CSQL += "GROUP BY E5_DTDISPO " + ENTER

CSQL += "UNION ALL " + ENTER

CSQL += "-- TRANSFERENCIA RECEBER " + ENTER
CSQL += "SELECT E5_HISTOR, E5_DTDISPO , SUM(E5_VALOR) AS VALOR, 'CREDITO' AS TIPO  " + ENTER
CSQL += "FROM "+RETSQLNAME("SE5")+" " + ENTER
CSQL += "WHERE	SUBSTRING(E5_DTDISPO,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
CSQL += "		E5_BANCO = '"+ALLTRIM(CBANCO)+"' AND  " + ENTER
CSQL += "		E5_AGENCIA = '"+ALLTRIM(CAGENCIA)+"' AND " + ENTER
CSQL += "		E5_CONTA = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL += "		E5_TIPODOC IN ('TR','TE') AND " + ENTER
CSQL += "		E5_SITUACA <> 'C' AND " + ENTER
CSQL += "		E5_RECPAG = 'R' AND " + ENTER
CSQL += "		D_E_L_E_T_ = '' " + ENTER
CSQL += "GROUP BY E5_DTDISPO, E5_HISTOR " + ENTER

CSQL += "UNION ALL" + ENTER

CSQL += "-- TRANSFERENCIA PAGAR " + ENTER
CSQL += "SELECT E5_HISTOR, E5_DTDISPO , SUM(E5_VALOR) AS VALOR, 'DEBITO' AS TIPO  " + ENTER
CSQL += "FROM "+RETSQLNAME("SE5")+" " + ENTER
CSQL += "WHERE	SUBSTRING(E5_DTDISPO,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
CSQL += "		E5_BANCO = '"+ALLTRIM(CBANCO)+"' AND  " + ENTER
CSQL += "		E5_AGENCIA = '"+ALLTRIM(CAGENCIA)+"' AND " + ENTER
CSQL += "		E5_CONTA = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL += "		E5_TIPODOC IN ('TR','TE') AND " + ENTER
CSQL += "		E5_SITUACA <> 'C' AND " + ENTER
CSQL += "		E5_RECPAG = 'P' AND " + ENTER
CSQL += "		D_E_L_E_T_ = '' " + ENTER
CSQL += "GROUP BY E5_DTDISPO, E5_HISTOR " + ENTER

CSQL += "UNION ALL" + ENTER

CSQL += "-- TARIFAS BANCARIAS " + ENTER
CSQL += "SELECT E5_HISTOR, E5_DTDISPO , SUM(E5_VALOR) AS VALOR, 'DEBITO' AS TIPO  " + ENTER
CSQL += "FROM "+RETSQLNAME("SE5")+" " + ENTER
CSQL += "WHERE	SUBSTRING(E5_DTDISPO,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
CSQL += "		E5_BANCO = '"+ALLTRIM(CBANCO)+"' AND  " + ENTER
CSQL += "		E5_AGENCIA = '"+ALLTRIM(CAGENCIA)+"' AND " + ENTER
CSQL += "		E5_CONTA = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL += "		E5_TIPODOC = '' AND " + ENTER          
CSQL += "		E5_SITUACA <> 'C' AND " + ENTER
CSQL += "		E5_LOTE = '' AND " + ENTER
CSQL += "		E5_RECPAG = 'P' AND " + ENTER
CSQL += "		D_E_L_E_T_ = ''  " + ENTER
CSQL += "GROUP BY E5_DTDISPO, E5_HISTOR " + ENTER

CSQL += "UNION ALL" + ENTER

CSQL += "-- CHEQUE A PAGAR " + ENTER
CSQL += "SELECT HIST, E5_DTDISPO, SUM(VALOR) , MAX(TIPO) AS TIPO " + ENTER
CSQL += "FROM " + ENTER
CSQL += " " + ENTER
CSQL += "(SELECT	'CH ' + E5_BENEF AS HIST, E5_DTDISPO ,  " + ENTER
CSQL += "		VALOR = CASE WHEN E5_TIPODOC = 'CH' THEN  E5_VALOR ELSE  (E5_VALOR * -1)  END,  " + ENTER
CSQL += "		'DEBITO' AS TIPO  " + ENTER
CSQL += "FROM "+RETSQLNAME("SE5")+" " + ENTER
CSQL += "WHERE	SUBSTRING(E5_DTDISPO,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
CSQL += "		E5_BANCO = '"+ALLTRIM(CBANCO)+"' AND  " + ENTER
CSQL += "		E5_AGENCIA = '"+ALLTRIM(CAGENCIA)+"' AND " + ENTER
CSQL += "		E5_CONTA = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL += "		E5_TIPODOC IN('CH', 'EC') AND " + ENTER 
CSQL += "		E5_SITUACA <> 'C' AND " + ENTER
CSQL += "		--E5_LOTE = '' AND " + ENTER
CSQL += "		E5_RECPAG = 'P' AND " + ENTER
CSQL += "		D_E_L_E_T_ = ''  " + ENTER

CSQL += "UNION ALL " + ENTER

CSQL += "-- CANCELAMENTOS DOS CHEQUES " + ENTER
CSQL += "SELECT	'CH ' + E5_BENEF AS HIST, E5_DTDISPO ,  " + ENTER
CSQL += "		(E5_VALOR * -1) AS VALOR ,  " + ENTER
CSQL += "		'DEBITO' AS TIPO  " + ENTER
CSQL += "FROM "+RETSQLNAME("SE5")+" " + ENTER
CSQL += "WHERE	SUBSTRING(E5_DTDISPO,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
CSQL += "		E5_BANCO = '"+ALLTRIM(CBANCO)+"' AND  " + ENTER
CSQL += "		E5_AGENCIA = '"+ALLTRIM(CAGENCIA)+"' AND " + ENTER
CSQL += "		E5_CONTA = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL += "		E5_TIPODOC IN('CH', 'EC') AND " + ENTER 
CSQL += "		E5_SITUACA <> 'C' AND " + ENTER
CSQL += "		--E5_LOTE = '' AND " + ENTER
CSQL += "		E5_RECPAG = 'R' AND " + ENTER
CSQL += "		D_E_L_E_T_ = '' ) AS SSS " + ENTER
CSQL += "GROUP BY E5_DTDISPO, HIST " + ENTER

CSQL += "UNION ALL" + ENTER

  // Tiago Rossini - OS: 0163-12 - Alessa Feliciano
  // Controle de recebimentos entre as empresas do grupo
	If (cEmpAnt == "01" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "0013431255.097-3") .Or. ; // Recebimento da Biancogress somente sera executado para o banco do brasil na agencia:34312 e conta:55.097-3
		 (cEmpAnt == "05" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "001343125.666-9") .Or. ; // Recebimento da Incesa somente sera executado para o banco do brasil na agencia:34312 e conta:5.666-9
		 (cEmpAnt == "06" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "0013431255.098-1") .Or. ; // Recebimento da JK somente sera executado para o banco do brasil na agencia:34312 e conta:55.098-1
		 (cEmpAnt == "07" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "0013431252868") .Or. ; // Recebimento da LM somente sera executado para o banco do brasil na agencia:34312 e conta:52868
		 (cEmpAnt == "12" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "0013431254968") .Or. ; // Recebimento da ST Gest„o somente sera executado para o banco do brasil na agencia:34312 e conta:54968
		 (cEmpAnt == "13" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "0013431254666") .Or. ; // Recebimento da Mundi somente sera executado para o banco do brasil na agencia:34312 e conta:54666
		 (cEmpAnt == "14" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "001343148755") // Recebimento da Vitcer somente sera executado para o banco do brasil na agencia:3431 e conta:48755
			
		cSQL += fGetRec(cEmpAnt)
		
	EndIf


CSQL += "-- ROTINA LANCAMENTO MANUAL " + ENTER
CSQL += "SELECT E5_HISTOR, E5_DTDISPO , SUM(E5_VALOR) AS VALOR, 'CREDITO' AS TIPO  " + ENTER
CSQL += "FROM "+RETSQLNAME("SE5")+" " + ENTER
CSQL += "WHERE	SUBSTRING(E5_DTDISPO,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
CSQL += "		E5_BANCO = '"+ALLTRIM(CBANCO)+"' AND  " + ENTER
CSQL += "		E5_AGENCIA = '"+ALLTRIM(CAGENCIA)+"' AND " + ENTER
CSQL += "		E5_CONTA = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL += "		E5_TIPODOC = '' AND " + ENTER             
CSQL += "		E5_SITUACA <> 'C' AND " + ENTER
CSQL += "		E5_LOTE = '' AND " + ENTER
CSQL += "		E5_RECPAG = 'R' AND " + ENTER
CSQL += "		D_E_L_E_T_ = '' " + ENTER
CSQL += "GROUP BY E5_HISTOR, E5_DTDISPO " + ENTER

CSQL += "UNION ALL " + ENTER
	
CSQL += "-- PAGAMENTO ANTECIPADO CHEQUE" + ENTER
CSQL += "SELECT E5_HISTOR, E5_DTDISPO , SUM(E5_VALOR) AS VALOR, 'DEBITO' AS TIPO FROM "+RETSQLNAME("SE5")+" " + ENTER
CSQL += "WHERE	SUBSTRING(E5_DTDISPO,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
CSQL += "		E5_BANCO = '"+ALLTRIM(CBANCO)+"' AND  " + ENTER
CSQL += "		E5_AGENCIA = '"+ALLTRIM(CAGENCIA)+"' AND " + ENTER
CSQL += "		E5_CONTA = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL += "		E5_TIPODOC IN('PA') AND " + ENTER
CSQL += "		E5_SITUACA <> 'C' AND " + ENTER
CSQL += "		E5_NUMCHEQ <> '' AND " + ENTER
CSQL += "		E5_RECPAG = 'P' AND " + ENTER
CSQL += "		D_E_L_E_T_ = '' " + ENTER
CSQL += "GROUP BY E5_HISTOR, E5_DTDISPO " + ENTER

CSQL += "UNION ALL" + ENTER

CSQL += "-- PAGAMENTO DARF  E PAGAMENTO ANTECIPADO FOI INCLUIDO O FILTRO TIPO <> '' PARA DESCONSIDERAR AS PA CANCELADAS " + ENTER
CSQL += "SELECT E5_HISTOR, E5_DTDISPO , SUM(E5_VALOR) AS VALOR, 'DEBITO' AS TIPO  " + ENTER
CSQL += "FROM "+RETSQLNAME("SE5")+" " + ENTER
CSQL += "WHERE	SUBSTRING(E5_DTDISPO,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
CSQL += "		E5_BANCO = '"+ALLTRIM(CBANCO)+"' AND  " + ENTER
CSQL += "		E5_AGENCIA = '"+ALLTRIM(CAGENCIA)+"' AND " + ENTER
CSQL += "		E5_CONTA = '"+ALLTRIM(CCONTA)+"' AND " + ENTER
CSQL += "		E5_SITUACA <> 'C' AND " + ENTER
CSQL += "		E5_CLIFOR = 'DARF' AND -- TIRANDO O FORNECEDOR INCESA " + ENTER
CSQL += "		E5_LOTE = '' AND " + ENTER
CSQL += "		E5_RECPAG = 'P' AND " + ENTER
CSQL += "		D_E_L_E_T_ = ''   AND E5_NUMCHEQ = ''  AND E5_TIPO NOT IN ('','PA') " + ENTER
CSQL += "GROUP BY E5_DTDISPO, E5_HISTOR " + ENTER

CSQL += "UNION ALL" + ENTER

/*
// FOLHA DE PAGAMENTO SO SERA EXECUTADA NA BIANCOP E NO BANCO DO BRASIL BANCO-AGENCIA-CONTA (0013431255.097-3)
IF CEMPANT = "01" .AND. (ALLTRIM(CBANCO)+ALLTRIM(CAGENCIA)+ALLTRIM(CCONTA) ) = "0013431255.097-3"
		CSQL += "-- FERIAS " + ENTER
		CSQL += "SELECT	E2_FORNECE, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO " + ENTER 
		CSQL += "FROM SE2010 SE2 " + ENTER 
		CSQL += "WHERE	SUBSTRING(E2_VENCREA,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
		CSQL += "		E2_TIPO = 'FER' AND " + ENTER 
		CSQL += "		E2_NUMBCO = '' AND " + ENTER
		CSQL += "		SE2.D_E_L_E_T_ = '' " + ENTER 
		CSQL += "UNION ALL" + ENTER
		CSQL += "-- FOLHA DE PAGAMENTO " + ENTER
		CSQL += "SELECT	RTRIM(E2_FORNECE) + ' - ' + E2_NOMFOR AS HIST, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO " + ENTER
		CSQL += "FROM SE2010 SE2 " + ENTER
		CSQL += "WHERE	SUBSTRING(E2_VENCREA,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
		CSQL += "		E2_TIPO IN ('FOL') AND " + ENTER
		CSQL += "		E2_NUMBCO = '' AND " + ENTER
		CSQL += "		SE2.D_E_L_E_T_ = '' " + ENTER
		CSQL += "UNION ALL " + ENTER
		CSQL += "-- RESCIS√O E EMPRESTIMO E DECIMO TERCEIRRO SALARIO " + ENTER
		CSQL += "SELECT	E2_FORNECE, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO " + ENTER
		CSQL += "FROM SE2010 SE2 " + ENTER
		CSQL += "WHERE	SUBSTRING(E2_VENCREA,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
		CSQL += "		E2_TIPO IN ('RES','ADI','132','INS','131') AND " + ENTER
		CSQL += "		E2_NUMBCO = '' AND " + ENTER
		CSQL += "		E2_FORNECE IN ('INSS','PARC13','RESCIS','EMPRES','INPS','ADTOSL') AND " + ENTER
		CSQL += "		SE2.D_E_L_E_T_ = '' " + ENTER
		CSQL += "UNION ALL" + ENTER
ELSEIF CEMPANT = "05" .AND. (ALLTRIM(CBANCO)+ALLTRIM(CAGENCIA)+ALLTRIM(CCONTA) ) == "001343125.666-9"  //= "02155210.532.885" ALTERADO EM 13/06/13 DEVIDO ALTERACAO PAGAMENTO FOLHA PARA O BB
		CSQL += "-- FERIAS " + ENTER
		CSQL += "SELECT	E2_FORNECE, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO " + ENTER 
		CSQL += "FROM SE2050 SE2 " + ENTER 
		CSQL += "WHERE	SUBSTRING(E2_VENCREA,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
		CSQL += "		E2_TIPO = 'FER' AND " + ENTER 
		CSQL += "		SE2.D_E_L_E_T_ = '' " + ENTER 
		CSQL += "UNION ALL" + ENTER
		CSQL += "-- FOLHA DE PAGAMENTO " + ENTER
		CSQL += "SELECT	RTRIM(E2_FORNECE) + ' - ' + E2_NOMFOR AS HIST, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO " + ENTER
		CSQL += "FROM SE2050 SE2 " + ENTER
		CSQL += "WHERE	SUBSTRING(E2_VENCREA,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
		CSQL += "		E2_TIPO IN ('FOL') AND " + ENTER
		CSQL += "		E2_NUMBCO = '' AND " + ENTER
		CSQL += "		SE2.D_E_L_E_T_ = '' " + ENTER
		CSQL += "UNION ALL " + ENTER
		CSQL += "-- RESCIS√O E EMPRESTIMO E DECIMO TERCEIRRO SALARIO " + ENTER
		CSQL += "SELECT	E2_FORNECE, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO " + ENTER
		CSQL += "FROM SE2050 SE2 " + ENTER
		CSQL += "WHERE	SUBSTRING(E2_VENCREA,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
		CSQL += "		E2_TIPO IN ('RES','ADI','132','INS','131') AND " + ENTER
		CSQL += "		E2_NUMBCO = '' AND " + ENTER
		CSQL += "		E2_FORNECE IN ('INSS','PARC13','RESCIS','EMPRES','INPS','ADTOSL') AND " + ENTER
		CSQL += "		SE2.D_E_L_E_T_ = '' " + ENTER
		CSQL += "UNION ALL" + ENTER		
END IF
*/


  // Tiago Rossini - OS: 0163-12 - Alessa Feliciano
  // Controle de folha de pagamento
	If (cEmpAnt == "01" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "0013431255.097-3") .Or. ; // Folha de pagamento da Biancogress somente sera executado para o banco do brasil na agencia:34312 e conta:55.097-3
		 (cEmpAnt == "05" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "001343125.666-9") .Or. ; // Folha de pagamento da Incesa somente sera executado para o banco do brasil na agencia:34312 e conta:5.666-9
		 (cEmpAnt == "06" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "0013431255.098-1") .Or. ; // Folha de pagamentoda da JK somente sera executado para o banco do brasil na agencia:34312 e conta:55.098-1
		 (cEmpAnt == "13" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "0013431254666") .Or. ; // Folha de pagamento da Mundi somente sera executado para o banco do brasil na agencia:34312 e conta:54666
		 (cEmpAnt == "14" .And. Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) == "001343148755") // Folha de pagamentoda da Vitcer somente sera executado para o banco do brasil na agencia:3431 e conta:48755
 
		 			
		cSQL += "-- FERIAS " + ENTER
		cSQL += "SELECT	E2_FORNECE, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO " + ENTER 
		cSQL += "FROM "+ RetSQLName("SE2") +" SE2 " + ENTER 
		cSQL += "WHERE	SUBSTRING(E2_VENCREA,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
		cSQL += "		E2_TIPO = 'FER' AND " + ENTER 
		cSQL += "		E2_NUMBCO = '' AND " + ENTER
		cSQL += "		SE2.D_E_L_E_T_ = '' " + ENTER 
		
		cSQL += "UNION ALL" + ENTER
		
		cSQL += "-- FOLHA DE PAGAMENTO " + ENTER
		cSQL += "SELECT	RTRIM(E2_FORNECE) + ' - ' + E2_NOMFOR AS HIST, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO " + ENTER
		cSQL += "FROM "+ RetSQLName("SE2") +" SE2 " + ENTER
		cSQL += "WHERE	SUBSTRING(E2_VENCREA,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
		cSQL += "		E2_TIPO IN ('FOL') AND " + ENTER
		cSQL += "		E2_NUMBCO = '' AND " + ENTER
		cSQL += "		SE2.D_E_L_E_T_ = '' " + ENTER
		
		cSQL += "UNION ALL " + ENTER
		
		cSQL += "-- RESCIS√O E EMPRESTIMO E DECIMO TERCEIRRO SALARIO " + ENTER
		cSQL += "SELECT	E2_FORNECE, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO " + ENTER
		cSQL += "FROM "+ RetSQLName("SE2") +" SE2 " + ENTER
		cSQL += "WHERE	SUBSTRING(E2_VENCREA,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
		cSQL += "		E2_TIPO IN ('RES','ADI','132','INS','131') AND " + ENTER
		cSQL += "		E2_NUMBCO = '' AND " + ENTER
		cSQL += "		E2_FORNECE IN ('INSS','PARC13','RESCIS','EMPRES','INPS','ADTOSL') AND " + ENTER
		cSQL += "		SE2.D_E_L_E_T_ = '' " + ENTER
		
		cSQL += "UNION ALL" + ENTER
		
	EndIf


CSQL += "-- TABELA PARA QUE GRAVA OS LANCAMENTOS MANUAIS " + ENTER
CSQL += "SELECT HISTORICO, DATA, VALOR, TIPO " + ENTER
IF cempant = "01"
	CSQL += " FROM TBL_COMP_SALDO_01 " + ENTER
ELSEIF  cempant = "05"
	CSQL += " FROM TBL_COMP_SALDO_05 " + ENTER
ELSE
	CSQL += " FROM TBL_COMP_SALDO_07 " + ENTER
END IF
CSQL += "WHERE	SUBSTRING(DATA,1,6) BETWEEN '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND '"+SUBSTR(CMES,4,4) + SUBSTR(CMES,1,2)+"' AND " + ENTER
CSQL += "		BANCO = '"+ALLTRIM(CBANCO)+"' AND  " + ENTER
CSQL += "		AGENCIA = '"+ALLTRIM(CAGENCIA)+"' AND " + ENTER
CSQL += "		CONTA = '"+ALLTRIM(CCONTA)+"' " + ENTER


CSQL += "ORDER BY EA_DATABOR, TIPO, EA_NUMBOR " + ENTER

IF CHKFILE("_TRAB")
	DBSELECTAREA("_TRAB")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_TRAB" NEW



NTOTA := 0
dDATA_MOV := ""
IF _TRAB->(EOF())
		aAdd(aBrowse,{.F., "" , "" , "R$ 0,0" , "R$ 0,0" })	
		RETURN		
END IF
IF ! _TRAB->(EOF())

	dDATA_MOV := _TRAB->EA_DATABOR
	
	IF UPPER(ALLTRIM(_TRAB->TIPO)) = "DEBITO"
		SALDO := SALDO - _TRAB->VALOR
		aAdd(aBrowse,{.F., DTOC(STOD(_TRAB->EA_DATABOR)) , _TRAB->EA_NUMBOR , "R$" + (Transform(  _TRAB->VALOR ,"@E 999,999,999,999.99")) , "R$" + (Transform(  SALDO ,"@E 999,999,999,999.99")) })	
	ELSE
	   	SALDO := SALDO + _TRAB->VALOR
		aAdd(aBrowse,{.T., DTOC(STOD(_TRAB->EA_DATABOR)) , _TRAB->EA_NUMBOR , "R$" + (Transform(  _TRAB->VALOR ,"@E 999,999,999,999.99")) , "R$" + (Transform(  SALDO ,"@E 999,999,999,999.99")) })	
    END IF

	_TRAB->(DBSKIP())
END IF

DO WHILE ! _TRAB->(EOF())
	
	
	IF dDATA_MOV <> _TRAB->EA_DATABOR
		dDATA_MOV := _TRAB->EA_DATABOR

     	IF UPPER(ALLTRIM(_TRAB->TIPO)) = "DEBITO"
	     	SALDO := SALDO - _TRAB->VALOR
     		aAdd(aBrowse,{.F., DTOC(STOD(_TRAB->EA_DATABOR)) , _TRAB->EA_NUMBOR ,  "R$" + (Transform(  _TRAB->VALOR ,"@E 999,999,999,999.99"))  , "R$" + (Transform(  SALDO ,"@E 999,999,999,999.99")) })	
     	ELSE
	     	SALDO := SALDO + _TRAB->VALOR
			aAdd(aBrowse,{.T., DTOC(STOD(_TRAB->EA_DATABOR)) , _TRAB->EA_NUMBOR ,  "R$" + (Transform(  _TRAB->VALOR ,"@E 999,999,999,999.99"))  , "R$" + (Transform(  SALDO ,"@E 999,999,999,999.99")) })	
     	END IF

    ELSE
     	IF UPPER(ALLTRIM(_TRAB->TIPO)) = "DEBITO"
	     	SALDO := SALDO - _TRAB->VALOR
     		aAdd(aBrowse,{.F., ' - ' , _TRAB->EA_NUMBOR ,  "R$" + (Transform(  _TRAB->VALOR ,"@E 999,999,999,999.99"))  , "R$" + (Transform(  SALDO ,"@E 999,999,999,999.99")) })	
     	ELSE
	     	SALDO := SALDO + _TRAB->VALOR
			aAdd(aBrowse,{.T., ' - ' , _TRAB->EA_NUMBOR ,  "R$" + (Transform(  _TRAB->VALOR ,"@E 999,999,999,999.99"))  , "R$" + (Transform(  SALDO ,"@E 999,999,999,999.99")) })	
     	END IF
     			
    END IF
   
	_TRAB->(DBSKIP())
END DO
FINAL_SALDO := SALDO
RETURN


 // Retorna SQL para recebimentos por empresas do grupo
Static Function fGetRec(cEmpOri)
Local cSQL := ""
Local aEmp := {}
Local cCodFor := ""
	
	If !cEmpOri == "01"
		aAdd(aEmp, "01")
	Else
		cCodFor := "000534"
	EndIf

	If !cEmpOri == "05"
		aAdd(aEmp, "05")
	Else
		cCodFor := "002912"
	EndIf
	
	If !cEmpOri == "06"
		aAdd(aEmp, "06")
	Else
		cCodFor := "007437"
	EndIf
	
	If !cEmpOri == "07"
		aAdd(aEmp, "07")
	Else
		cCodFor := "007602"
	EndIf
	
	If !cEmpOri == "12"
		aAdd(aEmp, "12")
	Else
		cCodFor := "004890"
	EndIf
	
	If !cEmpOri == "13"
		aAdd(aEmp, "13")
	Else
		cCodFor := "004695"	
	EndIf
	
	If !cEmpOri == "14"
		aAdd(aEmp, "14")
	Else
		cCodFor := "003721"	
	EndIf
		
	cSQL += fGetSQLRec(aEmp, cCodFor)	
	
Return(cSQL)


// Retorna SQL para recebimentos por empresa
Static Function fGetSQLRec(aEmp, cCodFor)
Local cSQL := ""
Local nCount := 0
Local cDsc := "'
Local cSEA := ""
Local cSE2 := ""

	For nCount := 1 To Len(aEmp)
	
		cDsc := "Rec. "+ Capital(FWEmpName(aEmp[nCount])) + Space(1)
		cSEA := "SEA"+aEmp[nCount]+"0"
		cSE2 := "SE2"+aEmp[nCount]+"0"	

		cSQL += " SELECT HIST, EA_DATABOR, SUM(VALOR) AS VALOR, 'CREDITO' AS TIPO "
		cSQL += " FROM ( "
		cSQL += " 	SELECT	"+ ValToSQL(cDsc) +" + EA_NUMBOR AS HIST, EA_DATABOR, "
		cSQL += "		VALOR = CASE WHEN E2_SALDO > 0 THEN E2_SALDO ELSE E2_VALOR END, "
		cSQL += "		'DEBITO' AS TIPO "
		cSQL += " 	FROM "+ cSEA +" SEA, "+ cSE2 +" SE2 "
		cSQL += " 	WHERE SUBSTRING(EA_DATABOR,1,6) BETWEEN "+ ValToSQL(SubStr(cMes,4,4) + SubStr(cMes,1,2)) +" AND "+ ValToSQL(SubStr(cMes,4,4) + SubStr(cMEs,1,2))
		cSQL += "		AND EA_PORTADO = "+ ValToSQL(Alltrim(cBanco))
		
		// Tratamento especifico para Vitcer, pois a agencia È diferente das demais empresas do grupo
		If cEmpAnt == "14"
			cSQL += "		AND EA_AGEDEP = '34312' "
		ElseIf aEmp[nCount] == "14"
			cSQL += "		AND EA_AGEDEP = '3431' "
		Else
			cSQL += "		AND EA_AGEDEP = "+ ValToSQL(Alltrim(cAgencia))
		EndIf
				
		cSQL += "		AND EA_FORNECE = "+ ValToSQL(Alltrim(cCodFor))
		cSQL += "		AND EA_CART = 'P' "
		cSQL += "		AND RTRIM(E2_PREFIXO)+RTRIM(E2_NUM)+RTRIM(E2_PARCELA)+RTRIM(E2_FORNECE)+RTRIM(E2_LOJA)+RTRIM(E2_TIPO) = RTRIM(EA_PREFIXO)+RTRIM(EA_NUM)+RTRIM(EA_PARCELA)+RTRIM(EA_FORNECE)+RTRIM(EA_LOJA)+RTRIM(EA_TIPO) "
		cSQL += "		AND SEA.D_E_L_E_T_ = '' "
		cSQL += "		AND SE2.D_E_L_E_T_ = '') AS TT "
		cSQL += "GROUP BY HIST, EA_DATABOR "
	
		cSQL += "UNION ALL "
		
	Next
	
Return(cSQL)