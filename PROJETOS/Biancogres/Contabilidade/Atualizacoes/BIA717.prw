#Include "Protheus.ch"
#include "topconn.ch"

User Function BIA717()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA717
Empresa   := Biancogres Cerêmicas S/A
Data      := 27/03/13
Uso       := Contabilidade / Faturamento
Aplicação := Conciliação da Comissão
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local hhi

cHInicio := Time()
fPerg := "BIA717"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

aDados2 := {}

A0001 := " SELECT SR,
A0001 += "        DOC,
A0001 += "        EMISSAO,
A0001 += "        CLIENTE,
A0001 += "        TIPO,
A0001 += "        VEND1,
A0001 += "        NOME1,
A0001 += "        VEND2,
A0001 += "        NOME2,
A0001 += "        VEND3,
A0001 += "        NOME3,
A0001 += "        VEND4,
A0001 += "        NOME4,
A0001 += "        VEND5,
A0001 += "        NOME5,
A0001 += "        VALOR_NF,
A0001 += "        DUPLIC,
A0001 += "        TIPO_VENDA,
If MV_PAR07 == 2
	A0001 += "        COMIS1,
	A0001 += "        COMIS2,
	A0001 += "        COMIS3,
	A0001 += "        COMIS4,
	A0001 += "        COMIS5,
