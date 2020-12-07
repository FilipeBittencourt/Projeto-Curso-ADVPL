#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao     ≥ FROPTE02 ≥ Autor ≥ FERNANDO ROCHA        ≥ Data ≥13/03/2014≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao  ≥ CONSULTA DE RESERVAS POR PEDIDO/ITEM/PRODUTO			   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso        ≥ BIANCOGRES                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

User Function FROPTE02(_cProduto, _cPedido, _cItem, _cOpDoc, _cTipo)
	//_cTipo >>>  E = reservas de estoque, R = reservas de OP, VAZIO = tudo
	Local oButCan
	Local oButCan2
	Local oButRep
	Local oButOk
	Private oPanel1
	Private oPanel2
	Private oListRes
	Private oDlgRes
	Private aListRes := {}
	Private lRetRes := .F.

	Private PZ4TIPOF3
	Private _CMOTEXC := ""

	//Carregar dados e verificar se tem reservas
	U_FRTE02LO(_cProduto, _cPedido, _cItem, _cOpDoc,_cTipo, @aListRes)

	If Len(aListRes) <= 0
		Return(.T.)
	EndIf

	DEFINE MSDIALOG oDlgRes TITLE "Consulta RESERVAS de Estoque/ProduÁ„o" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL

	@ 000, 000 MSPANEL oPanel1 SIZE 300, 129 OF oDlgRes COLORS 0, 16777215 RAISED

	fListRes()

	@ 129, 000 MSPANEL oPanel2 SIZE 300, 020 OF oDlgRes COLORS 0, 16777215 RAISED
	@ 000, 249 BUTTON oButOk PROMPT "OK" SIZE 050, 019 OF oPanel2 PIXEL ACTION ( oDlgRes:End() )

	If AllTrim(CEMPANT) <> "07"

		If _cTipo <> "R"
			@ 000, 199 BUTTON oButCan PROMPT "Excluir Reservas Estoque" SIZE 100, 019 OF oPanel2 PIXEL ACTION (  IIF( lRetRes := DelReserv(1,_cPedido),oDlgRes:End(),)  )
		EndIf

		@ 000, 199 BUTTON oButCan2 PROMPT "Excluir Reservas OP" SIZE 100, 019 OF oPanel2 PIXEL ACTION (  IIF( lRetRes := DelReserv(2,_cPedido),oDlgRes:End(),)  )

		If _cTipo == "R"
			@ 000, 199 BUTTON oButRep PROMPT "Reprogramar Reservas" SIZE 100, 019 OF oPanel2 PIXEL ACTION ( U_FROPTE03(_cOpDoc), lRetRes := Len(U_FRTE02LO("", "", "", _cOpDoc,_cTipo) ) <= 0 )
		EndIf

	EndIf

	// Don't change the Align Order
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
	oButOk:Align := CONTROL_ALIGN_RIGHT

	If AllTrim(CEMPANT) <> "07"

		If _cTipo <> "R"
			oButCan:Align := CONTROL_ALIGN_RIGHT
		EndIf

		oButCan2:Align := CONTROL_ALIGN_RIGHT

		If _cTipo == "R"
			oButRep:Align := CONTROL_ALIGN_RIGHT
		EndIf

	EndIf

	oListRes:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgRes CENTERED

	lRetRes := Len(U_FRTE02LO(_cProduto, _cPedido, _cItem, _cOpDoc,_cTipo, @aListRes)) <= 0

