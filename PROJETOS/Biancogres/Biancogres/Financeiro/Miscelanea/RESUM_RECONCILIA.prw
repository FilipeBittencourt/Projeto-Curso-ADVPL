#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ RESUM_RECONCILIA บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  06/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ RESUMO NA TELA DE RECONCILIACAO BANCARIA                           บฑฑ
ฑฑบ          ณ											                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ AP 8                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION RESUM_RECONCILIA()
LOCAL CSQL := ""
LOCAL I := 1
PRIVATE ENTER	:= CHR(13)+CHR(10)
PRIVATE NSALDOANTERIOR := 0
PRIVATE NSALDOATUAL := 0
PRIVATE NTOT_REC := 0
PRIVATE NTOT_PAG := 0

PRIVATE NQUANT_REC := 0
PRIVATE NVAL_REC := 0
PRIVATE NQUANT_PAG := 0
PRIVATE NVAL_PAG := 0
PRIVATE NNVALOR

IF CHKFILE("_SALD_ANTE")
	RETURN
END IF
IF UPPER(ALLTRIM(FUNNAME())) <> "FINA470" 
	RETURN
END IF

// BUSCANDO O SALDO ANTERIOR 
I := 1
IF ALLTRIM(TRB->AGEMOV) <> ""
	__AG := TRB->AGEMOV
	__CT := TRB->CTAMOV
ELSE
	__AG := TRB->AGESE5
	__CT := TRB->CTASE5
END IF
DO WHILE I < 1000

	CSQL := "SELECT  ISNULL(SUM(E8_SALATUA),0) AS SALDO  " + ENTER
	CSQL += "FROM SE8010 " + ENTER
	CSQL += "WHERE 	E8_BANCO = '"+MV_PAR03+"' AND " + ENTER
	CSQL += "		E8_AGENCIA = '"+__AG+"' AND " + ENTER
	CSQL += "		E8_CONTA = '"+__CT+"' AND " + ENTER
	CSQL += "		E8_DTSALAT =  CONVERT(INT,CONVERT(VARCHAR(8), DATEADD(D,-"+ALLTRIM(STR(I))+",'"+DTOS(MV_PAR09)+"' ) ,112)) AND " + ENTER
	CSQL += "		D_E_L_E_T_ = '' " + ENTER
	IF CHKFILE("_SALD_ANTE")
		DBSELECTAREA("_SALD_ANTE")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_SALD_ANTE" NEW	
	
	IF _SALD_ANTE->SALDO <> 0
		NSALDOANTERIOR := _SALD_ANTE->SALDO
		I := 10001
	END IF
	I ++
END DO

// BUSCANDO O SALDO ATUAL 
I := 0
DO WHILE I < 1000

	CSQL := "SELECT  ISNULL(SUM(E8_SALATUA),0) AS SALDO  " + ENTER
	CSQL += "FROM SE8010 " + ENTER
	CSQL += "WHERE 	E8_BANCO = '"+MV_PAR03+"' AND " + ENTER
	CSQL += "		E8_AGENCIA = '"+__AG+"' AND " + ENTER
	CSQL += "		E8_CONTA = '"+__CT+"' AND " + ENTER
	CSQL += "		E8_DTSALAT =  CONVERT(INT,CONVERT(VARCHAR(8), DATEADD(D,-"+ALLTRIM(STR(I))+",'"+DTOS(MV_PAR10)+"' ) ,112)) AND " + ENTER
	CSQL += "		D_E_L_E_T_ = '' " + ENTER
	IF CHKFILE("_SALD_ANTE")
		DBSELECTAREA("_SALD_ANTE")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_SALD_ANTE" NEW	
	
	IF _SALD_ANTE->SALDO <> 0
		NSALDOATUAL := _SALD_ANTE->SALDO
		I := 10001
	END IF
	I ++
END DO