EndIf
A0001 += "        CONTAB1,
A0001 += "        CONTAB2,
A0001 += "        CONTAB3,
A0001 += "        CONTAB4,
A0001 += "        CONTAB5
A0001 += "   FROM (SELECT F2_SERIE SR,
A0001 += "                F2_DOC DOC,
A0001 += "                F2_EMISSAO EMISSAO,
A0001 += "                A1_NOME CLIENTE,
A0001 += "                F2_TIPO TIPO,
A0001 += "                F2_VEND1 VEND1,
A0001 += "                ISNULL(SA3_1.A3_NOME, ' ') NOME1,
A0001 += "                F2_VEND2 VEND2,
A0001 += "                ISNULL(SA3_2.A3_NOME, ' ') NOME2,
A0001 += "                F2_VEND3 VEND3,
A0001 += "                ISNULL(SA3_3.A3_NOME, ' ') NOME3,
A0001 += "                F2_VEND4 VEND4,
A0001 += "                ISNULL(SA3_4.A3_NOME, ' ') NOME4,
A0001 += "                F2_VEND5 VEND5,
A0001 += "                ISNULL(SA3_5.A3_NOME, ' ') NOME5,
A0001 += "                (SELECT ROUND(SUM(D2_TOTAL),2)
A0001 += "                   FROM "+RetSqlName("SD2")+" SD2
A0001 += "                  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
A0001 += "                    AND D2_DOC = F2_DOC
A0001 += "                    AND D2_SERIE = F2_SERIE
A0001 += "                    AND D2_CLIENTE = F2_CLIENTE
A0001 += "                    AND D2_LOJA = F2_LOJA
A0001 += "                    AND D2_EMISSAO = F2_EMISSAO
A0001 += "                    AND SD2.D_E_L_E_T_ = ' ') VALOR_NF,
A0001 += "                (SELECT TOP 1 F4_DUPLIC
A0001 += "                   FROM "+RetSqlName("SD2")+" SD2
A0001 += "                  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
A0001 += "                                       AND F4_CODIGO = D2_TES
A0001 += "                                       AND SF4.D_E_L_E_T_ = ' '
A0001 += "                  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
A0001 += "                    AND D2_DOC = F2_DOC
A0001 += "                    AND D2_SERIE = F2_SERIE
A0001 += "                    AND D2_CLIENTE = F2_CLIENTE
A0001 += "                    AND D2_LOJA = F2_LOJA
A0001 += "                    AND D2_EMISSAO = F2_EMISSAO
A0001 += "                    AND SD2.D_E_L_E_T_ = ' ') DUPLIC,
A0001 += "                (SELECT TOP 1 C5_YSUBTP
A0001 += "                   FROM "+RetSqlName("SD2")+" SD2
A0001 += "                  INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"'
A0001 += "                                       AND C5_NUM = D2_PEDIDO
A0001 += "                                       AND C5_CLIENTE = D2_CLIENTE
A0001 += "                                       AND C5_LOJACLI = D2_LOJA
A0001 += "                                       AND SC5.D_E_L_E_T_ = ' '
A0001 += "                  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
A0001 += "                    AND D2_DOC = F2_DOC
A0001 += "                    AND D2_SERIE = F2_SERIE
A0001 += "                    AND D2_CLIENTE = F2_CLIENTE
A0001 += "                    AND D2_LOJA = F2_LOJA
A0001 += "                    AND D2_EMISSAO = F2_EMISSAO
A0001 += "                    AND SD2.D_E_L_E_T_ = ' ') TIPO_VENDA,
If MV_PAR07 == 2
	A0001 += "        (SELECT ROUND(SUM(D2_TOTAL * D2_COMIS1)/100,2)
	A0001 += "           FROM "+RetSqlName("SD2")+" SD2
	A0001 += "          WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	A0001 += "            AND D2_DOC = F2_DOC
	A0001 += "            AND D2_SERIE = F2_SERIE
	A0001 += "            AND D2_CLIENTE = F2_CLIENTE
	A0001 += "            AND D2_LOJA = F2_LOJA
	A0001 += "            AND D2_EMISSAO = F2_EMISSAO
	A0001 += "            AND SD2.D_E_L_E_T_ = ' ') COMIS1,
	A0001 += "        (SELECT ROUND(SUM(D2_TOTAL * D2_COMIS2)/100,2)
	A0001 += "           FROM "+RetSqlName("SD2")+" SD2
	A0001 += "          WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	A0001 += "            AND D2_DOC = F2_DOC
	A0001 += "            AND D2_SERIE = F2_SERIE
	A0001 += "            AND D2_CLIENTE = F2_CLIENTE
	A0001 += "            AND D2_LOJA = F2_LOJA
	A0001 += "            AND D2_EMISSAO = F2_EMISSAO
	A0001 += "            AND SD2.D_E_L_E_T_ = ' ') COMIS2,
	A0001 += "        (SELECT ROUND(SUM(D2_TOTAL * D2_COMIS3)/100,2)
	A0001 += "           FROM "+RetSqlName("SD2")+" SD2
	A0001 += "          WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	A0001 += "            AND D2_DOC = F2_DOC
	A0001 += "            AND D2_SERIE = F2_SERIE
	A0001 += "            AND D2_CLIENTE = F2_CLIENTE
	A0001 += "            AND D2_LOJA = F2_LOJA
	A0001 += "            AND D2_EMISSAO = F2_EMISSAO
	A0001 += "            AND SD2.D_E_L_E_T_ = ' ') COMIS3,
	A0001 += "        (SELECT ROUND(SUM(D2_TOTAL * D2_COMIS4)/100,2)
	A0001 += "           FROM "+RetSqlName("SD2")+" SD2
	A0001 += "          WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	A0001 += "            AND D2_DOC = F2_DOC
	A0001 += "            AND D2_SERIE = F2_SERIE
	A0001 += "            AND D2_CLIENTE = F2_CLIENTE
	A0001 += "            AND D2_LOJA = F2_LOJA
	A0001 += "            AND D2_EMISSAO = F2_EMISSAO
	A0001 += "            AND SD2.D_E_L_E_T_ = ' ') COMIS4,
	A0001 += "        (SELECT ROUND(SUM(D2_TOTAL * D2_COMIS5)/100,2)
	A0001 += "           FROM "+RetSqlName("SD2")+" SD2
	A0001 += "          WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	A0001 += "            AND D2_DOC = F2_DOC
	A0001 += "            AND D2_SERIE = F2_SERIE
	A0001 += "            AND D2_CLIENTE = F2_CLIENTE
	A0001 += "            AND D2_LOJA = F2_LOJA
	A0001 += "            AND D2_EMISSAO = F2_EMISSAO
	A0001 += "            AND SD2.D_E_L_E_T_ = ' ') COMIS5,