Return(lRetRes)

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//LISTBOX DA CONSULTA
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function fListRes()

	@ 000, 000 LISTBOX oListRes Fields HEADER "Tipo","Doc.","Pedido","Item","Produto","Qtde","Dt.Dispo.","Solicitante","Dt.Sol.","Hr.Sol." SIZE 299, 128 OF oPanel1 PIXEL ColSizes 50,50
	oListRes:SetArray(aListRes)
	oListRes:bLine := {|| {;
	aListRes[oListRes:nAt,1],;
	aListRes[oListRes:nAt,2],;
	aListRes[oListRes:nAt,3],;
	aListRes[oListRes:nAt,4],;
	aListRes[oListRes:nAt,5],;
	aListRes[oListRes:nAt,6],;
	aListRes[oListRes:nAt,7],;
	aListRes[oListRes:nAt,8],;
	aListRes[oListRes:nAt,9];
	}}
	// DoubleClick event
	oListRes:bLDblClick := {|| aListRes[oListRes:nAt,1] := !aListRes[oListRes:nAt,1],;
	oListRes:DrawSelect()}

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//CARREGAR DADOS DA LISTBOX
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
User Function FRTE02LO(_cProduto, _cPedido, _cItem, _cOpDoc,_cTipo, aListRes, _lTemp)
	Local cSQL
	Local aAux

	Default aListRes := {}
	Default _lTemp := .F.

	// Filtro implementado por Marcos Alberto em 01/04/15 conforme effettivo 1380-15
	If !cEmpAnt $ "06"

		//Carregar Dados
		cSQL := "select * from dbo.FNC_ROP_CONSULTA_RESERVA_"+AllTrim(CEMPANT)+"('"+XFilial("SC6")+"','"+_cProduto+"','"+_cPedido+"','"+_cItem+"','"+_cOpDoc+"','"+_cTipo+"')"

		If Select("QRY") > 0
			QRY->(DbCloseArea())
		EndIf

		TCQUERY CSQL ALIAS "QRY" NEW

		aRET := Array(4)

		While !QRY->(Eof())

			If _lTemp .Or. QRY->TEMP <> 'S'

				aAux := {}
				aAdd(aAux,QRY->TIPO)
				aAdd(aAux,QRY->DOC)
				aAdd(aAux,QRY->PEDIDO)
				aAdd(aAux,QRY->ITEM)
				aAdd(aAux,QRY->CODPRO)
				aAdd(aAux,QRY->QUANT)
				aAdd(aAux,QRY->DATADISP)
				aAdd(aAux,QRY->USUSOL)
				aAdd(aAux,QRY->DATASOL)
				aAdd(aAux,QRY->HORASOL)

				Aadd(aListRes,aAux)

			EndIf

			QRY->(DbSkip())
		EndDo

		QRY->(DbCloseArea())

	EndIf

Return(aListRes)

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//CARREGAR  RESERVAS TEMPORARIAS - USADO PARA VALIDACAO DA INCLUSAO DE PEDIDO
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
User Function FRTE02LT(_cProduto, _cItem, _cUsuTemp, _cEmpEst)
	Local cSQL
	Local aAux
	Local cAliasAux := GetNextAlias()
	Local aListAux := {}

	Default _cEmpEst := ""

	// Filtro implementado por Marcos Alberto em 01/04/15 conforme effettivo 1380-15
	If !cEmpAnt $ "06"

		//Carregar Dados

		If AllTrim(CEMPANT) == "07"
			cSQL := "select * from dbo.FNC_ROP_CONSULTA_RESERVA_TEMP_"+AllTrim(CEMPANT)+"('"+XFilial("SC6")+"','"+AllTrim(CEMPANT)+"','"+_cProduto+"','"+_cItem+"','"+_cUsuTemp+"','"+_cEmpEst+"')"
		Else
			cSQL := "select * from dbo.FNC_ROP_CONSULTA_RESERVA_TEMP_"+AllTrim(CEMPANT)+"('"+XFilial("SC6")+"','"+AllTrim(CEMPANT)+"','"+_cProduto+"','"+_cItem+"','"+_cUsuTemp+"')"
		EndIf

		TCQUERY CSQL ALIAS (cAliasAux) NEW

		aRET := Array(4)

		While !(cAliasAux)->(Eof())

			aAux := {}
			aAdd(aAux,(cAliasAux)->TIPO)
			aAdd(aAux,(cAliasAux)->DOC)
			aAdd(aAux,(cAliasAux)->PEDIDO)
			aAdd(aAux,(cAliasAux)->ITEM)
			aAdd(aAux,(cAliasAux)->CODPRO)
			aAdd(aAux,(cAliasAux)->QUANT)
			aAdd(aAux,(cAliasAux)->DATADISP)
			aAdd(aAux,(cAliasAux)->USUSOL)
			aAdd(aAux,(cAliasAux)->DATASOL)
			aAdd(aAux,(cAliasAux)->HORASOL)

			Aadd(aListAux,aAux)

			(cAliasAux)->(DbSkip())
		EndDo

		(cAliasAux)->(DbCloseArea())

	EndIf

