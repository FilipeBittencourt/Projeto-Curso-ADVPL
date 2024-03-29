#include "protheus.ch"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#include "vkey.ch"
#INCLUDE "TOTVS.CH"

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � BIA472A  篈utor  � Wanisay William    � Data �  10/05/10   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Gestao de Contratos                                        罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � MP811                                                      罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

User Function BIA472A()

	MsgInfo("Aten玢o, est� rotina foi descontinuada, caso necessite de acesso ao novo relat髍io de Gest鉶 de Contratos, favor solicitar ao setor Investimento.")

	/*
	cHInicio := Time()
	fPerg := "BIA472"
	If !Pergunte(fPerg,.T.)
		Return
	EndIf
	
	Processa({|| RptDet_1()})
	*/

Return()


Static Function RptDet_1()
LOCAL nPosCnt	:= 0
Private Enter := CHR(13)+CHR(10)

DO CASE 
   CASE cEmpAnt == '01'
      	aBitmap  := "LGRL01.BMP"
   CASE cEmpAnt == '02'
      	aBitmap  := "LGRL02.BMP"
   CASE cEmpAnt == '03'
      	aBitmap  := "LGRL03.BMP"
   CASE cEmpAnt == '04'
      	aBitmap  := "LGRL04.BMP"
   CASE cEmpAnt == '05'
      	aBitmap  := "LGRL05.BMP"
   CASE cEmpAnt == '06'
      	aBitmap  := "LGRL06.BMP"
   CASE cEmpAnt == '07'
      	aBitmap  := "LGRL07.BMP"
   CASE cEmpAnt == '08'
      	aBitmap  := "LGRL08.BMP"
   CASE cEmpAnt == '09'
      	aBitmap  := "LGRL09.BMP"
   CASE cEmpAnt == '10'
      	aBitmap  := "LGRL10.BMP"
   CASE cEmpAnt == '11'
      	aBitmap  := "LGRL11.BMP"
   CASE cEmpAnt == '12'
      	aBitmap  := "LGRL12.BMP"
   CASE cEmpAnt == '13'
      	aBitmap  := "LGRL13.BMP"
   OTHERWISE
				aBitmap  := " "   
ENDCASE

fCabec   := "Gest鉶 de Contratos da "+ALLTRIM(SM0->M0_NOME)+" de "+DTOC(MV_PAR01)+" a "+DTOC(MV_PAR02)
fCabec2  := " "
wnPag    := 0
nRow1    := 0

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()
oPrint:SetPaperSize(09)

fImpCabec()

CSQL := "SELECT C3_NUM, C3_YCLVL "
CSQL += "FROM "+RETSQLNAME("SC3")+" "
CSQL += "WHERE C3_NUM BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
//CSQL += "C3_YCLVL = '8080' AND "
CSQL += "D_E_L_E_T_ = '' "
CSQL += "GROUP BY C3_NUM, C3_YCLVL "
IF CHKFILE("_CTR")
	DBSELECTAREA("_CTR")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_CTR" NEW

nContrato := 0
nPC       := 0
nPagar    := 0
nPagos    := 0
nSaldo    := 0
nPA       := 0

DbSelectArea("_CTR")
DbGoTop()

