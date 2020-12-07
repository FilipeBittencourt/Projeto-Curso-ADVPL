#INCLUDE 'PROTHEUS.CH'

//---------------------------------------------------------------------------------------------
// Autor: 		Julio
// Data: 		24/11/2014
// Descrição: 	Aviso de Cancelamento de Férias - Exclusão data programação
//---------------------------------------------------------------------------------------------
User Function GP030CAN()
Local lContinua := MsgYesNo( "Deseja realmente excluir? Será necessario informar nova data de Programaçao.", "Atenção" ) 
Local aArea 	:= GetArea()

DbSelectArea("SRF")
DbSetOrder(1)
DbSeek(xFilial("SRF")+SRA->RA_MAT)

Reclock("SRF",.F.)
SRF->RF_DATAINI := cTOd("  /  /  ")
MsUnLock()
RestArea(aArea)

Return ( lContinua )
//---------------------------------------------------------------------------------------------