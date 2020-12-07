#Include "Protheus.ch"
#include "topconn.ch"

User Function BIA281()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA281
Empresa   := Biancogres Cerêmicas S/A
Data      := 16/02/12
Uso       := Gestão de Pessoal / Contabilidade
Aplicação := Conciliação da Contabilização Rateada
.            Se for feita alguma alteração neste programa tem que se aten-
.           tar ao programa BIA278
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local hhi

If cEmpAnt <> "01"
	MsgSTOP("Esta rotina somente está diponível para a empresa " + Alltrim(SM0->M0_NOME) )
	Return
EndIf

cHInicio := Time()
fPerg := "BIA281"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

aDados2 := {}

/*
A0001 := " SELECT SRZ.R_E_C_N_O_ REGSRZ,
A0001 += "        RV_LCTOP ORI_LAN,
A0001 += "        RZ_CC CC,
A0001 += "        RZ_PD VERBA,
A0001 += "        RZ_MAT MATR,
A0001 += "        RA_CODFUNC,
A0001 += "        RJ_DESC,
A0001 += "        RZ_VAL VALOR,
A0001 += "        ISNULL((SELECT Z14_PERC
A0001 += " 	       	        FROM " + RetSqlName("Z14")
A0001 += " 		             WHERE Z14_FILIAL = '"+xFilial("Z14")+"'
A0001 += " 		               AND Z14_CODREF = RA_CODFUNC
A0001 += " 		               AND Z14_EMPR = '0101'
A0001 += " 		               AND '"+dtos(MV_PAR01)+"' >= Z14_DTINI
A0001 += " 		               AND '"+dtos(MV_PAR01)+"' <= Z14_DTFIN
A0001 += " 		               AND (SUBSTRING(RZ_CC,1,1) = '1' OR RTRIM(RZ_CC) IN('4050','4080') )
A0001 += " 		               AND D_E_L_E_T_ = ' '), 100) PERC_EMP01,
A0001 += "        ISNULL((SELECT Z14_PERC
A0001 += " 	       	        FROM " + RetSqlName("Z14")
A0001 += " 		             WHERE Z14_FILIAL = '"+xFilial("Z14")+"'
A0001 += " 		               AND Z14_CODREF = RA_CODFUNC
A0001 += " 		               AND Z14_EMPR = '0501'
A0001 += " 		               AND '"+dtos(MV_PAR01)+"' >= Z14_DTINI
A0001 += " 		               AND '"+dtos(MV_PAR01)+"' <= Z14_DTFIN
A0001 += " 		               AND (SUBSTRING(RZ_CC,1,1) = '1' OR RTRIM(RZ_CC) IN('4050','4080') )
A0001 += " 		               AND D_E_L_E_T_ = ' '), 0) PERC_EMP05,
A0001 += " 	   0 BIANCO,
A0001 += " 	   0 INCESA,
A0001 += " 	   (SELECT CT5_DEBITO
A0001 += " 	      FROM " + RetSqlName("CT5")
A0001 += " 	     WHERE CT5_FILIAL = '"+xFilial("CT5")+"'
A0001 += " 	       AND CT5_LANPAD = RV_LCTOP
A0001 += " 	       AND CT5_SEQUEN = '001'
A0001 += " 	       AND D_E_L_E_T_ = ' ') CTA_DEB_01,
A0001 += " 	   (SELECT CT5_CREDIT
A0001 += " 	      FROM " + RetSqlName("CT5")
A0001 += " 	     WHERE CT5_FILIAL = '"+xFilial("CT5")+"'
A0001 += " 	       AND CT5_LANPAD = RV_LCTOP
A0001 += " 	       AND CT5_SEQUEN = '001'
A0001 += " 	       AND D_E_L_E_T_ = ' ') CTA_CRD_01
A0001 += "   FROM "+RetSqlname("SRZ")+" SRZ
A0001 += "  INNER JOIN "+RetSqlname("SRV")+" SRV ON RV_FILIAL = '"+xFilial("SRV")+"'
A0001 += "                       AND RV_COD = RZ_PD
A0001 += "                       AND RV_LCTOP <> '   '
A0001 += "                       AND SRV.D_E_L_E_T_ = ' '
A0001 += "  INNER JOIN "+RetSqlname("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
A0001 += "                       AND RA_MAT = RZ_MAT
A0001 += "                       AND SRA.D_E_L_E_T_ = ' '
A0001 += "   LEFT JOIN "+RetSqlname("SRJ")+" SRJ ON RJ_FILIAL = '"+xFilial("SRJ")+"'
A0001 += "                       AND RJ_FUNCAO = RA_CODFUNC
A0001 += "                       AND SRJ.D_E_L_E_T_ = ' '
A0001 += "  WHERE RZ_FILIAL = '"+xFilial("SRZ")+"'
A0001 += "    AND RZ_MAT <> 'zzzzzz'
A0001 += "    AND RZ_CC <> 'zzzzzzzzz'
A0001 += "    AND RZ_PD <> 'zzz'
A0001 += "    AND (SUBSTRING(RZ_CC,1,1) = '1' OR RTRIM(RZ_CC) IN('4050','4080'))
A0001 += "    AND RZ_PD BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'
A0001 += "    AND SRZ.D_E_L_E_T_ = ' '
*/