WHILE !Eof()
	
	IF MV_PAR05 == 1
		If nRow1 > 1
			fImpRoda()
			fImpCabec()
		EndIf
	ENDIF
	
	CSQL := "SELECT ISNULL(SUM(C3_TOTAL),0) AS CONTRATO FROM "+RETSQLNAME("SC3")+" WHERE C3_NUM = '"+_CTR->C3_NUM+"' AND C3_YCLVL = '"+_CTR->C3_YCLVL+"' AND D_E_L_E_T_ = '' "
	IF CHKFILE("_CONTRATO")
		DBSELECTAREA("_CONTRATO")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_CONTRATO" NEW
	IF _CONTRATO->CONTRATO = 0
		DbSelectArea("_CTR")
		DbSkip()
		Loop
	ENDIF
	
	DbSelectArea("SC3")
	DbSetOrder(1)
	DbSeek(xFilial("SC3")+_CTR->C3_NUM)
	
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial("SA2")+SC3->C3_FORNECE+SC3->C3_LOJA)
	cNome := SA2->A2_COD+'-'+SA2->A2_LOJA+'-'+ALLTRIM(SA2->A2_NOME)
	
	CSQL := "SELECT ISNULL(SUM(((SC7.C7_QUANT - SC7.C7_QUJE) * SC7.C7_PRECO)+(SC7.C7_IPI * ((SC7.C7_QUANT - SC7.C7_QUJE) * SC7.C7_PRECO)/100)),0) AS PEDIDOS_ABERTO" + Enter
	CSQL += "FROM " + RETSQLNAME("SC7") + " SC7 WITH(NOLOCK)" + Enter
	CSQL += "	INNER JOIN " + RETSQLNAME("SC3") + " SC3 WITH(NOLOCK) ON SC3.C3_FILIAL = '" + xFilial("SC3") + "' AND SC7.C7_YCONTR = SC3.C3_NUM AND SC7.C7_CLVL = SC3.C3_YCLVL AND SC3.C3_ITEM = '0001' AND SC3.D_E_L_E_T_ = ''" + Enter
	CSQL += "WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'" + Enter
	CSQL += "	AND SC7.C7_YCONTR = '" + _CTR->C3_NUM + "'" + Enter
	CSQL += "	AND SC7.C7_CLVL = '" + _CTR->C3_YCLVL + "'" + Enter
	CSQL += "	AND SC7.C7_QUANT <> SC7.C7_QUJE" + Enter
	CSQL += "	AND SC7.C7_RESIDUO <> 'S'" + Enter
	CSQL += "	AND SC7.C7_CONAPRO = 'L'" + Enter
	CSQL += "	AND SC7.C7_ENCER <> 'E'" + Enter
	CSQL += "	AND SC7.C7_NUM IN(SELECT SCR.CR_NUM  FROM " + RETSQLNAME("SCR") + " SCR WITH(NOLOCK) WHERE SCR.CR_FILIAL = '" + xFilial("SCR") + "' AND SCR.CR_DATALIB <> '' AND SCR.D_E_L_E_T_ = '')" + Enter
	CSQL += "	AND SC7.D_E_L_E_T_ = ''" + Enter
	IF CHKFILE("_ABERTO")
		DBSELECTAREA("_ABERTO")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_ABERTO" NEW
	_ABERTO->PEDIDOS_ABERTO
	
	// BUSCANDO OS TITULOS A PAGAR -- PARAMETRO CONTRATO
	CSQL := "SELECT ISNULL(SUM(E2_SALDO*ZZR_RATEIO/100),0) AS PAGAR "
	CSQL += "FROM "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("ZZR")+" ZZR "
	CSQL += "WHERE ZZR_CONTR = '"+_CTR->C3_NUM+"' "
	CSQL += "AND ZZR_PREF   = E2_PREFIXO "
	CSQL += "AND ZZR_NUM    = E2_NUM     "
	CSQL += "AND ZZR_PARC   = E2_PARCELA "
	CSQL += "AND ZZR_TIPO   = E2_TIPO    "
	CSQL += "AND ZZR_FORNEC = E2_FORNECE "
	CSQL += "AND ZZR_LOJA   = E2_LOJA    "
	CSQL += "AND ZZR_CLVL   = '"+_CTR->C3_YCLVL+"' "
	CSQL += "AND E2_SALDO > 0    "
	CSQL += "AND E2_TIPO NOT IN ('PA','NDF') "
	CSQL += "AND SE2.D_E_L_E_T_ = '' "
	CSQL += "AND ZZR.D_E_L_E_T_ = ''
	IF CHKFILE("_PAGAR")
		DBSELECTAREA("_PAGAR")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_PAGAR" NEW
	
	// BUSCANDO OS TITULOS A PAGOS -- PARAMETRO CONTRATO
	CSQL := "	SELECT SUM(PAGOS) AS PAGOS FROM "
	CSQL += "(SELECT PAGOS = CASE WHEN E5_RECPAG = 'P' THEN ISNULL((E5_VALOR*ZZR_RATEIO/100),0) "
	CSQL += "                     WHEN E5_RECPAG = 'R' THEN ISNULL((E5_VALOR*ZZR_RATEIO/100),0) * (-1) "
	CSQL += "		                  ELSE 0 END "
	CSQL += "FROM "+RETSQLNAME("SE5")+" SE5, "+RETSQLNAME("ZZR")+" ZZR "
	CSQL += "WHERE ZZR_CONTR = '"+_CTR->C3_NUM+"' "
	CSQL += "AND ZZR_PREF   = E5_PREFIXO "
	CSQL += "AND ZZR_NUM    = E5_NUMERO  "
	CSQL += "AND ZZR_PARC   = E5_PARCELA "
	CSQL += "AND ZZR_TIPO   = E5_TIPO    "
	CSQL += "AND ZZR_FORNEC = E5_CLIFOR "
	CSQL += "AND ZZR_LOJA   = E5_LOJA    "
	CSQL += "AND ZZR_CLVL   = '"+_CTR->C3_YCLVL+"' "
	CSQL += "AND E5_TIPODOC IN ('BA','CP','VL','ES') "
	CSQL += "AND E5_MOTBX NOT IN ('DES') "	
	CSQL += "AND SUBSTRING(E5_DOCUMEN,14,3) <> 'NDF' "
	CSQL += "AND E5_SITUACA <> 'C' "
	CSQL += "AND E5_TIPO <> 'PA' "
	CSQL += "AND E5_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	CSQL += "AND SE5.D_E_L_E_T_ = '' "
	CSQL += "AND ZZR.D_E_L_E_T_ = '') AS WWW "
	IF CHKFILE("_PAGOS")
		DBSELECTAREA("_PAGOS")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_PAGOS" NEW
	
	// BUSCANDO OS PAGAMENTOS ANTECIPADOS
	CSQL := "SELECT ISNULL(SUM(E2_SALDO*ZZR_RATEIO/100),0) AS PA "
	CSQL += "FROM "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("ZZR")+" ZZR "
	CSQL += "WHERE ZZR_CONTR = '"+_CTR->C3_NUM+"' "
	CSQL += "AND ZZR_PREF   = E2_PREFIXO "
	CSQL += "AND ZZR_NUM    = E2_NUM     "
	CSQL += "AND ZZR_PARC   = E2_PARCELA "
	CSQL += "AND ZZR_TIPO   = E2_TIPO    "
	CSQL += "AND ZZR_FORNEC = E2_FORNECE "
	CSQL += "AND ZZR_LOJA   = E2_LOJA    "
	CSQL += "AND ZZR_CLVL   = '"+_CTR->C3_YCLVL+"' "
	CSQL += "AND E2_SALDO > 0    "
	CSQL += "AND E2_TIPO  = 'PA' "
	CSQL += "AND SE2.D_E_L_E_T_ = '' "
	CSQL += "AND ZZR.D_E_L_E_T_ = ''
	
	IF CHKFILE("_PA")
		DBSELECTAREA("_PA")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_PA" NEW

	// BUSCANDO OS TITULOS DE DEVOLU敲O - NDF
	CSQL := "SELECT ISNULL(SUM(E2_SALDO*ZZR_RATEIO/100),0) AS NDF "
	CSQL += "FROM "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("ZZR")+" ZZR "
	CSQL += "WHERE ZZR_CONTR = '"+_CTR->C3_NUM+"' "
	CSQL += "AND ZZR_PREF   = E2_PREFIXO "
	CSQL += "AND ZZR_NUM    = E2_NUM     "
	CSQL += "AND ZZR_PARC   = E2_PARCELA "
	CSQL += "AND ZZR_TIPO   = E2_TIPO    "
	CSQL += "AND ZZR_FORNEC = E2_FORNECE "
	CSQL += "AND ZZR_LOJA   = E2_LOJA    "
	CSQL += "AND ZZR_CLVL   = '"+_CTR->C3_YCLVL+"' "
	CSQL += "AND E2_SALDO > 0    "
	CSQL += "AND E2_TIPO  = 'NDF' "
	CSQL += "AND SE2.D_E_L_E_T_ = '' "
	CSQL += "AND ZZR.D_E_L_E_T_ = ''
	
	IF CHKFILE("_NDF")
		DBSELECTAREA("_NDF")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_NDF" NEW
	
	SALDO_LIBERAR := _CONTRATO->CONTRATO - _ABERTO->PEDIDOS_ABERTO - _PAGAR->PAGAR - _PAGOS->PAGOS + _NDF->NDF
	
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Processando: "+cTempo)
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	nRow1 += 020
	DbSelectArea("_CTR")
	fr_Quebra := +;
	Padr(SC3->C3_NUM                                                           				,16)+" "+;
	Padr(_CTR->C3_YCLVL                                                        				,10)+" "+;
	Padr(SPACE(15)                                                                    ,15)+" "+;
	Padr(SC3->C3_YOBS                                                          				,50)+" "+;
	Padr(cNome                                                                    		,25)+" "+;
	Padl(Transform(_CONTRATO->CONTRATO, "@E 999,999,999.99")                 	   			,14)+" "+;
	Padl(Transform(_ABERTO->PEDIDOS_ABERTO, "@E 999,999,999.99")                 			,14)+" "+;
	Padl(Transform(_PAGAR->PAGAR, "@E 999,999,999.99")                 	   						,14)+" "+;
	Padl(Transform(_PAGOS->PAGOS, "@E 999,999,999.99")                 	   						,14)+" "+;
	Padl(Transform(SALDO_LIBERAR, "@E 999,999,999.99")                 	   						,14)+" "+;
	Padl(Transform(_PA->PA, "@E 999,999,999.99")                 	   				      		,25)
	
	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030
	oPrint:Line (nRow1, 010, nRow1, 3550)
	nRow1 += 020
	
	nContrato := nContrato + _CONTRATO->CONTRATO
	nPC       := nPC       + _ABERTO->PEDIDOS_ABERTO
	nPagar    := nPagar    + _PAGAR->PAGAR
	nPagos    := nPagos    + _PAGOS->PAGOS
	nSaldo    := nSaldo    + SALDO_LIBERAR
	nPA       := nPA       + _PA->PA
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	IF MV_PAR05 == 1
		//Busca todos os pedidos em aberto de forma analitica
		CSQL := "SELECT SC7.C7_ITEM" + Enter
		CSQL += "	, SC7.C7_NUM" + Enter
		CSQL += "	, SC7.C7_FORNECE" + Enter
		CSQL += "	, SC7.C7_LOJA" + Enter
		CSQL += "	, ((SC7.C7_QUANT - SC7.C7_QUJE) * SC7.C7_PRECO) AS C7_TOTAL" + Enter
		CSQL += "	, SC7.C7_IPI" + Enter
		CSQL += "	, SC7.C7_DESCRI" + Enter
		CSQL += "	, SC7.C7_DATPRF" + Enter
		CSQL += "FROM " + RETSQLNAME("SC7") + " SC7 WITH(NOLOCK)" + Enter
		CSQL += "	INNER JOIN " + RETSQLNAME("SC3") + " SC3 WITH(NOLOCK) ON SC3.C3_FILIAL = '" + xFilial("SC3") + "' AND SC7.C7_YCONTR = SC3.C3_NUM AND SC7.C7_CLVL = SC3.C3_YCLVL AND SC3.C3_ITEM = '0001' AND SC3.D_E_L_E_T_ = ''" + Enter
		CSQL += "WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'" + Enter
		CSQL += "	AND SC7.C7_YCONTR = '" + _CTR->C3_NUM + "'" + Enter
		CSQL += "	AND SC7.C7_CLVL = '" + _CTR->C3_YCLVL + "'" + Enter
		CSQL += "	AND SC7.C7_QUANT <> SC7.C7_QUJE" + Enter
		CSQL += "	AND SC7.C7_RESIDUO <> 'S'" + Enter
		CSQL += "	AND SC7.C7_CONAPRO = 'L'" + Enter
		CSQL += "	AND SC7.C7_ENCER <> 'E'" + Enter
		CSQL += "	AND SC7.C7_NUM IN(SELECT SCR.CR_NUM  FROM " + RETSQLNAME("SCR") + " SCR WITH(NOLOCK) WHERE SCR.CR_FILIAL = '" + xFilial("SCR") + "' AND SCR.CR_DATALIB <> '' AND SCR.D_E_L_E_T_ = '')" + Enter
		CSQL += "	AND SC7.D_E_L_E_T_ = ''" + Enter
		CSQL += "ORDER BY SC7.C7_NUM" + Enter
		CSQL += "	, SC7.C7_ITEM" + Enter
		
		IF CHKFILE("_ABERTO1")
			DBSELECTAREA("_ABERTO1")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_ABERTO1" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_ABERTO1")
		While !Eof()
			
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'PEDIDOS EM ABERTO:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF
			
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+_ABERTO1->C7_FORNECE+_ABERTO1->C7_LOJA)
			cNome := SA2->A2_COD+'-'+SA2->A2_LOJA+'-'+ALLTRIM(SA2->A2_NOME)
			
			cEntrega := SUBSTR(_ABERTO1->C7_DATPRF,7,2)+"/"+SUBSTR(_ABERTO1->C7_DATPRF,5,2)+"/"+SUBSTR(_ABERTO1->C7_DATPRF,3,2)
			
			fr_Quebra := +;
			Padr(_ABERTO1->C7_ITEM+'-'+_ABERTO1->C7_NUM                 								               					  ,16)+" "+;
			Padr(cEntrega                                                                                         ,10)+" "+;
			Padr(SPACE(15)                                                                                        ,15)+" "+;
			Padr(_ABERTO1->C7_DESCRI                                                   													  ,50)+" "+;
			Padr(cNome                                                                    											 	,25)+" "+;
			Padl(Transform(_ABERTO1->C7_TOTAL+(_ABERTO1->C7_IPI*_ABERTO1->C7_TOTAL/100), "@E 999,999,999.99")  	  ,29)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			DbSelectArea("_ABERTO1")
			DbSkip()
		END
		_ABERTO1->(dbCloseArea())
		
		//Busca todos os titulos a pagar em aberto de forma analitica
		CSQL := "SELECT E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, (RTRIM(ED_DESCRIC)+'-'+RTRIM(E2_TITPAI)) AS E2_HIST, E2_NOMFOR, E2_SALDO*ZZR_RATEIO/100 AS E2_SALDO, E2_VENCTO "
		CSQL += "FROM "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("ZZR")+" ZZR, "+RETSQLNAME("SED")+" SED "
		CSQL += "WHERE ZZR_CONTR = '"+_CTR->C3_NUM+"' "
		CSQL += "AND ZZR_PREF   = E2_PREFIXO "
		CSQL += "AND ZZR_NUM    = E2_NUM     "
		CSQL += "AND ZZR_PARC   = E2_PARCELA "
		CSQL += "AND ZZR_TIPO   = E2_TIPO    "
		CSQL += "AND ZZR_FORNEC = E2_FORNECE "
		CSQL += "AND ZZR_LOJA   = E2_LOJA    "
		CSQL += "AND ZZR_CLVL   = '"+_CTR->C3_YCLVL+"' "
		CSQL += "AND E2_SALDO > 0    "
		CSQL += "AND E2_TIPO NOT IN ('PA','NDF') "
		CSQL += "AND ED_CODIGO  = E2_NATUREZ "
		CSQL += "AND SE2.D_E_L_E_T_ = '' "
		CSQL += "AND ZZR.D_E_L_E_T_ = ''
		CSQL += "AND SED.D_E_L_E_T_ = ''
		CSQL += "ORDER BY E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA"
		IF CHKFILE("_PAGAR1")
			DBSELECTAREA("_PAGAR1")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_PAGAR1" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_PAGAR1")
		While !Eof()
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'TITULOS A PAGAR EM ABERTO:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF
			
			cVencto := SUBSTR(_PAGAR1->E2_VENCTO,7,2)+"/"+SUBSTR(_PAGAR1->E2_VENCTO,5,2)+"/"+SUBSTR(_PAGAR1->E2_VENCTO,3,2)
			
			fr_Quebra := +;
			Padr(ALLTRIM(_PAGAR1->E2_PREFIXO)+'-'+ALLTRIM(_PAGAR1->E2_NUM)+'-'+ALLTRIM(_PAGAR1->E2_PARCELA)+'-'+ALLTRIM(_PAGAR1->E2_TIPO)   ,16)+" "+;
			Padr(cVencto                                                                                                                    ,10)+" "+;
			Padr(SPACE(15)                                                                                                                  ,15)+" "+;
			Padr(_PAGAR1->E2_HIST   									                              									                     							    ,50)+" "+;
			Padr(_PAGAR1->E2_NOMFOR                   															                  			                   							,25)+" "+;
			Padl(Transform(_PAGAR1->E2_SALDO, "@E 999,999,999.99")                                         													      	,44)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			DbSelectArea("_PAGAR1")
			DbSkip()
		END
		_PAGAR1->(dbCloseArea())
		
		//Busca todos os titulos a pagar pagos de forma analitica
		CSQL := "SELECT E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, (RTRIM(ED_DESCRIC)+'-'+RTRIM(E2_TITPAI)) AS E5_HISTOR, E5_BENEF, E5_RECPAG, E5_VALOR*ZZR_RATEIO/100 AS E5_VALOR, E5_DATA, E5_TIPODOC, E5_DOCUMEN "
		CSQL += "FROM "+RETSQLNAME("SE5")+" SE5, "+RETSQLNAME("ZZR")+" ZZR, "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("SED")+" SED "
		CSQL += "WHERE ZZR_CONTR = '"+_CTR->C3_NUM+"' "
		CSQL += "AND ZZR_PREF   = E5_PREFIXO "
		CSQL += "AND ZZR_NUM    = E5_NUMERO  "
		CSQL += "AND ZZR_PARC   = E5_PARCELA "
		CSQL += "AND ZZR_TIPO   = E5_TIPO    "
		CSQL += "AND ZZR_FORNEC = E5_CLIFOR "
		CSQL += "AND ZZR_LOJA   = E5_LOJA    "
		CSQL += "AND ZZR_CLVL   = '"+_CTR->C3_YCLVL+"' "
		CSQL += "AND ZZR_PREF   = E2_PREFIXO "
		CSQL += "AND ZZR_NUM    = E2_NUM     "
		CSQL += "AND ZZR_PARC   = E2_PARCELA "
		CSQL += "AND ZZR_TIPO   = E2_TIPO    "
		CSQL += "AND ZZR_FORNEC = E2_FORNECE "
		CSQL += "AND ZZR_LOJA   = E2_LOJA    "
		CSQL += "AND ED_CODIGO  = E2_NATUREZ "
		CSQL += "AND E5_TIPODOC IN ('BA','CP','VL','ES') "
		CSQL += "AND E5_MOTBX NOT IN ('DES') "
		CSQL += "AND E5_SITUACA <> 'C' "
		CSQL += "AND SUBSTRING(E5_DOCUMEN,14,3) <> 'NDF' "
		CSQL += "AND E5_TIPO <> 'PA' "
		CSQL += "AND E5_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
		CSQL += "AND SE5.D_E_L_E_T_ = ''
		CSQL += "AND ZZR.D_E_L_E_T_ = ''
		CSQL += "AND SE2.D_E_L_E_T_ = ''
		CSQL += "AND SED.D_E_L_E_T_ = ''
		CSQL += "ORDER BY E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA"
		IF CHKFILE("_PAGOS1")
			DBSELECTAREA("_PAGOS1")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_PAGOS1" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_PAGOS1")
		While !Eof()
			
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'TITULOS PAGOS:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF
			
			nFator := 1
			IF _PAGOS1->E5_RECPAG == 'R'
				nFator := -1
			ENDIF
			
			cMovBanc := SUBSTR(_PAGOS1->E5_DATA,7,2)+"/"+SUBSTR(_PAGOS1->E5_DATA,5,2)+"/"+SUBSTR(_PAGOS1->E5_DATA,3,2)
			
			fr_Quebra := +;
			Padr(ALLTRIM(_PAGOS1->E5_PREFIXO)+'-'+ALLTRIM(_PAGOS1->E5_NUMERO)+'-'+ALLTRIM(_PAGOS1->E5_PARCELA)+'-'+ALLTRIM(_PAGOS1->E5_TIPO)    ,16)+" "+;
			Padr(cMovBanc                                                                                                                       ,10)+" "+;
			Padr(_PAGOS1->E5_TIPODOC + '-' + _PAGOS1->E5_DOCUMEN                                                                                ,15)+" "+;
			Padr(_PAGOS1->E5_HISTOR                                                    							  																					,50)+" "+;
			Padr(_PAGOS1->E5_BENEF                                                        						 																				  ,25)+" "+;
			Padl(Transform(_PAGOS1->E5_VALOR * nFator, "@E 999,999,999.99")                                        															,59)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			DbSelectArea("_PAGOS1")
			DbSkip()
		END
		_PAGOS1->(dbCloseArea())
		
		// BUSCANDO OS PAGAMENTOS ANTECIPADOS
		CSQL := "SELECT E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, (RTRIM(ED_DESCRIC)+'-'+RTRIM(E2_TITPAI)) AS E2_HIST, E2_NOMFOR, E2_SALDO*ZZR_RATEIO/100 AS E2_SALDO, E2_VENCTO "
		CSQL += "FROM "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("ZZR")+" ZZR, "+RETSQLNAME("SED")+" SED "
		CSQL += "WHERE ZZR_CONTR = '"+_CTR->C3_NUM+"' "
		CSQL += "AND ZZR_PREF   = E2_PREFIXO "
		CSQL += "AND ZZR_NUM    = E2_NUM     "
		CSQL += "AND ZZR_PARC   = E2_PARCELA "
		CSQL += "AND ZZR_TIPO   = E2_TIPO    "
		CSQL += "AND ZZR_FORNEC = E2_FORNECE "
		CSQL += "AND ZZR_LOJA   = E2_LOJA    "
		CSQL += "AND ZZR_CLVL   = '"+_CTR->C3_YCLVL+"' "
		CSQL += "AND E2_SALDO   > 0    "
		CSQL += "AND E2_TIPO    = 'PA' "
		CSQL += "AND ED_CODIGO  = E2_NATUREZ "
		CSQL += "AND SE2.D_E_L_E_T_ = '' "
		CSQL += "AND ZZR.D_E_L_E_T_ = ''
		CSQL += "AND SED.D_E_L_E_T_ = ''
		CSQL += "ORDER BY E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA"
		IF CHKFILE("_PA1")
			DBSELECTAREA("_PA1")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_PA1" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_PA1")
		While !Eof()
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'PAGAMENTOS ANTECIPADOS:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF
			
			cVencto := SUBSTR(_PA1->E2_VENCTO,7,2)+"/"+SUBSTR(_PA1->E2_VENCTO,5,2)+"/"+SUBSTR(_PA1->E2_VENCTO,3,2)
			
			fr_Quebra := +;
			Padr(ALLTRIM(_PA1->E2_PREFIXO)+'-'+ALLTRIM(_PA1->E2_NUM)+'-'+ALLTRIM(_PA1->E2_PARCELA)+'-'+ALLTRIM(_PA1->E2_TIPO)		    ,16)+" "+;
			Padr(cVencto                                                                                                            ,10)+" "+;
			Padr(SPACE(15)                                                                                                          ,15)+" "+;
			Padr(_PA1->E2_HIST                                                 						 	    																		,50)+" "+;
			Padr(_PA1->E2_NOMFOR                                                   																									,25)+" "+;
			Padl(Transform(_PA1->E2_SALDO, "@E 999,999,999.99")                                          														,100)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			DbSelectArea("_PA1")
			DbSkip()
		END
		_PA1->(dbCloseArea())
		
		// BUSCANDO AS DEVOLU钦ES DE COMPRAS - NDF
		CSQL := "SELECT E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, (RTRIM(ED_DESCRIC)+'-'+RTRIM(E2_TITPAI)) AS E2_HIST, E2_NOMFOR, E2_SALDO*ZZR_RATEIO/100 AS E2_SALDO, E2_VENCTO "
		CSQL += "FROM "+RETSQLNAME("SE2")+" SE2, "+RETSQLNAME("ZZR")+" ZZR, "+RETSQLNAME("SED")+" SED "
		CSQL += "WHERE ZZR_CONTR = '"+_CTR->C3_NUM+"' "
		CSQL += "AND ZZR_PREF   = E2_PREFIXO "
		CSQL += "AND ZZR_NUM    = E2_NUM     "
		CSQL += "AND ZZR_PARC   = E2_PARCELA "
		CSQL += "AND ZZR_TIPO   = E2_TIPO    "
		CSQL += "AND ZZR_FORNEC = E2_FORNECE "
		CSQL += "AND ZZR_LOJA   = E2_LOJA    "
		CSQL += "AND ZZR_CLVL   = '"+_CTR->C3_YCLVL+"' "
		CSQL += "AND E2_SALDO   > 0    "
		CSQL += "AND E2_TIPO    = 'NDF' "
		CSQL += "AND ED_CODIGO  = E2_NATUREZ "
		CSQL += "AND SE2.D_E_L_E_T_ = '' "
		CSQL += "AND ZZR.D_E_L_E_T_ = ''
		CSQL += "AND SED.D_E_L_E_T_ = ''
		CSQL += "ORDER BY E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA"
		IF CHKFILE("_NDF")
			DBSELECTAREA("_NDF")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_NDF" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_NDF")
		While !Eof()
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'DEVOLU钦ES DE COMPRAS - NDF:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF
			
			cVencto := SUBSTR(_NDF->E2_VENCTO,7,2)+"/"+SUBSTR(_NDF->E2_VENCTO,5,2)+"/"+SUBSTR(_NDF->E2_VENCTO,3,2)
			
			fr_Quebra := +;
			Padr(ALLTRIM(_NDF->E2_PREFIXO)+'-'+ALLTRIM(_NDF->E2_NUM)+'-'+ALLTRIM(_NDF->E2_PARCELA)+'-'+ALLTRIM(_NDF->E2_TIPO)		,16)+" "+;
			Padr(cVencto                                                                                                            ,10)+" "+;
			Padr(SPACE(15)                                                                                                          ,15)+" "+;
			Padr(_NDF->E2_HIST                                                 						 	    						,50)+" "+;
			Padr(_NDF->E2_NOMFOR                                                   													,25)+" "+;
			Padl(Transform(_NDF->E2_SALDO * (-1), "@E 999,999,999.99")                                     							,100)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			DbSelectArea("_NDF")
			DbSkip()
		END
		_NDF->(dbCloseArea())
	ENDIF
	
	DbSelectArea("_CTR")
	DbSkip()
