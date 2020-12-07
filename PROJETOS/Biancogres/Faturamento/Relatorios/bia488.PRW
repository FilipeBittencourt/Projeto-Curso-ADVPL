#include "rwmake.ch"
#include "topconn.ch"

User Function BIA488()
Private Enter   := CHR(13)+CHR(10)
Private fCabec  := ''
Private fCabec2 := ''
Private nValor_Alim := 0

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BIA488     ³ Autor ³ Biancogres           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Autorização de Investimento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/

cHInicio := Time()
fPerg := "BIA488"
If !Pergunte(fPerg,.T.)
	Return
EndIf

Processa({|| RptDet_1()})

Return

Static Function RptDet_1()
LOCAL nPosCnt	:= 0
IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Gestão de Autorização de Investimento "+ALLTRIM(SM0->M0_NOME)+" de "+DTOC(MV_PAR01)+" a "+DTOC(MV_PAR02)
fCabec2  := " "
wnPag    := 0
nRow1    := 0
aDados2  := {}
aDados3  := {}

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

//Valor do Visa Vale
nValor_Alim := 557.96

fImpCabec()

IF MV_PAR09 == 1
	
	//Monta area de trabalho para gerar a planilha em excel
	aCampos := {}
	AADD(aCampos,{ "NUMERO   " , "C", 025, 0 })
	AADD(aCampos,{ "DTMOV    " , "C", 008, 0 })
	AADD(aCampos,{ "CV       " , "C", 004, 0 })
	AADD(aCampos,{ "DESC_PROD" , "C", 300, 0 })
	AADD(aCampos,{ "CLI_FOR  " , "C", 300, 0 })
	AADD(aCampos,{ "CLI_AI   " , "C", 300, 0 })
	AADD(aCampos,{ "VALOR    " , "C", 018, 0 })
	AADD(aCampos,{ "TIPO     " , "C", 001, 0 })
	
	CSQL := "SELECT * " + Enter
	CSQL += "FROM "+RETSQLNAME("CTD")+" CTD " + Enter
	CSQL += "WHERE SUBSTRING(CTD_ITEM,1,1) = 'I' AND " + Enter
	CSQL += "	     CTD_BLOQ = '2' AND " + Enter
	CSQL += "      CTD_ITEM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND " + Enter
	CSQL += "      CTD.D_E_L_E_T_ = '' " + Enter
	CSQL += "ORDER BY CTD_ITEM " + Enter
	IF CHKFILE("_CTR")
		DBSELECTAREA("_CTR")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_CTR" NEW
	
	DbSelectArea("_CTR")
	DbGoTop()
	
	WHILE !Eof()
		
		If nRow1 > 1
			fImpRoda()
			fImpCabec()
		EndIf
		
		//Totaliza as notas fiscais de entrada
		CSQL := "SELECT ISNULL(SUM(D1_TOTAL),0) AS ENTRADA" + Enter
		
		CSQL += " FROM (SELECT D1_CLVL, SUBSTRING(D1_ITEMCTA,1,5) AS D1_ITEMCTA, D1_CONTA, D1_DTDIGIT, D1_YSI, (D1_TOTAL - D1_VALDESC) AS D1_TOTAL FROM SD1010 WHERE D_E_L_E_T_ = '' " + Enter
		CSQL += " UNION ALL  " + Enter
		CSQL += "       SELECT D1_CLVL, SUBSTRING(D1_ITEMCTA,1,5) AS D1_ITEMCTA, D1_CONTA, D1_DTDIGIT, D1_YSI, (D1_TOTAL - D1_VALDESC) AS D1_TOTAL FROM SD1050 WHERE D_E_L_E_T_ = '' " + Enter
		CSQL += " UNION ALL  " + Enter
		CSQL += "       SELECT D1_CLVL, SUBSTRING(D1_ITEMCTA,1,5) AS D1_ITEMCTA, D1_CONTA, D1_DTDIGIT, D1_YSI, (D1_TOTAL - D1_VALDESC) AS D1_TOTAL FROM SD1070 WHERE D_E_L_E_T_ = '') " + Enter		
		CSQL += " AS SD1, "+RETSQLNAME("SA1")+" SA1 " + Enter
		
		CSQL += " WHERE SUBSTRING(D1_ITEMCTA,1,1) = 'I' AND D1_ITEMCTA <> 'I9999' " + Enter
		IF DTOS(dDatabase) >= '20130701'
			CSQL += " AND (SUBSTRING(D1_CONTA,1,5) = '31401' OR SUBSTRING(D1_CONTA,1,5) = '31406') " + Enter
		ELSE
			CSQL += " AND (SUBSTRING(D1_CONTA,1,5) = '31401' OR SUBSTRING(D1_CONTA,1,5) = '31404') " + Enter
		ENDIF
		CSQL += " AND SUBSTRING(D1_CONTA,1,7) <> '31401017' " + Enter
		CSQL += " AND D1_YSI = A1_COD " + Enter
		CSQL += " AND D1_DTDIGIT BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		CSQL += " AND D1_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
		CSQL += " AND D1_ITEMCTA       =  '"+_CTR->CTD_ITEM+"' " + Enter
		CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
		CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
		CSQL += " AND D1_CLVL          IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
		CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
		
		IF CHKFILE("_ENTRADA")
			DBSELECTAREA("_ENTRADA")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_ENTRADA" NEW
		
		//Totaliza as notas fiscais de saida, tratando a empresa LM
		CSQL := "SELECT  ISNULL(SUM(SAIDA),0) AS SAIDA  " + Enter
		CSQL += "FROM ( " + Enter
		
		////CSQL += "SELECT SUM(D2_QUANT*CP) AS SAIDA" + Enter
		CSQL += "SELECT SUM(D2_QUANT*CPV) AS SAIDA" + Enter
        CSQL += " FROM (SELECT D2_CUSTO1/D2_QUANT AS CPV, * 		
		//CSQL += " FROM (SELECT *, 
		////(SELECT dbo.FN_CP(SUBSTRING(D2_YEMP,1,2),D2_COD,D2_EMISSAO,D2_EMISSAO)) AS CP 
		
		//CSQL += " CPV = CASE WHEN ISNULL((SELECT MAX(B9_DATA) FROM "+RETSQLNAME("SB9")+" WHERE B9_FILIAL = D2_FILIAL AND B9_COD = D2_COD AND B9_LOCAL = D2_LOCAL AND B9_CM1 > 0 AND D_E_L_E_T_=''),'') <> '' " + Enter
        //CSQL += "  		THEN " + Enter
        //CSQL += " 		   (SELECT TOP 1 CUSTO = B9_CM1 FROM "+RETSQLNAME("SB9")+" WHERE B9_FILIAL = D2_FILIAL AND B9_COD = D2_COD AND B9_LOCAL = D2_LOCAL AND B9_CM1 > 0 AND B9_DATA = " + Enter
        //CSQL += " 		   (SELECT MAX(B9_DATA) FROM "+RETSQLNAME("SB9")+" WHERE B9_FILIAL = D2_FILIAL AND B9_COD = D2_COD AND B9_LOCAL = D2_LOCAL AND B9_CM1 > 0 AND D_E_L_E_T_='')) " + Enter
        //CSQL += " 		ELSE " + Enter
        //CSQL += " 		    0 " + Enter
        //CSQL += " 		END " + Enter
		
        CSQL += " FROM VW_SD2 ) SD2, VW_SC5 SC5, "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) " + Enter
		
		CSQL += " WHERE D2_PEDIDO = C5_NUM " + Enter
		CSQL += " AND D2_CLIENTE  = C5_CLIENTE " + Enter
		CSQL += " AND D2_LOJA     = C5_LOJACLI " + Enter
		CSQL += " AND D2_YEMP     = C5_YEMP  " + Enter
		CSQL += " AND D2_YEMPORI  = C5_YEMPORI " + Enter		
		CSQL += " AND C5_YSI      = A1_COD " + Enter
		CSQL += " AND D2_DESCON   = 0 " + Enter
		
		CSQL += " AND D2_COD     >= 'A'  " + Enter
		
		CSQL += " AND C5_YCLVL    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
		CSQL += " AND SUBSTRING(C5_YITEMCT,1,1) = 'I' " + Enter
		//CSQL += " AND (C5_YSUBTP IN ('B','A','M','G','D') OR (C5_YSUBTP = 'O' AND SUBSTRING(D2_COD,1,3) IN ('214','216') )) " + Enter
		CSQL += " AND (C5_YSUBTP IN ('B','A','M','G','D','F') OR (C5_YSUBTP = 'O' AND SUBSTRING(D2_COD,1,3) IN ('214','216') )) " + Enter		
		CSQL += " AND D2_EMISSAO BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		CSQL += " AND D2_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
		CSQL += " AND C5_YITEMCT       =  '"+_CTR->CTD_ITEM+"' " + Enter
		CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
		CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
		CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
		
		CSQL += " UNION ALL  " + Enter
		
		CSQL += "SELECT ISNULL(SUM(D2_TOTAL+D2_VALIPI),0) AS SAIDA" + Enter
		CSQL += " FROM VW_SD2 SD2, VW_SC5 SC5, "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) " + Enter
		CSQL += " WHERE D2_PEDIDO = C5_NUM " + Enter
		CSQL += " AND D2_CLIENTE  = C5_CLIENTE " + Enter
		CSQL += " AND D2_LOJA     = C5_LOJACLI " + Enter
		CSQL += " AND D2_YEMP     = C5_YEMP  " + Enter
		CSQL += " AND D2_YEMPORI  = C5_YEMPORI " + Enter		
		CSQL += " AND C5_YSI      = A1_COD " + Enter
		CSQL += " AND D2_DESCON   = 0 " + Enter
		
		CSQL += " AND D2_COD < 'A' " + Enter
		
		CSQL += " AND C5_YCLVL    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
		CSQL += " AND SUBSTRING(C5_YITEMCT,1,1) = 'I' " + Enter
		CSQL += " AND (C5_YSUBTP = 'O' AND SUBSTRING(D2_COD,1,3) IN ('214','216')) " + Enter
		CSQL += " AND D2_EMISSAO BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		CSQL += " AND D2_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
		CSQL += " AND C5_YITEMCT       =  '"+_CTR->CTD_ITEM+"' " + Enter
		CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
		CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
		CSQL += " AND SA1.D_E_L_E_T_ = '') AS WWW " + Enter
		
		IF CHKFILE("_SAIDA")
			DBSELECTAREA("_SAIDA")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_SAIDA" NEW
		
		//Totaliza as notas fiscais de saida que contem descontos incondicionais, tratando a empresa LM
		CSQL := "SELECT ISNULL(SUM(D2_DESCON),0) AS VALDESC" + Enter
		CSQL += " FROM VW_SD2 SD2, VW_SC5 SC5, "+RETSQLNAME("SA1")+" SA1 " + Enter
		CSQL += " WHERE D2_PEDIDO = C5_NUM " + Enter
		CSQL += " AND D2_CLIENTE  = C5_CLIENTE " + Enter
		CSQL += " AND D2_LOJA     = C5_LOJACLI " + Enter
		CSQL += " AND D2_YEMP     = C5_YEMP  " + Enter
		CSQL += " AND D2_YEMPORI  = C5_YEMPORI " + Enter		
		CSQL += " AND C5_YSI      = A1_COD " + Enter
		CSQL += " AND D2_DESCON   > 0 " + Enter
		CSQL += " AND C5_YCLVL    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
		CSQL += " AND SUBSTRING(C5_YITEMCT,1,1) = 'I' " + Enter
		//CSQL += " AND (C5_YSUBTP NOT IN ('B','A','M','G','D') AND (C5_YSUBTP <> 'O' AND SUBSTRING(D2_COD,1,3) NOT IN ('214','216') )) " + Enter
		CSQL += " AND (C5_YSUBTP NOT IN ('B','A','M','G','D','F') AND (C5_YSUBTP <> 'O' AND SUBSTRING(D2_COD,1,3) NOT IN ('214','216') )) " + Enter		
		CSQL += " AND D2_EMISSAO BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		CSQL += " AND D2_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
		CSQL += " AND C5_YITEMCT       =  '"+_CTR->CTD_ITEM+"' " + Enter
		CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
		CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
		CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
		
		IF CHKFILE("_DESC_INC")
			DBSELECTAREA("_DESC_INC")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_DESC_INC" NEW
		
		// Totaliza as movimentações internas
		CSQL := "SELECT ISNULL(SUM(D3_CUSTO1),0) AS MOV_INT "+ Enter
		
		CSQL += " FROM (SELECT D3_TM, D3_COD, D3_DOC, D3_CLVL, SUBSTRING(D3_ITEMCTA,1,5) AS D3_ITEMCTA, D3_CONTA, D3_EMISSAO, D3_YSI, D3_CUSTO1 = CASE WHEN D3_TM < 500 THEN D3_CUSTO1*-1 ELSE D3_CUSTO1 END FROM SD3010 WHERE D_E_L_E_T_ = '' " + Enter
		CSQL += " UNION ALL  " + Enter
		CSQL += "       SELECT D3_TM, D3_COD, D3_DOC, D3_CLVL, SUBSTRING(D3_ITEMCTA,1,5) AS D3_ITEMCTA, D3_CONTA, D3_EMISSAO, D3_YSI, D3_CUSTO1 = CASE WHEN D3_TM < 500 THEN D3_CUSTO1*-1 ELSE D3_CUSTO1 END FROM SD3050 WHERE D_E_L_E_T_ = '') " + Enter
		CSQL += " AS SD3, "+RETSQLNAME("SA1")+" SA1 " + Enter
		
		CSQL += " WHERE SUBSTRING(D3_ITEMCTA,1,1) = 'I' " + Enter
		CSQL += " AND D3_YSI    = A1_COD " + Enter
		CSQL += " AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		CSQL += " AND D3_YSI     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
		CSQL += " AND D3_ITEMCTA       = '"+_CTR->CTD_ITEM+"' " + Enter
		CSQL += " AND A1_VEND    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
		CSQL += " AND A1_GRPVEN  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
		CSQL += " AND D3_CLVL          IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
		CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
		
		IF CHKFILE("_MOV")
			DBSELECTAREA("_MOV")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_MOV" NEW
		
		//Totaliza os descontos concedidos
		IF cEmpAnt == '01'
			CSQL := "SELECT SUM(DESCONTO1) AS DESCONTO FROM (" + Enter
			CSQL += "SELECT DESCONTO1 = CASE WHEN (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') THEN E5_VALOR*-1 ELSE E5_VALOR END " + Enter
			CSQL += "FROM "+RETSQLNAME("SE5")+" SE5, "+RETSQLNAME("SA1")+" SA1 " + Enter
			CSQL += "WHERE E5_CLIFOR  = A1_COD " + Enter
			CSQL += "AND E5_LOJA      = A1_LOJA " + Enter
			CSQL += "AND (E5_TIPODOC  IN ('DC') OR (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') OR (E5_TIPO = 'RPA' AND E5_PREFIXO = 'GPE' AND E5_MOTBX IN ('DEB','NOR')) ) " + Enter
			CSQL += "AND E5_SITUACA   <> 'C' " + Enter
			CSQL += "AND E5_CLIFOR    <> '010064' " + Enter
			CSQL += "AND SUBSTRING(E5_ITEMD,1,1) = 'I' " + Enter
			CSQL += "AND E5_ITEMD     = '"+_CTR->CTD_ITEM+"' " + Enter
			CSQL += "AND E5_CLVLDB    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
			CSQL += "AND E5_DATA    BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
			CSQL += "AND E5_CLIFOR  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
			CSQL += "AND A1_VEND    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
			CSQL += "AND A1_GRPVEN  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
			CSQL += "AND SE5.D_E_L_E_T_ = '' " + Enter
			CSQL += "AND SA1.D_E_L_E_T_ = '' " + Enter
			
			CSQL += "UNION ALL " + Enter
			
			CSQL += "SELECT DESCONTO1 = CASE WHEN (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') THEN E5_VALOR*-1 ELSE E5_VALOR END " + Enter
			CSQL += "FROM SE5070 SE5, SA1070 SA1 " + Enter
			CSQL += "WHERE E5_CLIFOR  = A1_COD " + Enter
			CSQL += "AND E5_LOJA      = A1_LOJA " + Enter
			CSQL += "AND (E5_TIPODOC  IN ('DC') OR (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') OR (E5_TIPO = 'RPA' AND E5_PREFIXO = 'GPE' AND E5_MOTBX IN ('DEB','NOR')) ) " + Enter
			CSQL += "AND E5_SITUACA   <> 'C' " + Enter
			CSQL += "AND E5_CLIFOR    <> '010064' " + Enter
			CSQL += "AND SUBSTRING(E5_ITEMD,1,1) = 'I' " + Enter
			CSQL += "AND E5_ITEMD     = '"+_CTR->CTD_ITEM+"' " + Enter
			CSQL += "AND E5_CLVLDB    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
			CSQL += "AND E5_DATA    BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
			CSQL += "AND E5_CLIFOR  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
			CSQL += "AND A1_VEND    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
			CSQL += "AND A1_GRPVEN  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
			CSQL += "AND SE5.D_E_L_E_T_ = '' " + Enter
			CSQL += "AND SA1.D_E_L_E_T_ = '') AS WWW " + Enter
		ELSE
			CSQL := "SELECT SUM(DESCONTO1) AS DESCONTO FROM (" + Enter
			CSQL += "SELECT DESCONTO1 = CASE WHEN (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') THEN E5_VALOR*-1 ELSE E5_VALOR END " + Enter
			CSQL += "FROM "+RETSQLNAME("SE5")+" SE5, "+RETSQLNAME("SA1")+" SA1 " + Enter
			CSQL += "WHERE E5_CLIFOR  = A1_COD " + Enter
			CSQL += "AND E5_LOJA      = A1_LOJA " + Enter
			CSQL += "AND (E5_TIPODOC  IN ('DC') OR (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') OR (E5_TIPO = 'RPA' AND E5_PREFIXO = 'GPE' AND E5_MOTBX IN ('DEB','NOR')) ) " + Enter
			CSQL += "AND E5_SITUACA   <> 'C' " + Enter
			CSQL += "AND E5_CLIFOR    <> '010064' " + Enter
			CSQL += "AND SUBSTRING(E5_ITEMD,1,1) = 'I' " + Enter
			CSQL += "AND E5_ITEMD     = '"+_CTR->CTD_ITEM+"' " + Enter
			CSQL += "AND E5_CLVLDB    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
			CSQL += "AND E5_DATA    BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
			CSQL += "AND E5_CLIFOR  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
			CSQL += "AND A1_VEND    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
			CSQL += "AND A1_GRPVEN  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
			//CSQL += "AND E5_RECPAG  = 'R' " + Enter
			CSQL += "AND SE5.D_E_L_E_T_ = '' " + Enter
			CSQL += "AND SA1.D_E_L_E_T_ = '') AS WWW " + Enter
		ENDIF
		
		IF CHKFILE("_DESC")
			DBSELECTAREA("_DESC")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_DESC" NEW
		
		//Totaliza lancamentos contábeis
		CSQL := "SELECT SUM(CT2_VALOR) AS CT2_VALOR " + Enter
		IF DTOS(dDatabase) >= '20130701'
			CSQL += " FROM (SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31406') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, SUBSTRING(CT2_ITEMD,1,5) CT2_ITEMD, SUBSTRING(CT2_ITEMC,1,5) CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2010 WHERE D_E_L_E_T_ = ''  " + Enter
		ELSE
			CSQL += " FROM (SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31404') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, SUBSTRING(CT2_ITEMD,1,5) CT2_ITEMD, SUBSTRING(CT2_ITEMC,1,5) CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2010 WHERE D_E_L_E_T_ = ''  " + Enter
		ENDIF
		CSQL += "       UNION ALL  " + Enter
		IF DTOS(dDatabase) >= '20130701'
			CSQL += "       SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31406') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, SUBSTRING(CT2_ITEMD,1,5) CT2_ITEMD, SUBSTRING(CT2_ITEMC,1,5) CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2050 WHERE D_E_L_E_T_ = '') " + Enter
		ELSE
			CSQL += "       SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31404') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, SUBSTRING(CT2_ITEMD,1,5) CT2_ITEMD, SUBSTRING(CT2_ITEMC,1,5) CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2050 WHERE D_E_L_E_T_ = '') " + Enter
		ENDIF
		CSQL += " AS CT2 " + Enter
		CSQL += "WHERE CT2_FILIAL = '"+xFilial("CT2")+"' " + Enter
		CSQL += "AND   CT2_DATA   BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		IF DTOS(dDatabase) >= '20130701'
			CSQL += "AND   (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31406' OR SUBSTRING(CT2_CREDIT,1,5) = '31401' OR SUBSTRING(CT2_CREDIT,1,5) = '31406') " + Enter
		ELSE
			CSQL += "AND   (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31404' OR SUBSTRING(CT2_CREDIT,1,5) = '31401' OR SUBSTRING(CT2_CREDIT,1,5) = '31404') " + Enter
		ENDIF
		CSQL += "AND    SUBSTRING(CT2_DEBITO,1,7) <> '31401017' AND SUBSTRING(CT2_CREDIT,1,7) <> '31401017' " + Enter
		CSQL += "AND   (SUBSTRING(CT2_ITEMD,1,1)  = 'I' OR SUBSTRING(CT2_ITEMC,1,1) = 'I') " + Enter
		CSQL += "AND   CT2_ITEMD <> 'I9999' AND CT2_ITEMC <> 'I9999' " + Enter		
		CSQL += "AND   SUBSTRING(CT2_ITEMD,1,3) <> 'I03' AND SUBSTRING(CT2_ITEMC,1,3) <> 'I03' " + Enter		
		CSQL += "AND   (CT2_CLVLDB   IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" OR CT2_CLVLCR IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" )"+ Enter
		CSQL += "AND   (CT2_ITEMD    =  '"+_CTR->CTD_ITEM+"'    OR CT2_ITEMC  =  '"+_CTR->CTD_ITEM+"') " + Enter
		CSQL += "AND   CT2_ROTINA = 'CTBA102' " + Enter
		
		IF CHKFILE("_CTB")
			DBSELECTAREA("_CTB")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_CTB" NEW
		
		// Totaliza os valores das promotoras nas tabelas de RH. 
		CSQL := "SELECT SUM(RD_VALOR1) AS RD_VALOR FROM ( " + Enter
		CSQL += "SELECT SUM(RD_VALOR) AS RD_VALOR1 " + Enter
		CSQL += "FROM SRD010 SRD, SRA010 SRA " + Enter
		CSQL += "WHERE RA_MAT = RD_MAT " + Enter
		CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6944','7045') " + Enter
		//Verba 792 retirada por Wanisay no dia 28/07/15 - OS 2908-15
		//CSQL += "  AND RD_PD IN ('731','732','781','782','792','876','877','730','718','743','744')   " + Enter
		//Inserido/retirado verbas no dia 17/05/16 com Lorena e Claudia Mara 
		//CSQL += "  AND RD_PD IN ('731','732','781','782','876','877','730','718','743','744')   " + Enter
		//Inserido verba no dia 15/12/16 com Lorena		
		//CSQL += "  AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744')   " + Enter				
		CSQL += "  AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')   " + Enter
		CSQL += "  AND RD_DATARQ = SUBSTRING('"+dtos(MV_PAR01)+"',1,6) " + Enter
		CSQL += "  AND SRA.D_E_L_E_T_ = ' ' " + Enter
		CSQL += "  AND SRD.D_E_L_E_T_ = ' ' " + Enter
		CSQL += " UNION ALL " + Enter
		CSQL += "SELECT SUM(RD_VALOR) AS RD_VALOR1 " + Enter
		CSQL += "FROM SRD050 SRD, SRA050 SRA " + Enter
		CSQL += "WHERE RA_MAT = RD_MAT " + Enter
		CSQL += "  AND RA_CODFUNC IN ('341','342','343','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
		//Verba 792 retirada por Wanisay no dia 28/07/15 - OS 2908-15
		//CSQL += "  AND RD_PD IN ('731','732','781','782','792','876','877','730','718','743','744')   " + Enter
		//Inserido/retuirado verbas no dia 17/05/16 com Lorena e Claudia Mara 		
		//CSQL += "  AND RD_PD IN ('731','732','781','782','876','877','730','718','743','744')   " + Enter
		//Inserido verba no dia 15/12/16 com Lorena		
		//CSQL += "  AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744')   " + Enter				
		CSQL += "  AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')   " + Enter
		CSQL += "  AND RD_DATARQ = SUBSTRING('"+dtos(MV_PAR01)+"',1,6) " + Enter
		CSQL += "  AND SRA.D_E_L_E_T_ = ' ' " + Enter
		CSQL += "  AND SRD.D_E_L_E_T_ = ' ' ) AS WWW" + Enter
		
		IF CHKFILE("_RH1")
			DBSELECTAREA("_RH1")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_RH1" NEW

