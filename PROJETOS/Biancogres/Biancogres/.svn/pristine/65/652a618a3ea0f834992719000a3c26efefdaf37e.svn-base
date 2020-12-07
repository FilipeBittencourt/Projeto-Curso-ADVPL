#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function MT440AT
Local lRetorno := .T. 
 
If SC5->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES","14")))
	lRetorno := U_FROPVLPV(SC5->C5_NUM)
	If lRetorno .And. cEmpAnt == '01' .And.  Alltrim(SC5->C5_YSUBTP) $ GETNEWPAR('MV_YTIPAMO',"A#F#M") .And. Dtos(SC5->C5_EMISSAO) > '20180723'
		U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE","Não é possível liberar o pedido "+SC5->C5_NUM+"."+CRLF+"O mesmo é um pedido de Amostra.",,,"PEDIDO DE AMOSTRA")
		_lRetorno := .F.
		
	EndIf
		
EndIf

Return(lRetorno)