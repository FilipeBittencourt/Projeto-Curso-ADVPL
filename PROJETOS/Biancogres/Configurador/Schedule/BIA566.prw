#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

User Function BIA566()

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	Autor     := Luana Marin Ribeiro
	Programa  := BIA566
	Empresa   := Biancogres Cerâmica S/A
	Data      := 15/09/2015
	Uso       := Faturamento
	Aplicação := Relação de NFs que não fora emitidas nem inutilizadas
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	LOCAL     xv_Emps    := U_BAGtEmpr("01_05")
	Local i 

	ConOut("HORA: " + TIME() + " - Iniciando Processo BIA566 ")

	//Inicializa o ambiente
	RPCSetType(3)
	RPCSetEnv("01","01","","","","",{})	

	pw_ImpCabec 	:= .F.

	cSqlPrinc := "SELECT CNPJ, ID_ENT "
	cSqlPrinc += "FROM SPED001 "
	cSqlPrinc += "WHERE D_E_L_E_T_=' ' "

	TCQUERY cSqlPrinc New Alias "cSqlPrinc"
	dbSelectArea("cSqlPrinc")
	dbGoTop() 

	sVetErro		:= {} //identificar se a discrepancia é tal que houve erro na serie

	While cSqlPrinc->(!Eof())

		sVetNFE 		:= {}
		sNotaAnterior 	:= 0
		sSerieAnterior  := 0	
		sContadorNfe 	:= 0

		cSql := "SELECT NFE_ID "
		cSql += "FROM SPED050 "
		cSql += "WHERE ID_ENT = '" + cSqlPrinc->ID_ENT +"' "   //essa data abaixo retorna o primeiro dia do mês corrente - 2 dias, pra não ficar dois dias sempre sem contar
		cSql += "	AND DATE_NFE BETWEEN CONVERT(VARCHAR, DATEADD(DAY, -2, CONVERT(VARCHAR(04),DATEPART(YEAR,GETDATE())) + '-' + REPLACE(SPACE(2 - LEN(DATEPART(MONTH,GETDATE()))),' ', '0') + CONVERT(VARCHAR(02),DATEPART(MONTH,GETDATE())) + '-' + '01'), 112) "
		cSql += "						AND CONVERT(VARCHAR, DATEADD(DAY, -1, GETDATE()), 112) AND MODELO = '55' AND D_E_L_E_T_ = '' "
		cSql += "   AND STATUSCANC <> '3' "
		cSql += "ORDER BY NFE_ID "

		TCQUERY cSql New Alias "cSql"
		dbSelectArea("cSql")
		dbGoTop()

		While cSql->(!Eof())
			sSplit := StrTokArr(AllTrim(cSql->NFE_ID), " ")
			If sNotaAnterior == 0 //PRIMEIRA PASSAGEMM, AINDA NÃO TEM COMPARATIVO
				sSerieAnterior 	:= Val(sSplit[1])
				sNotaAnterior 	:= Val(sSplit[2])
			Else
				If sSerieAnterior == Val(sSplit[1])
					//VERIFICA A DIFERENÇA ENTRE UMA NOTA E OUTRA, PRA SABER QUANTAS NUMERAÇÕES FORAM PULADAS, CASO TENHAM SIDO PULADAS
					Dif := Val(sSplit[2]) - (sNotaAnterior + 1)

					If Dif > 0
						if Dif > 10000
							aadd(sVetErro, {"de " + PadR(sSerieAnterior, 3, ' ') + PadL(sNotaAnterior, 9, "0") + " para " + AllTrim(cSql->NFE_ID), cSqlPrinc->CNPJ })
						else
							For i := 1 To Dif
								//ASSUME O FORMATO DO CAMPO NFE_ID DA TABELA SPED050, PRA QUE SEJA PROCURADO NOVAMENTE, PARA TER CERTEZA QUE A NOTA REALMENTE NÃO EXISTE
								Auxiliar := AllTrim(Str(sSerieAnterior)) + Space(3 - Len(AllTrim(Str(sSerieAnterior)))) + Replace(Space(9 - Len(AllTrim(Str(sNotaAnterior))))," ","0") + AllTrim(Str(sNotaAnterior + i)) + Space(32)
								AAdd(sVetNFE, Auxiliar)
							Next
						endif
						
					EndIf
				Else  //ESTÁ PASSANDO PARA OUTRA SÉRIE
					sSerieAnterior 	:= Val(sSplit[1])
					sNotaAnterior 	:= Val(sSplit[2])
				EndIf
				//If sNotaAnterior + 1 <> Val(sSplit[2]) .And. sSerieAnterior == Val(sSplit[1])
				//	AAdd(sVetNFE, cSql->NFE_ID)
				//EndIf
				sSerieAnterior 	:= Val(sSplit[1])
				sNotaAnterior 	:= Val(sSplit[2])
			EndIf 

			dbSelectArea("cSql")
			dbSkip()
		End
		cSql->(dbCloseArea())


		For i := 1 To Len(sVetNFE)

			cSql := "SELECT NFE_ID "
			cSql += "FROM SPED050 "
			cSql += "WHERE ID_ENT = '" + cSqlPrinc->ID_ENT +"' AND NFE_ID = '" + sVetNFE[i] + "' AND D_E_L_E_T_ = '' "

			TCQUERY cSql New Alias "cSql"
			dbSelectArea("cSql")

			dbGoTop()

			If AllTrim(cSql->NFE_ID) == ""
				If !pw_ImpCabec
					pw_ImpCabec := .T.
					cHtmlBia566 := Imp_Cabec()
				EndIf

				cHtmlBia566 += '	<tr>
				cHtmlBia566 += '		<td><div align="left"><span class="style14">' + Alltrim(sVetNFE[i]) + '</span></div></td>
				cHtmlBia566 += '		<td><div align="left"><span class="style14">' + cSqlPrinc->CNPJ + '</span></div></td>
				cHtmlBia566 += '	</tr>
			EndIf

			cSql->(dbCloseArea())
		Next

		dbSelectArea("cSqlPrinc")
		dbSkip()
	End
	
	if (len(sVetErro) > 0)
		
		cHtmlBia566 += ' </table>
		cHtmlBia566 += '	<div align="left">&nbsp;</div> '
		cHtmlBia566 += '	<div align="left"><span class="style14"><strong>NFs que apresentaram numera&ccedil;&atilde;o MUITO fora da sequ&ecirc;ncia da s&eacute;rie, verifique:</strong></span></div> '
		cHtmlBia566 += '	<div align="left">&nbsp;</div> '
	
		cHtmlBia566 += '<table width="840" border="1" cellspacing="0" bordercolor="#666666">
		For i := 1 To Len(sVetErro)

			cHtmlBia566 += '	<tr>
			cHtmlBia566 += '		<td><div align="left"><span class="style14">' + Alltrim(sVetErro[i][1]) + '</span></div></td>
			cHtmlBia566 += '		<td><div align="left"><span class="style14">' + Alltrim(sVetErro[i][2]) + '</span></div></td>
			cHtmlBia566 += '	</tr>

		Next
	endif
	
	cSqlPrinc->(dbCloseArea())	

	If pw_ImpCabec
		Env_Mail()

		xCLVL   := ""
		df_Dest := U_EmailWF('BIA566', cEmpAnt , xCLVL )

		df_Assu := "Relação de NFs que não foram emitidas nem inutilizadas."
		df_Erro := "Relação de NFs que não foram emitidas nem inutilizadas. Favor verificar!!!"
		U_BIAEnvMail(, df_Dest, df_Assu, cHtmlBia566, df_Erro)
	EndIf

	ConOut("HORA: "+TIME()+" - Finalizando Processo BIA566 ")

	//Finaliza o ambiente criado
	RESET ENVIRONMENT 