//--------------------------------------------------------------------------------

        IF SUBSTRING(DTOS(MV_PAR01),1,6) >= '201612'
        
        	CSQL := " SELECT SUM(RT_VALOR) AS RT_VALOR FROM (  " + Enter
        
        	CSQL += " SELECT (RT_VALOR2 - RT_VALOR1) AS RT_VALOR FROM " + Enter

        	CSQL += " (SELECT SUM(RT_VALOR) AS RT_VALOR1 " + Enter
        	CSQL += "  FROM SRT010 SRT, SRV010 SRV, SRA010 SRA  " + Enter 
        	CSQL += "  WHERE RT_VERBA = RV_COD " + Enter
        	CSQL += "  AND RT_MAT = RA_MAT " + Enter 
        	CSQL += "  AND RT_DATACAL = '"+dtos(MV_PAR01-1)+"' " + Enter
        	CSQL += "  AND RT_TIPPROV IN ('2','3') " + Enter
        	CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
        	IF SUBSTRING(DTOS(MV_PAR01),5,2) <> '12'
        		CSQL += "  AND RT_VERBA IN ('800','802','803','804','830','833','834') " + Enter
        	ELSE
        		CSQL += "  AND RT_VERBA IN ('800','802','803','804') " + Enter
        	ENDIF
        	CSQL += "  AND SRT.D_E_L_E_T_ = '' " + Enter
        	CSQL += "  AND SRV.D_E_L_E_T_ = '' " + Enter
        	CSQL += "  AND SRA.D_E_L_E_T_ = '' " + Enter
        	CSQL += "  GROUP BY RT_DATACAL) AS TAB1,  " + Enter

        	CSQL += " (SELECT SUM(RT_VALOR) AS RT_VALOR2 " + Enter
        	CSQL += "  FROM SRT010 SRT, SRV010 SRV, SRA010 SRA   " + Enter
        	CSQL += "  WHERE RT_VERBA = RV_COD " + Enter
        	CSQL += "  AND RT_MAT = RA_MAT " + Enter        	
        	CSQL += "  AND RT_DATACAL = '"+dtos(MV_PAR02)+"' " + Enter
        	CSQL += "  AND RT_TIPPROV IN ('2','3') " + Enter
        	CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter        	
        	IF SUBSTRING(DTOS(MV_PAR01),5,2) <> '12'
        		CSQL += "  AND RT_VERBA IN ('800','802','803','804','830','833','834') " + Enter
        	ELSE
        		CSQL += "  AND RT_VERBA IN ('800','802','803','804') " + Enter
        	ENDIF
        	CSQL += "  AND SRT.D_E_L_E_T_ = '' " + Enter
        	CSQL += "  AND SRV.D_E_L_E_T_ = '' " + Enter
        	CSQL += "  AND SRA.D_E_L_E_T_ = '' " + Enter        	
        	CSQL += "  GROUP BY RT_DATACAL) AS TAB2 " + Enter
                
        	CSQL += "  UNION ALL " + Enter
                        
            CSQL += " SELECT (RT_VALOR2 - RT_VALOR1) AS RT_VALOR FROM

        	CSQL += " (SELECT SUM(RT_VALOR) AS RT_VALOR1 " + Enter
        	CSQL += "  FROM SRT050 SRT, SRV010 SRV, SRA050 SRA  " + Enter 
        	CSQL += "  WHERE RT_VERBA = RV_COD " + Enter
        	CSQL += "  AND RT_MAT = RA_MAT " + Enter        	
        	CSQL += "  AND RT_DATACAL = '"+dtos(MV_PAR01-1)+"' " + Enter
        	CSQL += "  AND RT_TIPPROV IN ('2','3') " + Enter
        	CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
        	IF SUBSTRING(DTOS(MV_PAR01),5,2) <> '12'
        		CSQL += "  AND RT_VERBA IN ('800','802','803','804','830','833','834') " + Enter
        	ELSE
        		CSQL += "  AND RT_VERBA IN ('800','802','803','804') " + Enter
        	ENDIF
        	CSQL += "  AND SRT.D_E_L_E_T_ = '' " + Enter
        	CSQL += "  AND SRV.D_E_L_E_T_ = '' " + Enter
        	CSQL += "  AND SRA.D_E_L_E_T_ = '' " + Enter        	
        	CSQL += "  GROUP BY RT_DATACAL) AS TAB3,  " + Enter

        	CSQL += " (SELECT SUM(RT_VALOR) AS RT_VALOR2 " + Enter
        	CSQL += "  FROM SRT050 SRT, SRV010 SRV, SRA050 SRA   " + Enter
        	CSQL += "  WHERE RT_VERBA = RV_COD " + Enter
        	CSQL += "  AND RT_MAT = RA_MAT " + Enter        	
        	CSQL += "  AND RT_DATACAL = '"+dtos(MV_PAR02)+"' " + Enter
        	CSQL += "  AND RT_TIPPROV IN ('2','3') " + Enter
        	CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter	        	
        	IF SUBSTRING(DTOS(MV_PAR01),5,2) <> '12'
        		CSQL += "  AND RT_VERBA IN ('800','802','803','804','830','833','834') " + Enter
        	ELSE
        		CSQL += "  AND RT_VERBA IN ('800','802','803','804') " + Enter
        	ENDIF
        	CSQL += "  AND SRT.D_E_L_E_T_ = '' " + Enter
        	CSQL += "  AND SRV.D_E_L_E_T_ = '' " + Enter
        	CSQL += "  AND SRA.D_E_L_E_T_ = '' " + Enter        	
        	CSQL += "  GROUP BY RT_DATACAL) AS TAB4) AS TAB5 " + Enter
                
        ELSE 
        
        	//Dividir os valores das verbas 800/802/803/804/830/833/834 pelo campo RT_AVOS13S da verba 800
        	//RT_TIPPROV = 1=Fer.Venc.;2=Fer.Prop.;3=13o.Sal.;4=14o.Sal.;5=Mes Ferias;6=Mes 13o
        	CSQL := "SELECT SUM(RT_VALOR/RT_AVOS13S1) AS RT_TOTAL1 FROM ( " + Enter
		
        	CSQL += "	SELECT RT_MAT, RT_CC, RT_VALOR, RT_VERBA, RT_DATACAL, RT_AVOS13S, RT_TIPPROV, " + Enter
        	CSQL += "	(SELECT CASE 																			" + Enter
        	CSQL += "					WHEN RT_AVOS13S = 0 AND DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 <> 0 THEN DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 	" + Enter
        	CSQL += "					WHEN RT_AVOS13S = 0 AND DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 =  0 THEN 1											" + Enter
        	CSQL += "					ELSE RT_AVOS13S END AS RT_AVOS13S FROM SRT010 XRT, SRA010 XRA														" + Enter
        	CSQL += "		WHERE RA_MAT = RT_MAT " + Enter
        	CSQL += "		AND SRA.RA_MAT = XRA.RA_MAT " + Enter
        	CSQL += "		AND RT_DATACAL    = '"+dtos(MV_PAR02)+"' " + Enter
        	CSQL += "       AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
        	CSQL += "		AND RT_VERBA       = '800' " + Enter
        	CSQL += "		AND RT_DATABAS <> ''	   " + Enter
        	CSQL += "		AND XRT.D_E_L_E_T_ = ''    " + Enter
        	CSQL += "		AND XRA.D_E_L_E_T_ = '') AS RT_AVOS13S1 " + Enter
		
        	CSQL += "FROM SRT010 SRT, SRA010 SRA " + Enter
        	CSQL += "WHERE RA_MAT = RT_MAT " + Enter
        	CSQL += "AND RT_VERBA NOT IN ('801','831','862','863','864','865','866') " + Enter
        	CSQL += "AND RT_DATACAL    = '"+dtos(MV_PAR02)+"' " + Enter
        	CSQL += "AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
        	CSQL += "AND RT_TIPPROV IN ('2','3') " + Enter
        	CSQL += "AND SRT.D_E_L_E_T_ = '' " + Enter
        	CSQL += "AND SRA.D_E_L_E_T_ = '' 
		
        	CSQL += " UNION ALL " + Enter    
		
        	CSQL += "	SELECT RT_MAT, RT_CC, RT_VALOR, RT_VERBA, RT_DATACAL, RT_AVOS13S, RT_TIPPROV, " + Enter
        	CSQL += "	(SELECT CASE 																			" + Enter
        	CSQL += "					WHEN RT_AVOS13S = 0 AND DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 <> 0 THEN DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 	" + Enter
        	CSQL += "					WHEN RT_AVOS13S = 0 AND DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 =  0 THEN 1											" + Enter
        	CSQL += "					ELSE RT_AVOS13S END AS RT_AVOS13S FROM SRT050 XRT, SRA050 XRA														" + Enter
        	CSQL += "		WHERE RA_MAT = RT_MAT " + Enter
        	CSQL += "		AND SRA.RA_MAT = XRA.RA_MAT " + Enter
        	CSQL += "		AND RT_DATACAL    = '"+dtos(MV_PAR02)+"' " + Enter
        	CSQL += "		AND RA_CODFUNC IN ('341','342','343','6900','6901','6902','6903','6663','6944','7045') " + Enter
        	CSQL += "		AND RT_VERBA       = '800' " + Enter
        	CSQL += "		AND RT_DATABAS <> ''	   " + Enter		
        	CSQL += "		AND XRT.D_E_L_E_T_ = '' " + Enter
        	CSQL += "		AND XRA.D_E_L_E_T_ = '') AS RT_AVOS13S1 " + Enter
		
        	CSQL += "FROM SRT050 SRT, SRA050 SRA " + Enter
        	CSQL += "WHERE RA_MAT = RT_MAT " + Enter
        	CSQL += "AND RT_VERBA NOT IN ('801','831','862','863','864','865','866') " + Enter
        	CSQL += "AND RT_DATACAL    = '"+dtos(MV_PAR02)+"' " + Enter
        	CSQL += "AND RA_CODFUNC IN ('341','342','343','6900','6901','6902','6903','6663','6944','7045')" + Enter
        	CSQL += "AND RT_TIPPROV IN ('2','3') " + Enter
        	CSQL += "AND SRT.D_E_L_E_T_ = '' " + Enter
        	CSQL += "AND SRA.D_E_L_E_T_ = '' ) AS WWW " + Enter
		
        	IF CHKFILE("_RH2")
        		DBSELECTAREA("_RH2")
        		DBCLOSEAREA()
        	ENDIF
        	TCQUERY CSQL ALIAS "_RH2" NEW
		
        	//Somar os valores das verbas de provisão 801 e 831 e não somar baixa da provisão 862, 863, 864, 865, 866
        	//RT_TIPPROV = 1=Fer.Venc.;2=Fer.Prop.;3=13o.Sal.;4=14o.Sal.;5=Mes Ferias;6=Mes 13o
        	CSQL := "SELECT SUM(RT_VALOR1) AS RT_VALOR FROM ( " + Enter
        	CSQL += "SELECT RT_MAT, SUM(RT_VALOR) AS RT_VALOR1 " + Enter
        	CSQL += "FROM SRT010 SRT, SRA010 SRA " + Enter
        	CSQL += "WHERE RA_MAT = RT_MAT " + Enter
        	CSQL += "AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
        	CSQL += "AND RT_VERBA   IN ('801','831','862','863','864','865','866') " + Enter
        	CSQL += "AND RT_DATACAL  = '"+dtos(MV_PAR02)+"' " + Enter
        	CSQL += "AND RT_TIPPROV IN ('2','3') " + Enter
        	CSQL += "AND SRT.D_E_L_E_T_ = '' " + Enter
        	CSQL += "AND SRA.D_E_L_E_T_ = '' " + Enter 
        	CSQL += "GROUP BY RT_MAT " + Enter		

        	CSQL += " UNION ALL " + Enter    
				
        	CSQL += "SELECT RT_MAT, SUM(RT_VALOR) AS RT_VALOR1 " + Enter
        	CSQL += "FROM SRT050 SRT, SRA050 SRA " + Enter
        	CSQL += "WHERE RA_MAT = RT_MAT " + Enter
        	CSQL += "AND RA_CODFUNC IN ('341','342','343','6900','6901','6902','6903','6663','6944','7045') " + Enter
        	CSQL += "AND RT_VERBA   IN ('801','831','862','863','864','865','866') " + Enter
        	CSQL += "AND RT_DATACAL  = '"+dtos(MV_PAR02)+"' " + Enter
        	CSQL += "AND RT_TIPPROV IN ('2','3') " + Enter
        	CSQL += "AND SRT.D_E_L_E_T_ = '' " + Enter
        	CSQL += "AND SRA.D_E_L_E_T_ = '' " + Enter
		
        	CSQL += "GROUP BY RT_MAT ) AS WWW " + Enter

		ENDIF
		
		IF CHKFILE("_RH3")
			DBSELECTAREA("_RH3")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_RH3" NEW

