#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BIA422   ºAutor  ³Wanisay William     º Data ³  09/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analisa o credito de cliente de cada pedido em aberto      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA422(AA_EMP)
//AA_EMP := "07"                           

IF TYPE("DDATABASE") <> "D"
	PREPARE ENVIRONMENT EMPRESA AA_EMP FILIAL "01" MODULO "FAT" TABLES "SC5,SC6"
END IF

/*
If Type("DDATABASE") <> "D"
	If AA_EMP == "01"
		RPCSETENV("01","01",,,"FAT")
	Else 
		RPCSETENV("05","01",,,"FAT")
	EndIf
EndIf
*/

Private cSql		:= ""

Private nTipo		:= 0
Private nSaldo 		:= 0
Private nRisco 		:= 0

Private wVencto		:= wDataBase := wsAtraso := ""
Private wFim 		:= .T.
Private cMotivo		:= ""
Private aLista     	:= {}
Private nI         	:= 1
Private cMensagem  	:= ''
Private lOK        	:= .F.
Private lPassei    	:= .F.
Private lSexta     	:= .F.
Private lErro      	:= .F.
Private cERRO      	:= ''
Private nLastKey   	:= 0
Private cItem 	   	:= 1
Private cMensag    	:= ''
Private cMens      	:= ''
Private cMens2     	:= ''
Private nItemPrd   	:= 0
Private cFornece   	:= ''
Private cLoja      	:= ''
Private cAprov     	:= ''
Private cDia       	:= ''
Private cHInicio   	:= Time()
Private Enter 	   	:= CHR(13) + CHR(10)
PRIVATE __EMAIL    	:= ""
private wwUsuario1 	:= ""

//Analisa creditos dos clientes que tenham pedidos em aberto
cSql += "SELECT C9_FILIAL, REPRESENTANTE, CLIENTE, LOJA, C9_AGREG, SUM(C9_QTDLIB*C9_PRCVEN) AS VALOR, ZZI_ATENDE AS ATENDENTE "
DO CASE
	CASE cempant = "01"
		cSql += "FROM SC9010 SC9, SC6010 SC6, SF4010 SF4, (SELECT C5_VEND1 AS REPRESENTANTE, CLIENTE = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END, LOJA = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END, * FROM SC5010 ) AS SC5, SE4010 SE4, SA1010 SA1, ZZI010 ZZI "
	CASE cempant = "05"
		cSql += "FROM SC9050 SC9, SC6050 SC6, SF4050 SF4, (SELECT C5_VEND1 AS REPRESENTANTE, CLIENTE = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END, LOJA = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END, * FROM SC5050 ) AS SC5, SE4010 SE4, SA1050 SA1, ZZI050 ZZI "
	//CASE cempant = "07"
	//	cSql += "FROM SC9070 SC9, SC6070 SC6, SF4070 SF4, (SELECT C5_VEND1 AS REPRESENTANTE, CLIENTE = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END, LOJA = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END, * FROM SC5070 ) AS SC5, SE4010 SE4, SA1070 SA1, "
	//	cSql += "(SELECT * FROM ZZI010 WHERE D_E_L_E_T_ = '' "
	//	cSql += "UNION ALL "
	//	cSql += "SELECT * FROM ZZI050 WHERE D_E_L_E_T_ = '') AS ZZI "
ENDCASE
cSql += "WHERE C9_FILIAL = '01' "
cSql += "AND C9_NFISCAL  = ' ' "
cSql += "AND SUBSTRING(C9_PRODUTO,1,1) >= 'A' "
cSql += "AND F4_CODIGO   = C6_TES "
cSql += "AND C9_PEDIDO   = C6_NUM "
cSql += "AND C9_ITEM     = C6_ITEM "
cSql += "AND C9_PRODUTO  = C6_PRODUTO "
cSql += "AND C9_PEDIDO   = C5_NUM "
cSql += "AND E4_CODIGO   = C5_CONDPAG "
cSql += "AND C5_CONDPAG  NOT IN ('000','145','975','A75') "
cSql += "AND F4_DUPLIC   = 'S' "
cSql += "AND E4_DESCRI NOT LIKE '%ANTE%' "
cSql += "AND E4_YATIVO = '1' "

