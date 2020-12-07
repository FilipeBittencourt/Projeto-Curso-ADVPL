#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FROPRT05	ºAutor  ³Fernando Rocha      º Data ³ 22/12/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gerar reserva para pedidos nao reservados				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

User Function FROPRT05(lAuto)
	Local aArea := GetArea()
	Local nRet
	Local cTexto := ""
	Local _cTpNRes := GetNewPar("FA_TPNRES","A #RI#")
	Local aRetPed
	Local nQtdPed

	Default lAuto := .T. 

	If !(AllTrim(CUSERNAME) == "FACILE")
		U_FROPMSG(TIT_MSG, 	"Rotina bloqueada para uso, usar o processo de reserva manual no modo ALTERAR do pedido",{"Ok"},,"ROTINA BLOQUEADA")
		Return
	EndIf

	If !lAuto

		IF (SC5->C5_YSUBTP $ _cTpNRes)
			U_FROPMSG(TIT_MSG, 	"Não é possível gerar reservas para esse tipo de pedido",{"Ok"},,"C5_YSUBTP: Tipo Inválido")
			RestArea(aArea)
			Return
		Else
			nRet := U_FROPMSG(TIT_MSG, 	"Tem certeza que deseja GERAR RESERVAS para o pedido selecionado?",{"Não","Sim"},,"Confirme:")
		EndIf

		If nRet == 2

			U_BIAMsgRun("Aguarde... Processando Reservas.",,{|| cTexto := XProc(SC5->C5_NUM) })

			If !Empty(cTexto)
				U_FROPMSG(TIT_MSG, cTexto, {"Ok"}, , "Erros encontrados na reserva do pedido:")
			Else
				U_FROPMSG(TIT_MSG, "RESERVAS EFETIVADAS COM SUCESSO", {"Ok"}, , "Processamento OK")
			EndIf

		EndIf

	Else

		nQtdPed := AutoPerg()

		U_BIAMsgRun("Aguarde, processando pedidos...",, {|| aRetPed := XProcAuto(nQtdPed) })
		If Len(aRetPed) > 0
			F_EXCEL(aRetPed)
		Else
			U_FROPMSG(TIT_MSG, cTexto, {"Ok"}, , "Nenhum pedido pendente a ser processado!")
		EndIf

	EndIf

	RestArea(aArea)
Return


Static Function AutoPerg()
	Local aPergs := {}
	Local nQtdPed := 0
	Local aRet := {""}
	Local nRet

	aAdd( aPergs ,{1,"Quantos Pedidos/Itens",nQtdPed,"@R 9999",'.T.',"ZZ",'.T.',10,.T.})

	If ParamBox(aPergs ,"Processamento de pedidos pendentes",aRet)
		nRet := aRet[1]
	Else
		nRet := 0
	EndIf

Return nRet


Static Function XProcAuto(nQtdPed)
	Local cAliasTmp
	Local cAliasAux
	Local aRetPed := {}
	Local cExp
	Local cTexto := ""

	cExp := "% "+Alltrim(Str(Int(nQtdPed),0,0))+" %"

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NOPARSER%

		SELECT TOP %EXP:cExp%
		C5_EMISSAO, C5_NUM, C6_ITEM, C6_PRODUTO, C6_ENTREG, C6_QTDVEN

		FROM %TABLE:SC5% SC5
		JOIN %TABLE:SC6% SC6 ON C6_FILIAL = C5_FILIAL AND C5_NUM = C6_NUM
		JOIN %TABLE:SB1% SB1 ON B1_FILIAL = '  ' AND B1_COD = C6_PRODUTO
		left join %TABLE:SC0% SC0 (nolock) on C0_FILIAL = '01' and C6_NUM = C0_YPEDIDO and C6_ITEM = C0_YITEMPV and C6_PRODUTO = C0_PRODUTO and SC0.D_E_L_E_T_ = ''
		left join %TABLE:PZ0% PZ0 (nolock) on PZ0_FILIAL = '01' and C6_NUM = PZ0_PEDIDO and C6_ITEM = PZ0_ITEMPV and C6_PRODUTO = PZ0_CODPRO and PZ0.D_E_L_E_T_ = ''


		WHERE
		C5_FILIAL = %XFILIAL:SC5%
		AND C5_NOTA = ''
		AND C5_YSUBTP NOT IN ('A','RI')
		AND C5_EMISSAO >= '20140101'
		AND C6_NOTA = ''
		AND C6_BLQ <> 'R'
		AND B1_TIPO = 'PA'
		and C0_PRODUTO is null
		and PZ0_CODPRO is null
		and ROUND((C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from SC9050 SC9 (nolock) where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.D_E_L_E_T_=''),0)),2) > 0
		AND SC5.D_E_L_E_T_=' '
		AND SC6.D_E_L_E_T_=' '
		AND SB1.D_E_L_E_T_=' '

		ORDER BY 2,3,4

	EndSql

	aRetPed := {}
	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		__cPEDIDO := (cAliasTmp)->C5_NUM
		__cITEM := (cAliasTmp)->C6_ITEM
		__cPRODUTO := (cAliasTmp)->C6_PRODUTO

		aListRes := U_FRTE02LO("", __cPEDIDO, __cITEM, "", "")
		If Len(aListRes) > 0
			cTexto := "ITEM: "+__cITEM+" - Já existe reserva."
			AAdd(aRetPed,{__cPEDIDO,__cITEM,__cPRODUTO,"ERRO",cTexto})

			(cAliasTmp)->(DbSkip())
			loop
		EndIf

		cAliasAux := GetNextAlias()
		BeginSql Alias cAliasAux
			%NOPARSER%

			select SALDO = C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from %Table:SC9% SC9 where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.%NotDel%),0)
			from %Table:SC6% SC6 where C6_FILIAL = %XFILIAL:SC6% and C6_NUM = %EXP:__cPEDIDO% and C6_ITEM = %EXP:__cITEM% and SC6.%NotDel%

		EndSql

		If !(cAliasAux)->(Eof()) .And. (cAliasAux)->SALDO > 0

			SC5->(DbSetOrder(1))
			SC5->(DbSeek(XFilial("SC5")+__cPEDIDO))
			SC6->(DbSetOrder(1))
			SC6->(DbSeek(XFilial("SC6")+__cPEDIDO+__cITEM))

			aRet := XPrcItPv((cAliasAux)->SALDO)

			If !aRet[1]

				cTexto := "ITEM: "+SC6->C6_ITEM+" - Erro: "+aRet[2]
				AAdd(aRetPed,{__cPEDIDO,__cITEM,__cPRODUTO,"ERRO",cTexto})

			Else

				AAdd(aRetPed,{__cPEDIDO,__cITEM,__cPRODUTO,"OK","Reserva efetuada com sucesso!"})

			EndIf

		Else

			cTexto := "ITEM: "+SC6->C6_ITEM+" - Estoque já empenhado."
			AAdd(aRetPed,{__cPEDIDO,__cITEM,__cPRODUTO,"ERRO",cTexto})

		EndIf
		(cAliasAux)->(DbCloseArea())

		(cAliasTmp)->(DbSkip())
	EndDo