If Substr(dtos(MV_PAR02), 1, 6) <= "201312"
	
	A0001 := " SELECT CASE
	A0001 += "          WHEN SUBSTRING(ORI_DEB,1,1) = '3' THEN ORI_DEB
	A0001 += "          WHEN SUBSTRING(ORI_CRD,1,1) = '3' THEN ORI_CRD
	A0001 += "          ELSE
	A0001 += "            CASE
	A0001 += "              WHEN CT2_DEBITO = '11205010            ' THEN CT2_DEBITO
	A0001 += "              WHEN CT2_CREDIT = '11205010            ' THEN CT2_CREDIT
	A0001 += "              ELSE '                    '
	A0001 += "            END
	A0001 += "        END CONTA,
	A0001 += "        CASE
	A0001 += "          WHEN SUBSTRING(ORI_DEB,1,1) = '3' THEN CT2_CLVLDB
	A0001 += "          WHEN SUBSTRING(ORI_CRD,1,1) = '3' THEN CT2_CLVLCR
	A0001 += "          ELSE ' '
	A0001 += "        END CLVL,
	A0001 += "        CASE
	A0001 += "          WHEN SUBSTRING(ORI_DEB,1,1) = '3' THEN CT2_VALOR
	A0001 += "          ELSE
	A0001 += "            CASE
	A0001 += "              WHEN CT2_DEBITO = '11205010            ' THEN CT2_VALOR
	A0001 += "              ELSE 0
	A0001 += "            END
	A0001 += "        END VLR_DEB,
	A0001 += "        CASE
	A0001 += "          WHEN SUBSTRING(ORI_CRD,1,1) = '3' THEN CT2_VALOR * (-1)
	A0001 += "          ELSE
	A0001 += "            CASE
	A0001 += "              WHEN CT2_CREDIT = '11205010            ' THEN CT2_VALOR * (-1)
	A0001 += "              ELSE 0
	A0001 += "            END
	A0001 += "        END VLR_CRD,
	A0001 += "        CASE
	A0001 += "          WHEN CT2_DEBITO = '11205010            ' THEN CT2_DEBITO
	A0001 += "          WHEN CT2_CREDIT = '11205010            ' THEN CT2_CREDIT
	A0001 += "          ELSE '                    '
	A0001 += "        END INTRAGRUPO,
	A0001 += "        *
	A0001 += "   FROM (SELECT CT2_LOTE,
	A0001 += "                CT2_DEBITO,
	A0001 += "                CT2_CREDIT,
	A0001 += "                CT2_VALOR,
	A0001 += "                CT2_HIST,
	A0001 += "                SUBSTRING(CT2_ORIGEM, 1, 10) ORIG,
	A0001 += "                CT2_LP,
	A0001 += "                CT2_CLVLDB,
	A0001 += "                CT2_CLVLCR,
	A0001 += "                CASE
	A0001 += "                  WHEN CT2_DEBITO = '11205010            ' THEN (SELECT XCT2.CT2_DEBITO
	A0001 += "                                                                   FROM "+RetSqlName("CT2")+" XCT2
	A0001 += "                                                                  WHERE XCT2.CT2_FILIAL = '01'
	A0001 += "                                                                    AND XCT2.R_E_C_N_O_ = CT2.R_E_C_N_O_ - 1
	A0001 += "                                                                    AND XCT2.D_E_L_E_T_ = ' ')
	A0001 += "                  ELSE CT2_DEBITO
	A0001 += "                END ORI_DEB,
	A0001 += "                CASE
	A0001 += "                  WHEN CT2_CREDIT = '11205010            ' THEN (SELECT XCT2.CT2_CREDIT
	A0001 += "                                                                   FROM "+RetSqlName("CT2")+" XCT2
	A0001 += "                                                                  WHERE XCT2.CT2_FILIAL = '01'
	A0001 += "                                                                    AND XCT2.R_E_C_N_O_ = CT2.R_E_C_N_O_ - 1
	A0001 += "                                                                    AND XCT2.D_E_L_E_T_ = ' ')
	A0001 += "                  ELSE CT2_CREDIT
	A0001 += "                END ORI_CRD,
	A0001 += "                R_E_C_N_O_ REGCT2
	A0001 += "           FROM "+RetSqlName("CT2")+" CT2
	A0001 += "          WHERE CT2_FILIAL = '01'
	A0001 += "            AND CT2_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "            AND CT2_LOTE = '008890'
	A0001 += "            AND D_E_L_E_T_ = ' ') AS FOLHA
	A0001 += "     WHERE SUBSTRING(ORI_DEB,1,1) = '3' or SUBSTRING(ORI_CRD,1,1) = '3' or CT2_DEBITO = '11205010' or CT2_CREDIT = '11205010'
	A0001 += "     ORDER BY REGCT2
	
