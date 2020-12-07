#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF020
@author Tiago Rossini Coradini
@since 28/03/2019
@project Automação Financeira
@version 1.0
@description Rotina de deposito identificado
@type function
/*/

User Function BAF020()
Local aCores := {}
Private aRotina := {}
Private cCadastro := "Deposito Identificado"
Private cAlias := "ZK8"

	aAdd(aCores, {"ZK8_STATUS == 'A'", "BR_VERDE"})
	aAdd(aCores, {"ZK8_STATUS == 'B'", "BR_VERMELHO"})
	aAdd(aCores, {"ZK8_STATUS == 'C'", "BR_PRETO"})

	aAdd(aRotina, {"Pesquisar" , "PesqBrw", 0, 1})
	aAdd(aRotina, {"Visualizar", "U_BAF020A", 0, 2})
	aAdd(aRotina, {"Incluir", "U_BAF020A", 0, 3})
	aAdd(aRotina, {"Alterar", "U_BAF020A", 0, 4})
	aAdd(aRotina, {"Excluir", "U_BAF020A", 0, 5})
	aAdd(aRotina, {"Imprimir", "U_BAF020A", 0, 6})
	aAdd(aRotina, {"Legenda", "U_BAF020A", 0, 7})	
	                                               
	DbSelectArea(cAlias)
	DbSetOrder(1)

	mBrowse(,,,,cAlias,,,,,,aCores)

Return()


User Function BAF020A(cAlias, nRecno, nOpc)
Local oObj := TWAFDepositoIdentificado():New()
Local oParam := TParBAF020():New()

	If fVldOpc(nOpc)
		
		If nOpc == 3 .And. oParam:Box()
											
			oObj:nFDOpc := nOpc
			
			oObj:cGrpCli := oParam:cGrpCli
			oObj:cCodCli := oParam:cCodCli
			oObj:dVenctoDe := oParam:dVenctoDe
			oObj:dVenctoAte := oParam:dVenctoAte
			oObj:dDeposito := oParam:dDeposito
			
			oObj:Activate()				
							
		ElseIf nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5 
	
			oObj:nFDOpc := nOpc					

			oObj:cGrpCli := ZK8->ZK8_GRPVEN
			oObj:cCodCli := ZK8->ZK8_CODCLI
			oObj:dVenctoDe := ZK8->ZK8_VENCDE
			oObj:dVenctoAte := ZK8->ZK8_VENCAT
			oObj:dDeposito := ZK8->ZK8_DATDPI
			
			oObj:Activate()
				
		ElseIf nOpc == 6
		
			U_BAF020R()
		
		ElseIf nOpc == 7
		
			fLegenda()	
			
		EndIf
		
	EndIf
									
Return()


Static Function fVldOpc(nOpc)
Local lRet := .T.

	If ((nOpc == 4 .Or. nOpc == 5) .And. ZK8->ZK8_STATUS $ "B|C")
	
		lRet := .F.
		
		MsgStop("Atenção, opção não permitida para depósitos identificados baixados.")
			
	EndIf

Return(lRet)


Static Function fLegenda()
Local aLeg := {}

	aAdd(aLeg, {"BR_VERDE", "Em Aberto"})
	aAdd(aLeg, {"BR_VERMELHO", "Baixado"})
	aAdd(aLeg, {"BR_PRETO", "Cancelado"})
	
	BrwLegenda(cCadastro, "Legenda", aLeg)

Return()