Return

/*__________________________________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------------------------------------------------------------------+¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦¦Função    ¦ Imp_Cabec ¦ Autor     ¦ Luana Marin Ribeiro     ¦ Data     ¦ 16/09/2015     ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------------------------------------------------------------------+¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦¦          ¦ Imprimir Cabeçalho de Relação de NFs que não fora emitidas nem inutilizadas ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------------------------------------------------------------------+¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_Cabec()

	cHtmlBia566 := '<html xmlns="http://www.w3.org/1999/xhtml">
	cHtmlBia566 += '<head>
	cHtmlBia566 += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cHtmlBia566 += '<!-- TemplateBeginEditable name="doctitle" -->
	cHtmlBia566 += '<title>Untitled Document</title>
	cHtmlBia566 += '<style type="text/css">
	cHtmlBia566 += '<!--
	cHtmlBia566 += '.style1 {
	cHtmlBia566 += '	font-family: Geneva, Arial, Helvetica, sans-serif;
	cHtmlBia566 += '	font-weight: bold;
	cHtmlBia566 += '	color: #000066;
	cHtmlBia566 += '}
	cHtmlBia566 += '.style2 {color: #000066}
	cHtmlBia566 += '-->
	cHtmlBia566 += '</style>
	cHtmlBia566 += '</head>
	cHtmlBia566 += '<body>
	cHtmlBia566 += '<h3 class="style1">NOTAS FISCAIS</h3>
	cHtmlBia566 += '<table width="840" border="1" cellspacing="0" bordercolor="#666666">
	cHtmlBia566 += '    <tr>
	cHtmlBia566 += '        <td width="230" bgcolor="#99CCFF"><div align="left"><span class="style23">Série/NF</span></div></td>
	cHtmlBia566 += '        <td width="230" bgcolor="#99CCFF"><div align="left"><span class="style23">CNPJ Empresa</span></div></td>
	cHtmlBia566 += '    </tr>

	Return (cHtmlBia566)

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

	cHtmlBia566 += ' </table>
	cHtmlBia566 += ' <p>Favor verificar e efetuar os devidos ajustes, caso necessário.</p>
	cHtmlBia566 += ' <p>&nbsp;</p>
	cHtmlBia566 += ' <p>&nbsp;</p>
	cHtmlBia566 += ' <p>&nbsp;</p>
	cHtmlBia566 += ' <p>by Protheus (BIA566)</p>
	cHtmlBia566 += ' </body>
	cHtmlBia566 += ' </html>

	Return