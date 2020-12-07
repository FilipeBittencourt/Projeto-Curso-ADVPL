#Include "Protheus.ch"
#include "topconn.ch"

User Function BIA250()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA250
Empresa   := Biancogres Cerâmica S/A
Data      := 05/07/11
Uso       := Estoque/Custo
Aplicação := Controle de Poder de/em Terceiros
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

cHInicio := Time()
fPerg := "BIA250"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

oLogProc := TBiaLogProc():New()
oLogProc:LogIniProc("BIA250",fPerg)

aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
If MV_PAR01 == 2
	fCabec   := "Controle de Poder em Terceiros"
ElseIf MV_PAR01 == 1
	fCabec   := "Controle de Poder de Terceiros"
Else
	fCabec   := "Controle de Poder de/em Terceiros"
EndIf

wnPag    := 0
nRow1    := 0

oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetPortrait()
oPrint:SetPaperSize(09)
oPrint:Setup()

cTempo := Alltrim(ElapTime(cHInicio, Time()))
IncProc("Armazenando....   Tempo: "+cTempo)

A0001 := " SELECT B6_CLIFOR,
A0001 += "        B6_LOJA LJ,
A0001 += "        B6_PRODUTO PROD,
A0001 += "        B6_IDENT,
A0001 += "        B6_TPCF C_F,
A0001 += "        CASE
A0001 += "          WHEN B6_PODER3 = 'R' THEN
A0001 += "           '1'
A0001 += "          ELSE
A0001 += "           '2'
A0001 += "        END P3,
A0001 += "        B6_EMISSAO EMISSAO,
A0001 += "        B6_DTDIGIT DTDIGIT,
A0001 += "        B6_DOC NFISC,
A0001 += "        B6_SERIE SERI,
A0001 += "        CASE
A0001 += "          WHEN B6_PODER3 = 'R' THEN
A0001 += "           B6_QUANT
A0001 += "          ELSE
A0001 += "           0
A0001 += "        END REM_QTQ,
A0001 += "        CASE
A0001 += "          WHEN B6_PODER3 = 'R' THEN
If MV_PAR12 == 1
	A0001 += "           B6_PRUNIT * B6_QUANT
Else
	A0001 += "           B6_CUSTO1
EndIf
A0001 += "          ELSE
A0001 += "           0
A0001 += "        END REM_VLR,
A0001 += "        CASE
A0001 += "          WHEN B6_PODER3 = 'R' THEN
A0001 += "           0
A0001 += "          ELSE
A0001 += "           B6_QUANT
A0001 += "        END DEV_QTQ,
A0001 += "        CASE
A0001 += "          WHEN B6_PODER3 = 'R' THEN
A0001 += "           0
A0001 += "          ELSE
If MV_PAR12 == 1
	A0001 += "           B6_PRUNIT * B6_QUANT
Else
	A0001 += "           B6_CUSTO1
EndIf
A0001 += "        END DEV_VLR,
A0001 += "        B6_TES TES,
A0001 += "        B6_LOCAL LC
A0001 += "   FROM " + RetSqlName("SB6")
A0001 += "  WHERE B6_FILIAL = '"+xFilial("SB6")+"'
A0001 += "    AND B6_DTDIGIT <= '"+dtos(MV_PAR03)+"'
A0001 += "    AND B6_PRODUTO BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'
A0001 += "    AND B6_CLIFOR BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'
A0001 += "    AND B6_LOJA BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'
If MV_PAR01 == 2
	A0001 += "    AND B6_TPCF = 'F'
ElseIf MV_PAR01 == 1
	A0001 += "    AND B6_TPCF = 'C'
EndIf
If !Empty(MV_PAR13)
	A0001 += "    AND B6_CLIFOR <> '"+MV_PAR13+"'
EndIf
A0001 += "    AND D_E_L_E_T_ = ' '
A0001 := ChangeQuery(A0001)
cIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,A0001),'A001',.T.,.T.)
aStru1 := ("A001")->(dbStruct())

gh_Ind := ""
If MV_PAR10 == 1
	gh_Ind := "C_F+B6_CLIFOR+LJ+PROD+DTDIGIT+P3"
ElseIf MV_PAR10 == 2
	gh_Ind := "C_F+PROD+B6_CLIFOR+LJ+DTDIGIT+P3"
ElseIf MV_PAR10 == 3
	gh_Ind := "C_F+B6_CLIFOR+LJ+PROD+B6_IDENT+P3"
End

/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
If !chkfile("A002")
	A002 := U_BIACrTMP(aStru1)
	dbUseArea( .T.,, A002, "A002", .F., .F. )
	dbCreateInd(A002, gh_Ind,{ || gh_Ind })
EndIf
dbSelectArea("A002")
APPEND FROM ("A001")
If Select("A001") > 0
	A001->(dbCloseArea())
Endif

