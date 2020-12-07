#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Funcao: 	| BIAF028										|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas		|
| Data:		| 07/03/16										|
|-----------------------------------------------------------|
| Desc.:	|	Atualiza codigo do produto x fornecedor ao 	|
| 			|	gravar o Cotacao/pedido de compra  			|
|-----------------------------------------------------------|
| OS:		|	0837-16 - Carlos Junqueira					|
|-----------------------------------------------------------|
*/

User Function BIAF028(cCodFor, cLojFor, cCodPrd, cPrdFor)
Local aArea := GetArea()
Local lExist := .F.
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSA5 := RetSQLName("SA5")
	
	If !Empty(cPrdFor)
	
		DbSelectArea("SA5")
		DbSetOrder(1)	
		lExist := SA5->(DbSeek(xFilial("SA5") + cCodFor + cLojFor + cCodPrd))
					
		If (lExist .And. SA5->A5_CODPRF <> cPrdFor) .Or. !lExist
						
			cSQL := " SELECT ISNULL(MAX(LTRIM(RTRIM(A5_FABR))), '') AS SEQFAB "
			cSQL += " FROM " + cSA5
			cSQL += " WHERE A5_FILIAL = " + ValToSQL(xFilial("SA5"))
			cSQL += " AND A5_FORNECE = "+ ValToSQL(cCodFor)
			cSQL += " AND A5_LOJA = "+ ValToSQL(cLojFor)
			cSQL += " AND A5_PRODUTO = "+ ValToSQL(cCodPrd)
			cSQL += " AND D_E_L_E_T_ = '' "
			
			TcQuery cSQL New Alias (cQry)
			
			
			If lExist .And. (Empty(SA5->A5_CODPRF) .Or. Empty((cQry)->SEQFAB))

				RecLock("SA5", .F.)
			
					SA5->A5_CODPRF := cPrdFor
					SA5->A5_FABR := Soma1((cQry)->SEQFAB)
					SA5->A5_FALOJA := Space(2)
				
				SA5->(MsUnlock())
			
			Else
							
				RecLock("SA5", .T.)
			
					SA5->A5_FILIAL := xFilial("SA5")
					SA5->A5_FORNECE := cCodFor
					SA5->A5_LOJA := cLojFor
					SA5->A5_NOMEFOR := Posicione("SA2", 1, xFilial("SA2") + cCodFor + cLojFor, "A2_NOME")
					SA5->A5_PRODUTO := cCodPrd
					SA5->A5_NOMPROD := Posicione("SB1", 1, xFilial("SB1") + cCodPrd, "B1_DESC")
					SA5->A5_CODPRF := cPrdFor
					SA5->A5_FABR := Soma1((cQry)->SEQFAB)
					SA5->A5_FALOJA := Space(2)
					
				SA5->(MsUnlock())
			
			EndIf
			
			(cQry)->(DbCloseArea())
															
		EndIf				
												
	EndIf
	
	RestArea(aArea)

Return()