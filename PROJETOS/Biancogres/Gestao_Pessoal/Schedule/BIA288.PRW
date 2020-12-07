#Include "Protheus.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} BIA288
@author Marcos Alberto Soprani
@since 09/03/12
@version 1.0
@description Envio de e-mail automático para os supervisores contendo rela-
.           ção de funcionários para avaliação de:
.           - Tempo de trabalho do colaborador 6 meses e 1 ano;
@type function
/*/

User Function BIA288()

	ConOut("HORA: "+TIME()+" - Iniciando Processo BIA288 - BIANCOGRES")
	Startjob("U_WF_BI288","SCHEDULE",.T.,"01")
	ConOut("HORA: "+TIME()+" - Finalizando Processo BIA288 - BIANCOGRES")

	ConOut("HORA: "+TIME()+" - Iniciando Processo BIA288 - INCESA")
	Startjob("U_WF_BI288","SCHEDULE",.T.,"05")
	ConOut("HORA: "+TIME()+" - Finalizando PRocesso BIA288 - INCESA")

	ConOut("HORA: "+TIME()+" - Iniciando Processo BIA288 - MUNDI")
	Startjob("U_WF_BI288","SCHEDULE",.T.,"13")
	ConOut("HORA: "+TIME()+" - Finalizando PRocesso BIA288 - MUNDI")

Return( .T. )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ WF_BIA288 ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 09/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsável pela execução dos Jobs                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function WF_BI288TH(AA_EMP)

	Private xPrimeiro
	Private WF001
	Private xEmlDir := ""
	Private xEmprOr := ""

	If Type("DDATABASE") <> "D"

		Do Case

			Case AA_EMP == "01"
			RPCSETENV("01","01",,,"GPE")
			xEmlDir := ""
			xEmprOr := "BG"
			Case AA_EMP == "05"
			RPCSETENV("05","01",,,"GPE")
			xEmlDir := ""
			xEmprOr := "IN"
			Case AA_EMP == "13"
			RPCSETENV("13","01",,,"GPE")
			xEmlDir := "kelmer.casotti@biancogres.com.br"
			xEmprOr := "MD"

		EndCase

	EndIf

	fr_PriDia := Substr(dtos(dDataBase),1,6)+"01"
	fr_UltDia := dtos(Ultimodia(dDataBase))
	fr_DiaRet := dtoc(stod(Substr(dtos(dDataBase),1,6)+"15"))
	fr_MesExt := Alltrim(MesExtenso(Month(dDataBase)))+"/"+Alltrim(Str(Year(dDataBase)))

	//(Thiago Dantas - 14/03/2014)
	A0001 := GeraSql()

	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	// A consulta está ordenada por email para que seja agrupada por destinatário para evitar mandar mais de um email.
	While !Eof()

		xQdPeri 	:= A001->PERIODO
		xEmailRf 	:= A001->EMAIL	
		xCLVL       := A001->CLVL

		Imp_Cabec()
		Im_TtExp()

		df_Dest := ""

		//Pega todos os funcionarios para um mesmo email
		While !Eof() .and. A001->EMAIL == xEmailRf 

			//Monta a tabela para um mesmo período.
			If(A001->PERIODO == xQdPeri)

				WF001 += '   <tr> '
				WF001 += '     <td height="20" class="style4" scope="row"><div align="center" class="style6">'+A001->MATRIC+'</div></td> '
				WF001 += '     <td class="style4"><div align="center" class="style6">'+Alltrim(A001->CLVL)+'</div></td> '
				WF001 += '     <td class="style4"><div align="left" class="style6">'+Alltrim(A001->NOME)+'</div></td> '
				WF001 += '     <td class="style4"><div align="center" class="style6">'+dtoc(stod(A001->DT_ADMIS))+'</div></td> '
				WF001 += '     <td class="style4"><div align="left" class="style6">'+Alltrim(A001->RJ_DESC)+'</div></td> '
				WF001 += '     <td class="style4"><div align="right" class="style6">'+Transform(A001->RA_SALARIO, "@E 999,999.99")+'</div></td> '
				WF001 += '     <td class="style4"><div align="left" class="style6">'+A001->SETOR+'</div></td> '
				WF001 += '     <td class="style4"><div align="right" class="style6"></div></td> '
				WF001 += '     <td class="style4"><div align="left" class="style6"></div></td> '
				WF001 += '   </tr> '

				dbSelectArea("A001")
				dbSkip()

			Else

				WF001 += '<br>'
				// fecha a tabela para periodo de 1 ano
				Imp_FimFn()

				// abre a tabela para o periodo de 2 anos
				xQdPeri := A001->PERIODO
				Im_TtExp()

			EndIf

		End

		If A001->EMAIL != xEmailRf

			// fecha a tabela montada
			Imp_FimFn()
			// gera o rodapé do email
			Imp_Rodap()

			df_Assu := "Relação colaboradores completando 6 meses e 1 ano "+xEmprOr+" - ref. " + fr_MesExt
			df_Erro := "Relação colaboradores completando 6 meses e 1 ano BG - ref. nov/2011 não enviado. Favor verificar!!!"

			//Pega todos os destinatários para a classe de valor.
			df_Dest := U_EmailWF('BIA288', AA_EMP , xCLVL )

			U_BIAEnvMail(, df_Dest, df_Assu, WF001, df_Erro)

			xCLVL := A001->CLVL

		EndIf

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
	WF001 += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	WF001 += ' <title>Untitled Document</title> '
	WF001 += ' <style type="text/css"> '
	WF001 += ' <!-- '
	WF001 += ' .style1 { '
	WF001 += ' 	font-family: "Times New Roman", Times, serif; '
	WF001 += ' 	font-size: 12px; '
	WF001 += ' } '
	WF001 += ' .style2 {font-family: "Times New Roman", Times, serif; font-size: 14px; } '
	WF001 += ' .style3 {font-family: "Times New Roman", Times, serif; font-size: 12px; font-weight: bold; } '
	WF001 += ' .style4 {font-family: "Times New Roman", Times, serif; font-size: 10px; } '
	WF001 += ' .style5 {color: #FFFFFF} '
	WF001 += ' .style6 {font-size: 12px} '
	WF001 += ' --> '
	WF001 += ' </style> '
	WF001 += ' </head> '
	WF001 += ' <body> '
	WF001 += ' <p class="style2">Senhores, </p> '
	WF001 += ' <p class="style2">Segue planilha para avaliação,  em caso de reajuste favor devolver ao DP com o “de acordo” até '+fr_DiaRet+'.</p> '
	WF001 += ' <p class="style2">&nbsp;</p> '

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Im_TtExp  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 08/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Titulo para Tabela                                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Im_TtExp()

	WF001 += ' <table width="900" border="1" cellspacing="0" bordercolor="#000000"> '
	WF001 += '   <tr> '
	WF001 += '     <td height="26" colspan="9" bgcolor="#999999" class="style1" scope="row"><div align="center"><strong>RELAÇÃO DOS COLABORADORES - '+IIF(xQdPeri == "1", "6 MESES", "1 ANO")+' DE ADMISSÃO</strong></div></td> '
	WF001 += '   </tr> '
	WF001 += '   <tr> '
	WF001 += '     <td colspan="7" bgcolor="#0066FF" class="style3" scope="row"><div align="center" class="style5">Situação Atual</div></td> '
	WF001 += '     <td colspan="2" bgcolor="#FFFF00" class="style3"><div align="center" >Proposta</div></td> '
	WF001 += '   </tr> '
	WF001 += '   <tr> '
	WF001 += '     <td width="35" bgcolor="#0066FF" class="style3" scope="row"><div align="center" class="style5">Matr</div></td> '
	WF001 += '     <td width="51" bgcolor="#0066FF" class="style3"><div align="center" class="style5">C.Custo</div></td> '
	WF001 += '     <td width="208" bgcolor="#0066FF" class="style3"><div align="left" class="style5">Colaborador</div></td> '
	WF001 += '     <td width="72" bgcolor="#0066FF" class="style3"><div align="center" class="style5">Admissão</div></td> '
	WF001 += '     <td width="100" bgcolor="#0066FF" class="style3"><div align="left" class="style5">Função</div></td> '
	WF001 += '     <td width="57" bgcolor="#0066FF" class="style3"><div align="right" class="style5">Salário</div></td> '
	WF001 += '     <td width="119" bgcolor="#0066FF" class="style3"><div align="left" class="style5">Setor</div></td> '
	WF001 += '     <td width="64" bgcolor="#FFFF00" class="style3"><div align="right">Salário</div></td> '
	WF001 += '     <td width="136" bgcolor="#FFFF00" class="style3"><div align="left">Função</div></td> '
	WF001 += '   </tr> '

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

	WF001 += ' </table> '
	WF001 += ' <p class="style1">&nbsp;</p> '

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

	WF001 += ' <p class="style2">&nbsp;</p> '
	WF001 += ' <p class="style2">Atenciosamente,</p> '
	WF001 += ' <p class="style2">&nbsp;</p> '
	WF001 += ' <p class="style2">Departamento Pessoal.</p> '
	WF001 += ' <p class="style2">&nbsp;</p> '
	WF001 += ' <p class="style2">Informações geradas automaticamente por meio de parametrização do sistema Protheus (by BIA288).</p> '
	WF001 += ' <p class="style1">&nbsp;</p> '
	WF001 += ' </body> '
	WF001 += ' </html> '

Return

Static Function GeraSql()

	cSql := ''
	cSql+= " SELECT (CASE DATEDIFF(MONTH,CONVERT(DATETIME,(RA_ADMISSA)),CONVERT(DATETIME,'"+fr_UltDia+"' ))   "
	cSql+= "			 WHEN  6 THEN '1' "                                                                   "
	cSql+= " 			 WHEN 12 THEN '2'                                                                     "
	cSql+= " 	   END) PERIODO,                                                                              "
	cSql+= "        RA_CLVL CLVL,                                                                             "
	cSql+= "        RA_MAT MATRIC,                                                                            "
	cSql+= "        RA_NOME NOME,                                                                             "
	cSql+= "        RA_ADMISSA DT_ADMIS,                                                                      "
	cSql+= "        RJ_DESC,                                                                                  "
	cSql+= "        ISNULL((SELECT QB_YPCMSO                                                                  "
	cSql+= "                  FROM SQB010                                                                     "
	cSql+= "                 WHERE QB_FILIAL = '"+xFilial("SQB")+"'                                           "                                    
	cSql+= "                   AND QB_DEPTO = RA_DEPTO                                                        "
	cSql+= "                   AND D_E_L_E_T_ = ' '), 'NAO CLASSIFICADO') SETOR,                              "
	cSql+= "        RA_SALARIO,                                                                               "
	cSql+= "        ISNULL(Z28_EMAIL, '') EMAIL                                                               "
	cSql+= "                                                                                                  "
	cSql+= " FROM "+RetSqlName("SRA")+" SRA                                                                   "
	cSql+= " INNER JOIN "+RetSqlName("SRJ")+" SRJ ON RJ_FILIAL = '"+xFilial("SRJ")+"'                         "
	cSql+= "                       AND RJ_FUNCAO = RA_CODFUNC                                                 "
	cSql+= "                       AND SRJ.D_E_L_E_T_ = ' '                                                   "
	cSql+= " LEFT JOIN Z28010 Z ON RTRIM(Z28_ROTINA) = 'BIA288'                                               "
	cSql+= "				   AND RTRIM(Z28_CLASSE) = RA_CLVL                                                "
	cSql+= "				   AND Z.D_E_L_E_T_ = ' '                                                         "		 
	cSql+= " WHERE RA_FILIAL = '" +xFilial("SRA")+"'                                                          "
	cSql+= "   AND DATEDIFF(MONTH, CONVERT(DATETIME, RA_ADMISSA ), CONVERT(DATETIME,'"+fr_UltDia+"' )) IN (6,12)"
	cSql+= "   AND RA_SITFOLH <> 'D'                                                                            "
	cSql+= "   AND RA_CATFUNC = 'M'                                                                             "
	cSql+= "   AND RA_CATEG <> '07'                                                                             "
	cSql+= "   AND SRA.D_E_L_E_T_ = ' '                                                                         "
	cSql+= " ORDER BY EMAIL,PERIODO,NOME                                                                        "

Return cSql