// BUSCANDO O TOTAL RECEBIDO
CSQL := "SELECT ISNULL(SUM(E5_VALOR),0) AS TOTAL  " + ENTER
CSQL += "FROM SE5010 " + ENTER
CSQL += "WHERE	E5_DTDISPO BETWEEN '"+DTOS(MV_PAR09)+"' AND '"+DTOS(MV_PAR10)+"' AND " + ENTER
CSQL += "		E5_BANCO = '"+MV_PAR03+"' AND " + ENTER
CSQL += "		E5_AGENCIA = '"+__AG+"' AND " + ENTER
CSQL += "		E5_CONTA = '"+__CT+"' AND " + ENTER
CSQL += "		E5_RECPAG = 'R' AND  " + ENTER
CSQL += "		D_E_L_E_T_ = ''   " + ENTER
CSQL += "		AND E5_TIPODOC NOT IN('JR','DC','J2','TL','D2','MT','M2','CM','C2','CP','BA','V2') " + ENTER
CSQL += "		AND E5_RECONC = '' " + ENTER
IF CHKFILE("_TOT_REC")
	DBSELECTAREA("_TOT_REC")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_TOT_REC" NEW	
NTOT_REC := _TOT_REC->TOTAL

// BUSCANDO O TOTAL PAGO
CSQL := "SELECT ISNULL(SUM(E5_VALOR),0) AS TOTAL  " + ENTER
CSQL += "FROM SE5010 " + ENTER
CSQL += "WHERE	E5_DTDISPO BETWEEN '"+DTOS(MV_PAR09)+"' AND '"+DTOS(MV_PAR10)+"' AND " + ENTER
CSQL += "		E5_BANCO = '"+MV_PAR03+"' AND " + ENTER
CSQL += "		E5_AGENCIA = '"+__AG+"' AND " + ENTER
CSQL += "		E5_CONTA = '"+__CT+"' AND " + ENTER
CSQL += "		E5_RECPAG = 'P' AND  " + ENTER
CSQL += "		D_E_L_E_T_ = ''   " + ENTER
CSQL += "		AND E5_TIPODOC NOT IN('JR','DC','J2','TL','D2','MT','M2','CM','C2','CP','BA','V2') " + ENTER
CSQL += "		AND E5_RECONC = '' " + ENTER
IF CHKFILE("_TOT_PAG")
	DBSELECTAREA("_TOT_PAG")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_TOT_PAG" NEW	
NTOT_PAG := _TOT_PAG->TOTAL



TRB->(DBGOTOP())
DO WHILE ! TRB->(EOF())
	NNVALOR := STRTRAN(   ALLTRIM(TRB->VALORMOV)  ,  "." ,  "" )
	NNVALOR := STRTRAN(   NNVALOR  ,  "," ,  "." )
	NNVALOR := VAL(NNVALOR)
	IF TRB->OK = 1
		IF TRB->DEBCRED = "C"
			NQUANT_REC 	:= NQUANT_REC + 1
			NVAL_REC 	+= NNVALOR
		ELSE
			NQUANT_PAG 	:= NQUANT_REC + 1
			NVAL_PAG 	+= NNVALOR 		
		END IF
		
	END IF
  TRB->(DBSKIP())
END DO
TRB->(DBGOTOP())
MONTA_RESU()
RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ MONTA_RESU       บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  06/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ MONTA A TELA DE RESUMO DA CONCILIACAO BANCARIA AUTOMATICA          บฑฑ
ฑฑบ          ณ											                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION MONTA_RESU()

PRIVATE CN_QUANTPA := TRANSFORM(NQUANT_PAG,'@E 999,999,999.99')
PRIVATE CN_QUANTRE := TRANSFORM(NQUANT_REC,'@E 999,999,999.99')
PRIVATE CN_SALDOAN := TRANSFORM(NSALDOANTERIOR,'@E 999,999,999.99')
PRIVATE CN_SALDOAT := TRANSFORM(NSALDOATUAL,'@E 999,999,999.99')
PRIVATE CN_TOTPAGO := TRANSFORM(NTOT_PAG ,'@E 999,999,999.99') 
PRIVATE CN_TOTREC  := TRANSFORM(NTOT_REC ,'@E 999,999,999.99') 
PRIVATE CN_VALTPAG := TRANSFORM(NVAL_PAG ,'@E 999,999,999.99') 
PRIVATE CN_VALTREC := TRANSFORM(NVAL_REC ,'@E 999,999,999.99') 

SETPRVT("OFONTTEXTO","OFONTDADOS","OFONTTITULO","ODLG1","OPANEL1","OSAY1","OSAY3","OSAY4","OSAY2","OSAY5")
SETPRVT("OSAY7","OSAY8","OSAY9","OGET1","OGET2","OGET3","OGET4","OGET5","OGET6","OGET7","OGET8")

