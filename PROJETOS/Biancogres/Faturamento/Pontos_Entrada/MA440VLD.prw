#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MA440VLD
@description PONTO DE ENTRADA NA VALIDACAO DA TELA DE LIBERACAO DE PEDIDO DE VENDA
@author MADALENO / Revisado por Fernando Rocha no TICKET 17090
@since 25/07/2019
@version 1.0
/*/
USER FUNCTION MA440VLD()

	Local aAreaB1 := SB1->(GetArea())
	Local aAreaF4 := SF4->(GetArea())
	Local _aRet
	Local _aLotes := {}
	Local _cGerente 
	Local _cPedido := M->C5_NUM
	Local _lPswOk
	Local I, nX

	If cEmpAnt == "02"
		Return(.T.)
	EndIf

	FOR I := 1 TO LEN(ACOLS)

		If (ACOLS[I][Len(aHeader)+1]  )   //LINHA DELETADA
			Loop
		EndIf

		//Posiciona no Produto
		DBSELECTAREA("SB1")
		DBSETORDER(1)
		DBSEEK(XFILIAL("SB1")+Gdfieldget("C6_PRODUTO",I),.F.)

		//Posiciona no TES
		DBSELECTAREA("SF4")
		DBSETORDER(1)
		DBSEEK(XFILIAL("SF4")+Gdfieldget("C6_TES",I),.F.)

		//Valida o Lote, somente para produtos com Saldo a Liberar
		IF Gdfieldget("C6_QTDLIB",I) > 0
			//OBRIGA AO USUARIO INFORMAR O LOTE QUANDO TIPO E PA E A TES ATUALIZA ESTOQUE
			IF ALLTRIM(SB1->B1_TIPO) = "PA" .AND. ALLTRIM(SF4->F4_ESTOQUE) = "S"
				IF ALLTRIM(Gdfieldget("C6_LOTECTL",I) ) = ""
					// Projeto JK e regra geral de Lote
					If SB1->B1_RASTRO == "L"
						Msgbox("PARA PRODUTO DO TIPO PA, QUE ATUALIZA ESTOQUE, É OBRIGATORIO O PREENCHIMENTO DO LOTE","MA440VLD","STOP")
						RestArea(aAreaB1)
						RestArea(aAreaF4)
						RETURN(.F.)
					EndIf

				END IF
			END IF

			//RUBENS JUNIOR (FACILE SISTEMAS) IMPEDIR QUE SEJA LIBERADO PEDIDO NA BIANCOGRES OU INCESA, COM O PEDIDO DA LM BLOQUEADO
			//OS:0694-14
			//Fernando/Facile em 29/12/2014 - adicionado regra para o campo C6_YBLQLOT - bloqueio de lote
			If (cEmpAnt $ "01_05") .And. (SC5->C5_CLIENTE == '010064')

				CSQL := " SELECT C5_NUM,C6_BLQ,C6_BLOQUEI,C6_YBLQLOT FROM SC5070 SC5 "  +CRLF
				CSQL += " INNER JOIN SC6070 SC6 ON C6_PRODUTO = '"+Gdfieldget("C6_PRODUTO",I)+"' AND C6_NUM = C5_NUM AND C5_FILIAL = C6_FILIAL AND SC6.D_E_L_E_T_ = '' " +CRLF
				CSQL += " WHERE C5_YPEDORI = '"+SC5->C5_NUM+"' " +CRLF
				CSQL += " AND SC5.C5_CLIENTE = '"+SC5->C5_YCLIORI+"' " +CRLF
				CSQL += " AND SC5.C5_LOJACLI = '"+SC5->C5_YLOJORI+"' " +CRLF
				CSQL += " AND SC5.D_E_L_E_T_= '' "

				TCQUERY CSQL ALIAS "QRY" NEW

				IF !QRY->(EOF())
					If ((Alltrim(QRY->C6_BLQ) =='S') .And. (Alltrim(QRY->C6_BLOQUEI) =='S')) .Or. (QRY->C6_YBLQLOT $ "11_10_01")
						MsgStop("Pedido/Item Esta com Bloqueio na Empresa LM. Pedido na LM Numero: " +QRY->C5_NUM,"Verifique")
						QRY->(DbCloseArea())

						RestArea(aAreaB1)
						RestArea(aAreaF4)
						RETURN(.F.)
					EndIf
				EndIf
				QRY->(DbCloseArea())
			EndIf

		END IF

		//Valida a data de emissao e data de entrega do pedido
		IF Gdfieldget("C6_ENTREG",I) < M->C5_EMISSAO
			Msgbox("A Data de Entrega do item pedido não pode ser menor do que a Data de Emissao do pedido!","MA440VLD","STOP")

			RestArea(aAreaB1)
			RestArea(aAreaF4)
			RETURN(.F.)
		ENDIF

		//Ticket 17090 - Colocar mais uma validacao de ponta para tentar mitigar os riscos de passar algum pedido com esta condicao
		IF ( AllTrim(cEmpAnt) $ "01_05_13" ) .And. Gdfieldget("C6_QTDLIB",I) > 0 .And. M->C5_TIPO == 'N'  .And. M->C5_YLINHA <> "4" .And. !(Gdfieldget("C6_LOCAL",I) == AllTrim(GetNewPar("FA_LOCAMO","05")))

			//Acumulando Produtos/Lotes - pois a geracao de ponta pode ocorrer no total do pedido com o mesmo produto em varias linhas
			_nPL := aScan(_aLotes,{|x| x[1] == SB1->B1_COD .And. x[2] == Gdfieldget("C6_LOTECTL",I)})
			If _nPL > 0
				_aLotes[_nPL][3] += Gdfieldget("C6_QTDLIB",I)
			Else
				AAdd(_aLotes,{SB1->B1_COD, Gdfieldget("C6_LOTECTL",I), Gdfieldget("C6_QTDLIB",I)})
			EndIf

			If !(Gdfieldget("C6_YMOTFRA",I) == "998")

				_aRet := U_FR2CHKPT(SB1->B1_COD, Gdfieldget("C6_LOTECTL",I), Gdfieldget("C6_QTDLIB",I),,M->C5_NUM,Gdfieldget("C6_ITEM",I))
				If _aRet[1] == "P" 
					Msgbox("LIBERACAO DO ITEM: "+Gdfieldget("C6_ITEM",I)+" VAI GERAR PONTA NO ESTOQUE! POR FAVOR VERIFIQUE E DIGITE NOVAMENTE A QUANTIDADE A LIBERAR.","MA440VLD","STOP")

					RestArea(aAreaB1)
					RestArea(aAreaF4)
					RETURN(.F.)
				EndIF

			EndIf

		ENDIF

		//Fernando/Facile em 01/04/2014 - Reserva de OP - Excluir todas as reservas do item pedido se o mesmo foi liberado
		IF Gdfieldget("C6_QTDLIB",I) > 0

			aListRes := U_FRTE02LO("", _cPedido, Gdfieldget("C6_ITEM",I), "", "")
			If Len(aListRes) > 0
				
				//armazena os dados da reserva de op antes de apagar
				
				aRetOp	:= U_GETOPPED(_cPedido, Gdfieldget("C6_ITEM",I))
				
				U_FRRT02EX(_cPedido, Gdfieldget("C6_ITEM",I),Nil,"LIB",,,.T.)
				
				//refas o reserva op com saldo restante
				If (aRetOp != Nil .And. !Empty(aRetOp[2]))
					U_REFAZPZ0(_cPedido, Gdfieldget("C6_ITEM",I), aRetOp[1], aRetOp[2], aRetOp[3], aRetOp[4], aRetOp[5])
				EndIf 
			EndIf

		ENDIF

	NEXT I

	//Validar pontas do total de produto/lote
	IF ( AllTrim(cEmpAnt) $ "01_05_13" ) .And. M->C5_TIPO == 'N'  .And. M->C5_YLINHA <> "4"

		FOR nX := 1 To Len(_aLotes)

			//Posiciona no Produto
			DBSELECTAREA("SB1")
			DBSETORDER(1)
			DBSEEK(XFILIAL("SB1")+_aLotes[nX][1],.F.)

			_aRet := U_FR2CHKPT(_aLotes[nX][1], _aLotes[nX][2], _aLotes[nX][3],,"","")
			If _aRet[1] == "P" 

				_cGerente := U_FRGERADM(_cPedido) 

				_aRetAut := U_FROPTE10(AllTrim(SB1->B1_DESC),_aLotes[nX][2],Transform(_aLotes[nX][3],"@E 999,999.99"),Transform(_aRet[2],"@E 999,999.99"),Transform(_aRet[2]+_aLotes[nX][3],"@E 999,999.99"),_cGerente)
				_lPswOk := _aRetAut[1]		

				FOR I := 1 TO LEN(ACOLS)

					If (ACOLS[I][Len(aHeader)+1]  )   //LINHA DELETADA
						Loop
					EndIf

					IF (Gdfieldget("C6_LOCAL",I) == AllTrim(GetNewPar("FA_LOCAMO","05")))
						Loop
					ENDIF

					If _lPswOk 

						SC6->(DbSetOrder(1))
						If SC6->(DbSeek(XFilial("SC6")+_cPedido+Gdfieldget("C6_ITEM",I)))
							U_GravaPZ2(SC6->(RecNo()),"SC6",_aRetAut[4],_aRetAut[3],AllTrim(FunName()),"AGP", _aRetAut[2] )
						EndIf

						Gdfieldput("C6_YMOTFRA"	,"998",I)

					Else

						Gdfieldput("C6_QTDLIB",0,I)

					EndIf

				NEXT I

				If !_lPswOk
					RestArea(aAreaB1)
					RestArea(aAreaF4)
					RETURN(.F.)
				EndIf

			EndIF

		Next nX
	ENDIF

	RestArea(aAreaB1)
	RestArea(aAreaF4)

RETURN(.T.)