cSql += "AND LOJA        = A1_LOJA "
cSql += "AND CLIENTE     = A1_COD "
cSql += "AND C5_VEND1    = ZZI_VEND "
cSql += "AND A1_YTPSEG   = ZZI_TPSEG "

cSql += "AND C5_VEND1    = ZZI_VEND " 

cSql += "AND SC9.D_E_L_E_T_ = ' ' "
cSql += "AND SC6.D_E_L_E_T_ = ' ' "
cSql += "AND SC5.D_E_L_E_T_ = ' ' "
cSql += "AND SF4.D_E_L_E_T_ = ' ' "

cSql += "AND SA1.D_E_L_E_T_ = '' "

cSql += "GROUP BY C9_FILIAL, CLIENTE, LOJA, REPRESENTANTE, C9_AGREG, ZZI_ATENDE "
cSql += "ORDER BY ZZI_ATENDE, C9_FILIAL, CLIENTE, LOJA, C9_AGREG "

If chkfile("_PED")
	dbSelectArea("_PED")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "_PED" NEW

DbSelectArea("_PED")
DbGoTop()
ProcRegua(RecCount())

IF  !Eof()
	CATENDENTE := _PED->ATENDENTE
ENDIF

While !Eof()
	
	IF  CATENDENTE <> _PED->ATENDENTE .AND. !EMPTY(cMENS) .AND. nItemPrd >= 1
		psworder(1)
		pswseek( CATENDENTE ,.t.)
		wwUsuario1  := ALLTRIM(pswret(1)[1][4])  	//NOME DO USUARIO
		__EMAIL 	:= ALLTRIM(pswret(1)[1][14])    //EMAIL DO USUARIO
		Envioemail()
		CATENDENTE	:= _PED->ATENDENTE
		cMENS := ""
		nItemPrd := 0		
	ENDIF
	
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona Cliente da Empresa corrente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+_PED->CLIENTE+_PED->LOJA,.T.)
	cMotivo	:= ""
	
