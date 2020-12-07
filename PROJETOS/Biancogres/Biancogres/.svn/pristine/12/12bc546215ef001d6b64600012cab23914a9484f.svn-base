#Include "Protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} BIA555
@description Controle de Classe de Valor por empresa
@author Marcos Alberto Soprani
@since 02/06/2015
@version undefined
@param gpOriCtrl, , descricao
@type function
/*/

User Function BIA555(gpOriCtrl)

	//Abre variáveis necessários para a verificação

	Local cEmpCLVL := cEmpAnt
	Local ksAreaAtu		:= GetArea()
	Local aAreaCTH		:= CTH->(GetArea())

	ksCLVL         := ""
	ksRetOkCV      := .T.
	// Determina diferentes origens p/ tratamentos complementares
	ksCtrlOri      := Alltrim(IIF(ParamIXB == Nil, "", ParamIXB))
	ksVlrDescInc   := 0

	//                          A empresa Consolidada aceita todos os lançamentos
	*****************************************************************************
	If cEmpCLVL $ "02/03/08/09/10/11/90/91"
		Return ( ksRetOkCV )
	EndIf

	//Projeto Faturamento Automatico - Ciclo do pedido - nao pode chamar dialogs de mensagens de validacao na contabilidade
	If IsInCallsTack("U_BACP0010")
		Return ( ksRetOkCV )
	EndIf	

	//  Controle de abertura para exceções - O Default é .F., caso seja .T. passa
	*****************************************************************************
	If GetMv("MV_YLBCLVL", , .F.)
		MsgBox("O parâmetro MV_YLBCLVL está LIBERADO permitindo que a digitação da Classe de Valor não passe pelo processo de validação. Caso permaneça assim é importante alinhar com a Contabilidade.","ATENÇÃO - Controle de Classe de Valor - DESATIVADO", "ALERT")
		Return ( ksRetOkCV )
	EndIf

	//     Aqui serão incrementadas gradualmente as regras de validação para CLVL
	*****************************************************************************

	//                                                           Estoque e Custos
	*****************************************************************************
	If Alltrim(__readvar) == "M->D1_CLVL"
		ksCLVL := M->D1_CLVL
	EndIf
	If Alltrim(__readvar) == "M->D2_CLVL"
		ksCLVL := M->D2_CLVL
	EndIf
	If Alltrim(__readvar) == "M->D3_CLVL"
		ksCLVL := M->D3_CLVL
	EndIf
	If Alltrim(__readvar) == "M->ZI_CLVL"
		ksCLVL   := M->ZI_CLVL
	EndIf
	If Alltrim(__readvar) == "aCV[1][2]"
		ksCLVL := aCV[1][2]
	EndIf

	//                                                                Faturamento
	*****************************************************************************
	If Alltrim(__readvar) == "M->C5_YCLVL"
		ksCLVL       := M->C5_YCLVL
		ksCtrlOri    := "SC5PDV"
	EndIf
	If ksCtrlOri == "SC5TOK1"
		ksCLVL       := M->C5_YCLVL
		ksVlrDescInc := nDescInc
	EndIf

	//                                                                    Compras
	*****************************************************************************
	If Alltrim(__readvar) == "M->C1_CLVL"
		ksCLVL := M->C1_CLVL
	EndIf
	If ksCtrlOri == "SC1LOK1"
		ksCLVL := rtCLVL
	EndIf
	If Alltrim(__readvar) == "M->C3_YCLVL"
		ksCLVL := M->C3_YCLVL
	EndIf
	If Alltrim(__readvar) == "M->C7_CLVL"
		ksCLVL := M->C7_CLVL
	EndIf
	If ksCtrlOri == "SC7LOK1"
		ksCLVL := wCLVL
	EndIf
	If Alltrim(__readvar) == "M->C8_CLVL"
		ksCLVL := M->C8_CLVL
	EndIf
	
	If Alltrim(__readvar) == "M->WD_YCLVL"
		ksCLVL := M->WD_YCLVL
	EndIf

	//                                                                        EIC
	*****************************************************************************
	If Alltrim(__readvar) == "M->W2_YCLVL"
		ksCLVL := M->W2_YCLVL
	EndIf

	//                                                                 Financeiro
	*****************************************************************************
	If Alltrim(__readvar) == "M->E1_CLVLDB"
		ksCLVL := M->E1_CLVLDB
	EndIf
	If Alltrim(__readvar) == "M->E1_CLVLCR"
		ksCLVL := M->E1_CLVLCR
	EndIf
	If Alltrim(__readvar) == "M->E2_CLVLDB"
		ksCLVL := M->E2_CLVLDB
	EndIf
	If Alltrim(__readvar) == "M->E2_CLVLCR"
		ksCLVL := M->E2_CLVLCR
	EndIf

	If Alltrim(__readvar) == "M->E2_CLVL"
		ksCLVL := M->E2_CLVL
	EndIf	
	
	If Alltrim(__readvar) == "M->E3_CLVLDB"
		ksCLVL := M->E3_CLVLDB
	EndIf
	If Alltrim(__readvar) == "M->E3_CLVLCR"
		ksCLVL := M->E3_CLVLCR
	EndIf
	If Alltrim(__readvar) == "M->E5_CLVLDB"
		ksCLVL := M->E5_CLVLDB
	EndIf
	If Alltrim(__readvar) == "M->E5_CLVLCR"
		ksCLVL := M->E5_CLVLCR
	EndIf

	If ALLTRIM(__READVAR) = 'M->ZL0_CLVLDB'
		ksCLVL := M->ZL0_CLVLDB
	EndIf

	//                                                                   Produção
	*****************************************************************************
	If Alltrim(__readvar) == "M->C2_CLVL"
		ksCLVL := M->C2_CLVL
	EndIf

	//                                                           Folha de Pessoal
	*****************************************************************************
	If Alltrim(__readvar) == "M->RC_CLVL"
		ksCLVL := M->RC_CLVL
	EndIf
	If Alltrim(__readvar) == "M->RA_CLVL"
		ksCLVL := M->RA_CLVL
	EndIf

	//                                                              Contabilidade
	*****************************************************************************
	If Alltrim(__readvar) == "M->CT2_CLVLDB"
		ksCLVL := M->CT2_CLVLDB
	EndIf
	If Alltrim(__readvar) == "M->CT2_CLVLCR"
		ksCLVL := M->CT2_CLVLCR
	EndIf
	If ksCtrlOri == "CT2CTB1"
		If !Empty(cCVdeb)
			ksCLVL := cCVdeb
		ElseIf !Empty(cCVcred)
			ksCLVL := cCVcred
		EndIf
	EndIf
	If Alltrim(__readvar) == "M->ZBZ_CLVLDB"
		ksCLVL := M->ZBZ_CLVLDB
	EndIf
	If Alltrim(__readvar) == "M->ZBZ_CLVLCR"
		ksCLVL := M->ZBZ_CLVLCR
	EndIf

	//               Neste ponto o sistema verifica a classe de valor e a empresa
	*****************************************************************************
	dbSelectArea("CTH")
	dbSetOrder(1)
	//  Ranisses em 15/06/15, pois estava bloqueando nas tela RECEPÇÃO BANCÁRIA,
	// onde não é feito a digitação de CLASSE DE VALOR
	//PONTIN - Validação desativado para o projeto de consolidação de empresas
	//LUANA - Definindo que classes de valor cadastradas na empresa Incesa, sejam vistas como sendo da Biancogres
	If !Empty(Alltrim(ksCLVL))
		If dbSeek(xFilial("CTH")+ksCLVL)
			If cEmpCLVL <> Substr(CTH->CTH_YEMPFL,1,2)
				ksRetOkCV   := .F.
			EndIf
		EndIf
	EndIf


	//            Área reservada para controles adicionais de validações diversas
	*****************************************************************************
	If ksRetOkCV
		If ksCtrlOri $ "SC5PDV/SC5TOK1"
			If !(M->C5_YSUBTP) $ "A /B /D /F /G /M /O " .and. !Empty(ksCLVL)
				// Tratamento implementado me 29/09/15 para controle de desconto incondicional
				// - tem que informar classe de valor. Por Marcos Alberto Soprani.
				If ksVlrDescInc == 0
					ksRetOkCV   := .F.
				EndIf
			EndIf
		EndIf
		If ksCtrlOri $ "SC5TOK1"
			// Tratamento implantado para obrigar a digitação da classe de valor para tipos específicos de pedido.
			// por Marcos Alberto Soprani em 21/12/15. OS effettivo: 3122-15
			If M->C5_YSUBTP $ "A /B /D /F /G /M /O " .and. Empty(ksCLVL)
				ksRetOkCV   := .F.
			EndIf
		EndIf
	EndIf

	If ksRetOkCV

		If ksCtrlOri == "CT2CTB1"

			ksDebit := Substr(cDebito , 1, 1)
			ksCredt := Substr(cCredito, 1, 1)
			// Tratamento implementado por Marcos Alberto Soprani em 08/04/16, conforme detalhado
			ksCVDeb := U_B478RTCC(cCVdeb)[2]
			ksCVCrd := U_B478RTCC(cCVcred)[2]

			// Conta de custo só pode estar associada a clvl industrial
			If ( ksDebit == "6" .and. ksCVDeb <> "C" ) .or. ( ksCredt == "6" .and. ksCVCrd <> "C" )
				ksRetOkCV   := .F.
			EndIf

			// Conta de despesa só pode estar associada a clvl adm, comercial, diretoria, industrial
			If ( ksDebit == "3" .and. ksCVDeb <> "D" ) .or. ( ksCredt == "3" .and. ksCVCrd <> "D" )
				ksRetOkCV   := .F.
			EndIf

			// Conta de investimento do podem estar asssociadas a classe de Valor A/I
			If ( Alltrim(ksCVDeb) $ "A/I" .and. Substr(cDebito , 1, 5) <> "16503" ) .or. ( Alltrim(ksCVCrd) $ "A/I" .and. Substr(cCredito , 1, 5) <> "16503" )
				ksRetOkCV   := .F.
			EndIf

		EndIf

	EndIf

	//                                                             Mensagem Final
	*****************************************************************************
	If !ksRetOkCV
		Conout("BIA555 -> TESTES -> Controle de Classe de Valor (1) ("+Time()+")")
		MsgBox("A Classe de valor que se pretende utilizar não pode ser usada para a empresa atual; ou, alguma outra regra está impedindo de usuar esta classe de valor..."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+" Favor verificar com a contabilidade!!!", "Controle de Classe de Valor [BIA555]", "ALERT")
	EndIf

	RestArea(aAreaCTH)
	RestArea(ksAreaAtu)

Return ( ksRetOkCV )
