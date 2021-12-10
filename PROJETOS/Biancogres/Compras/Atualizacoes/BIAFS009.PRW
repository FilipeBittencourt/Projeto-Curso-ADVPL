#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFS009
Consulta Padrão F3 a ser chamada pelo campo ZNC_CODPRV (RPV)
@author Emerson Salvador
@since 30/08/2021
@version 1.0
@type function
/*/

User Function BIAFS009()

	Local aArea		:= GetArea()
	Local cTitulo 	:= "RPV´s"
	Local cAlias	:= "ZNC"
	Local cTitCampo	:= "RPV"
	Local cCpoChave	:= "ZNC_CODRPV"	 					//obrigatorio	
	Local cMascara	:= "@!"	
	Local nTamCpo	:= TamSx3("ZNC_CODRPV")[1] 			//obrigatorio	    
	Local cRetCpo	:= "uCRet1"							//obrigatorio
	Local nColuna	:= 1
	Local cCodigo	:= &(ReadVar())						//pego o conteudo e levo para minha consulta padrão			

	Local cQuery 	:= " SELECT PROTOCOLO ZNC_CODRPV FROM VW_RPV_ENCERRADA (NOLOCK) "

	Private bRet 	:= .F. 	
	Public uCRet1	:= ""

	
	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)

	RestArea( aArea )

Return .T. 