fImpCabec()
If MV_PAR10 == 1                                                                   // Por Fornecedor
	************************************************************************************************
	
	dbSelectArea("A002")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		If nRow1 > 3150
			fImpRoda()
			fImpCabec()
		EndIf
		If A002->C_F == "F"
			oPrint:Say  (nRow1 ,0050 , A002->B6_CLIFOR+"-"+A002->LJ+" "+Posicione("SA2",1,xFilial("SA2")+A002->B6_CLIFOR+A002->LJ,"A2_NOME")     ,oFont8)
		Else
			oPrint:Say  (nRow1 ,0050 , A002->B6_CLIFOR+"-"+A002->LJ+" "+Posicione("SA1",1,xFilial("SA1")+A002->B6_CLIFOR+A002->LJ,"A1_NOME")     ,oFont8)
		EndIf
		nRow1 += 050
		df_C_F  := A002->C_F
		df_Forn := A002->B6_CLIFOR
		df_Loja := A002->LJ
		dbSelectArea("A002")
		While !Eof() .and. df_C_F == A002->C_F .and. df_Forn == A002->B6_CLIFOR .and. df_Loja == A002->LJ
			
			If nRow1 > 3150
				fImpRoda()
				fImpCabec()
			EndIf
			
			df_Prod := A002->PROD
			If MV_PAR11 == 1
				A0007 := " SELECT ((SELECT ISNULL(SUM(B6_QUANT), 0)
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'R'
				A0007 += "             AND D_E_L_E_T_ = ' ') -
				A0007 += "        (SELECT ISNULL(SUM(B6_QUANT), 0)
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'D'
				A0007 += "             AND D_E_L_E_T_ = ' ')) QUANT,
				If MV_PAR12 == 1
					A0007 += "        ((SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
				Else
					A0007 += "        ((SELECT ISNULL(SUM(B6_CUSTO1), 0)
				EndIf
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'R'
				A0007 += "             AND D_E_L_E_T_ = ' ') -
				If MV_PAR12 == 1
					A0007 += "        (SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
				Else
					A0007 += "        (SELECT ISNULL(SUM(B6_CUSTO1), 0)
				EndIf
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'D'
				A0007 += "             AND D_E_L_E_T_ = ' ')) VALOR
				TCQUERY A0007 New Alias "A007"
				dbSelectArea("A007")
				dbGoTop()
				yy_Qtd   := A007->QUANT
				yy_Vlr   := A007->VALOR
				A007->(dbCloseArea())
				If yy_Qtd == 0 .and. yy_Vlr == 0
					dbSelectArea("A002")
					While !Eof() .and. df_C_F == A002->C_F .and. df_Forn == A002->B6_CLIFOR .and. df_Loja == A002->LJ .and. df_Prod == A002->PROD
						dbSkip()
					End
					Loop
				EndIf
			EndIf
			
			A0003 := " SELECT ((SELECT ISNULL(SUM(B6_QUANT), 0)
			A0003 += "            FROM " + RetSqlName("SB6")
			A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
			A0003 += "             AND B6_PRODUTO = '"+A002->PROD+"'
			A0003 += "             AND B6_CLIFOR = '"+df_Forn+"'
			A0003 += "             AND B6_LOJA = '"+df_Loja+"'
			A0003 += "             AND B6_PODER3 = 'R'
			A0003 += "             AND D_E_L_E_T_ = ' ') -
			A0003 += "        (SELECT ISNULL(SUM(B6_QUANT), 0)
			A0003 += "            FROM " + RetSqlName("SB6")
			A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
			A0003 += "             AND B6_PRODUTO = '"+A002->PROD+"'
			A0003 += "             AND B6_CLIFOR = '"+df_Forn+"'
			A0003 += "             AND B6_LOJA = '"+df_Loja+"'
			A0003 += "             AND B6_PODER3 = 'D'
			A0003 += "             AND D_E_L_E_T_ = ' ')) QUANT,
			If MV_PAR12 == 1
				A0003 += "        ((SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
			Else
				A0003 += "        ((SELECT ISNULL(SUM(B6_CUSTO1), 0)
			EndIf
			A0003 += "            FROM " + RetSqlName("SB6")
			A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
			A0003 += "             AND B6_PRODUTO = '"+A002->PROD+"'
			A0003 += "             AND B6_CLIFOR = '"+df_Forn+"'
			A0003 += "             AND B6_LOJA = '"+df_Loja+"'
			A0003 += "             AND B6_PODER3 = 'R'
			A0003 += "             AND D_E_L_E_T_ = ' ') -
			If MV_PAR12 == 1
				A0003 += "        (SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
			Else
				A0003 += "        (SELECT ISNULL(SUM(B6_CUSTO1), 0)
			EndIf
			A0003 += "            FROM " + RetSqlName("SB6")
			A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
			A0003 += "             AND B6_PRODUTO = '"+A002->PROD+"'
			A0003 += "             AND B6_CLIFOR = '"+df_Forn+"'
			A0003 += "             AND B6_LOJA = '"+df_Loja+"'
			A0003 += "             AND B6_PODER3 = 'D'
			A0003 += "             AND D_E_L_E_T_ = ' ')) VALOR
			TCQUERY A0003 New Alias "A003"
			dbSelectArea("A003")
			dbGoTop()
			nv_Qtd   := A003->QUANT
			nv_Vlr   := A003->VALOR
			A003->(dbCloseArea())
			
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+A002->PROD))
			nRow1 += 025
			oPrint:Say  (nRow1 ,0075 , Alltrim(A002->PROD)+" - "+Alltrim(SB1->B1_DESC)+"  "+SB1->B1_UM     ,oFont8)
			oPrint:Say  (nRow1 ,0075 , Padr("",103) + "Saldo Anterior:    "+IIF(nv_Qtd   <> 0  , Transform(nv_Qtd,"@E 9,999,999.9999"), "             -")+" "+IIF(nv_Vlr   <> 0  , Transform(nv_Vlr,"@E 9,999,999.9999"), "             -")     ,oFont7)
			nRow1 += 050
			dbSelectArea("A002")
			While !Eof() .and. df_C_F == A002->C_F .and. df_Forn == A002->B6_CLIFOR .and. df_Loja == A002->LJ .and. df_Prod == A002->PROD
				
				If stod(A002->DTDIGIT) < MV_PAR02
					dbSelectArea("A002")
					dbSkip()
					Loop
				EndIf
				
				cTempo := Alltrim(ElapTime(cHInicio, Time()))
				IncProc("Imprimindo....    Tempo: "+cTempo)
				
				If A002->DTDIGIT < dtos(MV_PAR02)
					dbSelectArea("A002")
					dbSkip()
					Loop
				EndIf
				
				If nRow1 > 3150
					fImpRoda()
					fImpCabec()
				EndIf
				
				nv_Qtd   += IIF(A002->P3 == "1", A002->REM_QTQ, 0)
				nv_Vlr   += IIF(A002->P3 == "1", A002->REM_VLR, 0)
				nv_Qtd   -= IIF(A002->P3 == "2", A002->DEV_QTQ, 0)
				nv_Vlr   -= IIF(A002->P3 == "2", A002->DEV_VLR, 0)
				
				xf_Item := +;
				Padr(""                                                                         ,05)+""+;
				Padr(A002->B6_IDENT                                                             ,06)+" "+;
				Padc(A002->C_F                                                                  ,03)+" "+;
				Padc(A002->P3                                                                   ,03)+" "+;
				Padc(dtoc(stod(A002->EMISSAO))                                                  ,08)+"  "+;
				Padc(dtoc(stod(A002->DTDIGIT))                                                  ,08)+"  "+;
				Padr(A002->SERI                                                                 ,03)+"  "+;
				Padr(A002->NFISC                                                                ,09)+"  "+;
				Padr(A002->TES                                                                  ,03)+"  "+;
				Padr(A002->LC                                                                   ,02)+" "+;
				Padl(IIF(A002->P3 == "1", Transform(A002->REM_QTQ,"@E 9,999,999.9999"), "-")    ,14)+" "+;
				Padl(IIF(A002->P3 == "1", Transform(A002->REM_VLR,"@E 9,999,999.9999"), "-")    ,14)+" "+;
				Padl(IIF(A002->P3 == "2", Transform(A002->DEV_QTQ,"@E 9,999,999.9999"), "-")    ,14)+" "+;
				Padl(IIF(A002->P3 == "2", Transform(A002->DEV_VLR,"@E 9,999,999.9999"), "-")    ,14)+" "+;
				Padl(IIF(nv_Qtd   <> 0  , Transform(nv_Qtd,"@E 9,999,999.9999"), "-")           ,14)+" "+;
				Padl(IIF(nv_Vlr   <> 0  , Transform(nv_Vlr,"@E 9,999,999.9999"), "-")           ,14)
				oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont7)
				nRow1 += 050
				dbSelectArea("A002")
				dbSkip()
			End
			If nRow1 > 3150
				fImpRoda()
				fImpCabec()
			EndIf
			oPrint:Say  (nRow1 ,0050 , Padr("",105) + "Novo Saldo:        "+IIF(nv_Qtd   <> 0  , Transform(nv_Qtd,"@E 9,999,999.9999"), "             -")+" "+IIF(nv_Vlr   <> 0  , Transform(nv_Vlr,"@E 9,999,999.9999"), "             -")     ,oFont7)
			nRow1 += 050
		End
	End
	
