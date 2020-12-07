#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA517
@author Marcos Alberto Soprani
@since 07/10/14
@version 1.0
@description Programação de Férias (enviado anualmente) 
@type function
/*/

User Function BIA517()

	Local xtArea := GetArea()
	Local x

	Private drDatIni
	Private drDatFim
	Private drMDesc
	Private drMatIni
	Private drMatFim

	If Select("SX6") == 0                                 // Via Schedule
		*****************************************************************

		xv_Emps    := U_BAGtEmpr("01_05_06_07_12_13")
		For x := 1 to Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

			ConOut("HORA: "+TIME()+" - Iniciando Processo BIA517 " + xv_Emps[x,1])

			drDatIni  := Substr(dtos(dDataBase+60),1,6)+"01"
			drDatFim  := dtos(Ultimodia(dDataBase+60))
			drMDesc   := drDatFim
			drMatIni  := "      "
			drMatFim  := "ZZZZZZ"

			Processa({||wfBIA517()})

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIA517 " + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()

		Next

	Else                                         // Via Integração Manual
		*****************************************************************

		fPerg := "BIA517"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		ValidPerg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		drDatIni  := dtos(MV_PAR01)
		drDatFim  := dtos(MV_PAR02)
		drMDesc   := MV_PAR05
		drMatIni  := MV_PAR03
		drMatFim  := MV_PAR04
		cObs      := MV_PAR06

		Processa({||wfBIA517()})

	EndIf

	RestArea(xtArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ wfBIA517  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 27/05/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsável pela execução dos Jobs                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function wfBIA517()

	QR006 := " SELECT RA_CLVL 'Clvl', "
	QR006 += "        RA_CC 'CCusto', "
	QR006 += "        RF_MAT 'Matricula', "
	QR006 += "        RA_NOME 'Nome', "
	QR006 += "        RA_YSEMAIL 'Supervisor', "
	QR006 += "        ISNULL((SELECT R8_DATAINI "
	QR006 += "                  FROM "+RetSqlName("SR8") "
	QR006 += "                 WHERE R8_FILIAL = '"+xFilial("SR8")+"' "
	QR006 += "                   AND R8_MAT = RF_MAT "
	QR006 += "                   AND ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' ) "
	QR006 += "                   AND R8_DATAFIM IN(SELECT MAX(R8_DATAFIM) "
	QR006 += "                                       FROM "+RetSqlName("SR8") "
	QR006 += "                                      WHERE R8_FILIAL = '"+xFilial("SR8")+"' "
	QR006 += "                                        AND R8_MAT = RF_MAT "
	QR006 += "                                        AND ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' ) "
	QR006 += "                                        AND R8_DATAFIM <= '"+dtos(dDataBase)+"' "
	QR006 += "                                        AND D_E_L_E_T_ = ' ') "
	QR006 += "                   AND D_E_L_E_T_ = ' '), '        ') 'Ult_Fer_ini', "
	QR006 += "        ISNULL((SELECT R8_DATAFIM "
	QR006 += "                  FROM "+RetSqlName("SR8") "
	QR006 += "                 WHERE R8_FILIAL = '"+xFilial("SR8")+"' "
	QR006 += "                   AND R8_MAT = RF_MAT "
	QR006 += "                   AND ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' ) "
	QR006 += "                   AND R8_DATAFIM IN(SELECT MAX(R8_DATAFIM) "
	QR006 += "                                       FROM "+RetSqlName("SR8") "
	QR006 += "                                      WHERE R8_FILIAL = '"+xFilial("SR8")+"' "
	QR006 += "                                        AND R8_MAT = RF_MAT "
	QR006 += "                                        AND ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' ) "
	QR006 += "                                        AND R8_DATAFIM <= '"+dtos(dDataBase)+"' "
	QR006 += "                                        AND D_E_L_E_T_ = ' ') "
	QR006 += "                   AND D_E_L_E_T_ = ' '), '        ') 'Ult_Fer_Fim', "
	QR006 += "        RA_ADMISSA 'DtAdmissao', "
	QR006 += "        RF_DATABAS 'DtBase', "
	QR006 += "        RF_DATABAS 'Per_Aqs_De', "
	QR006 += "        Convert(VarChar(10), DATEADD(YEAR , 1, Convert(datetime, RF_DATABAS)-1)   , 112) 'Per_Aqs_At', "
	QR006 += "        Convert(VarChar(10), DATEADD(YEAR , 1, Convert(datetime, RF_DATABAS))     , 112) 'DtLimit_De', "
	QR006 += "        Convert(VarChar(10), DATEADD(YEAR , 2, Convert(datetime, RF_DATABAS)-45-1), 112) 'DtLimit_At', "
	QR006 += "        RF_DATAINI 'Pr_F_De1', "
	QR006 += "        RF_DFEPRO1 'Pr_P_Fer', "
	QR006 += "        CASE "
	QR006 += "          WHEN RF_DATAINI <> '        ' THEN Convert(VarChar(10), convert(datetime, RF_DATAINI)+RF_DFEPRO1-1, 112) "
	QR006 += "          ELSE '        ' "
	QR006 += "        END 'Pr_F_At1', "
	QR006 += "        RF_DATINI2 'Pr_F_De2', "        
	QR006 += "        RF_DFEPRO2 'Sg_P_Fer', "
	QR006 += "        CASE "          
	QR006 += "          WHEN RF_DATINI2 <> '        ' THEN Convert(VarChar(10), convert(datetime, RF_DATINI2)+RF_DFEPRO2-1, 112) "          
	QR006 += "    	    ELSE '        ' "        
	QR006 += "        END 'Pr_F_At2', "
	QR006 += "        RF_DATINI3 'Pr_F_De3', "        
	QR006 += "        RF_DFEPRO3 'Tr_P_Fer', "
	QR006 += "        CASE "          
	QR006 += "          WHEN RF_DATINI3 <> '        ' THEN Convert(VarChar(10), convert(datetime, RF_DATINI3)+RF_DFEPRO3-1, 112) "          
	QR006 += "   	    ELSE '        '"         
	QR006 += "        END 'Pr_F_At3',"	
	QR006 += "        CONVERT(INT,DATEADD(YEAR , 2, Convert(datetime, RF_DATABAS)-45-1)) - CONVERT(INT, GETDATE()) 'Dias_Restantes', "
	QR006 += "        SRF.R_E_C_N_O_ REGSRF "
	QR006 += "   FROM "+RetSqlName("SRF")+" SRF "
	QR006 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"' "
	QR006 += "                       AND RA_MAT = RF_MAT "
	QR006 += "                       AND RA_SITFOLH <> 'D' "
	QR006 += "                       AND RA_CATFUNC = 'M' "
	QR006 += "                       AND SRA.RA_MAT BETWEEN '"+drMatIni+"' AND '"+drMatFim+"' "
	QR006 += "                       AND SRA.RA_MAT < '100000' "
	QR006 += "                       AND SRA.D_E_L_E_T_ = ' ' "
	QR006 += "  WHERE SRF.RF_FILIAL = '"+xFilial("SRF")+"' "
	QR006 += "    AND SRF.RF_DATAINI BETWEEN '"+drDatIni+"' AND '"+drDatFim+"' "
	QR006 += "    AND SRF.RF_STATUS = '1' "
	QR006 += "    AND SRF.D_E_L_E_T_ = ' ' "
//	QR006 += " AND SRF.RF_DATAFIM BETWEEN '"+SUBSTR(drDatFim,1,4)+"0101' AND '"+drDatFim+"' "
	QR006 += " AND SRF.RF_DATAFIM BETWEEN '' AND '"+drDatFim+"' "
	QR006 += "  ORDER BY RA_YSEMAIL, RF_MAT "
	QrIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR006),'QR06',.T.,.T.)
	dbSelectArea("QR06")

	dbGoTop()
	While !Eof()

		TG003 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
		TG003 += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
		TG003 += ' <head> '
		TG003 += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
		TG003 += ' <title>Untitled Document</title> '
		TG003 += ' <style type="text/css"> '
		TG003 += ' <!-- '
		TG003 += ' .style15 {font-size: 12px} '
		TG003 += ' .style16 { '
		TG003 += ' 	color: #FFFFFF; '
		TG003 += ' 	font-weight: bold; '
		TG003 += ' } '
		TG003 += ' .style17 {color: #FF0000} '
		TG003 += ' --> '
		TG003 += ' </style> '
		TG003 += ' </head> '
		TG003 += ' <body> '
		TG003 += ' <p>Prezados Senhores,</p> '
		TG003 += ' <p>Empresa: '+Alltrim(SM0->M0_NOMECOM)+'</p> '
		TG003 += ' <p>Favor realizar a programação de férias de seus colaboradores para o próximo ano e devolvê-las até o dia <strong>'+dtoc(drMDesc)+'</strong>.</p> '
		TG003 += ' <p><strong>Obs:'+cObs+'</strong>.</p> '		
		TG003 += ' <p>Responder esse e-mail com a programação para rh.pessoal@biancogres.com.br .</p> '
		TG003 += ' <table width="934" border="1" cellspacing="0" bordercolor="#666666"> '
		TG003 += '   <tr> '
		TG003 += '     <td width="27" rowspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Clvl</span></div></td> '
		TG003 += '     <td width="48" rowspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Matric</span></div></td> '
		TG003 += '     <td width="198" rowspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="left" class="style16"><span class="style15">Nome</span></div></td> '
		TG003 += '     <td colspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Últimas Férias</span></div></td> '
		TG003 += '     <td width="56" rowspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Admissão</span></div></td> '
		TG003 += '     <td width="56" rowspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">DataBase</span></div></td> '
		TG003 += '     <td colspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Período Aquisitivo</span></div></td> '
		TG003 += '     <td colspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Data Limite</span></div></td> '
		TG003 += '     <td colspan="3" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Férias Prog.(1)</span></div></td> '
		TG003 += '     <td colspan="3" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Férias Prog.(2)</span></div></td> '
		TG003 += '     <td colspan="3" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Férias Prog.(3)</span></div></td> '
		TG003 += '     <td colspan="2" bgcolor="#009933" class="style15" scope="col"><div align="center" class="style16">Reprogramação(1)</div></td> '
		TG003 += '     <td colspan="2" bgcolor="#009933" class="style15" scope="col"><div align="center" class="style16">Reprogramação(2)</div></td> '
		TG003 += '     <td colspan="2" bgcolor="#009933" class="style15" scope="col"><div align="center" class="style16">Reprogramação(3)</div></td> '
		TG003 += '   </tr> '
		TG003 += '   <tr> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Início</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Fim</span></div></td> '
		TG003 += '     <td width="51" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Início</span></div></td> '
		TG003 += '     <td width="51" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Fim</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">De</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Até</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Início</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Fim</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Dias</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Início</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Fim</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Dias</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Início</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Fim</span></div></td> '
		TG003 += '     <td width="47" bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Dias</span></div></td> '
		TG003 += '     <td width="50" bgcolor="#009933" class="style15"><div align="center" class="style16">Início</div></td> '
		TG003 += '     <td width="53" bgcolor="#009933" class="style15"><div align="center" class="style16">Fim</div></td> '
		TG003 += '     <td width="50" bgcolor="#009933" class="style15"><div align="center" class="style16">Início</div></td> '
		TG003 += '     <td width="53" bgcolor="#009933" class="style15"><div align="center" class="style16">Fim</div></td> '
		TG003 += '     <td width="50" bgcolor="#009933" class="style15"><div align="center" class="style16">Início</div></td> '
		TG003 += '     <td width="53" bgcolor="#009933" class="style15"><div align="center" class="style16">Fim</div></td> '
		TG003 += '   </tr> '

		xdEmailSup := QR06->Supervisor
		While !Eof() .and. QR06->Supervisor == xdEmailSup

			TG003 += '   <tr> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+QR06->Clvl+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+QR06->Matricula+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="left"><span class="style15">'+Alltrim(QR06->Nome)+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Ult_Fer_ini))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Ult_Fer_Fim))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->DtAdmissao))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->DtBase))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Per_Aqs_De))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Per_Aqs_At))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->DtLimit_De))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->DtLimit_At))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Pr_F_de1))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Pr_F_At1))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+cvaltochar(QR06->Pr_P_Fer)+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Pr_F_de2))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Pr_F_At2))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+cvaltochar(QR06->Sg_P_Fer)+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Pr_F_de3))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Pr_F_At3))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+cvaltochar(QR06->Tr_P_Fer)+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"></div></td> '
			TG003 += '     <td class="style15"><div align="center"></div></td> '
			TG003 += '     <td class="style15"><div align="center"></div></td> '
			TG003 += '     <td class="style15"><div align="center"></div></td> '
			TG003 += '     <td class="style15"><div align="center"></div></td> '
			TG003 += '     <td class="style15"><div align="center"></div></td> '
			TG003 += '   </tr> '

			dbSelectArea("QR06")
			dbSkip()

		End

		TG003 += ' </table> '
		TG003 += ' <p>&nbsp;</p> '
		TG003 += ' <p>Atenciosamente,</p> '
		TG003 += ' <p>&nbsp;</p> '
		TG003 += ' <p>Departamento Pessoal.</p> '
		TG003 += ' <p>&nbsp;</p> '
		TG003 += ' <p>E-mail enviado automaticamente pelo sistema Protheus (by BIA517).</p> '
		TG003 += ' </body> '
		TG003 += ' </html> '

		df_Dest := U_EmailWF('BIA517',cEmpAnt)
		df_Dest += Alltrim(xdEmailSup)

		df_Assu := "Programação anual de férias     " + Alltrim(xdEmailSup)
		df_Erro := "Programação anual de férias não enviado. Favor verificar!!!"

		U_BIAEnvMail(, df_Dest, df_Assu, TG003, df_Erro)

		dbSelectArea("QR06")
	End

	QR06->(dbCloseArea())
	Ferase(QrIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QrIndex+OrdBagExt())          //indice gerado

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
	aAdd(aRegs,{cPerg,"01","De Data              ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data             ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Matricula         ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"04","Ate Matricula        ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"05","Entregar até         ?","","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
