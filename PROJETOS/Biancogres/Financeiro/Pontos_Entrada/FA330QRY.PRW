#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*
##############################################################################################################
# PROGRAMA...: FA330QRY         
# AUTOR......: Ranisses A. Corona
# DATA.......: 21/08/2015                      
# DESCRICAO..: P.E. para amarração dos títulos de RA x Titulos de NF através do Numero do Pedido de Venda
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/

User Function FA330QRY()
Local cQuery 	:= PARAMIXB[1] 
Local cOrdemSE1	:= SE1->(IndexKey()) 
Local cPesq		:= "ORDER"
Local nPosIni	:= AT(cPesq,cQuery)-1

If fAmarraRA()  
	n := MsgBox("Este título possui amarração de RA, referente ao Pedido de Venda "+SE1->E1_PEDIDO+". Deseja exibir somente os títulos da amarração?","FA330QRY","YesNo")
	If n
		cQuery := Substr(cQuery,1,nPosIni)+" AND SE1.E1_PEDIDO = '"+SE1->E1_PEDIDO+"' ORDER BY "+SqlOrder(cOrdemSE1) 
	EndIf
EndIf

Return cQuery

//------------------------------------------------------------------------------------------------------------
//Verifica se o título em questão tem amarração de RA
Static Function fAmarraRA()
Local lRet := .F.
Local cSql := ""
          
cSql := "SELECT COUNT(*) QUANT										"
cSql += "FROM "+RetSqlName("SE1")+" 								"
cSql += "WHERE	E1_FILIAL 	= '"+xFilial("SE1")+"' 			AND 	"
cSql += "		E1_PREFIXO	IN ('RA1','RA2','RA3','RA4') 	AND 	"
cSql += "		E1_TIPO 	= 'RA' 							AND 	"
cSql += "		E1_PEDIDO 	= '"+SE1->E1_PEDIDO+"' 			AND 	"
cSql += "		D_E_L_E_T_ 	= '' 									" 
If chkfile("_RA")
	dbSelectArea("_RA")
	dbCloseArea()
EndIf
TcQuery cSql New Alias "_RA"
DbSelectArea("_RA")

If _RA->QUANT > 0
	lRet := .T.
	_RA->(DbCloseArea())
EndIf

Return lRet