ElseIf MV_PAR10 == 2                                                                  // Por Produto
	************************************************************************************************
	
	dbSelectArea("A002")
	dbGoTop()
	ProcRegua(RecCount())
	xx_Qtd  := 0
	xx_Vlr  := 0
	While !Eof()
		
		If nRow1 > 3150
			fImpRoda()
			fImpCabec()
		EndIf
		
		df_C_F  := A002->C_F
		df_Prod := A002->PROD
		df_Qtd  := 0
		df_Vlr  := 0
		If MV_PAR11 == 1
			A0007 := " SELECT ((SELECT ISNULL(SUM(B6_QUANT), 0)
			A0007 += "            FROM " + RetSqlName("SB6")
			A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0007 += "             AND B6_DTDIGIT <= '"+dtos(MV_PAR03)+"'
			A0007 += "             AND B6_TPCF = '"+df_C_F+"'
			A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
			A0007 += "             AND B6_PODER3 = 'R'
			A0007 += "             AND D_E_L_E_T_ = ' ') -
			A0007 += "        (SELECT ISNULL(SUM(B6_QUANT), 0)
			A0007 += "            FROM " + RetSqlName("SB6")
			A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0007 += "             AND B6_DTDIGIT <= '"+dtos(MV_PAR03)+"'
			A0007 += "             AND B6_TPCF = '"+df_C_F+"'
			A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
			A0007 += "             AND B6_PODER3 = 'D'
			A0007 += "             AND D_E_L_E_T_ = ' ')) QUANT,
			If MV_PAR12 == 1
				A0007 += "        ((SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
			Else
				A0007 += "        ((SELECT ISNULL(SUM(B6_CUSTO1), 0)
			EndIf
			A0007 += "            FROM " + RetSqlName("SB6")
			A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0007 += "             AND B6_DTDIGIT <= '"+dtos(MV_PAR03)+"'
			A0007 += "             AND B6_TPCF = '"+df_C_F+"'
			A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
			A0007 += "             AND B6_PODER3 = 'R'
			A0007 += "             AND D_E_L_E_T_ = ' ') -
			If MV_PAR12 == 1
				A0007 += "        (SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
			Else
				A0007 += "        (SELECT ISNULL(SUM(B6_CUSTO1), 0)
			EndIf
			A0007 += "            FROM " + RetSqlName("SB6")
			A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0007 += "             AND B6_DTDIGIT <= '"+dtos(MV_PAR03)+"'
			A0007 += "             AND B6_TPCF = '"+df_C_F+"'
			A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
			A0007 += "             AND B6_PODER3 = 'D'
			A0007 += "             AND D_E_L_E_T_ = ' ')) VALOR
			TCQUERY A0007 New Alias "A007"
			dbSelectArea("A007")
			dbGoTop()
			yy_Qtd   := A007->QUANT
			yy_Vlr   := A007->VALOR
			A007->(dbCloseArea())
			If yy_Qtd == 0 .and. yy_Vlr == 0
				dbSelectArea("A002")
				While !Eof() .and. df_C_F == A002->C_F .and. df_Prod == A002->PROD
					dbSkip()
				End
				Loop
			EndIf
		EndIf
		
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+A002->PROD))
		oPrint:Say  (nRow1 ,0050 , Alltrim(A002->PROD)+" - "+Alltrim(SB1->B1_DESC)+"  "+SB1->B1_UM     ,oFont8)
		nRow1 += 050
		dbSelectArea("A002")
		While !Eof() .and. df_C_F == A002->C_F .and. df_Prod == A002->PROD
			
			If nRow1 > 3150
				fImpRoda()
				fImpCabec()
			EndIf
			
			df_Forn := A002->B6_CLIFOR
			df_Loja := A002->LJ
			
			If MV_PAR11 == 1
				A0007 := " SELECT ((SELECT ISNULL(SUM(B6_QUANT), 0)
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT <= '"+dtos(MV_PAR03)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'R'
				A0007 += "             AND D_E_L_E_T_ = ' ') -
				A0007 += "        (SELECT ISNULL(SUM(B6_QUANT), 0)
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT <= '"+dtos(MV_PAR03)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'D'
				A0007 += "             AND D_E_L_E_T_ = ' ')) QUANT,
				If MV_PAR12 == 1
					A0007 += "        ((SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
				Else
					A0007 += "        ((SELECT ISNULL(SUM(B6_CUSTO1), 0)
				EndIf
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT <= '"+dtos(MV_PAR03)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'R'
				A0007 += "             AND D_E_L_E_T_ = ' ') -
				If MV_PAR12 == 1
					A0007 += "        (SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
				Else
					A0007 += "        (SELECT ISNULL(SUM(B6_CUSTO1), 0)
				EndIf
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT <= '"+dtos(MV_PAR03)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'D'
				A0007 += "             AND D_E_L_E_T_ = ' ')) VALOR
				TCQUERY A0007 New Alias "A007"
				dbSelectArea("A007")
				dbGoTop()
				yy_Qtd   := A007->QUANT
				yy_Vlr   := A007->VALOR
				A007->(dbCloseArea())
				If yy_Qtd == 0 .and. yy_Vlr == 0
					dbSelectArea("A002")
					While !Eof() .and. df_C_F == A002->C_F .and. df_Prod == A002->PROD .and. df_Forn == A002->B6_CLIFOR .and. df_Loja == A002->LJ
						dbSkip()
					End
					Loop
				EndIf
			EndIf
			
			A0003 := " SELECT ((SELECT ISNULL(SUM(B6_QUANT), 0)
			A0003 += "            FROM " + RetSqlName("SB6")
			A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
			A0003 += "             AND B6_PRODUTO = '"+A002->PROD+"'
			A0003 += "             AND B6_CLIFOR = '"+df_Forn+"'
			A0003 += "             AND B6_LOJA = '"+df_Loja+"'
			A0003 += "             AND B6_PODER3 = 'R'
			A0003 += "             AND D_E_L_E_T_ = ' ') -
			A0003 += "        (SELECT ISNULL(SUM(B6_QUANT), 0)
			A0003 += "            FROM " + RetSqlName("SB6")
			A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
			A0003 += "             AND B6_PRODUTO = '"+A002->PROD+"'
			A0003 += "             AND B6_CLIFOR = '"+df_Forn+"'
			A0003 += "             AND B6_LOJA = '"+df_Loja+"'
			A0003 += "             AND B6_PODER3 = 'D'
			A0003 += "             AND D_E_L_E_T_ = ' ')) QUANT,
			If MV_PAR12 == 1
				A0003 += "        ((SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
			Else
				A0003 += "        ((SELECT ISNULL(SUM(B6_CUSTO1), 0)
			EndIf
			A0003 += "            FROM " + RetSqlName("SB6")
			A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
			A0003 += "             AND B6_PRODUTO = '"+A002->PROD+"'
			A0003 += "             AND B6_CLIFOR = '"+df_Forn+"'
			A0003 += "             AND B6_LOJA = '"+df_Loja+"'
			A0003 += "             AND B6_PODER3 = 'R'
			A0003 += "             AND D_E_L_E_T_ = ' ') -
			If MV_PAR12 == 1
				A0003 += "        (SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
			Else
				A0003 += "        (SELECT ISNULL(SUM(B6_CUSTO1), 0)
			EndIf
			A0003 += "            FROM " + RetSqlName("SB6")
			A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
			A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
			A0003 += "             AND B6_PRODUTO = '"+A002->PROD+"'
			A0003 += "             AND B6_CLIFOR = '"+df_Forn+"'
			A0003 += "             AND B6_LOJA = '"+df_Loja+"'
			A0003 += "             AND B6_PODER3 = 'D'
			A0003 += "             AND D_E_L_E_T_ = ' ')) VALOR
			TCQUERY A0003 New Alias "A003"
			dbSelectArea("A003")
			dbGoTop()
			nv_Qtd   := A003->QUANT
			nv_Vlr   := A003->VALOR
			A003->(dbCloseArea())
			
			nRow1 += 025
			If A002->C_F == "F"
				oPrint:Say  (nRow1 ,0075 , A002->B6_CLIFOR+"-"+A002->LJ+" "+Posicione("SA2",1,xFilial("SA2")+A002->B6_CLIFOR+A002->LJ,"A2_NOME")     ,oFont8)
			Else
				oPrint:Say  (nRow1 ,0075 , A002->B6_CLIFOR+"-"+A002->LJ+" "+Posicione("SA1",1,xFilial("SA1")+A002->B6_CLIFOR+A002->LJ,"A1_NOME")     ,oFont8)
			EndIf
			oPrint:Say  (nRow1 ,0075 , Padr("",103) + "Saldo Anterior:    "+IIF(nv_Qtd   <> 0  , Transform(nv_Qtd,"@E 9,999,999.9999"), "             -")+" "+IIF(nv_Vlr   <> 0  , Transform(nv_Vlr,"@E 9,999,999.9999"), "             -")     ,oFont7)
			nRow1 += 050
			
			dbSelectArea("A002")
			While !Eof() .and. df_C_F == A002->C_F .and. df_Prod == A002->PROD .and. df_Forn == A002->B6_CLIFOR .and. df_Loja == A002->LJ
				
				If stod(A002->DTDIGIT) < MV_PAR02
					dbSelectArea("A002")
					dbSkip()
					Loop
				EndIf
				
				cTempo := Alltrim(ElapTime(cHInicio, Time()))
				IncProc("Imprimindo....    Tempo: "+cTempo)
				
				If A002->DTDIGIT < dtos(MV_PAR02)
					dbSelectArea("A002")
					dbSkip()
					Loop
				EndIf
				
				If nRow1 > 3150
					fImpRoda()
					fImpCabec()
				EndIf
				
				nv_Qtd   += IIF(A002->P3 == "1", A002->REM_QTQ, 0)
				nv_Vlr   += IIF(A002->P3 == "1", A002->REM_VLR, 0)
				nv_Qtd   -= IIF(A002->P3 == "2", A002->DEV_QTQ, 0)
				nv_Vlr   -= IIF(A002->P3 == "2", A002->DEV_VLR, 0)
				
				xf_Item := +;
				Padr(""                                                                         ,05)+""+;
				Padr(A002->B6_IDENT                                                             ,06)+" "+;
				Padc(A002->C_F                                                                  ,03)+" "+;
				Padc(A002->P3                                                                   ,03)+" "+;
				Padc(dtoc(stod(A002->EMISSAO))                                                  ,08)+"  "+;
				Padc(dtoc(stod(A002->DTDIGIT))                                                  ,08)+"  "+;
				Padr(A002->SERI                                                                 ,03)+"  "+;
				Padr(A002->NFISC                                                                ,09)+"  "+;
				Padr(A002->TES                                                                  ,03)+"  "+;
				Padr(A002->LC                                                                   ,02)+" "+;
				Padl(IIF(A002->P3 == "1", Transform(A002->REM_QTQ,"@E 9,999,999.9999"), "-")    ,14)+" "+;
				Padl(IIF(A002->P3 == "1", Transform(A002->REM_VLR,"@E 9,999,999.9999"), "-")    ,14)+" "+;
				Padl(IIF(A002->P3 == "2", Transform(A002->DEV_QTQ,"@E 9,999,999.9999"), "-")    ,14)+" "+;
				Padl(IIF(A002->P3 == "2", Transform(A002->DEV_VLR,"@E 9,999,999.9999"), "-")    ,14)+" "+;
				Padl(IIF(nv_Qtd   <> 0  , Transform(nv_Qtd,"@E 9,999,999.9999"), "-")           ,14)+" "+;
				Padl(IIF(nv_Vlr   <> 0  , Transform(nv_Vlr,"@E 9,999,999.9999"), "-")           ,14)
				oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont7)
				nRow1 += 050
				dbSelectArea("A002")
				dbSkip()
			End
			If nRow1 > 3150
				fImpRoda()
				fImpCabec()
			EndIf
			oPrint:Say  (nRow1 ,0050 , Padr("",105) + "Novo Saldo:        "+IIF(nv_Qtd   <> 0  , Transform(nv_Qtd,"@E 9,999,999.9999"), "             -")+" "+IIF(nv_Vlr   <> 0  , Transform(nv_Vlr,"@E 9,999,999.9999"), "             -")     ,oFont7)
			nRow1 += 050
			
			df_Qtd  += nv_Qtd
			df_Vlr  += nv_Vlr
			xx_Qtd  += nv_Qtd
			xx_Vlr  += nv_Vlr
		End
		
		If nRow1 > 3150
			fImpRoda()
			fImpCabec()
		EndIf
		
		oPrint:Say  (nRow1 ,0050 , "Total do Produto: " + df_Prod                                                                                                                                                     ,oFont8)
		oPrint:Say  (nRow1 ,0050 , Padr("",124) + IIF(df_Qtd   <> 0  , Transform(df_Qtd,"@E 9,999,999.9999"), "             -")+" "+IIF(df_Vlr   <> 0  , Transform(df_Vlr,"@E 9,999,999.9999"), "             -")     ,oFont7)
		oPrint:Line (nRow1+40, 050, nRow1+40, 2350)
		nRow1 += 075
		
	End
	
	oPrint:Say  (nRow1 ,0050 , "Total do Geral: "                                                                                                                                                                 ,oFont8)
	oPrint:Say  (nRow1 ,0050 , Padr("",124) + IIF(xx_Qtd   <> 0  , Transform(xx_Qtd,"@E 9,999,999.9999"), "             -")+" "+IIF(xx_Vlr   <> 0  , Transform(xx_Vlr,"@E 9,999,999.9999"), "             -")     ,oFont7)
	
