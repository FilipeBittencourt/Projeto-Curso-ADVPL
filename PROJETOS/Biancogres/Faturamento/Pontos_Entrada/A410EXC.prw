#include "rwmake.ch"
#include "topconn.ch"
#Include "PROTHEUS.CH"
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A410EXC     ³ Autor ³ FERNANDO ROCHA        ³ Data ³ 13/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponto de Entrada validar Excusao de Pedido de Venda          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BIANCOGRES                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function A410EXC()
	Local cAreaAnt := GetArea()
	Local lUsaCarga	:= GetNewPar("MV_YUSACAR",.F.)  //Define se utiliza a rotina de carga
	Local cAliasTmp
	Private lRet := .T.
	Private oMotCan := Nil

	If !Empty(cRepAtu)

		MsgBox("REPRESENTANTE não acesso para excluir pedido"+CRLF+"Favor entrar em contato com o depto. Comercial","A410EXC","STOP")

		RestArea(cAreaAnt)

		Return(.F.)

	EndIf

	//RUBENS JUNIOR (FACILE SISTEMAS)
	//VALIDAR SE JA EXISTE ALGUM ITEM FATURADO, POIS CASO EXISTA O SISTEMA NAO PERMITE EXCLUSAO MAS EXECUTA O PONTO DE ENTRADA
	cQRY := " SELECT C6_NUM,C6_NOTA FROM " + RetSqlName("SC6") + " SC6 "
	cQRY += " WHERE C6_NUM = '"+SC5->C5_NUM+"'AND C6_NOTA != '' AND D_E_L_E_T_='' AND C6_FILIAL = '"+xFilial("SC6")+"'  "

	TCQUERY cQRY ALIAS "QRY_SC6" NEW

	IF !QRY_SC6->(EOF())

		QRY_SC6->(DbCloseArea())

		RestArea(cAreaAnt)

		Return(.F.)

	EndIf

	QRY_SC6->(DbCloseArea())

	//RUBENS JUNIOR (FACILE SISTEMAS)
	//VALIDAR SE EXISTE PEDIDO ORIGINAL NA EMPRESA LM
	If !PedidoLM()
		RestArea(cAreaAnt)
		Return(.F.)
	EndIf

	//VALIDAR SE O PEDIDO POSSUI CARGA EM ABERTO E NAO DEIXAR EXLUIR
	IF lUsaCarga

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
		
			SELECT COUNT(ZZW_PEDIDO) CONT
			FROM %Table:ZZW% ZZW
			JOIN %Table:SC9% SC9 ON ZZW_FILIAL = C9_FILIAL AND ZZW_PEDIDO = C9_PEDIDO AND ZZW_ITEM = C9_ITEM AND ZZW_SEQUEN = C9_SEQUEN AND SC9.%NotDel%
			WHERE
				ZZW.ZZW_PEDIDO = %EXP:SC5->C5_NUM%
				AND ZZW.ZZW_STATUS <> 'X'
		   	AND SC9.C9_NFISCAL = ' '
				AND ZZW.%NotDel%
		
		EndSql

		IF (cAliasTmp)->CONT > 0
			MsgAlert("ESTE PEDIDO POSSUI CARGAS EM ABERTO!"+CRLF+"NÃO É POSSÍVEL A EXCLUSÃO.","CONTROLE DE CARGAS")
			lRet := .F.
		EndIf

		(cAliasTmp)->(DbCloseArea())

	ENDIF


	If lRet

		oMotCan := TWMotivoCancelamentoPedidoVenda():New()

		oMotCan:cNumero := SC5->C5_NUM
		oMotCan:cCliente := SC5->C5_CLIENTE
		oMotCan:cLoja := SC5->C5_LOJACLI

		oMotCan:Activate()

		lRet := oMotCan:lValid

	EndIf

	// Emerson (Facile) em 30/08/2021 - Tela Rateio RPV (BIAFG106) - Exclui os registros na tabela ZNC caso tenha sido rateado RPV
	If lRet

		U_FGT106EF("2", SC5->(C5_FILIAL+C5_NUM), "N")

	Endif

	RestArea(cAreaAnt)

Return(lRet)

/*
##############################################################################################################
# PROGRAMA...: PedidoLM
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 29/04/2014                      
# DESCRICAO..: VALIDAR SE EXISTE PEDIDO ORIGINAL NA EMPRESA LM 
##############################################################################################################                                      
*/
Static Function PedidoLM()
	Local ENTER := CHR(13)+CHR(10)
	Local lRet := .T.

	If cEmpAnt $ '01_03_05_13_14'

		If !Empty(SC5->C5_YCLIORI) .And. !Empty(SC5->C5_YLOJORI)

			cSQL := " SELECT C5_NUM, C6_BLQ, SC5LM.D_E_L_E_T_ AS DELETADO FROM SC5070 SC5LM " +ENTER
			cSQL += " INNER JOIN SC6070 SC6LM ON  C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL AND SC6LM.D_E_L_E_T_ ='' AND SC6LM.C6_NOTA='' " +ENTER
			cSQL += " WHERE SC5LM.C5_YPEDORI ='"+SC5->C5_NUM+"' AND SC5LM.C5_CLIENTE = '"+C5_YCLIORI+"' AND SC5LM.C5_LOJACLI = '"+C5_YLOJORI+"' "

			TCQUERY cSQL ALIAS "QRY" NEW

			If !QRY->(EOF())

				If (Empty(QRY->DELETADO)) .OR. (C6_BLQ != 'R')	//PEDIDO NAO EXCLUIDO E NEM ELIMINADO RESIDUO

					MsgBox("Favor Exlcuir Primeiramente o Pedido na Empresa LM. Pedido Na LM: '"+Alltrim(QRY->C5_NUM)+"' ","A410EXC","STOP")

					lRet := .F.

				EndIf

			EndIf

			QRY->(DbCloseArea())

		EndIf

	EndIf

Return(lRet)