EndIf
A0001 += "                ISNULL((SELECT SUM(CT2_VALOR)
A0001 += "                          FROM "+RetSqlName("CT2")+" CT2
A0001 += "                         WHERE CT2_FILIAL = '"+xFilial("CT2")+"'
A0001 += "                           AND CT2_DATA = F2_EMISSAO
A0001 += "                           AND CT2_HIST LIKE '%' + '' + RTRIM(F2_DOC) + '' + '%'
A0001 += "                           AND CT2_CREDIT = '21106003'
A0001 += "                           AND CT2_ITEMC = 'COM' + F2_VEND1
A0001 += "                           AND CT2.D_E_L_E_T_ = ' '), 0) CONTAB1,
A0001 += "                ISNULL((SELECT SUM(CT2_VALOR)
A0001 += "                          FROM "+RetSqlName("CT2")+" CT2
A0001 += "                         WHERE CT2_FILIAL = '"+xFilial("CT2")+"'
A0001 += "                           AND CT2_DATA = F2_EMISSAO
A0001 += "                           AND CT2_HIST LIKE '%' + '' + RTRIM(F2_DOC) + '' + '%'
A0001 += "                           AND CT2_CREDIT = '21106003'
A0001 += "                           AND CT2_ITEMC = 'COM' + F2_VEND2
A0001 += "                           AND CT2.D_E_L_E_T_ = ' '), 0) CONTAB2,
A0001 += "                ISNULL((SELECT SUM(CT2_VALOR)
A0001 += "                          FROM "+RetSqlName("CT2")+" CT2
A0001 += "                         WHERE CT2_FILIAL = '"+xFilial("CT2")+"'
A0001 += "                           AND CT2_DATA = F2_EMISSAO
A0001 += "                           AND CT2_HIST LIKE '%' + '' + RTRIM(F2_DOC) + '' + '%'
A0001 += "                           AND CT2_CREDIT = '21106003'
A0001 += "                           AND CT2_ITEMC = 'COM' + F2_VEND3
A0001 += "                           AND CT2.D_E_L_E_T_ = ' '), 0) CONTAB3,
A0001 += "                ISNULL((SELECT SUM(CT2_VALOR)
A0001 += "                          FROM "+RetSqlName("CT2")+" CT2
A0001 += "                         WHERE CT2_FILIAL = '"+xFilial("CT2")+"'
A0001 += "                           AND CT2_DATA = F2_EMISSAO
A0001 += "                           AND CT2_HIST LIKE '%' + '' + RTRIM(F2_DOC) + '' + '%'
A0001 += "                           AND CT2_CREDIT = '21106003'
A0001 += "                           AND CT2_ITEMC = 'COM' + F2_VEND4
A0001 += "                           AND CT2.D_E_L_E_T_ = ' '), 0) CONTAB4,
A0001 += "                ISNULL((SELECT SUM(CT2_VALOR)
A0001 += "                          FROM "+RetSqlName("CT2")+" CT2
A0001 += "                         WHERE CT2_FILIAL = '"+xFilial("CT2")+"'
A0001 += "                           AND CT2_DATA = F2_EMISSAO
A0001 += "                           AND CT2_HIST LIKE '%' + '' + RTRIM(F2_DOC) + '' + '%'
A0001 += "                           AND CT2_CREDIT = '21106003'
A0001 += "                           AND CT2_ITEMC = 'COM' + F2_VEND5
A0001 += "                           AND CT2.D_E_L_E_T_ = ' '), 0) CONTAB5
A0001 += "           FROM "+RetSqlName("SF2")+" SF2
A0001 += "           LEFT JOIN "+RetSqlName("SA3")+" SA3_1 ON SA3_1.A3_FILIAL = '"+xFilial("SA3")+"'
A0001 += "                                 AND SA3_1.A3_COD = F2_VEND1
A0001 += "                                 AND SA3_1.D_E_L_E_T_ = ' '
A0001 += "           LEFT JOIN "+RetSqlName("SA3")+" SA3_2 ON SA3_2.A3_FILIAL = '"+xFilial("SA3")+"'
A0001 += "                                 AND SA3_2.A3_COD = F2_VEND2
A0001 += "                                 AND SA3_2.D_E_L_E_T_ = ' '
A0001 += "           LEFT JOIN "+RetSqlName("SA3")+" SA3_3 ON SA3_3.A3_FILIAL = '"+xFilial("SA3")+"'
A0001 += "                                 AND SA3_3.A3_COD = F2_VEND3
A0001 += "                                 AND SA3_3.D_E_L_E_T_ = ' '
A0001 += "           LEFT JOIN "+RetSqlName("SA3")+" SA3_4 ON SA3_4.A3_FILIAL = '"+xFilial("SA3")+"'
A0001 += "                                 AND SA3_4.A3_COD = F2_VEND4
A0001 += "                                 AND SA3_4.D_E_L_E_T_ = ' '
A0001 += "           LEFT JOIN "+RetSqlName("SA3")+" SA3_5 ON SA3_5.A3_FILIAL = '"+xFilial("SA3")+"'
A0001 += "                                 AND SA3_5.A3_COD = F2_VEND5
A0001 += "                                 AND SA3_5.D_E_L_E_T_ = ' '
A0001 += "           LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"'
A0001 += "                               AND SA1.A1_COD = F2_CLIENTE
A0001 += "                               AND SA1.A1_LOJA = F2_LOJA
A0001 += "                               AND SA1.D_E_L_E_T_ = ' '
A0001 += "          WHERE F2_FILIAL = '"+xFilial("SF2")+"'
A0001 += "            AND F2_EMISSAO >= '20130101'
A0001 += "            AND F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
A0001 += "            AND F2_DOC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
A0001 += "            AND F2_SERIE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
A0001 += "            AND F2_TIPO NOT IN( 'B', 'D' )
A0001 += "            AND SF2.D_E_L_E_T_ = ' ') AS TABELA
A0001 += "  WHERE CONTAB1 + CONTAB2 + CONTAB3 + CONTAB4 + CONTAB5 > 0
TcQuery A0001 New Alias "A001"
dbSelectArea("A001")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc(A001->SR + " " + A001->DOC)
	
	If MV_PAR07 == 1
		
		aAdd(aDados2, { A001->SR,;
		A001->DOC,;
		dtoc(stod(A001->EMISSAO)),;
		A001->CLIENTE,;
		A001->TIPO,;
		A001->VEND1,;
		A001->NOME1,;
		A001->VEND2,;
		A001->NOME2,;
		A001->VEND3,;
		A001->NOME3,;
		A001->VEND4,;
		A001->NOME4,;
		A001->VEND5,;
		A001->NOME5,;
		Transform(A001->VALOR_NF ,"@E 999,999,999.9999"),;
		A001->DUPLIC,;
		A001->TIPO_VENDA,;
		Transform(A001->CONTAB1  ,"@E 999,999,999.9999"),;
		Transform(A001->CONTAB2  ,"@E 999,999,999.9999"),;
		Transform(A001->CONTAB3  ,"@E 999,999,999.9999"),;
		Transform(A001->CONTAB4  ,"@E 999,999,999.9999"),;
		Transform(A001->CONTAB5  ,"@E 999,999,999.9999")} )
	Else
		aAdd(aDados2, { A001->SR,;
		A001->DOC,;
		dtoc(stod(A001->EMISSAO)),;
		A001->CLIENTE,;
		A001->TIPO,;
		A001->VEND1,;
		A001->NOME1,;
		A001->VEND2,;
		A001->NOME2,;
		A001->VEND3,;
		A001->NOME3,;
		A001->VEND4,;
		A001->NOME4,;
		A001->VEND5,;
		A001->NOME5,;
		Transform(A001->VALOR_NF ,"@E 999,999,999.9999"),;
		A001->DUPLIC,;
		A001->TIPO_VENDA,;
		Transform(A001->COMIS1   ,"@E 999,999,999.9999"),;
		Transform(A001->COMIS2   ,"@E 999,999,999.9999"),;
		Transform(A001->COMIS3   ,"@E 999,999,999.9999"),;
		Transform(A001->COMIS4   ,"@E 999,999,999.9999"),;
		Transform(A001->COMIS5   ,"@E 999,999,999.9999"),;
		Transform(A001->CONTAB1  ,"@E 999,999,999.9999"),;
		Transform(A001->CONTAB2  ,"@E 999,999,999.9999"),;
		Transform(A001->CONTAB3  ,"@E 999,999,999.9999"),;
		Transform(A001->CONTAB4  ,"@E 999,999,999.9999"),;
		Transform(A001->CONTAB5  ,"@E 999,999,999.9999")} )
	EndIf
	
	dbSelectArea("A001")
	dbSkip()
	
End
aStru1 := ("A001")->(dbStruct())

A001->(dbCloseArea())

U_BIAxExcel(aDados2, aStru1, "BIA717"+strzero(seconds()%3500,5) )

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
aAdd(aRegs,{cPerg,"01","De Emissao          ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Emissao         ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","De Nota             ?","","","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Ate Nota            ?","","","mv_ch4","C",09,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","De Serie            ?","","","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Ate Serie           ?","","","mv_ch6","C",03,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Setor               ?","","","mv_ch7","N",01,0,0,"C","","mv_par07","Comercial","","","","","Contábil","","","","","","","","","","","","","","","","","","",""})

For i := 1 to Len(aRegs)
	If !dbSeek(cPerg + aRegs[i,2])
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
