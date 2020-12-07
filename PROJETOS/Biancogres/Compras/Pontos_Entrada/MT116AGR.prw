#include "rwmake.ch"
#include "ap5mail.ch"
#include "TOTVS.CH"
#include "topconn.ch"

User Function MT116AGR()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := MT116AGR
Empresa   := Biancogres Cerâmica S/A
Data      := 22/03/12
Uso       := Conhecimento de Transporte
Aplicação := Verifica a existencia mais de um conhecimento associado a mesma
.           nota fiscal de entrada.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local i
Private WF047	:=""

If IsInCallStack("U_PNFM0003")
	If (AllTrim(SF1->F1_ESPECIE) == "CTE")
		Reclock("SF1",.F.)
			SF1->F1_ORIGLAN	:=	""
		SF1->(MsUnlock())
	EndIf
EndIf


If INCLUI .and. Len(xtVetNfO) > 0
	xy_Busc := "'"
	For i := 1 to Len(xtVetNfO)
		xy_Busc += xtVetNfO[i][1]+xtVetNfO[i][2]+xtVetNfO[i][3]+xtVetNfO[i][4]
		xy_Busc += "','"
	Next i
	xy_Busc := Substr(xy_Busc, 1, Len(Alltrim(xy_Busc)) -2 )
	
	xy_1Prim := .T.
	A0001 := " SELECT F8_NFORIG+F8_SERORIG+F8_FORNECE+F8_LOJA CHAVE,
	A0001 += "        XA2.A2_NOME NOMFORN,
	A0001 += "        F8_TRANSP,
	A0001 += "        F8_LOJTRAN,
	A0001 += "        F8_NFDIFRE,
	A0001 += "        F8_SEDIFRE,
	A0001 += "        F8_DTDIGIT,
	A0001 += "        SA2.A2_NOME NOMTRANS
	A0001 += "   FROM "+RetSqlName("SF8")+" SF8
	A0001 += "  INNER JOIN SA2010 SA2 ON SA2.A2_FILIAL = '"+xFilial("SA2")+"'
	A0001 += "                       AND SA2.A2_COD = F8_TRANSP
	A0001 += "                       AND SA2.A2_LOJA = F8_LOJTRAN
	A0001 += "                       AND SA2.D_E_L_E_T_ = ' '
	A0001 += "  INNER JOIN SA2010 XA2 ON XA2.A2_FILIAL = '"+xFilial("SA2")+"'
	A0001 += "                       AND XA2.A2_COD = F8_FORNECE
	A0001 += "                       AND XA2.A2_LOJA = F8_LOJA
	A0001 += "                       AND XA2.D_E_L_E_T_ = ' '
	A0001 += "  WHERE F8_FILIAL = '"+xFilial("SF8")+"'
	A0001 += "    AND F8_NFORIG+F8_SERORIG+F8_FORNECE+F8_LOJA IN("+xy_Busc+")
	A0001 += "    AND SF8.D_E_L_E_T_ = ' '
	A0001 += "  ORDER BY F8_NFORIG+F8_SERORIG+F8_FORNECE+F8_LOJA
	TCQUERY A0001 ALIAS "A001" NEW
	dbSelectArea("A001")
	dbGotop()
	While !Eof()
		xy_2Prim := .T.
		gp_conta  := 0
		gp_Chv    := A001->CHAVE
		xy_RcAnt := Recno()
		While !Eof() .and. A001->CHAVE == gp_Chv
			gp_conta ++
			dbSelectArea("A001")
			dbSkip()
		EndDo
		xy_RcDep := Recno()
		If gp_conta > 1
			fGerHTML()
		EndIf
	EndDo
	A001->(dbCloseArea())
	
	If (!xy_1Prim)
		
		WF047 += ' </table>
		WF047 += ' <p class="style3">Sem mais para o momento,</p>
		WF047 += ' <p class="style3">Setor Contábil</p>
		WF047 += ' </body>
		WF047 += ' </html>
		
		df_Dest := "fabio.sa@biancogres.com.br"		
		df_Assu := "Conhecimentos de frete associados a uma única nota fiscal."
		df_Erro := "Conhecimentos de frete associados a uma única nota fiscal não enviado. Favor verificar!!!"
		U_BIAEnvMail(, df_Dest, df_Assu, WF047, df_Erro)
		
	EndIf
		
EndIf

  

  
Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fGerHTML  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 22/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Gera script para HTML                                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fGerHTML()