//--------------------------------------------------------------------------------

		// Cálculo do Visa Vale para as Promotoras
		CSQL := "SELECT COUNT(*) AS CONTADOR FROM ( " + Enter
		CSQL += "SELECT RA_MAT " + Enter
		CSQL += "FROM SRD010 SRD, SRA010 SRA " + Enter
		CSQL += "WHERE RA_MAT = RD_MAT " + Enter
		CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
		CSQL += "  AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')   " + Enter				
		CSQL += "  AND RD_DATARQ = SUBSTRING('"+dtos(MV_PAR01)+"',1,6) " + Enter
		CSQL += "  AND SUBSTRING(RA_ADMISSA,1,6) < SUBSTRING('"+dtos(MV_PAR01)+"',1,6) " + Enter
		CSQL += "  AND SRA.D_E_L_E_T_ = ' ' " + Enter
		CSQL += "  AND SRD.D_E_L_E_T_ = ' ' " + Enter
		CSQL += "  GROUP BY RA_MAT " + Enter
		CSQL += " UNION ALL " + Enter
		CSQL += "SELECT RA_MAT " + Enter
		CSQL += "FROM SRD050 SRD, SRA050 SRA " + Enter
		CSQL += "WHERE RA_MAT = RD_MAT " + Enter
		CSQL += "  AND RA_CODFUNC IN ('341','342','343','6900','6901','6902','6903','6663','6944','7045') " + Enter
		CSQL += "  AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')   " + Enter				
		CSQL += "  AND RD_DATARQ = SUBSTRING('"+dtos(MV_PAR01)+"',1,6) " + Enter
		CSQL += "  AND SUBSTRING(RA_ADMISSA,1,6) < SUBSTRING('"+dtos(MV_PAR01)+"',1,6) " + Enter		
		CSQL += "  AND SRA.D_E_L_E_T_ = ' ' " + Enter
		CSQL += "  AND SRD.D_E_L_E_T_ = ' ' GROUP BY RA_MAT ) AS WWW" + Enter
		
		IF CHKFILE("_RH4")
			DBSELECTAREA("_RH4")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_RH4" NEW
		
		// Totaliza os valores das promotoras referente a Licença Maternidade para abater ao valor Total. 
		CSQL := "SELECT SUM(RD_VALOR1) AS RD_VALOR FROM ( " + Enter
		CSQL += "SELECT SUM(RD_VALOR) AS RD_VALOR1 " + Enter
		CSQL += "FROM SRD010 SRD, SRA010 SRA " + Enter
		CSQL += "WHERE RA_MAT = RD_MAT " + Enter
		CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6944','7045') " + Enter
		CSQL += "  AND RD_PD IN ('131','174')   " + Enter
		CSQL += "  AND RD_DATARQ = SUBSTRING('"+dtos(MV_PAR01)+"',1,6) " + Enter
		CSQL += "  AND SRA.D_E_L_E_T_ = ' ' " + Enter
		CSQL += "  AND SRD.D_E_L_E_T_ = ' ' " + Enter
		CSQL += " UNION ALL " + Enter
		CSQL += "SELECT SUM(RD_VALOR) AS RD_VALOR1 " + Enter
		CSQL += "FROM SRD050 SRD, SRA050 SRA " + Enter
		CSQL += "WHERE RA_MAT = RD_MAT " + Enter
		CSQL += "  AND RA_CODFUNC IN ('341','342','343','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
		CSQL += "  AND RD_PD IN ('131','174')   " + Enter
		CSQL += "  AND RD_DATARQ = SUBSTRING('"+dtos(MV_PAR01)+"',1,6) " + Enter
		CSQL += "  AND SRA.D_E_L_E_T_ = ' ' " + Enter
		CSQL += "  AND SRD.D_E_L_E_T_ = ' ' ) AS WWW" + Enter
		
		IF CHKFILE("_RH5")
			DBSELECTAREA("_RH5")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_RH5" NEW
		
		//Calculo do valor do Visa Vale de Promotoras Afastadas.
		
		//Contar o nº de dias que a promotora trabalhou antes do afastamento - período inicial
		CSQL := " SELECT SUM(DIAS) AS DIAS FROM (  " + Enter
		CSQL += "   SELECT SUM(DIAS_INI) AS DIAS FROM (  " + Enter 
		CSQL += "   SELECT RA_MAT, MAX(DATEDIFF(D,'"+dtos(MV_PAR01)+"',R8_DATAINI)) AS DIAS_INI, MAX(DATEDIFF(D,R8_DATAFIM,'"+dtos(MV_PAR02)+"')) AS DIAS_FIM  " + Enter
		CSQL += "   FROM SRD010 SRD, SRA010 SRA, SR8010 SR8  " + Enter 
		CSQL += "   WHERE RA_MAT = RD_MAT  " + Enter
		CSQL += "   AND RA_MAT = R8_MAT " + Enter
		CSQL += "   AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045')  " + Enter 
		CSQL += "   AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')  " + Enter  				
		CSQL += "   AND RD_DATARQ = SUBSTRING('201611',1,6)  " + Enter
		CSQL += "   AND SUBSTRING(RA_ADMISSA,1,6)  < SUBSTRING('"+dtos(MV_PAR01)+"',1,6)  " + Enter 
		CSQL += "   AND (SUBSTRING(R8_DATAINI,1,6) = SUBSTRING('"+dtos(MV_PAR01)+"',1,6))  " + Enter
		CSQL += "   AND R8_TIPO <> 'F'  " + Enter
		CSQL += "   AND R8_TIPOAFA <> '001'  " + Enter
		CSQL += "   AND SRA.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   AND SRD.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   AND SR8.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   GROUP BY RA_MAT ) AS WWW  " + Enter
		CSQL += "   WHERE DIAS_INI > 0  " + Enter
		
		CSQL += "    UNION ALL  " + Enter

        //Contar o nº de dias que a promotora trabalhou após o afastamento - período final
		CSQL += "   SELECT SUM(DIAS_FIM) AS DIAS FROM (  " + Enter 
		CSQL += "   SELECT RA_MAT, MAX(DATEDIFF(D,'"+dtos(MV_PAR01)+"',R8_DATAINI)) AS DIAS_INI, MAX(DATEDIFF(D,R8_DATAFIM,'"+dtos(MV_PAR02)+"')) AS DIAS_FIM  " + Enter
		CSQL += "   FROM SRD010 SRD, SRA010 SRA, SR8010 SR8  " + Enter
		CSQL += "   WHERE RA_MAT = RD_MAT  " + Enter
		CSQL += "   AND RA_MAT = R8_MAT  " + Enter
		CSQL += "   AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045')  " + Enter 
		CSQL += "   AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')  " + Enter  				
		CSQL += "   AND RD_DATARQ = SUBSTRING('201611',1,6)  " + Enter
		CSQL += "   AND SUBSTRING(RA_ADMISSA,1,6)  < SUBSTRING('"+dtos(MV_PAR01)+"',1,6)  " + Enter 
		CSQL += "   AND (SUBSTRING(R8_DATAFIM,1,6) = SUBSTRING('"+dtos(MV_PAR02)+"',1,6))  " + Enter
		CSQL += "   AND R8_TIPO <> 'F'  " + Enter
		CSQL += "   AND R8_TIPOAFA <> '001'  " + Enter
		CSQL += "   AND SRA.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   AND SRD.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   AND SR8.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   GROUP BY RA_MAT ) AS WWW  " + Enter
		CSQL += "   WHERE DIAS_FIM <= 31  " + Enter		

		CSQL += "    UNION ALL  " + Enter

        //Contar o nº de dias que a promotora trabalhou antes do afastamento - período inicial
		CSQL += " 	SELECT SUM(DIAS_INI) AS DIAS FROM (  " + Enter 
		CSQL += "   SELECT RA_MAT, MAX(DATEDIFF(D,'"+dtos(MV_PAR01)+"',R8_DATAINI)) AS DIAS_INI, MAX(DATEDIFF(D,R8_DATAFIM,'"+dtos(MV_PAR02)+"')) AS DIAS_FIM  " + Enter
		CSQL += "   FROM SRD050 SRD, SRA050 SRA, SR8050 SR8  " + Enter 
		CSQL += "   WHERE RA_MAT = RD_MAT  " + Enter
		CSQL += "   AND RA_MAT = R8_MAT  " + Enter
		CSQL += "   AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045')  " + Enter 
		CSQL += "   AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')  " + Enter  				
		CSQL += "   AND RD_DATARQ = SUBSTRING('201611',1,6)  " + Enter
		CSQL += "   AND SUBSTRING(RA_ADMISSA,1,6)  < SUBSTRING('"+dtos(MV_PAR01)+"',1,6)  " + Enter 
		CSQL += "   AND (SUBSTRING(R8_DATAINI,1,6) = SUBSTRING('"+dtos(MV_PAR01)+"',1,6))  " + Enter
		CSQL += "   AND R8_TIPO <> 'F'  " + Enter
		CSQL += "   AND R8_TIPOAFA <> '001'  " + Enter
		CSQL += "   AND SRA.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   AND SRD.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   AND SR8.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   GROUP BY RA_MAT ) AS WWW  " + Enter
		CSQL += "   WHERE DIAS_INI > 0  " + Enter
		
		CSQL += "    UNION ALL  " + Enter

		//Contar o nº de dias que a promotora trabalhou após o afastamento - período final
		CSQL += "   SELECT SUM(DIAS_FIM) AS DIAS FROM (  " + Enter 
		CSQL += "   SELECT RA_MAT, MAX(DATEDIFF(D,'"+dtos(MV_PAR01)+"',R8_DATAINI)) AS DIAS_INI, MAX(DATEDIFF(D,R8_DATAFIM,'"+dtos(MV_PAR02)+"')) AS DIAS_FIM  " + Enter
		CSQL += "   FROM SRD050 SRD, SRA050 SRA, SR8050 SR8  " + Enter
		CSQL += "   WHERE RA_MAT = RD_MAT  " + Enter
		CSQL += "   AND RA_MAT = R8_MAT  " + Enter
		CSQL += "   AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045')  " + Enter 
		CSQL += "   AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')  " + Enter  				
		CSQL += "   AND RD_DATARQ = SUBSTRING('201611',1,6)  " + Enter
		CSQL += "   AND SUBSTRING(RA_ADMISSA,1,6)  < SUBSTRING('"+dtos(MV_PAR01)+"',1,6)  " + Enter 
		CSQL += "   AND (SUBSTRING(R8_DATAFIM,1,6) = SUBSTRING('"+dtos(MV_PAR02)+"',1,6))  " + Enter
		CSQL += "   AND R8_TIPO <> 'F'  " + Enter
		CSQL += "   AND R8_TIPOAFA <> '001'  " + Enter
		CSQL += "   AND SRA.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   AND SRD.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   AND SR8.D_E_L_E_T_ = ' '  " + Enter
		CSQL += "   GROUP BY RA_MAT ) AS WWW  " + Enter
		CSQL += "   WHERE DIAS_FIM <= 31  " + Enter
		
		CSQL += "   ) AS YYY  " + Enter
						
		IF CHKFILE("_RH6")
			DBSELECTAREA("_RH6")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_RH6" NEW
		
		IF SUBSTRING(DTOS(MV_PAR01),1,6) >= '201612'		
		   _TOTAL := _ENTRADA->ENTRADA + _SAIDA->SAIDA + _MOV->MOV_INT + _DESC->DESCONTO + _DESC_INC->VALDESC + _CTB->CT2_VALOR + _RH1->RD_VALOR + _RH3->RT_VALOR + (_RH4->CONTADOR * nValor_Alim) - _RH5->RD_VALOR + (_RH6->DIAS * nValor_Alim/30)
		ELSE
		   _TOTAL := _ENTRADA->ENTRADA + _SAIDA->SAIDA + _MOV->MOV_INT + _DESC->DESCONTO + _DESC_INC->VALDESC + _CTB->CT2_VALOR + _RH1->RD_VALOR + _RH2->RT_TOTAL1 + _RH3->RT_VALOR + (_RH4->CONTADOR * nValor_Alim) - _RH5->RD_VALOR + (_RH6->DIAS * nValor_Alim/30)		
		ENDIF    
		
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Processando: "+cTempo)
		
		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf
		
		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek(xFilial("CTD")+_CTR->CTD_ITEM)
		
		nRow1 += 020
		DbSelectArea("_CTR")
		fr_Quebra := +;
		Padr(CTD->CTD_ITEM                                                         					,25)+" "+;
		Padr(SPACE(08)                                                         					    ,08)+" "+;
		Padr(SPACE(04)                                                         					    ,04)+" "+;
		Padr(CTD->CTD_DESC01                                                       					,143)+" "+;
		Padl(Transform(_TOTAL, "@E 999,999,999.99")                 	   				          	,14)
		
		oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
		nRow1 += 030
		
		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf
		
		oPrint:Line (nRow1, 010, nRow1, 3550)
		nRow1 += 020
		
		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf
		
		//Busca todas as notas fiscais de entrada de forma analitica
		CSQL := "SELECT D1_ITEM, D1_SERIE, D1_DOC, D1_FORNECE, D1_LOJA, D1_PEDIDO, D1_ITEMPC, SUBSTRING(D1_ITEMCTA,1,5) AS D1_ITEMCTA, D1_COD, D1_TOTAL AS D1_TOTAL, D1_DTDIGIT, D1_CLVL, D1_YSI, D1_CONTA " + Enter
		
		CSQL += " FROM (SELECT D1_ITEM, D1_SERIE, D1_DOC, D1_FORNECE, D1_LOJA, D1_PEDIDO, D1_ITEMPC, SUBSTRING(D1_ITEMCTA,1,5) AS D1_ITEMCTA, D1_COD, (D1_TOTAL - D1_VALDESC) AS D1_TOTAL, D1_DTDIGIT, D1_CLVL, D1_YSI, D1_CONTA FROM SD1010 WHERE D_E_L_E_T_ = '' " + Enter
		CSQL += " UNION ALL  " + Enter
		CSQL += "       SELECT D1_ITEM, D1_SERIE, D1_DOC, D1_FORNECE, D1_LOJA, D1_PEDIDO, D1_ITEMPC, SUBSTRING(D1_ITEMCTA,1,5) AS D1_ITEMCTA, D1_COD, (D1_TOTAL - D1_VALDESC) AS D1_TOTAL, D1_DTDIGIT, D1_CLVL, D1_YSI, D1_CONTA FROM SD1050 WHERE D_E_L_E_T_ = '' " + Enter
		CSQL += " UNION ALL  " + Enter
		CSQL += "       SELECT D1_ITEM, D1_SERIE, D1_DOC, D1_FORNECE, D1_LOJA, D1_PEDIDO, D1_ITEMPC, SUBSTRING(D1_ITEMCTA,1,5) AS D1_ITEMCTA, D1_COD, (D1_TOTAL - D1_VALDESC) AS D1_TOTAL, D1_DTDIGIT, D1_CLVL, D1_YSI, D1_CONTA FROM SD1070 WHERE D_E_L_E_T_ = '') " + Enter
		CSQL += " AS SD1, "+RETSQLNAME("SA1")+" SA1 " + Enter
		
		CSQL += " WHERE SUBSTRING(D1_ITEMCTA,1,1) = 'I' AND D1_ITEMCTA <> 'I9999' " + Enter
		IF DTOS(dDatabase) >= '20130701'
			CSQL += " AND (SUBSTRING(D1_CONTA,1,5) = '31401' OR SUBSTRING(D1_CONTA,1,5) = '31406') " + Enter
		ELSE
			CSQL += " AND (SUBSTRING(D1_CONTA,1,5) = '31401' OR SUBSTRING(D1_CONTA,1,5) = '31404') " + Enter
		ENDIF
		
		CSQL += " AND SUBSTRING(D1_CONTA,1,7) <> '31401017' " + Enter
		CSQL += " AND D1_YSI = A1_COD " + Enter
		CSQL += " AND D1_DTDIGIT BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		CSQL += " AND D1_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
		CSQL += " AND D1_ITEMCTA       =  '"+_CTR->CTD_ITEM+"' " + Enter
		CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
		CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
		CSQL += " AND D1_CLVL          IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
		CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
		CSQL += " ORDER BY SUBSTRING(D1_ITEMCTA,1,5), D1_SERIE, D1_DOC "+ Enter
		
		IF CHKFILE("_ENTRADA1")
			DBSELECTAREA("_ENTRADA1")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_ENTRADA1" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_ENTRADA1")
		While !Eof()
			
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'NOTAS FISCAIS DE ENTRADA:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF
			
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+_ENTRADA1->D1_FORNECE+_ENTRADA1->D1_LOJA)
			cNome   := ALLTRIM(SA2->A2_COD+'-'+SA2->A2_LOJA+'-'+SUBSTR(SA2->A2_NOME,1,30))
			cDescri := ''
			
			IF !EMPTY(_ENTRADA1->D1_PEDIDO)
				DbSelectArea("SC7")
				DbSetOrder(1)
				DbSeek(xFilial("SC7")+_ENTRADA1->D1_PEDIDO+_ENTRADA1->D1_ITEMPC)
				cDescri := SUBSTRING(SC7->C7_DESCRI,1,35)
			ELSE
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+_ENTRADA1->D1_COD)
				cDescri := SUBSTRING(SB1->B1_DESC,1,35)
			ENDIF
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+_ENTRADA1->D1_YSI)
			cCliente := ALLTRIM(SUBSTR(SA1->A1_NOME,1,40))
			
			fr_Quebra := +;
			Padr(SUBSTRING(_ENTRADA1->D1_ITEMCTA,1,5)+'-'+_ENTRADA1->D1_SERIE+'-'+ALLTRIM(_ENTRADA1->D1_DOC)+'-'+_ENTRADA1->D1_ITEM ,25)+" "+;
			Padr(STOD(_ENTRADA1->D1_DTDIGIT)                                           								  		 	    ,08)+" "+;
			Padr(ALLTRIM(_ENTRADA1->D1_CLVL)                                           												,04)+SPACE(5)+;
			Padr(cDescri                                                              												,35)+SPACE(5)+;
			Padr(cNome                                                                   											,40)+SPACE(5)+;
			Padr(_ENTRADA1->D1_YSI+"-"+cCliente                                              										,50)+SPACE(5)+;
			Padl(Transform(_ENTRADA1->D1_TOTAL, "@E 999,999,999.99")  																,14)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			//Grava dados para planilha em excel
			cTipo = '1' //Entradas
			aAdd(aDados2, { SUBSTRING(_ENTRADA1->D1_ITEMCTA,1,5)+'-'+ALLTRIM(_ENTRADA1->D1_SERIE)+'-'+ALLTRIM(_ENTRADA1->D1_DOC)+'-'+_ENTRADA1->D1_ITEM,;
			STOD(_ENTRADA1->D1_DTDIGIT),;
			ALLTRIM(_ENTRADA1->D1_CLVL),;
			cDescri,;
			cNome,;
			_ENTRADA1->D1_YSI+'-'+cCliente,;
			Transform(_ENTRADA1->D1_TOTAL, "@E 999,999,999.99"),;
			cTipo })
			
			//Gravação das Despesas de Marketing ou Autorizações de Investimentos
			IF MV_PAR13 == 1 .AND. Alltrim(Upper(cUserName)) $ 'WANISAY_RANISSES'
				DbSelectArea("SZO")
				RecLock("SZO",.T.)
				SZO->ZO_FILIAL  := xFilial("SZO")
				SZO->ZO_DATA    := STOD(_ENTRADA1->D1_DTDIGIT)
				SZO->ZO_CLIENTE := SA1->A1_COD
				SZO->ZO_LOJA    := SA1->A1_LOJA
				SZO->ZO_VALOR   := _ENTRADA1->D1_TOTAL
				SZO->ZO_DESCR   := "NFE: "+ALLTRIM(_ENTRADA1->D1_SERIE)+'-'+ALLTRIM(_ENTRADA1->D1_DOC)+'-'+_ENTRADA1->D1_ITEM+'-'+SUBSTR(cNome,1,35)+'-'+SUBSTR(cDescri,1,35)
				SZO->ZO_STATUS  := 'Baixa Total'
				SZO->ZO_SI      := '999999'
				SZO->ZO_ITEMCTA := _ENTRADA1->D1_ITEMCTA
				SZO->ZO_FPAGTO  := '3'
				IF cEmpAnt == '01'
					SZO->ZO_SERIE := 'S1'
					SZO->ZO_REPRE := SA1->A1_VEND
					SZO->ZO_EMP   := '0101'
				ELSE
					IF ALLTRIM(_ENTRADA1->D1_CLVL) $ '2003_2200_2215'
						SZO->ZO_SERIE := 'S2'
						SZO->ZO_EMP   := '0501'
						SZO->ZO_REPRE := SA1->A1_YVENDI
					ELSE
						SZO->ZO_SERIE := 'S3'
						SZO->ZO_EMP   := '0599'
						SZO->ZO_REPRE := SA1->A1_YVENBE1
					ENDIF
				ENDIF
				MsUnLock()
			ENDIF
			
			DbSelectArea("_ENTRADA1")
			DbSkip()
		END
		_ENTRADA1->(dbCloseArea())
		
		//Busca todas as notas fiscais de saida de forma analitica                                                                                                                              
		CSQL := "SELECT D2_CLIENTE, D2_LOJA, D2_TOTAL, D2_VALIPI, SUBSTRING(C5_YITEMCT,1,5) AS C5_YITEMCT, D2_SERIE, D2_DOC, D2_ITEM, D2_COD, D2_EMISSAO, C5_YCLVL, C5_YSUBTP, C5_YSI, D2_PRCVEN, D2_QUANT, D2_CUSTO1/D2_QUANT AS D2_CUSTO1, D2_YEMP " + Enter
		//CSQL := "SELECT D2_CLIENTE, D2_LOJA, D2_TOTAL, D2_VALIPI, SUBSTRING(C5_YITEMCT,1,5) AS C5_YITEMCT, D2_SERIE, D2_DOC, D2_ITEM, D2_COD, D2_EMISSAO, C5_YCLVL, C5_YSUBTP, C5_YSI, " + Enter
		////(SELECT dbo.FN_CP(SUBSTRING(D2_YEMP,1,2),D2_COD,D2_EMISSAO,D2_EMISSAO)) AS ZZ5_CP,
		
        //CSQL += " ZZ5_CPV = CASE WHEN ISNULL((SELECT MAX(B9_DATA) FROM "+RETSQLNAME("SB9")+" WHERE B9_FILIAL = D2_FILIAL AND B9_COD = D2_COD AND B9_LOCAL = D2_LOCAL AND B9_CM1 > 0 AND D_E_L_E_T_=''),'') <> '' " + Enter
        //CSQL += "           THEN " + Enter
        //CSQL += "			    (SELECT TOP 1 CUSTO = B9_CM1 FROM "+RETSQLNAME("SB9")+" WHERE B9_FILIAL = D2_FILIAL AND B9_COD = D2_COD AND B9_LOCAL = D2_LOCAL AND B9_CM1 > 0 AND B9_DATA =  " + Enter
        //CSQL += "				(SELECT MAX(B9_DATA) FROM "+RETSQLNAME("SB9")+" WHERE B9_FILIAL = D2_FILIAL AND B9_COD = D2_COD AND B9_LOCAL = D2_LOCAL AND B9_CM1 > 0 AND D_E_L_E_T_='')) " + Enter
        //CSQL += "			ELSE " + Enter
        //CSQL += "				0 " + Enter
        //CSQL += "			END " + Enter
		
        //CSQL += " ,D2_QUANT " + Enter
		CSQL += " FROM VW_SD2 SD2, VW_SC5 SC5, "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) " + Enter
		CSQL += " WHERE D2_PEDIDO = C5_NUM " + Enter
		CSQL += " AND D2_CLIENTE  = C5_CLIENTE " + Enter
		CSQL += " AND D2_LOJA     = C5_LOJACLI " + Enter
		CSQL += " AND D2_YEMP     = C5_YEMP  " + Enter
		CSQL += " AND D2_YEMPORI  = C5_YEMPORI " + Enter		
		CSQL += " AND C5_YSI      = A1_COD " + Enter
		CSQL += " AND D2_DESCON   = 0 " + Enter
		
		CSQL += " AND D2_COD     >= 'A'  " + Enter
		
		CSQL += " AND C5_YCLVL    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
		CSQL += " AND SUBSTRING(C5_YITEMCT,1,1) = 'I' " + Enter
		//CSQL += " AND (C5_YSUBTP IN ('B','A','M','G','D') OR (C5_YSUBTP = 'O' AND SUBSTRING(D2_COD,1,3) IN ('214','216') )) " + Enter
		CSQL += " AND (C5_YSUBTP IN ('B','A','M','G','D','F') OR (C5_YSUBTP = 'O' AND SUBSTRING(D2_COD,1,3) IN ('214','216') )) " + Enter		
		CSQL += " AND D2_EMISSAO BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		CSQL += " AND D2_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
		CSQL += " AND C5_YITEMCT       =  '"+_CTR->CTD_ITEM+"' " + Enter
		CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
		CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
		CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
		
		CSQL += " UNION ALL  " + Enter
		
		CSQL += "SELECT D2_CLIENTE, D2_LOJA, D2_TOTAL, D2_VALIPI, SUBSTRING(C5_YITEMCT,1,5) AS C5_YITEMCT, D2_SERIE, D2_DOC, D2_ITEM, D2_COD, D2_EMISSAO, C5_YCLVL, C5_YSUBTP, C5_YSI, D2_PRCVEN, D2_QUANT, D2_CUSTO1/D2_QUANT AS D2_CUSTO1, D2_YEMP " + Enter
		CSQL += " FROM VW_SD2 SD2, VW_SC5 SC5, "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) " + Enter
		CSQL += " WHERE D2_PEDIDO = C5_NUM " + Enter
		CSQL += " AND D2_CLIENTE  = C5_CLIENTE " + Enter
		CSQL += " AND D2_LOJA     = C5_LOJACLI " + Enter
		CSQL += " AND D2_YEMP     = C5_YEMP  " + Enter
		CSQL += " AND D2_YEMPORI  = C5_YEMPORI " + Enter
		CSQL += " AND C5_YSI      = A1_COD " + Enter
		CSQL += " AND D2_DESCON   = 0 " + Enter
		
		CSQL += " AND D2_COD < 'A' " + Enter
		
		CSQL += " AND C5_YCLVL    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
		CSQL += " AND SUBSTRING(C5_YITEMCT,1,1) = 'I' " + Enter
		CSQL += " AND (C5_YSUBTP = 'O' AND SUBSTRING(D2_COD,1,3) IN ('214','216') ) " + Enter
		CSQL += " AND D2_EMISSAO BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		CSQL += " AND D2_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
		CSQL += " AND C5_YITEMCT       =  '"+_CTR->CTD_ITEM+"' " + Enter
		CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
		CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
		CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
		
		IF CHKFILE("_SAIDA1")
			DBSELECTAREA("_SAIDA1")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_SAIDA1" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_SAIDA1")
		While !Eof()
			
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'NOTAS FISCAIS DE SAIDA:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+_SAIDA1->D2_CLIENTE+_SAIDA1->D2_LOJA)
			cNome := SA1->A1_COD+'-'+SA1->A1_LOJA+'-'+ALLTRIM(SA1->A1_NOME)
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+_SAIDA1->C5_YSI)
			cCliente := SUBSTR(SA1->A1_NOME,1,40)
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+_SAIDA1->D2_COD)
			cDescri := SUBSTRING(SB1->B1_DESC,1,35)
			
			IF _SAIDA1->C5_YSUBTP == 'O' .AND. SUBSTRING(_SAIDA1->D2_COD,1,3) $ '214_216' .AND. _SAIDA1->D2_COD < 'A'
				nValor := _SAIDA1->D2_TOTAL + _SAIDA1->D2_VALIPI
			ELSE
				//nValor := _SAIDA1->ZZ5_CP * _SAIDA1->D2_QUANT
				//nValor := _SAIDA1->ZZ5_CPV * _SAIDA1->D2_QUANT
				nValor := _SAIDA1->D2_CUSTO1 * _SAIDA1->D2_QUANT
			ENDIF
			
			fr_Quebra := +;
			Padr(SUBSTRING(_SAIDA1->C5_YITEMCT,1,5)+'-'+_SAIDA1->D2_SERIE+'-'+ALLTRIM(_SAIDA1->D2_DOC)+'-'+_SAIDA1->D2_ITEM+'-'+_SAIDA1->C5_YSUBTP   ,25)+" "+;
			Padr(STOD(_SAIDA1->D2_EMISSAO)                                            																						 ,08)+" "+;
			Padr(ALLTRIM(_SAIDA1->C5_YCLVL)                                              																					 ,04)+SPACE(5)+;
			Padr(cDescri                                                              																						 ,35)+SPACE(5)+;
			Padr(cNome                                                                   																					 ,40)+SPACE(5)+;
			Padr(_SAIDA1->C5_YSI+'-'+cCliente					                                                   											 	   		     ,50)+SPACE(5)+;
			Padl(Transform(nValor, "@E 999,999,999.99")																														 ,14)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			//Grava dados para planilha em excel
			cTipo = '2' //Saidas
			aAdd(aDados2, { SUBSTRING(_SAIDA1->C5_YITEMCT,1,5)+'-'+ALLTRIM(_SAIDA1->D2_SERIE)+'-'+ALLTRIM(_SAIDA1->D2_DOC)+'-'+_SAIDA1->D2_ITEM+'-'+_SAIDA1->C5_YSUBTP,;
			_SAIDA1->D2_EMISSAO,;
			ALLTRIM(_SAIDA1->C5_YCLVL),;
			cDescri,;
			cNome,;
			_SAIDA1->C5_YSI+'-'+cCliente,;
			Transform(nValor, "@E 999,999,999.99"),;
			cTipo })
			
			//Gravação das Despesas de Marketing ou Autorizações de Investimentos
			IF MV_PAR13 == 1 .AND. alltrim(upper(cUserName)) $ 'WANISAY_RANISSES'
				DbSelectArea("SZO")
				RecLock("SZO",.T.)
				SZO->ZO_FILIAL  := xFilial("SZO")
				SZO->ZO_DATA    := STOD(_SAIDA1->D2_EMISSAO)
				SZO->ZO_CLIENTE := SA1->A1_COD
				SZO->ZO_LOJA    := SA1->A1_LOJA
				SZO->ZO_VALOR   := nValor
				SZO->ZO_DESCR   := "NFS: "+ALLTRIM(_SAIDA1->D2_SERIE)+'-'+ALLTRIM(_SAIDA1->D2_DOC)+'-'+_SAIDA1->D2_ITEM+'-'+_SAIDA1->C5_YSUBTP+'-'+SUBSTR(cNome,1,35)+'-'+SUBSTR(cDescri,1,35)
				SZO->ZO_STATUS  := 'Baixa Total'
				SZO->ZO_SI      := '999999'
				SZO->ZO_ITEMCTA := _SAIDA1->C5_YITEMCT
				
				IF ALLTRIM(_SAIDA1->C5_YSUBTP) == 'O'
					SZO->ZO_FPAGTO  := '3'
				ELSE
					SZO->ZO_FPAGTO  := '1'
				ENDIF
				
				DO CASE 
				   CASE _SAIDA1->D2_YEMP == '0101'
						SZO->ZO_SERIE := 'S1'
						SZO->ZO_REPRE := SA1->A1_VEND
						SZO->ZO_EMP   := _SAIDA1->D2_YEMP
					CASE _SAIDA1->D2_YEMP == '0501'
						SZO->ZO_SERIE := 'S2'
						SZO->ZO_EMP   := _SAIDA1->D2_YEMP
						SZO->ZO_REPRE := SA1->A1_YVENDI
					CASE _SAIDA1->D2_YEMP == '0599'
						SZO->ZO_SERIE := 'S3'
						SZO->ZO_EMP   := _SAIDA1->D2_YEMP
						SZO->ZO_REPRE := SA1->A1_YVENBE1
					CASE _SAIDA1->D2_YEMP == '1399'
						SZO->ZO_SERIE := 'S4'
						SZO->ZO_EMP   := _SAIDA1->D2_YEMP
						SZO->ZO_REPRE := SA1->A1_YVENML1
				ENDCASE
				MsUnLock()
			ENDIF
			
			DbSelectArea("_SAIDA1")
			DbSkip()
		END
		_SAIDA1->(dbCloseArea())
		
		//Busca todas as notas fiscais de saida com desconto incondicional de forma analitica
		CSQL := "SELECT D2_CLIENTE, D2_LOJA, D2_DESCON, SUBSTRING(C5_YITEMCT,1,5) AS C5_YITEMCT, D2_SERIE, D2_DOC, D2_ITEM, D2_COD, D2_EMISSAO, C5_YCLVL, C5_YSUBTP, C5_YSI, D2_YEMP " + Enter
		CSQL += " FROM VW_SD2 SD2, VW_SC5 SC5, "+RETSQLNAME("SA1")+" SA1 " + Enter
		CSQL += " WHERE D2_PEDIDO = C5_NUM " + Enter
		CSQL += " AND D2_CLIENTE  = C5_CLIENTE " + Enter
		CSQL += " AND D2_LOJA     = C5_LOJACLI " + Enter
		CSQL += " AND D2_YEMP     = C5_YEMP  " + Enter
		CSQL += " AND D2_YEMPORI  = C5_YEMPORI " + Enter
		CSQL += " AND C5_YSI      = A1_COD " + Enter
		CSQL += " AND D2_DESCON > 0 " + Enter
		CSQL += " AND C5_YCLVL    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
		CSQL += " AND SUBSTRING(C5_YITEMCT,1,1) = 'I' " + Enter
		//CSQL += " AND (C5_YSUBTP NOT IN ('B','A','M','G','D') AND (C5_YSUBTP <> 'O' AND SUBSTRING(D2_COD,1,3) NOT IN ('214','216') )) " + Enter
		CSQL += " AND (C5_YSUBTP NOT IN ('B','A','M','G','D','F') AND (C5_YSUBTP <> 'O' AND SUBSTRING(D2_COD,1,3) NOT IN ('214','216') )) " + Enter		
		CSQL += " AND D2_EMISSAO BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		CSQL += " AND D2_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
		CSQL += " AND C5_YITEMCT       =  '"+_CTR->CTD_ITEM+"' " + Enter
		CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
		CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
		CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
		CSQL += " ORDER BY C5_YITEMCT " + Enter
		
		IF CHKFILE("_DESC_INC1")
			DBSELECTAREA("_DESC_INC1")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_DESC_INC1" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_DESC_INC1")
		While !Eof()
			
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'DESCONTO INCONDICIONAL:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+_DESC_INC1->D2_CLIENTE+_DESC_INC1->D2_LOJA)
			cNome := SA1->A1_COD+'-'+SA1->A1_LOJA+'-'+ALLTRIM(SA1->A1_NOME)
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+_DESC_INC1->D2_COD)
			cDescri := SUBSTRING(SB1->B1_DESC,1,35)
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+_DESC_INC1->C5_YSI)
			cCliente := SUBSTR(SA1->A1_NOME,1,40)
			
			fr_Quebra := +;
			Padr(SUBSTRING(_DESC_INC1->C5_YITEMCT,1,5)+'-'+_DESC_INC1->D2_SERIE+'-'+ALLTRIM(_DESC_INC1->D2_DOC)+'-'+_DESC_INC1->D2_ITEM+'-'+_DESC_INC1->C5_YSUBTP  ,25)+" "+;
			Padr(STOD(_DESC_INC1->D2_EMISSAO)                                      						      																															 ,08)+" "+;
			Padr(ALLTRIM(_DESC_INC1->C5_YCLVL)                                              																																			 ,04)+SPACE(5)+;
			Padr(cDescri                                                              																																  					 ,35)+SPACE(5)+;
			Padr(cNome                                                                   																														 	 						 ,40)+SPACE(5)+;
			Padr(_DESC_INC1->C5_YSI+'-'+cCliente			                                                   											 		  					 		                 ,50)+SPACE(5)+;
			Padl(Transform(_DESC_INC1->D2_DESCON, "@E 999,999,999.99")																																														 ,14)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			//Grava dados para planilha em excel
			cTipo = '3' //Desconto Incondicional
			aAdd(aDados2, { SUBSTRING(_DESC_INC1->C5_YITEMCT,1,5)+'-'+ALLTRIM(_DESC_INC1->D2_SERIE)+'-'+ALLTRIM(_DESC_INC1->D2_DOC)+'-'+_DESC_INC1->D2_ITEM+'-'+_DESC_INC1->C5_YSUBTP,;
			STOD(_DESC_INC1->D2_EMISSAO),;
			ALLTRIM(_DESC_INC1->C5_YCLVL),;
			cDescri,;
			cNome,;
			_DESC_INC1->C5_YSI+'-'+cCliente,;
			Transform(_DESC_INC1->D2_DESCON, "@E 999,999,999.99"),;
			cTipo })
			
			//Gravação das Despesas de Marketing ou Autorizações de Investimentos
			IF MV_PAR13 == 1 .AND. alltrim(upper(cUserName)) $ 'WANISAY_RANISSES'
				DbSelectArea("SZO")
				RecLock("SZO",.T.)
				SZO->ZO_FILIAL  := xFilial("SZO")
				SZO->ZO_DATA    := STOD(_DESC_INC1->D2_EMISSAO)
				SZO->ZO_CLIENTE := SA1->A1_COD
				SZO->ZO_LOJA    := SA1->A1_LOJA
				SZO->ZO_VALOR   := _DESC_INC1->D2_DESCON
				SZO->ZO_DESCR   := "NFS: "+ALLTRIM(_DESC_INC1->D2_SERIE)+'-'+ALLTRIM(_DESC_INC1->D2_DOC)+'-'+_DESC_INC1->D2_ITEM+'-'+_DESC_INC1->C5_YSUBTP+'-'+SUBSTR(cNome,1,35)+'-'+SUBSTR(cDescri,1,35)
				SZO->ZO_STATUS  := 'Baixa Total'
				SZO->ZO_SI      := '999999'
				SZO->ZO_ITEMCTA := _DESC_INC1->C5_YITEMCT
				SZO->ZO_FPAGTO  := '6'
				DO CASE 
				   CASE _DESC_INC1->D2_YEMP == '0101'
						SZO->ZO_SERIE := 'S1'
						SZO->ZO_REPRE := SA1->A1_VEND
						SZO->ZO_EMP   := _DESC_INC1->D2_YEMP
					CASE _DESC_INC1->D2_YEMP == '0501'
						SZO->ZO_SERIE := 'S2'
						SZO->ZO_EMP   := _DESC_INC1->D2_YEMP
						SZO->ZO_REPRE := SA1->A1_YVENDI
					CASE _DESC_INC1->D2_YEMP == '0599'
						SZO->ZO_SERIE := 'S3'
						SZO->ZO_EMP   := _DESC_INC1->D2_YEMP
						SZO->ZO_REPRE := SA1->A1_YVENBE1
					CASE _DESC_INC1->D2_YEMP == '1399'
						SZO->ZO_SERIE := 'S4'
						SZO->ZO_EMP   := _DESC_INC1->D2_YEMP
						SZO->ZO_REPRE := SA1->A1_YVENML1
				ENDCASE
				MsUnLock()
			ENDIF
			
			DbSelectArea("_DESC_INC1")
			DbSkip()
		END
		_DESC_INC1->(dbCloseArea())
		
		//Busca todas as movimentacoes internas de forma analitica
		CSQL := "SELECT D3_TM, D3_COD, D3_DOC, D3_CLVL, SUBSTRING(D3_ITEMCTA,1,5) AS D3_ITEMCTA, D3_CONTA, D3_EMISSAO, D3_YSI, D3_CUSTO1 " + Enter
		
		CSQL += " FROM (SELECT D3_TM, D3_COD, D3_DOC, D3_CLVL, SUBSTRING(D3_ITEMCTA,1,5) AS D3_ITEMCTA, D3_CONTA, D3_EMISSAO, D3_YSI, D3_CUSTO1 = CASE WHEN D3_TM < 500 THEN D3_CUSTO1*-1 ELSE D3_CUSTO1 END FROM SD3010 WHERE D_E_L_E_T_ = '' " + Enter
		CSQL += " UNION ALL  " + Enter
		CSQL += "       SELECT D3_TM, D3_COD, D3_DOC, D3_CLVL, SUBSTRING(D3_ITEMCTA,1,5) AS D3_ITEMCTA, D3_CONTA, D3_EMISSAO, D3_YSI, D3_CUSTO1 = CASE WHEN D3_TM < 500 THEN D3_CUSTO1*-1 ELSE D3_CUSTO1 END FROM SD3050 WHERE D_E_L_E_T_ = '') " + Enter
		CSQL += " AS SD3, "+RETSQLNAME("SA1")+" SA1 " + Enter
		
		CSQL += " WHERE SUBSTRING(D3_ITEMCTA,1,1) = 'I' " + Enter
		CSQL += " AND D3_YSI    = A1_COD " + Enter
		CSQL += " AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		CSQL += " AND D3_YSI     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
		CSQL += " AND D3_ITEMCTA       = '"+_CTR->CTD_ITEM+"' " + Enter
		CSQL += " AND A1_VEND    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
		CSQL += " AND A1_GRPVEN  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
		CSQL += " AND D3_CLVL          IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
		CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
		CSQL += " ORDER BY D3_ITEMCTA " + Enter
		
		IF CHKFILE("_MOV1")
			DBSELECTAREA("_MOV1")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_MOV1" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_MOV1")
		While !Eof()
			
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'MOVIMENTAÇÕES INTERNAS:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+_MOV1->D3_COD)
			cDescri := SUBSTRING(SB1->B1_DESC,1,35)
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+_MOV1->D3_YSI)
			cCliente := SUBSTR(SA1->A1_NOME,1,40)
			
			fr_Quebra := +;
			Padr(SUBSTRING(_MOV1->D3_ITEMCTA,1,5)+'-'+ALLTRIM(_MOV1->D3_DOC)   										    ,25)+" "+;
			Padr(STOD(_MOV1->D3_EMISSAO)                       																			  ,08)+" "+;
			Padr(ALLTRIM(_MOV1->D3_CLVL)                                              							  ,04)+SPACE(5)+;
			Padr(cDescri					                                                    							  ,35)+SPACE(5)+;
			Padr(SPACE(40)			                                                        						  ,40)+SPACE(5)+;
			Padr(_MOV1->D3_YSI+'-'+cCliente              											 		  					 		    ,50)+SPACE(5)+;
			Padl(Transform(_MOV1->D3_CUSTO1, "@E 999,999,999.99")  		                                ,14)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			//Grava dados para planilha em excel
			cTipo = '4' //Requisições
			aAdd(aDados2, { SUBSTRING(_MOV1->D3_ITEMCTA,1,5)+'-'+ALLTRIM(_MOV1->D3_DOC),;
			STOD(_MOV1->D3_EMISSAO),;
			ALLTRIM(_MOV1->D3_CLVL),;
			cDescri,;
			SPACE(40),;
			_MOV1->D3_YSI+'-'+cCliente,;
			Transform(_MOV1->D3_CUSTO1, "@E 999,999,999.99"),;
			cTipo })
			
			//Gravação das Despesas de Marketing ou Autorizações de Investimentos
			IF MV_PAR13 == 1 .AND. alltrim(upper(cUserName)) $ 'WANISAY_RANISSES'
				DbSelectArea("SZO")
				RecLock("SZO",.T.)
				SZO->ZO_FILIAL  := xFilial("SZO")
				SZO->ZO_DATA    := STOD(_MOV1->D3_EMISSAO)
				SZO->ZO_CLIENTE := SA1->A1_COD
				SZO->ZO_LOJA    := SA1->A1_LOJA
				SZO->ZO_VALOR   := _MOV1->D3_CUSTO1
				SZO->ZO_DESCR   := "MOV.INTERNA: "+ALLTRIM(_MOV1->D3_DOC)+'-'+SUBSTR(cDescri,1,35)
				SZO->ZO_STATUS  := 'Baixa Total'
				SZO->ZO_SI      := '999999'
				SZO->ZO_ITEMCTA := _MOV1->D3_ITEMCTA
				SZO->ZO_FPAGTO  := '3'
				IF cEmpAnt == '01'
					SZO->ZO_SERIE := 'S1'
					SZO->ZO_REPRE := SA1->A1_VEND
					SZO->ZO_EMP   := '0101'
				ELSE
					IF ALLTRIM(_MOV1->D3_CLVL) $ '2003_2200_2215'
						SZO->ZO_SERIE := 'S2'
						SZO->ZO_EMP   := '0501'
						SZO->ZO_REPRE := SA1->A1_YVENDI
					ELSE
						SZO->ZO_SERIE := 'S3'
						SZO->ZO_EMP   := '0599'
						SZO->ZO_REPRE := SA1->A1_YVENBE1
					ENDIF
				ENDIF
				MsUnLock()
			ENDIF
			
			DbSelectArea("_MOV1")
			DbSkip()
		END
		_MOV1->(dbCloseArea())
		
		//Busca todos os descontos concedidos de forma analitica
		IF cEmpAnt == '01'
			CSQL := "SELECT E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLVLDB, SUBSTRING(E5_ITEMD,1,5) AS E5_ITEMD, E5_HISTOR, E5_VALOR = CASE WHEN (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') THEN E5_VALOR*-1 ELSE E5_VALOR END, E5_BENEF, E5_YSI " + Enter
			CSQL += "FROM "+RETSQLNAME("SE5")+" SE5, "+RETSQLNAME("SA1")+" SA1 " + Enter
			CSQL += "WHERE E5_CLIFOR  = A1_COD " + Enter
			CSQL += "AND E5_LOJA      = A1_LOJA " + Enter
			CSQL += "AND (E5_TIPODOC  IN ('DC') OR (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') OR (E5_TIPO = 'RPA' AND E5_PREFIXO = 'GPE' AND E5_MOTBX IN ('DEB','NOR')) ) " + Enter
			CSQL += "AND E5_SITUACA <> 'C' " + Enter
			CSQL += "AND E5_CLIFOR  <> '010064' " + Enter
			CSQL += "AND SUBSTRING(E5_ITEMD,1,1) = 'I' " + Enter
			CSQL += "AND E5_ITEMD       =   '"+_CTR->CTD_ITEM+"' " + Enter
			CSQL += "AND E5_CLVLDB      IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
			CSQL += "AND E5_DATA    BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
			CSQL += "AND E5_CLIFOR  BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
			CSQL += "AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
			CSQL += "AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
			//CSQL += "AND E5_RECPAG  = 'R' " + Enter
			CSQL += "AND SE5.D_E_L_E_T_ = '' " + Enter
			CSQL += "AND SA1.D_E_L_E_T_ = '' " + Enter
			
			CSQL += "UNION ALL " + Enter
			
			CSQL += "SELECT E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLVLDB, SUBSTRING(E5_ITEMD,1,5) AS E5_ITEMD, E5_HISTOR, E5_VALOR = CASE WHEN (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') THEN E5_VALOR*-1 ELSE E5_VALOR END, E5_BENEF, E5_YSI " + Enter
			CSQL += "FROM SE5070 SE5, SA1070 SA1 " + Enter
			CSQL += "WHERE E5_CLIFOR  = A1_COD " + Enter
			CSQL += "AND E5_LOJA      = A1_LOJA " + Enter
			CSQL += "AND (E5_TIPODOC  IN ('DC') OR (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') OR (E5_TIPO = 'RPA' AND E5_PREFIXO = 'GPE' AND E5_MOTBX IN ('DEB','NOR')) ) " + Enter
			CSQL += "AND E5_SITUACA <> 'C' " + Enter
			CSQL += "AND E5_CLIFOR  <> '010064' " + Enter
			CSQL += "AND SUBSTRING(E5_ITEMD,1,1) = 'I' " + Enter
			CSQL += "AND E5_ITEMD       =   '"+_CTR->CTD_ITEM+"' " + Enter
			CSQL += "AND E5_CLVLDB      IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
			CSQL += "AND E5_DATA    BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
			CSQL += "AND E5_CLIFOR  BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
			CSQL += "AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
			CSQL += "AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
			//CSQL += "AND E5_RECPAG  = 'R' " + Enter
			CSQL += "AND SE5.D_E_L_E_T_ = '' " + Enter
			CSQL += "AND SA1.D_E_L_E_T_ = '' " + Enter
		ELSE
			CSQL := "SELECT E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLVLDB, SUBSTRING(E5_ITEMD,1,5) AS E5_ITEMD, E5_HISTOR, E5_VALOR = CASE WHEN (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') THEN E5_VALOR*-1 ELSE E5_VALOR END, E5_BENEF, E5_YSI " + Enter
			CSQL += "FROM "+RETSQLNAME("SE5")+" SE5, "+RETSQLNAME("SA1")+" SA1 " + Enter
			CSQL += "WHERE E5_CLIFOR  = A1_COD " + Enter
			CSQL += "AND E5_LOJA      = A1_LOJA " + Enter
			CSQL += "AND (E5_TIPODOC  IN ('DC') OR (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') OR (E5_TIPO = 'RPA' AND E5_PREFIXO = 'GPE' AND E5_MOTBX IN ('DEB','NOR')) ) " + Enter
			CSQL += "AND E5_SITUACA <> 'C' " + Enter
			CSQL += "AND E5_CLIFOR  <> '010064' " + Enter
			CSQL += "AND SUBSTRING(E5_ITEMD,1,1) = 'I' " + Enter
			CSQL += "AND E5_ITEMD       =   '"+_CTR->CTD_ITEM+"' " + Enter
			CSQL += "AND E5_CLVLDB      IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
			CSQL += "AND E5_DATA    BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
			CSQL += "AND E5_CLIFOR  BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
			CSQL += "AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
			CSQL += "AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
			//CSQL += "AND E5_RECPAG  = 'R' " + Enter
			CSQL += "AND SE5.D_E_L_E_T_ = '' " + Enter
			CSQL += "AND SA1.D_E_L_E_T_ = '' " + Enter
		ENDIF
		
		IF CHKFILE("_DESC1")
			DBSELECTAREA("_DESC1")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_DESC1" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_DESC1")
		While !Eof()
			
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'DESCONTOS CONCEDIDOS:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+_DESC1->E5_YSI)
			cCliente := SUBSTR(SA1->A1_NOME,1,40)
			
			fr_Quebra := +;
			Padr(SUBSTRING(_DESC1->E5_ITEMD,1,5)+'-'+_DESC1->E5_PREFIXO+'-'+ALLTRIM(_DESC1->E5_NUMERO)+'-'+_DESC1->E5_PARCELA+_DESC1->E5_TIPO   ,25)+" "+;
			Padr(STOD(_DESC1->E5_DATA)									                        																			  		     ,08)+" "+;
			Padr(ALLTRIM(_DESC1->E5_CLVLDB)                									                           									  		   ,04)+SPACE(5)+;
			Padr(_DESC1->E5_HISTOR					  					                                                							  			   ,35)+SPACE(5)+;
			Padr(_DESC1->E5_BENEF									                                                        						  			   ,40)+SPACE(5)+;
			Padr(_DESC1->E5_YSI+'-'+cCliente					                          											 		  					 		       ,50)+SPACE(5)+;
			Padl(Transform(_DESC1->E5_VALOR, "@E 999,999,999.99")  											                                			   ,14)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			//Grava dados para planilha em excel
			cTipo = '5' //Movimentos Bancários
			aAdd(aDados2, { SUBSTRING(_DESC1->E5_ITEMD,1,5)+'-'+ALLTRIM(_DESC1->E5_PREFIXO)+'-'+ALLTRIM(_DESC1->E5_NUMERO)+'-'+ALLTRIM(_DESC1->E5_PARCELA)+'-'+ALLTRIM(_DESC1->E5_TIPO),;
			STOD(_DESC1->E5_DATA),;
			ALLTRIM(_DESC1->E5_CLVLDB),;
			_DESC1->E5_HISTOR,;
			_DESC1->E5_BENEF,;
			_DESC1->E5_YSI+'-'+cCliente,;
			Transform(_DESC1->E5_VALOR, "@E 999,999,999.99"),;
			cTipo })
			
			//Gravação das Despesas de Marketing ou Autorizações de Investimentos
			IF MV_PAR13 == 1 .AND. alltrim(upper(cUserName)) $ 'WANISAY_RANISSES'
				DbSelectArea("SZO")
				RecLock("SZO",.T.)
				SZO->ZO_FILIAL  := xFilial("SZO")
				SZO->ZO_DATA    := STOD(_DESC1->E5_DATA)
				SZO->ZO_CLIENTE := SA1->A1_COD
				SZO->ZO_LOJA    := SA1->A1_LOJA
				SZO->ZO_VALOR   := _DESC1->E5_VALOR
				SZO->ZO_DESCR   := "MOV.BANC: "+ALLTRIM(_DESC1->E5_PREFIXO)+'-'+ALLTRIM(_DESC1->E5_NUMERO)+'-'+ALLTRIM(_DESC1->E5_PARCELA)+'-'+ALLTRIM(_DESC1->E5_TIPO)+'-'+SUBSTR(_DESC1->E5_BENEF,1,35)+'-'+SUBSTR(_DESC1->E5_HISTOR,1,40)
				SZO->ZO_STATUS  := 'Baixa Total'
				SZO->ZO_SI      := '999999'
				SZO->ZO_ITEMCTA := _DESC1->E5_ITEMD
				SZO->ZO_FPAGTO  := '3'
				IF cEmpAnt == '01'
					SZO->ZO_SERIE := 'S1'
					SZO->ZO_REPRE := SA1->A1_VEND
					SZO->ZO_EMP   := '0101'
				ELSE
					IF ALLTRIM(_DESC1->E5_CLVLDB) $ '2003_2200_2215'
						SZO->ZO_SERIE := 'S2'
						SZO->ZO_EMP   := '0501'
						SZO->ZO_REPRE := SA1->A1_YVENDI
					ELSE
						SZO->ZO_SERIE := 'S3'
						SZO->ZO_EMP   := '0599'
						SZO->ZO_REPRE := SA1->A1_YVENBE1
					ENDIF
				ENDIF
				MsUnLock()
			ENDIF
			
			DbSelectArea("_DESC1")
			DbSkip()
		END
		_DESC1->(dbCloseArea())
		
		//Lista Lancamentos contábeis de forma analítica
		CSQL := "SELECT CT2_VALOR, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, SUBSTRING(CT2_ITEMD,1,5) AS CT2_ITEMD, SUBSTRING(CT2_ITEMC,1,5) AS CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST  " + Enter
		IF DTOS(dDatabase) >= '20130701'
			CSQL += " FROM (SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31406') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, SUBSTRING(CT2_ITEMD,1,5) AS CT2_ITEMD, SUBSTRING(CT2_ITEMC,1,5) AS CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2010 WHERE D_E_L_E_T_ = ''  " + Enter
		ELSE
			CSQL += " FROM (SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31404') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, SUBSTRING(CT2_ITEMD,1,5) AS CT2_ITEMD, SUBSTRING(CT2_ITEMC,1,5) AS CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2010 WHERE D_E_L_E_T_ = ''  " + Enter
		ENDIF
		CSQL += "       UNION ALL  " + Enter
		IF DTOS(dDatabase) >= '20130701'
			CSQL += "       SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31406') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, SUBSTRING(CT2_ITEMD,1,5) AS CT2_ITEMD, SUBSTRING(CT2_ITEMC,1,5) AS CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2050 WHERE D_E_L_E_T_ = '') " + Enter
		ELSE
			CSQL += "       SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31404') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, SUBSTRING(CT2_ITEMD,1,5) AS CT2_ITEMD, SUBSTRING(CT2_ITEMC,1,5) AS CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2050 WHERE D_E_L_E_T_ = '') " + Enter
		ENDIF
		CSQL += " AS CT2 " + Enter
		CSQL += "WHERE CT2_FILIAL = '"+xFilial("CT2")+"' " + Enter
		CSQL += "AND   CT2_DATA   BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
		IF DTOS(dDatabase) >= '20130701'
			CSQL += "AND   (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31406' OR SUBSTRING(CT2_CREDIT,1,5) = '31401' OR SUBSTRING(CT2_CREDIT,1,5) = '31406') " + Enter
		ELSE
			CSQL += "AND   (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31404' OR SUBSTRING(CT2_CREDIT,1,5) = '31401' OR SUBSTRING(CT2_CREDIT,1,5) = '31404') " + Enter
		ENDIF
		CSQL += "AND    SUBSTRING(CT2_DEBITO,1,7) <> '31401017' AND SUBSTRING(CT2_CREDIT,1,7) <> '31401017' " + Enter
		CSQL += "AND   (SUBSTRING(CT2_ITEMD,1,1)  = 'I'     OR SUBSTRING(CT2_ITEMC,1,1)  = 'I') " + Enter
		CSQL += "AND   CT2_ITEMD <> 'I9999' AND CT2_ITEMC <> 'I9999' " + Enter	
		CSQL += "AND   SUBSTRING(CT2_ITEMD,1,3) <> 'I03' AND SUBSTRING(CT2_ITEMC,1,3) <> 'I03' " + Enter					
		CSQL += "AND   (CT2_CLVLDB   IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" OR CT2_CLVLCR IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" )"+ Enter
		CSQL += "AND   (CT2_ITEMD   =  '"+_CTR->CTD_ITEM+"'     OR CT2_ITEMC =  '"+_CTR->CTD_ITEM+"') " + Enter
		CSQL += "AND   CT2_ROTINA = 'CTBA102' " + Enter
		
		IF CHKFILE("_CTB")
			DBSELECTAREA("_CTB")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_CTB" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_CTB")
		While !Eof()
			
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'LANÇAMENTOS CONTÁBEIS:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF

			IF SUBSTRING(_CTB->CT2_DEBITO,1,3) = '314'
			   cItemCTB := SUBSTRING(_CTB->CT2_ITEMD,1,5)
			   cClvlCTB := ALLTRIM(_CTB->CT2_CLVLDB)
			ELSE
			   cItemCTB := SUBSTRING(_CTB->CT2_ITEMC,1,5)			
   			   cClvlCTB := ALLTRIM(_CTB->CT2_CLVLCR)
			ENDIF
			
			fr_Quebra := +;
			Padr(cItemCTB+'-'+_CTB->CT2_LOTE+'-'+_CTB->CT2_SBLOTE+'-'+_CTB->CT2_DOC+'-'+_CTB->CT2_LINHA                    ,25)+" "+;
			Padr(STOD(_CTB->CT2_DATA)		    						                        																			  		     ,08)+" "+;
			Padr(cClvlCTB                                 									                           									  		   ,04)+SPACE(5)+;
			Padr(_CTB->CT2_HIST   					  					                                                							  			   ,35)+SPACE(5)+;
			Padr(SPACE(40)      									                                                        						  			   ,40)+SPACE(5)+;
			Padr(SPACE(50)														                          											 		  					 		       ,50)+SPACE(5)+;
			Padl(Transform(_CTB->CT2_VALOR, "@E 999,999,999.99")  											                                			   ,14)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			//Grava dados para planilha em excel
			cTipo = '6' //Lançamentos Contábeis
			aAdd(aDados2, { cItemCTB+'-'+_CTB->CT2_LOTE+'-'+_CTB->CT2_SBLOTE+'-'+_CTB->CT2_DOC+'-'+_CTB->CT2_LINHA,;
			STOD(_CTB->CT2_DATA),;
			cClvlCTB,;
			_CTB->CT2_HIST,;
			SPACE(40),;
			SPACE(50),;
			Transform(_CTB->CT2_VALOR, "@E 999,999,999.99"),;
			cTipo })
			
			//Gravação das Despesas de Marketing ou Autorizações de Investimentos
			IF MV_PAR13 == 1 .AND. alltrim(upper(cUserName)) $ 'WANISAY_RANISSES'
				DbSelectArea("SZO")
				RecLock("SZO",.T.)
				SZO->ZO_FILIAL  := xFilial("SZO")
				SZO->ZO_DATA    := STOD(_CTB->CT2_DATA)
				SZO->ZO_CLIENTE := '999999'
				SZO->ZO_LOJA    := '01'
				SZO->ZO_VALOR   := _CTB->CT2_VALOR
				SZO->ZO_DESCR   := "LANC.CONT: "+cItemCTB+'-'+_CTB->CT2_LOTE+'-'+_CTB->CT2_SBLOTE+'-'+_CTB->CT2_DOC+'-'+_CTB->CT2_LINHA
				SZO->ZO_STATUS  := 'Baixa Total'
				SZO->ZO_SI      := '999999'
				SZO->ZO_ITEMCTA := cItemCTB
				SZO->ZO_FPAGTO  := '3'
				IF cEmpAnt == '01'
					SZO->ZO_SERIE := 'S1'
					SZO->ZO_REPRE := '999999'
					SZO->ZO_EMP   := '0101'
				ELSE
					IF ALLTRIM(cClvlCTB) $ '2003_2200_2215'
						SZO->ZO_SERIE := 'S2'
						SZO->ZO_EMP   := '0501'
						SZO->ZO_REPRE := '000258'
					ELSE
						SZO->ZO_SERIE := 'S3'
						SZO->ZO_EMP   := '0599'
						SZO->ZO_REPRE := '000258'
					ENDIF
				ENDIF
				MsUnLock()
			ENDIF
			
			DbSelectArea("_CTB")
			DbSkip()
		END
		_CTB->(dbCloseArea())
				
		//Lista os valores das promotoras nas tabelas de RH de forma analítica
		//Verba 792 somar quando acabar a desoneração
		//Verbas (731 + 732 + 781 + 782 + 792 + 876 + 877 + 730 + 718) + Visa Vale
		//Mais 1/12 avos de férias + 33,33 % sobre 1/12 avos de férias (existe uma tabela de provisão) + 1/12 avos de 13º (existe uma tabela de provisão)
		//Mais INSS provisão de férias e 13° (existe uma tabela de provisão) + FGTS provisão de férias e 13º (existe uma tabela de provisão)
		CSQL := "SELECT *  " + Enter
		CSQL += "FROM (SELECT Z31_CODFUN, Z31_NOMFUN, Z31_ITEMCB, Z31_CODIGO, Z31_SEQ, Z31_CLVL, Z31_CODEMP, Z31_CODCLI, Z31_LOJCLI, Z31_NOMCLI, Z31_RATEIO, Z31_DTINIC, Z31_DTFIM  " + Enter
		CSQL += "      FROM Z31010  " + Enter
		CSQL += "      WHERE D_E_L_E_T_  = ''                                  AND " + Enter
		CSQL += "            Z31_DTINIC <= '"+dtos(MV_PAR02)+"'                AND " + Enter
		CSQL += "            Z31_DTFIM  >= '"+dtos(MV_PAR02)+"'                AND " + Enter  
		CSQL += "            Z31_CLVL   IN "+FormatIN(ALLTRIM(MV_PAR12),",")+" AND "+ Enter		
		CSQL += "            Z31_ITEMCB = '"+_CTR->CTD_ITEM+"'    ) " + Enter  				
		CSQL += "      AS Z31, " + Enter
		CSQL += "(SELECT RD_MAT  AS RD_MAT, SUM(RD_VALOR) AS RD_VALOR FROM ( " + Enter
		CSQL += " SELECT RD_MAT, RD_VALOR " + Enter
		CSQL += " FROM SRD010 SRD, SRA010 SRA " + Enter
		CSQL += " WHERE RA_MAT = RD_MAT " + Enter
		CSQL += "   AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
		CSQL += "   AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847') " + Enter
		CSQL += "   AND RD_DATARQ = SUBSTRING('"+dtos(MV_PAR02)+"',1,6) " + Enter     
		CSQL += "   AND SRA.D_E_L_E_T_ = ' ' " + Enter
		CSQL += "   AND SRD.D_E_L_E_T_ = ' ' " + Enter
		CSQL += " UNION ALL " + Enter
		CSQL += " SELECT RD_MAT, RD_VALOR " + Enter
		CSQL += " FROM SRD050 SRD, SRA050 SRA " + Enter
		CSQL += " WHERE RA_MAT = RD_MAT " + Enter
		CSQL += "   AND RA_CODFUNC IN ('341','342','343','6900','6901','6902','6903','6663','6944','7045') " + Enter
		CSQL += "   AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847') " + Enter
		CSQL += "   AND RD_DATARQ = SUBSTRING('"+dtos(MV_PAR02)+"',1,6) " + Enter
		CSQL += "   AND SRA.D_E_L_E_T_ = ' ' " + Enter
		CSQL += "   AND SRD.D_E_L_E_T_ = ' ') AS WWW " + Enter
		CSQL += "GROUP BY RD_MAT ) AS YYY " + Enter
		CSQL += "WHERE RD_MAT = Z31_CODFUN  " + Enter
		CSQL += "ORDER BY RD_MAT " + Enter
		
		IF CHKFILE("_RH1")
			DBSELECTAREA("_RH1")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_RH1" NEW
		lPrimeiro := .T.
		
		DbSelectArea("_RH1")
		While !Eof()
			
			IF lPrimeiro
				nRow1 += 040
				oPrint:Say  (nRow1 ,0010 ,'FOLHA DE PAGAMENTO:',ofont7)
				nRow1 += 040
				lPrimeiro := .F.
			ENDIF

			IF _RH1->Z31_CODFUN == '001880'
			   lww := .T.
			ENDIF
			
