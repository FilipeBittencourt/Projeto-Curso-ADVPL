#include "rwmake.ch"
#Include "Protheus.ch"
#include "topconn.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "tbiconn.ch"
#INCLUDE "DIRECTRY.CH"

User Function BIA714()

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	Autor     := Marcos Alberto Soprani
	Programa  := BIA714
	Empresa   := Biancogres Ceramica S.A.
	Data      := 16/04/13
	Uso       := Contábil / Fiscal
	Aplicação := Envio automático de e-mail para informa à Contabilidade/Fiscal
	.            que o status da nota fiscal junto a receita não está preenchido
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	Local xv_Emps
	Local x
	xv_Emps    := U_BAGtEmpr("01_05_07_12_13_14")

	For x := 1 to Len(xv_Emps)

	//Inicializa o ambiente
	RPCSetType(3)
	RPCSetEnv(xv_Emps[x,1],xv_Emps[x,2],"","","","",{})

	ConOut("Data" + dtoc(dDataBase) + " HORA: " + TIME() + " - Iniciando Processo BIA714 - Empresa " + xv_Emps[x,1] + " Filial " + xv_Emps[x,2] )

	cfEnvMl := .F.
	WF003 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	WF003 += ' <html xmlns="http://www.w3.org/1999/xhtml">
	WF003 += ' <head>
	WF003 += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	WF003 += ' <title>Untitled Document</title>
	WF003 += ' <style type="text/css">
	WF003 += ' <!--
	WF003 += ' .style1 {color: #FFFFFF}
	WF003 += ' -->
	WF003 += ' </style>
	WF003 += ' </head>
	WF003 += ' <body>
	WF003 += ' <p>Senhores,</p>
	WF003 += ' <p>&nbsp;</p>
	WF003 += ' <p><strong>Referente empresa: '+Alltrim(SM0->M0_NOMECOM)+'</strong></p>
	WF003 += ' <p>&nbsp;</p>
	WF003 += ' <p>As notas fiscais relacionadas abaixo não estão com o campo CODRSEF (código que difine o status da nota fiscal junto a receita federal) do Livro Fiscal preenchido, a saber:</p>
	WF003 += ' <table width="689" height="98" border="1" cellspacing="0" bordercolor="#000000">
	WF003 += '   <tr>
	WF003 += '     <th bgcolor="#0000FF" scope="col"><div align="center" class="style1">Emissão</div></th>
	WF003 += '     <th bgcolor="#0000FF" scope="col"><div align="center" class="style1">Serie</div></th>
	WF003 += '     <th bgcolor="#0000FF" scope="col"><div align="center" class="style1">N.Fiscal</div></th>
	WF003 += '     <th bgcolor="#0000FF" scope="col"><div align="center" class="style1">CFOP</div></th>
	WF003 += '     <th bgcolor="#0000FF" scope="col"><div align="right" class="style1">Valor</div></th>
	WF003 += '   </tr>

	QF008 := " SELECT F3_ENTRADA,
	QF008 += "        F3_SERIE,
	QF008 += "        F3_NFISCAL,
	QF008 += "        F3_CFO,
	QF008 += "        F3_VALCONT
	QF008 += "   FROM " + RetSqlName("SF3")
	QF008 += "  WHERE F3_FILIAL = '"+xFilial("SF3")+"'
	QF008 += "    AND F3_ENTRADA BETWEEN '"+dtos(dDataBase-1)+"' AND '"+dtos(dDataBase)+"'
	//QF008 += "    AND F3_CODRSEF = '   '
	QF008 += "    AND ( F3_CODRSEF = '   ' OR F3_CODRSEF <> '100' )
	QF008 += "    AND ( F3_CFO >= '5000' OR F3_FORMUL <> ' ' )
	QF008 += "    AND D_E_L_E_T_ = ' '
	QF008 += "  ORDER BY F3_SERIE, F3_NFISCAL
	QF008 := ChangeQuery(QF008)
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QF008),'QF08',.T.,.T.)
	dbSelectArea("QF08")
	dbGoTop()
	While !Eof()

	cfEnvMl := .T.

	WF003 += '  <tr>
	WF003 += '    <td><div align="center">'+dtoc(stod(QF08->F3_ENTRADA))+'</div></td>
	WF003 += '    <td><div align="center">'+Alltrim(QF08->F3_SERIE)+'</div></td>
	WF003 += '    <td><div align="center">'+Alltrim(QF08->F3_NFISCAL)+'</div></td>
	WF003 += '    <td><div align="center">'+Alltrim(QF08->F3_CFO)+'</div></td>
	WF003 += '    <td><div align="right">'+Transform(QF08->F3_VALCONT, "@E 999,999,999,999.99")+'</div></td>
	WF003 += '  </tr>

	dbSelectArea("QF08")
	dbSkip()
	End
	QF08->(dbCloseArea())
	Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(cIndex+OrdBagExt())          //indice gerado

	WF003 += ' </table>
	WF003 += ' <p>Necessário acessar o Sistema Protheus, Menu Sped, Sub-Menu Monitor, Item Faixa, informar o intervalo de notas relacionadas e clicar em Ok. Com isto, o sistema atualiza o campo.</p>
	WF003 += ' <p>&nbsp;</p>
	WF003 += ' <p>Sem mais,</p>
	WF003 += ' <p>&nbsp;</p>
	WF003 += ' <p>E-mail enviado automaticamente pelo sistema Protheus (by BIA714).</p>
	WF003 += ' </body>
	WF003 += ' </html>

	If cfEnvMl
	df_Dest := "nilmara.luz@biancogres.com.br;jessyca.delaia@biancogres.com.br"
	//df_Dest := "carla.souza@biancogres.com.br"
	df_Assu := "Relação de notas sem CODRSEF - Empresa " + xv_Emps[x,1] + " Filial " + xv_Emps[x,2]
	df_Erro := "Relação de notas sem CODRSEF - Empresa " + xv_Emps[x,1] + " Filial " + xv_Emps[x,2] + " não enviado. Favor verificar!!!"
	U_BIAEnvMail(, df_Dest, df_Assu, WF003, df_Erro)
	EndIf

	ConOut("Data" + dtoc(dDataBase) + " HORA: " + TIME() + " - Finalizando Processo BIA714 - Empresa " + xv_Emps[x,1] + " Filial " + xv_Emps[x,2] )

	RESET ENVIRONMENT

	Next x

	Return