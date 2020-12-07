#Include "Protheus.ch"
#include "topconn.ch"

User Function BIA275()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA275
Empresa   := Biancogres Cerêmicas S/A
Data      := 05/12/11
Uso       := Gestão de Pessoal
Aplicação := Apuração do Absenteísmo conforme regras estabelecidas pelo RH.
.            Exporta para o Excel.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local r

cHInicio := Time()
fPerg := "BIA275"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

xf_Stri := Alltrim(MV_PAR02)
cs_VetLoc := {}
If Right(xf_Stri,1) <> ','
	xf_Stri := xf_Stri+","
EndIf
While .T.
	nPos := AT(",", xf_Stri )
	If nPos > 0
		aAdd( cs_VetLoc , Substr(xf_Stri,1,nPos-1) )
		xf_Stri := Alltrim(Substr(xf_Stri,nPos+1,Len(xf_Stri)))
	Else
		Exit
	Endif
End

aDados2 := {}
df_FiltAb := U_BIAGetLike(GetMV("MV_YFLTABN"))

For r := 1 To Len(cs_VetLoc)
	
	xf_DtIni := MV_PAR01+cs_VetLoc[r]+"01"
	xf_DtFim := dtos(Ultimodia(stod(MV_PAR01+cs_VetLoc[r]+"01")))
	
	If MV_PAR03 == 1
		A0001 := " SELECT ' ' EMPRESA, ' ' PERIODO, CCLVL, SUM(FALTAS) FALTAS
	Else
		A0001 := " SELECT ' ' EMPRESA, ' ' PERIODO, *
	EndIf
	A0001 += "   FROM (SELECT RA_MAT,
	A0001 += "                RA_NOME,
	A0001 += "                CASE
	A0001 += "                  WHEN CCP <> '        ' THEN
	A0001 += "                    CCP
	A0001 += "                  ELSE
	A0001 += "                    RA_CC
	A0001 += "                END CCLVL,
	A0001 += "                CASE
	A0001 += "                  WHEN DURAC1 > 15 OR DURAC2 > 15 OR DURAC3 > 15 THEN 0
	A0001 += "                  ELSE FALTAS
	A0001 += "                END FALTAS
	A0001 += "           FROM (SELECT RA_MAT,
	A0001 += "                        RA_NOME,
	A0001 += "                        RA_CC,
	A0001 += "                        ISNULL((SELECT MAX(RE_CCP)
	A0001 += "                                  FROM " + RetSqlName("SRE")
	A0001 += "                                 WHERE RE_FILIAL = '"+xFilial("SRE")+"'
	A0001 += "                                   AND RE_MATP = RA_MAT
	A0001 += "                                   AND RE_DATA IN (SELECT MAX(RE_DATA)
	A0001 += "                                                     FROM " + RetSqlName("SRE")
	A0001 += "                                                    WHERE RE_FILIAL = '"+xFilial("SRE")+"'
	A0001 += "                                                      AND RE_MATP = RA_MAT
	A0001 += "                                                      AND SUBSTRING(RE_DATA,1,6) <= '"+MV_PAR01+cs_VetLoc[r]+"'
	A0001 += "                                                      AND RE_EMPP = '"+cEmpAnt+"'
	A0001 += "                                                      AND D_E_L_E_T_  = ' ')
	A0001 += "                                   AND RE_EMPP = '"+cEmpAnt+"'
	A0001 += "                                   AND D_E_L_E_T_ = ' '), '         ') CCP,
	A0001 += "                        ((SELECT COUNT(*)
	A0001 += "                            FROM "+RetSqlName("SPH")+" SPH
	A0001 += "                           WHERE PH_FILIAL = '"+xFilial("SPH")+"'
	A0001 += "                             AND PH_PD = '010'
	A0001 += "                             AND PH_MAT = RA_MAT
	A0001 += "                             AND PH_ABONO IN('   ',"+df_FiltAb+")
	A0001 += "                             AND SUBSTRING(PH_DATA,1,6) = '"+MV_PAR01+cs_VetLoc[r]+"'
	*****************************************************************************************
	A0001 += "                             AND SPH.D_E_L_E_T_ = ' ') + ISNULL((SELECT SUM(AFAST)
	A0001 += "                                                                   FROM (SELECT CASE
	A0001 += "                                                                                  WHEN SUBSTRING(R8_DATAINI,1,6) = '"+MV_PAR01+cs_VetLoc[r]+"' AND SUBSTRING(R8_DATAFIM,1,6) = '"+MV_PAR01+cs_VetLoc[r]+"' THEN
	A0001 += "                                                                                    R8_DPAGAR
	A0001 += "                                                                                  WHEN SUBSTRING(R8_DATAINI, 1, 6) < '"+MV_PAR01+cs_VetLoc[r]+"' AND SUBSTRING(R8_DATAFIM, 1, 6) > '"+MV_PAR01+cs_VetLoc[r]+"' THEN
	A0001 += "                                                                                    DATEDIFF(dd,'"+xf_DtIni+"','"+xf_DtFim+"') + 1
	A0001 += "                                                                                  WHEN SUBSTRING(R8_DATAINI,1,6) < '"+MV_PAR01+cs_VetLoc[r]+"' AND SUBSTRING(R8_DATAFIM,1,6) = '"+MV_PAR01+cs_VetLoc[r]+"' THEN
	A0001 += "                                                                                    DATEDIFF(dd,'"+xf_DtIni+"',R8_DATAFIM) + 1
	A0001 += "                                                                                  WHEN SUBSTRING(R8_DATAINI,1,6) = '"+MV_PAR01+cs_VetLoc[r]+"' AND SUBSTRING(R8_DATAFIM,1,6) > '"+MV_PAR01+cs_VetLoc[r]+"' THEN
	A0001 += "                                                                                    DATEDIFF(dd,R8_DATAINI,'"+xf_DtFim+"') + 1
	A0001 += "                                                                                  ELSE
	A0001 += "                                                                                    0
	A0001 += "                                                                                END AFAST
	A0001 += "                                                                           FROM "+RetSqlName("SR8")
	A0001 += "                                                                          WHERE R8_FILIAL = '"+xFilial("SR8")+"'
	A0001 += "                                                                            AND R8_MAT = RA_MAT
	A0001 += "                                                                            AND R8_TIPO IN('6','7','A','B','O','P','Q','R')
	A0001 += "                                                                            AND ( (R8_DATAINI <= '"+xf_DtIni+"' AND R8_DATAFIM >= '"+xf_DtFim+"') OR (R8_DATAINI >= '"+xf_DtIni+"' AND R8_DATAINI <= '"+xf_DtFim+"') OR (R8_DATAFIM >= '"+xf_DtIni+"' AND R8_DATAFIM <= '"+xf_DtFim+"') )
	//A0001 += "                                                                            AND (R8_DATAINI BETWEEN '"+xf_DtIni+"' AND '"+xf_DtFim+"' OR R8_DATAFIM BETWEEN '"+xf_DtIni+"' AND '"+xf_DtFim+"')
	A0001 += "                                                                            AND D_E_L_E_T_ = ' ') AS AFAS),0)) FALTAS,
	*****************************************************************************************
	A0001 += "                        ISNULL((SELECT R8_DURACAO
	A0001 += "                                  FROM " + RetSqlName("SR8")
	A0001 += "                                 WHERE R8_FILIAL = '"+xFilial("SR8")+"'
	A0001 += "                                   AND R8_MAT = RA_MAT
	A0001 += "                                   AND R8_TIPO IN('6','7','A','B','O','P','Q','R')
	A0001 += "                                   AND R8_MAT+R8_DATAFIM IN(SELECT R8_MAT+MAX(R8_DATAFIM)
	A0001 += "                                                              FROM " + RetSqlName("SR8")
	A0001 += "                                                             WHERE R8_FILIAL = '"+xFilial("SR8")+"'
	A0001 += "                                                               AND R8_MAT = RA_MAT
	A0001 += "                                                               AND R8_TIPO IN('6','7','A','B','O','P','Q','R')
	A0001 += "                                                               AND R8_DATAFIM >= '"+xf_DtIni+"'
	A0001 += "                                                               AND R8_DATAFIM <= '"+xf_DtFim+"'
	A0001 += "                                                               AND D_E_L_E_T_ = ' '
	A0001 += "                                                             GROUP BY R8_MAT)
	A0001 += "                                   AND D_E_L_E_T_ = ' '), 0) DURAC1,
	A0001 += "                        ISNULL((SELECT R8_DURACAO
	A0001 += "                                  FROM " + RetSqlName("SR8")
	A0001 += "                                 WHERE R8_FILIAL = '"+xFilial("SR8")+"'
	A0001 += "                                   AND R8_MAT = RA_MAT
	A0001 += "                                   AND R8_TIPO IN('6','7','A','B','O','P','Q','R')
	A0001 += "                                   AND R8_MAT+R8_DATAFIM IN(SELECT R8_MAT+MAX(R8_DATAFIM)
	A0001 += "                                                              FROM " + RetSqlName("SR8")
	A0001 += "                                                             WHERE R8_FILIAL = '"+xFilial("SR8")+"'
	A0001 += "                                                               AND R8_MAT = RA_MAT
	A0001 += "                                                               AND R8_TIPO IN('6','7','A','B','O','P','Q','R')
	A0001 += "                                                               AND R8_DATAINI <= '"+xf_DtIni+"'
	A0001 += "                                                               AND R8_DATAFIM > '"+xf_DtFim+"'
	A0001 += "                                                               AND D_E_L_E_T_ = ' '
	A0001 += "                                                              GROUP BY R8_MAT)
	A0001 += "                                   AND D_E_L_E_T_ = ' '), 0 ) DURAC2,
	A0001 += "                        ISNULL((SELECT R8_DURACAO
	A0001 += "                                  FROM " + RetSqlName("SR8")
	A0001 += "                                 WHERE R8_FILIAL = '"+xFilial("SR8")+"'
	A0001 += "                                   AND R8_MAT = RA_MAT
	A0001 += "                                   AND R8_TIPO IN('6','7','A','B','O','P','Q','R')
	A0001 += "                                   AND R8_MAT+R8_DATAFIM IN(SELECT R8_MAT+MAX(R8_DATAFIM)
	A0001 += "                                                              FROM " + RetSqlName("SR8")
	A0001 += "                                                             WHERE R8_FILIAL = '"+xFilial("SR8")+"'
	A0001 += "                                                               AND R8_MAT = RA_MAT
	A0001 += "                                                               AND R8_TIPO IN('6','7','A','B','O','P','Q','R')
	A0001 += "                                                               AND R8_DATAINI < '"+xf_DtFim+"'
	A0001 += "                                                               AND R8_DATAFIM = '        '
	A0001 += "                                                               AND D_E_L_E_T_ = ' '
	A0001 += "                                                              GROUP BY R8_MAT)
	A0001 += "                                   AND D_E_L_E_T_ = ' '), 0 ) DURAC3
	
	*****************************************************************************************
	A0001 += "                   FROM "+RetSqlName("SRA")+" SRA
	A0001 += "                  WHERE RA_FILIAL BETWEEN '  ' AND 'ZZ'
	A0001 += "                    AND RA_MAT BETWEEN '000000' AND '199999'
	A0001 += "                    AND RA_CATFUNC = 'M'
	A0001 += "                    AND RA_CATEG <> '07'
	A0001 += "                    AND SUBSTRING(RA_ADMISSA,1,6) <= '"+MV_PAR01+cs_VetLoc[r]+"'
	A0001 += "                    AND (RA_DEMISSA = '        ' OR RA_DEMISSA > '"+xf_DtFim+"')
	A0001 += "                    AND D_E_L_E_T_ = ' ') AS ABSEN) AS ABSEN2
	If MV_PAR03 == 1
		A0001 += "  GROUP BY CCLVL
	EndIf
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		
		IncProc()
		
		If MV_PAR03 == 1
			aAdd(aDados2, { SM0->M0_NOME,;
			MV_PAR01+cs_VetLoc[r],;
			A001->CCLVL,;
			Transform(A001->FALTAS   ,"@E 99999999999")} )
			
		Else
			aAdd(aDados2, { SM0->M0_NOME,;
			MV_PAR01+cs_VetLoc[r],;
			A001->RA_MAT,;
			A001->RA_NOME,;
			A001->CCLVL,;
			Transform(A001->FALTAS   ,"@E 99999999999")} )
			
		EndIf
		
		dbSelectArea("A001")
		dbSkip()
	End
	aStru1 := ("A001")->(dbStruct())
	
	A001->(dbCloseArea())
	
Next r

df_ArqEtq := Alltrim(SM0->M0_NOME)+"_"+strzero(seconds()%3500,5)

U_BIAxExcel(aDados2, aStru1, df_ArqEtq )

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
aAdd(aRegs,{cPerg,"01","Ano (quatro dígitos)  ?","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Meses(separado por ,) ?","","","mv_ch2","C",40,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Forma de Impressão    ?","","","mv_ch3","N",01,0,0,"C","","mv_par01","Por CCLVL","","","","","Por Matricula","","","","","","","","","","","","","","","","","","",""})

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