//--------------------------------------------------------------------------------			

        	IF SUBSTRING(DTOS(MV_PAR01),1,6) >= '201612'
        
        		CSQL := " SELECT SUM(RT_VALOR) AS RT_VALOR FROM (  " + Enter
        
        		CSQL += " SELECT (RT_VALOR2 - RT_VALOR1) AS RT_VALOR FROM " + Enter

        		CSQL += " (SELECT SUM(RT_VALOR) AS RT_VALOR1 " + Enter
        		CSQL += "  FROM SRT010 SRT, SRV010 SRV, SRA010 SRA  " + Enter 
        		CSQL += "  WHERE RT_VERBA = RV_COD " + Enter
        		CSQL += "  AND RT_MAT = RA_MAT " + Enter 
        		CSQL += "  AND RT_MAT = '"+_RH1->Z31_CODFUN+"' " + Enter        	
        		CSQL += "  AND RT_DATACAL = '"+dtos(MV_PAR01-1)+"' " + Enter
        		CSQL += "  AND RT_TIPPROV IN ('2','3') " + Enter
        		CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
        		IF SUBSTRING(DTOS(MV_PAR01),5,2) <> '12'
        			CSQL += "  AND RT_VERBA IN ('800','802','803','804','830','833','834') " + Enter
        		ELSE
        			CSQL += "  AND RT_VERBA IN ('800','802','803','804') " + Enter
        		ENDIF
        		CSQL += "  AND SRT.D_E_L_E_T_ = '' " + Enter
        		CSQL += "  AND SRV.D_E_L_E_T_ = '' " + Enter
        		CSQL += "  AND SRA.D_E_L_E_T_ = '' " + Enter
        		CSQL += "  GROUP BY RT_DATACAL) AS TAB1,  " + Enter
        		
        		CSQL += " (SELECT SUM(RT_VALOR) AS RT_VALOR2 " + Enter
        		CSQL += "  FROM SRT010 SRT, SRV010 SRV, SRA010 SRA   " + Enter
        		CSQL += "  WHERE RT_VERBA = RV_COD " + Enter
        		CSQL += "  AND RT_MAT = RA_MAT " + Enter        	
        		CSQL += "  AND RT_MAT = '"+_RH1->Z31_CODFUN+"' " + Enter        	
        		CSQL += "  AND RT_DATACAL = '"+dtos(MV_PAR02)+"' " + Enter
        		CSQL += "  AND RT_TIPPROV IN ('2','3') " + Enter
        		CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter        	
        		IF SUBSTRING(DTOS(MV_PAR01),5,2) <> '12'
        			CSQL += "  AND RT_VERBA IN ('800','802','803','804','830','833','834') " + Enter
        		ELSE
        			CSQL += "  AND RT_VERBA IN ('800','802','803','804') " + Enter
        		ENDIF
        		CSQL += "  AND SRT.D_E_L_E_T_ = '' " + Enter
        		CSQL += "  AND SRV.D_E_L_E_T_ = '' " + Enter
        		CSQL += "  AND SRA.D_E_L_E_T_ = '' " + Enter        	
        		CSQL += "  GROUP BY RT_DATACAL) AS TAB2 " + Enter
        		
        		CSQL += "  UNION ALL " + Enter
        		
        		CSQL += " SELECT (RT_VALOR2 - RT_VALOR1) AS RT_VALOR FROM
        		
        		CSQL += " (SELECT SUM(RT_VALOR) AS RT_VALOR1 " + Enter
        		CSQL += "  FROM SRT050 SRT, SRV010 SRV, SRA050 SRA  " + Enter 
        		CSQL += "  WHERE RT_VERBA = RV_COD " + Enter
        		CSQL += "  AND RT_MAT = RA_MAT " + Enter        	
        		CSQL += "  AND RT_MAT = '"+_RH1->Z31_CODFUN+"' " + Enter        	
        		CSQL += "  AND RT_DATACAL = '"+dtos(MV_PAR01-1)+"' " + Enter
        		CSQL += "  AND RT_TIPPROV IN ('2','3') " + Enter
        		CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
        		IF SUBSTRING(DTOS(MV_PAR01),5,2) <> '12'
        			CSQL += "  AND RT_VERBA IN ('800','802','803','804','830','833','834') " + Enter
        		ELSE
        			CSQL += "  AND RT_VERBA IN ('800','802','803','804') " + Enter
        		ENDIF
        		CSQL += "  AND SRT.D_E_L_E_T_ = '' " + Enter
        		CSQL += "  AND SRV.D_E_L_E_T_ = '' " + Enter
        		CSQL += "  AND SRA.D_E_L_E_T_ = '' " + Enter        	
        		CSQL += "  GROUP BY RT_DATACAL) AS TAB3,  " + Enter

        		CSQL += " (SELECT SUM(RT_VALOR) AS RT_VALOR2 " + Enter
        		CSQL += "  FROM SRT050 SRT, SRV010 SRV, SRA050 SRA   " + Enter
        		CSQL += "  WHERE RT_VERBA = RV_COD " + Enter
        		CSQL += "  AND RT_MAT = RA_MAT " + Enter        	
        		CSQL += "  AND RT_MAT = '"+_RH1->Z31_CODFUN+"' " + Enter        	
        		CSQL += "  AND RT_DATACAL = '"+dtos(MV_PAR02)+"' " + Enter
        		CSQL += "  AND RT_TIPPROV IN ('2','3') " + Enter
        		CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter	        	
        		IF SUBSTRING(DTOS(MV_PAR01),5,2) <> '12'
        			CSQL += "  AND RT_VERBA IN ('800','802','803','804','830','833','834') " + Enter
        		ELSE
        			CSQL += "  AND RT_VERBA IN ('800','802','803','804') " + Enter
        		ENDIF
        		CSQL += "  AND SRT.D_E_L_E_T_ = '' " + Enter
        		CSQL += "  AND SRV.D_E_L_E_T_ = '' " + Enter
        		CSQL += "  AND SRA.D_E_L_E_T_ = '' " + Enter        	
        		CSQL += "  GROUP BY RT_DATACAL) AS TAB4) AS TAB5 " + Enter
        		
        	ELSE 
			
        		//Utilizo a verba 800 no início da Query para buscar o número de avos e data base para cálculo da provisão mensal na query abaixo.
        		//Sempre ficar atento quando o campo RT_AVOS13S estiver igual a zero (Mês de dezembro, por exemplo para 13º)
        		//RT_TIPPROV = 1=Fer.Venc.;2=Fer.Prop.;3=13o.Sal.;4=14o.Sal.;5=Mes Ferias;6=Mes 13o
        		CSQL := "SELECT SUM(RT_VALOR/RT_AVOS13S1) AS RT_TOTAL1 FROM ( " + Enter
        		
        		CSQL += "	SELECT RT_MAT, RT_CC, RT_VALOR, RT_VERBA, RT_DATACAL, RT_DATABAS, RT_AVOS13S, RT_TIPPROV, 	" + Enter
        		CSQL += "		(SELECT CASE 																			" + Enter
        		CSQL += "					WHEN RT_AVOS13S = 0 AND DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 <> 0 THEN DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 	" + Enter
        		CSQL += "					WHEN RT_AVOS13S = 0 AND DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 =  0 THEN 1											" + Enter
        		CSQL += "					ELSE RT_AVOS13S END AS RT_AVOS13S FROM SRT010 XRT, SRA010 XRA														" + Enter
        		CSQL += "		WHERE RA_MAT = RT_MAT 					" + Enter
        		CSQL += "		AND SRA.RA_MAT = XRA.RA_MAT 			" + Enter
        		CSQL += "		AND RT_DATACAL = '"+dtos(MV_PAR02)+"' 	" + Enter
        		CSQL += "       AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
        		CSQL += "		AND RT_VERBA       = '800' 				" + Enter
        		CSQL += "		AND RT_DATABAS <> ''         			" + Enter
        		CSQL += "		AND RT_MAT         = '"+_RH1->Z31_CODFUN+"' " + Enter
        		CSQL += "		AND XRT.D_E_L_E_T_ = '' 				" + Enter
        		CSQL += "		AND XRA.D_E_L_E_T_ = '') AS RT_AVOS13S1 " + Enter
        		
        		CSQL += "FROM SRT010 SRT, SRA010 SRA " + Enter
        		CSQL += "WHERE RA_MAT = RT_MAT " + Enter
        		CSQL += "AND RT_VERBA NOT IN ('801','831','862','863','864','865','866') " + Enter
        		CSQL += "AND RT_DATACAL = '"+dtos(MV_PAR02)+"' " + Enter
        		CSQL += "AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
        		CSQL += "AND RT_MAT     = '"+_RH1->Z31_CODFUN+"' " + Enter
        		CSQL += "AND RT_TIPPROV IN ('2','3') " + Enter
        		CSQL += "AND SRT.D_E_L_E_T_ = '' " + Enter
        		CSQL += "AND SRA.D_E_L_E_T_ = ''        
        		
        		CSQL += " UNION ALL " + Enter    			
        		
        		CSQL += "	SELECT RT_MAT, RT_CC, RT_VALOR, RT_VERBA, RT_DATACAL, RT_DATABAS, RT_AVOS13S, RT_TIPPROV, " + Enter
        		CSQL += "		(SELECT CASE 																			" + Enter
        		CSQL += "					WHEN RT_AVOS13S = 0 AND DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 <> 0 THEN DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 	" + Enter
        		CSQL += "					WHEN RT_AVOS13S = 0 AND DATEDIFF(D, RT_DATABAS, RT_DATACAL)/30 =  0 THEN 1											" + Enter
        		CSQL += "					ELSE RT_AVOS13S END AS RT_AVOS13S FROM SRT050 XRT, SRA050 XRA														" + Enter
        		CSQL += "		WHERE RA_MAT = RT_MAT " + Enter
        		CSQL += "		AND SRA.RA_MAT = XRA.RA_MAT " + Enter
        		CSQL += "		AND RT_DATACAL = '"+dtos(MV_PAR02)+"' " + Enter
        		CSQL += "		AND RA_CODFUNC IN ('341','342','343','6900','6901','6902','6903','6663','6944','7045') " + Enter
        		CSQL += "		AND RT_VERBA       = '800' " + Enter
        		CSQL += "		AND RT_DATABAS <> ''         			" + Enter
        		CSQL += "		AND RT_MAT         = '"+_RH1->Z31_CODFUN+"' " + Enter
        		CSQL += "		AND XRT.D_E_L_E_T_ = '' " + Enter
        		CSQL += "		AND XRA.D_E_L_E_T_ = '') AS RT_AVOS13S1 " + Enter
        		CSQL += "FROM SRT050 SRT, SRA050 SRA " + Enter
        		CSQL += "WHERE RA_MAT = RT_MAT " + Enter
        		CSQL += "AND RT_VERBA NOT IN ('801','831','862','863','864','865','866') " + Enter
        		CSQL += "AND RT_DATACAL = '"+dtos(MV_PAR02)+"' " + Enter
        		CSQL += "AND RA_CODFUNC IN ('341','342','343','6900','6901','6902','6903','6663','6944','7045')" + Enter
        		CSQL += "AND RT_MAT     = '"+_RH1->Z31_CODFUN+"' " + Enter
        		CSQL += "AND RT_TIPPROV IN ('2','3') " + Enter
        		CSQL += "AND SRT.D_E_L_E_T_ = '' " + Enter
        		CSQL += "AND SRA.D_E_L_E_T_ = '' ) AS WWW " + Enter
        		
        		IF CHKFILE("_RH2")
        			DBSELECTAREA("_RH2")
        			DBCLOSEAREA()
        		ENDIF
        		TCQUERY CSQL ALIAS "_RH2" NEW
			
        		//Somar os valores das verbas 801 e 831
        		//RT_TIPPROV = 1=Fer.Venc.;2=Fer.Prop.;3=13o.Sal.;4=14o.Sal.;5=Mes Ferias;6=Mes 13o
        		CSQL := "SELECT SUM(RT_VALOR1) AS RT_VALOR FROM ( " + Enter
        		CSQL += "SELECT RT_MAT, SUM(RT_VALOR) AS RT_VALOR1 " + Enter
        		CSQL += "FROM SRT010 SRT, SRA010 SRA " + Enter
        		CSQL += "WHERE RA_MAT = RT_MAT " + Enter
        		CSQL += "AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
        		CSQL += "AND RT_VERBA   IN ('801','831') " + Enter
        		CSQL += "AND RT_DATACAL  = '"+dtos(MV_PAR02)+"' " + Enter
        		CSQL += "AND RT_TIPPROV IN ('2','3') " + Enter
        		CSQL += "AND RT_MAT         = '"+_RH1->Z31_CODFUN+"' " + Enter
        		CSQL += "AND SRT.D_E_L_E_T_ = '' " + Enter
        		CSQL += "AND SRA.D_E_L_E_T_ = '' " + Enter
        		CSQL += "GROUP BY RT_MAT " + Enter
        		CSQL += " UNION ALL " + Enter    
        		CSQL += "SELECT RT_MAT, SUM(RT_VALOR) AS RT_VALOR1 " + Enter
        		CSQL += "FROM SRT050 SRT, SRA050 SRA " + Enter
        		CSQL += "WHERE RA_MAT = RT_MAT " + Enter
        		CSQL += "AND RA_CODFUNC IN ('341','342','343','6900','6901','6902','6903','6663','6944','7045') " + Enter
        		CSQL += "AND RT_VERBA   IN ('801','831') " + Enter
        		CSQL += "AND RT_DATACAL  = '"+dtos(MV_PAR02)+"' " + Enter
        		CSQL += "AND RT_TIPPROV IN ('2','3') " + Enter           
        		CSQL += "AND RT_MAT         = '"+_RH1->Z31_CODFUN+"' " + Enter
        		CSQL += "AND SRT.D_E_L_E_T_ = '' " + Enter
        		CSQL += "AND SRA.D_E_L_E_T_ = '' " + Enter
        		CSQL += "GROUP BY RT_MAT ) AS WWW " + Enter
        		
        	ENDIF
		
			IF CHKFILE("_RH3")
				DBSELECTAREA("_RH3")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_RH3" NEW
							
