#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF040
@author Tiago Rossini Coradini
@since 11/07/2016
@version 1.0
@description Workflow - Analítico - Inconsistências do ponto eletrônico
@obs OS: 2623-15 - Claudia Mara
@obs OS: 4050-16 - Claudia Mara
@type function
/*/

User Function BIAF040()

	Local cSQL := ""
	Local cMail := ""
	Local cGerMail := ""
	Local lHTab := .T.
	Local cEve := ""
	Private cQry := GetNextAlias()
	Private cDbFile := GetNextAlias()
	Private cHTML := ""
	Private oLst := ArrayList():New()
	Private nTotHr := 0

	cSQL := fGetSQL()

	TcQuery cSQL New Alias cQry

	cDbfFile := CriaTrab(cQry->(DbStruct()), .T.)	
	COPY TO &cDbfFile VIA "DBFCDX"

	cQry->(DbCloseArea())

	DbUseArea(.T., "DBFCDX", cDbfFile, (cDbFile))		

	While !(cDbFile)->(Eof())

		If Empty(cMail) .Or. cMail <> (cDbFile)->YSEMAIL

			cHTML := fGetHeader()

		EndIf			 				

		If lHTab				

			cHTML += fGetHTable()

			lHTab := .F.				

		EndIf			

		cHTML += fGetTItem()

		cEve := (cDbFile)->EVENTO

		cMail := (cDbFile)->YSEMAIL
		cGerMail := Alltrim((cDbFile)->YSUPEML)

		(cDbFile)->(DbSkip())	

		If lHTab := (cEve <> (cDbFile)->EVENTO) .Or. (cMail <> (cDbFile)->YSEMAIL) 

			cHTML += fGetTFooter(cEve)				

		EndIf

		If cMail <> (cDbFile)->YSEMAIL

			cHTML += fGetHFooter()

			fSendMail(cHTML, cMail, cGerMail)

		EndIf

	EndDo	

	(cDbFile)->(DbCloseArea())

Return()

//****************************************************************************
//                                                                          **
//****************************************************************************
Static Function fGetHeader()

	Local cRet := ""

	cRet += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml"> '
	cRet += '<head> '
	cRet += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	cRet += '    <title>Workflow</title> '
	cRet += '    <style type="text/css"> '        
	cRet += '        <!-- ' 		
	cRet += '        .styleDiv{ margin: auto; width:80%; font: 12px Arial, Helvetica, sans-serif; } '
	cRet += '        .styleTable{ border:0; cellpadding:3; cellspacing:2; width:100%; } '		
	cRet += '        .styleTableCabecalho{ background: #fff; color: #000000; font: 14px Arial, Helvetica, sans-serif;  font-weight: bold; } '        
	cRet += '        .styleCabecalho{ background: #0c2c65; color: #ffffff; font: 12px Arial, Helvetica, sans-serif; font-weight: bold; padding: 5px; } '		
	cRet += '        .styleLinha{ background: #f6f6f6; color: #747474; font: 11px Arial, Helvetica, sans-serif; padding: 5px; } '        
	cRet += '        .styleNumerico{ text-align: right;} '
	cRet += '        .styleRodape{ background: #CFCFCF;color: #666666;font: 12px Arial, Helvetica, sans-serif;font-weight: bold;text-align: right;padding: 5px; } '		
	cRet += '        .styleLabel{ color:#0c2c65; } '		
	cRet += '        .styleValor{ color:#747474; } '        
	cRet += '        --> '   
	cRet += '    </style> '
	cRet += '</head> '
	cRet += '<body> '
	cRet += '    <div class="styleDiv"> '	
	cRet += '        <table cellpadding="0" cellspacing="0" width="100%"> '
	cRet += '            <tbody> '
	cRet += '               <tr class="styleTableCabecalho"> '
	cRet += '                    <td colspan="2" style="text-align:center;"> '
	cRet += '                    		<span class="styleLabel">RELATÓRIO ANALÍTICO - INCONSISTÊNCIAS DO PONTO ELETRÔNICO</span> '
	cRet += '                    </td> '
	cRet += '                </tr> '
	cRet += '                <tr class="styleTableCabecalho"> '
	cRet += '                    <td width="20%" style="text-align:left;"> '
	cRet += '                    		<span class="styleLabel">Empresa:</span> '
	cRet += '                        <span class="styleValor">'+ Capital(FWEmpName(cEmpAnt)) +'</span> '
	cRet += '                    </td> '
	cRet += '                </tr> '                
	cRet += '                <tr class="styleTableCabecalho"> '
	cRet += '                    <td width="20%" style="text-align:left;"> '
	cRet += '                        <span class="styleLabel">Data:</span> '
	cRet += '                        <span class="styleValor">'+ dToC(dDataBase-1) +'</span> '
	cRet += '                    </td> '
	cRet += '                </tr> '                
	cRet += '               	<tr class="styleTableCabecalho"> '
	cRet += '										<td width="40%" style="text-align:left;"> '
	cRet += '                    		<span class="styleLabel">Supervisão:</span> '
	cRet += '                        <span class="styleValor">'+ fGetName() +'</span> '
	cRet += '                    </td> '
	cRet += '                </tr> '
	cRet += '            </tbody> '
	cRet += '        </table> '
	cRet += '        <br /> '
	cRet += '        <br /> '	

Return(cRet)

//****************************************************************************
//                                                                          **
//****************************************************************************
Static Function fGetHTable()
	Local cRet := ""
	Local cDesc := ""

	If (cDbFile)->EVENTO $ "110/111"

		cDesc := "HORAS EXTRAS ACIMA DE 2 HORAS"

	ElseIf (cDbFile)->EVENTO $ "117/131/140"

		cDesc := "TRABALHO NAS FOLGAS - DSR"

	ElseIf (cDbFile)->EVENTO == "128"

		cDesc := "HORAS INTERJORNADAS MENOR DE 11 HORAS"

	ElseIf (cDbFile)->EVENTO == "FAL"

		cDesc := "FALTA DE REGISTRO DE PONTO"

	EndIf

	cRet += '        <table class="styleTable" align="center"> '
	cRet += '            <tr class="styleTableCabecalho"> '
	cRet += '                <td colspan="6">'+ cDesc
	cRet += '                </td> '
	cRet += '            </tr> '
	cRet += '            <tr align="center"> '
	cRet += '                <th class="styleCabecalho" width="20" scope="col">CV</th> '
	cRet += '                <th class="styleCabecalho" width="100" scope="col">Setor</th> '
	cRet += '                <th class="styleCabecalho" width="200" scope="col">Colaborador</th> '
	cRet += '                <th class="styleCabecalho" width="60" scope="col">Data </th> '
	cRet += '                <th class="styleCabecalho" width="150" scope="col">Marcação</th> '
	cRet += '                <th class="styleCabecalho" width="60" scope="col">'+ If (!(cDbFile)->EVENTO == "FAL", 'Qtde Horas', '') +'</th> '		
	cRet += '            </tr> '

Return(cRet)

//****************************************************************************
//                                                                          **
//****************************************************************************
Static Function fGetTItem()
	Local cRet := ""

	If !oLst:Contains((cDbFile)->(EVENTO+MATRIC+CLVL+_DATA+cValToChar(QUANT)))

		cRet += '        <tr align=center> '
		cRet += '            <td class="styleLinha" width="20" scope="col">'+ AllTrim((cDbFile)->CLVL) +'</td> '
		cRet += '            <td class="styleLinha" width="100" scope="col">'+ Capital(AllTrim((cDbFile)->DESCR01)) +'</td> '
		cRet += '            <td class="styleLinha" width="200" scope="col">'+ (cDbFile)->MATRIC + "-" + Capital(AllTrim((cDbFile)->NOME)) +'</td> '
		cRet += '            <td class="styleLinha" width="60" scope="col">'+ dToC(sToD((cDbFile)->_DATA)) +'</td> '
		cRet += '            <td class="styleLinha" width="150" scope="col">'+ fGetMar() +'</td> '
		cRet += '            <td class="styleLinha" styleNumerico" width="60" scope="col">'+ If (!(cDbFile)->EVENTO == "FAL", cValToChar(fGetQtd()), '') +'</td> '				
		cRet += '        </tr> '

		oLst:Add((cDbFile)->(EVENTO+MATRIC+CLVL+_DATA+cValToChar(QUANT)))

	EndIf

Return(cRet)

//****************************************************************************
//                                                                          **
//****************************************************************************
Static Function fGetTFooter(cEve)

	Local cRet := ""

	If cEve <> "FAL"

		cRet += '            <tr> '
		cRet += '                <td class="styleRodape" width="60" scope="col" colspan="5">Total de Horas</td> '
		cRet += '                <td class="styleRodape styleLinha styleNumerico styleTotal" width="60" scope="col">'+ cValToChar(nTotHr) +'</td> '
		cRet += '            </tr> '

	EndIf

	cRet += '        </table> '
	cRet += '        <br /> '

	nTotHr := 0

Return(cRet)

//****************************************************************************
//                                                                          **
//****************************************************************************
Static Function fGetHFooter()

	Local cRet := ""

	cRet += '        <p>Informações geradas automaticamente a partir da importação dos dados do relógios de Ponto para o sistema Protheus.</p> '
	cRet += '        <p>Estas informações não foram tratadas e poderão sofrer algum tipo de tratamento durante o processo de fechamento do Ponto.</p> '
	cRet += '        <p>Sem mais,</p> '
	cRet += '        <p><b>Departamento Pessoal</b></p> '
	cRet += '        <p>by BIAF040</p> '
	cRet += '    </div> '
	cRet += '</body> '
	cRet += '</html> '

Return(cRet)

//****************************************************************************
//                                                                          **
//****************************************************************************
Static Function fGetSQL()

	local cSQL := ""
	Local cSPC := RetSQLName("SPC")
	Local cSRA := RetSQLName("SRA")
	Local cCTH := RetSQLName("CTH")
	Local cSP9 := RetSQLName("SP9")
	Local cSP8 := RetSQLName("SP8")
	Local cEnter := CHR(13)+CHR(10)

	cSQL +=  "WITH EVENTOS AS (SELECT RA_YSEMAIL YSEMAIL, " + cEnter
	cSQL +=  "                        RA_YSUPEML YSUPEML, " + cEnter
	cSQL +=  "                        PC_PD EVENTO, " + cEnter
	cSQL +=  "                        P9_DESC DEVENTO, " + cEnter
	cSQL +=  "                        PC_MAT MATRIC, " + cEnter
	cSQL +=  "                        RA_NOME NOME, " + cEnter
	cSQL +=  "                        RA_CLVL CLVL, " + cEnter
	cSQL +=  "                        CTH_DESC01 DESCR01, " + cEnter
	cSQL +=  "                        PC_DATA _DATA, " + cEnter
	cSQL +=  "                        PC_QUANTC QUANT, " + cEnter
	cSQL +=  "                        P8_TPMARCA TPMARCA, " + cEnter
	cSQL +=  "                        P8_DATA _DATARF, " + cEnter
	cSQL +=  "                        P8_HORA HORA " + cEnter
	cSQL +=  "                  FROM "+ cSPC +" SPC " + cEnter
	cSQL +=  "                  INNER JOIN "+ cSRA +" SRA ON RA_FILIAL = "+ ValToSQL(xFilial("SRA")) + cEnter
	cSQL +=  "                                       AND RA_MAT = PC_MAT " + cEnter
	cSQL +=  "                                       AND SRA.D_E_L_E_T_ = '' " + cEnter
	cSQL +=  "                  INNER JOIN "+ cCTH +" CTH ON CTH_FILIAL = '' " + cEnter
	cSQL +=  "                                       AND CTH_CLVL = RA_CLVL " + cEnter
	cSQL +=  "                                       AND CTH.D_E_L_E_T_ = '' " + cEnter
	cSQL +=  "                  INNER JOIN "+ cSP9 +" SP9 ON P9_FILIAL = '' " + cEnter
	cSQL +=  "                                       AND P9_CODIGO = PC_PD " + cEnter
	cSQL +=  "                                       AND SP9.D_E_L_E_T_ = ' ' " + cEnter
	cSQL +=  "                   LEFT JOIN "+ cSP8 +" SP8 ON P8_FILIAL = "+ ValToSQL(xFilial("SP8")) + cEnter
	cSQL +=  "                                       AND P8_MAT = PC_MAT " + cEnter
	cSQL +=  "                                       AND P8_DATAAPO = PC_DATA " + cEnter
	//cSQL +=  "                                       AND P8_FLAG NOT IN('I','A') "
	cSQL +=  "                                       AND LTRIM(RTRIM(P8_IDORG)) <> ''" + cEnter
	cSQL +=  "                                       AND P8_TPMCREP <> 'D' " + cEnter
	cSQL +=  "                                       AND SP8.D_E_L_E_T_ = '' " + cEnter
	cSQL +=  "                                       AND P8_TPMARCA <> '2S' " + cEnter	
	cSQL +=  "                  WHERE PC_FILIAL = "+ ValToSQL(xFilial("SPC")) + cEnter
	cSQL +=  "                    AND PC_DATA = "+ ValToSQL(dDataBase-1) + cEnter
	cSQL +=  "                    AND ( ( PC_PD = '110' AND PC_QUANTC > 2 ) OR ( PC_PD = '128' AND PC_QUANTC <> 11 ) " + cEnter
	cSQL +=  "                    OR PC_PD IN('117','131','140') OR (PC_PD = '110' AND RA_TNOTRAB = '047') ) "	 + cEnter
	cSQL +=  "                    AND SPC.D_E_L_E_T_ = '') " + cEnter
	cSQL +=  ",    FALTREG AS (SELECT RA_YSEMAIL YSEMAIL, " + cEnter
	cSQL +=  "                        RA_YSUPEML YSUPEML, " + cEnter
	cSQL +=  "                        RA_MAT MATRIC, " + cEnter
	cSQL +=  "                        RA_NOME NOME, " + cEnter
	cSQL +=  "                        RA_CLVL CLVL, " + cEnter
	cSQL +=  "                        CTH_DESC01 DESCR01, " + cEnter
	cSQL +=  "                        P8_DATAAPO _DATA, " + cEnter
	cSQL +=  "                        P8_HORA QUANT, " + cEnter
	cSQL +=  "                        P8_TPMARCA TPMARCA, " + cEnter
	cSQL +=  "                        P8_DATA _DATARF, " + cEnter
	cSQL +=  "                        P8_HORA HORA, " + cEnter
	cSQL +=  "                        SP8.R_E_C_N_O_ REGSP8 " + cEnter
	cSQL +=  "                  FROM "+ cSP8 +" SP8 " + cEnter
	cSQL +=  "                  INNER JOIN "+ cSRA +" SRA ON RA_FILIAL = "+ ValToSQL(xFilial("SRA")) + cEnter
	cSQL +=  "                                       AND RA_MAT = P8_MAT " + cEnter
	cSQL +=  "                                       AND SRA.D_E_L_E_T_ = '' " + cEnter
	cSQL +=  "                  INNER JOIN "+ cCTH +" CTH ON CTH_FILIAL = '' " + cEnter
	cSQL +=  "                                       AND CTH_CLVL = RA_CLVL " + cEnter
	cSQL +=  "                                       AND CTH.D_E_L_E_T_ = '' " + cEnter
	cSQL +=  "                  WHERE P8_FILIAL = "+ ValToSQL(xFilial("SP8")) + cEnter
	cSQL +=  "                    AND P8_DATAAPO = "+ ValToSQL(dDataBase-1) + cEnter
	//cSQL +=  "                    AND P8_FLAG NOT IN('I','A') "
	cSQL +=  "					  AND LTRIM(RTRIM(P8_IDORG)) <> ''" + cEnter
	cSQL +=  "                    AND P8_TPMCREP <> 'D' " + cEnter
	cSQL +=  "                    AND SP8.D_E_L_E_T_ = '' )" + cEnter
//	cSQL +=  "                    AND P8_TPMARCA <> '2S' )" + cEnter	
	cSQL +=  "SELECT * " + cEnter
	cSQL +=  "FROM EVENTOS " + cEnter
	cSQL +=  "UNION ALL " + cEnter
	cSQL +=  "SELECT RA_YSEMAIL YSEMAIL, " + cEnter
	cSQL +=  "       RA_YSUPEML YSUPEML, " + cEnter
	cSQL +=  "       'FAL' EVENTO, " + cEnter
	cSQL +=  "       'FALTA MARCACAO' DEVENTO, " + cEnter
	cSQL +=  "       RA_MAT MATRIC, " + cEnter
	cSQL +=  "       RA_NOME NOME, " + cEnter
	cSQL +=  "       RA_CLVL CLVL, " + cEnter
	cSQL +=  "       CTH_DESC01 DESCR01, " + cEnter
	cSQL +=  "       P8_DATAAPO _DATA, " + cEnter
	cSQL +=  "       P8_HORA QUANT, " + cEnter
	cSQL +=  "       P8_TPMARCA TPMARCA, " + cEnter
	cSQL +=  "       P8_DATA _DATARF, " + cEnter
	cSQL +=  "       P8_HORA HORA " + cEnter
	cSQL +=  "FROM "+ cSP8 +" SP8 " + cEnter
	cSQL +=  "INNER JOIN "+ cSRA +" SRA ON RA_FILIAL = "+ ValToSQL(xFilial("SRA")) + cEnter
	cSQL +=  "                      AND RA_MAT = P8_MAT " + cEnter
	cSQL +=  "                      AND SRA.D_E_L_E_T_ = '' " + cEnter
	cSQL +=  "INNER JOIN "+ cCTH +" CTH ON CTH_FILIAL = '' " + cEnter
	cSQL +=  "                      AND CTH_CLVL = RA_CLVL " + cEnter
	cSQL +=  "                      AND CTH.D_E_L_E_T_ = '' " + cEnter
	cSQL +=  "WHERE SP8.R_E_C_N_O_ IN(SELECT MAX(REGSP8) CONTAD " + cEnter
	cSQL +=  "                          FROM FALTREG " + cEnter
	cSQL +=  "                          GROUP BY YSEMAIL, " + cEnter
	cSQL +=  "                                   MATRIC, " + cEnter
	cSQL +=  "                                   NOME, " + cEnter
	cSQL +=  "                                   CLVL, " + cEnter
	cSQL +=  "                                   DESCR01, " + cEnter
	cSQL +=  "                                   _DATA " + cEnter
	cSQL +=  "                         HAVING COUNT(*) < 2) " + cEnter
	cSQL +=  "ORDER BY YSEMAIL, EVENTO, MATRIC, _DATA, _DATARF, HORA " + cEnter

Return(cSQL)

//****************************************************************************
//                                                                          **
//****************************************************************************
Static Function fGetName()

	Local cRet := ""		

	cRet := Capital(StrTran(SubStr((cDbFile)->YSEMAIL, 1, (At("@", (cDbFile)->YSEMAIL) - 1)), '.', Space(1))) + Space(1) + AllTrim(Lower((cDbFile)->YSEMAIL))

Return(cRet)

//****************************************************************************
//                                                                          **
//****************************************************************************
Static Function fGetMar()

	Local nRecNo := (cDbFile)->(RecNo())
	Local cRet := ""
	Local cKey := (cDbFile)->(EVENTO+MATRIC+CLVL+_DATA+cValToChar(QUANT))

	If !Empty((cDbFile)->TPMARCA)
		cRet := SubStr((cDbFile)->TPMARCA, 2, 1) + " - " 	
	EndIf

	cRet += dToC(sToD((cDbFile)->_DATARF)) + " - " + cValToChar((cDbFile)->HORA)

	// Pula linha para verificar se o proximo registro é a segunda batida da ponto
	(cDbFile)->(DbSkip())

	// Veirifica se é a segunda batida do funcionario
	If cKey == (cDbFile)->(EVENTO+MATRIC+CLVL+_DATA+cValToChar(QUANT))

		cRet += " -- "

		If !Empty((cDbFile)->TPMARCA)
			cRet += SubStr((cDbFile)->TPMARCA, 2, 1) + " - "
		EndIf

		cRet += dToC(sToD((cDbFile)->_DATARF)) + " - " + cValToChar((cDbFile)->HORA)

	EndIf

	(cDbFile)->(DbGoTo(nRecNo))

Return(cRet)

//****************************************************************************
//                                                                          **
//****************************************************************************
Static Function fGetQtd()
	Local nRet := 0

	nRet := (cDbFile)->QUANT

	nTotHr := SomaHoras(nTotHr, nRet)

Return(nRet)

//****************************************************************************
//                                                                          **
//****************************************************************************
Static Function fSendMail(cHTML, cMail, cGerMail)

	Local cCopia := AllTrim(U_EmailWF('BIAF040', cEmpAnt))

	If (Select("SX6")== 0)
	 	DbSelectArea("SX6")
	EndIf
	If GetNewPar("MV_YWFPON",.T.)
		cMail += ";" + cGerMail + ";" + cCopia
	Else
		cMail := cCopia
	EndIf
	

	U_BIAEnvMail(,cMail, "Inconsistências do Ponto Eletrônico", cHTML)		

Return()
