#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF041
@author Tiago Rossini Coradini
@since 13/07/2016
@version 1.0
@description Workflow - Sintetico - Inconsistências do ponto eletrônico
@obs OS: 2623-15 - Claudia Mara
@type function
/*/

User Function BIAF041()

	Local xt

	Private zp_EpAtu

	cv_ViaWf := .F.
	If Select("SX6") == 0

		xv_Emps    := U_BAGtEmpr("01_05_14")
		For xt := 1 To Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)

			RPCSetEnv(xv_Emps[xt,1], xv_Emps[xt,2], "", "", "PON", "",{"SRA","SRX","SP4","SPC","SP9","SP8"})

			cv_ViaWf := .T.
			zp_EpAtu := xv_Emps[xt,1]
			MV_PAR01 := stod(Substr(dtos(dDataBase - 30),1,6)+"21")
			MV_PAR02 := dDataBase - 2 // Schedule configurado para ser executado no dia 22 de cada mês a zero hora, portanto tem que ser dois dias menos...
			ConOut("HORA: "+TIME()+" --> BIAF041 - Iniciando Processo " + xv_Emps[xt,1])

			Processa({||BF041ATU()})

			ConOut("HORA: "+TIME()+" --> BIAF041 - Finalizando Processo " + xv_Emps[xt,1])

			RpcClearEnv()

		Next xt

	Else

		zp_EpAtu := cEmpAnt
		cHInicio := Time()
		fPerg := "BIAF041"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		ValidPerg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		Processa({||BF041ATU()})

	EndIf

Return

//**********************************************************************************************
//**                                                                                          **
//**********************************************************************************************
Static Function BF041ATU()

	Local cSQL := ""
	Local lHTab := .T.
	Local cEve := ""
	Private cQry := GetNextAlias()
	Private cDbFile := GetNextAlias()
	Private cHTML := ""
	Private oLst := ArrayList():New()
	Private nTotHr := 0
	Private nTtHFn := 0

	cSQL := fGetSQL()

	TcQuery cSQL New Alias cQry

	cDbfFile := CriaTrab(cQry->(DbStruct()), .T.)	
	COPY TO &cDbfFile VIA "DBFCDX"

	cQry->(DbCloseArea())

	DbUseArea(.T., "DBFCDX", cDbfFile, (cDbFile))		

	cHTML := ""
	cHTML += fGetHeader()
	While !(cDbFile)->(Eof())

		If lHTab				
			cHTML += fGetHTable()
			lHTab := .F.				
		EndIf			

		// Estrutura de repetição implementada por Marcos Alberto Soprani em 22/07/16. A condição implementada originalmente acabava listando todos os registros.
		nTtHFn    := 0 
		cEve      := (cDbFile)->EVENTO
		gbCLVL    := AllTrim((cDbFile)->CLVL)
		gbDESCR01 := Capital(AllTrim((cDbFile)->DESCR01))
		gbSuper   := fGetName()
		gbFuncion := (cDbFile)->MATRIC + "-" + Capital(AllTrim((cDbFile)->NOME))
		gbKeyP    := (cDbFile)->(EVENTO+CLVL+YSEMAIL+MATRIC)
		While !(cDbFile)->(Eof()) .and. (cDbFile)->(EVENTO+CLVL+YSEMAIL+MATRIC) == gbKeyP 

			fGetQtd()

			(cDbFile)->(DbSkip())

		End	

		cHTML += fGetTItem(cEve)

		If lHTab := (cEve <> (cDbFile)->EVENTO) 

			cHTML += fGetTFooter(cEve)

		EndIf

	EndDo	

	cHTML += fGetHFooter()

	fSendMail(cHTML)

	(cDbFile)->(DbCloseArea())

Return()

//********************************************************************
//*                                                                  * 
//********************************************************************
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
	cRet += '                    		<span class="styleLabel">RELATÓRIO SINTÉTICO - INCONSISTÊNCIAS DO PONTO ELETRÔNICO</span> '
	cRet += '                    </td> '
	cRet += '                </tr> '
	cRet += '                <tr class="styleTableCabecalho"> '
	cRet += '                    <td width="20%" style="text-align:left;"> '
	cRet += '                    		<span class="styleLabel">Empresa:</span> '
	cRet += '                        <span class="styleValor">'+ Capital(FWEmpName(zp_EpAtu)) +'</span> '
	cRet += '                    </td> '
	cRet += '                </tr> '                
	cRet += '                <tr class="styleTableCabecalho"> '
	cRet += '                    <td width="20%" style="text-align:left;"> '
	cRet += '                        <span class="styleLabel">Data:</span> '
	cRet += '                        <span class="styleValor">de ' + dToC(MV_PAR01) + ' até '  + dToC(MV_PAR02) +  '</span> '
	cRet += '                    </td> '
	cRet += '                </tr> '                
	cRet += '            </tbody> '
	cRet += '        </table> '
	cRet += '        <br /> '
	cRet += '        <br />	'

Return(cRet)

//********************************************************************
//*                                                                  * 
//********************************************************************
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
	cRet += '                <td colspan="4">'+ cDesc 
	cRet += '                </td> '
	cRet += '            </tr> '
	cRet += '            <tr align="center"> '
	cRet += '                <th class="styleCabecalho" width="20" scope="col">CV</th> '
	cRet += '                <th class="styleCabecalho" width="100" scope="col">Setor</th> '
	cRet += '                <th class="styleCabecalho" width="200" scope="col">Supervisão</th> '
	cRet += '                <th class="styleCabecalho" width="200" scope="col">Colaborador</th> '

	If !(cDbFile)->EVENTO == "FAL"
		cRet += '                <th class="styleCabecalho" width="60" scope="col">Qtde Horas</th> '
	EndIf

	cRet += '            </tr> '

Return(cRet)

//********************************************************************
//*                                                                  * 
//********************************************************************
Static Function fGetTItem(cEve)

	Local cRet := ""

	cRet += '        <tr align=center> '
	cRet += '            <td class="styleLinha" width="20" scope="col">'+ gbCLVL +'</td> '
	cRet += '            <td class="styleLinha" width="100" scope="col">'+ gbDESCR01 +'</td> '
	cRet += '            <td class="styleLinha" width="200" scope="col">'+ gbSuper +'</td> '		
	cRet += '            <td class="styleLinha" width="200" scope="col">'+ gbFuncion +'</td> '

	If !cEve == "FAL"
		cRet += '            <td class="styleLinha" styleNumerico" width="60" scope="col">'+ cValToChar(nTtHFn) +'</td> '
	EndIf				

	cRet += '        </tr> '

Return(cRet)

//********************************************************************
//*                                                                  * 
//********************************************************************
Static Function fGetTFooter(cEve)

	Local cRet := ""

	If cEve <> "FAL"

		cRet += '            <tr> '
		cRet += '                <td class="styleRodape" width="60" scope="col" colspan="4">Total de Horas</td> '
		cRet += '                <td class="styleRodape styleLinha styleNumerico styleTotal" width="60" scope="col">'+ cValToChar(nTotHr) +'</td> '
		cRet += '            </tr> '

	EndIf

	cRet += '        </table> '
	cRet += '        <br /> '		

	nTotHr := 0

Return(cRet)

//********************************************************************
//*                                                                  * 
//********************************************************************
Static Function fGetHFooter()
	Local cRet := ""

	cRet += '        <p>Informações geradas automaticamente a partir da importação dos dados do relógios de Ponto para o sistema Protheus.</p> '
	cRet += '        <p>Estas informações não foram tratadas e poderão sofrer algum tipo de tratamento durante o processo de fechamento do Ponto.</p> '
	cRet += '        <p>Sem mais,</p> '
	cRet += '        <p><b>Equipe de RH</b></p> '
	cRet += '        <p>By BIAF041</p> '
	cRet += '    </div> '
	cRet += '</body> '
	cRet += '</html> '

Return(cRet)

//********************************************************************
//*                                                                  * 
//********************************************************************
Static Function fGetSQL()
	local cSQL := ""
	Local cSPC := RetSQLName("SPC")
	Local cSRA := RetSQLName("SRA")
	Local cCTH := RetSQLName("CTH")
	Local cSP9 := RetSQLName("SP9")
	Local cSP8 := RetSQLName("SP8")

	cSQL +=  "WITH EVENTOS AS (SELECT RA_YSEMAIL YSEMAIL, "
	cSQL +=  "                        PC_PD EVENTO, "
	cSQL +=  "                        P9_DESC DEVENTO, "
	cSQL +=  "                        PC_MAT MATRIC, "
	cSQL +=  "                        RA_NOME NOME, "
	cSQL +=  "                        RA_CLVL CLVL, "
	cSQL +=  "                        CTH_DESC01 DESCR01, "
	cSQL +=  "                        PC_DATA _DATA, "
	cSQL +=  "                        PC_QUANTC QUANT "
	cSQL +=  "                  FROM "+ cSPC +" SPC "
	cSQL +=  "                  INNER JOIN "+ cSRA +" SRA ON RA_FILIAL = "+ ValToSQL(xFilial("SRA"))
	cSQL +=  "                                       AND RA_MAT = PC_MAT "
	cSQL +=  "                                       AND SRA.D_E_L_E_T_ = '' "
	cSQL +=  "                  INNER JOIN "+ cCTH +" CTH ON CTH_FILIAL = '' "
	cSQL +=  "                                       AND CTH_CLVL = RA_CLVL "
	cSQL +=  "                                       AND CTH.D_E_L_E_T_ = '' "
	cSQL +=  "                  INNER JOIN "+ cSP9 +" SP9 ON P9_FILIAL = '' "
	cSQL +=  "                                       AND P9_CODIGO = PC_PD "
	cSQL +=  "                                       AND SP9.D_E_L_E_T_ = ' ' "
	cSQL +=  "                  WHERE PC_FILIAL = "+ ValToSQL(xFilial("SPC"))
	cSQL +=  "                    AND PC_DATA BETWEEN "+ValToSQL(MV_PAR01)+" AND "+ValToSQL(MV_PAR02)+" " 
	cSQL +=  "                    AND ( ( PC_PD = '110' AND PC_QUANTC > 2 ) OR ( PC_PD = '128' AND PC_QUANTC <> 11 ) OR PC_PD IN('117','131','140') ) "
	cSQL +=  "                    AND SPC.D_E_L_E_T_ = '') "
	cSQL +=  ",    FALTREG AS (SELECT RA_YSEMAIL YSEMAIL, "
	cSQL +=  "                        RA_MAT MATRIC, "
	cSQL +=  "                        RA_NOME NOME, "
	cSQL +=  "                        RA_CLVL CLVL, "
	cSQL +=  "                        CTH_DESC01 DESCR01, "
	cSQL +=  "                        P8_DATAAPO _DATA, "
	cSQL +=  "                        P8_HORA QUANT, "
	cSQL +=  "                        SP8.R_E_C_N_O_ REGSP8 "
	cSQL +=  "                  FROM "+ cSP8 +" SP8 "
	cSQL +=  "                  INNER JOIN "+ cSRA +" SRA ON RA_FILIAL = "+ ValToSQL(xFilial("SRA"))
	cSQL +=  "                                       AND RA_MAT = P8_MAT "
	cSQL +=  "                                       AND SRA.D_E_L_E_T_ = '' "
	cSQL +=  "                  INNER JOIN "+ cCTH +" CTH ON CTH_FILIAL = '' "
	cSQL +=  "                                       AND CTH_CLVL = RA_CLVL "
	cSQL +=  "                                       AND CTH.D_E_L_E_T_ = '' "
	cSQL +=  "                  WHERE P8_FILIAL = "+ ValToSQL(xFilial("SP8"))
	cSQL +=  "                    AND P8_DATAAPO BETWEEN "+ValToSQL(MV_PAR01)+" AND "+ValToSQL(MV_PAR02)+" "
	cSQL +=  "                    AND P8_FLAG NOT IN('I','A') "
	cSQL +=  "                    AND P8_TPMCREP <> 'D' "
	cSQL +=  "                    AND SP8.D_E_L_E_T_ = '') "
	cSQL +=  "SELECT * "
	cSQL +=  "FROM EVENTOS "
	cSQL +=  "UNION ALL "
	cSQL +=  "SELECT RA_YSEMAIL YSEMAIL, "
	cSQL +=  "       'FAL' EVENTO, "
	cSQL +=  "       'FALTA MARCACAO' DEVENTO, "
	cSQL +=  "       RA_MAT MATRIC, "
	cSQL +=  "       RA_NOME NOME, "
	cSQL +=  "       RA_CLVL CLVL, "
	cSQL +=  "       CTH_DESC01 DESCR01, "
	cSQL +=  "       P8_DATAAPO _DATA, "
	cSQL +=  "       P8_HORA QUANT "
	cSQL +=  "FROM "+ cSP8 +" SP8 "
	cSQL +=  "INNER JOIN "+ cSRA +" SRA ON RA_FILIAL = "+ ValToSQL(xFilial("SRA"))
	cSQL +=  "                      AND RA_MAT = P8_MAT "
	cSQL +=  "                      AND SRA.D_E_L_E_T_ = '' "
	cSQL +=  "INNER JOIN "+ cCTH +" CTH ON CTH_FILIAL = '' "
	cSQL +=  "                      AND CTH_CLVL = RA_CLVL "
	cSQL +=  "                      AND CTH.D_E_L_E_T_ = '' "
	cSQL +=  "WHERE SP8.R_E_C_N_O_ IN(SELECT MAX(REGSP8) CONTAD "
	cSQL +=  "                          FROM FALTREG "
	cSQL +=  "                          GROUP BY YSEMAIL, "
	cSQL +=  "                                   MATRIC, "
	cSQL +=  "                                   NOME, "
	cSQL +=  "                                   CLVL, "
	cSQL +=  "                                   DESCR01, "
	cSQL +=  "                                   _DATA "
	cSQL +=  "                         HAVING COUNT(*) NOT IN(2,4,6,8)) "
	cSQL +=  "ORDER BY EVENTO, YSEMAIL, MATRIC, _DATA "

Return(cSQL)

//********************************************************************
//*                                                                  * 
//********************************************************************
Static Function fGetName()

	Local cRet := ""		

	cRet := Capital(AllTrim(StrTran(SubStr((cDbFile)->YSEMAIL, 1, (At("@", (cDbFile)->YSEMAIL) - 1)), '.', Space(1))))

Return(cRet)

//********************************************************************
//*                                                                  * 
//********************************************************************
Static Function fGetQtd()

	Local nRet := 0

	nRet := (cDbFile)->QUANT

	nTotHr := SomaHoras(nTotHr, nRet)
	nTtHFn := SomaHoras(nTtHFn, nRet)

Return(nRet)

//********************************************************************
//*                                                                  * 
//********************************************************************
Static Function fSendMail(cHTML)

	Local cMail := AllTrim(U_EmailWF('BIAF041', zp_EpAtu))

	U_BIAEnvMail(,cMail, "Inconsistências do Ponto Eletrônico", cHTML)		

Return()

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs := {}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
