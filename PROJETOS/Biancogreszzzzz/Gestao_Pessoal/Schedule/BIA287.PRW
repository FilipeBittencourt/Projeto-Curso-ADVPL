#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA287
@author Marcos Alberto Soprani
@since 08/03/12
@version 1.0
@description Envio de e-mail automático para os supervisores contendo rela-
.           ção de funcionários para avaliação de:
.           - Vencimento de Experiencia;
@type function
/*/

User Function BIA287()

	ConOut("HORA: "+TIME()+" - Iniciando Processo BIA287 - BIANCOGRES")
	Startjob("U_WF_BIA287","SCHEDULE",.T.,"01")
	ConOut("HORA: "+TIME()+" - Finalizando PRocesso BIA287 - BIANCOGRES")

	ConOut("HORA: "+TIME()+" - Iniciando Processo BIA287 - INCESA")
	Startjob("U_WF_BIA287","SCHEDULE",.T.,"05")
	ConOut("HORA: "+TIME()+" - Finalizando PRocesso BIA287 - INCESA")

	ConOut("HORA: "+TIME()+" - Iniciando Processo BIA287 - MUNDI")
	Startjob("U_WF_BIA287","SCHEDULE",.T.,"13")
	ConOut("HORA: "+TIME()+" - Finalizando PRocesso BIA287 - MUNDI")
	
	ConOut("HORA: "+TIME()+" - Iniciando Processo BIA287 - LM")
	Startjob("U_WF_BIA287","SCHEDULE",.T.,"07")
	ConOut("HORA: "+TIME()+" - Finalizando PRocesso BIA287 - LM")

Return( .T. )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ WF_BIA287 ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsável pela execução dos Jobs                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function WF_BIA287(AA_EMP)

	Private xPrimeiro
	Private WF001
	Private xVctExp

	If Type("DDATABASE") <> "D"
		Do Case
			Case AA_EMP == "01"
			RPCSETENV("01","01",,,"GPE")
			Case AA_EMP == "05"
			RPCSETENV("05","01",,,"GPE")
			Case AA_EMP == "13"
			RPCSETENV("13","01",,,"GPE")
			Case AA_EMP == "07"
			RPCSETENV("07","01",,,"GPE")
		EndCase
	EndIf

	fr_PriDia := Substr(dtos(dDataBase),1,6)+"01"
	fr_UltDia := dtos(stod(Substr(dtos(dDataBase),1,6)+"01")+35)
	fr_MesExt := Alltrim(MesExtenso(Month(dDataBase)))+"/"+Alltrim(Str(Year(dDataBase)))

	A0001 := " SELECT '1' EXPER,
	A0001 += "        RA_CLVL CLVL,
	A0001 += "        RA_MAT MATRIC,
	A0001 += "        RA_NOME NOME,
	A0001 += "        RA_ADMISSA DT_ADMIS,
	A0001 += "        RA_VCTOEXP VCTEXP01,
	A0001 += "        RA_VCTEXP2 VCTEXP02,
	A0001 += "        ISNULL((SELECT QB_YPCMSO
	A0001 += "                  FROM " + RetSqlName("SQB")
	A0001 += "                 WHERE QB_FILIAL = '"+xFilial("SQB")+"'
	A0001 += "                   AND QB_DEPTO = RA_DEPTO
	A0001 += "                   AND D_E_L_E_T_ = ' '), 'NAO CLASSIFICADO') SETOR,
	A0001 += "        RA_YSEMAIL EMLSUP,
	A0001 += "        RA_YSUPEML EMLGER
	A0001 += "   FROM " + RetSqlName("SRA")
	A0001 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
	A0001 += "    AND RA_VCTOEXP BETWEEN '"+fr_PriDia+"' AND '"+fr_UltDia+"'
	A0001 += "    AND RA_MAT BETWEEN '      ' AND '099999'
	A0001 += "    AND RA_SITFOLH <> 'D'
	A0001 += "    AND RA_CATFUNC = 'M'
	A0001 += "    AND RA_CATEG <> '07'
	A0001 += "    AND D_E_L_E_T_ = ' '
	A0001 += " UNION ALL
	A0001 += " SELECT '2' EXPER,
	A0001 += "        RA_CLVL CLVL,
	A0001 += "        RA_MAT MATRIC,
	A0001 += "        RA_NOME NOME,
	A0001 += "        RA_ADMISSA DT_ADMIS,
	A0001 += "        RA_VCTOEXP VCTEXP01,
	A0001 += "        RA_VCTEXP2 VCTEXP02,
	A0001 += "        ISNULL((SELECT QB_YPCMSO
	A0001 += "                  FROM " + RetSqlName("SQB")
	A0001 += "                 WHERE QB_FILIAL = '"+xFilial("SQB")+"'
	A0001 += "                   AND QB_DEPTO = RA_DEPTO
	A0001 += "                   AND D_E_L_E_T_ = ' '), 'NAO CLASSIFICADO') SETOR,
	A0001 += "        RA_YSEMAIL EMLSUP,
	A0001 += "        RA_YSUPEML EMLGER
	A0001 += "   FROM " + RetSqlName("SRA")
	A0001 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
	A0001 += "    AND RA_VCTEXP2 BETWEEN '"+fr_PriDia+"' AND '"+fr_UltDia+"'
	A0001 += "    AND RA_MAT BETWEEN '      ' AND '099999'
	A0001 += "    AND RA_SITFOLH <> 'D'
	A0001 += "    AND RA_CATFUNC = 'M'
	A0001 += "    AND RA_CATEG <> '07'
	A0001 += "    AND D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY EMLSUP, EXPER, EMLGER, NOME
	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	While !A001->(Eof())

		Imp_Cabec()
		Im_TtExp()

		xEmailRf := A001->EMLSUP
		xEmlGrRf := A001->EMLGER
		xPrimeiro := .T.
		While !A001->(Eof()) .and. A001->EMLSUP == xEmailRf

			WF001 += '  <tr> '
			WF001 += '    <td class="style8" scope="row"><div align="center">'+Alltrim(A001->CLVL)+'</div></td> '
			WF001 += '    <td class="style8"><div align="center">'+A001->MATRIC+'</div></td> '
			WF001 += '    <td class="style8"><div align="left">'+Alltrim(A001->NOME)+'</div></td> '
			WF001 += '    <td class="style8"><div align="center">'+dtoc(stod(A001->DT_ADMIS))+'</div></td> '
			WF001 += '    <td class="style8"><div align="center">'+dtoc(stod(A001->VCTEXP01))+'</div></td> '
			WF001 += '    <td class="style8"><div align="center">'+dtoc(stod(A001->VCTEXP02))+'</div></td> '
			WF001 += '    <td class="style8"><div align="left">'+Alltrim(A001->SETOR)+'</div></td> '
			WF001 += '  </tr> '

			dbSelectArea("A001")
			A001->(dbSkip())

		End
		Imp_FimFn()
		Imp_Rodap()

		lDebug := .F.
		df_Dest := Alltrim(xEmailRf)+";"+Alltrim(xEmlGrRf)+";"+ U_EmailWF('BIA287',cEmpAnt)
		df_Assu := "Informativo Dpto.Pessoal: Vencimento de Experiência.   "
		df_Erro := "Informativo Dpto.Pessoal: Vencimento de Experiência não enviado. Favor verificar!!!"

		If lDebug
			df_Assu := "Informativo Dpto.Pessoal: Vencimento de Experiência.  - " + df_Dest
			df_Erro := "Informativo Dpto.Pessoal: Vencimento de Experiência não enviado. Favor verificar!!! - " + df_Dest
			df_Dest := 'jussara.nobrega@biancogres.com.br'
		EndIf

		U_BIAEnvMail(, df_Dest, df_Assu, WF001, df_Erro)

	End

	A001->(dbCloseArea())

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Imp_Cabec ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Cabeçalho                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_Cabec()

	WF001 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	WF001 += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	WF001 += ' <head> '
	WF001 += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> '
	WF001 += ' <title>Untitled Document</title> '
	WF001 += ' <style type="text/css"> '
	WF001 += ' <!-- '
	WF001 += ' .style1 { '
	WF001 += ' 	font-family: "Times New Roman", Times, serif; '
	WF001 += ' 	font-size: 10; '
	WF001 += ' } '
	WF001 += ' .style4 { '
	WF001 += ' 	font-family: "Times New Roman", Times, serif; '
	WF001 += ' 	font-size: 14px; '
	WF001 += ' } '
	WF001 += ' .style7 {font-family: "Times New Roman", Times, serif; font-size: 12px; font-weight: bold; color: #FFFFFF; } '
	WF001 += ' .style8 {font-family: "Times New Roman", Times, serif; font-size: 12px; } '
	WF001 += ' .style9 { '
	WF001 += ' 	font-family: "Times New Roman", Times, serif; '
	WF001 += ' 	font-size: 14px; '
	WF001 += ' } '
	WF001 += ' --> '
	WF001 += ' </style> '
	WF001 += ' </head> '
	WF001 += ' <body> '
	WF001 += ' <p class="style4">Senhores,</p> '
	WF001 += ' <p class="style4">Segue relação dos colaboradores com vencimento do contrato de experiência:</p> '
	WF001 += ' <p class="style4">Mês de Referência: <strong>'+fr_MesExt+'</strong></p> '

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Im_TtExp ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Titulo para Tabela                                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Im_TtExp()

	WF001 += ' <table width="742" border="1"> '
	WF001 += '   <tr> '
	WF001 += '     <td colspan="7" class="style4" scope="row"><div align="center"><strong>Vencimento Contrato de Experiência</strong></div></td> '
	WF001 += '   </tr> '
	WF001 += '   <tr> '
	WF001 += '     <td width="54" bgcolor="#000099" class="style7" scope="row"><div align="center">C.Custo</div></td> '
	WF001 += '     <td width="50" bgcolor="#000099" class="style7"><div align="center">Matric</div></td> '
	WF001 += '     <td width="165" bgcolor="#000099" class="style7"><div align="left">Nome</div></td> '
	WF001 += '     <td width="76" bgcolor="#000099" class="style7"><div align="center">Admissão</div></td> '
	WF001 += '     <td width="76" bgcolor="#000099" class="style7"><div align="center">Venc. 1a Per</div></td> '
	WF001 += '     <td width="76" bgcolor="#000099" class="style7"><div align="center">Venc. 2a Per</div></td> '
	WF001 += '     <td width="199" bgcolor="#000099" class="style7"><div align="left">Setor</div></td> '
	WF001 += '   </tr> '

	xPrimeiro := .F.

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Imp_FimFn ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Finalização da Tabela                             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_FimFn()

	WF001 += '   </tr> '
	WF001 += ' </table> '
	WF001 += ' <p>&nbsp;</p> '

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Imp_Rodap ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 28/02/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Rodapé de Horas Extras                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_Rodap()

	WF001 += ' <p class="style4">OBS: Caso haja a necessidade de desligamento no período de  experiência, favor informar ao Setor de Pessoal com antecedência mínima de 05 dias úteis (<strong>UN-IT-SPE-03).</strong> </p> '
	WF001 += ' <p class="style4">&nbsp;</p> '
	WF001 += ' <p class="style4">Atenciosamente,</p> '
	WF001 += ' <p class="style9">&nbsp;</p> '
	WF001 += ' <p class="style9">Departamento Pessoal.</p> '
	WF001 += ' <p class="style9">&nbsp;</p> '
	WF001 += ' <p class="style9">Informações geradas automaticamente por meio de parametrização do sistema Protheus (by BIA287).</p> '
	WF001 += ' <p class="style9">&nbsp;</p> '
	WF001 += ' </body> '
	WF001 += ' </html> '

Return