ElseIf MV_PAR10 == 3                                        // Por Ident - Controle de Nota por Nota
	************************************************************************************************
	
	dbSelectArea("A002")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		If nRow1 > 3150
			fImpRoda()
			fImpCabec()
		EndIf
		If A002->C_F == "F"
			oPrint:Say  (nRow1 ,0050 , A002->B6_CLIFOR+"-"+A002->LJ+" "+Posicione("SA2",1,xFilial("SA2")+A002->B6_CLIFOR+A002->LJ,"A2_NOME")     ,oFont8)
		Else
			oPrint:Say  (nRow1 ,0050 , A002->B6_CLIFOR+"-"+A002->LJ+" "+Posicione("SA1",1,xFilial("SA1")+A002->B6_CLIFOR+A002->LJ,"A1_NOME")     ,oFont8)
		EndIf
		nRow1 += 050
		df_C_F  := A002->C_F
		df_Forn := A002->B6_CLIFOR
		df_Loja := A002->LJ
		dbSelectArea("A002")
		While !Eof() .and. df_C_F == A002->C_F .and. df_Forn == A002->B6_CLIFOR .and. df_Loja == A002->LJ
			
			If nRow1 > 3150
				fImpRoda()
				fImpCabec()
			EndIf
			
			df_Prod := A002->PROD
			If MV_PAR11 == 1
				A0007 := " SELECT ((SELECT ISNULL(SUM(B6_QUANT), 0)
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03-1)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'R'
				A0007 += "             AND D_E_L_E_T_ = ' ') -
				A0007 += "        (SELECT ISNULL(SUM(B6_QUANT), 0)
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03-1)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'D'
				A0007 += "             AND D_E_L_E_T_ = ' ')) QUANT,
				If MV_PAR12 == 1
					A0007 += "        ((SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
				Else
					A0007 += "        ((SELECT ISNULL(SUM(B6_CUSTO1), 0)
				EndIf
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03-1)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'R'
				A0007 += "             AND D_E_L_E_T_ = ' ') -
				If MV_PAR12 == 1
					A0007 += "        (SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
				Else
					A0007 += "        (SELECT ISNULL(SUM(B6_CUSTO1), 0)
				EndIf
				A0007 += "            FROM " + RetSqlName("SB6")
				A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03-1)+"'
				A0007 += "             AND B6_TPCF = '"+df_C_F+"'
				A0007 += "             AND B6_CLIFOR = '"+df_Forn+"'
				A0007 += "             AND B6_LOJA = '"+df_Loja+"'
				A0007 += "             AND B6_PRODUTO = '"+df_Prod+"'
				A0007 += "             AND B6_PODER3 = 'D'
				A0007 += "             AND D_E_L_E_T_ = ' ')) VALOR
				TCQUERY A0007 New Alias "A007"
				dbSelectArea("A007")
				dbGoTop()
				yy_Qtd   := A007->QUANT
				yy_Vlr   := A007->VALOR
				A007->(dbCloseArea())
				If yy_Qtd == 0 .and. yy_Vlr == 0
					dbSelectArea("A002")
					While !Eof() .and. df_C_F == A002->C_F .and. df_Forn == A002->B6_CLIFOR .and. df_Loja == A002->LJ .and. df_Prod == A002->PROD
						dbSkip()
					End
					Loop
				EndIf
			EndIf
			
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+A002->PROD))
			nRow1 += 025
			oPrint:Say  (nRow1 ,0075 , Alltrim(A002->PROD)+" - "+Alltrim(SB1->B1_DESC)+"  "+SB1->B1_UM     ,oFont8)
			nRow1 += 050
			dbSelectArea("A002")
			While !Eof() .and. df_C_F == A002->C_F .and. df_Forn == A002->B6_CLIFOR .and. df_Loja == A002->LJ .and. df_Prod == A002->PROD
				
				If nRow1 > 3150
					fImpRoda()
					fImpCabec()
				EndIf
				
				df_Ident := A002->B6_IDENT
				If MV_PAR11 == 1
					A0007 := " SELECT ((SELECT ISNULL(SUM(B6_QUANT), 0)
					A0007 += "            FROM " + RetSqlName("SB6")
					A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
					A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03-1)+"'
					A0007 += "             AND B6_IDENT = '"+df_Ident+"'
					A0007 += "             AND B6_PODER3 = 'R'
					A0007 += "             AND D_E_L_E_T_ = ' ') -
					A0007 += "        (SELECT ISNULL(SUM(B6_QUANT), 0)
					A0007 += "            FROM " + RetSqlName("SB6")
					A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
					A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03-1)+"'
					A0007 += "             AND B6_IDENT = '"+df_Ident+"'
					A0007 += "             AND B6_PODER3 = 'D'
					A0007 += "             AND D_E_L_E_T_ = ' ')) QUANT,
					If MV_PAR12 == 1
						A0007 += "        ((SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
					Else
						A0007 += "        ((SELECT ISNULL(SUM(B6_CUSTO1), 0)
					EndIf
					A0007 += "            FROM " + RetSqlName("SB6")
					A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
					A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03-1)+"'
					A0007 += "             AND B6_IDENT = '"+df_Ident+"'
					A0007 += "             AND B6_PODER3 = 'R'
					A0007 += "             AND D_E_L_E_T_ = ' ') -
					If MV_PAR12 == 1
						A0007 += "        (SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
					Else
						A0007 += "        (SELECT ISNULL(SUM(B6_CUSTO1), 0)
					EndIf
					A0007 += "            FROM " + RetSqlName("SB6")
					A0007 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
					A0007 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR03-1)+"'
					A0007 += "             AND B6_IDENT = '"+df_Ident+"'
					A0007 += "             AND B6_PODER3 = 'D'
					A0007 += "             AND D_E_L_E_T_ = ' ')) VALOR
					TCQUERY A0007 New Alias "A007"
					dbSelectArea("A007")
					dbGoTop()
					yy_Qtd   := A007->QUANT
					yy_Vlr   := A007->VALOR
					A007->(dbCloseArea())
					If yy_Qtd == 0 .and. yy_Vlr == 0
						dbSelectArea("A002")
						dbSkip()
						Loop
					EndIf
				EndIf
				A0003 := " SELECT ((SELECT ISNULL(SUM(B6_QUANT), 0)
				A0003 += "            FROM " + RetSqlName("SB6")
				A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
				A0003 += "             AND B6_IDENT = '"+df_Ident+"'
				A0003 += "             AND B6_PODER3 = 'R'
				A0003 += "             AND D_E_L_E_T_ = ' ') -
				A0003 += "        (SELECT ISNULL(SUM(B6_QUANT), 0)
				A0003 += "            FROM " + RetSqlName("SB6")
				A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
				A0003 += "             AND B6_IDENT = '"+df_Ident+"'
				A0003 += "             AND B6_PODER3 = 'D'
				A0003 += "             AND D_E_L_E_T_ = ' ')) QUANT,
				If MV_PAR12 == 1
					A0003 += "        ((SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
				Else
					A0003 += "        ((SELECT ISNULL(SUM(B6_CUSTO1), 0)
				EndIf
				A0003 += "            FROM " + RetSqlName("SB6")
				A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
				A0003 += "             AND B6_IDENT = '"+df_Ident+"'
				A0003 += "             AND B6_PODER3 = 'R'
				A0003 += "             AND D_E_L_E_T_ = ' ') -
				If MV_PAR12 == 1
					A0003 += "        (SELECT ISNULL(SUM(B6_PRUNIT * B6_QUANT), 0)
				Else
					A0003 += "        (SELECT ISNULL(SUM(B6_CUSTO1), 0)
				EndIf
				A0003 += "            FROM " + RetSqlName("SB6")
				A0003 += "           WHERE B6_FILIAL = '"+xFilial("SB6")+"'
				A0003 += "             AND B6_DTDIGIT < '"+dtos(MV_PAR02)+"'
				A0003 += "             AND B6_IDENT = '"+df_Ident+"'
				A0003 += "             AND B6_PODER3 = 'D'
				A0003 += "             AND D_E_L_E_T_ = ' ')) VALOR
				TCQUERY A0003 New Alias "A003"
				dbSelectArea("A003")
				dbGoTop()
				nv_Qtd   := A003->QUANT
				nv_Vlr   := A003->VALOR
				A003->(dbCloseArea())
				
				nRow1 += 025
				oPrint:Say  (nRow1 ,0075 , A002->B6_IDENT     ,oFont8)
				oPrint:Say  (nRow1 ,0075 , Padr("",103) + "Saldo Anterior:    "+IIF(nv_Qtd   <> 0  , Transform(nv_Qtd,"@E 9,999,999.9999"), "             -")+" "+IIF(nv_Vlr   <> 0  , Transform(nv_Vlr,"@E 9,999,999.9999"), "             -")     ,oFont7)
				nRow1 += 050
				
				dbSelectArea("A002")
				While !Eof() .and. df_C_F == A002->C_F .and. df_Forn == A002->B6_CLIFOR .and. df_Loja == A002->LJ .and. df_Prod == A002->PROD .and. df_Ident == A002->B6_IDENT
					
					If stod(A002->DTDIGIT) < MV_PAR02
						dbSelectArea("A002")
						dbSkip()
						Loop
					EndIf
					
					cTempo := Alltrim(ElapTime(cHInicio, Time()))
					IncProc("Imprimindo....    Tempo: "+cTempo)
					
					If nRow1 > 3150
						fImpRoda()
						fImpCabec()
					EndIf
					
					nv_Qtd   += IIF(A002->P3 == "1", A002->REM_QTQ, 0)
					nv_Vlr   += IIF(A002->P3 == "1", A002->REM_VLR, 0)
					nv_Qtd   -= IIF(A002->P3 == "2", A002->DEV_QTQ, 0)
					nv_Vlr   -= IIF(A002->P3 == "2", A002->DEV_VLR, 0)
					
					xf_Item := +;
					Padr(""                                                                         ,05)+""+;
					Padr(A002->B6_IDENT                                                             ,06)+" "+;
					Padc(A002->C_F                                                                  ,03)+" "+;
					Padc(A002->P3                                                                   ,03)+" "+;
					Padc(dtoc(stod(A002->EMISSAO))                                                  ,08)+"  "+;
					Padc(dtoc(stod(A002->DTDIGIT))                                                  ,08)+"  "+;
					Padr(A002->SERI                                                                 ,03)+"  "+;
					Padr(A002->NFISC                                                                ,09)+"  "+;
					Padr(A002->TES                                                                  ,03)+"  "+;
					Padr(A002->LC                                                                   ,02)+" "+;
					Padl(IIF(A002->P3 == "1", Transform(A002->REM_QTQ,"@E 9,999,999.9999"), "-")    ,14)+" "+;
					Padl(IIF(A002->P3 == "1", Transform(A002->REM_VLR,"@E 9,999,999.9999"), "-")    ,14)+" "+;
					Padl(IIF(A002->P3 == "2", Transform(A002->DEV_QTQ,"@E 9,999,999.9999"), "-")    ,14)+" "+;
					Padl(IIF(A002->P3 == "2", Transform(A002->DEV_VLR,"@E 9,999,999.9999"), "-")    ,14)+" "+;
					Padl(IIF(nv_Qtd   <> 0  , Transform(nv_Qtd,"@E 9,999,999.9999"), "-")           ,14)+" "+;
					Padl(IIF(nv_Vlr   <> 0  , Transform(nv_Vlr,"@E 9,999,999.9999"), "-")           ,14)
					oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont7)
					nRow1 += 050
					dbSelectArea("A002")
					dbSkip()
				End
				If nRow1 > 3150
					fImpRoda()
					fImpCabec()
				EndIf
				oPrint:Say  (nRow1 ,0050 , Padr("",105) + "Novo Saldo:        "+IIF(nv_Qtd   <> 0  , Transform(nv_Qtd,"@E 9,999,999.9999"), "             -")+" "+IIF(nv_Vlr   <> 0  , Transform(nv_Vlr,"@E 9,999,999.9999"), "             -")     ,oFont7)
				oPrint:Line (nRow1+40, 050, nRow1+40, 2350)
				nRow1 += 050
			End
		End
	End