//--------------------------------------------------------------------------------
			
			//Calcula valor da licença maternidade para promotoras.
			CSQL := "SELECT SUM(RD_VALOR1) AS RD_VALOR FROM ( " + Enter
			CSQL += "SELECT SUM(RD_VALOR) AS RD_VALOR1 " + Enter
			CSQL += "FROM SRD010 SRD, SRA010 SRA " + Enter
			CSQL += "WHERE RA_MAT = RD_MAT " + Enter
			CSQL += "  AND RA_MAT = '"+_RH1->Z31_CODFUN+"' " + Enter
			CSQL += "  AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6944','7045') " + Enter
			CSQL += "  AND RD_PD IN ('131','174')   " + Enter
			CSQL += "  AND RD_DATARQ = SUBSTRING('"+dtos(MV_PAR01)+"',1,6) " + Enter
			CSQL += "  AND SRA.D_E_L_E_T_ = ' ' " + Enter
			CSQL += "  AND SRD.D_E_L_E_T_ = ' ' " + Enter
			CSQL += " UNION ALL " + Enter
			CSQL += "SELECT SUM(RD_VALOR) AS RD_VALOR1 " + Enter
			CSQL += "FROM SRD050 SRD, SRA050 SRA " + Enter
			CSQL += "WHERE RA_MAT = RD_MAT " + Enter
			CSQL += "  AND RA_MAT = '"+_RH1->Z31_CODFUN+"' " + Enter		
			CSQL += "  AND RA_CODFUNC IN ('341','342','343','6900','6901','6902','6903','6663','6046','6486','6944','7045') " + Enter
			CSQL += "  AND RD_PD IN ('131','174')   " + Enter
			CSQL += "  AND RD_DATARQ = SUBSTRING('"+dtos(MV_PAR01)+"',1,6) " + Enter
			CSQL += "  AND SRA.D_E_L_E_T_ = ' ' " + Enter
			CSQL += "  AND SRD.D_E_L_E_T_ = ' ' ) AS WWW" + Enter
		
			IF CHKFILE("_RH4")
				DBSELECTAREA("_RH4")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_RH4" NEW
            
			//Calculo do valor do Visa Vale de Promotoras Afastadas.
		
			//Contar o nº de dias que a promotora trabalhou antes do afastamento - período inicial
			CSQL := "SELECT SUM(DIAS) AS DIAS FROM (  " + Enter
			CSQL += "   SELECT SUM(DIAS_INI) AS DIAS FROM (  " + Enter 
			CSQL += "   SELECT RA_MAT, MAX(DATEDIFF(D,'"+dtos(MV_PAR01)+"',R8_DATAINI)) AS DIAS_INI, MAX(DATEDIFF(D,R8_DATAFIM,'"+dtos(MV_PAR02)+"'))AS DIAS_FIM  " + Enter
			CSQL += "   FROM SRD010 SRD, SRA010 SRA, SR8010 SR8  " + Enter 
			CSQL += "   WHERE RA_MAT = RD_MAT  " + Enter
			CSQL += "   AND RA_MAT = R8_MAT  " + Enter
			CSQL += "   AND RA_MAT = '"+_RH1->Z31_CODFUN+"' " + Enter
			CSQL += "   AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045')  " + Enter 
			CSQL += "   AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')  " + Enter  				
			CSQL += "   AND RD_DATARQ = SUBSTRING('201611',1,6)  " + Enter
			CSQL += "   AND SUBSTRING(RA_ADMISSA,1,6) < SUBSTRING('"+dtos(MV_PAR01)+"',1,6)  " + Enter 
			CSQL += "   AND (SUBSTRING(R8_DATAINI,1,6) = SUBSTRING('"+dtos(MV_PAR01)+"',1,6))  " + Enter
			CSQL += "   AND R8_TIPO <> 'F'  " + Enter
			CSQL += "   AND R8_TIPOAFA <> '001'  " + Enter
			CSQL += "   AND SRA.D_E_L_E_T_ = ' '  " + Enter
			CSQL += "   AND SRD.D_E_L_E_T_ = ' '  " + Enter
			CSQL += "   GROUP BY RA_MAT ) AS WWW  " + Enter
			CSQL += "   WHERE DIAS_INI > 0  " + Enter
		
			CSQL += "    UNION ALL  " + Enter

			//Contar o nº de dias que a promotora trabalhou após o afastamento - período final
			CSQL += "   SELECT SUM(DIAS_FIM) AS DIAS FROM (  " + Enter 
			CSQL += "   SELECT RA_MAT, MAX(DATEDIFF(D,'"+dtos(MV_PAR01)+"',R8_DATAINI)) AS DIAS_INI, MAX(DATEDIFF(D,R8_DATAFIM,'"+dtos(MV_PAR02)+"'))AS DIAS_FIM  " + Enter
			CSQL += "   FROM SRD010 SRD, SRA010 SRA, SR8010 SR8  " + Enter
			CSQL += "   WHERE RA_MAT = RD_MAT  " + Enter
			CSQL += "   AND RA_MAT = R8_MAT  " + Enter
			CSQL += "   AND RA_MAT = '"+_RH1->Z31_CODFUN+"' " + Enter		
			CSQL += "   AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045')  " + Enter 
			CSQL += "   AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')  " + Enter  				
			CSQL += "   AND RD_DATARQ = SUBSTRING('201611',1,6)  " + Enter
			CSQL += "   AND SUBSTRING(RA_ADMISSA,1,6) < SUBSTRING('"+dtos(MV_PAR01)+"',1,6)  " + Enter 
			CSQL += "   AND (SUBSTRING(R8_DATAFIM,1,6) = SUBSTRING('"+dtos(MV_PAR02)+"',1,6))  " + Enter
			CSQL += "   AND R8_TIPO <> 'F'  " + Enter
			CSQL += "   AND R8_TIPOAFA <> '001'  " + Enter
			CSQL += "   AND SRA.D_E_L_E_T_ = ' '  " + Enter
			CSQL += "   AND SRD.D_E_L_E_T_ = ' '  " + Enter
			CSQL += "   GROUP BY RA_MAT ) AS WWW  " + Enter
			CSQL += "   WHERE DIAS_FIM <= 31  " + Enter
			
			CSQL += "    UNION ALL  " + Enter
			
			//Contar o nº de dias que a promotora trabalhou antes do afastamento - período inicial
			CSQL += " 	SELECT SUM(DIAS_INI) AS DIAS FROM (  " + Enter 
			CSQL += "   SELECT RA_MAT, MAX(DATEDIFF(D,'"+dtos(MV_PAR01)+"',R8_DATAINI)) AS DIAS_INI, MAX(DATEDIFF(D,R8_DATAFIM,'"+dtos(MV_PAR02)+"'))AS DIAS_FIM  " + Enter
			CSQL += "   FROM SRD050 SRD, SRA050 SRA, SR8050 SR8  " + Enter 
			CSQL += "   WHERE RA_MAT = RD_MAT  " + Enter
			CSQL += "   AND RA_MAT = R8_MAT  " + Enter
			CSQL += "   AND RA_MAT = '"+_RH1->Z31_CODFUN+"' " + Enter		
			CSQL += "   AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045')  " + Enter 
			CSQL += "   AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')  " + Enter  				
			CSQL += "   AND RD_DATARQ = SUBSTRING('201611',1,6)  " + Enter
			CSQL += "   AND SUBSTRING(RA_ADMISSA,1,6)  < SUBSTRING('"+dtos(MV_PAR01)+"',1,6)  " + Enter 
			CSQL += "   AND (SUBSTRING(R8_DATAINI,1,6) = SUBSTRING('"+dtos(MV_PAR01)+"',1,6))  " + Enter
			CSQL += "   AND R8_TIPO <> 'F'  " + Enter
			CSQL += "   AND R8_TIPOAFA <> '001'  " + Enter
			CSQL += "   AND SRA.D_E_L_E_T_ = ' '  " + Enter
			CSQL += "   AND SRD.D_E_L_E_T_ = ' '  " + Enter
			CSQL += "   GROUP BY RA_MAT ) AS WWW  " + Enter
			CSQL += "   WHERE DIAS_INI > 0  " + Enter
			
			CSQL += "    UNION ALL  " + Enter
			
			//Contar o nº de dias que a promotora trabalhou após o afastamento - período final
			CSQL += "   SELECT SUM(DIAS_FIM) AS DIAS FROM (  " + Enter 
			CSQL += "   SELECT RA_MAT, MAX(DATEDIFF(D,'"+dtos(MV_PAR01)+"',R8_DATAINI)) AS DIAS_INI, MAX(DATEDIFF(D,R8_DATAFIM,'"+dtos(MV_PAR02)+"'))AS DIAS_FIM  " + Enter
			CSQL += "   FROM SRD050 SRD, SRA050 SRA, SR8050 SR8  " + Enter
			CSQL += "   WHERE RA_MAT = RD_MAT  " + Enter
			CSQL += "   AND RA_MAT = R8_MAT  " + Enter
			CSQL += "   AND RA_MAT = '"+_RH1->Z31_CODFUN+"' " + Enter		
			CSQL += "   AND RA_CODFUNC IN ('0291','0690','0691','0692','0753','0772','0698','0812','6900','6901','6902','6903','6663','6046','6486','6944','7045')  " + Enter 
			CSQL += "   AND RD_PD IN ('721','722','723','742','780','730','732','781','782','876','877','744','847')  " + Enter  				
			CSQL += "   AND RD_DATARQ = SUBSTRING('201611',1,6)  " + Enter
			CSQL += "   AND SUBSTRING(RA_ADMISSA,1,6)  < SUBSTRING('"+dtos(MV_PAR01)+"',1,6)  " + Enter 
			CSQL += "   AND (SUBSTRING(R8_DATAFIM,1,6) = SUBSTRING('"+dtos(MV_PAR02)+"',1,6))  " + Enter
			CSQL += "   AND R8_TIPO <> 'F'  " + Enter
			CSQL += "   AND R8_TIPOAFA <> '001'  " + Enter
			CSQL += "   AND SRA.D_E_L_E_T_ = ' '  " + Enter
			CSQL += "   AND SRD.D_E_L_E_T_ = ' '  " + Enter
			CSQL += "   GROUP BY RA_MAT ) AS WWW  " + Enter
			CSQL += "   WHERE DIAS_FIM <= 31  " + Enter
			
			CSQL += "   ) AS YYY  " + Enter
							
			IF CHKFILE("_RH5")
				DBSELECTAREA("_RH5")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_RH5" NEW
		
			CSQL := " SELECT COUNT(*) AS CONTADOR  " + Enter
			CSQL += " FROM SR8010  " + Enter
			CSQL += " WHERE R8_MAT = '"+_RH1->Z31_CODFUN+"'  " + Enter
			CSQL += " AND R8_DATAFIM = ''  " + Enter
			
			IF CHKFILE("_RH6")
				DBSELECTAREA("_RH6")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_RH6" NEW
		
			// O Valor nValor_Alim somado abaixo é referente ao Visa Vale.
			IF SUBSTRING(DTOS(MV_PAR01),1,6) >= '201612'						
				DbSelectArea("SRA")
				DbSetOrder(1)
				DbSeek(xFilial("SRA")+_RH1->Z31_CODFUN)
				IF SUBSTRING(DTOS(SRA->RA_ADMISSA),1,6) < SUBSTRING(DTOS(MV_PAR01),1,6)
					DO CASE 
						CASE _RH5->DIAS > 0		
							nValor := ((_RH1->RD_VALOR + _RH3->RT_VALOR - _RH4->RD_VALOR + (_RH5->DIAS * nValor_Alim/30)) *_RH1->Z31_RATEIO/100)
						CASE _RH6->CONTADOR > 0  
							nValor := ((_RH1->RD_VALOR + _RH3->RT_VALOR - _RH4->RD_VALOR) *_RH1->Z31_RATEIO/100)
						OTHERWISE 
							nValor := ((_RH1->RD_VALOR + _RH3->RT_VALOR - _RH4->RD_VALOR + nValor_Alim) *_RH1->Z31_RATEIO/100)
					ENDCASE        
				ELSE
					nValor := ((_RH1->RD_VALOR + _RH3->RT_VALOR - _RH4->RD_VALOR) *_RH1->Z31_RATEIO/100)			
				ENDIF
			ELSE
				DbSelectArea("SRA")
				DbSetOrder(1)
				DbSeek(xFilial("SRA")+_RH1->Z31_CODFUN)
				IF SUBSTRING(DTOS(SRA->RA_ADMISSA),1,6) < SUBSTRING(DTOS(MV_PAR01),1,6)
					DO CASE 
						CASE _RH5->DIAS > 0		
							nValor := ((_RH1->RD_VALOR + _RH2->RT_TOTAL1 + _RH3->RT_VALOR - _RH4->RD_VALOR + (_RH5->DIAS * nValor_Alim/30)) *_RH1->Z31_RATEIO/100)
						CASE _RH6->CONTADOR > 0  
							nValor := ((_RH1->RD_VALOR + _RH2->RT_TOTAL1 + _RH3->RT_VALOR - _RH4->RD_VALOR) *_RH1->Z31_RATEIO/100)
						OTHERWISE 
							nValor := ((_RH1->RD_VALOR + _RH2->RT_TOTAL1 + _RH3->RT_VALOR - _RH4->RD_VALOR + nValor_Alim) *_RH1->Z31_RATEIO/100)
					ENDCASE        
				ELSE
					nValor := ((_RH1->RD_VALOR + _RH2->RT_TOTAL1 + _RH3->RT_VALOR - _RH4->RD_VALOR) *_RH1->Z31_RATEIO/100)			
				ENDIF
			ENDIF
			
			fr_Quebra := +;
			Padr(SUBSTRING(_RH1->Z31_ITEMCB,1,5)+'-'+_RH1->Z31_CODIGO+'-'+_RH1->Z31_SEQ     														               ,25)+" "+;
			Padr(DTOC(MV_PAR02)		    						                        													  		      		   ,08)+" "+;
			Padr(ALLTRIM(_RH1->Z31_CLVL)                 									                           									  		   ,04)+SPACE(5)+;
			Padr(_RH1->Z31_CODFUN+'-'+SUBSTRING(_RH1->Z31_NOMFUN,1,27)				                                              					  			   ,35)+SPACE(5)+;
			Padr('FOLHA DE PAGAMENTO' + SPACE(22) 					                                                        						  			   ,40)+SPACE(5)+;
			Padr(_RH1->Z31_CODCLI+'-'+_RH1->Z31_LOJCLI+'-'+SUBSTRING(_RH1->Z31_NOMCLI,1,40)               											 		  	   ,50)+SPACE(5)+;
			Padl(Transform(nValor, "@E 999,999,999.99") 							  											              			           ,14)
			
			oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
			nRow1 += 030
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			oPrint:Line (nRow1, 010, nRow1, 3550)
			nRow1 += 020
			
			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf
			
			//Grava dados para planilha em excel
			cTipo = '7' //Folha de Pagamento
			aAdd(aDados2, { SUBSTRING(_RH1->Z31_ITEMCB,1,5)+'-'+_RH1->Z31_CODIGO+'-'+_RH1->Z31_SEQ,;
			DTOC(MV_PAR02),;
			ALLTRIM(_RH1->Z31_CLVL)+'-'+_RH1->Z31_CODEMP,;
			_RH1->Z31_CODFUN+'-'+_RH1->Z31_NOMFUN,;
			'FOLHA DE PAGAMENTO',;
			_RH1->Z31_CODCLI+'-'+_RH1->Z31_LOJCLI+'-'+_RH1->Z31_NOMCLI,;
			Transform(nValor, "@E 999,999,999.99"),;
			cTipo })    
			
			//Grava dados para totalizador por item contábil
			//aAdd(aDados3, { SUBSTRING(_RH1->Z31_ITEMCB,1,5);Transform(nValor, "@E 999,999,999.99") })    			
			
			//Gravação das Despesas de Marketing ou Autorizações de Investimentos
			IF MV_PAR13 == 1 .AND. alltrim(upper(cUserName)) $ 'WANISAY_RANISSES'
				DbSelectArea("SZO")
				RecLock("SZO",.T.)
				SZO->ZO_FILIAL  := xFilial("SZO")
				SZO->ZO_DATA    := MV_PAR02
				SZO->ZO_VALOR   := nValor
				SZO->ZO_DESCR   := "F.PAGTO: "+SUBSTRING(_RH1->Z31_ITEMCB,1,5)+'-'+_RH1->Z31_CODIGO+'-'+_RH1->Z31_SEQ
				SZO->ZO_STATUS  := 'Baixa Total'
				SZO->ZO_SI      := '999999'
				SZO->ZO_ITEMCTA := _RH1->Z31_ITEMCB
				SZO->ZO_CLIENTE := _RH1->Z31_CODCLI
				SZO->ZO_LOJA    := _RH1->Z31_LOJCLI
				SZO->ZO_FPAGTO  := '3' 
				
				CSQL := "SELECT A1_VEND, A1_YVENDI, A1_YVENBE1 " + Enter
				CSQL += "FROM "+RETSQLNAME("SA1")+" SA1 " + Enter
				CSQL += "WHERE A1_COD   = '"+_RH1->Z31_CODCLI+"' " + Enter
				CSQL += "AND   A1_LOJA  = '"+_RH1->Z31_LOJCLI+"' " + Enter
				CSQL += "AND D_E_L_E_T_ = '' " + Enter
				
				IF CHKFILE("_SA1")
					DBSELECTAREA("_SA1")
					DBCLOSEAREA()
				ENDIF
				TCQUERY CSQL ALIAS "_SA1" NEW

				IF cEmpAnt == '01'
					SZO->ZO_SERIE := 'S1'
					SZO->ZO_EMP   := '0101'					
					SZO->ZO_REPRE := _SA1->A1_VEND
				ELSE
					IF ALLTRIM(_RH1->Z31_CLVL) $ '2003_2200_2215'
						SZO->ZO_SERIE := 'S2'
						SZO->ZO_EMP   := '0501'
						SZO->ZO_REPRE := _SA1->A1_YVENDI
					ELSE
						SZO->ZO_SERIE := 'S3'
						SZO->ZO_EMP   := '0599'
						SZO->ZO_REPRE := _SA1->A1_YVENBE1
					ENDIF
				ENDIF
				MsUnLock()
			ENDIF
			
			DbSelectArea("_RH1")
			DbSkip()
		END
		_RH1->(dbCloseArea())
		
		DbSelectArea("_CTR")
		DbSkip()
	END
	_CTR->(dbCloseArea())
	
	//Gera excel
	U_BIAxExcel(aDados2, aCampos, "BIA488"+strzero(seconds()%3500,5) )
	
	fImpCabec()
	
	If nRow1 > 1
		fImpRoda()
		fImpCabec()
	EndIf
