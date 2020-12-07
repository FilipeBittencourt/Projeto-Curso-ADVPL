#Include "Protheus.ch"
#include "topconn.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA713
Empresa   := Biancogres Cerêmicas S/A
Data      := 30/04/13
Uso       := Gestão de Pessoal
Aplicação := Programação de Férias
.            Envia diariamente e-mail para os supervisores alertando que den-
.            tro de 80 dias encerra-se o limite legal para férias da lista de
.            funcionários relacionados e ainda não foi confirmada a programa-
.            ção de férias. Caso o limite legal para vencimento das férias
.            chegue a 70 dias sem programação, o sistema grava automaticamen-
.            te a programação pelo limite calculado.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA713()

	Local xtArea := GetArea()
	Local x
	Private xOrigProc

	If Select("SX6") == 0                                 // Via Schedule
		*****************************************************************

		xOrigProc := "2"
		xv_Emps    := U_BAGtEmpr("01_05_06_13_14")
		For x := 1 to Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

			ConOut("HORA: "+TIME()+" - Iniciando Processo BIA713 " + xv_Emps[x,1])

			Processa({||wfBIA713()})

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIA713 " + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()

		Next

	Else                                         // Via Integração Manual
		*****************************************************************

		xOrigProc := "1"
		
		fPerg := "BIA713"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		fValidPerg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf
		
		Processa({||wfBIA713()})

	EndIf

	RestArea(xtArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ wfBIA713  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 24/05/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsável pela execução dos Jobs                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function wfBIA713()
	
	Local nQuant := 1
	aDados2 := {}

	QR006 := " SELECT RA_CLVL 'Clvl',
	QR006 += "        RA_CC 'CCusto',
	QR006 += "        RF_MAT 'Matricula',
	QR006 += "        RA_NOME 'Nome',
	QR006 += "        RA_YSEMAIL 'Supervisor',
	QR006 += "        ISNULL((SELECT R8_DATAINI
	QR006 += "                  FROM "+RetSqlName("SR8")
	QR006 += "                 WHERE R8_FILIAL = '"+xFilial("SR8")+"'
	QR006 += "                   AND R8_MAT = RF_MAT
	QR006 += "                   AND ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' )
	QR006 += "                   AND R8_DATAFIM IN(SELECT MAX(R8_DATAFIM)
	QR006 += "                                       FROM "+RetSqlName("SR8")
	QR006 += "                                      WHERE R8_FILIAL = '"+xFilial("SR8")+"'
	QR006 += "                                        AND R8_MAT = RF_MAT
	QR006 += "                                        AND ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' )
	QR006 += "                                        AND R8_DATAFIM <= '"+dtos(dDataBase)+"'
	QR006 += "                                        AND D_E_L_E_T_ = ' ')
	QR006 += "                   AND D_E_L_E_T_ = ' '), '        ') 'Ult_Fer_ini',
	QR006 += "        ISNULL((SELECT R8_DATAFIM
	QR006 += "                  FROM "+RetSqlName("SR8")
	QR006 += "                 WHERE R8_FILIAL = '"+xFilial("SR8")+"'
	QR006 += "                   AND R8_MAT = RF_MAT
	QR006 += "                   AND ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' )
	QR006 += "                   AND R8_DATAFIM IN(SELECT MAX(R8_DATAFIM)
	QR006 += "                                       FROM "+RetSqlName("SR8")
	QR006 += "                                      WHERE R8_FILIAL = '"+xFilial("SR8")+"'
	QR006 += "                                        AND R8_MAT = RF_MAT
	QR006 += "                                        AND ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' )
	QR006 += "                                        AND R8_DATAFIM <= '"+dtos(dDataBase)+"'
	QR006 += "                                        AND D_E_L_E_T_ = ' ')
	QR006 += "                   AND D_E_L_E_T_ = ' '), '        ') 'Ult_Fer_Fim',
	QR006 += "        RA_ADMISSA 'DtAdmissao',
	QR006 += "        RF_DATABAS 'DtBase',
	QR006 += "        RF_DATABAS 'Per_Aqs_De',
	QR006 += "        Convert(VarChar(10), DATEADD(YEAR , 1, Convert(datetime, RF_DATABAS)-1)   , 112) 'Per_Aqs_At',
	QR006 += "        Convert(VarChar(10), DATEADD(YEAR , 1, Convert(datetime, RF_DATABAS))     , 112) 'DtLimit_De',
	QR006 += "        Convert(VarChar(10), DATEADD(YEAR , 2, Convert(datetime, RF_DATABAS)-45-1), 112) 'DtLimit_At',
	QR006 += "        RF_DATAINI 'Prg_Fer1_de',        
	QR006 += "        CASE WHEN RF_DATAINI <> '        ' THEN Convert(VarChar(10), convert(datetime, RF_DATAINI)+RF_DFEPRO1-1, 112) ELSE '        ' END 'Prg_Fer1_At',
	QR006 += "        RF_DFEPRO1 'Prg_Dias1',
	QR006 += "        RF_DATINI2 'Prg_Fer2_de',
	QR006 += "        CASE WHEN RF_DATINI2 <> '        ' THEN Convert(VarChar(10), convert(datetime, RF_DATINI2)+RF_DFEPRO2-1, 112) ELSE '        ' END 'Prg_Fer2_At',
	QR006 += "        RF_DFEPRO2 'Prg_Dias2', 
	QR006 += "        RF_DATINI3 'Prg_Fer3_de',
	QR006 += "        CASE WHEN RF_DATINI3 <> '        ' THEN Convert(VarChar(10), convert(datetime, RF_DATINI3)+RF_DFEPRO3-1, 112) ELSE '        ' END 'Prg_Fer3_At',
	QR006 += "        RF_DFEPRO3 'Prg_Dias3', 
	QR006 += "        CONVERT(INT,DATEADD(YEAR , 2, Convert(datetime, RF_DATABAS)-45-1)) - CONVERT(INT, GETDATE()) 'Dias_Restantes',
	QR006 += "        SRF.R_E_C_N_O_ REGSRF
	QR006 += "   FROM "+RetSqlName("SRF")+" SRF
	QR006 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
	QR006 += "                       AND RA_MAT = RF_MAT
	QR006 += "                       AND RA_SITFOLH <> 'D'
	QR006 += "                       AND RA_CATFUNC = 'M'
	QR006 += "                       AND SRA.RA_MAT < '100000'
	QR006 += "                       AND SRA.D_E_L_E_T_ = ' '
	IF TYPE("MV_PAR01") == "N" .AND. MV_PAR01 <> 1 .AND. '@' $ Alltrim(MV_PAR02)
		QR006 += "                   AND RTRIM(SRA.RA_YSEMAIL) = '"+Alltrim(MV_PAR02)+"' "
	ENDIF 
	QR006 += "  WHERE RF_FILIAL = '"+xFilial("SRF")+"'
	//QR006 += "    AND RF_STATUS = '1'
	If xOrigProc == "2"
		QR006 += "    AND RF_DFERVAT <> 0
	EndIf
	QR006 += "    AND SRF.D_E_L_E_T_ = ' '
	QR006 += "  ORDER BY RA_YSEMAIL, RF_MAT, RF_DATABAS DESC
	QrIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR006),'QR06',.T.,.T.)
	dbSelectArea("QR06")
	If xOrigProc == "1"                                                                           // Processamento Manual
		*****************************************************************************************************************

		dbGoTop()
		ProcRegua(RecCount())
		cfMat := QR06->Matricula
		While !Eof()

			IncProc("Proc.: "  + QR06->Matricula)
			if cfMat <> QR06->Matricula  
			  cfMat := QR06->Matricula
			  nQuant := 1
			end if
			
			While !Eof() .and. QR06->Matricula == cfMat
				if nQuant <= 2
					aAdd(aDados2, { QR06->Clvl      ,;
					QR06->CCusto                    ,;
					QR06->Matricula                 ,;
					ALLTRIM(QR06->Nome)             ,;
					ALLTRIM(QR06->Supervisor)       ,;
					dtoc(stod(QR06->Ult_Fer_ini))   ,;
					dtoc(stod(QR06->Ult_Fer_Fim))   ,;
					dtoc(stod(QR06->DtAdmissao))    ,;
					dtoc(stod(QR06->DtBase))        ,;
					dtoc(stod(QR06->Per_Aqs_De))    ,;
					dtoc(stod(QR06->Per_Aqs_At))    ,;
					dtoc(stod(QR06->DtLimit_De))    ,;
					dtoc(stod(QR06->DtLimit_At))    ,;
					dtoc(stod(QR06->Prg_Fer1_de))   ,;
					dtoc(stod(QR06->Prg_Fer1_At))   ,;
					cValtochar(QR06->Prg_Dias1)     ,;
					dtoc(stod(QR06->Prg_Fer2_de))   ,;
					dtoc(stod(QR06->Prg_Fer2_At))   ,;
					cValtochar(QR06->Prg_Dias2)     ,;
					dtoc(stod(QR06->Prg_Fer3_de))   ,;
					dtoc(stod(QR06->Prg_Fer3_At))   ,;
					cValtochar(QR06->Prg_Dias3)     ,;
					QR06->Dias_Restantes            ,;
					cValtochar(0)                   })
					nQuant := nQuant + 1 //soma1(nQuant)
				end if

				dbSelectArea("QR06")
				dbSkip()
				
			End

		End

		aStru1 := ("QR06")->(dbStruct())

		U_BIAxExcel(aDados2, aStru1, "BIA713"+strzero(seconds()%3500,5) )

	Else                                          // Comunica Supervisores a respeito do vencimento concessivo das férias
		*****************************************************************************************************************

		_bzCondF := {|| QR06->Dias_Restantes = 80 .and. Empty(QR06->Prg_Fer1_de) }
		_czCondF := "QR06->Dias_Restantes = 80 .and. Empty(QR06->Prg_Fer1_de) "
		DbSetFilter( _bzCondF, _czCondF )
		dbGoTop()
		While !Eof()

			WF054 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
			WF054 += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
			WF054 += ' <head> '
			WF054 += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> '
			WF054 += ' <title>Untitled Document</title> '
			WF054 += ' <style type="text/css"> '
			WF054 += ' <!-- '
			WF054 += ' .style15 {font-size: 12px} '
			WF054 += ' .style16 { '
			WF054 += ' 	color: #FFFFFF; '
			WF054 += ' 	font-weight: bold; '
			WF054 += ' } '
			WF054 += ' --> '
			WF054 += ' </style> '
			WF054 += ' </head> '
			WF054 += ' <body> '
			WF054 += ' <p>Prezados Senhores,</p> '
			WF054 += ' <p>Empresa: '+Alltrim(SM0->M0_NOMECOM)+'</p> '
			WF054 += ' <p>Dentro de 80 dias estará findando o período concessivo para gozo de férias dos funcionários de sua equipe. Ainda não foi efetuada a programação de férias para estes funcionários abaixo relacionados.</p> '
			WF054 += ' <table width="923" border="1" cellspacing="0" bordercolor="#666666"> '
			WF054 += '   <tr> '
			WF054 += '     <td rowspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Clvl</span></div></td> '
			WF054 += '     <td rowspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Matric</span></div></td> '
			WF054 += '     <td rowspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="left" class="style16"><span class="style15">Nome</span></div></td> '
			WF054 += '     <td colspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Últimas Férias</span></div></td> '
			WF054 += '     <td rowspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Admissão</span></div></td> '
			WF054 += '     <td rowspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">DataBase</span></div></td> '
			WF054 += '     <td colspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Período Aquisitivo</span></div></td> '
			WF054 += '     <td colspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Data Limite</span></div></td> '
			WF054 += '     <td colspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Férias Prog.</span></div></td> '
			WF054 += '   </tr> '
			WF054 += '   <tr> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Início</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Fim</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Início</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Fim</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">De</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Até</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Início Periodo 1</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Fim Periodo 1</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Dias Periodo 1</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Início Periodo 2</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Fim Periodo 2</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Dias Periodo 2</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Início Periodo 3</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Fim Periodo 3</span></div></td> '
			WF054 += '     <td bgcolor="#0066FF" class="style15"><div align="center" class="style16"><span class="style15">Dias Periodo 3</span></div></td> '
			WF054 += '   </tr> '

			xdEmailSup := QR06->Supervisor
			While !Eof() .and. QR06->Supervisor == xdEmailSup

				WF054 += '   <tr> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+QR06->Clvl+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+QR06->Matricula+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="left"><span class="style15">'+Alltrim(QR06->Nome)+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Ult_Fer_ini))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Ult_Fer_Fim))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->DtAdmissao))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->DtBase))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Per_Aqs_De))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Per_Aqs_At))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->DtLimit_De))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->DtLimit_At))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Prg_Fer1_de))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Prg_Fer1_At))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+(QR06->Prg_Dias1)+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Prg_Fer2_de))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Prg_Fer2_At))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+(QR06->Prg_Dias2)+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Prg_Fer3_de))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Prg_Fer3_At))+'</span></div></td> '
				WF054 += '     <td class="style15"><div align="center"><span class="style15">'+(QR06->Prg_Dias3)+'</span></div></td> ' 	
				WF054 += '   </tr> '

				dbSelectArea("QR06")
				dbSkip()

			End

			WF054 += ' </table> '
			WF054 += ' <p>Favor efetuar o preenchimento da coluna Férias Prog. e enviar para sadila.stinguel@biancogres.com.br.</p> '
			WF054 += ' <p>&nbsp;</p> '
			WF054 += ' <p>Atenciosamente,</p> '
			WF054 += ' <p>&nbsp;</p> '
			WF054 += ' <p>Departamento Pessoal.</p> '
			WF054 += ' <p>&nbsp;</p> '
			WF054 += ' <p>E-mail enviado automaticamente pelo sistema Protheus (by BIA713)</p> '
			WF054 += ' </body> '
			WF054 += ' </html> '

			xCLVL   := ""
			df_Dest := U_EmailWF('BIA713', cEmpAnt , xCLVL )
			df_Dest += Alltrim(xdEmailSup)
			df_Dest += ";rh.pessoal@biancogres.com.br"

			df_Assu := "Programação de férias incompletas " + Alltrim(xdEmailSup)
			df_Erro := "Programação de férias incompletas não enviado. Favor verificar!!!"

			U_BIAEnvMail(, df_Dest, df_Assu, WF054, df_Erro)
			
			dbSelectArea("QR06")

		End
		DbClearFilter()

		//                                        // Força atualização da previsão de férias para aqueles não preenchidos
		*****************************************************************************************************************
		_bzCondF := {|| QR06->Dias_Restantes = 70 .and. Empty(QR06->Prg_Fer1_de) }
		_czCondF := "QR06->Dias_Restantes = 70 .and. Empty(QR06->Prg_Fer1_de) "
		DbSetFilter( _bzCondF, _czCondF )
		dbGoTop()
		While !Eof()
			dbSelectArea("SRF")
			dbSetOrder(1)
			dbGoTo(QR06->REGSRF)
			RecLock("SRF",.F.)
			SRF->RF_DATAINI := stod(QR06->DtLimit_At)
			MsUnLock()
			dbSelectArea("QR06")
			dbSkip()
		End

		DbClearFilter()

	EndIf

	QR06->(dbCloseArea())
	Ferase(QrIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QrIndex+OrdBagExt())          //indice gerado

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcelo Sousa       ¦ Data ¦ 02/05/19 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","Filtrar Supervisor?","","","mv_ch1","N",01,0,0,"C","","mv_par01","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Filtrar por e-mail SUPER ?","","","mv_ch2","C",40,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})


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