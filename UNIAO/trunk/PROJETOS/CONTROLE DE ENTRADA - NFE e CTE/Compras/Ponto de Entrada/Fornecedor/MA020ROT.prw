#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MA020ROT
PE PARA ADICAO DE BOTOES NA MBROWSE
NO CADASTRO DE FORNECEDORES.
@type function
@author WLYSSES CERQUEIRA (FACILE)
@since 25/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function MA020ROT()	
	Local aArea 	:= SA2->(GetArea())
	Local aRotina_ := {}	
	aAdd(aRotina_, { OemToAnsi("Rota x Fornecedor"), "U_XDataZZ0", 0, 2})		
	RestArea(aArea)		
	
Return(aRotina_)
 
User function XDataZZ0()
 	  
 	Local aArea :=  ZZ0->(GetArea()) 	 	
 	If (ZZ0->(DbSeek(xFilial("ZZ0")+SA2->A2_COD)))
 		FWExecView(Upper("Rota x Fornecedor"),"VIEWDEF.VIXA256", 4,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)    // Visualizar
 	Else
		FWExecView(Upper("Rota x Fornecedor"),"VIEWDEF.VIXA256", 3,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)    // Visualizar 	
 	EndIf
 	
 	RestArea(aArea) 
return