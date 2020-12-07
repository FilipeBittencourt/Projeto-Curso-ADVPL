#include "rwmake.ch"
#Include "TopConn.ch"
#Include "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TOTAL_RESERVA    ºAutor  ³ MADALENO   º Data ³  14/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ CALCULA O TOTAL DA RESERVA EM (M2) QUANDO E PRESIONADA F12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION TOTAL_RESERVA()
	LOCAL cMSg 		:= ""
	LOCAL nTOTAL 	:= 0
	Local oModelAux := FWModelActive()
	Local cNum		:= SC0->C0_NUM
	Local aColsAux  := []
	Local aHeaderAux:= []
	Local I

	//TRATA MVC NA TELA DE RESERVA
	Local lMVC 		:= .F.
	If Upper(Alltrim(FunName())) == "MATA430"
		lMVC := U_BIAChkMVC()
		If lMVC .And. oModelAux != Nil
			aColsAux 	:= oModelAux:ADEPENDENCY[1][2][1][3]:ACOLS
			aHeaderAux	:= oModelAux:ADEPENDENCY[1][2][1][3]:aHeader
		EndIf
	EndIf

	IF UPPER(ALLTRIM(FUNNAME())) == "MATA430"
		IF ALTERA .OR. INCLUI
			If !lMVC
				nTOTAL := 0
				nPOSQUANT := AScan(aHeader, { |x| Alltrim(x[2]) == 'C0_QUANT'})
				FOR I:= 1 TO LEN(ACOLS)
					nTOTAL += ACOLS[I,nPOSQUANT]
				NEXT
			Else
				nTOTAL := 0
				If aColsAux != Nil
					nPOSQUANT := AScan(aHeaderAux, { |x| Alltrim(x[2]) == 'C0_QUANT'})
					FOR I:= 1 TO LEN(aColsAux)
						nTOTAL += aColsAux[I,nPOSQUANT]
					NEXT
				EndIf
			EndIf
			cMSg := "O TOTAL DA RESERVA " + cNum + " É DE " + Alltrim(Transform(nTOTAL,"@E 999,999.999") +" (M2). ")
			MSGBOX(cMSg ,"INFO","INFO")
		END IF
	END IF

RETURN()
