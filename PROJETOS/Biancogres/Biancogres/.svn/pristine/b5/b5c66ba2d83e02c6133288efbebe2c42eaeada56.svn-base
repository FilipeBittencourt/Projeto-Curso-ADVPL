#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

User Function BIA560()

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	Autor     := Luana Marin Ribeiro
	Programa  := BIA560
	Empresa   := Biancogres Cerâmica S/A
	Data      := 05/08/2015
	Uso       := Gestão de Pessoal
	Aplicação := Relação de funcionários ativos das funções 0690, 0691, 0692, 0772, 0771 e que não estão cadastrados na tabela de rateio (BIA193) com data de validade
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	LOCAL     xv_Emps    := U_BAGtEmpr("01")
	Local x
	Local nomeEmp := ""

	For x := 1 to Len(xv_Emps)

		//Inicializa o ambiente
		RPCSetType(3)
		RPCSetEnv(xv_Emps[x,1],xv_Emps[x,2],"","","","",{})

		ConOut("HORA: " + TIME() + " - Iniciando Processo BIA560 " + xv_Emps[x,1])

		pw_ImpCabec := .F.
		pw_DtRef    := dDataBase-1

		//stod    : string para data
		//dtos    : data para string
		//dtoc	  : data para caracter (usado para a impressão da data)

		nomeEmp := FWEmpName(cEmpAnt)

		cSql := " SELECT DISTINCT SRA.RA_MAT, SRA.RA_NOME, SRA.RA_ADMISSA, SRA.CODEMP AS EMPRESA, SRA.RA_CLVL "+CRLF
		cSql += " FROM VW_SENIOR_SRA SRA "+CRLF
		cSql += " WHERE SRA.RA_CLVL in ('2115','2155','2255','2155','2116','2156') "+CRLF
		cSql += " AND SRA.RA_DEMISSA = ' ' "+CRLF
		cSql += "	AND (SRA.RA_MAT NOT IN (SELECT Z31.Z31_CODFUN FROM " + RetSqlName("Z31") + " Z31 WHERE Z31.Z31_FILIAL = '" + xFilial("Z31") + "' "+CRLF
		cSql += "								AND Z31.D_E_L_E_T_ = ' ') "+CRLF
		cSql += "		OR SRA.RA_MAT IN (SELECT Z31.Z31_CODFUN FROM " + RetSqlName("Z31") + " Z31 WHERE Z31.Z31_FILIAL = '" + xFilial("Z31") + "' "+CRLF
		cSql += "								AND Z31.Z31_CODFUN = SRA.RA_MAT "+CRLF
		cSql += "								AND CONVERT(VARCHAR,GETDATE(),112) < Z31.Z31_DTINIC "+CRLF
		cSql += "								AND CONVERT(VARCHAR,GETDATE(),112) > Z31.Z31_DTFIM "+CRLF
		cSql += "								AND Z31.D_E_L_E_T_ = ' ')) "+CRLF
		
		TCQUERY cSql New Alias "cSql"
		dbSelectArea("cSql")
		dbGoTop()

		While !Eof()

			If !pw_ImpCabec
				pw_ImpCabec := .T.
				cHtmlBia560 := Imp_Cabec()
			EndIf

			cHtmlBia560 += '	<tr> '
			cHtmlBia560 += '		<td><div align="left"><span class="style14">' + Alltrim(cSql->RA_MAT) + '</span></div></td> '
			cHtmlBia560 += '		<td><div align="left"><span class="style14">' + Alltrim(cSql->RA_NOME) + '</span></div></td> '
			cHtmlBia560 += '		<td><div align="left"><span class="style14">' + dtoc(stod(cSql->RA_ADMISSA)) + '</span></div></td> '
			cHtmlBia560 += '		<td><div align="left"><span class="style14">' + Alltrim(nomeEmp) + '</span></div></td> '
			cHtmlBia560 += '		<td><div align="left"><span class="style14">' + Alltrim(cSql->RA_CLVL) + '</span></div></td> '
			cHtmlBia560 += '	</tr> '

			dbSelectArea("cSql")
			dbSkip()
		End
		cSql->(dbCloseArea())

		If pw_ImpCabec
			Env_Mail()

			xCLVL   := ""
			df_Dest := U_EmailWF('BIA560', cEmpAnt , xCLVL )

			df_Assu := "Promotores sem cadastro para rateio"
			df_Erro := "Promotores sem cadastro para rateio. Favor verificar!!!"
			U_BIAEnvMail(, df_Dest, df_Assu, cHtmlBia560, df_Erro)
		EndIf

		ConOut("HORA: "+TIME()+" - Finalizando Processo BIA560 " + xv_Emps[x,1])

		//Finaliza o ambiente criado
		RESET ENVIRONMENT

	Next x

