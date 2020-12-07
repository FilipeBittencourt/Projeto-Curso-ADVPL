#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

//--------------------------------------------------------------------------------------------
//								*** WF DE MUDANÇA DE CONTRATO DE FUNCIONARIOS - RH ***
//--------------------------------------------------------------------------------------------
// Solcitante: Claudia
// Desenvolv.: Thiago Dantas
// Danta: 02/12/2014 
//--------------------------------------------------------------------------------------------
// O intuito do WF é enviar RH a alterações nos contratos dos funcioários.
//--------------------------------------------------------------------------------------------
User Function BIA227()

	Local nI
	Private cMensagem  := ''
	Private lOK        := .F.
	Private lSexta     := .F.
	Private lErro      := .F.
	Private cERRO      := ''
	Private cMensag    := ''
	Private cMens      := ''
	Private nItemPrd   := 0
	Private cEmail     := ''
	Private Enter      := CHR(13)+CHR(10)

	xv_Emps    := U_BAGtEmpr("01_05_13_14")

	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
		//Gera o html do WF.
		Processa({|| GeraWF()})

		RpcClearEnv()
	Next nI

Return .T.
//---------------------------------------(GeraWF)----------------------------------
Static Function GeraWF()

	Private C_HTML		:= ''

	cQry := GeraSql()

	If chkfile("QRY")
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf
	TCQUERY cQry ALIAS "QRY" NEW

	DbSelectArea("QRY")
	DbGotop()

	Setprc(0,0)
	GeraHTML()

	DbSelectArea("QRY")
	If eof()
		DbCloseArea()
	EndIf

Return
//---------------------------------------(GeraHTML)----------------------------------
Static Function GeraHTML()
	Private cAuxSit := ""
	//caracter de salto de linha
	cCrLf := Chr(13) + Chr(10)

	GeraCab()

	If !Eof()

		While !EOF()

			cAuxSit := QRY->SITUACAO 
			GeraCabCls()
			nItemPrd := 0

			While cAuxSit == QRY->SITUACAO .And. !EOF()

				nItemPrd += 1
				GeraItmTb()
				DbSelectArea("QRY")
				DbSkip()

			End

			DbSelectArea("QRY")

			if Eof()
				GeraFtrFim()
			Else
				GeraFooter()
			EndIf

			DbSelectArea("QRY")
		END

		Enviar()

	EndIf

Return
//---------------------------------------(Enviar)----------------------------------
Static Function Enviar()

	ldebug := .F.

	if ldebug                                              
		Envioemail("luana.ribeiro@biancogres.com.br")
	else
		cDest := U_EmailWF('BIA227',cEmpAnt)
		Envioemail(cDest)
	EndIf

	cMensag  := ''
	cMens    := ''
	nItemPrd := 0

Return
//---------------------------------------(Envioemail)----------------------------------
Static Function Envioemail(cEmail)
	  					  		
	cRecebe   	:= cEmail														 		
	cRecebeCC	:= ""  												 			
	cRecebeCO	:= ""			  								 					
	cAssunto	:= 'Relação de admissão, demissão e promoção'

	cMensag := ""
	cMensag += C_HTML
	cArqAnexo := ''

	U_BIAEnvMail(,cRecebe,cAssunto,cMensag,'',cArqAnexo,,cRecebeCC)       

