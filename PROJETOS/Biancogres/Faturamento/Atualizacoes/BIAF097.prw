#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF097
@author Tiago Rossini Coradini
@since 07/02/2018
@version 1.0
@description Rotina para buscar motivos de cancelamento dos pedidos de venda 
@obs Ticket: 2123
@type Function
/*/

User Function BIAF097(cMot)
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT X5_DESCRI "
	cSQL += " FROM " + RetSqlName("SX5")
	cSQL += " WHERE X5_FILIAL = " + ValToSQL(xFilial("SX5"))
	cSQL += " AND X5_TABELA = 'ZZ' "
	cSQL += " AND X5_CHAVE = " + ValToSQL(cMot)
	cSQL += " AND D_E_L_E_T_ = '' " 

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->X5_DESCRI)				
		
		 cRet := (cQry)->X5_DESCRI
	
	Else
	
		cRet := fRetMotAnt(cMot)
		
	EndIf
	
	(cQry)->(DbCloseArea()) 

Return(cRet)


// Retorna motivos antigos, que foram removidos do cadastro 
Static Function fRetMotAnt(cMot)
Local cRet := ""

		If cMot == '001' 
		
		cRet := 'SUBSTITUIÇÃO DE PEDIDO'
		 
	ElseIf cMot == '002' 
		
		cRet := 'REPROVADO PELO FINANCEIRO'
		 
	ElseIf cMot == '003' 
		
		cRet := 'SOLICITADO PELO REPRESENTANTE/CLIENTE'
		 
	ElseIf cMot == '004' 
		
		cRet := 'PEDIDOS PARADOS EM CARTEIRA'
		 
	ElseIf cMot == '005'
		
		cRet := 'PRODUTO SEM ESTOQUE / FORA DE LINHA'
		 
	ElseIf cMot == '006'
		
		cRet := 'PEDIDO EM DUPLICIDADE'
		 
	ElseIf cMot == '007'
		
		cRet := 'ORÇAMENTO ENVIADO ERRADO'
		 
	ElseIf cMot == '008'
		
		cRet := 'ALTERAÇÃO ST'
		 
	ElseIf cMot == '009'
		
		cRet := 'ORÇAMENTO RECUSADO'
		 
	ElseIf cMot == '010'
		
		cRet := 'PEDIDO DUPLICADO LM'
		 
	ElseIf cMot == '011'
		
		cRet := 'SALDO DE PEDIDO À INDUSTRIALIZAR'
		 
	ElseIf cMot == '012'
		
		cRet := 'CANCELAMENTO DE SALDO SOLICITADO PELO REPRESENTANTE'
		 
	ElseIf cMot == '013'
		
		cRet := 'CANCELAMENTO DE SALDO REALIZADO PELO ATENDENTE'
		 
	ElseIf cMot == '014'
		
		cRet := 'CLIENTE DESISTIU DA MERCADORIA'
		 
	ElseIf cMot == '015'
		
		cRet := 'PEDIDO ENVIADO ERRADO POR PARTE DO REPRESENTANTE'
		 
	ElseIf cMot == '016'
		
		cRet := 'SALDO DE ITEM DE PEDIDO'
		 
	ElseIf cMot == '017'
		
		cRet := 'PRODUTO NÃO LOCALIZADO NO ESTOQUE'
		 
	ElseIf cMot == '018'
		
		cRet := 'NAO INCLUIR A NORMA'
		 
	ElseIf cMot == '019'
		
		cRet := 'PRODUTO REMANEJADO'
		 
	EndIf
	
Return(cRet)