#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF082
@author Tiago Rossini Coradini
@since 20/07/2017
@version 1.0
@description Rotina para inclusao do bloqueio comercial do pedido de venda
@obs OS: 4538-16 - Claudeir Fadini
@type function
/*/


User Function BIAF082(cNumPed)
	
	Local aArea		:= GetArea()
	Local oBlqCom	:= TBloqueioComercialPedidoVenda():New()
	Local oAprPed	:= TAprovaPedidoVendaEMail():New() 

	
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(xFilial("SC5") + cNumPed))		
		 		
		oBlqCom:cNumPed 		:= cNumPed
		oBlqCom:Inclui()
		
		//TODO DESCOMENTAR
		//If lEMail .And. Upper(AllTrim(GetEnvServer())) $ "PRODUCAO/REMOTO"
	
			oAprPed:cNumPed 		:= cNumPed
			oAprPed:Envia()
		
		//EndIf
			
	
	EndIf
	
	
	RestArea(aArea)
	
Return()


// Função para teste de envio de e-mail de aprovação
User Function BIAF082A()

/*
--Pablo S. Nascimento
--SQL util para buscar exemplos de pedidos conforme necessidade e que irao enviar email

SELECT C5_YITEMCT, C5_YCLVL, * FROM SC5010 SC
INNER JOIN ZKL010 ZKL on SC.C5_NUM = ZKL.ZKL_PEDIDO
WHERE 					 							
	ZKL.D_E_L_E_T_ 			= ' ' AND 
	SC.D_E_L_E_T_ 			= ' ' AND				
	ZKL_STATUS		= '1' 
	AND SC.C5_YITEMCT <> ' '
	AND SC.C5_YCLVL <> ' '
	--AND SC.C5_YSUBTP = 'G'		
	--and (select sum(SC6.C6_YDNV) from SC6070 SC6
	--		where SC6.C6_NUM = SC.C5_NUM) > 0
	ORDER BY ZKL.R_E_C_N_O_	desc
	
--SQL util para buscar pedidos e aprovadores de exemplo para testar workflow
SELECT * 								
	 FROM ZKL070
	WHERE 	1=1										
	D_E_L_E_T_ 			= ''						
	AND ZKL_PEDIDO		= 'F08304'			
	AND ZKL_FILIAL		= '01'		
	AND ZKL_STATUS		= '1'						
	ORDER BY R_E_C_N_O_	desc

*/
	Default cNumPed 		:= ''
	Default cCodAprov		:= ''
	
	RPCSetEnv("01", "01")
	
		oAprPed	:= TAprovaPedidoVendaEMail():New()
		
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5") + cNumPed))		
			 		
			oAprPed:cNumPed 		:= cNumPed
			oAprPed:cCodApr			:= cCodAprov
			oAprPed:Envia()
							
		EndIf
	
	RpcClearEnv()	
	
Return()