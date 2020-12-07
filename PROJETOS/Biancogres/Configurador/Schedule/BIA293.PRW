#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#include "topconn.ch"

User Function BIA293()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA293
Empresa   := Biancogres Ceramica S.A.
Data      := 23/04/12
Uso       := Workflow
Aplicação := Verifica lançamento do Conhecimentos de Frete a partir das notas
.            Fiscais de Entrada de Massa
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

LOCAL     xv_Emps    := U_BAGtEmpr("01_05")
Local x

For x := 1 to Len(xv_Emps)
	
	//Inicializa o ambiente
	RPCSetType(3)
	RPCSetEnv(xv_Emps[x,1],xv_Emps[x,2],"","","","",{})
	
	ConOut("HORA: "+TIME()+" - Iniciando Processo BIA293 " + xv_Emps[x,1])
	
	pw_ImpCabec := .F.
	pw_DtRef    := dDataBase-1
	WR027 := " SELECT D1_DOC,
	WR027 += "        D1_SERIE,
	WR027 += "        Convert(Char(10),convert(datetime, D1_DTDIGIT),103) D1_DTDIGIT,
	WR027 += "        D1_FORNECE,
	WR027 += "        D1_LOJA,
	WR027 += "        A2_NOME,
	WR027 += "        CASE
	WR027 += "          WHEN SF8_F > 0
	WR027 += "                OR SD1_F > 0 THEN 'FRETE OK'
	WR027 += "          ELSE 'FALTA LANCAMENTO DO FRETE'
	WR027 += "        END SITFRETE
	WR027 += "   FROM (SELECT *,
	WR027 += "                (SELECT COUNT(*)
	WR027 += "                   FROM "+RetSqlName("SF8")
	WR027 += "                  WHERE F8_FILIAL = '"+xFilial("SF8")+"'
	WR027 += "                    AND F8_NFORIG = NOTAS.D1_DOC
	WR027 += "                    AND F8_SERORIG = NOTAS.D1_SERIE
	WR027 += "                    AND F8_FORNECE = NOTAS.D1_FORNECE
	WR027 += "                    AND F8_LOJA = NOTAS.D1_LOJA
	WR027 += "                    AND D_E_L_E_T_ = ' ') SF8_F,
	WR027 += "                (SELECT COUNT(*)
	WR027 += "                   FROM "+RetSqlName("SD1")+" XXX
	WR027 += "                  WHERE XXX.D1_FILIAL = '"+xFilial("SD1")+"'
	WR027 += "                    AND XXX.D1_NFORI = NOTAS.D1_DOC
	WR027 += "                    AND XXX.D1_SERIORI = NOTAS.D1_SERIE
	WR027 += "                    AND XXX.D1_FORNECE = NOTAS.D1_FORNECE
	WR027 += "                    AND XXX.D1_LOJA = NOTAS.D1_LOJA
	WR027 += "                    AND XXX.D1_QUANT = 0
	WR027 += "                    AND XXX.D1_TES IN('397','4A6')
	WR027 += "                    AND XXX.D_E_L_E_T_ = ' ') SD1_F
	WR027 += "           FROM (SELECT D1_DOC,
	WR027 += "                        D1_SERIE,
	WR027 += "                        D1_FORNECE,
	WR027 += "                        D1_LOJA,
	WR027 += "                        D1_DTDIGIT
	WR027 += "                   FROM "+RetSqlName("SD1")+" SD1
	WR027 += "                  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
	WR027 += "                    AND D1_DTDIGIT = '"+dtos(pw_DtRef)+"'
	WR027 += "                    AND SUBSTRING(D1_COD, 1, 3) = '101'
	WR027 += "                    AND D1_COD NOT IN ( '1010127', '1010113', '1010107', '1010213', '1010229', '1010251', '1010271')
	WR027 += "                    AND D1_FORNECE NOT IN('008182','008241','001068','000534')
	WR027 += "                    AND D1_QUANT <> 0
	WR027 += "                    AND D1_TES NOT IN('397','4A6')
	WR027 += "                    AND D1_TIPO = 'N'
	WR027 += "                    AND SD1.D_E_L_E_T_ = ' ') AS NOTAS) AS FRETE
	WR027 += "  INNER JOIN SA2010 SA2 ON A2_FILIAL = '  '
	WR027 += "                       AND A2_COD = D1_FORNECE
	WR027 += "                       AND A2_LOJA = D1_LOJA
	WR027 += "                       AND SA2.D_E_L_E_T_ = ' '
	WR027 += "  WHERE NOT (SF8_F > 0 OR SD1_F > 0)
	TCQUERY WR027 New Alias "WR27"
	dbSelectArea("WR27")
	dbGoTop()
	While !Eof()
		
		If !pw_ImpCabec
			pw_ImpCabec := .T.
			Imp_Cabec()
		EndIf
		
		KY001 := '   <tr>
		KY001 += '     <td scope="row"><div align="center"><span class="style14">'+Alltrim(WR27->D1_DOC)+'</span></div></td>
		KY001 += '     <td><div align="center"><span class="style14">'+Alltrim(WR27->D1_SERIE)+'</span></div></td>
		KY001 += '     <td><div align="center"><span class="style14">'+dtoc(stod(WR27->D1_DTDIGIT))+'</span></div></td>
		KY001 += '     <td><div align="center"><span class="style14">'+Alltrim(WR27->D1_FORNECE)+'</span></div></td>
		KY001 += '     <td><div align="center"><span class="style14">'+Alltrim(WR27->D1_LOJA)+'</span></div></td>
		KY001 += '     <td><div align="left"><span class="style14">'+Alltrim(WR27->A2_NOME)+'</span></div></td>
		KY001 += '     <td><div align="left"><span class="style14">'+Alltrim(WR27->SITFRETE)+'</span></div></td>
		KY001 += '   </tr>
		
		dbSelectArea("WR27")
		dbSkip()
	End
	WR27->(dbCloseArea())
	
	If pw_ImpCabec
		Env_Mail()
		
		If xv_Emps[x,1] <> "05"
			df_Dest := "fabiano.bravin@biancogres.com.br;jessyca.delaia@biancogres.com.br;Marcieli.Malavasi@biancogres.com.br" //O.S 0698-15
			//df_Dest := "robert.luchi@biancogres.com.br;fabiana.corona@biancogres.com.br"
		Else                                         
			df_Dest := "fabiano.bravin@biancogres.com.br;marcio.nascimento@biancogres.com.br"			
			//df_Dest := "robert.luchi@biancogres.com.br;marcio.nascimento@biancogres.com.br"
		EndIf
		df_Assu := "Verificação de inclusão de Conhecimento de Frete"
		df_Erro := "Verificação de inclusão de Conhecimento de Frete não enviado. Favor verificar!!!"
		U_BIAEnvMail(, df_Dest, df_Assu, KY001, df_Erro)
	EndIf
	
	ConOut("HORA: "+TIME()+" - Finalizando Processo BIA293 " + xv_Emps[x,1])
	
	//Finaliza o ambiente criado
	RESET ENVIRONMENT
	