Return(aListAux)


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Excluir Reservas com Autorizacao
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function DelReserv(nOpc,_cPedido)
	Local nRet
	Local cEmpDest := ""

	If nOpc == 1

		If !U_VALOPER("R01",.F.,.F.)
			U_FROPMSG("OP R01 - "+TIT_MSG, 	"Usu·rio sem acesso a esta OperaÁ„o.")
			Return(.F.)
		EndIf

		nRet := U_FROPMSG(TIT_MSG, 	"Tem certeza que deseja EXCLUIR as Reservas de ESTOQUE (SC0) apresentadas?"+CRLF+;
		"O pedido/item/produto permanecer· sem reserva e pode n„o ser atendido.";
		,{"N„o","Sim"},,"Confirme:")

		If nRet == 1
			Return(.F.)
		EndIf

		PZ4TIPOF3 := "P"

	ElseIf nOpc == 2

		If !U_VALOPER("R02",.F.,.F.)
			U_FROPMSG("OP R02 - "+TIT_MSG, 	"Usu·rio sem acesso a esta OperaÁ„o.")
			Return(.F.)
		EndIf

		nRet := U_FROPMSG(TIT_MSG, 	"Tem certeza que deseja EXCLUIR as Reservas de ORDEM DE PRODU«√O apresentadas?"+CRLF+;
		"O pedido/item/produto permanecer· sem reserva e pode n„o ser atendido.";
		,{"N„o","Sim"},,"Confirme:")

		If nRet == 1
			Return(.F.)
		EndIf

		PZ4TIPOF3 := "O"

	EndIf

	If !DelRPerg()
		Return(.F.)
	EndIf

	If cEmpAnt <> "07"
		If nOpc == 1
			U_BIAMsgRun("Aguarde... Excluindo Reservas.",,{|| U_FRDELRC1(aListRes, _CMOTEXC, cUserName)})
		Else
			U_BIAMsgRun("Aguarde... Excluindo Reservas.",,{|| U_FRDELRC2(aListRes, _CMOTEXC, cUserName)})
		EndIf
	Else
		//Procurando empresa destino do pedido para exclusao da reserva
		SC6->(DbSetOrder(1))
		If SC6->(DbSeek(XFilial("SC6")+_cPedido))

			cEmpDest := SC6->SC6_YEMPPED

		EndIf

		If !Empty(cEmpDest)

			If nOpc == 1
				bProcessa := {|| U_FROPCPRO(SubStr(cEmpDest,1,2),SubStr(cEmpDest,3,2),"U_FRDELRC1", aListRes, _CMOTEXC, cUserName)  }
				U_BIAMsgRun("Aguarde... Excluindo Reservas.",,bProcessa)
			Else
				bProcessa := {|| U_FROPCPRO(SubStr(cEmpDest,1,2),SubStr(cEmpDest,3,2),"U_FRDELRC2", aListRes, _CMOTEXC, cUserName)  }
				U_BIAMsgRun("Aguarde... Excluindo Reservas.",,bProcessa)
			EndIf

		Else
			U_FROPMSG(TIT_MSG, 	"Empresa Destino para RESERVA n„o configurada!")
		EndIf

	EndIf
Return(.T.)