If xy_1Prim
	xy_1Prim := .F.
	WF047 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	WF047 += ' <html xmlns="http://www.w3.org/1999/xhtml">
	WF047 += ' <head>
	WF047 += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	WF047 += ' <title>Untitled Document</title>
	WF047 += ' <style type="text/css">
	WF047 += ' <!--
	WF047 += ' .style1 {
	WF047 += ' 	font-family: "Times New Roman", Times, serif;
	WF047 += ' 	font-size: 10px;
	WF047 += ' 	font-weight: bold;
	WF047 += ' }
	WF047 += ' .style3 {
	WF047 += ' 	font-family: "Times New Roman", Times, serif;
	WF047 += ' 	font-size: 12px;
	WF047 += ' 	font-weight: bold;
	WF047 += ' }
	WF047 += ' .style4 {color: #FFFFFF}
	WF047 += ' -->
	WF047 += ' </style>
	WF047 += ' </head>
	WF047 += ' <body>
	WF047 += ' <p class="style3">Senhores,</p>
	WF047 += ' <p class="style3">Segue relação de mais de um conhecimento de transporte associados a uma única nota fiscal de Origem.</p>
EndIf

If xy_2Prim
	xy_2Prim := .F.
	WF047 += ' <table width="680" border="1" bordercolor="#000000">
	WF047 += '   <tr>
	WF047 += '     <th width="55" bordercolor="#000000" bgcolor="#0000FF" class="style1" scope="row"><div align="center" class="style4">Espécie</div></th>
	WF047 += '     <td width="68" bordercolor="#000000" bgcolor="#0000FF" class="style1"><div align="center" class="style4">N.Fiscal</div></td>
	WF047 += '     <td width="46" bordercolor="#000000" bgcolor="#0000FF" class="style1"><div align="center" class="style4">Série</div></td>
	WF047 += '     <td width="73" bordercolor="#000000" bgcolor="#0000FF" class="style1"><div align="center" class="style4">Fornecedor</div></td>
	WF047 += '     <td width="47" bordercolor="#000000" bgcolor="#0000FF" class="style1"><div align="center" class="style4">Loja</div></td>
	WF047 += '     <td width="279" bordercolor="#000000" bgcolor="#0000FF" class="style1"><div align="left" class="style4">Nome</div></td>
	WF047 += '     <td width="66" bordercolor="#000000" bgcolor="#0000FF" class="style1"><div align="center" class="style4">Emissão</div></td>
	WF047 += '   </tr>
	dbSelectArea("A001")
	dbGoTop()
	dbGoTo(xy_RcAnt)
	WF047 += '   <tr>
	WF047 += '     <th bordercolor="#000000" class="style1" scope="row"><div align="center">'+"NF"+'</div></th>
	WF047 += '     <td bordercolor="#000000" class="style1"><div align="center">'+Substr(A001->CHAVE,1,9)+'</div></td>
	WF047 += '     <td bordercolor="#000000" class="style1"><div align="center">'+Alltrim(Substr(A001->CHAVE,10,3))+'</div></td>
	WF047 += '     <td bordercolor="#000000" class="style1"><div align="center">'+Substr(A001->CHAVE,13,6)+'</div></td>
	WF047 += '     <td bordercolor="#000000" class="style1"><div align="center">'+Substr(A001->CHAVE,19,2)+'</div></td>
	WF047 += '     <td bordercolor="#000000" class="style1"><div align="left">'+Alltrim(A001->NOMFORN)+'</div></td>
	WF047 += '     <td bordercolor="#000000" class="style1"><div align="center">.</div></td>
	WF047 += '   </tr>
	WF047 += '   <tr>
	WF047 += '     <th colspan="7" bordercolor="#000000" class="style1" scope="row"><div align="left" class="style4">.</div></th>
	WF047 += '   </tr>
	While !Eof() .and. A001->CHAVE == gp_Chv
		WF047 += '   <tr>
		WF047 += '     <th bordercolor="#000000" class="style1" scope="row"><div align="center">'+"CTR"+'</div></th>
		WF047 += '     <td bordercolor="#000000" class="style1"><div align="center">'+A001->F8_NFDIFRE+'</div></td>
		WF047 += '     <td bordercolor="#000000" class="style1"><div align="center">'+Alltrim(A001->F8_SEDIFRE)+'</div></td>
		WF047 += '     <td bordercolor="#000000" class="style1"><div align="center">'+A001->F8_TRANSP+'</div></td>
		WF047 += '     <td bordercolor="#000000" class="style1"><div align="center">'+A001->F8_LOJTRAN+'</div></td>
		WF047 += '     <td bordercolor="#000000" class="style1"><div align="left">'+Alltrim(A001->NOMTRANS)+'</div></td>
		WF047 += '     <td bordercolor="#000000" class="style1"><div align="center">'+dtoc(stod(A001->F8_DTDIGIT))+'</div></td>
		WF047 += '   </tr>
		dbSelectArea("A001")
		dbSkip()
	End
	dbGoTo(xy_RcDep)
	
EndIf
  
Return
