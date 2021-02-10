#include "rwmake.ch"
#include "topconn.ch"
#Include "PROTHEUS.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Ranisses A. Corona
Programa  := MT500ANT
Empresa   := Biancogres Cerêmicas S/A
Data      := 24/05/13
Uso       := Faturamento - Eliminação de Residuo
Aplicação := Grava campo C5_YMOTIVO, ao eliminar o pedido por residuo,
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function MT500ANT()
Local cAreaAnt := GetArea() 

Local aListRes

 
Private lRet := .T.
Private oMotCan := Nil

	
	//Gabriel Rossi Mafioletti - 21/02/2018 - Marcos - Impedir que se altere/exclua/elimine resíduo de pedidos cuja amostra esteja no ecosis
	If Alltrim(SC5->C5_YSUBTP) $ GETNEWPAR("MV_YTIPAMO","A#F#M") .And. !U_BIAFG032(SC5->C5_NUM,SC6->C6_ITEM)
	
		MsgStop("Atenção, Não será possível eliminar resíduo do pedido pois o mesmo possui amostras enviadas para o Ecosis. Favor proceder com a exclusão das mesmas para poder eliminar resíduo!")
		
		lRet	:= .F.
	//Gabriel Rossi Mafioletti - 09/07/2018 - Ticket 5828 - Excluir reservas de itens de amostra que não estejam no ecosis
	ElseIf Alltrim(SC5->C5_YSUBTP) $ GETNEWPAR("MV_YTIPAMO","A#F#M")
	
		aListRes := U_FRTE02LO("", SC5->C5_NUM, SC6->C6_ITEM, "", "")

		If Len(aListRes) > 0
			U_FRRT02EX(SC5->C5_NUM, SC6->C6_ITEM,Nil,"LIB",,,.F.)
		EndIf
		
	EndIf

	
	// Tiago Rossini Coradini - 05/12/16 - OS: 3843-16 - Ranisses Corona - Bloqueio de Eliminação de Residuo
	If lRet //If Incluído por Gabriel Rossi - 09/07/2018 para garantir o fluxo do fonte
		lRet := U_BIAF056(SC5->C5_NUM, SC5->C5_YPEDORI, SC5->C5_CLIENTE, SC5->C5_YCLIORI, SC5->C5_YLOJORI, SC6->C6_ITEM)
	EndIf
	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 24/03/2014 - Projeto RESERVA DE OP - Validar pedidos com RESERVA
	//---------------------------------------------------------------------------------------------------------------------------      
	If lRet
		
		If Len(U_FRTE02LO("", SC5->C5_NUM, SC6->C6_ITEM, "", "")) > 0
			MsgBox("Pedido/Item possui RESERVAS vinculadas, não é possível eliminar Resíduo.","MT500ANT","STOP")
			lRet := .F.
		EndIf
		
	EndIf

	

	// Tiago Rossini Coradini - OS: 2963-15 - Claudeir Fadini
	// Selecao de motivo de cancelamento
	If lRet

		oMotCan := TWMotivoCancelamentoPedidoVenda():New()
		
		oMotCan:cNumero := SC5->C5_NUM
		oMotCan:cCliente := SC5->C5_CLIENTE
		oMotCan:cLoja := SC5->C5_LOJACLI
		oMotCan:cItem := SC6->C6_ITEM
		
		If !oMotCan:GetMot()
		
			oMotCan:Activate()
		
			lRet := oMotCan:lValid
		
		EndIf
			
	EndIf

	

	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 09/02/2015 - MANTER POR ULTIMO - Vai eliminar residuo automaticamente na LM se houver
	//---------------------------------------------------------------------------------------------------------------------------      
	If lRet

		If SC6->C6_CLI == "010064"
			
			ELRESLM(cEmpAnt, SC5->C5_NUM, SC6->C6_ITEM)
			
			_cPedLM := ""
			_cPedFilLM := ""
				  	
			If !PedidoLM(@_cPedLM, @_cPedFilLM)
				
				U_BIAMsgRun("Aguarde... Excluindo Resíduo na LM. Pedido LM: "+_cPedLM,,{|| lRet := fResLM(_cPedLM, SC6->C6_ITEM, oMotCan:cCodMot, oMotCan:cObsMot, _cPedFilLM) })				
				
				If !lRet
					MsgBox("Não foi possivel Eliminar Residuo automaticamente do pedido "+_cPedLM+" na Empresa LM.","M410VRES","STOP")
				EndIf
				 				
			Else
				
				If !Empty(_cPedLM) .And. !CheckElimLM()
					lRet := .F.
				EndIf
				
			EndIf
						
		EndIf

	EndIf
	


	//---------------------------------------------------------------------------------------------------------------------------
	//FILIPE/FACILE em 03/02/2021 -  28398 - o sistema esta deixando o pedido ser cancelado,mesmo ele estando em carga. 	
	//---------------------------------------------------------------------------------------------------------------------------
	If lRet
		if CheckCarga(SC5->C5_NUM, SC6->C6_ITEM)
			MsgStop("Atenção - MT500ANT, Não será possível eliminar resíduo do pedido <b>"+SC5->C5_NUM+"</b>, pois o item <b>"+SC6->C6_ITEM+"</b> se econtra  em carga.")
		  lRet := .F.
		endIf
	EndIf



	If lRet

		// Salva motivo de cancelamento
		oMotCan:Save()		

		oMotCan := Nil

		// Tiago Rossini Coradini - 09/08/2017 - OS: 4538-16 - Exclui bloqueio comercial do pedido de venda 
		U_BIAF083(SC5->C5_NUM)

	EndIf

	RestArea(cAreaAnt)

