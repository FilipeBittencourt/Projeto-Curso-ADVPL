#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#include "TOTVS.CH"

/*/{Protheus.doc} BIA772
@author Marcos Alberto Soprani
@since 17/02/17
@version 1.0
@description Conferência de saldo de estoque negativo 
@obs Desenvolvido em atendimento a OS effettivo 3428-16.
@type function
/*/

User Function BIA772()

	Local hkArea := GetArea()
	Local hkDiasMenos := 0
	Local x

	If Select("SX6") == 0                                 // Via Schedule
		//***************************************************************

		xv_Emps    := U_BAGtEmpr("01_05_13_14")
		For x := 1 to Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

			ConOut("HORA: "+TIME()+" - Iniciando Processo BIA772 " + xv_Emps[x,1])

			hkDiasMenos := 1
			Processa({|| Bia772Proc(hkDiasMenos)})

			ConOut("HORA: "+TIME()+" - Finalizando Processo BIA772 " + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()

		Next

	Else                                         // Via Integração Manual
		//***************************************************************

		Processa({|| Bia772Proc(hkDiasMenos)})

	EndIf

	RestArea(hkArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Bia772Proc ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 17/02/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsável pela execução dos Jobs                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Bia772Proc(xxDiasMenos)

	If xxDiasMenos == 0
		hkDtRef := dDataBase
		hkDtFim := dDataBase
	Else
		hkDtRef := GetMV("MV_ULMES") + 1
		hkDtFim := dDataBase - xxDiasMenos 
	EndIf 
	hkProdN := {}

	RZ007 := " WITH MOVPRODT AS (SELECT DISTINCT D3_COD PRODUTO, D3_LOCAL LOCREF "
	RZ007 += "                      FROM " + RetSqlName("SD3") + " WITH (NOLOCK)"
	RZ007 += "                    WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	RZ007 += "                      AND D3_EMISSAO BETWEEN '" + dtos(hkDtRef) + "' AND '" + dtos(hkDtFim) + "' "
	RZ007 += "                      AND D_E_L_E_T_ = ' ' "
	RZ007 += "                    UNION "
	RZ007 += "                   SELECT DISTINCT D1_COD PRODUTO, D1_LOCAL LOCREF "
	RZ007 += "                      FROM " + RetSqlName("SD1") + " WITH (NOLOCK) "
	RZ007 += "                    WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
	RZ007 += "                      AND D1_DTDIGIT BETWEEN '" + dtos(hkDtRef) + "' AND '" + dtos(hkDtFim) + "' "
	RZ007 += "                      AND D_E_L_E_T_ = ' ' "
	RZ007 += "                    UNION "
	RZ007 += "                   SELECT DISTINCT D2_COD PRODUTO, D2_LOCAL LOCREF "
	RZ007 += "                      FROM " + RetSqlName("SD2") + " WITH (NOLOCK) "
	RZ007 += "                    WHERE D2_FILIAL = '" + xFilial("SD2") + "' "
	RZ007 += "                      AND D2_EMISSAO BETWEEN '" + dtos(hkDtRef) + "' AND '" + dtos(hkDtFim) + "' "
	RZ007 += "                      AND D_E_L_E_T_ = ' ') "
	RZ007 += " SELECT * "
	RZ007 += "   FROM MOVPRODT "
	RZ007 += "  ORDER BY PRODUTO, LOCREF "
	RZcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RZ007),'RZ07',.F.,.T.)
	dbSelectArea("RZ07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Prod.: " + Alltrim(RZ07->PRODUTO) + " Loc.: " + RZ07->LOCREF)

		If Substr(RZ07->PRODUTO,1,3) <> "MOD"

			aSaldos := CalcEst(RZ07->PRODUTO, RZ07->LOCREF, dDataBase)
			If aSaldos[1] < 0

				aAdd(hkProdN, { RZ07->PRODUTO                                                    ,;
				Substr(Posicione("SB1", 1, xFilial("SB1") + RZ07->PRODUTO, "B1_DESC"),1,70)      ,;
				RZ07->LOCREF                                                                     ,;
				Transform(aSaldos[1],"@E 9,999,999.99999999")                                    })

			EndIf

		EndIf

		dbSelectArea("RZ07")
		dbSkip()

	End

	RZ07->(dbCloseArea())
	Ferase(RZcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RZcIndex+OrdBagExt())          //indice gerado

	If Len(hkProdN) > 0

		Bia772Mail()

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Bia772Mail ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 17.02.17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Bia772Mail()

	Local hkCorpMens
	Local npk

	hkCorpMens := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	hkCorpMens += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	hkCorpMens += ' <head> '
	hkCorpMens += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	hkCorpMens += ' <title>Untitled Document</title> '
	hkCorpMens += ' <style type="text/css"> '
	hkCorpMens += ' <!-- '
	hkCorpMens += ' .style15 {font-family: "Times New Roman", Times, serif} '
	hkCorpMens += ' .style17 {color: #FFFFFF; font-family: "Times New Roman", Times, serif; } '
	hkCorpMens += ' --> '
	hkCorpMens += ' </style> '
	hkCorpMens += ' </head> '
	hkCorpMens += ' <body> '
	hkCorpMens += ' <p>Prezados,</p> '
	hkCorpMens += ' <p>&nbsp;</p> '
	hkCorpMens += ' <p>Bom dia.</p> '
	hkCorpMens += ' <p>&nbsp;</p> '
	hkCorpMens += ' <p>Durante o processamento realizado deste dia ' + dtoc(dDataBase) + ' e hora ' + Time() + ', identificou-se os seguintes produtos com saldo negativo.</p> '
	hkCorpMens += ' <table width="1346" border="1"> '
	hkCorpMens += '   <tr> '
	hkCorpMens += '     <th width="234" bgcolor="#0066FF" scope="col"><div align="left" class="style17">Produto</div></th> '
	hkCorpMens += '     <th width="683" bgcolor="#0066FF" scope="col"><div align="left" class="style17">Descrição</div></th> '
	hkCorpMens += '     <th width="151" bgcolor="#0066FF" scope="col"><div align="center"><span class="style17">Local</span></div></th> '
	hkCorpMens += '     <th width="250" bgcolor="#0066FF" scope="col"><div align="right" class="style17">Quantidade Negativa</div></th> '
	hkCorpMens += '     <th width="250" bgcolor="#0066FF" scope="col"><div align="right" class="style17">B2_QATU</div></th> '
	hkCorpMens += '     <th width="250" bgcolor="#0066FF" scope="col"><div align="right" class="style17">B2_RESERVA</div></th> '
	hkCorpMens += '   </tr> '

	For npk := 1 to Len(hkProdN)

		SB2->(DbSetOrder(1))
		SB2->(DbSeek(xFilial("SB2") + hkProdN[npk][1] + hkProdN[npk][3] ))

		hkCorpMens += '   <tr> '
		hkCorpMens += '     <td><div align="left" class="style5 style15">' + hkProdN[npk][1] + '</div></td> '
		hkCorpMens += '     <td><div align="left" class="style5 style15">' + hkProdN[npk][2] + '</div></td> '
		hkCorpMens += '     <td><div align="center" class="style15">' + hkProdN[npk][3] + '</div></td> '
		hkCorpMens += '     <td><div align="right" class="style5 style15">' + hkProdN[npk][4] + '</div></td> '
		hkCorpMens += '     <td><div align="right" class="style5 style15">' + Transform(SB2->B2_QATU,"@E 9,999,999.99999999") + '</div></td> '
		hkCorpMens += '     <td><div align="right" class="style5 style15">' + Transform(SB2->B2_RESERVA,"@E 9,999,999.99999999") + '</div></td> '
		hkCorpMens += '   </tr> '

	Next npk

	hkCorpMens += ' </table> '
	hkCorpMens += ' <p>&nbsp;</p> '
	hkCorpMens += ' <p>Favor gerar o KARDEX do dia primeiro do mês corrente até a data da geração desta notificação e verificar qual movimento deixou o estoque negativo a fim de tentarmos corrigir antes do fechamento mensal. Caso identifique algum motivo que você não consiga corrigir, favor abrir ticket para tratar a situação.</p> '
	hkCorpMens += ' <p>&nbsp;</p> '
	hkCorpMens += ' <p>Atenciosamente,</p> '
	hkCorpMens += ' <p>&nbsp;</p> '
	hkCorpMens += ' <p>ps.: Não é necessários responder este e-mail. by BIA772</p> '
	hkCorpMens += ' </body> '
	hkCorpMens += ' </html> '

	df_Orig := "workflow@biancogres.com.br"
	df_Dest := U_EmailWF('BIA772', cEmpAnt)
	df_Assu := "Estoque com Saldo Negativo"
	df_Mens := hkCorpMens
	df_Erro := "Estoque com Saldo Negativo não enviado. Favor verificar!!!"

	U_BIAEnvMail(df_Orig, df_Dest, df_Assu, df_Mens, df_Erro)

Return
