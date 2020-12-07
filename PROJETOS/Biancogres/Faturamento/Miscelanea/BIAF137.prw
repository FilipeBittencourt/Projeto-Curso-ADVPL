#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF137
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Função para Manutencao de Vistorias em Obras de Engenharia
@obs Ticket: 19122
@type function
/*/

User Function BIAF137()
Local oParam := TParBIAF137():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Selecionando Vistorias...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


Static Function fProcess(oParam)
Local oObj := Nil
		
	oObj := TWVistoriaObraEngenharia():New(oParam)

	oObj:Activate()

Return()