#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA671
Empresa   := Biancogres Cerâmica S/A
Data      := 12/04/16
Uso       := Ponto Eletrônico
Aplicação := Relatório de acompanhamento do Banco de Horas
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA671()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local xt
	
	Local _cSitIn	:=	""
	
	Local _nI   
	
	Private nDiasLim 	:= GetNewPar("MV_YDIASBH", 90)
	Private xCtrlFch    := stod(Substr(GetNewPar("MV_PONMES", "20160211/20160310"),1,8))    // Por Marcos Alberto Soprani em 25/04/16...
	Private xCtrlUlt    := stod(Substr(GetNewPar("MV_PONMES", "20160211/20160310"),10,8))   // Por Marcos Alberto Soprani em 25/04/16...

	fPerg := "BIA671"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	//                                                                                           Regras geral para cálculo
	//********************************************************************************************************************
	//   - NO fechamento mensal, depois de efetuados todos os ajutes de ponto e concluído o cálculo mensal, executar este
	//   com a data (Período até) igual à data INICIO do período do ponto em aberto.
	//   - NA rescisão, além da matrícula "De" "Até" serem iguais, a data de REFERÊNCIA tem que ser igual a DATA do DIA
	//   date()
	//********************************************************************************************************************

	//                            Se for rescisao considerar apenas o "Matricula De", deve ser feito para cada funcionario
	//********************************************************************************************************************

	If MV_PAR04 == 1                                                                                           // Rescisão
		******************************************************************************************************************

		If ( MV_PAR03 <> MV_PAR02 )
			MsgAlert("Para a opção RESCISÃO somente é possível executar a rotina para uma única matrícula!","ATENÇÃO!!!")
			Return
		EndIf

		MV_PAR03 := MV_PAR02
		MV_PAR01 := Date() + 1

	ElseIf MV_PAR04 == 2                                                                                     // Fechamento
		******************************************************************************************************************

		If MV_PAR01 <> xCtrlUlt
			MsgAlert("A Data REFERÊNCIA para Fechamento tem que ser a mesma do último dia do período do ponto. Favor verificar!!!" , "ATENÇÃO!!!")
			Return
		EndIf

	ElseIf MV_PAR04 == 3                                                                                 // Acompanhamento
		******************************************************************************************************************

		If MV_PAR01 <> xCtrlFch
			MsgAlert("A Data REFERÊNCIA para Acompanhmento tem que ser a mesma do primeiro dia do período do ponto. Favor verificar!!!" , "ATENÇÃO!!!")
			Return
		EndIf

	EndIf


	For _nI:=1 to Len(MV_PAR08)
		_cSitIn += "'"+Subs(MV_PAR08,_nI,1)+"'"
		If ( _nI+1 ) <= Len(MV_PAR08)
			_cSitIn += "," 
		EndIf
	Next _nI  

	xArqGerd := ""

	JF002 := " SELECT 'FECHADO' PONTO, "
	JF002 += "        RA_YSEMAIL SUPER, "
	JF002 += "        PI_MAT MATRIC, "
	JF002 += "        RA_NOME NOME, "
	JF002 += "        RA_CLVL CLVL, "
	JF002 += "        PI_DATA DTREF, "
	JF002 += "        PI_PD EVENTO, "
	JF002 += "        P9_DESC D_EVENTO, "
	JF002 += "        CASE "
	JF002 += "          WHEN P9_CLASEV = '01' THEN 'HORA EXTRA' "
	JF002 += "          WHEN P9_CLASEV = '02' THEN 'FALTA' "
	JF002 += "          WHEN P9_CLASEV = '03' THEN 'ATRASO' "
	JF002 += "          WHEN P9_CLASEV = '04' THEN 'SAIDA NO EXPD' "
	JF002 += "          WHEN P9_CLASEV = '05' THEN 'SAIDA ANTECIPADA' "
	JF002 += "          WHEN P9_CLASEV = 'ZZ' THEN 'OUTROS' "
	JF002 += "        END CLASSIF, "
	JF002 += "        PI_YHORIG HORIG, "
	JF002 += "        PI_QUANTV QUANT, "
	JF002 += "        CASE "
	JF002 += "          WHEN P9_CLASEV IN('02','03','04','05','ZZ') THEN (-1) "
	JF002 += "          ELSE 1 "
	JF002 += "        END TPMOV, "
	JF002 += "        Convert(Char(10),convert(datetime, PI_YDTLIM ),112) DTLIM, "
	JF002 += "        PI_YCOMPE COMPENS, "
	JF002 += "        CASE "
	JF002 += "          WHEN PI_YDTCOM = '        ' THEN '          ' "
	JF002 += "          ELSE Convert(Char(10),convert(datetime, PI_YDTCOM ),112) "
	JF002 += "        END DTCOMP, "
	JF002 += "        PI_STATUS XTATUS "
	JF002 += "   FROM "+RetSqlName("SPI")+" SPI "
	JF002 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"' "
	JF002 += "                       AND RA_MAT = PI_MAT "
	JF002 += "						AND RA_SITFOLH IN ( " +_cSitIn+ ")	"
	If MV_PAR04 == 1
		JF002 += "                       AND RA_SITFOLH <> 'D' "
	EndIf
	If !Empty(MV_PAR05)
		JF002 += "                       AND RTRIM(RA_YSEMAIL) = '"+Alltrim(MV_PAR05)+"' "
	EndIf
	JF002 += "                       AND SRA.D_E_L_E_T_ = ' ' "
	JF002 += "  INNER JOIN "+RetSqlName("SP9")+" SP9 ON P9_FILIAL = '"+xFilial("SP9")+"' "
	JF002 += "                       AND P9_CODIGO = PI_PD "
	JF002 += "                       AND SP9.D_E_L_E_T_ = ' ' "
	JF002 += "  WHERE PI_FILIAL = '"+xFilial("SPI")+"' "
	JF002 += "    AND PI_MAT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "
	JF002 += "    AND PI_DATA < '"+dtos(MV_PAR01)+"' "
	//If MV_PAR07 == 1
	//	JF002 += "                       AND PI_STATUS = ' ' "
	//EndIf
	JF002 += "    AND SPI.D_E_L_E_T_ = ' ' "
	JF002 += "  UNION ALL "
	// Ponto Original Aberto
	JF002 += " SELECT 'ABERTO(O)' PONTO, "
	JF002 += "        RA_YSEMAIL SUPER, "
	JF002 += "        PC_MAT MATRIC, "
	JF002 += "        RA_NOME NOME, "
	JF002 += "        RA_CLVL CLVL, "
	JF002 += "        PC_DATA DTREF, "
	JF002 += "        PC_PD EVENTO, "
	JF002 += "        P9_DESC D_EVENTO, "
	JF002 += "        CASE "
	JF002 += "          WHEN P9_CLASEV = '01' THEN 'HORA EXTRA' "
	JF002 += "          WHEN P9_CLASEV = '02' THEN 'FALTA' "
	JF002 += "          WHEN P9_CLASEV = '03' THEN 'ATRASO' "
	JF002 += "          WHEN P9_CLASEV = '04' THEN 'SAIDA NO EXPD' "
	JF002 += "          WHEN P9_CLASEV = '05' THEN 'SAIDA ANTECIPADA' "
	JF002 += "          WHEN P9_CLASEV = 'ZZ' THEN 'OUTROS' "
	JF002 += "        END CLASSIF, "
	JF002 += "        PC_QUANTC HORIG, "
	JF002 += "        PC_QUANTC QUANT, "
	JF002 += "        CASE "
	JF002 += "          WHEN P9_CLASEV IN('02','03','04','05','ZZ') THEN (-1) "
	JF002 += "          ELSE 1 "
	JF002 += "        END TPMOV, "
	JF002 += "        Convert(Char(10),convert(datetime, PC_DATA )+"+Alltrim(Str(nDiasLim))+",112) DTLIM, "
	JF002 += "        ' ' COMPENS, "
	JF002 += "        '        ' DTCOMP, "
	JF002 += "        ' ' XTATUS "
	JF002 += "   FROM "+RetSqlName("SPC")+" SPC "
	JF002 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"' "
	JF002 += "                       AND RA_MAT = PC_MAT "
	If MV_PAR04 == 1
		JF002 += "                       AND RA_SITFOLH <> 'D' "
	EndIf
	If !Empty(MV_PAR05)
		JF002 += "                       AND RTRIM(RA_YSEMAIL) = '"+Alltrim(MV_PAR05)+"' "
	EndIf
	JF002 += "                       AND SRA.RA_ACUMBH <> 'N' " //Inserido por Gabriel Rossi Mafioletti - Ticket 7534
	JF002 += "                       AND SRA.D_E_L_E_T_ = ' ' "
	JF002 += "  INNER JOIN "+RetSqlName("SP9")+" SP9 ON P9_FILIAL = '"+xFilial("SP9")+"' "
	JF002 += "                       AND P9_CODIGO = PC_PD "
	JF002 += "                       AND SP9.P9_BHORAS = 'S' "
	JF002 += "                       AND SP9.D_E_L_E_T_ = ' ' "
	JF002 += "  WHERE PC_FILIAL = '"+xFilial("SPC")+"' "
	JF002 += "    AND PC_MAT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "
	JF002 += "    AND PC_DATA >= '"+dtos(MV_PAR01)+"' "
	JF002 += "    AND SPC.D_E_L_E_T_ = ' ' "
	JF002 += "  UNION ALL "
	// Ponto Aberto INFORMADO
	JF002 += " SELECT 'ABERTO(A)' PONTO, "
	JF002 += "        RA_YSEMAIL SUPER, "
	JF002 += "        PC_MAT MATRIC, "
	JF002 += "        RA_NOME NOME, "
	JF002 += "        RA_CLVL CLVL, "
	JF002 += "        PC_DATA DTREF, "
	JF002 += "        PC_PDI EVENTO, "
	JF002 += "        P9_DESC D_EVENTO, "
	JF002 += "        CASE "
	JF002 += "          WHEN P9_CLASEV = '01' THEN 'HORA EXTRA' "
	JF002 += "          WHEN P9_CLASEV = '02' THEN 'FALTA' "
	JF002 += "          WHEN P9_CLASEV = '03' THEN 'ATRASO' "
	JF002 += "          WHEN P9_CLASEV = '04' THEN 'SAIDA NO EXPD' "
	JF002 += "          WHEN P9_CLASEV = '05' THEN 'SAIDA ANTECIPADA' "
	JF002 += "          WHEN P9_CLASEV = 'ZZ' THEN 'OUTROS' "
	JF002 += "        END CLASSIF, "
	JF002 += "        PC_QUANTC HORIG, "
	JF002 += "        PC_QUANTC QUANT, "
	JF002 += "        CASE "
	JF002 += "          WHEN P9_CLASEV IN('02','03','04','05','ZZ') THEN (-1) "
	JF002 += "          ELSE 1 "
	JF002 += "        END TPMOV, "
	JF002 += "        Convert(Char(10),convert(datetime, PC_DATA )+"+Alltrim(Str(nDiasLim))+",112) DTLIM, "
	JF002 += "        ' ' COMPENS, "
	JF002 += "        '        ' DTCOMP, "
	JF002 += "        ' ' XTATUS "
	JF002 += "   FROM "+RetSqlName("SPC")+" SPC "
	JF002 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"' "
	JF002 += "                       AND RA_MAT = PC_MAT "
	If MV_PAR04 == 1
		JF002 += "                       AND RA_SITFOLH <> 'D' "
	EndIf
	If !Empty(MV_PAR05)
		JF002 += "                       AND RTRIM(RA_YSEMAIL) = '"+Alltrim(MV_PAR05)+"' "
	EndIf
	JF002 += "                       AND SRA.D_E_L_E_T_ = ' ' "
	JF002 += "  INNER JOIN "+RetSqlName("SP9")+" SP9 ON P9_FILIAL = '"+xFilial("SP9")+"' "
	JF002 += "                       AND P9_CODIGO = PC_PDI "
	JF002 += "                       AND SP9.P9_BHORAS = 'S' "
	JF002 += "                       AND SP9.D_E_L_E_T_ = ' ' "
	JF002 += "  WHERE PC_FILIAL = '"+xFilial("SPC")+"' "
	JF002 += "    AND PC_MAT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "
	JF002 += "    AND PC_DATA >= '"+dtos(MV_PAR01)+"' "
	JF002 += "    AND SPC.D_E_L_E_T_ = ' ' "
	JF002 += "  UNION ALL "
	// Ponto Aberto ABONADO
	JF002 += " SELECT 'ABERTO(B)' PONTO, "
	JF002 += "        RA_YSEMAIL SUPER, "
	JF002 += "        PC_MAT MATRIC, "
	JF002 += "        RA_NOME NOME, "
	JF002 += "        RA_CLVL CLVL, "
	JF002 += "        PC_DATA DTREF, "
	JF002 += "        PC_PDI EVENTO, "
	JF002 += "        P9_DESC D_EVENTO, "
	JF002 += "        CASE "
	JF002 += "          WHEN P9_CLASEV = '01' THEN 'HORA EXTRA' "
	JF002 += "          WHEN P9_CLASEV = '02' THEN 'FALTA' "
	JF002 += "          WHEN P9_CLASEV = '03' THEN 'ATRASO' "
	JF002 += "          WHEN P9_CLASEV = '04' THEN 'SAIDA NO EXPD' "
	JF002 += "          WHEN P9_CLASEV = '05' THEN 'SAIDA ANTECIPADA' "
	JF002 += "          WHEN P9_CLASEV = 'ZZ' THEN 'OUTROS' "
	JF002 += "        END CLASSIF, "
	JF002 += "        PC_QTABONO HORIG, "
	JF002 += "        PC_QTABONO QUANT, "
	JF002 += "        CASE "
	JF002 += "          WHEN P9_CLASEV IN('02','03','04','05','ZZ') THEN (-1) "
	JF002 += "          ELSE 1 "
	JF002 += "        END TPMOV, "
	JF002 += "        Convert(Char(10),convert(datetime, PC_DATA )+"+Alltrim(Str(nDiasLim))+",112) DTLIM, "
	JF002 += "        ' ' COMPENS, "
	JF002 += "        '        ' DTCOMP, "
	JF002 += "        ' ' XTATUS "
	JF002 += "   FROM "+RetSqlName("SPC")+" SPC "
	JF002 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"' "
	JF002 += "                       AND RA_MAT = PC_MAT "
	If MV_PAR04 == 1
		JF002 += "                       AND RA_SITFOLH <> 'D' "
	EndIf
	If !Empty(MV_PAR05)
		JF002 += "                       AND RTRIM(RA_YSEMAIL) = '"+Alltrim(MV_PAR05)+"' "
	EndIf
	JF002 += "                       AND SRA.D_E_L_E_T_ = ' ' "
	JF002 += "  INNER JOIN "+RetSqlName("SP6")+" SP6 ON P6_FILIAL = '"+xFilial("SP6")+"' "
	JF002 += "                       AND P6_CODIGO = PC_ABONO "
	JF002 += "                       AND P6_ABHORAS = 'S' "
	JF002 += "                       AND SP6.D_E_L_E_T_ = ' ' "
	JF002 += "  INNER JOIN "+RetSqlName("SP9")+" SP9 ON P9_FILIAL = '"+xFilial("SP9")+"' "
	JF002 += "                       AND P9_CODIGO = P6_EVENTO "
	JF002 += "                       AND P9_BHORAS = 'S' "
	JF002 += "                       AND SP9.D_E_L_E_T_ = ' ' "
	JF002 += "  WHERE PC_FILIAL = '"+xFilial("SPC")+"' "
	JF002 += "    AND PC_MAT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "
	JF002 += "    AND PC_DATA >= '"+dtos(MV_PAR01)+"' "
	JF002 += "    AND SPC.D_E_L_E_T_ = ' ' "
	JF002 += "  ORDER BY 2, 3, 6, 1 DESC "
	JFcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,JF002),'JF02',.F.,.T.)
	dbSelectArea("JF02")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento..." + Alltrim(JF02->SUPER))

		oExcel := FWMSEXCEL():New()

		yvPlan := "Parâmetros"
		yvTabl := "Relação de Parâmetros utilizados para filtros"

		oExcel:AddworkSheet(yvPlan)
		oExcel:AddTable (yvPlan, yvTabl)
		oExcel:AddColumn(yvPlan, yvTabl, "Grupo"              ,1,1)
		oExcel:AddColumn(yvPlan, yvTabl, "Ordem"              ,1,1)
		oExcel:AddColumn(yvPlan, yvTabl, "Pergunta"           ,1,1)
		oExcel:AddColumn(yvPlan, yvTabl, "Presel"             ,1,1)
		oExcel:AddColumn(yvPlan, yvTabl, "CNT01"              ,1,1)
		oExcel:AddColumn(yvPlan, yvTabl, "Def01"              ,1,1)
		oExcel:AddColumn(yvPlan, yvTabl, "Def02"              ,1,1)
		oExcel:AddColumn(yvPlan, yvTabl, "Def03"              ,1,1)
		oExcel:AddColumn(yvPlan, yvTabl, "Def04"              ,1,1)
		oExcel:AddColumn(yvPlan, yvTabl, "Def05"              ,1,1)
		dbSelectArea("SX1")
		dbSetOrder(1)
		If dbSeek(PADR(fPerg,fTamX1))

			While !Eof() .and. SX1->X1_GRUPO == PADR(fPerg,fTamX1)

				oExcel:AddRow(yvPlan, yvTabl, { SX1->X1_GRUPO           ,;
				SX1->X1_ORDEM                                           ,;
				SX1->X1_PERGUNT                                         ,;
				SX1->X1_PRESEL                                          ,;
				SX1->X1_CNT01                                           ,;
				SX1->X1_DEF01                                           ,;
				SX1->X1_DEF02                                           ,;
				SX1->X1_DEF03                                           ,;
				SX1->X1_DEF04                                           ,;
				SX1->X1_DEF05                                           })		

				dbSelectArea("SX1")
				dbSkip()

			End

			lrSetPar := dtoc(Date()) + ", " + Time() + ", " + Alltrim(cUserName) + ", " + GetNewPar("MV_PONMES", "20160211/20160310")
			
			oExcel:AddRow(yvPlan, yvTabl, { ""                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      })		

			oExcel:AddRow(yvPlan, yvTabl, { ""                      ,;
			""                                                      ,;
			"Data, Hora e Usuário do Processamento, MV_PONMES"      ,;
			""                                                      ,;
			lrSetPar                                                ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      })		


		EndIf
		dbSelectArea("JF02")

		nxPlan := "Planilha 01"
		nxTabl := "Acompanhamento de Banco de Horas - SEXAGEMAL (HORA RELÓGIO)"

		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)
		oExcel:AddColumn(nxPlan, nxTabl, "EMPR"               ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PONTO"              ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "SUPER"              ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "MATRIC"             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "NOME"               ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CLVL"               ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DTREF"              ,1,4)
		oExcel:AddColumn(nxPlan, nxTabl, "EVENTO"             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "D_EVENTO"           ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CLASSIF"            ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "HORIG"              ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "QUANT"              ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "SALDOFUNC"          ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "SALDOSUPR"          ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "DTLIM"              ,1,4)
		oExcel:AddColumn(nxPlan, nxTabl, "COMPENS"            ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DTCOMP"             ,1,4)
		oExcel:AddColumn(nxPlan, nxTabl, "STATUS"             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "ConvHoras"          ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DataCompens"        ,1,4)
		oExcel:AddColumn(nxPlan, nxTabl, "HorasPagas"         ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "HorasAcum"          ,3,2)

		kjSuper := JF02->SUPER
		kjHrSpr := 0
		While !Eof() .and. JF02->SUPER == kjSuper

			kjMatric := JF02->MATRIC
			kjHrMtr  := 0
			kjAcHrOr := 0
			While !Eof() .and. JF02->SUPER == kjSuper .and. JF02->MATRIC == kjMatric

				jkHOrig := JF02->HORIG * JF02->TPMOV
				jkQuant := JF02->QUANT * JF02->TPMOV
				jkHrPgt := 0

				// Tratamento esperimental, pois teremos casos em que o registro foi baixado devido datalimite ultrapassada ou por demissao... Sobre acompanhamento em 13/05/16
				If JF02->XTATUS == "B"
					jkQuant := 0
				EndIf
				If JF02->XTATUS == "B" .and. Empty(JF02->COMPENS)
					jkHrPgt := JF02->QUANT * JF02->TPMOV 
				EndIf

				If jkQuant <> 0

					// Adição
					kjFator := 0
					If JF02->TPMOV < 0
						// Subtração
						kjFator := 1
					EndIf

					//                                                        Acumula Saldo Matricula
					//*******************************************************************************
					bkpSinal := 1
					bkpFator := kjFator
					// Se o Saldo de horas é NEGATIVO
					If kjHrMtr < 0
						bkpSinal := (-1)
						// ... e o próximo item for POSITICO (subrai)
						If kjFator == 0
							kjFator  := 1
						Else
							// ... e o próximo item for NEGATIVO (soma)
							If kjFator == 1
								kjFator := 0
							EndIf
						EndIf
					EndIf

					_cAliasHex := GetNextAlias()
					BeginSql Alias _cAliasHex
					%NoParser%
					select CALC = dbo.FN_HORAHEXDIFF(%EXP:kjHrMtr%, %EXP:jkQuant%, %EXP:kjFator%)
					EndSql
					kjHrMtr := (_cAliasHex)->CALC * bkpSinal
					(_cAliasHex)->(DbCloseArea())
					_cAliasHex := GetNextAlias()

					//                                                       Acumula Saldo Supervisor
					//*******************************************************************************
					bkpSinal := 1
					kjFator := bkpFator
					// Se o Saldo de horas é NEGATIVO
					If kjHrSpr < 0
						bkpSinal := (-1)
						// ... e o próximo item for POSITICO (subrai)
						If kjFator == 0
							kjFator  := 1
						Else
							// ... e o próximo item for NEGATIVO (soma)
							If kjFator == 1
								kjFator := 0
							EndIf
						EndIf
					EndIf

					BeginSql Alias _cAliasHex
					%NoParser%
					select CALC = dbo.FN_HORAHEXDIFF(%EXP:kjHrSpr%, %EXP:jkQuant%, %EXP:kjFator%)
					EndSql
					kjHrSpr := (_cAliasHex)->CALC * bkpSinal
					(_cAliasHex)->(DbCloseArea())

				EndIf

				// Em 29/07/16... devido dúvidas geradas pelo setor de DP - Carolina
				If jkHOrig > 0
					kjAcHrOr := SomaHoras(kjAcHrOr, JF02->HORIG)
				Else
					kjAcHrOr := SubHoras(kjAcHrOr, JF02->HORIG)
				EndIf
				If jkHrPgt > 0
					kjAcHrOr := SubHoras(kjAcHrOr, JF02->QUANT)
				ElseIf  jkHrPgt < 0
					kjAcHrOr := SomaHoras(kjAcHrOr, JF02->QUANT)
				EndIf

				If MV_PAR07 == 2 .or. (MV_PAR07 == 1 .and. JF02->XTATUS == " ")

					oExcel:AddRow(nxPlan, nxTabl, { cEmpAnt                 ,;
					JF02->PONTO                                             ,;
					JF02->SUPER                                             ,;
					JF02->MATRIC                                            ,;
					JF02->NOME                                              ,;
					JF02->CLVL                                              ,;
					stod(JF02->DTREF)                                       ,;
					JF02->EVENTO                                            ,;
					JF02->D_EVENTO                                          ,;
					JF02->CLASSIF                                           ,;
					jkHOrig                                                 ,;
					jkQuant                                                 ,;
					kjHrMtr                                                 ,;
					kjHrSpr                                                 ,;
					stod(JF02->DTLIM)                                       ,;
					JF02->COMPENS                                           ,;
					stod(JF02->DTCOMP)                                      ,;
					JF02->XTATUS                                            ,;
					""                                                      ,;
					""                                                      ,;
					jkHrPgt                                                 ,;
					kjAcHrOr                                                })

				EndIf

				dbSelectArea("JF02")
				dbSkip()

			End

			oExcel:AddRow(nxPlan, nxTabl, { ""                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      ,;
			""                                                      })

		End

		EmlSuprX := ""
		If At("@",kjSuper) > 0
			EmlSuprX := Substr(kjSuper, 1, At("@",kjSuper)-1)
			EmlSuprX := StrTran( EmlSuprX, ".", "_" )
		Else
			EmlSuprX := Alltrim(kjSuper)
		EndIf

		xArqTemp := "banco_horas - " + cEmpAnt + " - " + EmlSuprX + " - " + dtos(MV_PAR01)

		xArqGerd += xArqTemp+".xml" + CHR(13) + CHR(10)

		If File("C:\TEMP\"+xArqTemp+".xml")
			If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
				Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
			EndIf
		EndIf

		oExcel:Activate()
		oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

		oExcel := FWMsExcel():DeActivate()

	End

	Aviso('Acomp. Banco de Horas', 'Os seguintes arquivos foram gerados com sucesso em: C:\TEMP\*' + CHR(13) + CHR(10) + CHR(13) + CHR(10) + xArqGerd, {'Ok'}, 3)

	JF02->(dbCloseArea())
	Ferase(JFcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(JFcIndex+OrdBagExt())          //indice gerado

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","Data de Referência       ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","De Matrícula             ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"03","Até Matrícula            ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"04","Quanto a Finalidade      ?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Rescisão","","","","","Fechamento","","","","","Acompanhamento","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Filtrar por e-mail SUPER ?","","","mv_ch5","C",85,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Enviar Arq. p/ Supervisor?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Filtrar Registro Baixado ?","","","mv_ch7","N",01,0,0,"C","","mv_par07","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
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