END

nRow1 += 020
DbSelectArea("_CTR")
fr_Quebra := +;
Padr("Total Geral"                                                         				,16)+" "+;
Padr(SPACE(10)                                                             				,10)+" "+;
Padr(SPACE(15)                                                             				,15)+" "+;
Padr(SPACE(50)                                                             				,50)+" "+;
Padr(SPACE(40)                                                                 		,25)+" "+;
Padl(Transform(nContrato, "@E 999,999,999.99")                           	   			,14)+" "+;
Padl(Transform(nPC,       "@E 999,999,999.99")                   			            ,14)+" "+;
Padl(Transform(nPagar,    "@E 999,999,999.99")                 	   						    ,14)+" "+;
Padl(Transform(nPagos,    "@E 999,999,999.99")                 	   						    ,14)+" "+;
Padl(Transform(nSaldo,    "@E 999,999,999.99")                 	   						    ,14)+" "+;
Padl(Transform(nPA,       "@E 999,999,999.99")           	   				      		    ,25)

oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
nRow1 += 030
oPrint:Line (nRow1, 010, nRow1, 3550)
nRow1 += 020

_CTR->(dbCloseArea())

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

Return

/*___________________________________________________________________________
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
Ζ+-----------------------------------------------------------------------+Ζ
Ζun玎o    � fImpCabec� Autor � Wanisay William       � Data � 13.02.08 Ζ�
Ζ+-----------------------------------------------------------------------+Ζ
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
�*/
Static Function fImpCabec()