Return(lRet) 

//---------------------------------------------------------------------------------------------------------------------------
//FERNANDO/FACILE em 09/02/2015 - Eliminar residuo automaticamente na LM se houver
//---------------------------------------------------------------------------------------------------------------------------      
Static Function fResLM(_cPedLM, _cItem, cMotivo, cObsMot, _cPedFilLM)
Local _lOk := .T.

	_lOk := U_FROPCPRO("07","01","U_FXRLMIT", _cPedLM, _cItem, cMotivo, cObsMot, _cPedFilLM)

Return(_lOk)


Static Function ELRESLM(cEmp, cPed, cItem)

	Local cAliasTmp 	:= Nil
	Local cQuery		:= ""
	
	cAliasTmp 	:= GetNextAlias()
		
	cQuery := " SELECT *												" 
	cQuery += " FROM SC5070			 				  					" 
	cQuery += " WHERE C5_YEMPPED = '"+AllTrim(cEmp)+"'			AND		" 
	cQuery += " C5_YPEDORI = '"+cPed+"'					 		AND		" 		
	cQuery += " D_E_L_E_T_ = ''										 	"		
	
	TcQuery cQuery New Alias (cAliasTmp)
	
	If (!(cAliasTmp)->(Eof()))
		
		//limpa os bloqueios problemas na eliminação residuos
		cQuery := "UPDATE SC6070 SET				 												"
		cQuery += " C6_BLQ 			= 'N',															"
		cQuery += " C6_BLOQUEI 		= '',															"
		cQuery += " C6_MSEXP 		= ''															"
		cQuery += " WHERE C6_FILIAL = '"+(cAliasTmp)->C5_FILIAL+"' AND C6_NUM = '"+ (cAliasTmp)->C5_NUM +"'	AND C6_ITEM = '"+cItem+"' "
		cQuery += " AND C6_BLQ <> 'R' AND D_E_L_E_T_ = '' 											"
		TcSQLExec(cQuery)
	
	
		//U_BIAF083((cAliasTmp)->C5_NUM)
		
	EndIf
	
	(cAliasTmp)->(DbCloseArea())	

Return 