OFONTTEXTO := TFONT():NEW( "ARIAL",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )
OFONTDADOS := TFONT():NEW( "MS SANS SERIF",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )
OFONTTITUL := TFONT():NEW( "MS SANS SERIF",0,-24,,.T.,0,,700,.F.,.F.,,,,,, )
ODLG1      := MSDIALOG():NEW( 100,237,349,974,"RESUMO RECONCILIAวรO BANCARIA",,,.F.,,,,,,.T.,,,.T. )

oDlg1:bInit := {||EnchoiceBar(oDlg1,{||oDlg1:End(FECHA_TAB())},{||oDlg1:End(FECHA_TAB())},.F.,{})}

OPANEL1    := TPANEL():NEW( 016,004,"",ODLG1,,.F.,.F.,,,356,100,.T.,.F. )
OSAY1      := TSAY():NEW( 037,008,{||"SALDO ANTERIOR"},OPANEL1,,OFONTTEXTO,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,096,008)
OSAY3      := TSAY():NEW( 053,008,{||"TOTAL RECEBIDO"},OPANEL1,,OFONTTEXTO,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,096,008)
OSAY4      := TSAY():NEW( 069,008,{||"DADOS RECONCILIADOS A RECEBER"},OPANEL1,,OFONTTEXTO,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,096,008)
OSAY2      := TSAY():NEW( 085,008,{||"DADOS RECONCILIADOS A PAGAR"},OPANEL1,,OFONTTEXTO,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,096,008)
OSAY5      := TSAY():NEW( 084,185,{||"VALOR PAGO"},OPANEL1,,OFONTTEXTO,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,096,008)
OSAY6      := TSAY():NEW( 068,185,{||"VALOR RECEBIDO"},OPANEL1,,OFONTTEXTO,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,096,008)
OSAY7      := TSAY():NEW( 052,185,{||"TOTAL PAGO"},OPANEL1,,OFONTTEXTO,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,096,008)
OSAY8      := TSAY():NEW( 036,185,{||"SALDO ATUAL"},OPANEL1,,OFONTTEXTO,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,096,008)
OSAY9      := TSAY():NEW( 008,064,{||"RESUMO DA CONCILIAวรO BANCARIA"},OPANEL1,,OFONTTITULO,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,248,016)

oGet1      := TGet():New( 036,110,{|u| If(PCount()>0,cN_SALDOAN:=u,cN_SALDOAN)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,oFontDADOS,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cN_SALDOAN",,)
oGet2      := TGet():New( 052,110,{|u| If(PCount()>0,cN_TOTREC:=u,cN_TOTREC)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,oFontDADOS,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cN_TOTREC",,)
oGet3      := TGet():New( 084,110,{|u| If(PCount()>0,cN_QUANTPAGA:=u,cN_QUANTPAGA)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,oFontDADOS,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cN_QUANTPAGA",,)
oGet4      := TGet():New( 068,110,{|u| If(PCount()>0,cN_QUANTREC:=u,cN_QUANTREC)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,oFontDADOS,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cN_QUANTREC",,)
oGet5      := TGet():New( 083,287,{|u| If(PCount()>0,cN_VALTPAGO:=u,cN_VALTPAGO)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,oFontDADOS,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cN_VALTPAGO",,)
oGet6      := TGet():New( 067,287,{|u| If(PCount()>0,cN_VALTREC:=u,cN_VALTREC)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,oFontDADOS,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cN_VALTREC",,)
oGet7      := TGet():New( 051,287,{|u| If(PCount()>0,cN_TOTPAGO:=u,cN_TOTPAGO)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,oFontDADOS,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cN_TOTPAGO",,)
oGet8      := TGet():New( 035,287,{|u| If(PCount()>0,cN_SALDOATU:=u,cN_SALDOATU)},oPanel1,060,008,'',,CLR_BLACK,CLR_WHITE,oFontDADOS,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cN_SALDOATU",,)

ODLG1:ACTIVATE(,,,.T.)
RETURN


STATIC FUNCTION FECHA_TAB()
IF CHKFILE("_SALD_ANTE")
	DBSELECTAREA("_SALD_ANTE")
	DBCLOSEAREA()
END IF
RETURN