#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT460EST  บAutor  ณFernando Rocha      บ Data ณ  06/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada - validar estorno Docs - MATA460          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BIANCOGRES                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MT460EST()
	Local lUsaCarga	:=	GetNewPar("MV_YUSACAR",.F.)  //Define se utiliza a rotina de carga
	Local _lRet 		:= .T.
	Local _aArea 		:= GetArea()
	Local cAliasTmp
	Local _aRet
	Local _aRetAut		:= {}
	Local _cGerente
	Local _cTpNRes := GetNewPar("FA_TPNRES","A #RI#F #")

	//Tratamento especial para Replicacao de reajuste de pre็o
	If (IsInCallStack("U_M410RPRC")) .Or. (AllTrim(FunName()) == "RPC")
		Return(.T.)
	EndIf

	//Fernando/Facile em 28/04/2015 - sempre gravar log de inclusao do SC9 - avaliando para relatorio
	If Type("CUSERNAME") <> "U" //.And. 1 == 0 //temporario - nao rodar

		//Posicionar Pedido
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(XFilial("SC5")+SC9->C9_PEDIDO))

		If SC5->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES",""))) .And. SC5->C5_YLINHA <> "4" .And. !(SC5->C5_YSUBTP $ _cTpNRes) .And. !(AllTrim(FunName()) == "BIAEC001") .And. AllTrim(CEMPANT) <> "07" .And. !(AllTrim(SC5->C5_YSUBTP) $ "A#M")

			_aRet := U_FR2CPTEX(SC9->C9_PRODUTO, SC9->C9_LOTECTL, SC9->C9_QTDLIB, SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_SEQUEN)
			//Ponta
			If (_aRet[1] == "P")

				_cGerente := U_FRGERADM(SC9->C9_PEDIDO)

				SB1->(DbSetOrder(1))
				SB1->(DbSeek(XFilial("SB1")+SC9->C9_PRODUTO))

				//Caso a origem do estorno seja a rotina de BIA859/SCHEDULE, o sistema passa os parametros automaticamente para a rotina //RANISSES EM 26/06/15
				If (AllTrim(FunName()) == "BIA859") .Or. (AllTrim(FunName()) == "WFPREPENV")
					aadd(_aRetAut,.T.)				//Autoriza
					aadd(_aRetAut,"BIA859")			//Nome do Autor
					aadd(_aRetAut,"010")			//Codigo do Motivo do Estorno
					aadd(_aRetAut,"ESTORNO DE RA")  //Descri็ใo do Motivo do Estorno

					//Criado por Fernando em 22/10/15  - na alteracao de pedido o fonte padrao nใo respeita o retorno falso deste PE, logo tive que desativar e sempre retornar true
					//O SC9 nao estava sendo estornado ficando diferente do SC6
				ElseIf  (AllTrim(FunName()) == "MATA410")
					aadd(_aRetAut,.T.)				//Autoriza
					aadd(_aRetAut,"MATA410")		//Nome do Autor
					aadd(_aRetAut,"999")			//Codigo do Motivo do Estorno
					aadd(_aRetAut,"ALTERACAO DE PEDIDO")  //Descri็ใo do Motivo do Estorno
				ElseIf (IsInCallStack("U_BIAFG023"))
					aadd(_aRetAut,.T.)				//Autoriza
					aadd(_aRetAut,"BIAFG023")			//Nome do Autor
					aadd(_aRetAut,"999")			//Codigo do Motivo do Estorno
					aadd(_aRetAut,"ESTORNO BIAFG023")  //Descri็ใo do Motivo do Estorno
				ElseIf (IsInCallStack("U_PROCQBIT"))
					aadd(_aRetAut,.T.)				//Autoriza
					aadd(_aRetAut,"PROCQBIT")			//Nome do Autor
					aadd(_aRetAut,"999")			//Codigo do Motivo do Estorno
					aadd(_aRetAut,"ESTORNO PROCQBIT")  //Descri็ใo do Motivo do Estorno
				Else

					_aRetAut	:= U_FROPTE10(AllTrim(SB1->B1_DESC),AllTrim(SC9->C9_LOTECTL),Transform(SC9->C9_QTDLIB,"@E 999,999.99"),Transform(_aRet[2],"@E 999,999.99"),Transform(_aRet[2]-SC9->C9_QTDLIB,"@E 999,999.99"),_cGerente, .T.)

				EndIf

				_lRet 		:= _aRetAut[1]

				If _lRet

					U_GravaPZ2(SC9->(RecNo()),"SC9","MT460EST","PONTA",AllTrim(FunName()),"PNE",CUSERNAME)

					SC6->(DbSetOrder(1))
					If SC6->(DbSeek(XFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))
						U_GravaPZ2(SC6->(RecNo()),"SC6",_aRetAut[4],_aRetAut[3],AllTrim(FunName()),"AGP", _aRetAut[2] )
					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

//VALIDAR SE O PEDIDO POSSUI CARGA EM ABERTO E NAO DEIXAR EXLUIR
//ALTERACAO - RUBENS JUNIOR (FACILE SISTEMAS) - 14/02/14 OS:1429-13
//IF lUsaCarga .And. (AllTrim(FunName()) == "MATA460") .And. CMODULO = "FAT"
	IF _lRet .And. lUsaCarga .And. (AllTrim(FunName()) == "MATA460" .OR. AllTrim(FunName()) == "MATA460A") .And. CMODULO = "FAT"

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
	
		SELECT COUNT(ZZW_PEDIDO) CONT
		FROM %Table:ZZW% ZZW
		JOIN %Table:SC9% SC9 ON ZZW_FILIAL = C9_FILIAL AND ZZW_PEDIDO = C9_PEDIDO AND ZZW_ITEM = C9_ITEM AND ZZW_SEQUEN = C9_SEQUEN AND SC9.%NotDel%
		WHERE
			ZZW.ZZW_PEDIDO 		= %EXP:SC9->C9_PEDIDO%
			AND ZZW.ZZW_ITEM 	= %EXP:SC9->C9_ITEM%
			AND ZZW.ZZW_SEQUEN 	= %EXP:SC9->C9_SEQUEN%
			AND ZZW.ZZW_STATUS 	<> 'X'
		 	AND SC9.C9_NFISCAL 	= ' '
			AND ZZW.%NotDel%
	
		EndSql

		IF (cAliasTmp)->CONT > 0
			MsgAlert("O PEDIDO "+SC9->C9_PEDIDO+" - ITEM "+SC9->C9_ITEM+" POSSUI CARGAS EM ABERTO!"+CRLF+"NรO ษ POSSอVEL O ESTORNO DA LIBERAวรO.","CONTROLE DE CARGAS")
			_lRet := .F.
		ENDIF
		(cAliasTmp)->(DbCloseArea())

	ENDIF

//Fernando/Facile em 28/04/2015 - sempre gravar log de inclusao do SC9 - manter por ultimo
	If Type("CUSERNAME") <> "U" .And. _lRet
		U_GravaPZ2(SC9->(RecNo()),"SC9",AllTrim(ProcName()),"MT460EST",AllTrim(FunName()),"C9E", CUSERNAME)
	EndIf

	RestArea(_aArea)
Return(_lRet)
