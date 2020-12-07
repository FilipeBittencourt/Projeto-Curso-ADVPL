#Include "protheus.ch" 
#Include "rwMake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FA070CA3
//FA070CA3 - Verifica cancelamento
	O ponto de entrada FA070CA3 sera executado antes da entrada na rotina cancelamento de baixa
	do contas a receber, para verificar se esta pode ou nao ser cancelada..
@author Pedro Henrique
@since 03/05/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

User Function FA070CA3()

Local lRet := .T.
                                                                                 	
	lRet := ValidaSE3()

Return(lRet)


Static Function ValidaSE3()
	
	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local cChave		:= ""
	Local aVend			:= {}
	Local cCodVend		:= ""
	Local nI			:= 0
	Local cMsg			:= ""
	Local cAliasTrab	:= Nil
	Local cQuery		:= ""
	
	If (!Empty(SE1->E1_VEND1))
		Aadd(aVend, SE1->E1_VEND1)
	EndIf
	
	If (!Empty(SE1->E1_VEND2))
		Aadd(aVend, SE1->E1_VEND2)
	EndIf
	
	If (!Empty(SE1->E1_VEND3))
		Aadd(aVend, SE1->E1_VEND3)
	EndIf
	
	If (!Empty(SE1->E1_VEND4))
		Aadd(aVend, SE1->E1_VEND4)
	EndIf
	
	If (!Empty(SE1->E1_VEND5))
		Aadd(aVend, SE1->E1_VEND5)
	EndIf
		
	cMsg += "Registro não pode ser alterado"+CRLF+CRLF
	cMsg += "Comissão já quitada"+CRLF
				
	For nI:=1 To Len (aVend)
		
		cCodVend := aVend[nI]
		cAliasTrab 	:= GetNextAlias()
		
		cQuery := "SELECT * FROM "+RetSQLName("SE3")+" "
		cQuery += " WHERE "
		cQuery += " E3_FILIAL 		= '"+xFilial("SE3")+"' "
		cQuery += " AND E3_VEND		= '"+cCodVend+"' "
		cQuery += " AND E3_PREFIXO 	= '"+SE1->E1_PREFIXO+"' "
		cQuery += " AND E3_NUM 		= '"+SE1->E1_NUM+"' "
		cQuery += " AND E3_PARCELA 	= '"+SE1->E1_PARCELA+"' "
		cQuery += " AND E3_EMISSAO 	= '"+dtos(DDATABASE)+"' "
		cQuery += " AND D_E_L_E_T_ 	= '' "
		cQuery += " AND E3_BASE > 0 "
		
		TCQUERY cQuery NEW ALIAS cAliasTrab	
		
		If !(cAliasTrab->(Eof()))
		
			If (!Empty(cAliasTrab->E3_DATA))
				
				If (!Empty(cMsg))
					cMsg += CRLF
				EndIf
				
				cMsg += "Vendedor...: "+cCodVend
				cMsg += ", Prefixo...: "+SE1->E1_PREFIXO
				cMsg += ", Numero....: "+SE1->E1_NUM
				cMsg += ", Parcela...: "+SE1->E1_PARCELA+CRLF
				
				lRet := .F.
			EndIf
			
		EndIf
		
		cAliasTrab->(DbCloseArea())
		
	Next nI
	
	If (!lRet) 
		MsgBox(cMsg,"Baixa","INFO")
	EndIf
		
	RestArea(aArea)
Return lRet