ENDIF

//Totaliza os itens contabeis
CSQL := "	SELECT ITEM, SUM(VALOR) AS VALOR FROM ( " + Enter

CSQL += "	SELECT SUBSTRING(D1_ITEMCTA,1,5) AS ITEM, SUM(D1_TOTAL) AS VALOR " + Enter
CSQL += " FROM (SELECT SUBSTRING(D1_ITEMCTA,1,5) AS D1_ITEMCTA, (D1_TOTAL - D1_VALDESC) AS D1_TOTAL, D1_YSI, D1_DTDIGIT, D1_CLVL, D1_CONTA FROM SD1010 WHERE D_E_L_E_T_ = '' " + Enter
CSQL += "       UNION ALL  " + Enter
CSQL += "       SELECT SUBSTRING(D1_ITEMCTA,1,5) AS D1_ITEMCTA, (D1_TOTAL - D1_VALDESC) AS D1_TOTAL, D1_YSI, D1_DTDIGIT, D1_CLVL, D1_CONTA FROM SD1050 WHERE D_E_L_E_T_ = '' " + Enter
CSQL += "       UNION ALL  " + Enter
CSQL += "       SELECT SUBSTRING(D1_ITEMCTA,1,5) AS D1_ITEMCTA, (D1_TOTAL - D1_VALDESC) AS D1_TOTAL, D1_YSI, D1_DTDIGIT, D1_CLVL, D1_CONTA FROM SD1070 WHERE D_E_L_E_T_ = '') " + Enter
CSQL += " AS SD1, "+RETSQLNAME("SA1")+" SA1 " + Enter

