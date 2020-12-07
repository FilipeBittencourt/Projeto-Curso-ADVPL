#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA722
@author Marcos Alberto Soprani
@since 27/05/13
@version 1.0
@description Programação de Férias:
.            Todo dia 25 de cada mês comunica aos supervisores a lista de
.            funcionários de sua equipe que estará entrando de férias a par-
.            tir do segundo mês contados a partir da data de envio deste
.            e-mail.
@type function
/*/

User Function BIA722()

	Local xtArea := GetArea()
	Local x		 := 0

	Private drDatIni
	Private drDatFim
	Private drMDesc
	Private drMatIni
	Private drMatFim

	If Select("SX6") == 0                                 // Via Schedule
		//***************************************************************

		xv_Emps    := U_BAGtEmpr("01_05_06_07_12_13_14")
		//xv_Emps    := U_BAGtEmpr("07")
		For x := 1 to Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

			ConOut("HORA: "+TIME()+" - Iniciando Processo BIA722 " + xv_Emps[x,1])
			
			drDatIni  := Substr(dtos(dDataBase+60),1,6)+"01"
			drDatFim  := dtos(Ultimodia(dDataBase+60))
			drMDesc   := MesExtenso( stod(drDatIni) )
			drDescPer := drMDesc+' de '+Substr(drDatIni,1,4)
			drMatIni  := "      "
			drMatFim  := "ZZZZZZ"

			Processa({||wfBIA722()})

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIA722 " + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()

		Next

	Else                                         // Via Integração Manual
		//***************************************************************

		fPerg := "BIA722"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		ValidPerg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		drDatIni  := dtos(MV_PAR01)
		drDatFim  := dtos(MV_PAR02)
		drMDesc   := MesExtenso( stod(drDatIni) )
		drDescPer := Alltrim(MV_PAR03)
		drMatIni  := MV_PAR04
		drMatFim  := MV_PAR05

		Processa({||wfBIA722()})

	EndIf

	RestArea(xtArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ wfBIA722  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 27/05/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsável pela execução dos Jobs                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function wfBIA722()

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
	QR006 += "        case when RF_DATAINI BETWEEN '"+drDatIni+"' AND '"+drDatFim+"' then RF_DATAINI else RF_DATINI2 end 'Prg_Fer_de',
	QR006 += "        CASE
	QR006 += "          WHEN RF_DATAINI <> '        ' and RF_DATAINI BETWEEN '"+drDatIni+"' AND '"+drDatFim+"' THEN Convert(VarChar(10), convert(datetime, RF_DATAINI)+RF_DFEPRO1-1, 112)
	QR006 += "          WHEN RF_DATINI2 <> '        ' and RF_DATINI2 BETWEEN '"+drDatIni+"' AND '"+drDatFim+"' THEN Convert(VarChar(10), convert(datetime, RF_DATINI2)+RF_DFEPRO2-1, 112)
	QR006 += "          ELSE '        '
	QR006 += "        END 'Prg_Fer_At',
	QR006 += "        CONVERT(INT,DATEADD(YEAR , 2, Convert(datetime, RF_DATABAS)-45-1)) - CONVERT(INT, GETDATE()) 'Dias_Restantes',
	QR006 += "        SRF.R_E_C_N_O_ REGSRF
	QR006 += "   FROM "+RetSqlName("SRF")+" SRF
	QR006 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
	QR006 += "                       AND RA_MAT = RF_MAT
	QR006 += "                       AND RA_SITFOLH <> 'D'
	QR006 += "                       AND RA_CATFUNC = 'M'
	QR006 += "                       AND SRA.RA_MAT BETWEEN '"+drMatIni+"' AND '"+drMatFim+"'
	QR006 += "                       AND SRA.RA_MAT < '100000'
	QR006 += "                       AND SRA.D_E_L_E_T_ = ' '
	QR006 += "  WHERE RF_FILIAL = '"+xFilial("SRF")+"'
	QR006 += "    AND (RF_DATAINI BETWEEN '"+drDatIni+"' AND '"+drDatFim+"' or RF_DATINI2 BETWEEN '"+drDatIni+"' AND '"+drDatFim+"')
	QR006 += "    AND SRF.D_E_L_E_T_ = ' '
	QR006 += "  ORDER BY RA_YSEMAIL, RF_MAT
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
		TG003 += ' <p>Abaixo encontra-se a lista de funcionários com suas respectivas programações de férias previstas para se realizarem no período de <strong>'+drDescPer+'</strong>.</p> '
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
		TG003 += '     <td colspan="2" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Férias Prog.</span></div></td> '
		TG003 += '     <td colspan="2" bgcolor="#009933" class="style15" scope="col"><div align="center" class="style16">Reprogramação</div></td> '
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
		TG003 += '     <td width="50" bgcolor="#009933" class="style15"><div align="center" class="style16">Início</div></td> '
		TG003 += '     <td width="53" bgcolor="#009933" class="style15"><div align="center" class="style16">Fim</div></td> '
		TG003 += '   </tr> '

		xdEmailSup := QR06->Supervisor
		While !Eof() .and. QR06->Supervisor == xdEmailSup

			TG003 += '   <tr>
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
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Prg_Fer_de))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"><span class="style15">'+dtoc(stod(QR06->Prg_Fer_At))+'</span></div></td> '
			TG003 += '     <td class="style15"><div align="center"></div></td> '
			TG003 += '     <td class="style15"><div align="center"></div></td> '
			TG003 += '   </tr> '

			dbSelectArea("QR06")
			dbSkip()

		End

		TG003 += ' </table> '
		TG003 += ' <p>Caso não estejam de acordo ou necessitem reprogramar, favor preencher adequadamente a coluna &quot;Reprogramação&quot;.</p> '
		TG003 += ' <p>&nbsp;</p> '
		TG003 += ' <p>Este e-mail deverá ser respondido para <span class="style17">sadila.stinguel@biancogres.com.br</span> do setor de pessoal <span class="style17">até o dia 1o.</span></p> '
		TG003 += ' <p>&nbsp;</p> '
		TG003 += ' <p>Com intuito de facilitar e tornar os processos internos mais ágeis, o Setor de Pessoal orienta sobre os procedimentos que devem ser </p> '
		TG003 += ' <p>realizados para solicitação de férias. Confira abaixo:</p> '
		TG003 += ' <p>&nbsp;</p> '
		
		TG003 += ' <table width="934" border="1" cellspacing="0" bordercolor="#666666"> '
		TG003 += '   <tr> '
		TG003 += '     <td width="27" bgcolor="#0066FF" class="style15" scope="col"><div align="center" class="style16"><span class="style15">Procedimentos</span></div></td> '
		TG003 += '     <td width="198" bgcolor="#0066FF" class="style15" scope="col"><div align="left" class="style16"><span class="style15">Orientação à Liderança</span></div></td> '
		TG003 += '   </tr> '
		TG003 += '   <tr> '
		TG003 += '   <tr> '
		TG003 += '     <td class="style15"><div align="center"><span class="style15">Programação de férias</span></div></td> '
		TG003 += '     <td class="style15"><div align="left"><span class="style15">Dia 20 de cada mês, o Gestor recebe o Workflow da programação de férias para os próximos 40 dias. Exemplo: 20 de Janeiro para quem irá sair de férias em Março;</span></div></td> '
		TG003 += '   </tr> '
		TG003 += '   <tr> '
		TG003 += '     <td class="style15"><div align="center"><span class="style15">Confirmação da Programação de férias</span></div></td> '
		TG003 += '     <td class="style15"><div align="left"><span class="style15">O gestor terá até o último dia do mês para confirmar as solicitações de férias por e-mail;</span></div></td> '
		TG003 += '   </tr> '
		TG003 += '   <tr> '
		TG003 += '     <td class="style15"><div align="center"><span class="style15">Aviso de férias ao Gestor</span></div></td> '
		TG003 += '     <td class="style15"><div align="left"><span class="style15">O Setor de Pessoal enviará e-mail ao Gestor informando que os avisos estarão disponíveis para os colaboradores assinarem;</span></div></td> '
		TG003 += '   </tr> '
		TG003 += '   <tr> '
		TG003 += '     <td class="style15"><div align="center"><span class="style15">Aviso de férias ao Colaborador</span></div></td> '
		TG003 += '     <td class="style15"><div align="left"><span class="style15">O Gestor comunicará ao colaborador e ele deverá comparecer ao DP, no prazo de 10 dias após receber a comunicação, para assinar o aviso de férias. Será necessário a apresentação da carteira de trabalho para atualização;</span></div></td> '
		TG003 += '   </tr> '
		TG003 += '   <tr> '
		TG003 += '     <td class="style15"><div align="center"><span class="style15">Recibo</span></div></td> '
		TG003 += '     <td class="style15"><div align="left"><span class="style15">O recibo de férias ficará disponível no Portal RH a partir do dia 25 de cada mês.</span></div></td> '
		TG003 += '   </tr> '
		TG003 += ' </table> '
		
		
		TG003 += ' <p>Solicitamos à liderança que oriente os membros da equipe.</p> '
		TG003 += ' <p>Importante que a liderança informe aos membros da equipe o período das suas férias antes de repassar ao Setor de Pessoal.</p> '
		TG003 += ' <p>Caso o colaborador não compareça para assinar o Aviso de Férias, as férias serão canceladas.</p> '
		TG003 += ' <p>&nbsp;</p> '		
		TG003 += ' <p>Atenciosamente,</p> '
		TG003 += ' <p>&nbsp;</p> '
		TG003 += ' <p>Setor de Pessoal.</p> '
		TG003 += ' <p>&nbsp;</p> '
		TG003 += ' <p>E-mail enviado automaticamente pelo sistema Protheus (by BIA722).</p> '
		TG003 += ' </body> '
		TG003 += ' </html> '

		//(Rubens Junior - 14/03/14) - nova forma de buscar destinatario do email, via tabela Z28 
		df_Dest := U_EmailWF('BIA722',cEmpAnt)
		df_Dest += Alltrim(xdEmailSup)
		
		//df_Dest := "barbara.coelho@biancogres.com.br"
		
		df_Assu := "Confirmação de Programação de férias     " + Alltrim(xdEmailSup)
		df_Erro := "Confirmação de Programação de férias não enviado. Favor verificar!!!"

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
	aAdd(aRegs,{cPerg,"03","Período por Extenso  ?","","","mv_ch3","C",50,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","De Matricula         ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"05","Ate Matricula        ?","","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
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