Return
//---------------------------------------(GeraCab)----------------------------------
Static Function GeraCab()

	C_HTML := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
	C_HTML += '   <html xmlns="http://www.w3.org/1999/xhtml">
	C_HTML += '      <head>
	C_HTML += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	C_HTML += '         <title>Producao</title>
	C_HTML += '         <style type="text/css">
	C_HTML += '			<!--
	C_HTML += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
	C_HTML += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
	C_HTML += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
	C_HTML += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
	C_HTML += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
	C_HTML += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
	C_HTML += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif } 			
	C_HTML += '			--> 
	C_HTML += '         </style>
	C_HTML += '      </head>
	C_HTML += '      <body>

	C_HTML += '         <table align="center" width="800" class = "headProd">
	C_HTML += '               <tr>
	C_HTML += '                  <div align="left">
	C_HTML += "                  <th width='694' scope='col'> "+Upper(AllTrim(SM0->M0_NOMECOM))+" </th>
	C_HTML += '					 </div>
	C_HTML += '               </tr>
	C_HTML += '         </table>


	Return
	//---------------------------------------(GeraCabCls)----------------------------------
	Static Function GeraCabCls()
	C_HTML += '         <table align="center" width="800" class = "headProd">
	C_HTML += '               <tr>
	C_HTML += '                  <div align="left">
	C_HTML += "                  <th width='694' scope='col'> "+ALLTRIM(QRY->SITUACAO)+" </th>
	C_HTML += '					 </div>
	C_HTML += '               </tr>
	C_HTML += '         </table>
	C_HTML += '         <table align="center" width="800" border="1" cellspacing="0" cellpadding="1">
	C_HTML += '            <tr align=center>
	C_HTML += '               <th class = "cabtab" width="10" scope="col"> MATRICULA </span></th>
	C_HTML += '               <th class = "cabtab" width="100" scope="col"> NOME </span></th>
	C_HTML += '               <th class = "cabtab" width="30" scope="col"> NASCIMENTO </span></th>
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> CARGO </span></th>

	If ALLTRIM(QRY->SITUACAO) != 'ADMITIDO'
	C_HTML += '               <th class = "cabtab" width="30" scope="col"> ADMISSAO </span></th>
	EndIf

	C_HTML += '               <th class = "cabtab" width="30" scope="col"> '+ALLTRIM(QRY->SITUACAO)+' </span></th>
	C_HTML += '               <th class = "cabtab" width="60" scope="col"> TRANSF. </span></th>
	C_HTML += '            </tr>

	Return
	//---------------------------------------(GeraItmTb)----------------------------------
	Static Function GeraItmTb()

	C_HTML += " 			<tr align=center>
	C_HTML += "                   <td class='style12' width='10'scope='col'>" +ALLTRIM(QRY->RA_MAT)			+"</td>
	C_HTML += "                   <td class='style12' width='100'scope='col'>"+ALLTRIM(QRY->RA_NOME)		+"</td>
	C_HTML += "                   <td class='style12' width='30'scope='col'>" +DToC(SToD(QRY->RA_NASC))		+"</td>
	C_HTML += "                   <td class='style12' width='60'scope='col'>" +ALLTRIM(QRY->CARGO)			+"</td>

	If ALLTRIM(QRY->SITUACAO) != 'ADMITIDO'
	C_HTML += "                   <td class='style12' width='30'scope='col'>" +DToC(SToD(QRY->RA_ADMISSA))	+"</td>
	EndIf

	C_HTML += "                   <td class='style12' width='30'scope='col'>" +DToC(SToD(QRY->DATA))		+"</td>
	C_HTML += "                   <td class='style12' width='60'scope='col'>" +ALLTRIM(QRY->TRANSF)			+"</td>
	C_HTML += "             </tr>

	Return
	//---------------------------------------(GeraFooter)----------------------------------
	Static Function GeraFooter()

	C_HTML +=" </table> "
	C_HTML +="	<div id='psdg-footer'> &nbsp </div>"

	Return

	//---------------------------------------(GeraFtrFim)----------------------------------
	Static Function GeraFtrFim()
	C_HTML += "     </table>
	C_HTML += "		<table align='center' width='800' border='1' cellspacing='0' cellpadding='1'>
	C_HTML += "            <tr>
	C_HTML += "               <th class = 'tottab' width='600' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (by BIA227).</th>
	C_HTML += "			</tr>  
	C_HTML += "		</table>
	C_HTML += "      </body>
	C_HTML += "   </html>

	Return
	//---------------------------------------(GeraSql)--------------------------------------
	Static Function GeraSql()

	Local cSql := ""

	// A rotina está programada para rodar todo o dia primeiro.
	// Data atual - 15 dias -> metade de um mes normal. Caso seja Fevereiro a regra será atendida.

	cSql += "SELECT RA_MAT" + Enter
	cSql += "	, RA_NOME" + Enter
	cSql += "	, RA_NASC" + Enter
	cSql += "	, CASE WHEN RA_DEMISSA <> '' THEN 'DEMITIDO' ELSE 'ADMITIDO' END SITUACAO" + Enter
	cSql += "	, SRJ.RJ_DESC  AS CARGO" + Enter
	cSql += "	, RA_ADMISSA" + Enter
	cSql += "	, CASE WHEN RA_DEMISSA != '' THEN RA_DEMISSA ELSE RA_ADMISSA END DATA" + Enter
	cSql += "	, (CASE WHEN (ISNULL((SELECT TOP 1 (CASE WHEN SRA2.RA_MAT IS NULL THEN 'NAO' ELSE 'SIM' END) FROM " + RetSqlName("SRA") + " SRA2" + Enter
	cSql += "			WHERE SRA2.RA_FILIAL = '" + xFilial("SRA") + "' SRA.RA_CIC = SRA2.RA_CIC AND SRA.RA_MAT <> SRA2.RA_MAT AND SRA2.RA_SITFOLH <> 'D' AND SRA2.D_E_L_E_T_ = '' ORDER BY SRA2.RA_ADMISSA DESC),'NAO')='SIM')" + Enter 
	cSql += "		OR (ISNULL((SELECT (CASE WHEN SRE.RE_MATP IS NULL THEN 'NAO' ELSE 'SIM' END)" + Enter
	cSql += "			FROM " + RetSqlName("SRE") + " SRE" + Enter
	cSql += "			WHERE SRE.RE_FILIAL='" + xFilial("SRE") + "'" + Enter
	cSql += "				AND (CASE WHEN SRA.RA_DEMISSA <> '' THEN SRE.RE_MATD ELSE SRE.RE_MATP END)=SRA.RA_MAT" + Enter
	cSql += "				AND (CASE WHEN SRA.RA_DEMISSA <> '' THEN SRE.RE_EMPD ELSE SRE.RE_EMPP END)='" + cEmpAnt + "'" + Enter
	cSql += "				AND SRE.RE_MATD<>SRE.RE_MATP" + Enter
	cSql += "				AND SRE.RE_EMPD<>SRE.RE_EMPP" + Enter
	cSql += "				AND SRE.D_E_L_E_T_ = ''),'NAO') = 'SIM') THEN" + Enter
	cSql += "			'SIM'" + Enter
	cSql += "		ELSE" + Enter
	cSql += "			'NAO'" + Enter
	cSql += "		END) AS TRANSF" + Enter
	cSql += "FROM " + RetSqlName("SRA") + " SRA" + Enter
	cSql += "	INNER JOIN " + RetSqlName("SRJ") + " SRJ ON RA_CODFUNC = RJ_FUNCAO" + Enter
	cSql += "		AND SRJ.D_E_L_E_T_ = ''" + Enter
	cSql += "WHERE ((DATEPART(M, CONVERT(DATETIME, RA_DEMISSA)) = DATEPART(M, GETDATE()-15) AND DATEPART(YEAR, CONVERT(DATETIME, RA_DEMISSA)) = DATEPART(YEAR, GETDATE()-15))" + Enter
	cSql += "		OR (DATEPART(M, CONVERT(DATETIME, RA_ADMISSA)) = DATEPART(M, GETDATE()-15) AND DATEPART(YEAR, CONVERT(DATETIME, RA_ADMISSA)) = DATEPART(YEAR, GETDATE()-15)))" + Enter
	cSql += "	AND SRA.RA_CODFUNC NOT IN('9999','9998')" + Enter
	cSql += "	AND RA_SITFOLH <> 'T'" + Enter
	cSql += "	AND SRA.D_E_L_E_T_ = ''" + Enter
	cSql += "UNION" + Enter
	cSql += "SELECT RA_MAT" + Enter
	cSql += "	, RA_NOME" + Enter
	cSql += "	, RA_NASC" + Enter
	cSql += "	,'PROMOVIDO' AS SITUACAO" + Enter
	cSql += "	, SR7.R7_DESCFUN AS CARGO" + Enter
	cSql += "	, RA_ADMISSA" + Enter
	cSql += "	, R7_DATA AS DATA" + Enter
	cSql += "	, 'NAO' AS TRANSF" + Enter
	cSql += "FROM " + RetSqlName("SR7") + " SR7" + Enter
	cSql += "	INNER JOIN " + RetSqlName("SRA") + " SRA ON SR7.R7_MAT = SRA.RA_MAT AND SR7.D_E_L_E_T_ = ''" + Enter
	cSql += "WHERE R7_TIPO = '006'" + Enter
	cSql += "	AND (DATEPART(M, CONVERT(DATETIME, R7_DATA)) = DATEPART(M, GETDATE()-15)" + Enter
	cSql += "	AND DATEPART(YEAR, CONVERT(DATETIME, R7_DATA)) = DATEPART(YEAR, GETDATE()-15))" + Enter
	cSql += "	AND SRA.RA_CODFUNC NOT IN('9999','9998')" + Enter
	cSql += "	AND SR7.D_E_L_E_T_ = ''" + Enter
	cSql += "ORDER BY SITUACAO, DATA, RA_NOME" + Enter

	Return cSql