#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MA120BUT
@author Tiago Rossini Coradini
@since 10/01/2017
@version 1.0
@description Adiciona botões no pedido de compras 
@obs Ponto de entrada
@type function
/*/  

User Function MA120BUT()
Local aButton := {}

	//Adiciona os botoes somente na rotina de Pedido de Compra e Autorizacao de Entrega
	If Alltrim(FunName()) == "MATA121" .Or. Alltrim(FunName()) == "MATA122"
	
		aAdd(aButton, {"EDITABLE", {|| U_IMP_ETI(1)}, "Imp Etiqueta"})
		//aAdd(aButton, {"EDITABLE", {|| U_IMP_ETI(2)}, "Imp Etiq Pedido"}) 15.10.2018 GABRIEL MAFIOLETTI - Retirado conforme alinhado com SidCley
		aAdd(aButton, {"EDITABLE", {|| U_BIAF091(SC7->C7_NUM, "M")}, "Envia E-mail"})
		aAdd(aButton, {"EDITABLE", {|| U_BIAF094()}, "Confirma Manual"})
		aAdd(aButton, {"EDITABLE", {|| U_BIAFR012()}, "Imp Ped Confirm"})
		aAdd(aButton, {"EDITABLE", {|| U_ATRA_FORN()}, "E-mail Follow Up"})
		aAdd(aButton, {"EDITABLE", {|| u_A130WEB()}, "Abrir Anexos"})
	EndIf

	aAdd(aButton, {"EDITABLE", {|| U_BIAF002("MATA121")}, "Hist. Preço"})
	aAdd(aButton, {"EDITABLE", {|| U_NOME_SOL()}, "Nome Solicitante"})
	
	If IsInCallStack("MATA094")
	
		aAdd(aButton, {"EDITABLE", {|| A94ExLiber(),U_M120SCGD()}, "Aprova"})
	
	EndIf

Return(aButton)