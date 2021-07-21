#include "rwmake.ch"
#include "topconn.ch"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} M410VRES
@author Ranisses A. Corona
@since 24/05/13
@version 1.0
@description Grava campo C5_YMOTIVO, ao eliminar o pedido por residuo
@Obs Faturamento - Pedido de Venda
@type function
/*/

User Function M410VRES()

	Local cAreaAnt  := GetArea()
	Private lRet := .T.
	Private oMotCan := Nil

	//Gabriel Rossi Mafioletti - 21/02/2018 - Marcos - Impedir que se altere/exclua/elimine resíduo de pedidos cuja amostra esteja no ecosis
	If !U_BIAFG032(SC5->C5_NUM) .And. Alltrim(SC5->C5_YSUBTP) $ GETNEWPAR("MV_YTIPAMO","A#F#M")

		// Por Marcos Alberto Soprani, em 13/07/21, em atendimento ao ticket 33607
		If !SC5->C5_NUM $ "BK4054/F08110"

			MsgStop("Atenção, Não será possível eliminar resíduo do pedido pois o mesmo possui amostras enviadas para o Ecosis. Favor proceder com a exclusão das mesmas para poder eliminar resíduo!", "M410VRES(a)")
			Return(.F.)

		EndIf

	EndIf

	// Tiago Rossini Coradini - 05/12/16 - OS: 3843-16 - Ranisses Corona - Bloqueio de Eliminação de Residuo
	lRet := U_BIAF056(SC5->C5_NUM, SC5->C5_YPEDORI, SC5->C5_CLIENTE, SC5->C5_YCLIORI, SC5->C5_YLOJORI)

	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 24/03/2014 - Projeto RESERVA DE OP - Validar pedidos com RESERVA
	//---------------------------------------------------------------------------------------------------------------------------
	If lRet .And. SC5->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES","14")))

		SC6->(DbSetOrder(1))

		If (AllTrim(CEMPANT) == "14") .And. SC6->(DbSeek(XFilial("SC6")+SC5->C5_NUM)) .And. !U_CHKRODA(SC6->C6_PRODUTO)
			lRet := .T.
		ElseIf Len(U_FRTE02LO("", SC5->C5_NUM, "", "", "")) > 0  
			MsgBox("Pedido possui RESERVAS vinculadas, não é possível eliminar Resíduo.","M410VRES","STOP")
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

		oMotCan:Activate()

		lRet := oMotCan:lValid

	EndIf

	//RUBENS JUNIOR (FACILE SISTEMAS)
	//VALIDAR SE EXISTE PEDIDO ORIGINAL NA EMPRESA LM 
	//Fernando/Facil em 09/02/15 - mater por ultimo no PE - verifica se o pedido na LM ainda nao esta cancelado e cancela automaticamente
	If lRet

		If SC5->C5_CLIENTE == "010064"			

			ELRESLM(cEmpAnt, SC5->C5_NUM)

			_cPedLM := ""
			_cPedFilLM := ""			

			If !PedidoLM(@_cPedLM, @_cPedFilLM)			    

				// Tentar Eliminar Residuo de todos os itens automaticamente na LM
				U_BIAMsgRun("Aguarde... Excluindo Resíduo na LM. Pedido LM: "+_cPedLM,,{|| lRet := fResLM(_cPedLM, oMotCan:cCodMot, oMotCan:cObsMot, _cPedFilLM) })

				If !lRet
					MsgBox("Não foi possivel Eliminar Residuo automaticamente do pedido "+_cPedLM+" na Empresa LM.","M410VRES","STOP")
				EndIf			    

			Else

				If !Empty(_cPedLM)
					lRet := .F.
				EndIf


			EndIf 

		EndIf

	EndIf

	If lRet

		// Salva motivo de cancelamento
		oMotCan:Save()

		oMotCan := Nil		

		//Verificar se existe baixa de AI do pedido e excluir a baixa
		If !Empty(SC5->C5_YNUMSI) .And. !(AllTrim(CEMPANT) $ '14')
			U_AIEXCBX(SC5->C5_NUM, SC5->C5_YLINHA, SC5->C5_YNUMSI, SC5->C5_CLIENTE, SC5->C5_YEMPPED)
		EndIf

		If (!Empty(SC5->C5_NUM))

			//limpa os bloqueios problemas na eliminação residuos
			cQuery := "UPDATE "+RetSqlName("SC6")+" SET 											"
			cQuery += " C6_BLQ 			= 'N',														"
			cQuery += " C6_BLOQUEI 		= '',														"
			cQuery += " C6_MSEXP 		= ''														"
			cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+ SC5->C5_NUM +"'		"
			cQuery += " AND C6_BLQ <> 'R' AND D_E_L_E_T_ = '' 										"
			TcSQLExec(cQuery)

		EndIf

		// Tiago Rossini Coradini - 09/08/2017 - OS: 4538-16 - Exclui bloqueio comercial do pedido de venda 
		U_BIAF083(SC5->C5_NUM)

	EndIf

	RestArea(cAreaAnt)

Return(lRet) 

//---------------------------------------------------------------------------------------------------------------------------
//FERNANDO/FACILE em 09/02/2015 - Eliminar residuo automaticamente na empresa LM
//---------------------------------------------------------------------------------------------------------------------------
Static Function fResLM(_cPedLM, cMotivo, cObsMot, _cPedFilLM)

	Local _lOk := .T.

	_lOk := U_FROPCPRO("07","01","U_FXRESLM", _cPedLM, cMotivo, cObsMot, _cPedFilLM)

Return(_lOk)

Static Function ELRESLM(cEmp, cPed)

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
		cQuery += " WHERE C6_FILIAL = '"+(cAliasTmp)->C5_FILIAL+"' AND C6_NUM = '"+ (cAliasTmp)->C5_NUM +"'	"
		cQuery += " AND C6_BLQ <> 'R' AND D_E_L_E_T_ = '' 											"
		TcSQLExec(cQuery)

		//U_BIAF083((cAliasTmp)->C5_NUM)

	EndIf

	(cAliasTmp)->(DbCloseArea())	

Return 

User Function FXRESLM(cPedOri, cMotivo, cObsMot, _cPedFilLM)

	Local _lOk := .T.

	BEGIN TRANSACTION

		SC6->(DbSetOrder(1))
		If SC6->(DbSeek(XFilial("SC6")+cPedOri))

			While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == (XFilial("SC6")+cPedOri)

				If !(AllTrim(SC6->C6_BLQ) == "R") .And. (SC6->C6_QTDVEN - SC6->C6_QTDENT) > 0
					_lOk := MaResDoFat(SC6->(RecNo()),.T.,.T.,0) 

					If _lOk

						RecLock("SC6", .F.)

						SC6->C6_YDTRESI := dDataBase
						SC6->C6_YMOTIVO := cMotivo
						SC6->C6_YOBSMOT := cObsMot

						SC6->(MsUnlock())

					EndIf

				EndIf

				If !_lOk
					exit
				EndIf

				SC6->(DbSkip())

			EndDo

		EndIf

		If !Empty(_cPedFilLM)

			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(_cPedFilLM))

				While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == (_cPedFilLM)

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

					If !_lOk
						exit
					EndIf

					SC6->(DbSkip())

				EndDo

			EndIf

		EndIf

		If !(Empty(cPedOri))
			U_BIAF083(cPedOri)
		EndIf

		If !_lOk
			DisarmTransaction()
		EndIf

	END TRANSACTION

Return(_lOk)

/*############################################################################################################
# PROGRAMA...: PedidoLM
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 29/04/2014                      
# DESCRICAO..: VALIDAR SE EXISTE PEDIDO ORIGINAL NA EMPRESA LM 
############################################################################################################*/
Static Function PedidoLM(_cPedLM, _cPedFilLM)

	Local ENTER := CHR(13)+CHR(10)  
	Local lRet := .T.

	If cEmpAnt $ '01_03_05_13_14'

		If !Empty(SC5->C5_YCLIORI) .And. !Empty(SC5->C5_YLOJORI)

			cSQL := " SELECT C5_FILIAL, C5_NUM, C6_BLQ, SC5LM.D_E_L_E_T_ AS DELETADO	" +ENTER
			cSQL += " FROM SC5070 SC5LM INNER JOIN SC6070 SC6LM ON  		            " +ENTER
			cSQL += "	C5_FILIAL = C6_FILIAL AND 							            " +ENTER
			cSQL += "	C5_NUM    = C6_NUM 									            " +ENTER
			cSQL += " WHERE SC5LM.C5_YEMPPED = '" + AllTrim(CEMPANT) + "' AND           " +ENTER
			cSQL += " 		SC5LM.C5_YPEDORI = '" + SC5->C5_NUM + "' AND 	            " +ENTER		
			cSQL += "	  	SC6LM.C6_QTDVEN-SC6LM.C6_QTDENT > 0 	 AND	            " +ENTER	
			cSQL += "	  	SC6LM.C6_BLQ	 <> 'R' 				 AND	            " +ENTER	
			cSQL += "	  	SC6LM.D_E_L_E_T_ = '' 					 AND	            " +ENTER
			cSQL += " 		SC5LM.D_E_L_E_T_ = '' 							            " +ENTER				

			TCQUERY cSQL ALIAS "QRY" NEW

			WHILE !QRY->(EOF())

				If AllTrim(QRY->C6_BLQ) == "S"

					MsgBox("O Pedido na Empresa LM (Filial: "+QRY->C5_FILIAL+") está com BLOQUEIO COMERCIAL."+CRLF+"Favor Cancelar Primeiramente o Pedido na Empresa LM. Pedido Na LM: '"+Alltrim(QRY->C5_NUM)+"' ","M410VRES","STOP")

					lRet := .T.

					Exit

				Else

					If AllTrim(QRY->C5_FILIAL) == "01" .and. Empty(_cPedLM)
						_cPedLM := QRY->C5_NUM
					EndIf

					If AllTrim(QRY->C5_FILIAL) <> "01" .and. Empty(_cPedFilLM)
						_cPedFilLM := QRY->C5_FILIAL+QRY->C5_NUM
					EndIf

					lRet := .F.

				EndIf

				QRY->(DBSKIP())

			EndDo

			QRY->(DbCloseArea())

		EndIf

	EndIf       

Return(lRet)
