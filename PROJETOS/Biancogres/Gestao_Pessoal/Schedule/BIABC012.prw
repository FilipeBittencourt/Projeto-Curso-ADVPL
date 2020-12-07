#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIABC012
@author Barbara Coelho	  
@since 25/11/2019
@version 1.0
@description Relatório de acompanhamento do Banco de Horas por Gerente
@type function
/*/

User Function BIABC012()

	Local x
	
	Private cDeb
	Private cCred
	Private cTot
	Private cDebi
	Private cCredi
	Private cTota

	cDeb := ""
	cCred := ""
	cTot := ""
	cDebi := ""
	cCredi := ""
	cTota := ""

	If Select("SX6") == 0
		xv_Emps    := U_BAGtEmpr("01")

		For x := 1 to Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

			DbSelectArea("SX6")

			Conout("BIABC012 - Dia da semana corrente: " + Alltrim(DiaSemana( Date() )))

			RptDetail(2)

			//Finaliza o ambiente criado
			RpcClearEnv()

		Next	

	ELSE 
		Processa({|| RptDetail(3)})
	ENDIF
Return

Static Function RptDetail(cReto)

	Local xt
	Local _nI   
	Local cSuper  := ""
	Local cMat    := "" 
	
	Local cNome   := "" 
	Local cEmail  := ""
	Local cClvl   := ""  
	Local aColabHE := {}   

	Private nDiasLim 	:= GetNewPar("MV_YDIASBH", 90)
	Private xCtrlFch    := stod(Substr(GetNewPar("MV_PONMES", "20160211/20160310"),1,8))    // Por Marcos Alberto Soprani em 25/04/16...
	Private xCtrlUlt    := stod(Substr(GetNewPar("MV_PONMES", "20160211/20160310"),10,8))   // Por Marcos Alberto Soprani em 25/04/16...
	Private cEnter := CHR(13)+CHR(10)

	IF cReto == 2

		MV_PAR01 := STOD(SUBSTR(GETMV("MV_PONMES"),1,8)) //Data de Referência 
		MV_PAR02 := ''  //De Matrícula
		MV_PAR03 := '999999' //Até Matrícula
		MV_PAR04 := '' //Filtrar por e-mail GERENTE
		MV_PAR05 := 2  //Enviar Arq. p/ Gerente
		MV_PAR06 := 1  //Arq. Colab. c/ BH a 100%
		MV_PAR07 := 2  //Eventos Integrados ao BH

	ELSEIF cReto == 3
		fPerg := "BIABC012"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		fValidPerg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf
		MV_PAR01 := STOD(SUBSTR(GETMV("MV_PONMES"),1,8))
	Else

		// Verificar a configuração desta regra
		Return()

	ENDIF

	xArqGerd := ""

	JF002 := " SELECT 'FECHADO' PONTO, " + cEnter
	JF002 += "        RA_YSUPEML GERENTE, " + cEnter
	JF002 += "        RA_YSEMAIL SUPER, " + cEnter
	JF002 += "        PI_MAT MATRIC, " + cEnter
	JF002 += "        RA_NOME NOME, " + cEnter
	JF002 += "        RA_CLVL CLVL, " + cEnter
	JF002 += "        PI_DATA DTREF, " + cEnter
	JF002 += "        PI_PD EVENTO, " + cEnter
	JF002 += "        P9_DESC D_EVENTO, " + cEnter
	JF002 += "        CASE " + cEnter
	JF002 += "          WHEN P9_CLASEV = '01' THEN 'HORA EXTRA' " + cEnter
	JF002 += "          WHEN P9_CLASEV = '02' THEN 'FALTA' " + cEnter
	JF002 += "          WHEN P9_CLASEV = '03' THEN 'ATRASO' " + cEnter
	JF002 += "          WHEN P9_CLASEV = '04' THEN 'SAIDA NO EXPD' " + cEnter
	JF002 += "          WHEN P9_CLASEV = '05' THEN 'SAIDA ANTECIPADA' " + cEnter
	JF002 += "          WHEN P9_CLASEV = 'ZZ' THEN 'OUTROS' " + cEnter
	JF002 += "        END CLASSIF, " + cEnter
	JF002 += "        PI_YHORIG HORIG, " + cEnter
	JF002 += "        PI_QUANTV QUANT, " + cEnter
	JF002 += "        CASE " + cEnter
	JF002 += "          WHEN P9_CLASEV IN('02','03','04','05','ZZ') THEN (-1) " + cEnter
	JF002 += "          ELSE 1 " + cEnter
	JF002 += "        END TPMOV, " + cEnter
	JF002 += "        Convert(Char(10),convert(datetime, PI_YDTLIM ),112) DTLIM, " + cEnter
	JF002 += "        PI_YCOMPE COMPENS, " + cEnter
	JF002 += "        CASE " + cEnter
	JF002 += "          WHEN PI_YDTCOM = '        ' THEN '          ' " + cEnter
	JF002 += "          ELSE Convert(Char(10),convert(datetime, PI_YDTCOM ),112) " + cEnter
	JF002 += "        END DTCOMP, " + cEnter
	JF002 += "        PI_STATUS XTATUS " + cEnter
	JF002 += "   FROM "+RetSqlName("SPI")+" SPI " + cEnter
	JF002 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"' " + cEnter
	JF002 += "                       AND RA_MAT = PI_MAT " + cEnter
	JF002 += "                       AND RA_SITFOLH <> 'D' " + cEnter
	If !Empty(MV_PAR04)
		JF002 += "                       AND RTRIM(RA_YSUPEML) = '"+Alltrim(MV_PAR04)+"' " + cEnter
	EndIf
	JF002 += "                       AND SRA.D_E_L_E_T_ = ' ' " + cEnter
	JF002 += "  INNER JOIN "+RetSqlName("SP9")+" SP9 ON P9_FILIAL = '"+xFilial("SP9")+"' " + cEnter
	JF002 += "                       AND P9_CODIGO = PI_PD " + cEnter
	JF002 += "                       AND SP9.D_E_L_E_T_ = ' ' " + cEnter
	JF002 += "  WHERE PI_FILIAL = '"+xFilial("SPI")+"' " + cEnter
	JF002 += "    AND PI_MAT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' " + cEnter
	JF002 += "    AND PI_DATA <= '"+dtos(MV_PAR01)+"' " + cEnter
	JF002 += "    AND SPI.D_E_L_E_T_ = ' ' " + cEnter

	If MV_PAR07 == 2

		JF002 += "  UNION ALL " + cEnter
		// Ponto Original Aberto
		JF002 += " SELECT 'ABERTO(O)' PONTO, " + cEnter
		JF002 += "        RA_YSUPEML GERENTE, " + cEnter
		JF002 += "        RA_YSEMAIL SUPER, " + cEnter
		JF002 += "        PC_MAT MATRIC, " + cEnter
		JF002 += "        RA_NOME NOME, " + cEnter
		JF002 += "        RA_CLVL CLVL, " + cEnter
		JF002 += "        PC_DATA DTREF, " + cEnter
		JF002 += "        PC_PD EVENTO, " + cEnter
		JF002 += "        P9_DESC D_EVENTO, " + cEnter
		JF002 += "        CASE " + cEnter
		JF002 += "          WHEN P9_CLASEV = '01' THEN 'HORA EXTRA' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '02' THEN 'FALTA' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '03' THEN 'ATRASO' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '04' THEN 'SAIDA NO EXPD' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '05' THEN 'SAIDA ANTECIPADA' " + cEnter
		JF002 += "          WHEN P9_CLASEV = 'ZZ' THEN 'OUTROS' " + cEnter
		JF002 += "        END CLASSIF, " + cEnter
		JF002 += "        PC_QUANTC HORIG, " + cEnter
		JF002 += "        CASE " + cEnter
		JF002 += "          WHEN P9_BHPERC = 200 THEN" + cEnter
		JF002 += "             replace(convert(varchar(5),(convert(smalldatetime,replace(CONVERT(NUMERIC(14,2),PC_QUANTC),'.',':')) + " + cEnter
		JF002 += "                                         convert(smalldatetime,replace(CONVERT(NUMERIC(14,2),PC_QUANTC),'.',':'))),108),':','.')" + cEnter
		JF002 += "        ELSE" + cEnter
		JF002 += "	           convert(varchar,PC_QUANTC)" + cEnter
		JF002 += "        END QUANT, " + cEnter
		JF002 += "        CASE " + cEnter
		JF002 += "          WHEN P9_CLASEV IN('02','03','04','05','ZZ') THEN (-1) " + cEnter
		JF002 += "          ELSE 1 " + cEnter
		JF002 += "        END TPMOV, " + cEnter
		JF002 += "        Convert(Char(10),convert(datetime, PC_DATA )+"+Alltrim(Str(nDiasLim))+",112) DTLIM, " + cEnter
		JF002 += "        ' ' COMPENS, " + cEnter
		JF002 += "        '        ' DTCOMP, " + cEnter
		JF002 += "        ' ' XTATUS " + cEnter
		JF002 += "   FROM "+RetSqlName("SPC")+" SPC " + cEnter
		JF002 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"' " + cEnter
		JF002 += "                       AND RA_MAT = PC_MAT " + cEnter
		JF002 += "                       AND RA_SITFOLH <> 'D' " + cEnter
		If !Empty(MV_PAR04)
			JF002 += "                       AND RTRIM(RA_YSUPEML) = '"+Alltrim(MV_PAR04)+"' " + cEnter
		EndIf
		JF002 += "                       AND SRA.RA_ACUMBH <> 'N' "  + cEnter//Inserido por Gabriel Rossi Mafioletti - Ticket 7534
		JF002 += "                       AND SRA.D_E_L_E_T_ = ' ' " + cEnter
		JF002 += "  INNER JOIN "+RetSqlName("SP9")+" SP9 ON P9_FILIAL = '"+xFilial("SP9")+"' " + cEnter
		JF002 += "                       AND P9_CODIGO = PC_PD " + cEnter
		JF002 += "                       AND SP9.P9_BHORAS = 'S' " + cEnter
		JF002 += "                       AND SP9.D_E_L_E_T_ = ' ' " + cEnter
		JF002 += "  WHERE PC_FILIAL = '"+xFilial("SPC")+"' " + cEnter
		JF002 += "    AND PC_MAT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' " + cEnter
		JF002 += "    AND PC_DATA > '"+dtos(MV_PAR01)+"' " + cEnter
		JF002 += "    AND SPC.D_E_L_E_T_ = ' ' " + cEnter
		JF002 += "  UNION ALL " + cEnter
		// Ponto Aberto INFORMADO
		JF002 += " SELECT 'ABERTO(A)' PONTO, " + cEnter
		JF002 += "        RA_YSUPEML GERENTE, " + cEnter
		JF002 += "        RA_YSEMAIL SUPER, " + cEnter
		JF002 += "        PC_MAT MATRIC, " + cEnter
		JF002 += "        RA_NOME NOME, " + cEnter
		JF002 += "        RA_CLVL CLVL, " + cEnter
		JF002 += "        PC_DATA DTREF, " + cEnter
		JF002 += "        PC_PDI EVENTO, " + cEnter
		JF002 += "        P9_DESC D_EVENTO, " + cEnter
		JF002 += "        CASE " + cEnter
		JF002 += "          WHEN P9_CLASEV = '01' THEN 'HORA EXTRA' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '02' THEN 'FALTA' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '03' THEN 'ATRASO' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '04' THEN 'SAIDA NO EXPD' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '05' THEN 'SAIDA ANTECIPADA' " + cEnter
		JF002 += "          WHEN P9_CLASEV = 'ZZ' THEN 'OUTROS' " + cEnter
		JF002 += "        END CLASSIF, " + cEnter
		JF002 += "        PC_QUANTC HORIG, " + cEnter
		JF002 += "        CASE " + cEnter
		JF002 += "          WHEN P9_BHPERC = 200 THEN" + cEnter
		JF002 += "             replace(convert(varchar(5),(convert(smalldatetime,replace(CONVERT(NUMERIC(14,2),PC_QUANTC),'.',':')) + " + cEnter
		JF002 += "                                         convert(smalldatetime,replace(CONVERT(NUMERIC(14,2),PC_QUANTC),'.',':'))),108),':','.')" + cEnter
		JF002 += "        ELSE" + cEnter
		JF002 += "	           convert(varchar,PC_QUANTC)" + cEnter
		JF002 += "        END QUANT, " + cEnter
		JF002 += "        CASE " + cEnter
		JF002 += "          WHEN P9_CLASEV IN('02','03','04','05','ZZ') THEN (-1) " + cEnter
		JF002 += "          ELSE 1 " + cEnter
		JF002 += "        END TPMOV, " + cEnter
		JF002 += "        Convert(Char(10),convert(datetime, PC_DATA )+"+Alltrim(Str(nDiasLim))+",112) DTLIM, " + cEnter
		JF002 += "        ' ' COMPENS, " + cEnter
		JF002 += "        '        ' DTCOMP, " + cEnter
		JF002 += "        ' ' XTATUS " + cEnter
		JF002 += "   FROM "+RetSqlName("SPC")+" SPC " + cEnter
		JF002 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"' " + cEnter
		JF002 += "                       AND RA_MAT = PC_MAT " + cEnter
		JF002 += "                       AND RA_SITFOLH <> 'D' " + cEnter
		If !Empty(MV_PAR04)
			JF002 += "                       AND RTRIM(RA_YSUPEML) = '"+Alltrim(MV_PAR04)+"' " + cEnter
		EndIf
		JF002 += "                       AND SRA.D_E_L_E_T_ = ' ' " + cEnter
		JF002 += "  INNER JOIN "+RetSqlName("SP9")+" SP9 ON P9_FILIAL = '"+xFilial("SP9")+"' " + cEnter
		JF002 += "                       AND P9_CODIGO = PC_PDI " + cEnter
		JF002 += "                       AND SP9.P9_BHORAS = 'S' " + cEnter
		JF002 += "                       AND SP9.D_E_L_E_T_ = ' ' " + cEnter
		JF002 += "  WHERE PC_FILIAL = '"+xFilial("SPC")+"' " + cEnter
		JF002 += "    AND PC_MAT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' " + cEnter
		JF002 += "    AND PC_DATA > '"+dtos(MV_PAR01)+"' " + cEnter
		JF002 += "    AND SPC.D_E_L_E_T_ = ' ' " + cEnter
		JF002 += "  UNION ALL " + cEnter
		// Ponto Aberto ABONADO
		JF002 += " SELECT 'ABERTO(B)' PONTO, " + cEnter
		JF002 += "        RA_YSUPEML GERENTE, " + cEnter
		JF002 += "        RA_YSEMAIL SUPER, " + cEnter
		JF002 += "        PC_MAT MATRIC, " + cEnter
		JF002 += "        RA_NOME NOME, " + cEnter
		JF002 += "        RA_CLVL CLVL, " + cEnter
		JF002 += "        PC_DATA DTREF, " + cEnter
		JF002 += "        PC_PDI EVENTO, " + cEnter
		JF002 += "        P9_DESC D_EVENTO, " + cEnter
		JF002 += "        CASE " + cEnter
		JF002 += "          WHEN P9_CLASEV = '01' THEN 'HORA EXTRA' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '02' THEN 'FALTA' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '03' THEN 'ATRASO' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '04' THEN 'SAIDA NO EXPD' " + cEnter
		JF002 += "          WHEN P9_CLASEV = '05' THEN 'SAIDA ANTECIPADA' " + cEnter
		JF002 += "          WHEN P9_CLASEV = 'ZZ' THEN 'OUTROS' " + cEnter
		JF002 += "        END CLASSIF, " + cEnter
		JF002 += "        PC_QTABONO HORIG, " + cEnter
		JF002 += "        PC_QTABONO QUANT, " + cEnter
		JF002 += "        CASE " + cEnter
		JF002 += "          WHEN P9_CLASEV IN('02','03','04','05','ZZ') THEN (-1) " + cEnter
		JF002 += "          ELSE 1 " + cEnter
		JF002 += "        END TPMOV, " + cEnter
		JF002 += "        Convert(Char(10),convert(datetime, PC_DATA )+"+Alltrim(Str(nDiasLim))+",112) DTLIM, " + cEnter
		JF002 += "        ' ' COMPENS, " + cEnter
		JF002 += "        '        ' DTCOMP, " + cEnter
		JF002 += "        ' ' XTATUS " + cEnter
		JF002 += "   FROM "+RetSqlName("SPC")+" SPC " + cEnter
		JF002 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"' " + cEnter
		JF002 += "                       AND RA_MAT = PC_MAT " + cEnter
		JF002 += "                       AND RA_SITFOLH <> 'D' " + cEnter
		If !Empty(MV_PAR04)
			JF002 += "                       AND RTRIM(RA_YSUPEML) = '"+Alltrim(MV_PAR04)+"' " + cEnter
		EndIf
		JF002 += "                       AND SRA.D_E_L_E_T_ = ' ' " + cEnter
		JF002 += "  INNER JOIN "+RetSqlName("SP6")+" SP6 ON P6_FILIAL = '"+xFilial("SP6")+"' " + cEnter
		JF002 += "                       AND P6_CODIGO = PC_ABONO " + cEnter
		JF002 += "                       AND P6_ABHORAS = 'S' " + cEnter
		JF002 += "                       AND SP6.D_E_L_E_T_ = ' ' " + cEnter
		JF002 += "  INNER JOIN "+RetSqlName("SP9")+" SP9 ON P9_FILIAL = '"+xFilial("SP9")+"' " + cEnter
		JF002 += "                       AND P9_CODIGO = P6_EVENTO " + cEnter
		JF002 += "                       AND P9_BHORAS = 'S' " + cEnter
		JF002 += "                       AND SP9.D_E_L_E_T_ = ' ' " + cEnter
		JF002 += "  WHERE PC_FILIAL = '"+xFilial("SPC")+"' " + cEnter
		JF002 += "    AND PC_MAT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' " + cEnter
		JF002 += "    AND PC_DATA > '"+dtos(MV_PAR01)+"' " + cEnter
		JF002 += "    AND SPC.D_E_L_E_T_ = ' ' " + cEnter

	EndIf

	JF002 += "  ORDER BY 2, 4, 7, 1 DESC " + cEnter

	JFcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,JF002),'JF02',.F.,.T.)
	dbSelectArea("JF02")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IF cReto == 3

			IncProc("Processamento..." )

		ENDIF

		cDesc := "COLABORADORES - LIDERANÇA: "+ UPPER(StrTran(Substr(Alltrim(JF02->GERENTE), 1, At("@",Alltrim(JF02->GERENTE))-1), ".", " " ))

		cRet1 := ""
		cRet1 += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional	//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
		cRet1 += '<html xmlns="http://www.w3.org/1999/xhtml"> '
		cRet1 += '<head> '
		cRet1 += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
		cRet1 += '    <title>Workflow</title> '
		cRet1 += '    <style type="text/css"> '        
		cRet1 += '        <!-- ' 		
		cRet1 += '        .styleDiv{ margin: auto; width:80%; font: 12px Arial, Helvetica, sans-serif; } '
		cRet1 += '        .styleTable{ border:0; cellpadding:3; cellspacing:2; width:100%; } '		
		cRet1 += '        .styleTableCabecalho{ background: #fff; color: #000000; font: 14px Arial, Helvetica, sans-serif;  font-weight: bold; } '        
		cRet1 += '        .styleCabecalho{ background: #0c2c65; color: #ffffff; font: 12px Arial, Helvetica, sans-serif; font-weight: bold; padding: 5px; } '		
		cRet1 += '        .styleLinha{ background: #f6f6f6; color: #747474; font: 11px Arial, Helvetica, sans-serif; padding: 5px; } '        
		cRet1 += '        .styleNumerico{ text-align: right;} '
		cRet1 += '        .styleRodape{ background: #CFCFCF;color: #666666;font: 12px Arial, Helvetica, sans-serif;font-weight: bold;text-align: right;padding: 5px; } '		
		cRet1 += '        .styleLabel{ color:#0c2c65; } '		
		cRet1 += '        .styleValor{ color:#747474; } '        
		cRet1 += '        --> '   
		cRet1 += '    </style> '
		cRet1 += '</head> '
		cRet1 += '<body> '
		cRet1 += '    <div class="styleDiv"> '	
		cRet1 += '        <table cellpadding="0" cellspacing="0" width="100%"> '
		cRet1 += '            <tbody> '
		cRet1 += '               <tr class="styleTableCabecalho"> '
		cRet1 += '                    <td colspan="2" style="text-align:center;"> '
		cRet1 += '                    		<span class="styleLabel">RELATÓRIO SALDO BANCO DE HORAS</span> '
		cRet1 += '                    </td> '
		cRet1 += '                </tr> '
		cRet1 += '                <tr class="styleTableCabecalho"> '
		cRet1 += '                    <td width="20%" style="text-align:left;"> '
		cRet1 += '                    		<span class="styleLabel">Empresa:</span> '
		cRet1 += '                        <span class="styleValor">'+ Capital(FWEmpName(cEmpAnt)) +'</span> '
		cRet1 += '                    </td> '
		cRet1 += '                </tr> '                
		cRet1 += '                <tr class="styleTableCabecalho"> '
		cRet1 += '                    <td width="20%" style="text-align:left;"> '
		cRet1 += '                        <span class="styleLabel">Data:</span> '
		cRet1 += '                        <span class="styleValor">'+ dToC(dDataBase-1) +'</span> '
		cRet1 += '                    </td> '
		cRet1 += '                </tr> '                
		cRet1 += '            </tbody> '
		cRet1 += '        </table> '
		cRet1 += '        <br /> '
		cRet1 += '        <br /> '	
		cRet1 += '        <table class="styleTable" align="center"> '
		cRet1 += '            <tr class="styleTableCabecalho"> '
		cRet1 += '                <td colspan="6">'+ cDesc
		cRet1 += '                </td> '
		cRet1 += '            </tr> '
		cRet1 += '            <tr align="center"> '
		cRet1 += '                <th class="styleCabecalho" width="100" scope="col">Matricula</th> '
		cRet1 += '                <th class="styleCabecalho" width="200" scope="col">Nome</th> '
		cRet1 += '                <th class="styleCabecalho" width="60" scope="col">Email Supervisor </th> '
		cRet1 += '                <th class="styleCabecalho" width="60" scope="col">Classe </th> '
		cRet1 += '                <th class="styleCabecalho" width="150" scope="col">Crédito</th> '
		cRet1 += '                <th class="styleCabecalho" width="150" scope="col">Débito</th> '		
		cRet1 += '                <th class="styleCabecalho" width="150" scope="col">Saldo</th> '
		cRet1 += '            </tr> '

		cRet := ""

		oExcel := FWMSEXCEL():New()
		dbSelectArea("JF02")

		nxPlan := "Planilha 01"
		nxTabl := "Acompanhamento de Banco de Horas"

		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)
		oExcel:AddColumn(nxPlan, nxTabl, "Matricula"		,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "Nome"				,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "e-mail Supervisor",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "Classe"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "Crédito"			,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "Débito"			,1,1)	
		oExcel:AddColumn(nxPlan, nxTabl, "Saldo"			,3,2)

		kjSuper := Alltrim(JF02->GERENTE)
		kjHrSpr := 0
		aColabHE := {}

		While !Eof() .and. Alltrim(JF02->GERENTE) == kjSuper

			kjMatric := JF02->MATRIC
			kjHrMtr  := 0
			kjAcHrOr := 0

			While !Eof() .and. Alltrim(JF02->GERENTE) == kjSuper .and. JF02->MATRIC == kjMatric

				jkHOrig := JF02->HORIG * JF02->TPMOV
				jkQuant := JF02->QUANT * JF02->TPMOV
				jkHrPgt := 0
				cPos := ""
				cNeg := ""
				// Tratamento experimental, pois teremos casos em que o registro foi baixado devido data limite ultrapassada ou por demissao... Sobre acompanhamento em 13/05/16
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
						// ... e o próximo item for POSITIVO (subrai)
						If kjFator == 0
							kjFator  := 1
							//	cPos := cPos + JF02->QUANT
						Else
							// ... e o próximo item for NEGATIVO (soma)
							If kjFator == 1
								kjFator := 0
								//			cNeg := cNeg + JF02->QUANT
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

				// Calcula Credito e Débito 
				cMat  := JF02->MATRIC		
				cNome := JF02->NOME
				cEmail := JF02->SUPER
				cClvl := JF02->CLVL
				cTot := kjHrMtr

				IF JF02->TPMOV < 0 .AND. XTATUS <> 'B' .AND. JF02->QUANT > 0

					cDeb := __TimeSum(cDeb,JF02->QUANT)

				ELSEIF JF02->TPMOV > 0 .AND. XTATUS <> 'B' .AND. JF02->QUANT > 0

					cCred := __TimeSum(cCred,JF02->QUANT)

				ENDIF

				dbSelectArea("JF02")
				dbSkip()

			End

			//cTot := __TimeSub(cCred,cDeb)

			IF kjHrMtr <> 0

				cRet += '        <tr align=center> '
				cRet += '            <td class="styleLinha" width="100" scope="col">'+ cMat +'</td> '
				cRet += '            <td class="styleLinha" width="200" scope="col">'+ cNome +'</td> '
				cRet += '            <td class="styleLinha" width="200" scope="col">'+ cEmail +'</td> '
				cRet += '            <td class="styleLinha" width="60" scope="col">'+ cClvl +'</td> '
				cRet += '            <td class="styleLinha" width="150" scope="col">'+ cValtoChar(cCred) +'</td> '
				cRet += '            <td class="styleLinha" width="150" scope="col">'+ cValtoChar(cDeb) +'</td> '
				cRet += '            <td class="styleLinha" width="150" scope="col">'+ cValtoChar(kjHrMtr) +'</td> '
				cRet += '        </tr> '

				oExcel:AddRow(nxPlan, nxTabl, { cMat,;
				cNome								,;
				cEmail								,;
				cClvl								,;
				cCred								,;
				cDeb								,;						
				kjHrMtr								})

				oExcel:AddRow(nxPlan, nxTabl, { ""	,;
				""									,;
				""									,;
				""									,;
				""                                  ,;
				""                                  ,;
				""                                  })

				IF cReto == 3 .and. MV_PAR06 == 1 .and. kjHrMtr > 0 
					aadd(aColabHE,cMat+'|'+cValtoChar(kjHrMtr))
				endif
			ENDIF	

			cDeb 	:= ""
			cCred 	:= ""
			cCredi 	:= ""
			cDebi 	:= ""

			dbSelectArea("JF02")

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

		IF (cReto <> 3) .AND. !EMPTY(cRet)

			cRet += '        </table> '
			cRet += '        <br /> '
			cRet += '        <p>Informações geradas automaticamente a partir da importação dos dados do relógios de Ponto para o sistema Protheus e são enviadas semanalmente.</p> '
			cRet += '        <p>Estas informações de saldo poderão ser alteradas durante o processo de fechamento do Ponto.</p> '
			cRet += '        <p>Sem mais,</p> '
			cRet += '        <p><b>Departamento Pessoal</b></p> '
			cRet += '        <p>by BIABC012</p> '
			cRet += '    </div> '
			cRet += '</body> '
			cRet += '</html> '

			cEnv := cRet1 + cRet

			if !Empty(kjSuper)
				kjSuper += ";" + U_EmailWF('BIABC012',cEmpAnt) 
			else
				kjSuper :=  U_EmailWF('BIABC012',cEmpAnt) 
			endif 
			
			U_BIAEnvMail(,kjSuper,"Acompanhamento do Banco de Horas",cEnv)
		ELSEIF (cReto == 3)

			If File("C:\TEMP\"+xArqTemp+".xml")
				If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
					Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
				EndIf
			EndIf

			oExcel:Activate()
			oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")
			oExcel := FWMsExcel():DeActivate()

			If ApOleClient("MsExcel")
				oExcelApp := MsExcel():New() 
				oExcelApp:SetVisible(.T.)
				oExcelApp:WorkBooks:Open("C:\TEMP\"+xArqTemp+".xml") 
				oExcelApp:Destroy() 
			endif 

			IF MV_PAR05 == 1

				cRet += '        </table> '
				cRet += '        <br /> '
				cRet += '        <p>Informações geradas automaticamente a partir da importação dos dados do relógios de Ponto para o sistema Protheus e são enviadas semanalmente.</p> '
				cRet += '        <p>Estas informações de saldo poderão ser alteradas durante o processo de fechamento do Ponto.</p> '
				cRet += '        <p>Sem mais,</p> '
				cRet += '        <p><b>Departamento Pessoal</b></p> '
				cRet += '        <p>by BIABC012</p> '
				cRet += '    </div> '
				cRet += '</body> '
				cRet += '</html> '

				cEnv := cRet1 + cRet

				if !Empty(kjSuper)
					kjSuper += ";" + U_EmailWF('BIABC012') 
				else
					kjSuper :=  U_EmailWF('BIABC012',cEmpAnt) 
				endif
				U_BIAEnvMail(,kjSuper,"Acompanhamento do Banco de Horas",cEnv)

			ENDIF

			if MV_PAR06 == 1 .and. len(aColabHE) > 0
				BH100(aColabHE,EmlSuprX)
			endif

		ENDIF

		dbSelectArea("JF02")

	End

	IF cReto == 3

		Aviso('Acomp. Banco de Horas', 'Os arquivos foram gerados com sucesso em C:\TEMP\', {'Ok'}, 3)

	EndIf

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
	aAdd(aRegs,{cPerg,"04","Filtrar por e-mail LIDER ?","","","mv_ch4","C",85,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Enviar Arq. p/ LIDER ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Arq. Colab. c/ BH a 100% ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Eventos Integrados ao BH ?","","","mv_ch7","N",01,0,0,"C","","mv_par07","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})

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

User Function BBC012Job()

	STARTJOB("U_BIABC012()",GetEnvServer(),.F.,cEmpAnt,cFilAnt)

Return

Static Function BH100(aColab, cSuperior)
	Local cMatric
	Local cHoras
	local i
	local xArqH
	Local CriaArq := .F.
	
	xArqH := "Colab_H100_" + cSuperior + "_" + dtos(Date())+StrTran(Time(),":","")
	
	For i := 1 to Len(aColab)
		cMatric := SubStr( aColab[i], 1, 6) 
		cHoras := SubStr( aColab[i], 8) 
	
		JF003 := "SELECT RA_MAT, RA_NOME, RA_YSUPEML,SP9.P9_CODIGO+'-'+SP9.P9_DESC EVENTO, "+ cEnter
		JF003 += "       SUBSTRING(PI_DATA,7,2)+'/'+SUBSTRING(PI_DATA,5,2)+'/'+SUBSTRING(PI_DATA,1,4) DATAP, "+ cEnter
		JF003 += "       PI_QUANTV QUANTV"+ cEnter
		JF003 += "  FROM SPI010 SPI "+ cEnter
		JF003 += " INNER JOIN SP9010 SP9 ON(PI_PD = P9_CODIGO AND SP9.D_E_L_E_T_ = '' AND P9_BHPERC = 200) "+ cEnter
		JF003 += " INNER JOIN SRA010 SRA ON (PI_MAT = RA_MAT AND SRA.D_E_L_E_T_ = '') "+ cEnter
		JF003 += " WHERE SPI.D_E_L_E_T_ = '' "+ cEnter
		JF003 += "   AND PI_DTBAIX = '' "+ cEnter
		JF003 += "   AND PI_STATUS <> 'B'"+ cEnter
		JF003 += "   AND PI_DATA > '20181211' "+ cEnter
		JF003 += "   AND PI_QUANTV > 0 "+ cEnter
		JF003 += "   AND RA_MAT = '" + cMatric + "'"+ cEnter
		JF003 += "UNION ALL "+ cEnter
		JF003 += "SELECT RA_MAT, RA_NOME, RA_YSUPEML,SP9.P9_CODIGO+'-'+SP9.P9_DESC EVENTO, "+ cEnter
		JF003 += "       SUBSTRING(PC_DATA,7,2)+'/'+SUBSTRING(PC_DATA,5,2)+'/'+ SUBSTRING(PC_DATA,1,4) DATAP, "+ cEnter 
		JF003 += "       REPLACE(CONVERT(varchar(5),(CONVERT(SMALLDATETIME,REPLACE(CONVERT(NUMERIC(14,2),PC_QUANTC),'.',':')) + "+ cEnter
		JF003 += "	                                 CONVERT(SMALLDATETIME,REPLACE(CONVERT(NUMERIC(14,2),PC_QUANTC),'.',':'))),108),':','.') "+ cEnter
		JF003 += "       QUANTV "+ cEnter
		JF003 += "  FROM SPC010 SPC "+ cEnter
		JF003 += " INNER JOIN SP9010 SP9 ON(PC_PD = P9_CODIGO AND SP9.D_E_L_E_T_ = '' AND P9_BHPERC = 200) "+ cEnter
		JF003 += " INNER JOIN SRA010 SRA ON (PC_MAT = RA_MAT AND SRA.D_E_L_E_T_ = '') "+ cEnter
		JF003 += " WHERE SPC.D_E_L_E_T_ = '' "+ cEnter
		JF003 += "   AND PC_DATA > '20181211' "+ cEnter
		JF003 += "   AND PC_QUANTC > 0 "+ cEnter
		JF003 += "   AND RA_MAT = '" + cMatric + "'"+ cEnter
	
		JFcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,JF003),'JF03',.F.,.T.)
		dbSelectArea("JF03")
		dbGoTop()
	
		If JF03->(!Eof())
	
			If !CriaArq
				oExcel2 := FWMSEXCEL():New()
	
				nxPlan2 := "Planilha 01"
				nxTabl2 := "Colaboradores com Horas a 100%"
	
				oExcel2:AddworkSheet(nxPlan2)
				oExcel2:AddTable (nxPlan2, nxTabl2)
				oExcel2:AddColumn(nxPlan2, nxTabl2, "Matricula"			,1,1)
				oExcel2:AddColumn(nxPlan2, nxTabl2, "Nome"				,1,1)
				oExcel2:AddColumn(nxPlan2, nxTabl2, "e-mail gerente"	,1,1)
				oExcel2:AddColumn(nxPlan2, nxTabl2, "Evento"			,1,1)
				oExcel2:AddColumn(nxPlan2, nxTabl2, "Data"				,1,1)	
				oExcel2:AddColumn(nxPlan2, nxTabl2, "H 100%"			,3,2)
				oExcel2:AddColumn(nxPlan2, nxTabl2, "Saldo"				,3,2)
	
				CriaArq := .T.
			endif
	
			While !Eof()
				oExcel2:AddRow(nxPlan2, nxTabl2, { 	JF03->RA_MAT	,;
				JF03->RA_NOME	,;
				JF03->RA_YSUPEML,;
				JF03->EVENTO	,;
				JF03->DATAP	 	,;		
				JF03->QUANTV	,;					
				cHoras			})
				oExcel2:AddRow(nxPlan2, nxTabl2, { 	""	,;
				""	,;
				""	,;
				""	,;
				""	,;
				""	,;
				""	})
	
				dbSkip()
			END  
		endif	
		JF03->(dbCloseArea())
	
		Next
	
	If File("C:\TEMP\"+xArqH+".xml")
		If fErase("C:\TEMP\"+xArqH+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqH+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf
	
	if CriaArq
		oExcel2:Activate()
		oExcel2:GetXMLFile("C:\TEMP\"+xArqH+".xml")
		oExcel2 := FWMsExcel():DeActivate()	
	
		If ApOleClient("MsExcel")
			oExcelApp2 := MsExcel():New() 
			oExcelApp2:SetVisible(.T.)
			oExcelApp2:WorkBooks:Open("C:\TEMP\"+xArqH+".xml") 
			oExcelApp2:Destroy() 
		endif 
	endif
Return 
