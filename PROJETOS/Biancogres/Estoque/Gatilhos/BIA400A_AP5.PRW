#include "rwmake.ch"

/*/{Protheus.doc} Bia400A
@author BiancoGres
@since 08/06/00
@version 1.0
@description Gatilho do Campo D3_YMATRIC - Seq.001 
@type function
/*/

User Function Bia400A()

	Local xn

	If Type("_ExecAutoII") <> "U"

		cCLVL := Gdfieldget("D3_CLVL",n)
		Return ( cCLVL )

	EndIf

	If Upper(Alltrim(FUNNAME())) == "MATA240" .or. UPPER(ALLTRIM(FUNNAME())) == "BIA294"

		If Alltrim(cUserName) $ "ALETEIA"
			wD3_CLVL := ""
			Return(wD3_CLVL)
		EndIf

		If Empty(M->D3_CLVL) .or. M->D3_CLVL == SRA->RA_CLVL
			wD3_CLVL := SRA->RA_CLVL
		Else
			wD3_CLVL := M->D3_CLVL
		Endif

		Return ( wD3_CLVL )

	Elseif UPPER(ALLTRIM(FUNNAME())) == "MATA241" .and. inclui

		For xn := 1 to Len(aHeader)
			xcCampo := Trim(aHeader[xn][2])
			If xcCampo == "D3_CLVL"
				If Alltrim(cUserName) $ "ALETEIA"
					CCC := ""
				Else
					If Empty(CCC) .OR. CCC == SRA->RA_CLVL
						CCC := SRA->RA_CLVL
					Endif
				Endif
			Endif
		Next

		Return ( Gdfieldget('D3_CLVL', n) )

	Endif

Return