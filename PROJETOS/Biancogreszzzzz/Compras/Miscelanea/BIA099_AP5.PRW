#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA099
@author RANISSES A. CORONA
@since 22/03/16
@version 1.0
@description Numero de Solicitação de Compras
@obs Ajuste para controle de numeração nas demais empresas
@type function
/*/

User Function Bia099()

	Local qpAlias := Alias()
	Local wNumSC := ""
	Local cSql   := ""

	//Procura o ultimo valor numerico do codigo e o incrementa de 1. ³

	CONOUT("cEmpAnt : " + cEmpAnt  )

	If cEmpAnt == "01"
		If Alltrim(Funname()) == "MATA110"

			CONOUT("MATA110 : " + cEmpAnt  )

			DbSelectArea("SC1")
			DbSetOrder(1)
			DbSeek(xFilial("SC1")+"99999A",.T.)
			DbSkip(-1)
			wNumSC := StrZero(Val(SC1->C1_NUM)+1,6)

			CONOUT("1wNumSC : " + wNumSC  )

		Else

			CONOUT("NOT MATA110: " + cEmpAnt  )

			cSql := "SELECT MAX(C1_NUM) NUMSC FROM SC1"+AllTrim(cEmpAnt)+"0 WHERE C1_FILIAL = '"+xFilial("SC1")+"' AND LEN(C1_NUM) >= 6 AND D_E_L_E_T_ = '' "
			IF SELECT("RAC") > 0
				RAC->(DBCLOSEAREA())
			ENDIF

			CONOUT("2cSql : " + cSql  )

			TCQUERY cSQL New Alias "RAC"
			wNumSC := Soma1(RAC->NUMSC,6)

			CONOUT("2wNumSC : " + wNumSC  )

		EndIf

	Else

		CONOUT("NOT MATA110: " + cEmpAnt  )

		cSql := "SELECT MAX(C1_NUM) NUMSC FROM SC1"+AllTrim(cEmpAnt)+"0 WHERE C1_FILIAL = '"+xFilial("SC1")+"' AND LEN(C1_NUM) >= 6 AND D_E_L_E_T_ = '' "
		IF SELECT("RAC") > 0
			RAC->(DBCLOSEAREA())
		ENDIF

		CONOUT("3cSql : " + cSql  )

		TCQUERY cSQL New Alias "RAC"
		wNumSC := Soma1(RAC->NUMSC,6)

		CONOUT("3wNumSC : " + wNumSC  )

	EndIf

	dbSelectArea(qpAlias)

Return(wNumSC)