CSQL += " WHERE SUBSTRING(D1_ITEMCTA,1,1) = 'I' AND D1_ITEMCTA <> 'I9999' " + Enter
IF DTOS(dDatabase) >= '20130701'
	CSQL += " AND (SUBSTRING(D1_CONTA,1,5) = '31401' OR SUBSTRING(D1_CONTA,1,5) = '31406') " + Enter
ELSE
	CSQL += " AND (SUBSTRING(D1_CONTA,1,5) = '31401' OR SUBSTRING(D1_CONTA,1,5) = '31404') " + Enter
ENDIF
CSQL += " AND SUBSTRING(D1_CONTA,1,7) <> '31401017' " + Enter
CSQL += " AND D1_YSI = A1_COD " + Enter
CSQL += " AND D1_DTDIGIT BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
CSQL += " AND D1_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
CSQL += " AND D1_ITEMCTA BETWEEN  '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + Enter
CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' "  + Enter
CSQL += " AND D1_CLVL          IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
CSQL += " GROUP BY SUBSTRING(D1_ITEMCTA,1,5) " + Enter

CSQL += "UNION ALL " + Enter

//CSQL += "	SELECT SUBSTRING(C5_YITEMCT,1,5) AS ITEM, SUM(CP*D2_QUANT) AS VALOR				" + Enter
CSQL += "	SELECT SUBSTRING(C5_YITEMCT,1,5) AS ITEM, SUM(CPV*D2_QUANT) AS VALOR				" + Enter
CSQL += " FROM (SELECT D2_CUSTO1/D2_QUANT AS CPV, *
//CSQL += " FROM (SELECT *,
////(SELECT dbo.FN_CP(SUBSTRING(D2_YEMP,1,2),D2_COD,D2_EMISSAO,D2_EMISSAO)) AS CP 
//CSQL += " CPV =  CASE WHEN ISNULL((SELECT MAX(B9_DATA) FROM "+RETSQLNAME("SB9")+" WHERE B9_FILIAL = D2_FILIAL AND B9_COD = D2_COD AND B9_LOCAL = D2_LOCAL AND B9_CM1 > 0 AND D_E_L_E_T_=''),'') <> '' " + Enter
//CSQL += " 					THEN " + Enter
//CSQL += " 						(SELECT TOP 1 CUSTO = B9_CM1 FROM "+RETSQLNAME("SB9")+" WHERE B9_FILIAL = D2_FILIAL AND B9_COD = D2_COD AND B9_LOCAL = D2_LOCAL AND B9_CM1 > 0 AND B9_DATA = " + Enter
//CSQL += " 						(SELECT MAX(B9_DATA) FROM "+RETSQLNAME("SB9")+" WHERE B9_FILIAL = D2_FILIAL AND B9_COD = D2_COD AND B9_LOCAL = D2_LOCAL AND B9_CM1 > 0 AND D_E_L_E_T_='')) " + Enter
//CSQL += " 					ELSE " + Enter
//CSQL += " 						0 " + Enter
//CSQL += " 					END " + Enter
    