User Function FXRLMIT(cPedOri, cItOri, cMotivo, cObsMot, _cPedFilLM)
Local _lOk := .T.

	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+cPedOri+cItOri))
		If !(AllTrim(SC6->C6_BLQ) == "R") .And. (SC6->C6_QTDVEN - SC6->C6_QTDENT) > 0
			_lOk := MaResDoFat(SC6->(RecNo()),.T.,.T.,0) 

			If _lOk
				
				RecLock("SC6",.F.)
				
					SC6->C6_YDTRESI := dDataBase
					SC6->C6_YMOTIVO := cMotivo
					SC6->C6_YOBSMOT := cObsMot
				
				SC6->(MsUnlock())
			EndIf
		EndIf
	EndIf

	If !Empty(_cPedFilLM)

		SC6->(DbSetOrder(1))
		If SC6->(DbSeek(_cPedFilLM+cItOri))
			If !(AllTrim(SC6->C6_BLQ) == "R") .And. (SC6->C6_QTDVEN - SC6->C6_QTDENT) > 0
				_lOk := MaResDoFat(SC6->(RecNo()),.T.,.T.,0) 

				If _lOk
					
					RecLock("SC6",.F.)
					
						SC6->C6_YDTRESI := dDataBase
						SC6->C6_YMOTIVO := cMotivo
						SC6->C6_YOBSMOT := cObsMot
					
					SC6->(MsUnlock())
					
				EndIf
			EndIf
		EndIf

	EndIf
	
	If !(Empty(cPedOri))
		U_BIAF083(cPedOri)
	EndIf

Return(_lOk)  

/*
##############################################################################################################
# PROGRAMA...: PedidoLM
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 29/04/2014                      
# DESCRICAO..: VALIDAR SE EXISTE PEDIDO ORIGINAL NA EMPRESA LM 
##############################################################################################################                                      
*/
Static Function PedidoLM(_cPedLM, _cPedFilLM)

	Local ENTER := CHR(13)+CHR(10)
	Local lRet := .T.

	If cEmpAnt $ '01_03_05_13_14'
		If !Empty(SC5->C5_YCLIORI) .And. !Empty(SC5->C5_YLOJORI)

			cSQL := " SELECT C5_FILIAL, C5_NUM, C6_BLQ, SC5LM.D_E_L_E_T_ AS DELETADO	" +ENTER
			cSQL += " FROM SC5070 SC5LM INNER JOIN SC6070 SC6LM ON  		" +ENTER
			cSQL += "	C5_FILIAL = C6_FILIAL AND 							" +ENTER
			cSQL += "	C5_NUM    = C6_NUM 									" +ENTER
			cSQL += " WHERE SC5LM.C5_YEMPPED = '"+AllTrim(CEMPANT)+"' AND 	" +ENTER
			cSQL += " 		SC5LM.C5_YPEDORI = '"+SC5->C5_NUM+"'	 AND 	" +ENTER
			cSQL += "	  	SC6LM.C6_ITEM = '"+SC6->C6_ITEM+"'	 	 AND	" +ENTER
			cSQL += "	  	SC6LM.C6_QTDVEN-SC6LM.C6_QTDENT > 0 	 AND	" +ENTER
			cSQL += "	  	SC6LM.C6_BLQ	 <> 'R' 				 AND	" +ENTER
			cSQL += "	  	SC6LM.D_E_L_E_T_ = '' 					 AND	" +ENTER
			cSQL += " 		SC5LM.D_E_L_E_T_ = '' 							" +ENTER
			TCQUERY cSQL ALIAS "QRY" NEW

			WHILE !QRY->(EOF())

				If AllTrim(QRY->C6_BLQ) == "S"
					MsgBox("O Pedido na Empresa LM (Filial: "+QRY->C5_FILIAL+") está com BLOQUEIO COMERCIAL."+CRLF+"Favor Cancelar Primeiramente o Pedido na Empresa LM. Pedido Na LM: '"+Alltrim(QRY->C5_NUM)+"' ","M410VRES","STOP")
					lRet := .T.
					Exit
				Else
					If AllTrim(QRY->C5_FILIAL) == "01"
						_cPedLM := QRY->C5_NUM
					Else
						_cPedFilLM := QRY->C5_FILIAL+QRY->C5_NUM
					EndIf
					lRet := .F.
				EndIf

				QRY->(DBSKIP())
			ENDDO

			QRY->(DbCloseArea())
		EndIf
	EndIf

