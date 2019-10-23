#INCLUDE "PROTHEUS.CH"
 
User Function GFEA0514()

Local lRetorno := .T.
  
    dbSelectArea('GW1')
    /*GW1->(dbSetOrder(1)) //GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC
     
    If GW1->(dbSeek(GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC)))
        If GW1->GW1_TPFRET == "6"
            Help( ,, 'HELP',, "Trecho inválido para registro de entrega.", 1, 0,)
            lRetorno := .F.
        EndIf
    EndIf*/
 
Return lRetorno



/*/{Protheus.doc} CUSTOMERVENDOR
PE APÓS A GRAVAÇÃO DA GWU
PARAMETROS -> INCLUIR = 3 ALTERAR = 4 EXCLUIR = 5
@type function
@author WLYSSES CERQUEIRA (FACILE)
@since 12/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
		/*
User Function GFEA044()
	
	Local aParam     := PARAMIXB

	Local xRet       := .T.
	Local oObj       := Nil
	Local cIdPonto   := ''
	Local cIdModel   := '' 
	Local cCampo     := ''
	Local cTipo      := ''	 
	Local oModel	
	Local cFunName   := FunName()
	
	If cFunName $ "MATA103"		
		//ConOut("> "+aParam[2])
		
If PARAMIXB <> NIL	
		 
			//Pega informações dos parâmetrosadm
			oObj     := aParam[1]
			cIdPonto := aParam[2]
			cIdModel := aParam[3]

	 
			//Pré configurações do Modelo de Dados
			If cIdModel == "GFEA044_GWU" 
			
				If (cIdPonto == "FORMPRE") //'MODELCOMMITNTTS'
					nOper  := oObj:GetModel(cIdPonto):nOperation
					cTipo  := aParam[4]
					cCampo := aParam[6]

					//Se for inclusão
					If nOper == 3 .AND. Alltrim(cCampo) $ ("GWU_NRCIDO.GWU_NRCIDD")	
						oModel  := FWModelActive()					
						oModel:SetValue('GFEA044_GWU', 'GWU_NRCIDO', "3200136") // cidade Origem 3201506
						oModel:SetValue('GFEA044_GWU', 'GWU_NRCIDD', "3200201") // cidade Destino	
									 
						//setTrecho()
					EndIf
				EndIf
			Endif


		EndIF
	EndIF

Return(xRet)
*/