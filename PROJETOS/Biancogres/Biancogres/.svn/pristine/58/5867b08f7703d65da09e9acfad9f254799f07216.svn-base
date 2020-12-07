#Include "Protheus.ch"
#include "topconn.ch"

User Function BIA285()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA285
Empresa   := Biancogres Cerâmica S/A
Data      := 28/02/12
Uso       := Ponto Eletrônico
Aplicação := Envio de e-mail contendo Resumo Gerencial de horas extras
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Private xPrimeiro
Private xEnviaM
Private WF001

cHInicio := Time()
fPerg := "BIA285"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

A0007 := " SELECT RA_NOME,
A0007 += "        RA_YSEMAIL,
A0007 += "        RA_EMAIL,
A0007 += "        RA_YSUPEML,
A0007 += "        RA_HRSMES,
A0007 += "        RA_SALARIO,
A0007 += "        CASE
A0007 += "          WHEN RA_PERICUL <> 0 THEN 1
A0007 += "          ELSE 0
A0007 += "        END PERICUL,
A0007 += "        CASE
A0007 += "          WHEN RA_INSMED <> 0 THEN 1
A0007 += "          ELSE 0
A0007 += "        END INSMED,
A0007 += "        CASE
A0007 += "          WHEN RA_INSMAX <> 0 THEN 1
A0007 += "          ELSE 0
A0007 += "        END INSMAX,
A0007 += "        DADOS.*,
A0007 += "        CONVERT(NUMERIC, RX_TXT, 2) MINIMO
A0007 += "   FROM (SELECT MATRIC,
A0007 += "                VERBA,
A0007 += "                DTREF,
A0007 += "                SUM(HORAS) HORAS
A0007 += "           FROM (SELECT PB_MAT MATRIC,
A0007 += "                        PB_PD VERBA,
A0007 += "                        SUBSTRING(PB_DATA,1,6) DTREF,
A0007 += "                        PB_HORAS HORAS
A0007 += "                   FROM "+RetSqlname("SPB")
A0007 += "                  WHERE PB_FILIAL = '"+xFilial("SPB")+"'
A0007 += "                    AND PB_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
A0007 += "                    AND PB_MAT BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
A0007 += "                    AND D_E_L_E_T_ = ' '
A0007 += "                 UNION ALL
A0007 += "                 SELECT PL_MAT MATRIC,
A0007 += "                        PL_PD VERBA,
A0007 += "                        SUBSTRING(PL_DATA,1,6) DTREF,
A0007 += "                        PL_HORAS HORAS
A0007 += "                   FROM "+RetSqlname("SPL")
A0007 += "                  WHERE PL_FILIAL = '"+xFilial("SPL")+"'
A0007 += "                    AND PL_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
A0007 += "                    AND PL_MAT BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
A0007 += "                    AND D_E_L_E_T_ = ' ') AS RESULT
A0007 += "          GROUP BY MATRIC,
A0007 += "                   DTREF,
A0007 += "                   VERBA) AS DADOS
A0007 += "  INNER JOIN "+RetSqlname("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
A0007 += "                       AND RA_MAT = MATRIC
A0007 += "                       AND RA_SITFOLH <> 'D'
A0007 += "                       AND SRA.D_E_L_E_T_ = ' '
A0007 += "   LEFT JOIN "+RetSqlname("SRX")+" SRX ON RX_FILIAL = '"+xFilial("SRX")+"'
A0007 += "                       AND RX_TIP = '11'
A0007 += "                       AND (RX_COD = DTREF OR RX_COD = '      ')
A0007 += "                       AND SRX.D_E_L_E_T_ = ' '
A0007 += "  ORDER BY RA_YSEMAIL, RA_NOME, VERBA
TCQUERY A0007 New Alias "A007"
dbSelectArea("A007")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	Imp_Cabec()
	Imp_Setor()
	xEnviaM := .F.
	
	xEmailRf := A007->RA_YSEMAIL
	xPrimeiro := .T.
	ttHr50h  := 0
	ttHr50v  := 0
	ttHr100h := 0
	ttHr100v := 0
	While !Eof() .and. A007->RA_YSEMAIL == xEmailRf
		
		xMatRf  := A007->MATRIC
		xNomRef := A007->RA_NOME
		xHr50h  := 0
		xHr50v  := 0
		xHr100h := 0
		xHr100v := 0
		xVlrBas := A007->RA_SALARIO + IIF(A007->PERICUL == 1, A007->RA_SALARIO*30/100, 0) + IIF(A007->INSMED == 1, A007->MINIMO*20/100, 0) + IIF(A007->INSMAX == 1, A007->MINIMO*40/100, 0)
		xVlrBas := xVlrBas/A007->RA_HRSMES
		While !Eof() .and. A007->RA_YSEMAIL == xEmailRf .and. A007->RA_NOME == xNomRef
			
			IncProc()
			
			If Alltrim(A007->VERBA) $ Alltrim(MV_PAR05) // Horas Extras 50%
				xEnviaM := .T.
				xHr50h += A007->HORAS
				xHr50v += xVlrBas * A007->HORAS * 1.5
				ttHr50h  += A007->HORAS
				ttHr50v  += xVlrBas * A007->HORAS * 1.5
			EndIf
			If Alltrim(A007->VERBA) $ Alltrim(MV_PAR06) // Horas Extras 100%
				xEnviaM := .T.
				xHr100h += A007->HORAS
				xHr100v += xVlrBas * A007->HORAS * 2
				ttHr100h += A007->HORAS
				ttHr100v += xVlrBas * A007->HORAS * 2
			EndIf
			dbSelectArea("A007")
			dbSkip()
		End
		f285ImprL()
		
	End
	Imp_FimFn()
	Imp_Rodap()
	
	If xEnviaM
		
		df_Dest := U_EmailWF('BIA285',cEmpAnt)
		/*
		If cEmpAnt == "01"
			df_Dest := "francine.araujo@biancogres.com.br"
		Else
			df_Dest := "jeane.carvalho@biancogres.com.br"
		EndIf
		*/
		df_Assu := "Resumo Gerencial de Horas Extras   " + Alltrim(xEmailRf)
		df_Erro := "Resumo Gerencial de Horas Extras não enviado. Favor verificar!!!"
		U_BIAEnvMail(, df_Dest, df_Assu, WF001, df_Erro)
	EndIf
	
End

A007->(dbCloseArea())

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Imp_Cabec ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 28/02/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Cabeçalho de Horas Extras                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_Cabec()

WF001 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
WF001 += ' <html xmlns="http://www.w3.org/1999/xhtml">
WF001 += ' <head>
//WF001 += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
WF001 += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
WF001 += ' <title>Untitled Document</title>
WF001 += ' <style type="text/css">
WF001 += ' <!--
WF001 += ' .style37 {font-family: Arial, Helvetica, sans-serif; font-size: 18px; font-weight: bold; }
WF001 += ' .style39 {font-family: Arial, Helvetica, sans-serif; font-size: 9px; }
WF001 += ' .style42 {font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }
WF001 += ' .style48 {font-family: Arial, Helvetica, sans-serif; font-size: 12px; color: #FFFFFF; }
WF001 += ' .style49 {font-family: Arial, Helvetica, sans-serif; font-size: 12px; }
WF001 += ' .style60 {font-family: Arial, Helvetica, sans-serif; font-size: 16px; }
WF001 += ' .style61 {font-family: Arial, Helvetica, sans-serif; font-size: 14px; }
WF001 += ' -->
WF001 += ' </style>
WF001 += ' </head>
WF001 += ' <body>
WF001 += ' <table width="781" border="1" bordercolor="#000000">
WF001 += '   <tr>
WF001 += '     <td width="596" height="56" colspan="3"><div align="center" class="style37">AUTORIZAÇÃO DE HORAS-EXTRAS EVENTUAIS</div></td>
WF001 += '     <td width="169" rowspan="2"><div align="center" class="style37">UN-FO-SPE-10</div></td>
WF001 += '   </tr>
WF001 += '   <tr>
WF001 += '     <td height="21"><div align="center" class="style39">Revisão anterior: 26/01/12</div></td>
WF001 += '     <td><div align="center" class="style39">Revisão atual: 26/01/12</div></td>
WF001 += '     <td><div align="center" class="style39">Nº Revisão: 00</div></td>
WF001 += '   </tr>
WF001 += ' </table>
WF001 += ' <table width="200" border="0">
WF001 += '   <tr>
WF001 += '     <td>&nbsp;</td>
WF001 += '   </tr>
WF001 += ' </table>

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Imp_Setor ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 28/02/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Setor e Periodo de Horas Extras                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_Setor()

WF001 += ' <table width="781" border="1" bordercolor="#000000">
WF001 += '   <tr>
WF001 += '     <td width="171"><div align="center" class="style42">Período</div></td>
WF001 += '     <td width="244"><div align="center" class="style42">Setor</div></td>
WF001 += '     <td width="344"><div align="center" class="style42">Empresa</div></td>
WF001 += '   </tr>
WF001 += '   <tr>
WF001 += '     <td><div align="center" class="style49"> DE '+dtoc(MV_PAR01)+' ATÉ '+dtoc(MV_PAR02)+'</div></td>
WF001 += '     <td><div align="center" class="style49">A definir</div></td>
WF001 += '     <td><div align="center" class="style49">'+Alltrim(SM0->M0_NOMECOM)+'</div></td>
WF001 += '   </tr>
WF001 += ' </table>
WF001 += ' <table width="200" border="0">
WF001 += '   <tr>
WF001 += '     <td height="23">&nbsp;</td>
WF001 += '   </tr>
WF001 += ' </table>

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ f284ImprL ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 28/02/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir detalhes de Horas Extras                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function f285ImprL(cString)

If xPrimeiro
	xPrimeiro := .F.
	WF001 += ' <table width="781" border="1" bordercolor="#000000">
	WF001 += '   <tr>
	WF001 += '     <td width="459" rowspan="2" bgcolor="#0000FF"><div align="left" class="style48">Nome</div></td>
	//WF001 += '     <td width="197" rowspan="2" bgcolor="#0000FF"><div align="left" class="style48">Nome</div></td>
	//WF001 += '     <td width="155" rowspan="2" bgcolor="#0000FF"><div align="left" class="style48">Descrição do Serviço</div></td>
	//WF001 += '     <td width="107" rowspan="2" bgcolor="#0000FF"><div align="center" class="style48">Assinatura</div></td>
	WF001 += '     <td height="20" colspan="4" bgcolor="#0000FF"><div align="center" class="style48">Horas Eventuais</div></td>
	WF001 += '   </tr>
	WF001 += '   <tr>
	WF001 += '     <td width="69" height="19" bgcolor="#0000FF"><div align="right" class="style48">50%</div></td>
	WF001 += '     <td width="69" bgcolor="#0000FF"><div align="right" class="style48">R$ Aprox.</div></td>
	WF001 += '     <td width="69" bgcolor="#0000FF"><div align="right" class="style48">100%</div></td>
	WF001 += '     <td width="69" bgcolor="#0000FF"><div align="right" class="style48">R$ Aprox.</div></td>
	WF001 += '   </tr>
EndIf
If xHr50h <> 0 .or. xHr100h <> 0
	WF001 += '  <tr>
	WF001 += '    <td><div align="left" class="style49">'+xNomRef+'</div></td>
	//WF001 += '    <td><div align="left" class="style48">.</div></td>
	//WF001 += '    <td><div align="center" class="style48">.</div></td>
	WF001 += '    <td><div align="right" class="style49">'+Transform(xHr50h,  "@E 99999.99")+'</div></td>
	WF001 += '    <td><div align="right" class="style49">'+Transform(xHr50v,  "@E 99999.99")+'</div></td>
	WF001 += '    <td><div align="right" class="style49">'+Transform(xHr100h, "@E 99999.99")+'</div></td>
	WF001 += '    <td><div align="right" class="style49">'+Transform(xHr100v, "@E 99999.99")+'</div></td>
	WF001 += '  </tr>
EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Imp_FimFn ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 28/02/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Finalizição da Tabela dos dados do Funcionário    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_FimFn()

If !xPrimeiro
	WF001 += ' </table>
	WF001 += ' <table width="781" border="1">
	WF001 += '   <tr>
	WF001 += '     <td width="226" rowspan="2">&nbsp;</td>
	WF001 += '     <td width="239" rowspan="2">&nbsp;</td>
	WF001 += '     <td width="69" bordercolor="#333333"><div align="right" class="style49">'+Transform(ttHr50h,  "@E 99999.99")+'</div></td>
	WF001 += '     <td width="69" bordercolor="#333333"><div align="right" class="style49">'+Transform(ttHr50v,  "@E 99999.99")+'</div></td>
	WF001 += '     <td width="69" bordercolor="#333333"><div align="right" class="style49">'+Transform(ttHr100h, "@E 99999.99")+'</div></td>
	WF001 += '     <td width="69" bordercolor="#333333"><div align="right" class="style49">'+Transform(ttHr100v, "@E 99999.99")+'</div></td>
	WF001 += '   </tr>
	WF001 += '   <tr>
	WF001 += '     <td colspan="4" bordercolor="#333333"><div align="center" class="style49">'+Transform(ttHr50h+ttHr100h, "@E 99999.99")+'</div></td>
	WF001 += '   </tr>
	WF001 += '   <tr>
	WF001 += '     <td width="226"><div align="center"><span class="style60">_____/_____/_______</span></div></td>
	WF001 += '     <td><div align="center" class="style61">Assinatura Gerência/Diretoria</div></td>
	WF001 += '     <td colspan="4" bordercolor="#333333"><div align="center" class="style49">'+Transform(ttHr50v+ttHr100v, "@E 99999.99")+'</div></td>
	WF001 += '   </tr>
	WF001 += ' </table>
	WF001 += ' <p>&nbsp;</p>
EndIf

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

WF001 += ' <p class="style61">Sem mais para o momento,</p>
WF001 += ' <p class="style61">&nbsp;</p>
WF001 += ' <p class="style61">Departamento Pessoal.</p>
WF001 += ' </body>
WF001 += ' </html>

Return

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
aAdd(aRegs,{cPerg,"01","De Data (Período)   ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Data (Período)  ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","De Matricula        ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"04","Ate Matricula       ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"05","Verbas p/ H.E. 50%  ?","","","mv_ch5","C",40,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Verbas p/ H.E. 100% ?","","","mv_ch6","C",40,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