Else
	
	A0001 := " SELECT CASE
	A0001 += "          WHEN SUBSTRING(ORI_DEB,1,1) = '3' THEN ORI_DEB
	A0001 += "          WHEN SUBSTRING(ORI_CRD,1,1) = '3' THEN ORI_CRD
	A0001 += "          ELSE
	A0001 += "            CASE
	A0001 += "              WHEN SUBSTRING(CT2_DEBITO,1,8) = '11206001' THEN CT2_DEBITO
	A0001 += "              WHEN SUBSTRING(CT2_DEBITO,1,8) = '11206001' THEN CT2_CREDIT
	A0001 += "              ELSE '                    '
	A0001 += "            END
	A0001 += "        END CONTA,
	A0001 += "        CASE
	A0001 += "          WHEN SUBSTRING(ORI_DEB,1,1) = '3' THEN CT2_CLVLDB
	A0001 += "          WHEN SUBSTRING(ORI_CRD,1,1) = '3' THEN CT2_CLVLCR
	A0001 += "          ELSE ' '
	A0001 += "        END CLVL,
	A0001 += "        CASE
	A0001 += "          WHEN SUBSTRING(ORI_DEB,1,1) = '3' THEN CT2_VALOR
	A0001 += "          ELSE
	A0001 += "            CASE
	A0001 += "              WHEN SUBSTRING(CT2_DEBITO,1,8) = '11206001' THEN CT2_VALOR
	A0001 += "              ELSE 0
	A0001 += "            END
	A0001 += "        END VLR_DEB,
	A0001 += "        CASE
	A0001 += "          WHEN SUBSTRING(ORI_CRD,1,1) = '3' THEN CT2_VALOR * (-1)
	A0001 += "          ELSE
	A0001 += "            CASE
	A0001 += "              WHEN SUBSTRING(CT2_CREDIT,1,8) = '11206001' THEN CT2_VALOR * (-1)
	A0001 += "              ELSE 0
	A0001 += "            END
	A0001 += "        END VLR_CRD,
	A0001 += "        CASE
	A0001 += "          WHEN SUBSTRING(CT2_DEBITO,1,8) = '11206001' THEN CT2_DEBITO
	A0001 += "          WHEN SUBSTRING(CT2_CREDIT,1,8) = '11206001' THEN CT2_CREDIT
	A0001 += "          ELSE '                    '
	A0001 += "        END INTRAGRUPO,
	A0001 += "        *
	A0001 += "   FROM (SELECT CT2_LOTE,
	A0001 += "                CT2_DEBITO,
	A0001 += "                CT2_CREDIT,
	A0001 += "                CT2_VALOR,
	A0001 += "                CT2_HIST,
	A0001 += "                SUBSTRING(CT2_ORIGEM, 1, 10) ORIG,
	A0001 += "                CT2_LP,
	A0001 += "                CT2_CLVLDB,
	A0001 += "                CT2_CLVLCR,
	A0001 += "                CASE
	A0001 += "                  WHEN SUBSTRING(CT2_DEBITO,1,8) = '11206001' THEN (SELECT TOP 1 XCT2.CT2_DEBITO
	A0001 += "                                                                      FROM "+RetSqlName("CT2")+" XCT2
	A0001 += "                                                                     WHERE XCT2.CT2_FILIAL = '"+xFilial("CT2")+"'
	A0001 += "                                                                       AND XCT2.CT2_DATA = CT2.CT2_DATA
	A0001 += "                                                                       AND XCT2.CT2_LOTE = CT2.CT2_LOTE
	A0001 += "                                                                       AND XCT2.CT2_HIST = CT2.CT2_HIST
	A0001 += "                                                                       AND XCT2.CT2_LP = CT2.CT2_LP
	A0001 += "                                                                       AND XCT2.CT2_CLVLDB = CT2.CT2_CLVLDB
	A0001 += "                                                                       AND XCT2.CT2_CLVLCR = CT2.CT2_CLVLCR
	A0001 += "                                                                       AND XCT2.CT2_ROTINA = CT2.CT2_ROTINA
	A0001 += "                                                                       AND XCT2.D_E_L_E_T_ = ' ')
	A0001 += "                  ELSE CT2_DEBITO
	A0001 += "                END ORI_DEB,
	A0001 += "                CASE
	A0001 += "                  WHEN SUBSTRING(CT2_CREDIT,1,8) = '11206001' THEN (SELECT TOP 1 XCT2.CT2_CREDIT
	A0001 += "                                                                      FROM "+RetSqlName("CT2")+" XCT2
	A0001 += "                                                                     WHERE XCT2.CT2_FILIAL = '"+xFilial("CT2")+"'
	A0001 += "                                                                       AND XCT2.CT2_DATA = CT2.CT2_DATA
	A0001 += "                                                                       AND XCT2.CT2_LOTE = CT2.CT2_LOTE
	A0001 += "                                                                       AND XCT2.CT2_HIST = CT2.CT2_HIST
	A0001 += "                                                                       AND XCT2.CT2_LP = CT2.CT2_LP
	A0001 += "                                                                       AND XCT2.CT2_CLVLDB = CT2.CT2_CLVLDB
	A0001 += "                                                                       AND XCT2.CT2_CLVLCR = CT2.CT2_CLVLCR
	A0001 += "                                                                       AND XCT2.CT2_ROTINA = CT2.CT2_ROTINA
	A0001 += "                                                                       AND XCT2.D_E_L_E_T_ = ' ')
	A0001 += "                  ELSE CT2_CREDIT
	A0001 += "                END ORI_CRD,
	A0001 += "                R_E_C_N_O_ REGCT2
	A0001 += "           FROM "+RetSqlName("CT2")+" CT2
	A0001 += "          WHERE CT2_FILIAL = '"+xFilial("CT2")+"'
	A0001 += "            AND CT2_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "            AND CT2_LOTE = '008890'
	A0001 += "            AND D_E_L_E_T_ = ' ') AS FOLHA
	A0001 += "     WHERE SUBSTRING(ORI_DEB,1,1) = '3' or SUBSTRING(ORI_CRD,1,1) = '3' or SUBSTRING(CT2_DEBITO,1,8) = '11206001' or SUBSTRING(CT2_CREDIT,1,8) = '11206001'
	A0001 += "     ORDER BY REGCT2
	