//	cSql := ""
//	cSql += "SELECT	ACY_GRPVEN, A1_GRPVEN, A1_YTIPOLC, '' A1_COD, '' A1_LOJA, '' A1_NOME, "
//	cSql += "		MAX(A1_LC) LC, SUM(PEDIDO) PEDIDO, SUM(TITULO) TITULO, (MAX(A1_LC)-SUM(PEDIDO)-SUM(TITULO)) SALDO "
//	cSql += "FROM (SELECT	ACY_GRPVEN = CASE "
//	cSql += "								WHEN SA1_1.A1_GRPVEN <> '' AND SA1_1.A1_YTIPOLC = 'G' THEN ACY_GRPVEN+' - '+ACY_DESCRI "
//	cSql += "								ELSE SA1_1.A1_COD+' - '+SA1_1.A1_NOME "
//	cSql += "							 END, "
//	cSql += "				SA1_1.A1_GRPVEN, SA1_1.A1_YTIPOLC, SA1_1.A1_COD, SA1_1.A1_LOJA, SA1_1.A1_VEND, SA1_1.A1_YVENDI, SA1_1.A1_NOME, SA1_1.A1_LC,    "
//	cSql += "				ISNULL(PED.SALDO,0) PEDIDO, ISNULL(TIT.SALDO,0) TITULO,  "
//	cSql += "				ROUND((SA1_1.A1_LC-(ISNULL(PED.SALDO,0)+ISNULL(TIT.SALDO,0))),2) AS SALDO	"
//	cSql += "		FROM SA1010 SA1_1 , SA1050 SA1_5, ACY010 ACY, VW_SALDOPEDIDO PED, VW_SALDOTITULO TIT "
//	cSql += "		WHERE	SA1_1.A1_COD	= SA1_5.A1_COD		AND "
//	cSql += "				SA1_1.A1_LOJA	= SA1_5.A1_LOJA		AND "
//	If ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
//		cSql += "			SA1_1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1_1.A1_YTIPOLC = 'G' AND "
//	Else
//		cSql += "			SA1_1.A1_COD	= '"+_PED->CLIENTE+"'	AND "
//		cSql += "			SA1_1.A1_LOJA	= '"+_PED->LOJA+"' 		AND "
//	EndIf
//	cSql += "				SA1_1.A1_GRPVEN *= ACY_GRPVEN		AND "
//	cSql += "				SA1_1.A1_COD	*= PED.C5_CLIENTE	AND "
//	cSql += "				SA1_1.A1_LOJA	*= PED.C5_LOJACLI	AND "
//	cSql += "				SA1_1.A1_COD	*= TIT.E1_CLIENTE	AND "
//	cSql += "				SA1_1.A1_LOJA	*= TIT.E1_LOJA		AND "
//	cSql += "				SA1_1.D_E_L_E_T_ = ''				AND "
//	cSql += "				SA1_5.D_E_L_E_T_ = ''				AND "
//	cSql += "				ACY.D_E_L_E_T_	 = '') LIM				"
//	cSql += "GROUP BY ACY_GRPVEN, A1_GRPVEN, A1_YTIPOLC				"
//	cSql += "ORDER BY A1_GRPVEN, A1_YTIPOLC							"
	
	
	
	
	//ATUALIZAÇÃO QUERY - SQL ATUAL - 14/10/2015
	cSql := ""
	cSql += "SELECT	ACY_GRPVEN, A1_GRPVEN, A1_YTIPOLC, '' A1_COD, '' A1_LOJA, '' A1_NOME, " + Enter
	cSql += "		MAX(A1_LC) LC, SUM(PEDIDO) PEDIDO, SUM(TITULO) TITULO, (MAX(A1_LC)-SUM(PEDIDO)-SUM(TITULO)) SALDO " + Enter
	cSql += "FROM (SELECT	ACY_GRPVEN = CASE " + Enter
	cSql += "								WHEN SA1_1.A1_GRPVEN <> '' AND SA1_1.A1_YTIPOLC = 'G' THEN ACY_GRPVEN+' - '+ACY_DESCRI " + Enter
	cSql += "								ELSE SA1_1.A1_COD+' - '+SA1_1.A1_NOME " + Enter
	cSql += "							 END, " + Enter
	cSql += "				SA1_1.A1_GRPVEN, SA1_1.A1_YTIPOLC, SA1_1.A1_COD, SA1_1.A1_LOJA, SA1_1.A1_VEND, SA1_1.A1_YVENDI, SA1_1.A1_NOME, SA1_1.A1_LC, " + Enter
	cSql += "				ISNULL(PED.SALDO,0) PEDIDO, ISNULL(TIT.SALDO,0) TITULO, " + Enter
	cSql += "				ROUND((SA1_1.A1_LC-(ISNULL(PED.SALDO,0)+ISNULL(TIT.SALDO,0))),2) AS SALDO " + Enter
	cSql += "		FROM SA1010 SA1_1 " + Enter
	cSql += "			INNER JOIN SA1050 SA1_5 " + Enter
	cSql += "				ON SA1_1.A1_COD	= SA1_5.A1_COD " + Enter
	cSql += "					AND SA1_1.A1_LOJA = SA1_5.A1_LOJA " + Enter
	cSql += "					AND SA1_5.D_E_L_E_T_ = '' " + Enter
	cSql += "			LEFT JOIN ACY010 ACY " + Enter
	cSql += "				ON SA1_1.A1_GRPVEN = ACY_GRPVEN " + Enter
	cSql += "					AND ACY.D_E_L_E_T_ = '' " + Enter
	cSql += "			LEFT JOIN VW_SALDOPEDIDO PED " + Enter
	cSql += "				ON SA1_1.A1_COD = PED.C5_CLIENTE " + Enter
	cSql += "					AND SA1_1.A1_LOJA = PED.C5_LOJACLI " + Enter
	cSql += "			LEFT JOIN VW_SALDOTITULO TIT " + Enter
	cSql += "				ON SA1_1.A1_COD = TIT.E1_CLIENTE " + Enter
	cSql += "					AND SA1_1.A1_LOJA = TIT.E1_LOJA " + Enter
	cSql += "		WHERE " + Enter
	If ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		cSql += "				SA1_1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1_1.A1_YTIPOLC = 'G' AND " + Enter
	Else
		cSql += "				SA1_1.A1_COD	= '"+_PED->CLIENTE+"'	AND " + Enter
		cSql += "				SA1_1.A1_LOJA	= '"+_PED->LOJA+"' 		AND " + Enter
	EndIf
	cSql += "				SA1_1.D_E_L_E_T_ = '') LIM " + Enter
	cSql += "GROUP BY ACY_GRPVEN, A1_GRPVEN, A1_YTIPOLC " + Enter
	cSql += "ORDER BY A1_GRPVEN, A1_YTIPOLC " + Enter
	
	
	If chkfile("_SA1")
		DbSelectArea("_SA1")
		DbCloseArea()
	EndIf
	TCQUERY cSql NEW ALIAS "_SA1"
	DbSelectArea("_SA1")
	DbGotop()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o Vencimento do Limite de Credito na Outra Empresa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SA1->A1_VENCLC > dDataBase
		DbSelectArea("_PED")
		DbSkip()
		Loop
	ELSE
		cMotivo := "Data do Limite"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Saldo do Limite Credito somando Biancogres e Incesa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSaldo := _SA1->SALDO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Saldo esta dentro do Limite³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nSaldo <= 0
		cMotivo := "Saldo/"+ALLTRIM(cMotivo)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Cliente esta com Titulos em Atraso³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := " SELECT '01' EMPRESA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_SALDO, E1_EMISSAO, E1_VENCTO, E1_VALOR, E1_CLIENTE, E1_LOJA  " + Enter
	cSql += " FROM SE1010 SE1, SA1010 SA1 " + Enter
	cSql += " WHERE	SE1.E1_FILIAL	= '"+xFilial("SE1")+"'	AND " + Enter
	cSql += "		SE1.E1_CLIENTE	= SA1.A1_COD			AND	" + Enter
	cSql += " 		SE1.E1_LOJA		= SA1.A1_LOJA			AND	" + Enter
	IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += "	SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G' AND " + ENTER
	ELSE
		CSQL += "	SA1.A1_COD    = '"+SA1->A1_COD+"'    AND SA1.A1_LOJA = '"+SA1->A1_LOJA+"'	AND " + ENTER
	END IF
	cSql += " 	 	E1_SALDO        > 0                        AND	 " + Enter
	cSql += " 	 	E1_TIPO    NOT IN ('NCC','RA','BOL')             AND	 " + Enter
	cSql += " 	 	SE1.D_E_L_E_T_ = ''  AND " + Enter
	cSql += " 		SA1.D_E_L_E_T_ = ''	 " + Enter
	cSql += " UNION	 " + Enter
	cSql += " SELECT '05' EMPRESA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_SALDO, E1_EMISSAO, E1_VENCTO, E1_VALOR, E1_CLIENTE, E1_LOJA  " + Enter
	cSql += " FROM SE1050 SE1, SA1050 SA1 " + Enter
	cSql += " WHERE	SE1.E1_FILIAL	= '"+xFilial("SE1")+"'	AND " + Enter
	cSql += "		SE1.E1_CLIENTE	= SA1.A1_COD			AND	" + Enter
	cSql += " 		SE1.E1_LOJA		= SA1.A1_LOJA			AND	" + Enter
	IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += "	SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G' AND " + ENTER
	ELSE
		CSQL += "	SA1.A1_COD    = '"+SA1->A1_COD+"'    AND SA1.A1_LOJA = '"+SA1->A1_LOJA+"'	AND " + ENTER
	END IF
	cSql += "  		E1_SALDO        > 0                        AND  " + Enter
	cSql += " 	 	E1_TIPO    NOT IN ('NCC','RA','BOL')             AND  " + Enter
	cSql += " 	 	SE1.D_E_L_E_T_ = '' AND " + Enter
	cSql += " 		SA1.D_E_L_E_T_ = '' " + Enter
	cSql += " UNION	 " + Enter
	cSql += " SELECT '07' EMPRESA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_SALDO, E1_EMISSAO, E1_VENCTO, E1_VALOR, E1_CLIENTE, E1_LOJA  " + Enter
	cSql += " FROM SE1070 SE1, SA1070 SA1 " + Enter
	cSql += " WHERE	SE1.E1_FILIAL	= '"+xFilial("SE1")+"'	AND " + Enter
	cSql += "		SE1.E1_CLIENTE	= SA1.A1_COD			AND	" + Enter
	cSql += " 		SE1.E1_LOJA		= SA1.A1_LOJA			AND	" + Enter
	IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += "	SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G' AND " + ENTER
	ELSE
		CSQL += "	SA1.A1_COD = '"+SA1->A1_COD+"'       AND SA1.A1_LOJA = '"+SA1->A1_LOJA+"'	AND " + ENTER
	END IF
	cSql += "  		E1_SALDO        > 0                  AND  " + Enter
	cSql += " 	 	E1_TIPO    NOT IN ('NCC','RA','BOL') AND  " + Enter
	cSql += " 	 	SE1.D_E_L_E_T_ = '' AND " + Enter
	cSql += " 		SA1.D_E_L_E_T_ = '' " + Enter
	cSql += " ORDER BY E1_VENCTO  " + Enter
	If chkfile("RAN")
		DbSelectArea("RAN")
		DbCloseArea("RAN")
	EndIf
	TCQUERY cSql ALIAS "RAN" NEW
	DbSelectArea("RAN")
	DbGoTop()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar o Risco do Cliente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(SA1->A1_RISCO) == "E"
		nRisco := 0
	ElseIf Alltrim(SA1->A1_RISCO) == "A"
		nRisco := 999999
	Else
		nRisco := GetMv("MV_RISCO"+Alltrim(SA1->A1_RISCO))
	EndIf
	
	wFim := .T.
	While !Eof() .and. wFim
		wVencto   := Ctod(Subs(RAN->E1_VENCTO,7,2)+"/"+Subs(RAN->E1_VENCTO,5,2)+"/"+Subs(RAN->E1_VENCTO,1,4))
		wDataBase := DdataBase
		wsAtraso  := wDataBase - wVencto
		If wsAtraso > nRisco
			cMotivo := "Atraso/Risco/"+ALLTRIM(cMotivo)
			wFim := .F.
		EndIf
		DbSelectArea("RAN")
		DbSkip()
	EndDo
	
	IF cItem = 1
		cMENS := cMENS+'<TR bgcolor="#33CCFF">'
		cItem := 0
	ELSE
		cMENS := cMENS+'<TR bgcolor="#FFFFFF">'
		cItem := 1
	ENDIF
	
	nItemPrd := nItemPrd + 1
	
	cMENS := cMENS+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
	cMENS := cMENS+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+_PED->CLIENTE+"-"+_PED->LOJA+'</TD>'
	cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+SA1->A1_NOME+'</TD>'
	cMENS := cMENS+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+Alltrim(_PED->REPRESENTANTE)+" - "+Posicione("SA3",1,xFilial("SA3")+_PED->REPRESENTANTE,"A3_NOME")+'</TD>'
	cMENS := cMENS+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+_PED->C9_AGREG+'</TD>'
	cMENS := cMENS+'<TD width="70"  valign="Top"><FONT face="Verdana" size="1">'+STR(nSaldo,11,2)+'</TD>'
	cMENS := cMENS+'<TD width="70"  valign="Top"><FONT face="Verdana" size="1">'+STR(_PED->VALOR,11,2)+'</TD>'
	cMENS := cMENS+'<TD width="250" valign="Top"><FONT face="Verdana" size="1">'+cMotivo+'</TD>'
	cMENS := cMENS+'</TR>'
	
	DbSelectArea("_PED")
	DbSkip()
	Loop