EndIf

A002->(dbCloseArea())

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

oLogProc:LogFimProc()
Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpCabec¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

oPrint:StartPage()
wnPag ++
nRow1 := 050
If File(aBitmap)
	oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
EndIf
nRow1 += 025
sw_Perid := "Periodo: "+ dtoc(MV_PAR02) +" até " + dtoc(MV_PAR03) + "     " + IIF(MV_PAR12 == 1, "(Valor = Valor da Nota Fiscal)","(Valor = Custo Médio)")
oPrint:Say  (nRow1    ,0750 ,fCabec                                                     ,oFont14)
oPrint:Say  (nRow1+10 ,1950 ,"Página:"                                                  ,oFont7)
oPrint:Say  (nRow1+05 ,2100 ,Transform(wnPag,"@E 9999")                                 ,oFont8)
oPrint:Say  (nRow1+60 ,1950 ,"Emissão:"                                                 ,oFont7)
oPrint:Say  (nRow1+65 ,2140 ,dtoc(dDataBase)                                            ,oFont8)
oPrint:Say  (nRow1+75 ,0750 ,sw_Perid                                                   ,oFont10)
nRow1 += 150
xf_Titu := +;
Padr(""                                                                         ,05)+""+;
Padc(""                                                                         ,06)+" "+;
Padc(""                                                                         ,03)+" "+;
Padc(""                                                                         ,03)+" "+;
Padc(""                                                                         ,08)+"  "+;
Padr(""                                                                         ,08)+"  "+;
Padr(""                                                                         ,03)+"  "+;
Padr(""                                                                         ,09)+"  "+;
Padr(""                                                                         ,03)+"  "+;
Padr(""                                                                         ,02)+" "+;
Padc("Remessa"                                                                  ,29)+" "+;
Padc("Retorno"                                                                  ,29)+" "+;
Padc("Saldos"                                                                   ,29)
oPrint:Say  (nRow1 ,0050 ,xf_Titu                               ,oFont7)
nRow1 += 040
xf_Titu := +;
Padr(""                                                                         ,05)+""+;
Padr("Ident"                                                                    ,06)+" "+;
Padc("C_F"                                                                      ,03)+" "+;
Padc("P3"                                                                       ,03)+" "+;
Padc("Emissão"                                                                  ,08)+"  "+;
Padc("Entrada"                                                                  ,08)+"  "+;
Padr("Serie"                                                                    ,03)+"  "+;
Padr("N.Fiscal"                                                                 ,09)+"  "+;
Padr("TES"                                                                      ,03)+"  "+;
Padr("LC"                                                                       ,02)+" "+;
Padl("Quant"                                                                    ,14)+" "+;
Padl("Valor"                                                                    ,14)+" "+;
Padl("Quant"                                                                    ,14)+" "+;
Padl("Valor"                                                                    ,14)+" "+;
Padl("Quant"                                                                    ,14)+" "+;
Padl("Valor"                                                                    ,14)
oPrint:Say  (nRow1 ,0050 ,xf_Titu                               ,oFont7)
oPrint:Line (nRow1+40, 050, nRow1+40, 2350)
nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpRoda ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

oPrint:Line (3200, 050, 3200, 2350)
oPrint:Say  (3200+30 , 050,"Prog.: " + fPerg                                      ,oFont7)
oPrint:Say  (3200+30 ,1800,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
oPrint:EndPage()
nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Tipo                ?","","","mv_ch1","N",01,0,0,"C","","mv_par01","De Terceiros","","","","","Em Terceiros","","","","","Ambos","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","De Data             ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Ate Data            ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","De Produto          ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"05","Ate Produto         ?","","","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"06","De Clie/For         ?","","","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Ate Clie/For        ?","","","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","De Loja             ?","","","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Ate Loja            ?","","","mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Ordem de Impressao  ?","","","mv_cha","N",01,0,0,"C","","mv_par10","Fornecedor","","","","","Produto","","","","","Ident-NF","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Quanto ao Saldo     ?","","","mv_chb","N",01,0,0,"C","","mv_par11","Em Aberto","","","","","Todos","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12","Quanto ao Valor     ?","","","mv_chc","N",01,0,0,"C","","mv_par12","Da Nota Fiscal","","","","","Do Custo","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"13","Clie/For DIFERENTE  ?","","","mv_chd","C",06,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","",""})
For i := 1 to Len(aRegs)
	if !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return