Return(aRetPed)


Static Function XProc(cPedido)
	Local aRet
	Local cTexto := ""
	Local aListRes
	Local cAliasTmp

	If SC6->(DbSeek(XFilial("SC6")+cPedido))

		While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == (XFilial("SC6")+cPedido)

			If (AllTrim(SC6->C6_BLQ) == "R")
				cTexto += "ITEM: "+SC6->C6_ITEM+" - Resíduo Eliminado."+CRLF

				SC6->(DbSkip())
				loop
			EndIf

			aListRes := U_FRTE02LO("", cPedido, SC6->C6_ITEM, "", "")
			If Len(aListRes) > 0
				cTexto += "ITEM: "+SC6->C6_ITEM+" - Já existe reserva."+CRLF

				SC6->(DbSkip())
				loop
			EndIf

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				%NOPARSER%

				select SALDO = C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from %Table:SC9% SC9 where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.%NotDel%),0)
				from %Table:SC6% SC6 where C6_FILIAL = %XFILIAL:SC6% and C6_NUM = %EXP:SC6->C6_NUM% and C6_ITEM = %EXP:SC6->C6_ITEM% and SC6.%NotDel%

			EndSql

			If !(cAliasTmp)->(Eof()) .And. (cAliasTmp)->SALDO > 0

				aRet := XPrcItPv((cAliasTmp)->SALDO)

				If !aRet[1]

					cTexto += "ITEM: "+SC6->C6_ITEM+" - Erro: "+aRet[2]+CRLF

				Else

					cTexto += "ITEM: "+SC6->C6_ITEM+" - Reserva efetuada com sucesso!"+CRLF

				EndIf

			Else

				cTexto += "ITEM: "+SC6->C6_ITEM+" - Estoque já empenhado."+CRLF

			EndIf
			(cAliasTmp)->(DbCloseArea())

			SC6->(DbSkip())
		EndDo

	EndIf

Return(cTexto)