Return lRet


Static Function CheckElimLM()

	Local ENTER		:= CHR(13)+CHR(10)
	Local lRet		:= .F.

	If cEmpAnt $ '01_03_05_13_14'
		If !Empty(SC5->C5_YCLIORI) .And. !Empty(SC5->C5_YLOJORI)

			cSQL := " SELECT C5_FILIAL, C5_NUM, C6_BLQ, SC5LM.D_E_L_E_T_ AS DELETADO	" +ENTER
			cSQL += " FROM SC5070 SC5LM INNER JOIN SC6070 SC6LM ON  					" +ENTER
			cSQL += "	C5_FILIAL = C6_FILIAL AND 										" +ENTER
			cSQL += "	C5_NUM    = C6_NUM 												" +ENTER
			cSQL += " WHERE SC5LM.C5_YEMPPED 	= '"+AllTrim(CEMPANT)+"' 		AND 	" +ENTER
			cSQL += " 		SC5LM.C5_YPEDORI	= '"+SC5->C5_NUM+"'	 			AND 	" +ENTER
			cSQL += "	  	SC6LM.C6_ITEM 		= '"+SC6->C6_ITEM+"'	 		AND		" +ENTER
			cSQL += "	  	SC6LM.C6_BLQ	 	= 'R' 							AND		" +ENTER
			cSQL += "	  	SC6LM.D_E_L_E_T_ 	= '' 							AND		" +ENTER
			cSQL += " 		SC5LM.D_E_L_E_T_ 	= '' 									" +ENTER
			TCQUERY cSQL ALIAS "QRY" NEW

			If !QRY->(EOF())
				lRet := .T.
			EndIf

			QRY->(DbCloseArea())
		EndIf
	EndIf

Return lRet



Static Function CheckCarga(c5Num, c6Item)

	Local cQuery   := ""
	Local cQry      := GetNextAlias()
	Local lRet      := .F.

	cQuery += " SELECT ZZW.ZZW_FILIAL, ZZW.ZZW_PEDIDO, ZZW.ZZW_ITEM , ZZW.ZZW_CCLI,  ZZW.ZZW_LCLI, ZZW.ZZW_CARGA " + CRLF
	cQuery += " FROM  "+RetSQLName("ZZW")+"  ZZW " + CRLF

	cQuery += " INNER JOIN "+RetSQLName("SC6")+" SC6 ON SC6.C6_FILIAL = ZZW.ZZW_FILIAL " + CRLF
	cQuery += " AND SC6.C6_NUM = ZZW.ZZW_PEDIDO " + CRLF
	cQuery += " AND SC6.C6_ITEM = ZZW.ZZW_ITEM " + CRLF
	cQuery += " AND SC6.D_E_L_E_T_ = '' " + CRLF

	cQuery += " WHERE ZZW.ZZW_FILIAL = '"+FWxFilial('SC6')+"' " + CRLF
	cQuery += " AND ZZW.ZZW_PEDIDO = '"+c5Num+"' " + CRLF
	cQuery += " AND ZZW.ZZW_ITEM = '"+c6Item+"' " + CRLF
	cQuery += " AND ZZW.D_E_L_E_T_ = '' " + CRLF

	TcQuery cQuery New Alias (cQry)

	If !EMPTY((cQry)->ZZW_PEDIDO)
		lRet := .T.
	EndIf

	(cQry)->(DbCloseArea())

Return lRet