Next x

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Imp_Cabec ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 23/04/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir Cabeçalho de Horas Extras                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Imp_Cabec()

KY001 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
KY001 += ' <html xmlns="http://www.w3.org/1999/xhtml">
KY001 += ' <head>
KY001 += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
KY001 += ' <title>Untitled Document</title>
KY001 += ' <style type="text/css">
KY001 += ' <!--
KY001 += ' .style14 {font-family: "Times New Roman", Times, serif; font-size: 12px; }
KY001 += ' .style23 {font-family: "Times New Roman", Times, serif; font-size: 12px; font-weight: bold; }
KY001 += ' -->
KY001 += ' </style>
KY001 += ' </head>
KY001 += ' <body>
KY001 += ' <p>Algumas notas fiscal de mercadoria MASSA lançadas no dia '+dtoc(pw_DtRef)+' não possuem seus respectivos frete lançados.</p>
KY001 += ' <table width="751" border="1" cellspacing="0" bordercolor="#666666">
KY001 += '   <tr>
KY001 += '     <td width="59" bgcolor="#66CCFF" scope="row"><div align="center"><span class="style23">N.Fiscal</span></div></td>
KY001 += '     <td width="34" bgcolor="#66CCFF"><div align="center"><span class="style23">Serie</span></div></td>
KY001 += '     <td width="66" bgcolor="#66CCFF"><div align="center"><span class="style23">Dt Digit.</span></div></td>
KY001 += '     <td width="45" bgcolor="#66CCFF"><div align="center"><span class="style23">Forn.</span></div></td>
KY001 += '     <td width="30" bgcolor="#66CCFF"><div align="center"><span class="style23">Loja</span></div></td>
KY001 += '     <td width="231" bgcolor="#66CCFF"><div align="left"><span class="style23">Nome</span></div></td>
KY001 += '     <td width="256" bgcolor="#66CCFF"><div align="left"><span class="style23">Situação do Frete</span></div></td>
KY001 += '   </tr>

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Env_Mail  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 23/04/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprime rodapé do relatório                                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Env_Mail()

KY001 += ' </table>
KY001 += ' <p>Favor verificar e efetuar os devidos ajustes, caso necessário.</p>
KY001 += ' <p>&nbsp;</p>
KY001 += ' <p>&nbsp;</p>
KY001 += ' <p>&nbsp;</p>
KY001 += ' <p>by Protheus (BIA293)</p>
KY001 += ' </body>
KY001 += ' </html>

Return