Static Function XPrcItPv(_NSALDO)
	Local aArea := GetArea()
	Local cMVPAR01 := MV_PAR01

	Local _cTipo
	Local _lOk		:= .F.
	Local _cProd 	:= SC6->C6_PRODUTO
	Local _cLocal 	:= SC6->C6_LOCAL
	Local _nPTPEST 	:= SC6->C6_YTPEST
	Local _nPENTREG	:= SC6->C6_ENTREG
	Local _nPNECESS	:= SC6->C6_YDTNECE
	Local _nPLOTE	:= SC6->C6_LOTECTL
	Local _nPMOTFR	:= SC6->C6_YMOTFRA
	Local _nQtdDig 	:= _NSALDO
	Local _cItem 	:= SC6->C6_ITEM
	Local _nPrcVen 	:= SC6->C6_PRCVEN
	Local _nPTotal	:= SC6->C6_VALOR

	Local _nQtdRet	:= 0
	Local _aRetOP
	Local _lAchouOPE := .F.
	Local _cSegmento := "R"
	Local _aRetLot
	Local _nRet	:= 0

	//Parametros para pergunta do motivo do lote
	Local aPergs := {}
	Local cCodMot := space(03)
	Local aRet := {""}
	Local _cRestri := ""

	//Parametro para Filtrar tipo de pedido que não entram na regra do projeto reserva/pesquisa de lote
	Local _cTpNPLot := GetNewPar("FA_TPNLOT","A#M#G#B")

	Local _aRetProc 

	//Posiciona Pedido
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(XFilial("SC5")+SC6->C6_NUM))

	//Tratamento outro produtos
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProd)) .And. SB1->B1_TIPO <> "PA"
		_aRetProc := {".F.","Produto diferente de PA"}
		RestArea(aArea)
		Return(_aRetProc)
	EndIf

	//Verificando Segmento do Cliente
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(XFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
		_cSegmento := AllTrim(SA1->A1_YTPSEG)
	EndIf

	If (_cSegmento == "E" .And. Empty(_nPNECESS))
		_aRetProc := {.F.,"ENGENHARIA sem Dt.Necessidade preenchida"}
		RestArea(aArea)
		Return(_aRetProc)
	EndIf

	//Posicionar Produto
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_cProd))

	If SC6->C6_YTPEST == "E"

		aRet := U_FRRT02IR(SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO, SC6->C6_LOCAL, _nQtdDig, SC5->C5_VEND1, SC6->C6_LOTECTL,,SC5->C5_YDIGP, .T., "NRE", SC5->C5_YSUBTP)
		//se reservou estoque com sucesso apaga a reserva de OP
		If Len(aRet[2]) > 0

			_aRetProc := {.T.,""} 
			Return(_aRetProc)

		EndIf	

	Else

		_aRetProc := {.F.,"Tipo de reserva invalido"} 
		Return(_aRetProc)

	EndIf

	RestArea(aArea)
	_aRetProc := {.F.,"Tipo Invalido/Sem Estoque"}
Return(_aRetProc)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCAO PARA RETORNAR O RELATORIO DO PROCESSAMENTO EM EXCEL
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function F_EXCEL(aRetPed)

	U_BIAMsgRun("Aguarde, gerando planilha...",, {|| ProcExcel(aRetPed)  })

Return

Static Function ProcExcel(aRetPed)

	Local aArea := GetArea()
	Local oFWExcel := Nil
	Local oMsExcel := Nil
	Local cDir := GetSrvProfString("Startpath", "")
	Local cFile := "RESERVAS_PEDIDO_EXCEL-"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
	Local cWorkSheet := ""
	Local cTable := ""
	Local cDirTmp := AllTrim(GetTempPath())
	Local cAliasTab
	Local I 

	cWorkSheet := "Processamento de Reservas de pedidos pendentes"
	cTable := cWorkSheet + " - Data: "+DTOC(dDataBase)+" - Hora: "+SubStr(Time(),1,5)

	oFWExcel := FWMsExcel():New()
	oFWExcel:AddWorkSheet(cWorkSheet)
	oFWExcel:AddTable(cWorkSheet, cTable)

	oFWExcel:AddColumn(cWorkSheet, cTable, "Emissao", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Cliente", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Pedido", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Item", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Produto", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Descricao", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Quantidade", 1, 2)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Dt.Necessidade", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Lote", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Status", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Texto", 1, 1)

	SC6->(DbSetOrder(1))
	FOR I := 1 To Len(aRetPed)

		SC6->(DbSeek(XFilial("SC6")+aRetPed[I][1]+aRetPed[I][2]))

		aAux := {}
		AAdd(aAux, DTOC(SC6->C6_YEMISSA))
		AAdd(aAux, SC6->C6_CLI)
		AAdd(aAux, aRetPed[I][1])
		AAdd(aAux, aRetPed[I][2])
		AAdd(aAux, aRetPed[I][3])
		AAdd(aAux, SC6->C6_DESCRI)
		AAdd(aAux, SC6->C6_QTDVEN)
		AAdd(aAux, DTOC(SC6->C6_YDTNECE))
		AAdd(aAux, SC6->C6_LOTECTL)
		AAdd(aAux, aRetPed[I][4])
		AAdd(aAux, aRetPed[I][5])

		oFWExcel:AddRow(cWorkSheet, cTable,	aAux)

	NEXT I

	oFWExcel:Activate()
	oFWExcel:GetXMLFile(cFile)
	oFWExcel:DeActivate()

	If CpyS2T(cDir + cFile, cDirTmp, .T.)

		fErase(cDir + cFile)

		If ApOleClient('MsExcel')

			oMSExcel := MsExcel():New()
			oMSExcel:WorkBooks:Close()
			oMSExcel:WorkBooks:Open(cDirTmp + cFile)
			oMSExcel:SetVisible(.T.)
			oMSExcel:Destroy()

		EndIf

	Else
		MsgInfo("Arquivo não copiado para a pasta temporária do usuário.")
	Endif

	RestArea(aArea)
Return(cDir + cFile)
