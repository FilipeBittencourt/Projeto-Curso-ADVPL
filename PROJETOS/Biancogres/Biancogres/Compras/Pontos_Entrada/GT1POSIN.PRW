#INCLUDE "PROTHEUS.CH"

//PONTO DE ENTRADA DO PRODUTO CONEXÃO NFE
User Function GT1POSIN()
Private nTipoXML := PARAMIXB[1]
Private _oXml  := PARAMIXB[2]

	/* ------------------------------------
	 nTipoXML: 1- Nota Fiscal Eletrônica
	           2- Cancelamento
	-------------------------------------*/
	// Elimina objeto
	//	FreeObj(_oObjXML)
	//	_oObjXML := Nil

	// ********** Monta um Vetor com os Dados do Arquivo XML ***************
	If nTipoXML == 1
		lRet := U_BIA657(_oXml, .T.,"G")
	EndIf
Return