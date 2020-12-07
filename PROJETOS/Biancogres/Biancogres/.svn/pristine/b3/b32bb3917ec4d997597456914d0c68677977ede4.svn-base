#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TContratoParceria
@author Tiago Rossini Coradini
@since 10/08/2019
@version 1.0
@description Classe para controle de contratos de parceria
@obs Ticket: 17900
@type class
/*/

Class TContratoParceria From LongClassName

	Data cNumero // Numero do contrato para pesquisa
	Data cContrato // Contrato retornado
	Data nValor // Valor do contrato
	Data nPedAbe // Valor de pedidos em aberto
	Data nTitAbe // Valor de titulos a pagar
	Data nTitPag // Valor de titulos pagos
	Data nTitAnt // Valor de titulos antecipados nao compensados
	Data nPreReq // Valor de pre requisições	
	Data nTitDev // Valor de titulos devolucao
	Data nSaldo // Saldo do contrato	
			
	Method New(cNumero) Constructor
	Method Get()
	Method Validate(cNumero, dDtVig)
	
EndClass


Method New(cNumero) Class TContratoParceria	

	Default cNumero := ""

	::cNumero := cNumero
	::cContrato := ""
	::nValor := 0
	::nPedAbe := 0
	::nTitAbe := 0
	::nTitPag := 0
	::nTitAnt := 0
	::nPreReq := 0
	::nTitDev := 0
	::nSaldo := 0
								
Return()


Method Get() Class TContratoParceria
Local cSQL := ""
Local cQry := GetNextAlias()
Local aArea := GetArea()

	cSQL := " SELECT * " 
	cSQL += " FROM FNC_CTR_SALDO(" + ValToSQL(::cNumero) + ")"
			
	TcQuery cSQL New Alias (cQry)
	
	::cContrato := (cQry)->CONTRATO
	::nValor := (cQry)->VALOR
	::nPedAbe := (cQry)->VLR_PC
	::nTitAbe := (cQry)->VLR_ABE
	::nTitPag := (cQry)->VLR_PAG
	::nTitAnt := (cQry)->VLR_PA
	::nPreReq := (cQry)->VLR_REQ
	::nTitDev := (cQry)->VLR_DEV
	::nSaldo := (cQry)->SALDO

	(cQry)->(DbCloseArea())	
	
	RestArea(aArea)	

Return()


Method Validate(cNumero, dDtVig) Class TContratoParceria
Local lRet := .T.

	Default dDtVig := dDataBase

	DbSelectArea("SC3")
	DbSetOrder(1)
	If DbSeek(xFilial("SC3") + cNumero)

		If SC3->C3_MSBLQL == "1"
			
			MsgAlert("Atenção, o pedido de compra não poderá ser liberado, pois o contrato está bloqueado.")
			
			lRet := .F.
		
		ElseIf dDtVig < SC3->C3_DATPRI .Or. dDtVig > SC3->C3_DATPRF
	
			MsgAlert("Atenção, o pedido de compra não poderá ser liberado, pois o contrato está fora da vigência.")
			
			lRet := .F.
				
		EndIf
	
	EndIf
	
Return(lRet)