EndIf
TcQuery A0001 New Alias "A001"
dbSelectArea("A001")
dbGoTop()
ProcRegua(RecCount())
hhi := 0
While !Eof()
	
	IncProc( StrZero(hhi += 1, 7) )
	
	aAdd(aDados2, { A001->CONTA,;
	A001->CLVL,;
	Transform(A001->VLR_DEB,"@E 999,999,999.9999"),;
	Transform(A001->VLR_CRD,"@E 999,999,999.9999"),;
	A001->INTRAGRUPO,;
	A001->CT2_LOTE,;
	A001->CT2_DEBITO,;
	A001->CT2_CREDIT,;
	Transform(A001->CT2_VALOR,"@E 999,999,999.9999"),;
	A001->CT2_HIST,;
	A001->ORIG,;
	A001->CT2_LP,;
	A001->CT2_CLVLDB,;
	A001->CT2_CLVLCR,;
	A001->ORI_DEB,;
	A001->ORI_CRD,;
	A001->REGCT2} )
	
	/*
	A001->REGSRZ ,;
	A001->ORI_LAN,;
	A001->CC,;
	A001->VERBA,;
	A001->MATR,;
	A001->RA_CODFUNC,;
	A001->RJ_DESC,;
	Transform(A001->VALOR       ,"@E 999,999,999.9999"),;
	Transform(A001->PERC_EMP01  ,"@E 999,999,999.9999"),;
	Transform(A001->PERC_EMP05  ,"@E 999,999,999.9999"),;
	Transform(A001->VALOR * A001->PERC_EMP01 / 100  ,"@E 999,999,999.9999"),;
	Transform(A001->VALOR * A001->PERC_EMP05 / 100  ,"@E 999,999,999.9999"),;
	xe_Deb,;
	xe_Crd} )
	*/
	
	dbSelectArea("A001")
	dbSkip()
End
aStru1 := ("A001")->(dbStruct())

A001->(dbCloseArea())

U_BIAxExcel(aDados2, aStru1, fPerg+strzero(seconds()%3500,5) )

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
aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
