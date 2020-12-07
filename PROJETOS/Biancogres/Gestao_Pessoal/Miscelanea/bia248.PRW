#Include "TOPCONN.CH"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'

User Function BIA248()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA248
Empresa   := Biancogres Cerâmica S/A
Data      := 30/10/12
Uso       := Gestão de Pessoal
Aplicação := Relatório de Calculo de Benefício
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

cHInicio := Time()
fPerg := "BIA249"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

wqChave := ""
wqAgrup := ""
If MV_PAR01 == 1
	wqChave := "RA_CC, RHR_MAT, RHR_ORIGEM, CODIGO, RHR_CODFOR DESC"
	wqAgrup := "GP04->RA_CC + GP04->RHR_MAT + GP04->RA_NOME"
ElseIf MV_PAR01 == 2
	wqChave := "RHR_MAT, RHR_ORIGEM, CODIGO, RHR_CODFOR DESC"
	wqAgrup := "GP04->RHR_MAT + GP04->RA_NOME + GP04->RA_CC"
ElseIf MV_PAR01 == 3
	wqChave := "RA_NOME, RHR_ORIGEM, CODIGO, RHR_CODFOR DESC"
	wqAgrup := "GP04->RA_NOME + GP04->RHR_MAT + GP04->RA_CC"
EndIf

