#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
##############################################################################################################
# PROGRAMA...: MT160WF         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 27/06/2014
# DESCRICAO..: P.E. EXECUTADO NA FINALIZACAO DA ANALISE DE COTACAO (MATA160)PARA LIMPAR REGISTRO SCR QUE E
# 		FEITO PELO WFW120P QUANDO O PED. COMPRA EH INCLUSO MANUALMENTE
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function MT160WF()      

Local cNumPed := SC7->C7_NUM

IF cempant $ ("01_05_06_07_12_13_14_16")
	
	DbSelectArea("SCR")
	DbSetOrder(1)
	If DbSeek(xFilial("SCR")+"PC"+cNumPed)
		While !SCR->(Eof()) .And. SCR->CR_FILIAL == cFilAnt .And. AllTrim(SCR->CR_NUM) == AllTrim(cNumPed)
			While !Reclock("SCR",.F.);EndDo
			SCR->CR_YDTINCL := dDataBase
			MsUnlock()
					
			SCR->(DbSkip())
		EndDo
	EndIf
	
	U_BIAF107(SC8->C8_NUM)
	
ENDIF

	If (SUPERGETMV("MV_YRTPAY", .F., .T.))
		//RequestToPay
		U_RETP0006()
	EndIf	
                         
Return
