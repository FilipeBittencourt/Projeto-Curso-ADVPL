#Include 'Protheus.ch'
#Include "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH  "
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"

/*/{Protheus.doc} PTX0013
Função para impressão da DANFE
@type Function
@author Pontin
@since 14/06/2016
@version 1.0
/*/
User Function TESTPTX()

 
	DbSelectArea("ZZZ")
	ZZZ->(DbSetOrder(1)) // ZZZ_FILIAL, ZZZ_CHAVE, R_E_C_N_O_, D_E_L_E_T_
	ZZZ->(DbGoTop())	
	 
	If ZZZ->(DbSeek("0152170503657569000384550010000097721214114687"))
		u_PTX0013("NOME_DO_ARQUIVO")
	EndIf

return 
 
	 