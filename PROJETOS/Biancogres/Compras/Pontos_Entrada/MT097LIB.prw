#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"

/*
##############################################################################################################
# PROGRAMA...: MT097LIB         
# AUTOR......: Rubens Junior  (FACILE SISTEMAS)
# DATA.......: 26/06/2014                      
# DESCRICAO..: Ponto de entrada executado na rotina MATA097, quano existe C7_MOEDA = 0 OU EM BRANCO
# 	(NECESSARIO USAR ESSE P.E. POIS NAO EXISTE NO PROJETO OS FONTES DO ZAGO PARA CORRIGIR O ERRO NA ORIGEM)
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/

User Function MT097LIB()

Local Enter  := CHR(13)+CHR(10)
Local lMoeda := .F.

	cQuery := 	""
	cQuery +=	"SELECT C7_NUM,C7_MOEDA FROM "+RetSqlName("SC7")+" SC7 " 	+ Enter
	cQuery +=	"WHERE C7_NUM   = '"+SCR->CR_NUM+"'			AND " 	+ Enter
	cQuery +=	" C7_FILIAL = '"+xFilial("SC7")+"'	AND "	+ Enter
	cQuery +=	" D_E_L_E_T_ = '' "
	TCQuery cQuery Alias "QRY" New  
	
	DbSelecTArea("QRY")
	While !QRY->(EOF())
		If Empty(QRY->C7_MOEDA) .Or. (QRY->C7_MOEDA == 0)
			lMoeda := .T.  			
		EndIf 
		QRY->(DbSkip())	
	EndDo
	
	QRY->(DbCloseArea())     
	
	If lMoeda		 
		cQuery := 	""
		cQuery +=	"UPDATE "+RetSqlName("SC7")+" SET C7_MOEDA = 1 " 	+ Enter
		cQuery +=	"WHERE C7_NUM   = '"+SCR->CR_NUM+"'			AND " 	+ Enter
		cQuery +=	" C7_FILIAL = '"+xFilial("SC7")+"'	AND "	+ Enter
		cQuery +=	" D_E_L_E_T_ = '' AND (C7_MOEDA  ='' OR C7_MOEDA = 0) "
		TCSQLExec(cQuery)	     	
	EndIf			 	
return