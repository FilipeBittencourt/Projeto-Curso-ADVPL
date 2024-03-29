#INCLUDE 'PROTHEUS.CH'

//---------------------------------------------------------------------------------------------
// Autor: 		Julio
// Data: 		24/11/2014
// Descri��o: 	Aviso de Cancelamento de F�rias - Exclus�o data programa��o
//---------------------------------------------------------------------------------------------
User Function GP030CAN()
Local lContinua := MsgYesNo( "Deseja realmente excluir? Ser� necessario informar nova data de Programa�ao.", "Aten��o" ) 
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