EndDo

IF !EMPTY(cMENS) .AND. nItemPrd >= 1
	psworder(1)
	pswseek( CATENDENTE ,.t.)
	wwUsuario1	:= ALLTRIM(pswret(1)[1][4])		//NOME DO USUARIO
	__EMAIL 	:= ALLTRIM(pswret(1)[1][14])    //EMAIL DO USUARIO
	Envioemail()
	CATENDENTE	:= _PED->ATENDENTE
	cMENS := ""
ENDIF

If chkfile("RAN")
	DbSelectArea("RAN")
	DbCloseArea("RAN")
EndIf

If chkfile("_SA1")
	DbSelectArea("_SA1")
	DbCloseArea("_SA1")
EndIf

If chkfile("_PED")
	dbSelectArea("_PED")
	dbCloseArea()
EndIf

//Analisa pedidos nao entregues
cSql := ""
cSql := "SELECT C9_FILIAL, REPRESENTANTE, CLIENTE, LOJA, C9_AGREG, C9_DATALIB, SUM(C9_QTDLIB*C9_PRCVEN) AS VALOR, ZZI_ATENDE AS ATENDENTE "
DO CASE
	CASE cempant = "01"
		cSql += "FROM SC9010 C9, (SELECT C5_VEND1 AS REPRESENTANTE,CLIENTE = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END, LOJA = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END, * FROM SC5010 ) AS C5, SC6010 C6, SF4010 F4, SE4010 E4, SA1010 A1, ZZI010 ZZI "
	CASE cempant = "05"
		cSql += "FROM SC9050 C9, (SELECT C5_VEND1 AS REPRESENTANTE,CLIENTE = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END, LOJA = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END, * FROM SC5050 ) AS C5, SC6050 C6, SF4050 F4, SE4010 E4, SA1050 A1, ZZI050 ZZI "
	//CASE cempant = "07"
	//	cSql += "FROM SC9070 C9, (SELECT C5_VEND1 AS REPRESENTANTE,CLIENTE = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END, LOJA = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END, * FROM SC5070 ) AS C5, SC6070 C6, SF4070 F4, SE4010 E4, SA1070 A1, "
	//	cSql += "(SELECT * FROM ZZI010 WHERE D_E_L_E_T_ = '' "
	//	cSql += "UNION ALL "
	//	cSql += "SELECT * FROM ZZI050 WHERE D_E_L_E_T_ = '') AS ZZI "
