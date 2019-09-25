#include 'protheus.ch'
#include 'totvs.ch'
#include "RWMAKE.ch"
 
//U_testeZ
User Function testeZ()


    Local oZQRCODE := TZEBRAqrcode():New()  
	Local lRet	   := .T.
	Local cQRCOD   := ""
	
	Local aParam := {"08", "01"}	
	RpcSetType(3)
	RpcSetEnv(aParam[1],aParam[2],,,"COM")

	SA1->(DbSetOrder(1)) //A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_
	If SA1->(DbSeek(xFilial("SA1")+"000046"+"01"))

		oZQRCODE:cCEPDest := SA1->A1_CEP
		oZQRCODE:cCEPComD := ""
		oZQRCODE:cCEPOrig := ""
		oZQRCODE:cCEPComO := ""
		oZQRCODE:cValCEPD := ""
		oZQRCODE:cIDV     := ""
                          
		oZQRCODE:cEtiquet := ""
		oZQRCODE:cServAdd := ""
		oZQRCODE:cCarPost := ""
		oZQRCODE:cCodServ := ""
		oZQRCODE:cInfoAgr := ""
		oZQRCODE:cNLograd := ""
		oZQRCODE:cCLograd := SA1->A1_END
		oZQRCODE:cVlrDecl := ""
		oZQRCODE:cTelDest := AllTrim(SA1->A1_DDD)+AllTrim(SA1->A1_TELEX)
		oZQRCODE:cLatitud := ""
		oZQRCODE:cLongitu := ""
		oZQRCODE:cPipe	  := ""
		oZQRCODE:cObsCli  := "" 
	

		cQRCOD := oZQRCODE:GeraQRCODE(oZQRCODE)

	EndIf 

Return lRet
