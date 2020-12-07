#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0019; Return()

/*
|-----------------------------------------------------------|
| Classe: | TConsumoProdutoComum														|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 27/04/15																			  |
|-----------------------------------------------------------|
| Desc.:	|	Class para calculo do consumo mensal de produtos|
| 				|	comuns						 															|
|-----------------------------------------------------------|
| OS:			|	N/A - Usuário: Wanisay William 									|
|-----------------------------------------------------------|
*/


Class TConsumoProdutoComum From LongClassName
	
	Data oInterface
	Data oLst
	
	Method New() Constructor
	Method Get()
 	Method Set()

EndClass


Method New() Class TConsumoProdutoComum
	
	::oInterface	:= TIConsumoProdutoComum():New()
	
	::oLst := ArrayList():New()
	
Return()


Method Get(oParam) Class TConsumoProdutoComum
Local cSQL := ""
Local Qry := GetNextAlias()
	        	
	::oLst := ArrayList():New()
	        
	cSQL := "EXEC SP_CONSUMO_PRODUTO_COMUM_"+cEmpAnt + ValToSQL(oParam:dData)
			
	TcQuery cSQL New Alias (Qry)
	  		
	While (Qry)->(!EOF())
			
	 	::oInterface := TIConsumoProdutoComum():New()
	 	
		::oInterface:cEmp := cEmpAnt
		::oInterface:cData := dToS(oParam:dData)
		::oInterface:cPrd := (Qry)->_PRODUTO
		::oInterface:nQtdCon := (Qry)->_QTDCON
			 	
		::oLst:Add(::oInterface)
						
		(Qry)->(dbSkip())
		                                                           
	EndDo
		
	(Qry)->(DbCloseArea())	 	
	 		 		
Return()


Method Set() Class TConsumoProdutoComum
Local nCount := 0
Local cSQL := ""
Local cSB3 := RetSQLName("SB3")

	If ::oLst:GetCount() > 0
	
		For nCount := 1 To ::oLst:GetCount()
		
			cSQL := " UPDATE "+ cSB3
			cSQL += " SET B3_Q"+ SubStr(::oLst:GetItem(nCount):cData, 5, 2) +" = "+ ValToSQL(::oLst:GetItem(nCount):nQtdCon)
				
			cSQL += " WHERE B3_FILIAL = "+ ValToSQL(xFilial("SB3"))
			cSQL += " AND B3_COD = "+ ValToSQL(::oLst:GetItem(nCount):cPrd)
			cSQL += " AND D_E_L_E_T_= '' "
			
			TcSQLExec(cSQL)
		
		Next
	
	EndIf
			
Return()