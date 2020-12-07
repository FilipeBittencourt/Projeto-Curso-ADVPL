#include "rwmake.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "vkey.ch"
#include "Ap5Mail.ch"
#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA283
@author Marcos Alberto Soprani
@since 22/02/11
@version 1.0
@description Controle de Refeitório
@type function
/*/

User Function BIA283()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hhi
	Private xEnter 		:= CHR(13)+CHR(10)

	cHInicio := Time()
	fPerg := "BIA283"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	aDados2 := {}
	aVetFcc := {}

	A0001 := " SELECT CASE
	A0001 += "          WHEN END_IP = '192.168.020.130' THEN 'BIANCOGRES'
	A0001 += "          WHEN END_IP = '192.168.020.131' THEN 'INCESA'
	A0001 += "          ELSE 'REFEITORIO'
	A0001 += "        END CATRACA,
	A0001 += "        ISNULL((SELECT DISTINCT ZC0_EMPR
	A0001 += "                  FROM " + RetSqlName("ZC0")
	A0001 += "                 WHERE ZC0_FILIAL = '" + xFilial("ZC0") + "'
	A0001 += "                   AND REPLICATE('0', 12 - LEN(RTRIM(ZC0_NUMERO))) + RTRIM(ZC0_NUMERO) = ICARD COLLATE Latin1_General_BIN
	A0001 += "                   AND ( ( '20'+ANOM+MESM+DIAM COLLATE Latin1_General_BIN BETWEEN ZC0_DATREC AND ZC0_DATDEV )
	A0001 += "                            OR ( '20'+ANOM+MESM+DIAM COLLATE Latin1_General_BIN >= ZC0_DATREC AND ZC0_DATDEV = '        ' ) )
	A0001 += "                   AND D_E_L_E_T_ = ' '),
	A0001 += "                                          CASE
	A0001 += "                                            WHEN SUBSTRING(ICARD,1,2) = '00' THEN '01'
	A0001 += "                                            WHEN SUBSTRING(ICARD,1,2) = '05' THEN '05'
	A0001 += "                                            WHEN SUBSTRING(ICARD,1,2) = '12' THEN '12'
	A0001 += "                                            WHEN SUBSTRING(ICARD,1,2) = '13' THEN '13'
	A0001 += "                                            WHEN SUBSTRING(ICARD,1,2) = '14' THEN '14'
	A0001 += "                                            ELSE '00'
	A0001 += "                                          END ) EMP_FIL,
	A0001 += "        SUBSTRING(ICARD,7,6) MATRICULA,
	A0001 += "        (SELECT DISTINCT PESSOA.NomePess NOMEPESS
	A0001 += "           FROM ZEUS.suricato.suricato.TbColab COLAB
	A0001 += "          INNER JOIN ZEUS.suricato.suricato.TbPessoa PESSOA ON PESSOA.IdPessoa = COLAB.IdPessoa
	A0001 += "          INNER JOIN ZEUS.suricato.suricato.TbHistoCrach HIST ON COLAB.IdColab = HIST.IdColab
	A0001 += "                                                        AND GETDATE() >= HIST.DataInic
	A0001 += "                                                        AND GETDATE() <= HIST.DataFina
	A0001 += "          WHERE REPLICATE('0',12-LEN(HIST.Icard))+CONVERT(VARCHAR,HIST.Icard) = DAM.ICARD) NOME,
	A0001 += "        DIAM+'/'+MESM+'/'+ANOM DATAREF,
	A0001 += "        SUBSTRING(HORAM,1,2)+':'+SUBSTRING(HORAM,3,2)+':'+SEGUNDO HORA,
	A0001 += "        CASE
	A0001 += "          WHEN SUBSTRING(ICARD,1,2) = '00' THEN 'BIANCOGRES'
	A0001 += "          WHEN SUBSTRING(ICARD,1,2) = '05' THEN 'INCESA'
	A0001 += "          WHEN SUBSTRING(ICARD,1,2) = '12' THEN 'ST GESTAO'
	A0001 += "          WHEN SUBSTRING(ICARD,1,2) = '13' THEN 'MUNDI'
	A0001 += "          WHEN SUBSTRING(ICARD,1,2) = '14' THEN 'VITCER'
	A0001 += "          ELSE 'NAO CONFIGURADA'
	A0001 += "        END REGISTRADO,
	A0001 += "        ISNULL((SELECT TOP 1 ZC0_CLVL
	A0001 += "                  FROM " + RetSqlName("ZC0")
	A0001 += "                 WHERE ZC0_FILIAL = '" + xFilial("ZC0") + "'
	A0001 += "                   AND REPLICATE('0', 12 - LEN(RTRIM(ZC0_NUMERO))) + RTRIM(ZC0_NUMERO) = ICARD COLLATE Latin1_General_BIN
	A0001 += "                   AND ( ( '20'+ANOM+MESM+DIAM COLLATE Latin1_General_BIN BETWEEN ZC0_DATREC AND ZC0_DATDEV )
	A0001 += "                            OR ( '20'+ANOM+MESM+DIAM COLLATE Latin1_General_BIN >= ZC0_DATREC AND ZC0_DATDEV = '        ' ) )
	A0001 += "                   AND D_E_L_E_T_ = ' '), ' ') CCLVL
	A0001 += "   FROM ZEUS.suricato.TELESSVR.DAM00 DAM
	A0001 += "  WHERE '20'+ANOM+MESM+DIAM BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "    AND POSIC = '0'
	A0001 += "    AND CODAC = '01'
	If MV_PAR04 == 1
		A0001 += "    AND HORAM BETWEEN '1000' AND '1430'
	Else
		A0001 += "    AND HORAM BETWEEN '0500' AND '0700'
	EndIf
	A0001 += "  ORDER BY EMP_FIL, DATAREF, HORA, CATRACA, MATRICULA
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		aVetFcc := {}
		fr_EmpFl := A001->EMP_FIL
		fr_DatRf := A001->DATAREF
		If A001->EMP_FIL <> "00"
			ftBuscCC()
		EndIf
		While !Eof() .and. A001->EMP_FIL == fr_EmpFl .and. A001->DATAREF == fr_DatRf

			IncProc("Processando... " + A001->EMP_FIL + " " + A001->DATAREF )

			nPos := aScan(aVetFcc,{|x| x[1] == A001->MATRICULA })
			cs_CC := Space(09)
			If nPos > 0
				cs_CC := aVetFcc[nPos][2]
			Else
				cs_CC := A001->CCLVL
			EndIf

			rrFil := A001->EMP_FIL
			rrMat := A001->MATRICULA
			If A001->EMP_FIL == "05" .and. dtos(ctod(fr_DatRf)) >= "20181111" .and. dtos(ctod(fr_DatRf)) <= "20181130"

				QD004 := " SELECT MAX(RE_MATP) MATP "
				QD004 += "   FROM " + RetSqlName("SRE") + " "
				QD004 += "   WHERE RE_FILIAL = '" + xFilial("SRE") + "' "
				QD004 += "     AND RE_MATD = '" + rrMat + "' "
				QD004 += "     AND RE_DATA = '20181201' "
				QD004 += "     AND RE_EMPD = '05' "
				QD004 += "     AND D_E_L_E_T_ = ' ' "
				TcQuery QD004 New Alias "QD04"
				dbSelectArea("QD04")
				dbGoTop()
				rrFil := "01"
				rrMat := QD04->MATP
				QD04->(dbCloseArea())

			EndIf

			dbSelectArea("A001")

			aAdd(aDados2, { A001->CATRACA,;
			rrFil,;
			rrMat,;
			A001->NOME,;
			A001->DATAREF,;
			A001->HORA,;
			A001->REGISTRADO,;
			cs_CC} )

			dbSelectArea("A001")
			dbSkip()
		End

	End
	aStru1 := ("A001")->(dbStruct())

	A001->(dbCloseArea())

	U_BIAxExcel(aDados2, aStru1, fPerg+strzero(seconds()%3500,5) )

	If MV_PAR03 == 1
		aDados2 := Asort(aDados2,,, { |x, y| x[7]+x[5]+x[3]+x[6] < y[7]+y[5]+y[3]+y[6] })
		cf_Empre := ""
		For hhi := 1 to Len(aDados2)

			// Estrutura para criação do arquivo txt
			If cf_Empre <> aDados2[hhi][7]
				cf_Empre := aDados2[hhi][7]
				cf_sigla := IIF(Alltrim(cf_Empre) == 'BIANCOGRES', "bg", IIF(Alltrim(cf_Empre) == 'INCESA', "in", IIF(Alltrim(cf_Empre) == 'MUNDI', "mn", IIF(Alltrim(cf_Empre) == 'VITCER', "vt", IIF(Alltrim(cf_Empre) == 'ST GESTAO', "st", "ou")))))
				cf_relog := IIF(Alltrim(cf_Empre) == 'BIANCOGRES', "51", IIF(Alltrim(cf_Empre) == 'INCESA', "52", IIF(Alltrim(cf_Empre) == 'MUNDI', "53", IIF(Alltrim(cf_Empre) == 'VITCER', "54", IIF(Alltrim(cf_Empre) == 'ST GESTAO', "55", "00")))))
				df_ArqEtq := "\p10\ponto\refeitorio"+cf_Sigla+".txt"
				If File(df_ArqEtq)
					FERASE(df_ArqEtq)
					nHandle := FCREATE(df_ArqEtq, FC_NORMAL)
					FCLOSE(nHandle)
				Else
					nHandle := FCREATE(df_ArqEtq, FC_NORMAL)
					FCLOSE(nHandle)
				EndIf
				nTerHdl := FOPEN(df_ArqEtq,FO_WRITE)
				nTamArq := FSEEK(nTerHdl,0,0)
			EndIf
			If Substr(aDados2[hhi][3],1,1) == "0"
				fr_Refeit := +;
				Padr(StrZero(Val(aDados2[hhi][3]),15)                 ,015)+;
				Padr(GravaData(ctod(aDados2[hhi][5]),.F.,1)           ,006)+;
				Padr(Substr(aDados2[hhi][6],1,2)                      ,002)+;
				Padr(Substr(aDados2[hhi][6],4,2)                      ,002)+;
				Padr(cf_relog                                         ,002)
				FWRITE(nTerHdl,  fr_Refeit + CRLF )
			EndIf

			If hhi+1 > Len(aDados2)
				FCLOSE(nTerHdl)
				MsgINFO("Arquivo: " + df_ArqEtq + " foi gerado!!!")
			Else
				If cf_Empre <> aDados2[hhi+1][7]
					FCLOSE(nTerHdl)
					MsgINFO("Arquivo: " + df_ArqEtq + " foi gerado!!!")
				EndIf
			EndIf

		Next hhi

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ftBuscCC()

	Local sdArea := GetArea()

	A0002 := " SELECT RA_MAT MATRIC,
	A0002 += "        CCLVL
	A0002 += "   FROM (SELECT RA_MAT,
	A0002 += "                CASE
	// Retirado em 28/09/15 a pedido de Jessica - OS 3606-15
	//A0002 += "                  WHEN CCP <> '        ' THEN CCP
	A0002 += "                  WHEN CCP <> '        ' AND 1 = 2 THEN CCP
	A0002 += "                  ELSE RA_CLVL
	A0002 += "                END CCLVL
	A0002 += "           FROM (SELECT RA_MAT,
	A0002 += "                        RA_CLVL,
	A0002 += "                        ISNULL((SELECT MAX(RE_CCP)
	//A0002 += "                                  FROM SRE"+A001->EMP_FIL+"0"  // Retirado em 30/04/13 porque a tabela de Transferência foi unificada para atender a transferência entre empresas
	A0002 += "                                  FROM " + RetSqlName("SRE")
	A0002 += "                                 WHERE RE_FILIAL = '"+xFilial("SRE")+"'
	A0002 += "                                   AND RE_MATP = RA_MAT
	A0002 += "                                   AND RE_DATA IN (SELECT MAX(RE_DATA)
	A0002 += "                                                     FROM " + RetSqlName("SRE")
	A0002 += "                                                    WHERE RE_FILIAL = '"+xFilial("SRE")+"'
	A0002 += "                                                      AND RE_MATP = RA_MAT
	A0002 += "                                                      AND RE_DATA <= '"+dtos(ctod(fr_DatRf))+"'
	A0002 += "                                                      AND RE_EMPP = '"+A001->EMP_FIL+"'
	A0002 += "                                                      AND D_E_L_E_T_ = ' ')
	A0002 += "                                   AND RE_EMPP = '"+A001->EMP_FIL+"'
	A0002 += "                                   AND D_E_L_E_T_ = ' '), '         ') CCP
	A0002 += "                   FROM SRA"+A001->EMP_FIL+"0 SRA
	A0002 += "                  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
	A0002 += "                    AND RA_MAT BETWEEN '000000' AND '199999'
	A0002 += "                    AND RA_ADMISSA <= '"+dtos(ctod(fr_DatRf))+"'
	A0002 += "                    AND D_E_L_E_T_ = ' ') AS CENTROC) AS CCUST2
	TcQuery A0002 New Alias "A002"
	dbSelectArea("A002")
	dbGoTop()
	While !Eof()

		aAdd(aVetFcc, {A002->MATRIC, A002->CCLVL} )

		dbSelectArea("A002")
		dbSkip()
	End
	A002->(dbCloseArea())

	RestArea(sdArea)

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
	aAdd(aRegs,{cPerg,"01","Da Data                 ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data                ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Gerar arq. p/ Integração?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Horário                 ?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Almoço","","","","","Desjejum","","","","","","","","","","","","","","","","","","",""})

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