oPrint:StartPage()
wnPag ++
nRow1 := 050
If File(aBitmap)
	oPrint:SayBitmap( nRow1,0050,aBitmap,0500,0150 )
EndIf
nRow1 += 025
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec,098)                        ,oFont14)
oPrint:Say  (nRow1+20 ,2950 ,"P醙ina:"                               ,oFont7)
oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont8)
nRow1 += 075
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec2,133)                       ,oFont10)
nRow1 += 075

xf_Titu := +;
Padr("N鷐ero"    										     ,16)+" "+;
Padr("DT Venc/Pg"   										 ,10)+" "+;
Padr("Pgto Antecipado"									 ,15)+" "+;
Padr("Descri玢o"         					 			 ,50)+" "+;
Padr("Fornecedor"        					 			 ,25)+" "+;
Padl("Valor"       		        					 ,14)+" "+;
Padl("PC Aberto"   	 	            			 ,14)+" "+;
Padl("Tit. Aberto"     						 	     ,14)+" "+;
Padl("Tit. Pagos" 	  						 	     ,14)+" "+;
Padl("Saldo" 		       						 	     ,14)+" "+;
Padl("PAs n鉶 comp."     								 ,25)

oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 075

Return

/*
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
Ζ+-----------------------------------------------------------------------+Ζ
Ζun玎o    � fImpRoda � Autor � Wanisay William       � Data � 13.02.08 Ζ�
Ζ+-----------------------------------------------------------------------+Ζ
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
�*/
Static Function fImpRoda()

oPrint:Line (2300, 010, 2300, 3550)
oPrint:Say  (2300+30 , 010,"Prog.: BIA472"                                        ,oFont7)
oPrint:Say  (2300+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
oPrint:EndPage()
nRow1 := 4000

Return
