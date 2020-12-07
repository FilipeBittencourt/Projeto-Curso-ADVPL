#include "rwmake.ch"
#Include "Protheus.ch"
#include "topconn.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "tbiconn.ch"
#INCLUDE "DIRECTRY.CH"

User Function BIA721()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA721
Empresa   := Biancogres Ceramica S.A.
Data      := 21/05/13
Uso       := Comercial
Aplicação := Envio automático de e-mail para informar ao Comercial que a nota
.            fiscal foi emitida e não foi enviada à Receita Federal
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local xv_Emps
Local x
xv_Emps    := U_BAGtEmpr("01_05_07_12_13")

For x := 1 to Len(xv_Emps)
	
	//Inicializa o ambiente
	RPCSetType(3)
	RPCSetEnv(xv_Emps[x,1],xv_Emps[x,2],"","","","",{})
	
	ConOut("Data " + dtoc(dDataBase) + " HORA: " + TIME() + " - Iniciando Processo BIA721 - Empresa " + xv_Emps[x,1] + " Filial " + xv_Emps[x,2] )
	
	grProsseg := .T.
	If cEmpAnt == "05"
		If Substr(Time(), 1, 5) < "17:53" .or. Substr(Time(), 1, 5) > "17:57"
			grProsseg := .F.
		EndIf
	Else
		If Substr(Time(), 1, 5) >= "17:53" .and. Substr(Time(), 1, 5) <= "17:57"
			grProsseg := .F.
		EndIf
	EndIf
	
	If grProsseg
		
		QJ008 := " SELECT *
		QJ008 += "   FROM (SELECT F3_ENTRADA,
		QJ008 += " 	              F3_SERIE,
		QJ008 += " 	              F3_NFISCAL,
		QJ008 += " 	              F3_CFO,
		QJ008 += " 	              F3_VALCONT,
		QJ008 += "                ISNULL((SELECT COUNT(*)
		QJ008 += "                          FROM SPED050 S050
		QJ008 += "                         INNER JOIN SPED001 S001 ON S001.ID_ENT = S050.ID_ENT
		QJ008 += "                                                AND S001.CNPJ = '"+Alltrim(SM0->M0_CGC)+"'
		QJ008 += "                                                AND S001.D_E_L_E_T_ = ' '
		QJ008 += "                         WHERE SUBSTRING(NFE_ID,1,12) = F3_SERIE+F3_NFISCAL
		QJ008 += "                           AND S050.D_E_L_E_T_ = ' '), 0) CONTAD,
		QJ008 += "                ISNULL((SELECT TOP 1 C5_YEMPPED
		QJ008 += "                          FROM "+RetSqlName("SD2")+" SD2
		QJ008 += "                         INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"'
		QJ008 += "                                              AND C5_NUM = D2_PEDIDO
		QJ008 += "                                              AND SC5.D_E_L_E_T_ = ' '
		QJ008 += "                         WHERE D2_FILIAL = '"+xFilial("SD2")+"'
		QJ008 += "                           AND D2_DOC = F3_NFISCAL
		QJ008 += "                           AND D2_SERIE = F3_SERIE
		QJ008 += "                           AND D2_CLIENTE = F3_CLIEFOR
		QJ008 += "                           AND D2_LOJA = F3_LOJA
		QJ008 += "                           AND D2_EMISSAO = F3_EMISSAO
		QJ008 += "                           AND SD2.D_E_L_E_T_ = ' '), '"+cEmpAnt+"') EMP_ORI
		QJ008 += "           FROM " + RetSqlName("SF3")
		QJ008 += "          WHERE F3_FILIAL = '"+xFilial("SF3")+"'
		QJ008 += "            AND F3_ENTRADA = '"+dtos(dDataBase)+"'
		QJ008 += "            AND F3_CODRSEF = '   '
		QJ008 += "            AND ( F3_CFO >= '5000' OR F3_FORMUL <> ' ' )
		QJ008 += "            AND F3_DTCANC = '        '
		QJ008 += "            AND D_E_L_E_T_ = ' ') AS TABL
		QJ008 += "  WHERE CONTAD = 0
		QJ008 += "  ORDER BY EMP_ORI, F3_NFISCAL, F3_SERIE
		cIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QJ008),'QJ08',.T.,.T.)
		dbSelectArea("QJ08")
		dbGoTop()
		While !Eof()
			
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
			WF003 += ' <p>As notas fiscais relacionadas abaixo não foram transmitidas para a Receita Federal, a saber:</p>
			WF003 += ' <table width="689" height="98" border="1" cellspacing="0" bordercolor="#000000">
			WF003 += '   <tr>
			WF003 += '     <th bgcolor="#0000FF" scope="col"><div align="center" class="style1">Emissão</div></th>
			WF003 += '     <th bgcolor="#0000FF" scope="col"><div align="center" class="style1">Serie</div></th>
			WF003 += '     <th bgcolor="#0000FF" scope="col"><div align="center" class="style1">N.Fiscal</div></th>
			WF003 += '     <th bgcolor="#0000FF" scope="col"><div align="center" class="style1">CFOP</div></th>
			WF003 += '     <th bgcolor="#0000FF" scope="col"><div align="right" class="style1">Valor</div></th>
			WF003 += '   </tr>
			
			gpEmpOri := QJ08->EMP_ORI
			While !Eof() .and. QJ08->EMP_ORI == gpEmpOri
				
				cfEnvMl := .T.
				
				WF003 += '  <tr>
				WF003 += '    <td><div align="center">'+dtoc(stod(QJ08->F3_ENTRADA))+'</div></td>
				WF003 += '    <td><div align="center">'+Alltrim(QJ08->F3_SERIE)+'</div></td>
				WF003 += '    <td><div align="center">'+Alltrim(QJ08->F3_NFISCAL)+'</div></td>
				WF003 += '    <td><div align="center">'+Alltrim(QJ08->F3_CFO)+'</div></td>
				WF003 += '    <td><div align="right">'+Transform(QJ08->F3_VALCONT, "@E 999,999,999,999.99")+'</div></td>
				WF003 += '  </tr>
				
				dbSelectArea("QJ08")
				dbSkip()
				
			End
			
			WF003 += ' </table>
			WF003 += ' <p>Necessário acessar o Sistema Protheus, Menu Sped e verificar porque a nota fiscal não foi enviada a Receita Federal.</p>
			WF003 += ' <p>&nbsp;</p>
			WF003 += ' <p>Sem mais,</p>
			WF003 += ' <p>&nbsp;</p>
			WF003 += ' <p>E-mail enviado automaticamente pelo sistema Protheus (by BIA721).</p>
			WF003 += ' </body>
			WF003 += ' </html>
			
			If cfEnvMl
			
				If gpEmpOri == "  "
					gpEmpOri := cEmpAnt
				EndIf
				If gpEmpOri == "01"
					df_Dest := "valmir.vali@biancogres.com.br;dalvina.ferreira@biancogres.com.br"
				ElseIf gpEmpOri == "05"
					df_Dest := "luismar.lucchini@biancogres.com.br;tatiane.perpetua@biancogres.com.br;breno.barbieri@biancogres.com.br;ramon.santos@biancogres.com.br"
				ElseIf gpEmpOri == "07"
					df_Dest := "valmir.vali@biancogres.com.br;luismar.lucchini@biancogres.com.br;tatiane.perpetua@biancogres.com.br;breno.barbieri@biancogres.com.br;ramon.santos@biancogres.com.br"
				ElseIf gpEmpOri == "12"
					//df_Dest := "robert.luchi@biancogres.com.br"
					df_Dest := "fabio.sa@biancogres.com.br"					
				ElseIf gpEmpOri == "13"
					df_Dest := "rodolfo.stanke.mundi@biancogres.com.br"
				EndIf
				df_Assu := "Relação de notas não transmitidas à Receita Federal - Empresa " + xv_Emps[x,1] + " Filial " + xv_Emps[x,2]
				df_Erro := "Relação de notas não transmitidas à Receita Federal - Empresa " + xv_Emps[x,1] + " Filial " + xv_Emps[x,2] + " não enviado. Favor verificar!!!"
				U_BIAEnvMail(, df_Dest, df_Assu, WF003, df_Erro)
			
				ConOut("Data " + dtoc(dDataBase) + " HORA: " + TIME() + " - Enviando e-mail para responsáveis BIA721 - Empresa " + xv_Emps[x,1] + " Filial " + xv_Emps[x,2] )
			
			EndIf
			
		End
		QJ08->(dbCloseArea())
		Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(cIndex+OrdBagExt())          //indice gerado
		
	EndIf
	
	ConOut("Data " + dtoc(dDataBase) + " HORA: " + TIME() + " - Finalizando Processo BIA721 - Empresa " + xv_Emps[x,1] + " Filial " + xv_Emps[x,2] )
	
	RESET ENVIRONMENT
	
Next x

Return