ENDCASE

cSql += "WHERE	C9.C9_FILIAL	= '01'		     AND "
cSql += "		C9.C9_PEDIDO	= C5.C5_NUM      AND "
cSql += "		C9.C9_PEDIDO	= C6_NUM	     AND "
cSql += "		C9.C9_ITEM      = C6_ITEM	     AND "
cSql += "		C9.C9_PRODUTO   = C6_PRODUTO     AND "
cSql += "		C6.C6_TES		= F4.F4_CODIGO	 AND "
cSql += "		SUBSTRING(C9_PRODUTO,1,1) >= 'A' AND "
cSql += "		C5.C5_CONDPAG   = E4.E4_CODIGO   AND "
cSql += "		E4.E4_DESCRI NOT LIKE '%ANTE%'   AND "
cSql += "       E4.E4_YATIVO = '1'               AND "
cSql += "		C5.CLIENTE	    = A1_COD         AND "
cSql += "		C5.LOJA	        = A1_LOJA        AND "
cSql += "		C5.C5_VEND1		= ZZI.ZZI_VEND   AND "
cSql += "		A1.A1_YTPSEG	= ZZI.ZZI_TPSEG  AND "
cSql += "		F4.F4_DUPLIC  = 'S' AND  "
cSql += "       C5.C5_CONDPAG  NOT IN ('000','145','975','A75') AND "
cSql += "		C9.C9_NFISCAL = '' AND "
cSql += "		C9.D_E_L_E_T_ = '' AND "
cSql += "       C5.D_E_L_E_T_ = '' AND "
cSql += "       C6.D_E_L_E_T_ = '' AND "
cSql += "       F4.D_E_L_E_T_ = '' AND "
cSql += "       E4.D_E_L_E_T_ = '' AND "
cSql += "		A1.D_E_L_E_T_ = '' AND "
cSql += "		ZZI.D_E_L_E_T_ = '' "
cSql += "GROUP BY C9_FILIAL, CLIENTE, LOJA, REPRESENTANTE, C9_AGREG, C9_DATALIB, ZZI_ATENDE "
cSql += "ORDER BY ZZI_ATENDE, C9_FILIAL, CLIENTE, LOJA, C9_AGREG, C9_DATALIB "