GP003 := " SELECT RA_CC,
GP003 += "        RHR_MAT,
GP003 += "        RA_NOME,
GP003 += "        CASE
GP003 += "          WHEN RHR_ORIGEM = '1' THEN 'TITULAR'
GP003 += "          WHEN RHR_ORIGEM = '2' THEN 'DEPENDENTE'
GP003 += "          WHEN RHR_ORIGEM = '3' THEN 'AGREGADO'
GP003 += "          ELSE 'NAO CLASSIFICADO'
GP003 += "        END ORIGEM,
GP003 += "        CASE
GP003 += "          WHEN RHR_CODIGO = '  ' THEN '00'
GP003 += "          ELSE RHR_CODIGO
GP003 += "        END CODIGO,
GP003 += "        ISNULL(RB_NOME, RA_NOME) NOME,
GP003 += "        CASE
GP003 += "          WHEN RHR_TPLAN = '1' THEN 'PLANOS'
GP003 += "          WHEN RHR_TPLAN = '2' THEN 'CO-PARTICIPACAO'
GP003 += "          WHEN RHR_TPLAN = '3' THEN 'REEMBOLSO'
GP003 += "          ELSE 'NAO CADASTRADO'
GP003 += "        END TP_LANC,
GP003 += "        CASE
GP003 += "          WHEN RHR_TPFORN = '1' THEN 'ASS.MEDICA'
GP003 += "          WHEN RHR_TPFORN = '2' THEN 'ASS.ODONTOLOGICA'
GP003 += "          ELSE 'NAO CADASTRADO'
GP003 += "        END TP_FORN,
GP003 += "        RHR_CODFOR,
GP003 += "        SUBSTRING(S016.RCC_CONTEU,4, 150) FORNEC,
GP003 += "        CASE
GP003 += "          WHEN RHR_TPPLAN = '1' THEN 'FAIXA SALARIAL'
GP003 += "          WHEN RHR_TPPLAN = '2' THEN 'FAIXA ETARIA'
GP003 += "          WHEN RHR_TPPLAN = '3' THEN 'VALOR FIXO'
GP003 += "          WHEN RHR_TPPLAN = '3' THEN '% SOBRE SALARIO'
GP003 += "          ELSE '-'
GP003 += "        END TP_PLAN,
GP003 += "        RHR_PLANO,
GP003 += "        ISNULL(SUBSTRING(S008.RCC_CONTEU,3, 20), ISNULL(SUBSTRING(S013.RCC_CONTEU,3, 20),'-') ) FORNEC,
GP003 += "        RHR_PD,
GP003 += "        RV_DESC,
GP003 += "        RHR_VLRFUN,
GP003 += "        RHR_VLREMP,
GP003 += "        RHR_COMPPG
GP003 += "   FROM RHR010 RHR
GP003 += "  INNER JOIN SRA010 SRA ON RA_FILIAL = '01'
GP003 += "                       AND RA_MAT = RHR_MAT
GP003 += "                       AND SRA.D_E_L_E_T_ = ' '
GP003 += "   LEFT JOIN SRB010 SRB ON RB_FILIAL = '01'
GP003 += "                       AND RB_MAT = RHR_MAT
GP003 += "                       AND RB_COD = RHR_CODIGO
GP003 += "                       AND SRB.D_E_L_E_T_ = ' '
GP003 += "  INNER JOIN SRV010 SRV ON RV_FILIAL = '  '
GP003 += "                       AND RV_COD = RHR_PD
GP003 += "                       AND SRV.D_E_L_E_T_ = ' '
GP003 += "  INNER JOIN RCC010 S016 ON S016.RCC_FILIAL = '  '
GP003 += "                        AND S016.RCC_CODIGO = 'S016'
GP003 += "                        AND SUBSTRING(S016.RCC_CONTEU,1,3) = RHR_CODFOR
GP003 += "                        AND S016.D_E_L_E_T_ = ' '
GP003 += "   LEFT JOIN RCC010 S008 ON S008.RCC_FILIAL = '  '
GP003 += "                        AND S008.RCC_CODIGO = 'S008'
GP003 += "                        AND S008.RCC_CHAVE IN('      ',RHR_COMPPG)
GP003 += "                        AND SUBSTRING(S008.RCC_CONTEU,1,2) = RHR_PLANO
GP003 += "                        AND CONVERT(NUMERIC(12,2), SUBSTRING(S008.RCC_CONTEU,23,12)) IN(SELECT MAX(CONVERT(NUMERIC(12,2), SUBSTRING(RCC_CONTEU,23,12)))
GP003 += "                                                                                         FROM RCC010
GP003 += "                                                                                        WHERE RCC_CODIGO = 'S008'
GP003 += "                                                                                          AND RCC_CHAVE IN('      ','"+MV_PAR02+"')
GP003 += "                                                                                          AND SUBSTRING(RCC_CONTEU,1,2) = RHR_PLANO
GP003 += "                                                                                          AND CONVERT(NUMERIC(12,2), SUBSTRING(RCC_CONTEU,23,12)) >= RA_SALARIO
GP003 += "                                                                                          AND D_E_L_E_T_ = ' ')
GP003 += "                        AND S008.D_E_L_E_T_ = ' '
GP003 += "   LEFT JOIN RCC010 S013 ON S013.RCC_FILIAL = '  '
GP003 += "                        AND S013.RCC_CODIGO = 'S013'
GP003 += "                        AND S013.RCC_CHAVE IN('      ',RHR_COMPPG)
GP003 += "                        AND SUBSTRING(S013.RCC_CONTEU,1,2) = RHR_PLANO
GP003 += "                        AND CONVERT(NUMERIC(12,2), SUBSTRING(S013.RCC_CONTEU,23,12)) IN(SELECT MAX(CONVERT(NUMERIC(12,2), SUBSTRING(RCC_CONTEU,23,12)))
GP003 += "                                                                                          FROM RCC010
GP003 += "                                                                                         WHERE RCC_CODIGO = 'S013'
GP003 += "                                                                                           AND RCC_CHAVE IN('      ','"+MV_PAR02+"')
GP003 += "                                                                                           AND SUBSTRING(RCC_CONTEU,1,2) = RHR_PLANO
GP003 += "                                                                                           AND CONVERT(NUMERIC(12,2), SUBSTRING(RCC_CONTEU,23,12)) >= RA_SALARIO
GP003 += "                                                                                           AND D_E_L_E_T_ = ' ')
GP003 += "                        AND S013.D_E_L_E_T_ = ' '
GP003 += "  WHERE RHR_FILIAL = '"+xFilial("RHR")+"'
GP003 += "    AND RHR_MAT BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
If !Empty(MV_PAR05)
	GP003 += "    AND RHR_PD  IN "+FormatIn(MV_PAR05,",")
EndIf
GP003 += "    AND RHR.D_E_L_E_T_ = ' '
GP003 += "  ORDER BY " + wqChave

GP003 := ChangeQuery(GP003)
cIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,GP003),'GP03',.T.,.T.)
aStru1 := ("GP03")->(dbStruct())
/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
If !chkfile("GP04")
	GP04 := U_BIACrTMP(aStru1)
	dbUseArea( .T.,, GP04, "GP04", .F., .F. )
	//dbCreateInd(GP04, "RA_CC + RHR_MAT",{ || "RA_CC + RHR_MAT" })
EndIf
dbSelectArea("GP04")
APPEND FROM ("GP03")
If Select("GP03") > 0
	GP03->(dbCloseArea())
Endif
dbGotop()
While !Eof()
	
	
	dbSelectArea("GP04")
	dbSkip()
End
GP04->(dbCloseArea())


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
aAdd(aRegs,{cPerg,"01","Order de Produção    ?","","","mv_ch1","N",01,0,0,"C","","mv_par01","CentroCusto+Matric","","","","","Matricula","","","","","Nome","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","AnoMes de Referência ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","De Matricula         ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"04","Ate Matricula        ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"05","Quais Verbas Listar  ?","","","mv_ch5","C",50,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