User Function FRDELRC1(aListRes, _CMOTEXC, _cUSUARIO)
	Local I
	Local _cPedido, _cItem

	For I := 1 To Len(aListRes)

		//Apagar reservas de estoque SC0 se existir
		_cPedido	:= aListRes[I][3]
		_cItem		:= aListRes[I][4]

		SC0->(DbSetOrder(8))
		If SC0->(DbSeek(XFilial("SC0")+_cPedido+_cItem))
			While !SC0->(Eof()) .And. SC0->(C0_FILIAL+C0_YPEDIDO+C0_YITEMPV) == (XFilial("SC0")+_cPedido+_cItem)

				U_GravaPZ2(SC0->(RecNo()),"SC0",SC0->(C0_FILIAL+C0_NUM+C0_PRODUTO),"ALTPED",AllTrim(FunName()),_CMOTEXC, _cUSUARIO)

				//Marcar o item como NAO RESERVADO
				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(XFilial("SC6")+SC0->C0_YPEDIDO+SC0->C0_YITEMPV))
					RecLock("SC6",.F.)
					SC6->C6_YTPEST := "N"
					SC6->(MsUnlock())
				EndIf

				__cChaveSDC := SC0->(C0_FILIAL+C0_PRODUTO+C0_LOCAL+'SC0'+C0_NUM)

				a430Reserv({3,"VD","",cUserName,XFilial("SC0")},;
				SC0->C0_NUM,;
				SC0->C0_PRODUTO,;
				SC0->C0_LOCAL,;
				SC0->C0_QUANT,;
				{	SC0->C0_NUMLOTE,;
				SC0->C0_LOTECTL,;
				SC0->C0_LOCALIZ,;
				SC0->C0_NUMSERI})

				U_FRCHKSDC(__cChaveSDC, _cUSUARIO)

				SC0->(DbSkip())
			EndDo
		EndIf

	Next I

Return


User Function FRDELRC2(aListRes, _CMOTEXC, _cUsuario)
	Local I
	Local _cPedido, _cItem

	For I := 1 To Len(aListRes)

		//Apagar reservas de OP se existir
		_cPedido	:= aListRes[I][3]
		_cItem		:= aListRes[I][4]

		//Apagar reservas de OP se existir
		PZ0->(DbSetOrder(2))
		If PZ0->(DbSeek(XFilial("PZ0")+_cPedido+_cItem))
			While !PZ0->(Eof()) .And. AllTrim(PZ0->(PZ0_FILIAL+PZ0_PEDIDO+PZ0_ITEMPV)) == (XFilial("PZ0")+_cPedido+_cItem)

				U_GravaPZ2(PZ0->(RecNo()),"PZ0",PZ0->(PZ0_FILIAL+PZ0_PEDIDO+PZ0_ITEMPV),"ALTPED",AllTrim(FunName()),_CMOTEXC, _cUsuario)

				//Marcar o item como NAO RESERVADO
				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(XFilial("SC6")+PZ0->PZ0_PEDIDO+PZ0->PZ0_ITEMPV))
					RecLock("SC6",.F.)
					SC6->C6_YTPEST := "N"
					SC6->(MsUnlock())
				EndIf

				RecLock("PZ0",.F.)
				PZ0->(DbDelete())
				PZ0->(MsUnlock())

				PZ0->(DbSkip())
			EndDo
		EndIf

	Next I

Return


Static Function DelRPerg()
	Local aPergs := {}
	Local cCodMot := space(03)
	Local aRet := {""}
	Local lRet

	aAdd( aPergs ,{1,"CÛdigo do Motivo: ",cCodMot,"@!", "U_BIAF096(MV_PAR01)", "ZZ", ".T.",10,.T.})

	If ParamBox(aPergs ,"Motivo de Exclusao de Reservas",aRet,,,,,,,,.F.,.F.)
		_CMOTEXC := aRet[1]
		lRet := .T.
	Else
		lRet := .F.
	EndIf

Return lRet