If chkfile("_PED")
	dbSelectArea("_PED")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "_PED" NEW

DbSelectArea("_PED")
DbGoTop()
ProcRegua(RecCount())
nItemPrd := 0

IF  !Eof()
	CATENDENTE := _PED->ATENDENTE
END IF

While !Eof()
	
	IF  CATENDENTE <> _PED->ATENDENTE .AND. !EMPTY(cMENS2) .AND. nItemPrd >= 1
		psworder(1)
		pswseek( CATENDENTE ,.t.)
		wwUsuario1  := ALLTRIM(pswret(1)[1][4])  //NOME DO USUARIO
		__EMAIL := ALLTRIM(pswret(1)[1][14]) //EMAIL DO USUARIO
		Envemail2()
		CATENDENTE := _PED->ATENDENTE
		cMENS2 := ""
		nItemPrd := 0		
	ENDIF
	
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona Cliente da Empresa corrente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+_PED->CLIENTE+_PED->LOJA,.T.)
	
	IF STOD(_PED->C9_DATALIB) <= (DDATABASE - GETMV("MV_YPRZROM"))
		IF cItem = 1
			cMENS2 := cMENS2+'<TR bgcolor="#33CCFF">'
			cItem := 0
		ELSE
			cMENS2 := cMENS2+'<TR bgcolor="#FFFFFF">'
			cItem := 1
		ENDIF
		
		nItemPrd := nItemPrd + 1
		
		cMENS2 := cMENS2+'<TD width="35"  valign="Top"><FONT face="Verdana" size="1">'+STRZERO(nItemPrd,4)+'</TD>'
		cMENS2 := cMENS2+'<TD width="80"  valign="Top"><FONT face="Verdana" size="1">'+_PED->CLIENTE+"-"+_PED->LOJA+'</TD>'
		cMENS2 := cMENS2+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+SA1->A1_NOME+'</TD>' 
		cMENS2 := cMENS2+'<TD width="450  valign="Top"><FONT face="Verdana" size="1">'+Alltrim(_PED->REPRESENTANTE)+" - "+Posicione("SA3",1,xFilial("SA3")+_PED->REPRESENTANTE,"A3_NOME")+'</TD>'
		cMENS2 := cMENS2+'<TD width="100" valign="Top"><FONT face="Verdana" size="1">'+_PED->C9_AGREG+'</TD>'
		cMENS2 := cMENS2+'<TD width="70"  valign="Top"><FONT face="Verdana" size="1">'+SUBSTR(_PED->C9_DATALIB,7,2)+"/"+SUBSTR(_PED->C9_DATALIB,5,2)+"/"+SUBSTR(_PED->C9_DATALIB,3,2)+'</TD>'
		cMENS2 := cMENS2+'<TD width="70"  valign="Top"><FONT face="Verdana" size="1">'+STR(_PED->VALOR,11,2)+'</TD>'
		cMENS2 := cMENS2+'</TR>'
	ENDIF
	
	DbSelectArea("_PED")
	DbSkip()
