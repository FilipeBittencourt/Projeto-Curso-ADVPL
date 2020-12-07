#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FPFCRT01
@author Fernando Rocha
@since 27/07/2017
@version 1.0
@description Funcao para envio de e-mail de aprovação de pedidos de compra
@type class
/*/
User Function FPFCRT01(cNumPed)

	Local aArea := GetArea()
	Local aAreaC7 := SC7->(GetArea())
	Local aAreaAK := SAK->(GetArea())

	Local oAprPed := TAprovaPedidoCompraEMail():New()
	Local __cAprTmp

	SC7->(DbSetOrder(1))
	If SC7->(DbSeek(xFilial("SC7") + cNumPed)) .And. SC7->C7_CONAPRO == "B"

		oAprPed:cNumPed := cNumPed

		SCR->(DbSetOrder(1))  //CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL, R_E_C_N_O_, D_E_L_E_T_

		IF SCR->(DbSeek(XFilial("SCR")+"PC"+cNumPed))

			SAK->(DbSetOrder(2))  //AK_FILIAL, AK_USER, R_E_C_N_O_, D_E_L_E_T_

			If SAK->(DbSeek(XFilial("SAK")+SCR->CR_USER))

				oAprPed:cCodApr := SAK->AK_USER

				//POR ENQUANTO IGNORAR APROVADOR TEMPORARIO - REGRA NAO ESTA DEFINIDA
				//__cAprTmp := SAK->AK_APROSUP
				//If !Empty(__cAprTmp) .And. SAK->(DbSeek(XFilial("SAK")+__cAprTmp))
				//	oAprPed:cCodAprT := SAK->AK_USER
				//EndIf

				oAprPed:Envia()

			EndIf

		ENDIF

	EndIf

	RestArea(aArea)
	RestArea(aAreaC7)
	RestArea(aAreaAK)

Return


/*/{Protheus.doc} FPFCRT02
@author Fernadno Rocha
@since 27/07/2017
@version 1.0
@description Funcao para envio de e-mail de aprovação de pre nota de servico
@type class
/*/
User Function FPFCRT02(cDoc, cSerie, cCliFor, cLoja)

	Local aArea := GetArea()
	Local aAreaC7 := SC7->(GetArea())
	Local aAreaAK := SAK->(GetArea())
	Local aAreaD1 := SD1->(GetArea())

	Local oAprPed := TAprovaPreNotaEMail():New()
	Local __cAprTmp

	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(xFilial("SC7") + cDoc + cSerie + cCliFor + cLoja))

		oAprPed:cDoc 	:= cDoc
		oAprPed:cSerie 	:= cSerie
		oAprPed:cCliFor	:= cCliFor
		oAprPed:cLoja	:= cLoja

		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(xFilial("SC7") + SD1->D1_PEDIDO))

			oAprPed:cNumPed := SD1->D1_PEDIDO

			SAK->(DbSetOrder(1))
			If SAK->(DbSeek(XFilial("SAK")+SC7->C7_APROV))

				oAprPed:cCodApr := SAK->AK_USER

				__cAprTmp := SAK->AK_APROSUP

				If !Empty(__cAprTmp) .And. SAK->(DbSeek(XFilial("SAK")+__cAprTmp))

					oAprPed:cCodAprT := SAK->AK_USER

				EndIf

				oAprPed:Envia()

			EndIf

		EndIf

	EndIf

	RestArea(aArea)
	RestArea(aAreaC7)
	RestArea(aAreaAK)
	RestArea(aAreaD1)

Return

/*/{Protheus.doc} FPFCRT04
@description JOB RECEBIMENTO DE RESPOSTS DE E_MAILS DE APROVACAO DE PEDIDO DE COMPRAS
@author Fernando Rocha
@since 20/07/2018
@version 1.0
@type function
/*/
User Function FPFCRT03()

	RpcSetType(3)
	RpcSetEnv("01", "01")

	oMail := TAprovaPedidoCompraEMail():New()
	oMail:Recebe()

	RpcClearEnv()

Return

//teste de envio de email
/*
User Function PABEMAIL()

	RpcSetType(3)
	RpcSetEnv("01", "01")

	//oMail := TAprovaPedidoCompraEMail():New()
	//oMail:cNumPed := 'PAPCMS' //'PAOYH1'	'PAOYD8' //'PAOYD0', 'PAOYBP' //exemplo2 P82740 tem classe de valor, contrato e mais de um solicitante
	//oMail:Envia()
	
	oMail := TPedidoCompraEmail():New()
	oMail:cNumPed := 'PAOZE0' //possui despesa
	oMail:cCodFor := '008911'
	oMail:cLojFor := '01'
	oMail:EnviaFor()

	RpcClearEnv()

Return
*/

/*/{Protheus.doc} FPFCRT04
@description JOB SEMANAL ENVIA LISTA DE TODOS OS PEDIDOS DE COMPRAS PENDENTES DE APROVAÇÃO
@author ferna
@since 20/07/2018
@version 1.0
@type function
/*/
User Function FPFCRT04()

	Local nI
	Local xv_Emps    := U_BAGtEmpr("01_05")

	//REPLICAR PEDIDOS PENDENTES DA LM PARA ORIGEM
	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2])

		If !ZC1->(FieldPos("ZC1_TIPDOC")) > 0
			loop
		EndIf

		//Gera o html do WF.
		Processa({|| Rt04Processa()})

		RpcClearEnv()
	Next nI

Return

Static Function Rt04Processa()

	oMail := TAprovaPedidoCompraEMail():New()
	oMail:EnviaPendentes()

Return



//FUNCOES DE TESTES
User Function FPFCTST(_CPC)

	U_FPFCRT01(_CPC)	

Return

User Function FPFCTST2()

	oMail := TAprovaPedidoCompraEMail():New()
	oMail:Recebe()

Return

User Function FPFCTST3()

	U_FPFCRT02('000060035', '1  ', '011576', '01')

Return

User Function FPFCTST4()

	oMail := TAprovaPreNotaEMail():New()
	oMail:Recebe()

Return

User Function FPFCTST5()

	oMail := TAprovaPedidoCompraEMail():New()
	oMail:EnviaPendentes()

Return


User Function FPFCTST6()

	Local _cIDMSG := "AC1252200ED32AE85E17E45AFEE96EAF"
	Local _cACTION := "APROVA"
	
	RpcSetType(3)
	RpcSetEnv("01", "01")

	oMail := TAprovaPedidoCompraEMail():New()
	oMail:RecebeManual(_cIDMSG, _cACTION)

Return
