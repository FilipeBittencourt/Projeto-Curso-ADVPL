#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0011; Return()

/*
|------------------------------------------------------------|
| Classe:	| TWPesquisaPrecoProduto													 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 12/08/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Classe para pesquisa de precos de produtos			 |
|------------------------------------------------------------|
| OS:			|	0069-15 - Usuário: Claudia Carvalho   		 			 |
|------------------------------------------------------------|
*/


Class TPesquisaPrecoProduto From LongClassName

	Data oInterface
	Data oLst
	
	Method New() Constructor
	Method Get(cCodPrd, cCodFor, nPrcCom)

EndClass


Method New() Class TPesquisaPrecoProduto

	::oInterface	:= TIPesquisaPrecoProduto():New()
	::oLst := ArrayList():New()
	
Return()


Method Get(cCodPrd, cCodFor, nPrcCom, lInit) Class TPesquisaPrecoProduto
Local cSQL := ""
Local Qry := GetNextAlias()
	
	Default lInit := .F.
	        	
	::oLst := ArrayList():New()
	        
	cSQL := " SELECT AIB_CODPRO, 
	cSQL += " (SELECT B1_DESC FROM SB1010 WHERE B1_COD = AIB_CODPRO AND D_E_L_E_T_ = '') AS DESPRD, "
	cSQL += " AIB_PRCCOM, AIB_FRETE, AIB_DATVIG, AIB_CODFOR, AIB_LOJFOR, "
	cSQL += " (SELECT A2_NREDUZ FROM SA2010 WHERE A2_COD = AIB_CODFOR AND A2_LOJA = AIB_LOJFOR AND D_E_L_E_T_ = '') AS NOMFOR, "
	cSQL += " (SELECT AIA_CONDPG FROM AIA010 WHERE AIA_FILIAL = AIB_FILIAL AND AIA_CODFOR = AIB_CODFOR AND AIA_LOJFOR = AIB_LOJFOR AND AIA_CODTAB = AIB_CODTAB AND D_E_L_E_T_ = '') AS CONPAG "
	cSQL += " FROM AIB010 "
	cSQL += " WHERE D_E_L_E_T_ = '' "	
	
	If lInit
		
		cSQL += " AND 0 = 1 "

	Else
		
		If !Empty(cCodPrd)
			cSQL += " AND AIB_CODPRO = "+ ValToSQL(cCodPrd)
		EndIf
		
		If !Empty(cCodFor)
			cSQL += " AND AIB_CODFOR = "+ ValToSQL(cCodFor)
		EndIf
		
		If nPrcCom > 0
			cSQL += " AND AIB_PRCCOM LIKE "+ ValToSQL(cValToChar(nPrcCom) + "%")
		EndIf

	EndIf
		
	cSQL += " ORDER BY AIB_CODPRO, AIB_CODFOR, AIB_PRCCOM "
			
	TcQuery cSQL New Alias (Qry)
	  		
	While (Qry)->(!EOF())
			
	 	::oInterface := TIPesquisaPrecoProduto():New()
	 	
		::oInterface:cCodPrd := (Qry)->AIB_CODPRO
		::oInterface:cDesPrd := (Qry)->DESPRD
		::oInterface:nPrcCom := (Qry)->AIB_PRCCOM
		::oInterface:nVlrFrt := (Qry)->AIB_FRETE
		::oInterface:dDtVig := sToD((Qry)->AIB_DATVIG)
		::oInterface:cCodFor := (Qry)->AIB_CODFOR
		::oInterface:cLojFor := (Qry)->AIB_LOJFOR
		::oInterface:cNomFor := (Qry)->NOMFOR
		::oInterface:cConPag := (Qry)->CONPAG
		
		::oLst:Add(::oInterface)
						
		(Qry)->(dbSkip())
		                                                           
	EndDo
		
	(Qry)->(dbCloseArea())
	 		 		
Return(::oLst)