END

IF !EMPTY(cMENS2) .AND. nItemPrd >= 1
	psworder(1)
	pswseek( CATENDENTE ,.t.)
	wwUsuario1  := ALLTRIM(pswret(1)[1][4])  //NOME DO USUARIO
	__EMAIL := ALLTRIM(pswret(1)[1][14]) //EMAIL DO USUARIO
	Envemail2()
	CATENDENTE := _PED->ATENDENTE
	cMENS2 := ""
ENDIF

//conout('BIA422-ENCERRADO')

Return

Static Function Envioemail()

cMensag  := ''
cMensag := cMensag+'<HTML>'
cMensag := cMensag+'<script language="JavaScript"><!--'+;
'function MM_reloadPage(init) {  //reloads the window if Nav4 resized'+;
'if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {'+;
'document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}'+;
'else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();'+;
'}'+;
'MM_reloadPage(true);// -->'

cMensag := cMensag+'</script> '
cMensag := cMensag+'<TITLE> Relação de clientes bloqueados com pedidos em aberto.</TITLE> '
// DADOS DA BIANCOGRES
cMensag := cMensag+'<BODY> '
cMensag := cMensag+'<FONT face="Verdana" size="1"> '
// MENSAGENS AUTOMATICAS
cMensag := cMensag+'<BR> '
// OBSERVACOES
cMensag := cMensag+'<BR> Segue abaixo a relação de clientes bloqueados com pedidos em aberto até o presente momento da Empresa '+ALLTRIM(SM0->M0_NOMECOM)+':'
cMensag := cMensag+'<BR> '
// DADOS DA TABELA
cMensag := cMensag+'<TABLE border="1"> '
cMensag := cMensag+'<TR bgcolor="#0000CC" bordercolor="#999999"> '
cMensag := cMensag+'<TD width="26"><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Item</div></TD> '

