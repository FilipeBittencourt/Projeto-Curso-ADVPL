#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"


/*/{Protheus.doc} BIAFG025
@author Gabriel Rossi Mafioletti
@since 07/11/2017
@version 1.0
@description Valid Temporário para Relatório FINR130 pois o mesmo não considera o parametro
@type function
/*/


User Function BIAFG025()

Local _aArea	:=	SX1->(GetArea())
Local _cData	:= "'" +	SUBSTR(DTOS(MV_PAR36),7,2)+'/'+SUBSTR(DTOS(MV_PAR36),5,2)+'/'+SUBSTR(DTOS(MV_PAR36),3,2) + "'"

SX1->(DbSetOrder(1))

If SX1->(DbSeek("FIN130    " + "36"))

	Reclock("SX1",.F.)
	SX1->X1_CNT01	:=	_cData
	SX1->(MsUnlock())

EndIf

RestArea(_aArea)

Return .T.