CSQL += "  FROM VW_SD2) SD2, VW_SC5 SC5, SA1010 SA1 WITH (NOLOCK) " + Enter
CSQL += " WHERE D2_PEDIDO = C5_NUM " + Enter
CSQL += " AND D2_CLIENTE  = C5_CLIENTE " + Enter
CSQL += " AND D2_LOJA     = C5_LOJACLI " + Enter
CSQL += " AND D2_YEMP     = C5_YEMP  " + Enter
CSQL += " AND D2_YEMPORI  = C5_YEMPORI " + Enter
CSQL += " AND C5_YSI      = A1_COD " + Enter
CSQL += " AND D2_DESCON   = 0 " + Enter

CSQL += " AND D2_COD     >= 'A'  " + Enter

CSQL += " AND C5_YCLVL    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
CSQL += " AND SUBSTRING(C5_YITEMCT,1,1) = 'I' " + Enter
//CSQL += " AND (C5_YSUBTP IN ('B','A','M','G','D') OR (C5_YSUBTP = 'O' AND SUBSTRING(D2_COD,1,3) IN ('214','216') )) " + Enter
CSQL += " AND (C5_YSUBTP IN ('B','A','M','G','D','F') OR (C5_YSUBTP = 'O' AND SUBSTRING(D2_COD,1,3) IN ('214','216') )) " + Enter
CSQL += " AND D2_EMISSAO BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
CSQL += " AND D2_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
CSQL += " AND C5_YITEMCT BETWEEN  '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + Enter
CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
CSQL += " GROUP BY SUBSTRING(C5_YITEMCT,1,5) " + Enter

CSQL += " UNION ALL  " + Enter

CSQL += "   SELECT SUBSTRING(C5_YITEMCT,1,5) AS ITEM, ISNULL(SUM(D2_TOTAL+D2_VALIPI),0) AS VALOR" + Enter
CSQL += " FROM VW_SD2 SD2, VW_SC5 SC5, "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) " + Enter
CSQL += " WHERE D2_PEDIDO = C5_NUM " + Enter
CSQL += " AND D2_CLIENTE  = C5_CLIENTE " + Enter
CSQL += " AND D2_LOJA     = C5_LOJACLI " + Enter
CSQL += " AND D2_YEMP     = C5_YEMP  " + Enter
CSQL += " AND D2_YEMPORI  = C5_YEMPORI " + Enter
CSQL += " AND C5_YSI      = A1_COD " + Enter
CSQL += " AND D2_DESCON   = 0 " + Enter

CSQL += " AND D2_COD < 'A' " + Enter

CSQL += " AND C5_YCLVL    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
CSQL += " AND SUBSTRING(C5_YITEMCT,1,1) = 'I' " + Enter
CSQL += " AND (C5_YSUBTP = 'O' AND SUBSTRING(D2_COD,1,3) IN ('214','216') ) " + Enter
CSQL += " AND D2_EMISSAO BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
CSQL += " AND D2_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
CSQL += " AND C5_YITEMCT BETWEEN  '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + Enter
CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
CSQL += " GROUP BY SUBSTRING(C5_YITEMCT,1,5) " + Enter

CSQL += "UNION ALL " + Enter

CSQL += "	SELECT SUBSTRING(C5_YITEMCT,1,5) AS ITEM, ISNULL(SUM(D2_DESCON),0) AS VALOR " + Enter
CSQL += " FROM VW_SD2 SD2, VW_SC5 SC5, "+RETSQLNAME("SA1")+" SA1 " + Enter
CSQL += " WHERE D2_PEDIDO = C5_NUM " + Enter
CSQL += " AND D2_CLIENTE  = C5_CLIENTE " + Enter
CSQL += " AND D2_LOJA     = C5_LOJACLI " + Enter
CSQL += " AND D2_YEMP     = C5_YEMP  " + Enter
CSQL += " AND D2_YEMPORI  = C5_YEMPORI " + Enter
CSQL += " AND C5_YSI      = A1_COD " + Enter
CSQL += " AND D2_DESCON   > 0 " + Enter
CSQL += " AND C5_YCLVL    IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
CSQL += " AND SUBSTRING(C5_YITEMCT,1,1) = 'I' " + Enter
//CSQL += " AND (C5_YSUBTP NOT IN ('B','A','M','G','D') AND (C5_YSUBTP <> 'O' AND SUBSTRING(D2_COD,1,3) NOT IN ('214','216') )) " + Enter
CSQL += " AND (C5_YSUBTP NOT IN ('B','A','M','G','D','F') AND (C5_YSUBTP <> 'O' AND SUBSTRING(D2_COD,1,3) NOT IN ('214','216') )) " + Enter
CSQL += " AND D2_EMISSAO BETWEEN  '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
CSQL += " AND D2_YSI     BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
CSQL += " AND C5_YITEMCT BETWEEN  '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + Enter
CSQL += " AND A1_VEND    BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
CSQL += " AND A1_GRPVEN  BETWEEN  '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
CSQL += " GROUP BY SUBSTRING(C5_YITEMCT,1,5) " + Enter

CSQL += " UNION ALL " + Enter

CSQL += "	SELECT SUBSTRING(D3_ITEMCTA,1,5) AS ITEM, ISNULL(SUM(D3_CUSTO1),0) AS VALOR " + Enter
CSQL += " FROM (SELECT SUBSTRING(D3_ITEMCTA,1,5) AS D3_ITEMCTA, D3_CUSTO1 = CASE WHEN D3_TM < 500 THEN D3_CUSTO1*-1 ELSE D3_CUSTO1 END, D3_YSI, D3_EMISSAO, D3_CLVL FROM SD3010 WHERE D_E_L_E_T_ = '' " + Enter
CSQL += " UNION ALL  " + Enter
CSQL += "       SELECT SUBSTRING(D3_ITEMCTA,1,5) AS D3_ITEMCTA, D3_CUSTO1 = CASE WHEN D3_TM < 500 THEN D3_CUSTO1*-1 ELSE D3_CUSTO1 END, D3_YSI, D3_EMISSAO, D3_CLVL FROM SD3050 WHERE D_E_L_E_T_ = '') " + Enter
CSQL += " AS SD3, "+RETSQLNAME("SA1")+" SA1 " + Enter

CSQL += " WHERE SUBSTRING(D3_ITEMCTA,1,1) = 'I' " + Enter
CSQL += " AND D3_YSI    = A1_COD " + Enter
CSQL += " AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
CSQL += " AND D3_YSI     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
CSQL += " AND D3_ITEMCTA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + Enter
CSQL += " AND A1_VEND    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
CSQL += " AND A1_GRPVEN  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
CSQL += " AND D3_CLVL          IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
CSQL += " AND SA1.D_E_L_E_T_ = '' " + Enter
CSQL += " GROUP BY SUBSTRING(D3_ITEMCTA,1,5) " + Enter

CSQL += "UNION ALL " + Enter

CSQL += "	SELECT SUBSTRING(E5_ITEMD,1,5) AS ITEM, VALOR = CASE WHEN (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') THEN E5_VALOR*-1 ELSE E5_VALOR END " + Enter
CSQL += "FROM "+RETSQLNAME("SE5")+" SE5, "+RETSQLNAME("SA1")+" SA1 " + Enter
CSQL += "WHERE E5_CLIFOR  = A1_COD " + Enter
CSQL += "AND E5_LOJA      = A1_LOJA " + Enter
CSQL += "AND (E5_TIPODOC  IN ('DC') OR (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') OR (E5_TIPO = 'RPA' AND E5_PREFIXO = 'GPE' AND E5_MOTBX IN ('DEB','NOR')) ) " + Enter
CSQL += "AND E5_SITUACA <> 'C' " + Enter
CSQL += "AND E5_CLIFOR  <> '010064' " + Enter
CSQL += "AND SUBSTRING(E5_ITEMD,1,1) = 'I' " + Enter
CSQL += "AND E5_CLVLDB  IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
CSQL += "AND E5_ITEMD   BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + Enter
CSQL += "AND E5_DATA    BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
CSQL += "AND E5_CLIFOR  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
CSQL += "AND A1_VEND    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
CSQL += "AND A1_GRPVEN  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
//CSQL += "AND E5_RECPAG  = 'R' " + Enter
CSQL += "AND SE5.D_E_L_E_T_ = '' " + Enter
CSQL += "AND SA1.D_E_L_E_T_ = ''" + Enter

IF cEmpAnt == '01'
	CSQL += "UNION ALL " + Enter
	
	CSQL += "	SELECT SUBSTRING(E5_ITEMD,1,5) AS ITEM, VALOR = CASE WHEN (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') THEN E5_VALOR*-1 ELSE E5_VALOR END " + Enter
	CSQL += "FROM SE5070 SE5, SA1070 SA1 " + Enter
	CSQL += "WHERE E5_CLIFOR  = A1_COD " + Enter
	CSQL += "AND E5_LOJA      = A1_LOJA " + Enter
	CSQL += "AND (E5_TIPODOC  IN ('DC') OR (E5_MOTBX = 'DES' AND E5_NATUREZ = '2451') OR (E5_TIPO = 'RPA' AND E5_PREFIXO = 'GPE' AND E5_MOTBX IN ('DEB','NOR')) ) " + Enter
	CSQL += "AND E5_SITUACA <> 'C' " + Enter
	CSQL += "AND E5_CLIFOR  <> '010064' " + Enter
	CSQL += "AND SUBSTRING(E5_ITEMD,1,1) = 'I' " + Enter
	CSQL += "AND E5_CLVLDB  IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" "+ Enter
	CSQL += "AND E5_ITEMD   BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + Enter
	CSQL += "AND E5_DATA    BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
	CSQL += "AND E5_CLIFOR  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
	CSQL += "AND A1_VEND    BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + Enter
	CSQL += "AND A1_GRPVEN  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + Enter
	//CSQL += "AND E5_RECPAG  = 'R' " + Enter
	CSQL += "AND SE5.D_E_L_E_T_ = '' " + Enter
	CSQL += "AND SA1.D_E_L_E_T_ = ''" + Enter
ENDIF

CSQL += "UNION ALL " + Enter

CSQL += "	SELECT SUBSTRING(CT2_ITEMD,1,5) AS ITEM, ISNULL(SUM(CT2_VALOR),0) AS VALOR " + Enter
IF DTOS(dDatabase) >= '20130701'
	CSQL += " FROM (SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31406') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2010 WHERE D_E_L_E_T_ = ''  " + Enter
ELSE
	CSQL += " FROM (SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31404') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2010 WHERE D_E_L_E_T_ = ''  " + Enter
ENDIF
CSQL += "       UNION ALL  " + Enter
IF DTOS(dDatabase) >= '20130701'
	CSQL += "       SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31406') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2050 WHERE D_E_L_E_T_ = '') " + Enter
ELSE
	CSQL += "       SELECT CT2_VALOR = CASE WHEN (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31404') AND (SUBSTRING(CT2_DEBITO,1,7) <> '31401017') THEN CT2_VALOR ELSE CT2_VALOR * -1 END, CT2_FILIAL, CT2_DATA, CT2_DEBITO, CT2_CREDIT, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_ROTINA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST FROM CT2050 WHERE D_E_L_E_T_ = '') " + Enter
ENDIF
CSQL += " AS CT2 " + Enter
CSQL += "WHERE CT2_FILIAL = '"+xFilial("CT2")+"' " + Enter
CSQL += "AND   CT2_DATA   BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " + Enter
IF DTOS(dDatabase) >= '20130701'
	CSQL += "AND   (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31406' OR SUBSTRING(CT2_CREDIT,1,5) = '31401' OR SUBSTRING(CT2_CREDIT,1,5) = '31406') " + Enter
ELSE
	CSQL += "AND   (SUBSTRING(CT2_DEBITO,1,5) = '31401' OR SUBSTRING(CT2_DEBITO,1,5) = '31404' OR SUBSTRING(CT2_CREDIT,1,5) = '31401' OR SUBSTRING(CT2_CREDIT,1,5) = '31404') " + Enter
ENDIF
CSQL += "AND   SUBSTRING(CT2_DEBITO,1,7) <> '31401017' AND SUBSTRING(CT2_CREDIT,1,7) <> '31401017' " + Enter
CSQL += "AND   (SUBSTRING(CT2_ITEMD,1,1) = 'I' OR SUBSTRING(CT2_ITEMC,1,1) = 'I') " + Enter
CSQL += "AND   CT2_ITEMD <> 'I9999' AND CT2_ITEMC <> 'I9999' " + Enter	
CSQL += "AND   SUBSTRING(CT2_ITEMD,1,3) <> 'I03' AND SUBSTRING(CT2_ITEMC,1,3) <> 'I03' " + Enter	
CSQL += "AND   (CT2_CLVLDB   IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" OR CT2_CLVLCR IN  "+FormatIN(ALLTRIM(MV_PAR12),",")+" )"+ Enter
CSQL += "AND   ((CT2_ITEMD   BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') OR (CT2_ITEMC  BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' )) " + Enter
CSQL += "AND   CT2_ROTINA = 'CTBA102' " + Enter
CSQL += "GROUP BY SUBSTRING(CT2_ITEMD,1,5) ) AS WWW " + Enter

CSQL += "GROUP BY ITEM " + Enter
CSQL += "ORDER BY ITEM " + Enter

//CSQL += "UNION ALL " + Enter

//CSQL += "	SELECT SUBSTRING(CT2_ITEMD,1,5) AS ITEM, ISNULL(SUM(CT2_VALOR),0) AS VALOR " + Enter
//                                                                                              
//CSQL += "GROUP BY SUBSTRING(CT2_ITEMD,1,5) ) AS WWW " + Enter
//
//CSQL += "GROUP BY ITEM " + Enter
//CSQL += "ORDER BY ITEM " + Enter

IF CHKFILE("_CTR2")
	DBSELECTAREA("_CTR2")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_CTR2" NEW

DbSelectArea("_CTR2")
DbGoTop()

nTotal   := 0
nSubTot  := 0
cItemAnt := SUBSTR(_CTR2->ITEM,1,3)

WHILE !Eof()
	
	IF SUBSTR(_CTR2->ITEM,1,3) <> cItemAnt
		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek(xFilial("CTD")+cItemAnt)
		
		fr_Quebra := +;
		Padr(cItemAnt        								        						  ,25)+" "+;
		Padr(SPACE(8)  					                  				         		      ,08)+" "+;
		Padr(SPACE(9)                       											 	  ,08)+" "+;
		Padr(ALLTRIM(CTD->CTD_DESC01)      													  ,75)+" "+;
		Padr(SPACE(61)                       											 	  ,63)+" "+;
		Padl(Transform(nSubTot, "@E 999,999,999.99") 					    		 	      ,14)
		
		oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
		nRow1 += 030
		
		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf
		
		oPrint:Line (nRow1, 010, nRow1, 3550)
		nRow1 += 050
		
		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf
		nSubTot := 0
	ENDIF
	
	DbSelectArea("CTD")
	DbSetOrder(1)
	DbSeek(xFilial("CTD")+_CTR2->ITEM)
	
	fr_Quebra := +;
	Padr(_CTR2->ITEM					                  								  ,25)+" "+;
	Padr(SPACE(8)  					                  								      ,08)+" "+;
	Padr(SPACE(9)                       											 	  ,08)+" "+;
	Padr(ALLTRIM(CTD->CTD_DESC01)      													  ,75)+" "+;
	Padr(SPACE(61)                       											 	  ,63)+" "+;
	Padl(Transform(_CTR2->VALOR, "@E 999,999,999.99")                          	          ,14)
	
	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	oPrint:Line (nRow1, 010, nRow1, 3550)
	nRow1 += 020
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	nSubTot  := nSubTot + _CTR2->VALOR
	nTotal   := nTotal  + _CTR2->VALOR
	cItemAnt := SUBSTR(_CTR2->ITEM,1,3)
	
	DbSelectArea("_CTR2")
	DbSkip()
END

IF !EMPTY(cItemAnt)
	DbSelectArea("CTD")
	DbSetOrder(1)
	DbSeek(xFilial("CTD")+cItemAnt)
	
	fr_Quebra := +;
	Padr(cItemAnt        								        					      ,25)+" "+;
	Padr(SPACE(8)  					                  							   	      ,08)+" "+;
	Padr(SPACE(4)                       											 	  ,08)+" "+;
	Padr(ALLTRIM(CTD->CTD_DESC01)      													  ,75)+" "+;
	Padr(SPACE(61)                       											 	  ,63)+" "+;
	Padl(Transform(nSubTot, "@E 999,999,999.99")   			 	                          ,14)
	
	oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
	nRow1 += 030
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	oPrint:Line (nRow1, 010, nRow1, 3550)
	nRow1 += 050
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
ENDIF

fr_Quebra := +;
Padr(SPACE(25)					                  								    ,25)+" "+;
Padr(SPACE(8)  					                  								    ,08)+" "+;
Padr(SPACE(4)                       											    ,08)+" "+;
Padr(SPACE(75)					                  								    ,75)+" "+;
Padr("Total Geral: "  	                   									        ,63)+" "+;
Padl(Transform(nTotal, "@E 999,999,999.99")			    	                        ,14)

oPrint:Say  (nRow1 ,0010 ,fr_Quebra,ofont7)
nRow1 += 030

If nRow1 > 2250
	fImpRoda()
	fImpCabec()
EndIf

oPrint:Line (nRow1, 010, nRow1, 3550)
nRow1 += 020

_CTR2->(dbCloseArea())

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

oPrint:StartPage()
wnPag ++
nRow1 := 050
If File(aBitmap)
	oPrint:SayBitmap( nRow1,0050,aBitmap,0500,0150 )
EndIf
nRow1 += 025
oPrint:Say  (nRow1   , 0050 ,Padl(fCabec,90)                         ,oFont14)
oPrint:Say  (nRow1+20 ,2950 ,"Página:"                               ,oFont7)
oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont8)
nRow1 += 075
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec2,133)                       ,oFont10)
nRow1 += 075

xf_Titu := +;
Padr("Número"    			    						     ,25)+" "+;
Padr("Data    "             					 			 ,08)+" "+;
Padr("CV  "            							 			 ,04)+SPACE(5)+;
Padr("Descrição/Produto"     					 			 ,35)+SPACE(5)+;
Padr("Cliente/Fornecedor"    					 			 ,40)+SPACE(5)+;
Padr("Cliente - AI"         					 			 ,50)+SPACE(5)+;
Padl("Valor"              		       					     ,14)
//Padl("Saldo" 		           						 	     ,14)

oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 075

Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

oPrint:Line (2300, 010, 2300, 3550)
oPrint:Say  (2300+30 , 010,"Prog.: BIA488"                                        ,oFont7)
oPrint:Say  (2300+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
oPrint:EndPage()
nRow1 := 4000

Return
