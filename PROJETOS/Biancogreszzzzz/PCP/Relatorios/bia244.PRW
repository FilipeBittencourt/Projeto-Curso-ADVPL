#include "rwmake.ch"
#include "ap5mail.ch"
#include "TOTVS.CH"
#include "topconn.ch"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} BIA244
@author Marcos Alberto Soprani
@since 14/09/12
@description Resumo de Produção
@type function
/*/

User Function BIA244()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	fPerg := "BIA244"
	ktNomArq := "producao"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	kt_BsDad := ""
	If cEmpAnt == "01"
		kt_BsDad := "DADOSEOS"
	ElseIf cEmpAnt == "05"
		kt_BsDad := "DADOS_05_EOS"
	Else
		// Acompanhar possíveis impactos nos resultados
	EndIf

	aDados2 := {}

	If dtos(MV_PAR02) <= '20150531' .or. cEmpAnt == "14"

		A0001 := " SELECT D3_EMISSAO EMISSAO,
		A0001 += "        D3_YDIMPOR DIMPORT,
		A0001 += "        SUBSTRING(CODIGO,1,7) CODIGO,
		A0001 += "        ISNULL(SUBSTRING(XB1.B1_DESC,1,50), SUBSTRING(SB1.B1_DESC,1,50)) DESCR,
		A0001 += "        ISNULL(XB1.B1_YFORMAT, SB1.B1_YFORMAT) FORMATO,
		A0001 += "        ZZ7_TIPO TIPOLOGIA,
		A0001 += "        D3_LOTECTL LOTE,
		A0001 += "        TURNO,
		A0001 += "        FORNO,
		A0001 += "        QUANT,
		A0001 += "        (SELECT RTRIM(ZZ8_DESC)
		A0001 += "           FROM " + RetSqlName("ZZ8") + " WITH (NOLOCK)
		A0001 += "          WHERE ZZ8_FILIAL = '"+xFilial("ZZ8")+"'
		A0001 += "            AND ZZ8_COD = SB1.B1_YCLASSE
		A0001 += "            AND D_E_L_E_T_ = ' ') CLASSE,
		A0001 += "        (SELECT TOP 1 ZZ9_RESTRI + ZZ9_MOTIVO 
		A0001 += "           FROM " + RetSqlName("ZZ9") + " WITH (NOLOCK)
		A0001 += "          WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
		A0001 += "            AND ZZ9_PRODUT = CODIGO
		A0001 += "            AND ZZ9_LOTE = D3_LOTECTL
		A0001 += "            AND D_E_L_E_T_ = ' ') RETRIC,
		A0001 += "        Z33_DESCR ACABAMENTO,
		A0001 += "        (SELECT TOP 1 ZZ9_PESO
		A0001 += "           FROM " + RetSqlName("ZZ9") + " WITH (NOLOCK)
		A0001 += "          WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
		A0001 += "            AND ZZ9_PRODUT = CODIGO
		A0001 += "            AND ZZ9_LOTE = D3_LOTECTL
		A0001 += "            AND D_E_L_E_T_ = ' ') PESO_LOTE,
		A0001 += "        D3_YEMPLIB DTDISPO,
		A0001 += "        SUBSTRING(D3_OP, 1, 6) AS OP,
		A0001 += "        '' MOTIVO  		
		A0001 += "   FROM (SELECT CODIGO,
		A0001 += "                D3_EMISSAO,
		A0001 += "                D3_YDIMPOR,
		A0001 += "                D3_YEMPLIB,
		A0001 += "                D3_LOTECTL,
		A0001 += "                TURNO,
		A0001 += "                FORNO,
		A0001 += "                SUM(QUANT) QUANT,
		A0001 += "                D3_OP
		A0001 += "           FROM (SELECT D3_COD CODIGO,
		A0001 += "                        D3_EMISSAO,
		A0001 += "                        D3_YDIMPOR,
		A0001 += "                        D3_YEMPLIB,
		A0001 += "                        D3_LOTECTL,
		A0001 += "                        CASE
		A0001 += "                          WHEN D3_TM > '500' THEN D3_QUANT * ( -1 )
		A0001 += "                          ELSE D3_QUANT
		A0001 += "                        END QUANT, 
		A0001 += "                        D3_OP,
		If !Empty(kt_BsDad)
			A0001 += "                        ce_turno TURNO,
			A0001 += "                        ce_forno FORNO
		Else
			A0001 += "                        ' ' TURNO,
			A0001 += "                        ' ' FORNO
		EndIf
		A0001 += "                   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)		
		If !Empty(kt_BsDad)
			A0001 += "                   LEFT JOIN "+kt_BsDad+"..CEP_MOVIMENTO_PRODUTO A ON ID_MOV_PROD = D3_YIDECO
		EndIf
		A0001 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "                    AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
		A0001 += "                    AND ( D3_TM IN( '500', '501' ) OR D3_YORIMOV = 'PR0' OR (D3_EMISSAO >= '20140101' AND D3_TIPO = 'PA' AND D3_TM IN('010','711')) )
		A0001 += "                    AND D3_ESTORNO = ' '
		A0001 += "                    AND SD3.D_E_L_E_T_ = ' ') AS REQUIS
		A0001 += "          GROUP BY CODIGO,
		A0001 += "                   D3_EMISSAO,
		A0001 += "                   D3_YDIMPOR,
		A0001 += "                   D3_YEMPLIB,
		A0001 += "                   D3_LOTECTL,
		A0001 += "                   TURNO,
		A0001 += "                   FORNO, 
		A0001 += "               		 D3_OP) AS REQFIM
		A0001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
		A0001 += "                       AND SB1.B1_COD = CODIGO
		A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0001 += "   LEFT JOIN "+RetSqlName("SB1")+" XB1 ON XB1.B1_FILIAL = '"+xFilial("SB1")+"'
		A0001 += "                       AND XB1.B1_COD = SUBSTRING(CODIGO,1,7)+'        '
		A0001 += "                       AND XB1.D_E_L_E_T_ = ' '
		A0001 += "   LEFT JOIN "+RetSqlName("ZZ7")+" ZZ7 ON ZZ7_FILIAL = '"+xFilial("ZZ7")+"'
		A0001 += "                       AND ZZ7_COD = SB1.B1_YLINHA
		A0001 += "                       AND ZZ7_LINSEQ = SB1.B1_YLINSEQ
		A0001 += "                       AND ZZ7.D_E_L_E_T_ = ' '
		A0001 += "  INNER JOIN "+RetSqlName("Z33")+" Z33 ON Z33.Z33_FILIAL = '"+xFilial("Z33")+"'
		A0001 += "                       AND Z33.Z33_CODIGO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
		A0001 += "                       AND Z33.Z33_CODIGO = SB1.B1_YACABAM
		A0001 += "                       AND Z33.D_E_L_E_T_ = ' '
		A0001 += "  WHERE QUANT <> 0

	Else

		KP003 := " SELECT ROUND(SUM(QUANT), 2) QUANT
		KP003 += "   FROM (SELECT SUM(QUANT) QUANT
		KP003 += "           FROM (SELECT Z18_TM,
		KP003 += "                        CASE
		KP003 += "                          WHEN Z18_TM = 'PR0' THEN SUM(Z18_QUANT)
		KP003 += "                          ELSE SUM(Z18_QUANT) * (-1)
		KP003 += "                        END QUANT
		KP003 += "                   FROM " + RetSqlName("Z18")
		KP003 += "                  WHERE Z18_FILIAL = '"+xFilial("Z18")+"'
		KP003 += "                    AND Z18_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		KP003 += "                    AND Z18_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
		KP003 += "                    AND Z18_TM NOT IN('REP','TRF')
		KP003 += "                    AND D_E_L_E_T_ = ' '
		KP003 += "                  GROUP BY Z18_TM) AS TABLW
		KP003 += "          UNION ALL
		KP003 += "         SELECT SUM(QUANT) * (-1) QUANT
		KP003 += "           FROM (SELECT D3_TM,
		KP003 += "                        CASE
		KP003 += "                          WHEN D3_TM = '010' THEN SUM(D3_QUANT)
		KP003 += "                          ELSE SUM(D3_QUANT) * (-1)
		KP003 += "                        END QUANT
		KP003 += "                   FROM " + RetSqlName("SD3")
		KP003 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		KP003 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		KP003 += "                    AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
		KP003 += "                    AND D3_TIPO = 'PA'
		KP003 += "                    AND D3_TM IN('010','711')
		KP003 += "                    AND D3_ESTORNO = ' '
		KP003 += "                    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
		KP003 += "                    AND D_E_L_E_T_ = ' '
		KP003 += "                  GROUP BY D3_TM) AS TABLW) TABLT
		KPIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,KP003),'KP03',.T.,.T.)
		dbSelectArea("KP03")
		dbGoTop()
		kpQtd := KP03->QUANT
		KP03->(dbCloseArea())
		Ferase(KPIndex+GetDBExtension())
		Ferase(KPIndex+OrdBagExt())
		If kpQtd == 0

			A0001 := " SELECT Z18_DATA EMISSAO,
			A0001 += "        Z18_DTCANC DIMPORT,
			A0001 += "        SUBSTRING(CODIGO,1,7) CODIGO,
			A0001 += "        ISNULL(SUBSTRING(XB1.B1_DESC,1,50), SUBSTRING(SB1.B1_DESC,1,50)) DESCR,
			A0001 += "        ISNULL(XB1.B1_YFORMAT, SB1.B1_YFORMAT) FORMATO,
			A0001 += "        ZZ7_TIPO TIPOLOGIA,
			A0001 += "        CE_LOTE LOTE,
			A0001 += "        TURNO,
			A0001 += "        FORNO,
			A0001 += "        QUANT,
			A0001 += "        (SELECT RTRIM(ZZ8_DESC)
			A0001 += "           FROM " + RetSqlName("ZZ8") + " WITH (NOLOCK)
			A0001 += "          WHERE ZZ8_FILIAL = '"+xFilial("ZZ8")+"'
			A0001 += "            AND ZZ8_COD = SB1.B1_YCLASSE
			A0001 += "            AND D_E_L_E_T_ = ' ') CLASSE,
			A0001 += "        (SELECT TOP 1 ZZ9_RESTRI + ZZ9_MOTIVO
			A0001 += "           FROM " + RetSqlName("ZZ9") + " WITH (NOLOCK)
			A0001 += "          WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
			A0001 += "            AND ZZ9_PRODUT = CODIGO
			A0001 += "            AND ZZ9_LOTE = CE_LOTE COLLATE Latin1_General_BIN
			A0001 += "            AND D_E_L_E_T_ = ' ') RETRIC,
			A0001 += "        Z33_DESCR ACABAMENTO,
			A0001 += "        (SELECT TOP 1 ZZ9_PESO
			A0001 += "           FROM " + RetSqlName("ZZ9") + " WITH (NOLOCK)
			A0001 += "          WHERE ZZ9_FILIAL = '"+xFilial("ZZ9")+"'
			A0001 += "            AND ZZ9_PRODUT = CODIGO
			A0001 += "            AND ZZ9_LOTE = CE_LOTE COLLATE Latin1_General_BIN
			A0001 += "            AND D_E_L_E_T_ = ' ') PESO_LOTE,
			A0001 += "        Z18_YEMPLI DTDISPO,
			A0001 += "        SUBSTRING(D3_OP, 1, 6) AS OP,
			A0001 += "        '' MOTIVO 
			A0001 += "   FROM (SELECT CODIGO,
			A0001 += "                Z18_DATA,
			A0001 += "                Z18_DTCANC,
			A0001 += "                Z18_YEMPLI,
			A0001 += "                CE_LOTE,
			A0001 += "                TURNO,
			A0001 += "                FORNO,
			A0001 += "                SUM(QUANT) QUANT, D3_OP
			A0001 += "           FROM (SELECT Z18_COD CODIGO,
			A0001 += "                        Z18_DATA,
			A0001 += "                        Z18_DTCANC,
			A0001 += "                        Z18_YEMPLI,
			A0001 += "                        CE_LOTE,
			A0001 += "                        CASE
			A0001 += "                          WHEN Z18_TM = 'EST' THEN Z18_QUANT * ( -1 )
			A0001 += "                          ELSE Z18_QUANT
			A0001 += "                        END QUANT,
			A0001 += "                        ce_turno TURNO,
			A0001 += "                        ce_forno FORNO, D3_OP
			A0001 += "                   FROM "+RetSqlName("Z18")+" Z18 WITH (NOLOCK)			
			A0001 += "                   INNER JOIN " + RetSqlName("SD3") + " SD3 WITH (NOLOCK) ON D3_FILIAL = " + ValToSQL(xFilial("SD3"))
			A0001 += "                                                     AND D3_COD = Z18_COD
			A0001 += "                                                     AND D3_NUMSEQ = Z18_NSQSD3
			A0001 += "                                                     AND D3_TM IN('010','711')
			A0001 += "                                                     AND D3_ESTORNO = ' '
			A0001 += "                                                     AND SD3.D_E_L_E_T_ = ' '						
			A0001 += "                   LEFT JOIN "+kt_BsDad+"..CEP_MOVIMENTO_PRODUTO A ON CE_NUMERO_DOCTO = Z18_NUMETQ
			A0001 += "                                                               AND COD_TRANSACAO IN('1','20')
			A0001 += "                                                               AND CE_DOCTO <> 'SA'
			A0001 += "                  WHERE Z18_FILIAL = '"+xFilial("Z18")+"' 
			A0001 += "                    AND Z18_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
			A0001 += "                    AND Z18_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
			A0001 += "                    AND Z18_TM NOT IN('REP','TRF')
			A0001 += "                    AND Z18_NUMETQ NOT IN (SELECT XXX.Z18_NUMETQ
			A0001 += "                                             FROM " + RetSqlName("Z18") + " XXX
			A0001 += "                                            WHERE XXX.Z18_FILIAL = '" + xFilial("Z18") + "'
			A0001 += "                                              AND XXX.Z18_DATA = Z18.Z18_DATA
			A0001 += "                                              AND XXX.Z18_COD = Z18.Z18_COD
			A0001 += "                                              AND XXX.Z18_TM = 'EST'
			A0001 += "                                              AND XXX.D_E_L_E_T_ = ' ' )
			A0001 += "                    AND Z18.D_E_L_E_T_ = ' '
			A0001 += "                    ) AS REQUIS
			A0001 += "          GROUP BY CODIGO,
			A0001 += "                   Z18_DATA,
			A0001 += "                   Z18_DTCANC,
			A0001 += "                   Z18_YEMPLI,
			A0001 += "                   CE_LOTE,
			A0001 += "                   TURNO,
			A0001 += "                   FORNO,
			A0001 += "                   D3_OP) AS REQFIM
			A0001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
			A0001 += "                       AND SB1.B1_COD = CODIGO
			A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
			A0001 += "   LEFT JOIN "+RetSqlName("SB1")+" XB1 ON XB1.B1_FILIAL = '"+xFilial("SB1")+"'
			A0001 += "                       AND XB1.B1_COD = SUBSTRING(CODIGO,1,7)+'        '
			A0001 += "                       AND XB1.D_E_L_E_T_ = ' '
			A0001 += "   LEFT JOIN "+RetSqlName("ZZ7")+" ZZ7 ON ZZ7_FILIAL = '"+xFilial("ZZ7")+"'
			A0001 += "                       AND ZZ7_COD = SB1.B1_YLINHA
			A0001 += "                       AND ZZ7_LINSEQ = SB1.B1_YLINSEQ
			A0001 += "                       AND ZZ7.D_E_L_E_T_ = ' '
			A0001 += "  INNER JOIN "+RetSqlName("Z33")+" Z33 ON Z33.Z33_FILIAL = '"+xFilial("Z33")+"'
			A0001 += "                       AND Z33.Z33_CODIGO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
			A0001 += "                       AND Z33.Z33_CODIGO = SB1.B1_YACABAM
			A0001 += "                       AND Z33.D_E_L_E_T_ = ' '
			A0001 += "  WHERE QUANT <> 0

		Else

			Aviso('Divergência', 'A soma das quantidades do apontamento aglutinado versus a soma da quantidade das etiquetas registradas no controle auxiliar de etiqueta não estão batendo. Favor verificar...',{'Ok'})
			Return

		EndIf


	EndIf

	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		aAdd(aDados2, { dtoc(stod(A001->EMISSAO))              ,;
		dtoc(stod(A001->DIMPORT))                              ,;
		A001->CODIGO                                           ,;
		A001->DESCR                                            ,;
		A001->FORMATO                                          ,;
		A001->TIPOLOGIA                                        ,;
		A001->LOTE                                             ,;
		A001->TURNO                                            ,;
		A001->FORNO                                            ,;
		Transform(A001->QUANT  ,"@E 999,999,999.9999")         ,;
		A001->CLASSE                                           ,;
		Substr(A001->RETRIC,1,1)                               ,;
		A001->ACABAMENTO                                       ,;
		Transform(A001->PESO_LOTE  ,"@E 999,999,999.9999")     ,;
		dtoc(stod(A001->DTDISPO))                              ,;
		A001->OP                                       	       ,;
		Substr(A001->RETRIC,2,75)                              })

		dbSelectArea("A001")
		dbSkip()

	End

	aStru1 := ("A001")->(dbStruct())
	A001->(dbCloseArea())

	U_BIAxExcel(aDados2, aStru1, ktNomArq+strzero(seconds()%3500,5) )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 14/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Produto          ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"04","Ate Produto         ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"05","Do Acabamento       ?","","","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","Z33"})
	aAdd(aRegs,{cPerg,"06","Ate Acabamento      ?","","","mv_ch6","C",03,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","Z33"})
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
