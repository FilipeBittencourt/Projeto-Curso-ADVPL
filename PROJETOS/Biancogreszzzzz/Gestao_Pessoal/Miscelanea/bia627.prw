#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA627
@author Marcos Alberto Soprani
@since 15/08/2016
@version 1.0
@description Workflow - Analítico - Inconsistências Intrajornada igual a 11 horas
@obs OS: 3199-16 - Vania
@type function
/*/

User Function BIA627()

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

			fSendMail(cHTML)

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
	cRet += '                    		<span class="styleLabel">RELATÓRIO ANALÍTICO - INCONSISTÊNCIAS INTRAJORNADA IGUAL A 11 HORAS</span> '
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

	cDesc := "HORAS INTERJORNADAS IGUAL A 11 HORAS"

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
	cRet += '                <th class="styleCabecalho" width="60" scope="col">Qtde Horas</th> '		
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
	cRet += '        <p>by BIA627</p> '
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

	cSQL +=  "WITH EVENTOS AS (SELECT 'X' YSEMAIL, "
	cSQL +=  "                        'Y' YSUPEML, "
	cSQL +=  "                        PC_PD EVENTO, "
	cSQL +=  "                        P9_DESC DEVENTO, "
	cSQL +=  "                        PC_MAT MATRIC, "
	cSQL +=  "                        RA_NOME NOME, "
	cSQL +=  "                        RA_CLVL CLVL, "
	cSQL +=  "                        CTH_DESC01 DESCR01, "
	cSQL +=  "                        PC_DATA _DATA, "
	cSQL +=  "                        PC_QUANTC QUANT, "
	cSQL +=  "                        P8_TPMARCA TPMARCA, "
	cSQL +=  "                        P8_DATA _DATARF, "
	cSQL +=  "                        P8_HORA HORA "
	cSQL +=  "                  FROM "+ cSPC +" SPC "
	cSQL +=  "                  INNER JOIN "+ cSRA +" SRA ON RA_FILIAL = "+ ValToSQL(xFilial("SRA"))
	cSQL +=  "                                       AND RA_MAT = PC_MAT "
	cSQL +=  "                                       AND SRA.D_E_L_E_T_ = '' "
	cSQL +=  "                  INNER JOIN "+ cCTH +" CTH ON CTH_FILIAL = "+ ValToSQL(xFilial("CTH"))
	cSQL +=  "                                       AND CTH_CLVL = RA_CLVL "
	cSQL +=  "                                       AND CTH.D_E_L_E_T_ = '' "
	cSQL +=  "                  INNER JOIN "+ cSP9 +" SP9 ON P9_FILIAL = "+ ValToSQL(xFilial("SP9"))
	cSQL +=  "                                       AND P9_CODIGO = PC_PD "
	cSQL +=  "                                       AND SP9.D_E_L_E_T_ = ' ' "
	cSQL +=  "                   LEFT JOIN "+ cSP8 +" SP8 ON P8_FILIAL = "+ ValToSQL(xFilial("SP8"))
	cSQL +=  "                                       AND P8_MAT = PC_MAT "
	cSQL +=  "                                       AND P8_DATAAPO = PC_DATA "
	cSQL +=  "                                       AND P8_FLAG NOT IN('I','A') "
	cSQL +=  "                                       AND P8_TPMCREP <> 'D' "
	cSQL +=  "                                       AND SP8.D_E_L_E_T_ = '' "
	cSQL +=  "                  WHERE PC_FILIAL = "+ ValToSQL(xFilial("SPC"))
	cSQL +=  "                    AND PC_DATA = "+ ValToSQL(dDataBase-1)
	cSQL +=  "                    AND PC_PD = '128' "
	cSQL +=  "                    AND PC_QUANTC = 11 "
	cSQL +=  "                    AND SPC.D_E_L_E_T_ = ' ') "
	cSQL +=  "SELECT * "
	cSQL +=  "FROM EVENTOS "
	cSQL +=  "ORDER BY YSEMAIL, EVENTO, MATRIC, _DATA, _DATARF, HORA "

Return(cSQL)

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
Static Function fSendMail(cHTML)

	Local cCopia := AllTrim(U_EmailWF('BIA627', cEmpAnt))

	cMail := cCopia

	U_BIAEnvMail(,cMail, "Inconsistências Intrajornada igual a 11 horas", cHTML)		

Return()