Return

/*__________________________________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦¦Função    ¦ Imp_Cabec ¦ Autor ¦ Luana Marin Ribeiro     ¦ Data ¦ 05/08/2015 ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦¦          ¦ Imprimir Cabeçalho de funcionários showroom que não tenham rateio cadastrado com data de validade ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_Cabec()

	cHtmlBia560 := '<html xmlns="http://www.w3.org/1999/xhtml">  '
	cHtmlBia560 += '<head> '
	cHtmlBia560 += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	cHtmlBia560 += '<!-- TemplateBeginEditable name="doctitle" --> '
	cHtmlBia560 += '<title>Untitled Document</title> '
	cHtmlBia560 += '<style type="text/css"> '
	cHtmlBia560 += '<!-- '
	cHtmlBia560 += '.style1 { '
	cHtmlBia560 += '	font-family: Geneva, Arial, Helvetica, sans-serif; '
	cHtmlBia560 += '	font-weight: bold; '
	cHtmlBia560 += '	color: #000066; '
	cHtmlBia560 += '} '
	cHtmlBia560 += '.style2 {color: #000066} '
	cHtmlBia560 += '--> '
	cHtmlBia560 += '</style> '
	cHtmlBia560 += '</head> '
	cHtmlBia560 += '<body> '
	cHtmlBia560 += '<h3 class="style1">PROMOTORES SEM CADASTRO PARA RATEIO</h3> '
	cHtmlBia560 += '<table width="840" border="1" cellspacing="0" bordercolor="#666666"> '
	cHtmlBia560 += '    <tr> '
	cHtmlBia560 += '        <td width="230" bgcolor="#99CCFF"><div align="left"><span class="style23">MATRÍCULA</span></div></td> '
	cHtmlBia560 += '        <td width="600" bgcolor="#99CCFF"><div align="left"><span class="style23">NOME</span></div></td> '
	cHtmlBia560 += '        <td width="230" bgcolor="#99CCFF"><div align="left"><span class="style23">ADMISSÃO</span></div></td> '
	cHtmlBia560 += '        <td width="230" bgcolor="#99CCFF"><div align="left"><span class="style23">EMPRESA</span></div></td> '
	cHtmlBia560 += '        <td width="230" bgcolor="#99CCFF"><div align="left"><span class="style23">CLASSE VALOR</span></div></td> '
	cHtmlBia560 += '    </tr> '

Return (cHtmlBia560)

/*____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Env_Mail  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 05/08/2015 ¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprime rodapé do relatório                                  ¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Env_Mail()

	cHtmlBia560 += ' </table> '
	cHtmlBia560 += ' <p>Favor verificar e efetuar os devidos ajustes, caso necessário.</p> '
	cHtmlBia560 += ' <p>&nbsp;</p> '
	cHtmlBia560 += ' <p>&nbsp;</p> '
	cHtmlBia560 += ' <p>&nbsp;</p> '
	cHtmlBia560 += ' <p>by Protheus (BIA560)</p> '
	cHtmlBia560 += ' </body> '
	cHtmlBia560 += ' </html> '

Return

//Função criada para ser chamada pelo menu do Protheus e testar o código. 
/* Para Executar em DEBUG:
Se quiser debugar o codigo BIA560: 
1. vá no menu Depurar Debug
2. Depurar Configurations... 
3. em (-P) Função Principal deixe vazio, clique em Aplicar.
4. Execute o debug
5. Na tela que aparecer, em (-P) Função Principal digite U_BIA560 e clique OK.
*/
User Function BA560JOB()

	cEmpAnt := "01"
	cFilAnt := "01"
	STARTJOB("U_BIA560",GetEnvServer(),.F.,cEmpAnt,cFilAnt)

Return