IF !EMPTY(cMENS)
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Cliente-Loja</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Nome do Cliente</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Representante</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Carga</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Saldo de Crédito</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Valor Liberado</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Motivo Blq.</div></TD> '
ELSE
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Cliente-Loja</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Nome do Cliente</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Representante</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Carga</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Emissão do Carga</div></TD> '
	cMensag := cMensag+'<TD><div align="left"><FONT face="Verdana" size="1" color="#FFFFFF">Valor</div></TD> '
ENDIF

cMensag := cMensag+'</TR> '
cMensag := cMensag+cMENS
cMensag := cMensag+'</TABLE> '
// RODAPE
cMensag := cMensag+'<BR> '
cMensag := cMensag+'<BR> Atenciosamente,'
cMensag := cMensag+'<BR> '
cMensag := cMensag+'<BR>Qualquer dúvida entre em contato com o departamento comercial. '
cMensag := cMensag+'Este e-mail é automático.'+'<BR> '
cMensag := cMensag+'Não Responda esta mensagem.'+'<BR> '
cMensag := cMensag+'<BR> '

cMensag := cMensag+'</BODY> '
cMensag := cMensag+'</HTML>'

cRecebe 	:= U_EmailWF('BIA422',cEmpAnt)
cRecebeCC	:= ""																				// Com Copia
cRecebeCO	:= ""																				// Copia Oculta
cAssunto	:= 'Relação de clientes bloqueados com pedidos em aberto.'							// Assunto do Email

U_BIAEnvMail(,cRecebe,cAssunto,cMensag)

cMensag  := ''
cMens    := ''
nItemPrd := 0

Return