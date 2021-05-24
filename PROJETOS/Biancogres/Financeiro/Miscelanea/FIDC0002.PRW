#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FIDC0002(cCnpj, cNumPar, nValor)

	Local aAreaSA2		:= Nil
	Local cQuery 		:= ""
	Local cAliasTemp	:= Nil
	Local aListEmp		:= {'01', '05', '06', '07'}
	Local nI			:= 0
	Local cEmp			:= ""
	Local aEmpTitulo	:= {}
	Local _cEnter		:= Chr(13)+Chr(10)
	
	Default cCnpj 		:= ''
	Default cNumPar		:= ''
	
	If (!Empty(cCnpj) .And. !Empty(cNumPar))
	
		aAreaSA2	:= SA2->(GetArea())
		cAliasTemp	:= GetNextAlias()
		
		DbSelectArea('SA2')
		SA2->(DbSetOrder(3))//A2_FILIAL, A2_CGC, R_E_C_N_O_, D_E_L_E_T_
		SA2->(DbSeek(xFilial('SA2')+cCnpj))
		
		For nI:=1 to Len (aListEmp)
			
			cEmp	:= aListEmp[nI]
			
			cQuery += " SELECT EMPRESA='"+cEmp+"', FILIAL=E2_FILIAL,ID=R_E_C_N_O_													"
			cQuery += " FROM " + RetFullName('SE2', cEmp)+" SE2																		"
			cQuery += " WHERE 1=1																									"		
			cQuery += " AND SE2.E2_NUM+SE2.E2_PARCELA	= " + ValToSQL(cNumPar)+"													"
			cQuery += " AND SE2.E2_FORNECE 			= " + ValToSQL(SA2->A2_COD)+" 													"
			cQuery += " AND SE2.E2_LOJA 			= " + ValToSQL(A2_LOJA)+"	 													"
			cQuery += " AND SE2.E2_SALDO 			> 0							 													"
			
			If (nValor > 0)
				cQuery += " AND SE2.E2_VALOR 			= " + ValToSQL(cvaltochar(nValor))+"										"
			EndIf
			
			cQuery += " AND SE2.D_E_L_E_T_ = '' 																					"
			cQuery += " GROUP BY E2_FILIAL, R_E_C_N_O_																				"+_cEnter
			
			If (nI < Len (aListEmp))
				cQuery += " UNION ALL			 																					"+_cEnter
			EndIf
				
		Next nI
		
		ConOut(cQuery)
		
		TcQuery cQuery New Alias (cAliasTemp)
		
		While ( !(cAliasTemp)->(Eof()))
			Aadd(aEmpTitulo, {(cAliasTemp)->EMPRESA, (cAliasTemp)->FILIAL, (cAliasTemp)->ID})
			(cAliasTemp)->(DbSkip())
		EndDo
		
		(cAliasTemp)->(DbCloseArea())
		
		SA2->(RestArea(aAreaSA2))
		
		If Len(aEmpTitulo) == 1
			Return aEmpTitulo[1]
		EndIf
		//TODO se existir mais de 1 aconteu colisão no filtro
		//TRATAR Envio de e-mail, deveria existir apenas um titulo aberto
	
	EndIf
	
Return {"", "", ""} 
